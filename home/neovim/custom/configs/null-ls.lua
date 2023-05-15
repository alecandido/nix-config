local present, null_ls = pcall(require, "null-ls")

if not present then
	return
end

local b = null_ls.builtins

local sources = {

	-- python
	null_ls.builtins.formatting.black,
	null_ls.builtins.formatting.isort,
	null_ls.builtins.diagnostics.flake8,
	null_ls.builtins.diagnostics.mypy,

	-- rust
	b.formatting.rustfmt,

	-- webdev stuff
	b.formatting.deno_fmt, -- choosed deno for ts/js files cuz its very fast!
	b.formatting.prettier.with({ filetypes = { "html", "markdown", "css" } }), -- so prettier works only on these filetypes

	-- Lua
	b.formatting.stylua,

	-- cpp
	b.formatting.clang_format,
}

null_ls.setup({
	debug = true,
	sources = sources,
})
