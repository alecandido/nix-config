return {
  -- Keybindings
  "tpope/vim-repeat",
  "tpope/vim-rsi",
  'tpope/vim-surround',
  -- Control case
  'tpope/vim-abolish',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Unix
  "tpope/vim-eunuch",

  -- Git
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-git',
  'junegunn/gv.vim',

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true }
  },

  {
    'nvim-telescope/telescope.nvim', tag = '0.1.2',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
  },
}
