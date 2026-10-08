return {
	-- Keybindings
	"tpope/vim-repeat",
	"tpope/vim-rsi",

	-- Substitute
	{
		"echasnovski/mini.surround",
		version = "*",
		config = function()
			require("mini.surround").setup()
		end,
	},
	"svermeulen/vim-subversive",
	-- Control case
	"tpope/vim-abolish",
	-- Copy, cut, and paste
	"svermeulen/vim-cutlass",

	-- Detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth",

	-- File management (replaces vim-eunuch)
	{
		"stevearc/oil.nvim",
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
		},
	},

	-- Navigation (quick jumping)
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
		},
	},

	-- Git
	"tpope/vim-fugitive",
	"tpope/vim-git",

	-- GitHub
	{
		"pwntester/octo.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = true,
		cmd = "Octo",
	},

	-- Lark
	"lark-parser/vim-lark-syntax",
}
