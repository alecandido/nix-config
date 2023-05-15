---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require("custom.highlights")

M.ui = {
	theme = "onedark",
	theme_toggle = { "onedark", "one_light" },

	hl_override = highlights.override,
	hl_add = highlights.add,

	statusline = {
		overriden_modules = function()
			local st_modules = require("nvchad_ui.statusline.default")
			-- this is just default table of statusline modules

			return {
				cursor_position = function()
          local c = vim.fn.col "."
					return st_modules.cursor_position() .. "➤ " .. c .. " "
					-- or just return "" to hide this module
				end,
			}
		end,
	},
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require("custom.mappings")

return M
