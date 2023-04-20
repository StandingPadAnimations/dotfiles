-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
	"windwp/nvim-autopairs",

	config = function()
    		require("nvim-autopairs").setup {}
		vim.keymap.set("n", "<leader>ga", ":Git add")
		vim.keymap.set("n", "<leader>gc", ':Git commit<CR>')
		vim.keymap.set("n", '<leader>gp', ':Git push<CR>')
	end,

	require("luasnip").config.set_config {
		region_check_events = 'InsertEnter'
	}
}
