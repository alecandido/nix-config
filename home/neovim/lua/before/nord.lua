-- complete migration https://alpha2phi.medium.com/neovim-for-beginners-lua-autocmd-and-keymap-functions-3bdfe0bebe42
vim.cmd([[
    " override: https://www.nordtheme.com/docs/ports/vim/customization
    augroup nord-theme-overrides
        autocmd!

        " Remove background from normal text and fold/sign column in GUI mode
        autocmd ColorScheme nord highlight Normal guibg=NONE
        autocmd ColorScheme nord highlight FoldColumn guibg=NONE
        autocmd ColorScheme nord highlight SignColumn guibg=NONE
        " remove it also from the split, for a more minimalistic appearance
        autocmd ColorScheme nord highlight VertSplit guibg=NONE
        " Swap foreground and background color in cterm selection
        autocmd ColorScheme nord highlight Visual cterm=reverse
        autocmd ColorScheme nord highlight Folded ctermfg='4' ctermbg='0' cterm=italic guifg='#81A1C1' guibg='#2E3440' gui=italic
    augroup END
]])

-- configure: https://www.nordtheme.com/docs/ports/vim/configuration
vim.g.nord_cursor_line_number_background = 1
vim.g.nord_uniform_diff_background = 1
vim.g.nord_italic = 1
vim.g.nord_italic_comments = 1
vim.g.nord_underline = 1
