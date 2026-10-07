# Neovim Configuration Update (2026 Trends)

I've updated your Neovim configuration to reflect the current community trends, preserving your general structure (Lazy, modular files) while replacing older plugins with their modern, high-performance equivalents.

Here is a detailed breakdown of the changes and how your workflow should adapt.

## 1. File Management: `oil.nvim` replacing `vim-eunuch`
We removed `tpope/vim-eunuch` and installed `stevearc/oil.nvim`. 
**Workflow Change:** 
Instead of using commands like `:Rename`, `:Move`, or `:Remove`, you can now edit your filesystem exactly like a text buffer.
- Press **`-`** (minus) to open the parent directory of the current file in Oil.
- You will see a buffer with a list of files.
- You can use standard Neovim commands (e.g., `cw` to rename a file, `dd` to delete a file, `p` to paste/move a file).
- Save the buffer (`:w`) to apply the filesystem changes.

## 2. Navigation: `flash.nvim`
We added `folke/flash.nvim` for lightning-fast navigation, replacing the need to spam `j` or `k`.
**Workflow Change:**
- Press **`s`** to activate Flash. Type 2 characters of the word you want to jump to. You'll see labels (like `a`, `f`, `j`) appear over matches across your screen. Press the corresponding label to jump directly to it.
- Press **`S`** to activate Treesitter selection mode, which lets you visually select entire functions, blocks, or expressions instantly.

## 3. Formatting: `conform.nvim` replacing `formatter.nvim`
We removed `formatter.nvim` and `lsp-format.nvim` in favor of the much more robust `stevearc/conform.nvim`.
**Workflow Change:**
- Your format-on-save behavior remains exactly the same, but it's now handled reliably by Conform (timeout set to 500ms, falls back to LSP if no external formatter is found).
- You can manually trigger formatting with `:ConformInfo` to see the status of formatters for the current buffer.

## 4. Autocompletion: `blink.cmp` replacing `nvim-cmp`
We removed the bulky `nvim-cmp` ecosystem (which included ~8 separate dependencies) and replaced it with `saghen/blink.cmp`.
**Workflow Change:**
- You shouldn't notice much difference visually, but completion will be **significantly faster** and use less memory because it's written in Rust.
- Snippet expansion and LSP completions work out of the box.

## 5. UI & Notifications: `snacks.nvim` replacing `noice` & `nvim-notify`
We introduced `folke/snacks.nvim`, the new standard for Neovim QoL features. We enabled its `notifier`, `dashboard`, `words`, and `picker` modules.
**Workflow Change:**
- Notifications (previously handled by `nvim-notify`) are now managed by `snacks.notifier`, which is sleeker and faster.
- **Snacks Picker** is enabled! While we kept `telescope` intact so your custom setups don't break, you can experiment with the snacks picker via the Lua API: `:lua Snacks.picker.files()` or `:lua Snacks.picker.grep()`.

## 6. Editing: Native Comments & `mini.surround`
- **Comments:** We removed `Comment.nvim`. You can now use Neovim's built-in commenting! Use **`gcc`** to comment a line, or **`gc`** with a motion (like `gcap` for a paragraph).
- **Surround:** We swapped `vim-surround` for `mini.surround`. 
  - The default keybindings are slightly different from tpope's: 
  - Add surround: `sa{motion}{char}` (e.g., `saiw"` to surround inner word with quotes).
  - Delete surround: `sd{char}` (e.g., `sd"` to delete quotes).
  - Replace surround: `sr{old}{new}` (e.g., `sr"'` to replace quotes with single quotes).

## 7. The Snacks Way (New Shortcuts)
To fully embrace the `snacks.nvim` philosophy (searchable history, ephemeral buffers, non-intrusive UI), we've mapped some fundamental operations:

**Search & Navigation:**
- `<leader>ff`: Find Files (Snacks Picker)
- `<leader><space>`: Find Buffers (Snacks Picker)
- `<leader>fg`: Live Grep (Snacks Picker)

**Notifications & Commands:**
- `<leader>fn`: Find Notifications (Fuzzy search past errors/messages)
- `<leader>n`: Notification History (Open full log in a scratch buffer)
- `<leader>fc`: Find Commands (Command palette)
- `<leader>f:`: Command History (Fuzzy search previously executed commands)

**Scratch Buffers:**
- `<leader>.`: Toggle Scratch Buffer (Ephemeral buffer for notes/testing without cluttering the workspace)
