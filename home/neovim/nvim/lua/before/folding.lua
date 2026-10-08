local M = {}

function _G.custom_foldtext()
	-- Attempt to use the native treesitter foldtext if available (Neovim 0.10+)
	local ok, text = pcall(vim.treesitter.foldtext)
	if not ok or type(text) ~= "table" then
		text = { { vim.fn.getline(vim.v.foldstart), "Normal" } }
	end

	-- Calculate the number of lines folded
	local line_count = vim.v.foldend - vim.v.foldstart + 1
	local badge = string.format(" ⋯ %d lines", line_count)

	-- Ensure text is a table of virtual text chunks
	if type(text) == "string" then
		text = { { text, "Normal" } }
	end

	-- Append the badge to the virtual text
	table.insert(text, { badge, "Folded" })
	return text
end

-- Native folding with Treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = "v:lua.custom_foldtext()"

-- Fold-related options
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- Clean UI with v0.12 specific fillchars
vim.opt.fillchars:append({
	fold = " ",
	foldopen = "",
	foldclose = "",
	foldsep = " ",
	foldinner = " ",
})

-- Session persistence for folds
local fold_group = vim.api.nvim_create_augroup("FoldSaver", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
	group = fold_group,
	pattern = "?*",
	command = "silent! mkview 1",
})
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
	group = fold_group,
	pattern = "?*",
	command = "silent! loadview 1",
})

return M
