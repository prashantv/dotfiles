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

local setupZig = function()
	lspconfig = require "lspconfig"
	util = require "lspconfig/util"
	lspconfig.zls.setup {
		cmd = {"/home/prashant/zig/zls/zig-out/bin/zls"};
		filetypes = {"zig"};
		root_dir = util.root_pattern("build.zig", ".git");
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
require("lazy").setup("plugins")

setupGopls()
setupZig()

setIndentation()
vim.opt.number = true


