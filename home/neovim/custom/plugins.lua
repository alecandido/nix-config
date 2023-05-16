local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

	-- Override plugin definition options

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- format & linting
			{
				"jose-elias-alvarez/null-ls.nvim",
				config = function()
					require("custom.configs.null-ls")
				end,
			},
		},
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end, -- Override to setup mason-lspconfig
	},

	{
		"folke/trouble.nvim",
		requires = "nvim-tree/nvim-web-devicons",
	},
	{
    -- TODO
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
	},

	-- override plugin configs
	{
		"williamboman/mason.nvim",
		opts = overrides.mason,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = overrides.treesitter,
	},

	{
		"nvim-tree/nvim-tree.lua",
		opts = overrides.nvimtree,
	},

	-- Install a plugin
	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("better_escape").setup()
		end,
	},

	-- Non-lua plugin can not be lazy-loaded, seems like
	{
		"tpope/vim-eunuch",
		lazy = false,
	},
	{
		"tpope/vim-speeddating",
		lazy = false,
	},
	{
		"tpope/vim-abolish",
		lazy = false,
	},
	{
		"svermeulen/vim-subversive",
		lazy = false,
	},
	{
		"svermeulen/vim-cutlass",
		lazy = false,
	},

	-- Domain specific

  -- Git
	{
		"tpope/vim-fugitive",
		lazy = false,
	},
	{
		"tpope/vim-git",
		lazy = false,
	},

  --
	{
		"rust-lang/rust.vim",
		ft = "rust",
	},
	{
    -- TODO
		"simrat39/rust-tools.nvim",
	},

	-- To make a plugin not be loaded
	-- {
	--   "NvChad/nvim-colorizer.lua",
	--   enabled = false
	-- },

	-- All NvChad plugins are lazy-loaded by default
	-- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
	-- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
	-- {
	--   "mg979/vim-visual-multi",
	--   lazy = false,
	-- }
}

return plugins
