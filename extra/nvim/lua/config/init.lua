vim.g.termguicolors = true

vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.signcolumn = "yes"

vim.cmd([[colorscheme catppuccin-macchiato]])
-- Use the system clipboard for all yank, delete, change and put operations
vim.opt.clipboard = "unnamedplus"

-- enable mouse support
vim.opt.mouse = "a"

if vim.g.neovide then
	vim.g.neovide_remember_window_size = true
end
