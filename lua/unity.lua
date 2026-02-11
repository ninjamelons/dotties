--- This will be called on LS initialization to request Roslyn to open the
--- provided solution
---
---@param client vim.lsp.Client
---@param target string
---
---@return nil
local function on_init_sln(client, target)
  vim.notify("Initializing: " .. target, vim.log.levels.INFO)
  ---@diagnostic disable-next-line: param-type-mismatch
  client:notify("solution/open", {
    solution = vim.uri_from_fname(target),
  })
end

--- This will be called on LS initialization to request Roslyn to open the
--- provided project (usually when no solution (.sln) file was found this is
--- used as a fallback).
---
---@param client vim.lsp.Client LSP client (this neovim instance)
---@param project_files string[] set of project files (.csproj) that will be
---requested to be opened by Roslyn LS
---
---@return nil
local function on_init_project(client, project_files)
  vim.notify("Initializing: projects", vim.log.levels.INFO)
  ---@diagnostic disable-next-line: param-type-mismatch
  client:notify("project/open", {
    projects = vim.tbl_map(function(file)
      return vim.uri_from_fname(file)
    end, project_files),
  })
end

--- Tries to find the solution/project root directory using the provided buffer
--- id. This is done by trying to look up the directories until finding a one
--- that contains a .sln file. If that fails, this looks instead for the first
--- .csproj file it encounters.
---
---@param bufnr integer
---@param cb function
local function project_root_dir_discovery(bufnr, cb)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  -- don't try to find sln or csproj for files from libraries outside of the
  -- project
  if not bufname:match("^" .. vim.fs.joinpath("/tmp/MetadataAsSource/")) then
    -- try find '.sln' file (which resides in root dir)
    -- TODO: add support for .slnx and .slnf discovery
    local root_dir = vim.fs.root(bufnr, function(fname, _)
      return fname:match("%.sln$") ~= nil
    end)

    -- in case no '.sln' file was found then look for the first '.csproj' file
    if not root_dir then
      root_dir = vim.fs.root(bufnr, function(fname, _)
        return fname:match("%.csproj$") ~= nil
      end)
    end

    -- TODO: add Unity project root discovery heuristic in case the first opened C#
    -- script is directly part of the project (e.g., opening a file from Library)
    -- TODO: add user-input method for entering the project root manually

    if root_dir then
      cb(root_dir)
    else
      vim.notify(
        "[C# LSP] failed to find root directory - LS support is disabled",
        vim.log.levels.ERROR
      )
    end
  end
end

--- set Roslyn LS handlers. Each handler corresponds to a notification that
--- might be sent by Roslyn LS - you can get the set of Roslyn LSP method names
--- from: https://github.com/dotnet/roslyn/tree/main/src/LanguageServer/Protocol
---
---@type table<string, function>
local roslyn_handlers = {

  -- once Roslyn LS has finished initializing the project, we request
  -- diagnostics for the current opened buffers
  ["workspace/projectInitializationComplete"] = function(_, _, ctx)
    vim.notify("Roslyn project initialization complete", vim.log.levels.INFO)

    local buffers = vim.lsp.get_buffers_by_client_id(ctx.client_id)
    local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
    for _, buf in ipairs(buffers) do
      client:request(vim.lsp.protocol.Methods.textDocument_diagnostic, {
        textDocument = vim.lsp.util.make_text_document_params(buf),
      }, nil, buf)
    end
  end,

  -- this means that `dotnet restore` has to be ran on the project/solution
  -- we can do that manually or, better, request the Roslyn LS instance to do it
  -- for us using the "workspace/_roslyn_restore" request which invokes the
  -- `dotnet restore <PATH-TO-SLN>` cmd
  ["workspace/_roslyn_projectNeedsRestore"] = function(_, result, ctx)
    local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

    ---@diagnostic disable-next-line: param-type-mismatch
    client:request("workspace/_roslyn_restore", result, function(err, response)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR)
      end
      if response then
        local log_lvl = vim.log.levels.INFO
        local t = {}
        for _, v in ipairs(response) do
          t[#t + 1] = v.message
          -- an error could be reported in the message string, if found then
          -- change the log level accordingly
          if string.find(v.message, "error%s*MSB%d%d%d%d") then
            log_lvl = vim.log.levels.WARN
          end
        end
        -- TODO: improve dotnet restore notification message
        -- bombard the user with a shitton of `dotnet restore` messages - this
        -- is actually better than remaining silent since this is only expected
        -- to run once
        vim.notify(table.concat(t, "\n"), log_lvl)
      end
    end)

    return vim.NIL
  end,

  -- Razor stuff that we do not care about
  ["razor/provideDynamicFileInfo"] = function(_, _, _)
    vim.notify(
      "Razor is not supported.\nPlease use https://github.com/tris203/rzls.nvim",
      vim.log.levels.WARN
    )
  end,
}

---@type vim.lsp.ClientConfig
local roslyn_ls_config = {
  name = "roslyn_ls",
  offset_encoding = "utf-8",
  cmd = {
    "dotnet",
    -- <roslyn-ls-path> is a placeholder for the path to the Roslyn LS directory
    "/usr/lib/roslyn-ls/Microsoft.CodeAnalysis.LanguageServer.dll",
    "--logLevel=Error", -- Critical|Debug|Error|Information|None|Trace|Warning
    "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
    "--stdio",
  },
  filetypes = { "cs" },
  handlers = roslyn_handlers,
  ---@diagnostic disable-next-line: assign-type-mismatch
  root_dir = project_root_dir_discovery,
  on_init = {
    function(client)
      local root_dir = client.config.root_dir

      -- try load first solution we find
      for entry, type in vim.fs.dir(root_dir) do
        if type == "file" and vim.endswith(entry, ".sln") then
          on_init_sln(client, vim.fs.joinpath(root_dir, entry))
          return
        end
      end

      -- if no solution is found then load project
      local project_found = false
      for entry, type in vim.fs.dir(root_dir) do
        if type == "file" and vim.endswith(entry, ".csproj") then
          on_init_project(client, { vim.fs.joinpath(root_dir, entry) })
          project_found = true
        end
      end

      if not project_found then
        vim.notify(
          "[C# LSP] no solution/.csproj files were found",
          vim.log.levels.ERROR
        )
      end
    end,
  },
  capabilities = {
    -- HACK: Doesn't show any diagnostics if we do not set this to true
    textDocument = {
      diagnostic = {
        dynamicRegistration = true,
      },
    },
  },
  -- Roslyn-LS-specific settings
  settings = {
    ["csharp|background_analysis"] = {
      dotnet_analyzer_diagnostics_scope = "fullSolution",
      dotnet_compiler_diagnostics_scope = "fullSolution",
    },
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_indexer_parameters = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
      dotnet_enable_inlay_hints_for_other_parameters = true,
      dotnet_enable_inlay_hints_for_parameters = true,
      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
    },
    ["csharp|symbol_search"] = {
      dotnet_search_reference_assemblies = true,
    },
    ["csharp|completion"] = {
      dotnet_show_name_completion_suggestions = true,
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_provide_regex_completions = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
  },
}

-- then add Roslyn LS to core Neovim LSP and enable it
vim.lsp.config("roslyn_ls", roslyn_ls_config)
vim.lsp.enable("roslyn_ls")




-- UNIT DAP
local dap = require("dap")

dap.adapters.unity = function(clbk, config)
  -- options passed to unity-debug-adapter.exe

  -- when connecting to a running Unity Editor, the TCP address of the listening
  -- connection is localhost
  -- on Linux, use: ss -tlp | grep 'Unity' to find the debugger connection
  vim.ui.input(
    { prompt = "address [127.0.0.1]: ", default = "127.0.0.1" },
    function(result)
      config.address = result
    end
  )
  -- then prompt the user for which port the DA should connect to
  vim.ui.input({ prompt = "port: " }, function(result)
    config.port = tonumber(result)
  end)
  clbk({
    type = "executable",
    -- adjust mono path - do NOT use Unity's integrated MonoBleedingEdge
    command = "mono",
    -- adjust unity-debug-adapter.exe path
    args = {
      -- get and install Unity debug adapter from:
      -- https://github.com/walcht/unity-dap
      -- then adjust the following path to where the installed executable is
      "/home/filip/Repos/unity-dap/bin/Release/unity-debug-adapter.exe",
      -- optional log level argument: trace | debug | info | warn | error | critical | none
      "--log-level=error",
      -- optional path to log file (logs to stderr in case this is not provided)
      -- "--log-file=<path_to_log_file_txt>",
    },
  })
end

-- make sure NOT to override other C# DAP configurations
if dap.configurations.cs == nil then
  dap.configurations.cs = {}
end

table.insert(dap.configurations.cs, {
  name = "Unity Editor/Player Instance [Mono]",
  type = "unity",
  request = "attach",
})
