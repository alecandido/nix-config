-- Interface improvements

local parent = "plugins.ui"

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
    opts = {},
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
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      picker = { enabled = true },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      -- Force the picker to use the standard background and readable path colors
      vim.api.nvim_set_hl(0, "SnacksPickerNormal", { link = "Normal" })
      vim.api.nvim_set_hl(0, "SnacksPickerListNormal", { link = "Normal" })
      vim.api.nvim_set_hl(0, "SnacksPickerDir", { link = "Comment" })
    end,
    keys = {
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader><space>", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>fn", function() Snacks.picker.notifications() end, desc = "Find Notifications" },
      { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "<leader>fc", function() Snacks.picker.commands() end, desc = "Find Commands" },
      { "<leader>f:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    },
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
