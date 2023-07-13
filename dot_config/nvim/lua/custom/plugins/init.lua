-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
	"windwp/nvim-autopairs",
	{
		"kaarmu/typst.vim",
		ft = 'typst',
		lazy = false,
	},
	"NoahTheDuke/vim-just",
	"sindrets/diffview.nvim",
	"mfussenegger/nvim-dap",
	"mrcjkb/haskell-tools.nvim",
	"andweeb/presence.nvim",
	config = function()
    		require("nvim-autopairs").setup {}
		require("presence").setup({
		    neovim_image_text   = "The One True Text Editor",
		    main_image          = "file",
		})
		vim.keymap.set("n", "<leader>ga", ":Git add")
		vim.keymap.set("n", "<leader>gc", ':Git commit<CR>')
		vim.keymap.set("n", '<leader>gp', ':Git push<CR>')
	end,

	require("luasnip").config.set_config {
		region_check_events = 'InsertEnter'
	},
	vim.keymap.set("n", "<leader>bn", ":bNext"),
	vim.keymap.set("n", '<leader>o', ':Oil<CR>')
}
