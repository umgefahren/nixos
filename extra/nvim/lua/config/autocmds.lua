vim.api.nvim_exec2(
	[[
  augroup remember-cursor-position
      autocmd!
      autocmd BufWinEnter * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"zz" | endif
  augroup END
]],
	{
		output = false,
	}
)

-- dont list quickfix buffers
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.opt_local.buflisted = false
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "alpha",
	callback = function()
		vim.opt_local.fillchars = { eob = " " }
	end,
})
