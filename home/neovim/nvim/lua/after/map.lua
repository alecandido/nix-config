local nmap = require("lib.map").nmap

-- Broader movements
local big_steps = {
  { "H", "^" },
  { "L", "$" },
  { "K", "H" },
  { "J", "L" },
  { "^", "K" },
  { "$", "J" },
}

for _, map in ipairs(big_steps) do
  vim.keymap.set("", map[1], map[2])
end

-- Insert new lines
nmap("o", "o<Esc>", { desc = "Insert new line below" })
nmap("O", "O<Esc>", { desc = "Insert new line above" })
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Jump in windows
for _, c in ipairs({ "h", "j", "k", "l" }) do
  nmap(
    string.format("<C-%s>", c),
    string.format("<C-w>%s", c),
    { desc = "Move to adjacent window" }
  )
end

-- Increment & decrement
nmap("<A-a>", "<C-a>", { desc = "Increment" })
nmap("<A-x>", "<C-x>", { desc = "Decrement" })

-- Escape in terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Disable space, keep for leader
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Diagnostic keymaps
nmap("[d", vim.diagnostic.goto_next, { desc = "Previous [D]iagnostic" })
nmap("]d", vim.diagnostic.goto_prev, { desc = "Next [D]iagnostic" })
nmap("god", vim.diagnostic.open_float, { desc = "Open [D]iagnostic" })
