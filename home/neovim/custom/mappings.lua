---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "Enter command mode", opts = { nowait = true } },
    ["H"] = { "^", "Beginning of line", opts = { nowait = true } },
    ["L"] = { "$", "End of line", opts = { nowait = true } },
    ["^"] = { "^", "Beginning of page", opts = { nowait = true } },
    ["$"] = { "$", "End of page", opts = { nowait = true } },
    ["o"] = { "o<Esc>", "New line", opts = { nowait = true } },
    ["O"] = { "O<Esc>", "New line above", opts = { nowait = true } },
    ["Y"] = { "y$", "Copy until the end of line", opts = { nowait = true } },
    ["x"] = { "d", "Cut", opts = { nowait = true } },
    ["xx"] = { "dd", "Cut line", opts = { nowait = true } },
    ["X"] = { "D", "Cut until the end of line", opts = { nowait = true } },
    ["s"] = { "<plug>(SubversiveSubstitute)", "Substitute", opts = { nowait = true } },
    ["ss"] = { "<plug>(SubversiveSubstituteLine)", "Substitute line", opts = { nowait = true } },
    ["S"] = { "<plug>(SubversiveSubstituteToEndOfLine)", "Substitute until the end of line", opts = { nowait = true } },
  },
  v = {
    [ ">" ] = { ">gv", "Indent selection", opts = { nowait = true } },
    [ "<" ] = { "<gv", "Deindent selection", opts = { nowait = true } },
  },
  x = {
    ["x"] = { "d", "Cut", opts = { nowait = true } },
  }
}

-- more keybinds!

return M
