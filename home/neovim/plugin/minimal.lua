opts = {
  relativenumber = true,
  list = true,
  listchars = "tab:-->,trail:·",
}

for name, value in pairs(opts) do
  vim.o[name] = value
end
