local parent = "plugins.language"

local dap = require(parent .. ".dap")
local lint = require(parent .. ".lint")
local lspconfig = require(parent .. ".lspconfig")
local tree_sitter = require(parent .. ".tree-sitter")
local trouble = require(parent .. ".trouble")

return {
  -- Symbols & related
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nushell/tree-sitter-nu",
    },
    build = ":TSUpdate",
    init = tree_sitter.init,
    config = tree_sitter.config,
    opts = tree_sitter.opts,
    event = tree_sitter.event,
    keys = tree_sitter.keys,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "saghen/blink.cmp",
    },
    opts = lspconfig.opts,
    config = lspconfig.config,
  },

  -- Autocompletion
  {
    "saghen/blink.cmp",
    lazy = false, -- blink.cmp handles lazy loading internally
    dependencies = "rafamadriz/friendly-snippets",
    version = "*",
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        c = { "uncrustify" },
        cpp = { "uncrustify" },
        css = { "prettier" },
        fennel = { "fnlfmt" },
        go = { "gofmt", "goimports" },
        graphql = { "prettier" },
        haskell = { "stylish-haskell" },
        html = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        kotlin = { "ktlint" },
        markdown = { "prettier" },
        nix = { "alejandra" },
        python = { "ruff" }, -- using ruff for python formatting
        rust = { "rustfmt" },
        sh = { "shfmt" },
        sql = { "pg_format" },
        svelte = { "prettier" },
        toml = { "taplo" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        yaml = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    },
  },

  -- Debug
  {
    "mfussenegger/nvim-dap",
    config = dap.config,
    keys = dap.keys,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug: See last session result.",
      },
    },
  },

  -- Diagnostics
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = trouble.keys,
  },

  {
    "mfussenegger/nvim-lint",
    config = lint.config,
    opts = lint.opts,
    init = lint.init,
    event = lint.event,
  },

  -- Bunch of syntaxes for those languages which I do not bother installing a language
  -- server for
  "sheerun/vim-polyglot",

  -- Neovim specific
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- Tex
  {
    "lervag/vimtex",
    ft = "tex",
  },
}
