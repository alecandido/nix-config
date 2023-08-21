-- Broader movements
vim.keymap.set('', 'H', '^')
vim.keymap.set('', 'L', '$')
vim.keymap.set('', 'K', 'H')
vim.keymap.set('', 'J', 'L')
vim.keymap.set('', '^', 'K')
vim.keymap.set('', '$', 'J')

-- Insert new lines

vim.keymap.set('n', 'o', 'o<Esc>')
vim.keymap.set('n', 'O', 'O<Esc>')

-- Escape in terminal
vim.keymap.set('t', '<Esc>', '<C-\><C-n>')
