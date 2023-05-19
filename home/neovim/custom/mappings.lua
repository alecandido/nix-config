-- Free mappings

-- unmap

---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "Enter command mode" },
    ["H"] = { "^", "Beginning of line" },
    ["L"] = { "$", "End of line" },
    ["^"] = { "^", "Beginning of page" },
    ["$"] = { "$", "End of page" },
    ["o"] = { "o<Esc>", "New line" },
    ["O"] = { "O<Esc>", "New line above" },
  },
  v = {
    [ ">" ] = { ">gv", "Indent selection" },
    [ "<" ] = { "<gv", "Deindent selection" },
  },
}

M.copypaste = {
  n = {
    ["Y"] = { "y$", "Copy until the end of line" },
    ["x"] = { "d", "Cut" },
    ["xx"] = { "dd", "Cut line" },
    ["X"] = { "D", "Cut until the end of line" },
    ["s"] = { "<plug>(SubversiveSubstitute)", "Substitute" },
    ["ss"] = { "<plug>(SubversiveSubstituteLine)", "Substitute line" },
    ["S"] = { "<plug>(SubversiveSubstituteToEndOfLine)", "Substitute until the end of line" },
  },
  x = {
    ["x"] = { "d", "Cut" },
  }
}

M.trouble = {
  n = {
    ["<leader>xx"] = { "<cmd>TroubleToggle<cr>", "Toggle" },
    ["<leader>xd"] = { "<cmd>TroubleToggle document_diagnostics<cr>", "Toggle document" },
    ["<leader>xq"] = { "<cmd>TroubleToggle quickfix<cr>", "Toggle quickfix" },
    ["<leader>xl"] = { "<cmd>TroubleToggle loclist<cr>", "Toggle loclist" },
    ["<leader>xt"] = { "<cmd>TodoTrouble<cr>", "Toggle to do" },
  },
}

-- more keybinds!

return M
