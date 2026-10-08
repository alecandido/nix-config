-- Interface improvements

local parent = "plugins.ui"

local barbar = require(parent .. ".barbar")
local gitsigns = require(parent .. ".gitsigns")
local headlines = require(parent .. ".headlines")
local osc52 = require(parent .. ".osc52")
local symbols_outline = require(parent .. ".symbols-outline")

return {
  { "shaunsingh/nord.nvim",  lazy = false, priority = 1000 },
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
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          {
            pane = 2,
            section = "terminal",
            cmd = "colorscript -e square",
            height = 5,
            padding = 1,
          },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          {
            title = "Recent Files",
            icon = " ",
            section = "recent_files",
            indent = 2,
            padding = 1,
          },
          {
            pane = 2,
            icon = " ",
            desc = "Browse Repo",
            padding = 1,
            key = "b",
            action = function()
              Snacks.gitbrowse()
            end,
          },
          function()
            local in_git = Snacks.git.get_root() ~= nil
            local cmds = {
              {
                title = "Notifications",
                cmd = "gh notify -s -a -n5",
                action = function()
                  vim.ui.open("https://github.com/notifications")
                end,
                key = "n",
                icon = " ",
                height = 5,
                enabled = true,
              },
              {
                title = "Open Issues",
                cmd = "gh issue list -L 3",
                key = "i",
                action = function()
                  vim.fn.jobstart("gh issue list --web", { detach = true })
                end,
                icon = " ",
                height = 8,
              },
              {
                icon = " ",
                title = "Open PRs",
                cmd = "gh pr list -L 3",
                key = "P",
                action = function()
                  vim.fn.jobstart("gh pr list --web", { detach = true })
                end,
                height = 8,
              },
              {
                icon = " ",
                title = "Git Status",
                cmd = "git --no-pager diff --stat -B -M -C",
                height = 10,
              },
            }
            return vim.tbl_map(function(cmd)
              return vim.tbl_extend("force", {
                pane = 2,
                section = "terminal",
                enabled = in_git,
                padding = 1,
                ttl = 5 * 60,
                indent = 3,
              }, cmd)
            end, cmds)
          end,
          { section = "startup" },
        },
      },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      picker = { enabled = true },
      image = { enabled = true },
      scroll = { enabled = true },
      indent = { enabled = true },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      -- Force the picker to use the standard background and readable path colors
      local function fix_snacks_hl()
        vim.api.nvim_set_hl(0, "SnacksPickerNormal", { link = "Normal" })
        vim.api.nvim_set_hl(0, "SnacksPickerListNormal", { link = "Normal" })
        vim.api.nvim_set_hl(0, "SnacksPickerDir", { link = "Comment" })
      end
      fix_snacks_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = fix_snacks_hl,
      })
    end,
    keys = {
      { "<leader>ff",      function() Snacks.picker.files() end,                     desc = "Find Files" },
      { "<leader><space>", function() Snacks.picker.buffers() end,                   desc = "Buffers" },
      { "<leader>fg",      function() Snacks.picker.grep() end,                      desc = "Grep" },
      { "<leader>fn",      function() Snacks.picker.notifications() end,             desc = "Find Notifications" },
      { "<leader>n",       function() Snacks.notifier.show_history() end,            desc = "Notification History" },
      { "<leader>fc",      function() Snacks.picker.commands() end,                  desc = "Find Commands" },
      { "<leader>f:",      function() Snacks.picker.command_history() end,           desc = "Command History" },
      { "<leader>.",       function() Snacks.scratch() end,                          desc = "Toggle Scratch Buffer" },
      { "<leader>,",       function() Snacks.picker.buffers() end,                   desc = "Buffers" },
      { "<leader>/",       function() Snacks.picker.grep() end,                      desc = "Grep" },
      { "<leader>:",       function() Snacks.picker.command_history() end,           desc = "Command History" },
      { "<leader>e",       function() Snacks.explorer() end,                         desc = "File Explorer" },
      { "<leader>fb",      function() Snacks.picker.buffers() end,                   desc = "Buffers" },
      { "<leader>fp",      function() Snacks.picker.projects() end,                  desc = "Projects" },
      { "<leader>fr",      function() Snacks.picker.recent() end,                    desc = "Recent" },
      { "<leader>gb",      function() Snacks.picker.git_branches() end,              desc = "Git Branches" },
      { "<leader>gl",      function() Snacks.picker.git_log() end,                   desc = "Git Log" },
      { "<leader>gL",      function() Snacks.picker.git_log_line() end,              desc = "Git Log Line" },
      { "<leader>gs",      function() Snacks.picker.git_status() end,                desc = "Git Status" },
      { "<leader>gS",      function() Snacks.picker.git_stash() end,                 desc = "Git Stash" },
      { "<leader>gd",      function() Snacks.picker.git_diff() end,                  desc = "Git Diff (Hunks)" },
      { "<leader>gf",      function() Snacks.picker.git_log_file() end,              desc = "Git Log File" },
      { "<leader>gi",      function() Snacks.picker.gh_issue() end,                  desc = "GitHub Issues (open)" },
      { "<leader>gI",      function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
      { "<leader>gp",      function() Snacks.picker.gh_pr() end,                     desc = "GitHub Pull Requests (open)" },
      { "<leader>gP",      function() Snacks.picker.gh_pr({ state = "all" }) end,    desc = "GitHub Pull Requests (all)" },
      { "<leader>sb",      function() Snacks.picker.lines() end,                     desc = "Buffer Lines" },
      { "<leader>sB",      function() Snacks.picker.grep_buffers() end,              desc = "Grep Open Buffers" },
      { "<leader>sg",      function() Snacks.picker.grep() end,                      desc = "Grep" },
      { "<leader>sw",      function() Snacks.picker.grep_word() end,                 desc = "Visual selection or word",   mode = { "n", "x" } },
      { '<leader>s"',      function() Snacks.picker.registers() end,                 desc = "Registers" },
      { '<leader>s/',      function() Snacks.picker.search_history() end,            desc = "Search History" },
      { "<leader>sa",      function() Snacks.picker.autocmds() end,                  desc = "Autocmds" },
      { "<leader>sc",      function() Snacks.picker.command_history() end,           desc = "Command History" },
      { "<leader>sC",      function() Snacks.picker.commands() end,                  desc = "Commands" },
      { "<leader>sd",      function() Snacks.picker.diagnostics() end,               desc = "Diagnostics" },
      { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,        desc = "Buffer Diagnostics" },
      { "<leader>sh",      function() Snacks.picker.help() end,                      desc = "Help Pages" },
      { "<leader>sH",      function() Snacks.picker.highlights() end,                desc = "Highlights" },
      { "<leader>si",      function() Snacks.picker.icons() end,                     desc = "Icons" },
      { "<leader>sj",      function() Snacks.picker.jumps() end,                     desc = "Jumps" },
      { "<leader>sk",      function() Snacks.picker.keymaps() end,                   desc = "Keymaps" },
      { "<leader>sl",      function() Snacks.picker.loclist() end,                   desc = "Location List" },
      { "<leader>sm",      function() Snacks.picker.marks() end,                     desc = "Marks" },
      { "<leader>sM",      function() Snacks.picker.man() end,                       desc = "Man Pages" },
      { "<leader>sp",      function() Snacks.picker.lazy() end,                      desc = "Search for Plugin Spec" },
      { "<leader>sq",      function() Snacks.picker.qflist() end,                    desc = "Quickfix List" },
      { "<leader>sR",      function() Snacks.picker.resume() end,                    desc = "Resume" },
      { "<leader>su",      function() Snacks.picker.undo() end,                      desc = "Undo History" },
      { "<leader>uC",      function() Snacks.picker.colorschemes() end,              desc = "Colorschemes" },
      { "gd",              function() Snacks.picker.lsp_definitions() end,           desc = "Goto Definition" },
      { "gD",              function() Snacks.picker.lsp_declarations() end,          desc = "Goto Declaration" },
      { "gr",              function() Snacks.picker.lsp_references() end,            nowait = true,                       desc = "References" },
      { "gI",              function() Snacks.picker.lsp_implementations() end,       desc = "Goto Implementation" },
      { "gy",              function() Snacks.picker.lsp_type_definitions() end,      desc = "Goto T[y]pe Definition" },
      { "gai",             function() Snacks.picker.lsp_incoming_calls() end,        desc = "C[a]lls Incoming" },
      { "gao",             function() Snacks.picker.lsp_outgoing_calls() end,        desc = "C[a]lls Outgoing" },
      { "<leader>ss",      function() Snacks.picker.lsp_symbols() end,               desc = "LSP Symbols" },
      { "<leader>sS",      function() Snacks.picker.lsp_workspace_symbols() end,     desc = "LSP Workspace Symbols" },
      { "<leader>z",       function() Snacks.zen() end,                              desc = "Toggle Zen Mode" },
      { "<leader>Z",       function() Snacks.zen.zoom() end,                         desc = "Toggle Zoom" },
      { "<leader>S",       function() Snacks.scratch.select() end,                   desc = "Select Scratch Buffer" },
      { "<leader>bd",      function() Snacks.bufdelete() end,                        desc = "Delete Buffer" },
      { "<leader>cR",      function() Snacks.rename.rename_file() end,               desc = "Rename File" },
      { "<leader>gB",      function() Snacks.gitbrowse() end,                        desc = "Git Browse",                 mode = { "n", "v" } },
      { "<leader>gg",      function() Snacks.lazygit() end,                          desc = "Lazygit" },
      { "<leader>un",      function() Snacks.notifier.hide() end,                    desc = "Dismiss All Notifications" },
      { "<c-/>",           function() Snacks.terminal() end,                         desc = "Toggle Terminal" },
      { "<c-_>",           function() Snacks.terminal() end,                         desc = "which_key_ignore" },
      { "]]",              function() Snacks.words.jump(vim.v.count1) end,           desc = "Next Reference",             mode = { "n", "t" } },
      { "[[",              function() Snacks.words.jump(-vim.v.count1) end,          desc = "Prev Reference",             mode = { "n", "t" } },
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
