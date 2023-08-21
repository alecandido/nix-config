opts = {
  number = true,
  relativenumber = true,
  splitbelow = true,
  splitright = true,
  termguicolors = true,
  list = true,
  listchars = "tab:-->,trail:·",
  clipboard = "unnamed",
  ignorecase = true,
  smartcase = true,
  completeopt = 'menuone,noselect'
}

for name, value in pairs(opts) do
  vim.o[name] = value
end

vim.cmd.colorscheme("nord")
