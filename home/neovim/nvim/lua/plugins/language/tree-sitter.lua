local M = {}

local parser_path = vim.fn.stdpath("cache") .. "/tree-sitter"

M.event = { "BufReadPre", "BufNewFile" }

M.config = function(_, opts)
  vim.opt.runtimepath:prepend(parser_path)
  require("nvim-treesitter.configs").setup(opts)
end

M.opts = {
  parser_install_dir = parser_path,

  ensure_installed = {
    "bash",
    "bibtex",
    "c",
    "comment",
    "cpp",
    "css",
    "csv",
    "cuda",
    "diff",
    "dockerfile",
    "fennel",
    "firrtl",
    "fortran",
    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "go",
    "gomod",
    "gosum",
    "gowork",
    "graphql",
    "haskell",
    "ini",
    "java",
    "javascript",
    "jq",
    "jsdoc",
    "json",
    "jsonc",
    "julia",
    "just",
    "kdl",
    "kotlin",
    "latex",
    "llvm",
    "lua",
    "luadoc",
    "luau",
    "make",
    "markdown",
    "markdown_inline",
    "mermaid",
    "meson",
    "mlir",
    "ninja",
    "nix",
    "nu",
    "passwd",
    "perl",
    "python",
    "query",
    "racket",
    "regex",
    "rst",
    "rust",
    "scala",
    "scheme",
    "scss",
    "sql",
    "strace",
    "svelte",
    "swift",
    "toml",
    "tsx",
    "typescript",
    "verilog",
    "vim",
    "vimdoc",
    "vue",
    "xml",
    "yaml",
  },

  auto_install = true,

  ignore_install = {},

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-space>",
      node_incremental = "<C-space>",
      scope_incremental = "<C-s>",
      node_decremental = "<M-space>",
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["aa"] = { query = "@parameter.outer", desc = "[a]round p[a]rameter" },
        ["ia"] = { query = "@parameter.inner", desc = "[i]nnner p[a]rameter" },
        ["af"] = { query = "@function.outer", desc = "[a]round [f]unction" },
        ["if"] = { query = "@function.inner", desc = "[i]nnner [f]unction" },
        ["ac"] = { query = "@class.outer", desc = "[a]round [c]lass" },
        ["ic"] = { query = "@class.inner", desc = "[i]nnner [c]lass" },
        ["aq"] = { query = "@comment.outer", desc = "Comment (or [q]omment)" },
        ["as"] = { query = "@scope", query_group = "locals", desc = "[a]round language [s]cope" },
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]f"] = { query = "@function.outer", desc = "Next [f]unction" },
        ["]]"] = { query = "@function.outer", desc = "Next function" },
        ["]c"] = { query = "@class.outer", desc = "Next [c]lass" },
        ["]i"] = { query = "@conditional.outer", desc = "Next [i]f" },
        ["]l"] = { query = "@loop.outer", desc = "Next [l]oop" },
        ["]r"] = { query = "@return.outer", desc = "Next [r]eturn" },
        ["]n"] = { query = "@number.inner", desc = "Next [n]umber" },
        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next [s]cope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_next_end = {
        ["]F"] = { query = "@function.outer", desc = "Next [F]unction end" },
        ["]["] = { query = "@function.outer", desc = "Next [F]unction end" },
        ["]C"] = { query = "@class.outer", desc = "Next [C]lass end" },
      },
      goto_previous_start = {
        ["[f"] = { query = "@function.outer", desc = "Previous [f]unction" },
        ["[["] = { query = "@function.outer", desc = "Previous function" },
        ["[c"] = { query = "@class.outer", desc = "Previous [c]lass" },
        ["]i"] = { query = "@conditional.outer", desc = "Previous i[f]" },
        ["[l"] = { query = "@loop.outer", desc = "Previous [l]oop" },
        ["[r"] = { query = "@return.outer", desc = "Previous [r]eturn" },
        ["[n"] = { query = "@number.inner", desc = "Previous [n]umber" },
        ["[s"] = { query = "@scope", query_group = "locals", desc = "Previous [s]cope" },
        ["[z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
      },
      goto_previous_end = {
        ["[F"] = { query = "@function.outer", desc = "Previous [F]unction end" },
        ["[]"] = { query = "@function.outer", desc = "Previous Function end" },
        ["[C"] = { query = "@class.outer", desc = "Previous [C]lass end" },
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>sa"] = { query = "@parameter.inner", desc = "[S]wap with next [a]rgument" },
      },
      swap_previous = {
        ["<leader>sA"] = { query = "@parameter.inner", desc = "[S]wap with previous [a]rgument" },
      },
    },
  },
}

function ts_repeat_move()
  return require("nvim-treesitter.textobjects.repeatable_move")
end

M.keys = {
  -- vim way: ; goes to the direction you were moving.
  {
    ";",
    function()
      ts_repeat_move().repeat_last_move()
    end,
    mode = { "n", "x", "o" },
  },
  {
    ",",
    function()
      ts_repeat_move().repeat_last_move_opposite()
    end,
    mode = { "n", "x", "o" },
  },
  -- Make builtin f, F, t, T also repeatable with ; and ,
  {
    "f",
    function()
      ts_repeat_move().builtin_f()
    end,
    mode = { "n", "x", "o" },
  },
  {
    "F",
    function()
      ts_repeat_move().builtin_F()
    end,
    mode = { "n", "x", "o" },
  },
  {
    "t",
    function()
      ts_repeat_move().builtin_t()
    end,
    mode = { "n", "x", "o" },
  },
  {
    "T",
    function()
      ts_repeat_move().builtin_T()
    end,
    mode = { "n", "x", "o" },
  },
}

return M
