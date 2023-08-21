-- Broader movements
local big_steps = {
  {'H', '^'},
  {'L', '$'},
  {'K', 'H'},
  {'J', 'L'},
  {'^', 'K'},
  {'$', 'J'},
}

for _, map in ipairs(big_steps) do
  vim.keymap.set({'n', 'v', 'o', 'c'}, map[1], map[2])
end

-- Insert new lines
vim.keymap.set('n', 'o', 'o<Esc>')
vim.keymap.set('n', 'O', 'O<Esc>')

-- Jump in windows
for _, c in ipairs({'h', 'j', 'k', 'l'}) do
  vim.keymap.set('n', string.format('<C-%s>', c), string.format('<C-w>%s', c))
end

-- Escape in terminal
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
