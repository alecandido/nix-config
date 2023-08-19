opts = {
	relativenumber = true,
	mouse = a,
	list = "list listchars=tab:›,trail:·",
}

for name, value in pairs(opts) do
  vim.o[name] = value
end
