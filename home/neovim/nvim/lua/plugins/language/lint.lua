local M = {}

local function get_cur_file_extension(bufnr)
  bufnr = bufnr or 0
  return "." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":e")
end

M.config = function(_, opts)
  require("lint").linters_by_ft = opts

  -- customize linter options
  local linters = require("lint").linters
  local ruff = linters.ruff
  ruff.args = {
    "check",
    "--force-exclude",
    "--quiet",
    "--stdin-filename",
    linters.ruff.get_file_name,
    "--no-fix",
    "--extend-select",
    "D",
    "--output-format",
    "json",
    "-",
  }
end

M.opts = {
  -- c = { "cppcheck" },
  -- cpp = { "cppcheck" },
  css = { "stylelint" },
  fennel = { "fennel" },
  gh_workflows = { "actionlint" },
  go = { "revive" },
  javascript = { "eslint" },
  json = { "jsonlint" },
  lua = { "selene" },
  -- markdown = { "vale" },
  nix = { "nix" },
  python = { "ruff" },
  -- rst = { "vale" },
  sql = { "sqlfluff" },
  tex = { "lacheck" },
  -- text = { "vale" },
  verilog = { "verilator" },
  yaml = { "yamllint" },
}

M.init = function()
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      require("lint").try_lint()
    end,
  })

  local vale = require("lint.linters.vale")
  vale.args = {
    "--no-exit",
    "--output",
    "JSON",
    "--ext",
    get_cur_file_extension,
    "--config",
    os.getenv("XDG_CONFIG_HOME") .. "/vale/vale.ini",
  }

  -- local cppcheck = require("lint.linters.cppcheck")
  -- -- https://stackoverflow.com/a/19779624/8653979
  -- cppcheck.args = { "--suppress=missingIncludeSystem", unpack(cppcheck.args) }
end

M.event = "BufWritePost"

return M
