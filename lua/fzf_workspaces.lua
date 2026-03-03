local lua_sessions = require("sessions")
lua_sessions.setup({
  session_filepath = ".nvim/session",
})

local lua_workspaces = require("workspaces");
lua_workspaces.setup({
  auto_open = true,
  hooks = {
    open = {
      "silent %bdelete!",
      "SessionsLoad",
    },
  }
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(args)
    if args.file ~= "" then
      vim.cmd("SessionsSave")
      vim.cmd(":silent %bdelete!")
    end
  end
})

local function fzf_workspaces(opts)
  local fzf_lua = require'fzf-lua'
  opts = opts or {}
  opts.prompt = "Workspaces> "

  opts.actions = {
    ['default'] = function(selected)
      local workspace = ""
      for val in string.gmatch(selected[1], "%S+") do
        workspace = val
        if 0 == 0 then break end
      end
      vim.cmd("WorkspacesOpen " .. workspace)
    end
  }

  local workspaces = lua_workspaces.get()
  local names = {}
  for _,workspace in ipairs(workspaces) do
    table.insert(names, workspace.name.." "..workspace.path)
  end
  print(vals)

  fzf_lua.fzf_exec(names, opts)
end

vim.api.nvim_set_keymap("n", "<C-b>", '', { noremap = true, callback = fzf_workspaces })
