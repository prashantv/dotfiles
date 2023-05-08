local initLazyVim = function()
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not vim.loop.fs_stat(lazypath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable", -- latest stable release
			lazypath,
		})
	end
	vim.opt.rtp:prepend(lazypath)
end

local getPlugins = function()
	return {
		 'neovim/nvim-lspconfig',

		 -- Autocompletion
		 {
			 'hrsh7th/nvim-cmp',
			 dependencies = {
				 'hrsh7th/cmp-nvim-lsp', 
				 'hrsh7th/cmp-nvim-lsp-signature-help',
				 'L3MON4D3/LuaSnip',
				 'saadparwaiz1/cmp_luasnip',
			 },
		 },

		 -- Color scheme, similar to Dark+ in VS Code
		 {
			 'martinsione/darkplus.nvim',
			 config = function()
				 vim.cmd[[colorscheme darkplus]]
			 end,
		 },

		 -- Tree
		 {
			 "nvim-tree/nvim-tree.lua",
			 version = "*",
			 config = function()
				 require("nvim-tree").setup({})
			 end,
		 }
	}
end

local setupGopls = function()
	lspconfig = require "lspconfig"
	util = require "lspconfig/util"
	lspconfig.gopls.setup {
    cmd = {"gopls", "serve"},
    filetypes = {"go", "gomod"},
    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
				gofumpt = true,
        staticcheck = true,
      },
    },
  }


	vim.api.nvim_create_autocmd('BufWritePre', {
		pattern = '*.go',
		callback = function()
			vim.lsp.buf.format()
			vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
		end
	})
end

local setupNvimCmp = function() 
	local cmp = require 'cmp'
	local luasnip = require 'luasnip'

	luasnip.config.setup {}

	cmp.setup {
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		mapping = cmp.mapping.preset.insert {
			['<C-n>'] = cmp.mapping.select_next_item(),
			['<C-p>'] = cmp.mapping.select_prev_item(),
			['<C-d>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<C-Space>'] = cmp.mapping.complete {},
			['<CR>'] = cmp.mapping.confirm {
				behavior = cmp.ConfirmBehavior.Replace,
				select = true,
			},
			['<Tab>'] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { 'i', 's' }),
			['<S-Tab>'] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { 'i', 's' }),
		},
		sources = {
			{ name = 'nvim_lsp' },
			{ name = 'luasnip' },
			{ name = 'nvim_lsp_signature_help' }
		},
	}
end


--- Indentation options
local setIndentation = function()
	-- Indent automatically on {}
	vim.opt.cindent = true
	-- display tabs with width=2
	vim.opt.tabstop = 2
	-- use tabstop to determine indentation
	vim.opt.shiftwidth=0
	-- highlight column width 100
	vim.opt.colorcolumn="100"
end

initLazyVim()
require("lazy").setup(getPlugins(), {})

setupGopls()
setupNvimCmp()

setIndentation()
vim.opt.number = true


