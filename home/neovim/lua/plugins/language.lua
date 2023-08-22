local parent = ...

local lsp_zero_config = require(parent .. ".lsp-zero")
local nvim_cmp_config = require(parent .. ".nvim-cmp")

return {
  -- Symbols & related
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ":TSUpdate"
  },
  'simrat39/symbols-outline.nvim',

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
    },
  },

  {
    'VonHeikemen/lsp-zero.nvim',
    dependencies = {
      -- LSP Support
      'neovim/nvim-lspconfig',

      -- Autocompletion
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',

      -- Additional lua configuration for nvim
      'folke/neodev.nvim',
    },
    config = lsp_zero_config,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',

      -- Further completion sources,
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'petertriho/cmp-git',
      'hrsh7th/cmp-emoji',
      'hrsh7th/cmp-calc',
      'uga-rosa/cmp-dictionary',
      'hrsh7th/cmp-cmdline',
    },
    config = nvim_cmp_config,
  },

  -- Debug
  {
    'mfussenegger/nvim-dap',
    keys = {},
  },

  -- Diagnostics
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { },
  },

  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
    },
  },
}
