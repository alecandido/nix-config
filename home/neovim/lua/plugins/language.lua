return {
  -- Symbols & related
  'simrat39/symbols-outline.nvim',
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ":TSUpdate"
  },

  -- LSP Configuration & Plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
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
