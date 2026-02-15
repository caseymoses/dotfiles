return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,
	priority = 1000,
	opts = {
		flavour = "mocha",
		transparent_background = true,
		integrations = {
			gitsigns = true,
			telescope = true,
			treesitter = true,
			which_key = true,
			mini = true,
			neo_tree = true,
			indent_blankline = { enabled = true },
		},
	},
	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.cmd.colorscheme("catppuccin")
	end,
}
