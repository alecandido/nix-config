---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "Enter command mode", opts = { nowait = true } },
    ["H"] = { "^", "Beginning of line", opts = { nowait = true } },
    ["L"] = { "$", "End of line", opts = { nowait = true } },
    ["o"] = { "o<Esc>", "New line", opts = { nowait = true } },
    ["O"] = { "O<Esc>", "New line above", opts = { nowait = true } },
  },
}

-- more keybinds!

return M
