local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug 'Mofiqul/vscode.nvim'

Plug('MunifTanjim/nui.nvim')
Plug('nvim-lualine/lualine.nvim')
Plug('topaxi/pipeline.nvim')
Plug('lukas-reineke/indent-blankline.nvim')
Plug('preservim/nerdtree')
Plug('lewis6991/gitsigns.nvim')
Plug('tpope/vim-fugitive')
Plug('windwp/nvim-autopairs')
Plug('nvim-treesitter/nvim-treesitter')
Plug('mg979/vim-visual-multi', { branch = "master" })
Plug('smjonas/inc-rename.nvim')

Plug('junegunn/fzf', { ['do'] = vim.fn['fzf#install'] })
Plug('ibhagwan/fzf-lua', { branch = 'main' })
Plug('nvim-tree/nvim-web-devicons')

Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/nvim-cmp')

Plug('L3MON4D3/LuaSnip')
Plug('saadparwaiz1/cmp_luasnip')

Plug('nvim-lua/plenary.nvim')
Plug('pmizio/typescript-tools.nvim')

Plug('LuaLS/lua-language-server')

Plug('Saecki/crates.nvim')
Plug('mrcjkb/rustaceanvim')

Plug('ray-x/go.nvim')

Plug('varnishcache-friends/vim-varnish')
Plug('towolf/vim-helm', { ft = 'helm' })

vim.call('plug#end')

vim.opt.title = true
vim.api.nvim_create_autocmd({"BufEnter"}, {
	callback = function()
		local pwd = vim.fn.getcwd()
		vim.opt.titlestring = 'nvim - ' .. pwd .. ' - %{expand("%:p:.")}'
	end
})

-- Misc Plugins
vim.o.background = 'dark'
local c = require('vscode.colors').get_colors()
require('vscode').setup({
  underline_links = true,
  terminal_colors = true,
})
require('vscode').load()

require('pipeline').setup({
  build = 'yq',
})
require('lualine').setup({
  sections = {
    lualine_a = {
      { 'pipeline' }
    }
  },
  options = {
    theme = 'vscode',
  }
})

local iblhooks = require('ibl.hooks')
require('ibl').setup({
  scope = { highlight = { "Normal" } },
  viewport_buffer = {
    min = 100
  }
})
iblhooks.register(iblhooks.type.SCOPE_HIGHLIGHT, iblhooks.builtin.scope_highlight_from_extmark)
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

require('gitsigns').setup {
	on_attach = function(buf)
		vim.api.nvim_buf_set_keymap(buf, 'n', ']c', ':Gitsigns next_hunk<CR>', { noremap = true })
		vim.api.nvim_buf_set_keymap(buf, 'n', '[c', ':Gitsigns prev_hunk<CR>', { noremap = true })
	end,
  current_line_blame = true,
}
require('nvim-autopairs').setup()
local treesitter = require('nvim-treesitter.configs')
treesitter.setup({
	ensure_installed = 'all',
  highlight = { enable = true },
	indent = { enable = false },
  auto_install = true,
	autotag = { enable = true, enable_close_on_slash = false },
})

require("inc_rename").setup()

-- Keymaps
vim.api.nvim_set_keymap('n', '<C-ø>', '', { noremap = true, callback = function ()
  vim.cmd("silent !kitty &")
end
})

vim.api.nvim_set_keymap("n", "<leader>rn", ":IncRename ", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>t", ":tabnew | terminal<CR> | :startinsert<CR>", { noremap = true })
vim.api.nvim_set_keymap("t", "<C-\\>l", "<C-\\><C-n> :q <CR>", { noremap = true })

-- FzfLua keymaps
vim.api.nvim_set_keymap('n', '<C-p>', ':FzfLua files winopts.fullscreen=true winopts.preview.wrap=true<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-g>', ':FzfLua live_grep winopts.fullscreen=true winopts.preview.wrap=true<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-\\>', ':FzfLua buffers winopts.fullscreen=true winopts.preview.wrap=true<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', ':FzfLua builtin winopts.fullscreen=true winopts.preview.wrap=true<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-æ>', ':FzfLua lsp_references winopts.fullscreen=true winopts.preview.wrap=true<CR>', { noremap = true })

-- Ctrl Arrow keys (insert/command modes)
vim.api.nvim_set_keymap('i', '<C-h>', '<Left>', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-j>', '<Down>', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-k>', '<Up>', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-l>', '<Right>', { noremap = true })

vim.api.nvim_set_keymap('c', '<C-h>', '<Left>', { noremap = true })
vim.api.nvim_set_keymap('c', '<C-j>', '<Down>', { noremap = true })
vim.api.nvim_set_keymap('c', '<C-k>', '<Up>', { noremap = true })
vim.api.nvim_set_keymap('c', '<C-l>', '<Right>', { noremap = true })

-- Buffer navigation
vim.api.nvim_set_keymap('n', '<Leader><Leader>', '<C-^>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-,>', ':bp<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-.>', ':bn<CR>', { noremap = true })

-- Intellisense/snippets
local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	}, {
		{ name = 'buffer' },
	})
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	}),
	matching = { disallow_symbol_nonprefix_matching = false }
})

-- LSP config
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.api.nvim_buf_set_keymap(args.buf, 'n', ']g', ':lua vim.diagnostic.goto_next()<CR>', { noremap = true })
		vim.api.nvim_buf_set_keymap(args.buf, 'n', '[g', ':lua vim.diagnostic.goto_prev()<CR>', { noremap = true })
		vim.api.nvim_buf_set_keymap(args.buf, 'n', '<C-å>', ':lua vim.lsp.buf.code_action()<CR>', { noremap = true })
    vim.api.nvim_buf_set_keymap(args.buf, 'n', 'å', ':lua vim.lsp.buf.hover()<CR>', { noremap = true })
    vim.api.nvim_buf_set_keymap(args.buf, 'n', 'gl', ':lua vim.diagnostic.open_float()<CR>', { noremap = true })

    -- Quickfix lsp recommendation
    local function quickfix()
      vim.lsp.buf.code_action({
        filter = function(a) return a.isPreferred end,
        apply = true
      })
    end
    vim.keymap.set('n', '<leader>qf', quickfix, { noremap=true, silent=true })
	end
})

require("go").setup()
local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
   require('go.format').gofmt()
   require('go.format').goimports()
  end,
  group = format_sync_grp,
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require("lspconfig")
lspconfig.lua_ls.setup {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc')) then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        }
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
	settings = {
		Lua = {
			diagnostics = {
				globals = { 'vim' }
			}
		}
	},
	capabilities = capabilities,
  filetypes = { 'lua' }
}
lspconfig.ts_ls.setup {
	capabilities = capabilities,
  filetypes = { 'ts', 'js', 'typescript', 'javascript' }
}
lspconfig.pyright.setup {
	capabilities = capabilities,
  filetypes = { 'py', 'python' }
}
lspconfig.kotlin_language_server.setup {
	capabilities = capabilities,
  filetypes = { 'kt', 'kotlin' }
}
lspconfig.java_language_server.setup {
  capabilities = capabilities,
  filetypes = { 'java' },
  cmd = { '/home/filipo/Repos/java-language-server/dist/lang_server_linux.sh' }
}
lspconfig.gopls.setup {
  capabilities = capabilities,
  filetypes = { 'go', 'golang' }
}
lspconfig.r_language_server.setup {
  capabilities = capabilities,
  filetypes = { 'r', 'R', 'rmd' }
}
-- https://github.com/datreeio/CRDs-catalog/tree/main
-- https://www.arthurkoziel.com/json-schemas-in-neovim/
lspconfig.helm_ls.setup {
  capabilities = capabilities,
  filetypes = { 'yaml', 'yml' }
}

-- https://www.npmjs.com/package/fastly-vcl-lsp
-- https://vi.stackexchange.com/questions/42926/how-do-i-add-a-custom-lsp-to-nvim-lspconfig
require('lspconfig.configs').fastly_vcl_lsp = {
  default_config = {
    name = 'fastly-vcl-lsp',
    cmd = { 'node', '/usr/lib/node_modules/fastly-vcl-lsp/out/server.js', '--stdio' },
    root_dir = require('lspconfig.util').root_pattern('.git', '*.vcl'),
    filetypes = { 'vcl' }
  }
}
lspconfig.fastly_vcl_lsp.setup {
  capabilities = capabilities,
  filetypes = { 'vcl' }
}
