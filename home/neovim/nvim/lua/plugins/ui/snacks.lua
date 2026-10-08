local M = {}

M.opts = {
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
}
M.config = function(_, opts)
	require("snacks").setup(opts)
	-- Force the picker to use the standard background and readable path colors
	local function fix_snacks_hl()
		-- Use the correct highlight groups for Snacks Picker windows
		vim.api.nvim_set_hl(0, "SnacksPicker", { link = "Normal" })
		vim.api.nvim_set_hl(0, "SnacksPickerList", { link = "Normal" })
		vim.api.nvim_set_hl(0, "SnacksPickerPreview", { link = "Normal" })
		vim.api.nvim_set_hl(0, "SnacksPickerInput", { link = "Normal" })
		vim.api.nvim_set_hl(0, "SnacksPickerBox", { link = "Normal" })
		vim.api.nvim_set_hl(0, "SnacksPickerDir", { link = "Comment" })

		-- Clear backgrounds on picker borders so they don't show the old background
		local fb = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
		local border_fg = fb.fg or vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg
		local borders = {
			"SnacksPickerBorder",
			"SnacksPickerListBorder",
			"SnacksPickerPreviewBorder",
			"SnacksPickerInputBorder",
			"SnacksPickerBoxBorder",
		}
		for _, hl_group in ipairs(borders) do
			vim.api.nvim_set_hl(0, hl_group, { fg = border_fg, bg = "NONE" })
		end

		local function get_hl_hex(name)
			local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
			if hl.fg then
				return hl.fg
			end
			hl = vim.api.nvim_get_hl(0, { name = name, link = true })
			return hl.fg
		end

		local indent_fg = get_hl_hex("SnacksIndent") or get_hl_hex("Whitespace")
		-- If Normal background is transparent/unset, assume pure black for blending
		local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg or 0x000000

		if indent_fg then
			vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = indent_fg })

			local r1 = math.floor(indent_fg / 0x10000)
			local g1 = math.floor((indent_fg % 0x10000) / 0x100)
			local b1 = indent_fg % 0x100

			local r2 = math.floor(normal_bg / 0x10000)
			local g2 = math.floor((normal_bg % 0x10000) / 0x100)
			local b2 = normal_bg % 0x100

			-- Use a higher alpha (0.5 instead of 0.3) so it's barely visible instead of invisible on pure black
			local alpha = 0.5
			local r = math.floor(r1 * alpha + r2 * (1 - alpha))
			local g = math.floor(g1 * alpha + g2 * (1 - alpha))
			local b = math.floor(b1 * alpha + b2 * (1 - alpha))

			local faint_fg = string.format("#%06x", r * 0x10000 + g * 0x100 + b)
			vim.api.nvim_set_hl(0, "SnacksIndent", { fg = faint_fg, bg = "NONE" })
		end
	end
	fix_snacks_hl()
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = fix_snacks_hl,
	})
end
M.keys = {
	{
		"<leader>ff",
		function()
			Snacks.picker.files()
		end,
		desc = "Find Files",
	},
	{
		"<leader><space>",
		function()
			Snacks.picker.buffers()
		end,
		desc = "Buffers",
	},
	{
		"<leader>fg",
		function()
			Snacks.picker.grep()
		end,
		desc = "Grep",
	},
	{
		"<leader>fn",
		function()
			Snacks.picker.notifications()
		end,
		desc = "Find Notifications",
	},
	{
		"<leader>n",
		function()
			Snacks.notifier.show_history()
		end,
		desc = "Notification History",
	},
	{
		"<leader>fc",
		function()
			Snacks.picker.commands()
		end,
		desc = "Find Commands",
	},
	{
		"<leader>f:",
		function()
			Snacks.picker.command_history()
		end,
		desc = "Command History",
	},
	{
		"<leader>.",
		function()
			Snacks.scratch()
		end,
		desc = "Toggle Scratch Buffer",
	},
	{
		"<leader>,",
		function()
			Snacks.picker.buffers()
		end,
		desc = "Buffers",
	},
	{
		"<leader>/",
		function()
			Snacks.picker.grep()
		end,
		desc = "Grep",
	},
	{
		"<leader>:",
		function()
			Snacks.picker.command_history()
		end,
		desc = "Command History",
	},
	{
		"<leader>e",
		function()
			Snacks.explorer()
		end,
		desc = "File Explorer",
	},
	{
		"<leader>fb",
		function()
			Snacks.picker.buffers()
		end,
		desc = "Buffers",
	},
	{
		"<leader>fp",
		function()
			Snacks.picker.projects()
		end,
		desc = "Projects",
	},
	{
		"<leader>fr",
		function()
			Snacks.picker.recent()
		end,
		desc = "Recent",
	},
	{
		"<leader>gb",
		function()
			Snacks.picker.git_branches()
		end,
		desc = "Git Branches",
	},
	{
		"<leader>gl",
		function()
			Snacks.picker.git_log()
		end,
		desc = "Git Log",
	},
	{
		"<leader>gL",
		function()
			Snacks.picker.git_log_line()
		end,
		desc = "Git Log Line",
	},
	{
		"<leader>gs",
		function()
			Snacks.picker.git_status()
		end,
		desc = "Git Status",
	},
	{
		"<leader>gS",
		function()
			Snacks.picker.git_stash()
		end,
		desc = "Git Stash",
	},
	{
		"<leader>gd",
		function()
			Snacks.picker.git_diff()
		end,
		desc = "Git Diff (Hunks)",
	},
	{
		"<leader>gf",
		function()
			Snacks.picker.git_log_file()
		end,
		desc = "Git Log File",
	},
	{
		"<leader>gi",
		function()
			Snacks.picker.gh_issue()
		end,
		desc = "GitHub Issues (open)",
	},
	{
		"<leader>gI",
		function()
			Snacks.picker.gh_issue({ state = "all" })
		end,
		desc = "GitHub Issues (all)",
	},
	{
		"<leader>gp",
		function()
			Snacks.picker.gh_pr()
		end,
		desc = "GitHub Pull Requests (open)",
	},
	{
		"<leader>gP",
		function()
			Snacks.picker.gh_pr({ state = "all" })
		end,
		desc = "GitHub Pull Requests (all)",
	},
	{
		"<leader>sb",
		function()
			Snacks.picker.lines()
		end,
		desc = "Buffer Lines",
	},
	{
		"<leader>sB",
		function()
			Snacks.picker.grep_buffers()
		end,
		desc = "Grep Open Buffers",
	},
	{
		"<leader>sg",
		function()
			Snacks.picker.grep()
		end,
		desc = "Grep",
	},
	{
		"<leader>sw",
		function()
			Snacks.picker.grep_word()
		end,
		desc = "Visual selection or word",
		mode = { "n", "x" },
	},
	{
		'<leader>s"',
		function()
			Snacks.picker.registers()
		end,
		desc = "Registers",
	},
	{
		"<leader>s/",
		function()
			Snacks.picker.search_history()
		end,
		desc = "Search History",
	},
	{
		"<leader>sa",
		function()
			Snacks.picker.autocmds()
		end,
		desc = "Autocmds",
	},
	{
		"<leader>sc",
		function()
			Snacks.picker.command_history()
		end,
		desc = "Command History",
	},
	{
		"<leader>sC",
		function()
			Snacks.picker.commands()
		end,
		desc = "Commands",
	},
	{
		"<leader>sd",
		function()
			Snacks.picker.diagnostics()
		end,
		desc = "Diagnostics",
	},
	{
		"<leader>sD",
		function()
			Snacks.picker.diagnostics_buffer()
		end,
		desc = "Buffer Diagnostics",
	},
	{
		"<leader>sh",
		function()
			Snacks.picker.help()
		end,
		desc = "Help Pages",
	},
	{
		"<leader>sH",
		function()
			Snacks.picker.highlights()
		end,
		desc = "Highlights",
	},
	{
		"<leader>si",
		function()
			Snacks.picker.icons()
		end,
		desc = "Icons",
	},
	{
		"<leader>sj",
		function()
			Snacks.picker.jumps()
		end,
		desc = "Jumps",
	},
	{
		"<leader>sk",
		function()
			Snacks.picker.keymaps()
		end,
		desc = "Keymaps",
	},
	{
		"<leader>sl",
		function()
			Snacks.picker.loclist()
		end,
		desc = "Location List",
	},
	{
		"<leader>sm",
		function()
			Snacks.picker.marks()
		end,
		desc = "Marks",
	},
	{
		"<leader>sM",
		function()
			Snacks.picker.man()
		end,
		desc = "Man Pages",
	},
	{
		"<leader>sp",
		function()
			Snacks.picker.lazy()
		end,
		desc = "Search for Plugin Spec",
	},
	{
		"<leader>sq",
		function()
			Snacks.picker.qflist()
		end,
		desc = "Quickfix List",
	},
	{
		"<leader>sR",
		function()
			Snacks.picker.resume()
		end,
		desc = "Resume",
	},
	{
		"<leader>su",
		function()
			Snacks.picker.undo()
		end,
		desc = "Undo History",
	},
	{
		"<leader>uC",
		function()
			Snacks.picker.colorschemes()
		end,
		desc = "Colorschemes",
	},
	{
		"gd",
		function()
			Snacks.picker.lsp_definitions()
		end,
		desc = "Goto Definition",
	},
	{
		"gD",
		function()
			Snacks.picker.lsp_declarations()
		end,
		desc = "Goto Declaration",
	},
	{
		"gr",
		function()
			Snacks.picker.lsp_references()
		end,
		nowait = true,
		desc = "References",
	},
	{
		"gI",
		function()
			Snacks.picker.lsp_implementations()
		end,
		desc = "Goto Implementation",
	},
	{
		"gy",
		function()
			Snacks.picker.lsp_type_definitions()
		end,
		desc = "Goto T[y]pe Definition",
	},
	{
		"gai",
		function()
			Snacks.picker.lsp_incoming_calls()
		end,
		desc = "C[a]lls Incoming",
	},
	{
		"gao",
		function()
			Snacks.picker.lsp_outgoing_calls()
		end,
		desc = "C[a]lls Outgoing",
	},
	{
		"<leader>ss",
		function()
			Snacks.picker.lsp_symbols()
		end,
		desc = "LSP Symbols",
	},
	{
		"<leader>sS",
		function()
			Snacks.picker.lsp_workspace_symbols()
		end,
		desc = "LSP Workspace Symbols",
	},
	{
		"<leader>z",
		function()
			Snacks.zen()
		end,
		desc = "Toggle Zen Mode",
	},
	{
		"<leader>Z",
		function()
			Snacks.zen.zoom()
		end,
		desc = "Toggle Zoom",
	},
	{
		"<leader>S",
		function()
			Snacks.scratch.select()
		end,
		desc = "Select Scratch Buffer",
	},
	{
		"<leader>bd",
		function()
			Snacks.bufdelete()
		end,
		desc = "Delete Buffer",
	},
	{
		"<leader>cR",
		function()
			Snacks.rename.rename_file()
		end,
		desc = "Rename File",
	},
	{
		"<leader>gB",
		function()
			Snacks.gitbrowse()
		end,
		desc = "Git Browse",
		mode = { "n", "v" },
	},
	{
		"<leader>gg",
		function()
			Snacks.lazygit()
		end,
		desc = "Lazygit",
	},
	{
		"<leader>un",
		function()
			Snacks.notifier.hide()
		end,
		desc = "Dismiss All Notifications",
	},
	{
		"<c-/>",
		function()
			Snacks.terminal()
		end,
		desc = "Toggle Terminal",
	},
	{
		"<c-_>",
		function()
			Snacks.terminal()
		end,
		desc = "which_key_ignore",
	},
	{
		"]]",
		function()
			Snacks.words.jump(vim.v.count1)
		end,
		desc = "Next Reference",
		mode = { "n", "t" },
	},
	{
		"[[",
		function()
			Snacks.words.jump(-vim.v.count1)
		end,
		desc = "Prev Reference",
		mode = { "n", "t" },
	},
}

return M
