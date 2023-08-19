opts = {
  relativenumber = true,
  list = true,
  listchars = "tab:-->,trail:·",
  clipboard = "unnamed",
}

for name, value in pairs(opts) do
  vim.o[name] = value
end
