-- Pure UI

return { 
  'shaunsingh/nord.nvim',
  "rebelot/kanagawa.nvim",
  "navarasu/onedark.nvim",

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  -- Adds git related signs to the gutter, as well as utilities for managing changes
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
        vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
      end,
    },
  },


  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    opts = {
      show_current_context = true,
      show_trailing_blankline_indent = false,
    },
  },


  {
    'lukas-reineke/headlines.nvim',
    dependencies = "nvim-treesitter/nvim-treesitter",
    opts = {
      markdown = {
        headline_highlights = {
          "Headline1",
          "Headline2",
          "Headline3",
          "Headline4",
          "Headline5",
          "Headline6",
        },
        fat_headlines = false,
      },
    },
  },

  -- Set lualine as statusline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true },
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<A-,>', '<Cmd>BufferPrevious<CR>' },
      { '<A-.>', '<Cmd>BufferNext<CR>' },
      { '<A-<>', '<Cmd>BufferMovePrevious<CR>' },
      { '<A->>', '<Cmd>BufferMoveNext<CR>' },
      { '<A-1>', '<Cmd>BufferGoto 1<CR>' },
      { '<A-2>', '<Cmd>BufferGoto 2<CR>' },
      { '<A-3>', '<Cmd>BufferGoto 3<CR>' },
      { '<A-4>', '<Cmd>BufferGoto 4<CR>' },
      { '<A-0>', '<Cmd>BufferLast<CR>' },
      { '<A-w>', '<Cmd>BufferClose<CR>' },
      { '<A-q>', '<Cmd>q<CR>' },
      { '<A-p>', '<Cmd>BufferPick<CR>' },
    },
    lazy = false,
    version = '^1.0.0',
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { '<A-t>', '<Cmd>Neotree toggle<CR>' },
      { '<A-g>s', '<Cmd>Neotree git_status float<CR>' },
    },
  },
}
