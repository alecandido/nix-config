-- Interface improvements

local parent = "plugins.ui"

local snacks = require(parent .. ".snacks")
local barbar = require(parent .. ".barbar")
local gitsigns = require(parent .. ".gitsigns")
local headlines = require(parent .. ".headlines")
local osc52 = require(parent .. ".osc52")
local symbols_outline = require(parent .. ".symbols-outline")

return {
	{ "shaunsingh/nord.nvim", lazy = false, priority = 1000 },
	{ "rebelot/kanagawa.nvim", lazy = true },
	{ "navarasu/onedark.nvim", lazy = true },

	-- Useful plugin to show you pending keybinds.
	{
		"folke/which-key.nvim",
		opts = { preset = "modern" },
	},

	-- Adds git related signs to the gutter, as well as utilities for managing changes
	{
		"lewis6991/gitsigns.nvim",
		opts = gitsigns.opts,
	},

	-- Add indentation guides even on blank lines
	{ "lukas-reineke/indent-blankline.nvim" },

	{
		"lukas-reineke/headlines.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = headlines.opts,
		ft = headlines.ft,
	},

	-- Set lualine as statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
		opts = {
			options = {
				icons_enabled = false,
				component_separators = "|",
				section_separators = "",
			},
		},
	},

	{
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		keys = barbar.keys,
		event = barbar.event,
		version = "^1.0.0",
	},

	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = snacks.opts,
		config = snacks.config,
		keys = snacks.keys,
	},

	{
		"hedyhli/outline.nvim",
		keys = symbols_outline.keys,
		config = function(_, opts)
			require("outline").setup(opts)
		end,
		cmd = symbols_outline.cmd,
		opts = symbols_outline.opts,
	},

	{
		"ojroques/nvim-osc52",
		branch = osc52.branch,
		keys = osc52.keys,
	},
}
