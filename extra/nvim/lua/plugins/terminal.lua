return {
	{
		"akinsho/toggleterm.nvim",
		tag = "v2.11.0",
		config = true,
		opts = {
			open_mapping = [[<c-\>]],
			size = 20,
			shell = "fish",
			direction = "float",
		},
		keys = {
			{
				"<leader>th",
				"<cmd>ToggleTerm direction=horizontal<cr>",
				desc = "Open terminal horizontal",
			},
			{
				"<leader>h",
				"<cmd>ToggleTerm direction=horizontal<cr>",
				desc = "Open terminal horizontal",
			},
			{
				"<leader>tv",
				"<cmd>ToggleTerm direction=vertical size=60<cr>",
				desc = "Open terminal vertical",
			},
			{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Open floating terminal" },
			[[<C-\>]],
		},
	},
}
