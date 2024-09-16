local fn = vim.fn
local marginTopPercent = 0.3
local headerPadding = fn.max({ 2, fn.floor(fn.winheight(0) * marginTopPercent) })

local function generate_maze(height, width)
	math.randomseed(os.time())
	-- Initialize grid
	local grid = {}
	for y = 1, height do
		grid[y] = {}
		for x = 1, width do
			grid[y][x] = "█"
		end
	end

	-- DFS to generate maze
	local dx = { 0, 1, 0, -1 }
	local dy = { -1, 0, 1, 0 }

	local function dfs(x, y)
		local directions = { 0, 1, 2, 3 }

		-- Shuffle directions
		for i = #directions, 2, -1 do
			local j = math.random(i)
			directions[i], directions[j] = directions[j], directions[i]
		end

		for _, dir in ipairs(directions) do
			local nx, ny = x + dx[dir + 1] * 2, y + dy[dir + 1] * 2

			if nx > 0 and nx <= width and ny > 0 and ny <= height and grid[ny][nx] == "█" then
				grid[y + dy[dir + 1]][x + dx[dir + 1]] = " "
				grid[ny][nx] = " "
				dfs(nx, ny)
			end
		end
	end

	-- Ensure that all border cells are walls
	for x = 1, width do
		grid[1][x] = "█"
		grid[height][x] = "█"
	end
	for y = 1, height do
		grid[y][1] = "█"
		grid[y][width] = "█"
	end

	-- Start DFS
	grid[2][2] = "S" -- Starting point
	grid[height - 1][width - 1] = "E" -- Ending point
	dfs(2, 2)

	grid[2][2] = " "
	grid[height - 1][width - 1] = " "

	-- Convert grid to array of strings
	local maze_str_arr = {}
	for y = 1, height do
		maze_str_arr[y] = table.concat(grid[y], "")
	end

	return maze_str_arr
end

local function button(sc, txt, keybind)
	local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")

	local opts = {
		position = "center",
		text = txt,
		shortcut = sc,
		cursor = 5,
		width = 36,
		align_shortcut = "right",
		hl = "AlphaButtons",
	}

	if keybind then
		opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true } }
	end

	return {
		type = "button",
		val = txt,
		on_press = function()
			local key = vim.api.nvim_replace_termcodes(sc_, true, false, true) or ""
			vim.api.nvim_feedkeys(key, "normal", false)
		end,
		opts = opts,
	}
end

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "macchiato",
			show_end_of_buffer = true,
			integrations = {
				cmp = true,
				alpha = true,
				fidget = true,
				gitsigns = true,
				indent_blankline = {
					enabled = true,
					colored_indent_levels = true,
				},
				leap = true,
				lsp_saga = true,
				markdown = true,
				mason = true,
				noice = true,
				semantic_tokens = true,
				treesitter = true,
				treesitter_context = true,
				nvimtree = true,
				telescope = { enabled = true },
				lsp_trouble = true,
				which_key = true,
			},
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {},
	},
	{
		"MunifTanjim/nui.nvim",
	},
	{
		"rcarriga/nvim-notify",
		config = function()
			vim.notify = require("notify")
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				signature = {
					enabled = false,
				},
			},
			presets = {
				inc_rename = true,
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"nvim-lua/plenary.nvim",
	},
	{ "echasnovski/mini.nvim", version = false },
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		lazy = true,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-lua/plenary.nvim",
		},
		opts = function()
			local actions = require("telescope.actions")
			return {
				defaults = {
					mappings = {
						i = {
							["<esc>"] = actions.close,
						},
					},
					vimgrep_arguments = {
						"rg",
						"-L",
						"--color=never",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					},
					file_sorter = require("telescope.sorters").get_fuzzy_file,
					prompt_prefix = "   ",
					selection_caret = "  ",
					entry_prefix = "  ",
					preview = {
						mime_hook = function(filepath, bufnr, opts)
							local is_image = function(filepath)
								-- Support JPEG, PNG, GIF, BMP, AVIF, WebP, HEIF, HEIC, TIFF, Jpeg2000 and JpegXL
								local image_extensions = {
									"jpg",
									"jpeg",
									"png",
									"gif",
									"bmp",
									"dib",
									"avif",
									"webp",
									"heif",
									"heic",
									"tif",
									"tiff",
									"jp2",
									"j2k",
									"jpf",
									"jpx",
									"jpm",
									"mj2",
									"jxl",
								}
								local split_path = vim.split(filepath:lower(), ".", { plain = true })
								local extension = split_path[#split_path]
								return vim.tbl_contains(image_extensions, extension)
							end
							if is_image(filepath) then
								local term = vim.api.nvim_open_term(bufnr, {})
								local function send_output(_, data, _)
									for _, d in ipairs(data) do
										vim.api.nvim_chan_send(term, d .. "\r\n")
									end
								end
								vim.fn.jobstart({
									"catimg",
									filepath,
								}, {
									on_stdout = send_output,
									stdout_buffered = true,
									pty = true,
								})
							else
								require("telescope.previewers.utils").set_preview_message(
									bufnr,
									opts.winid,
									"Binary cannot be previewed"
								)
							end
						end,
					},
				},
			}
		end,
		config = true,
		keys = {
			{ "<leader>ff", require("telescope.builtin").find_files, desc = "Find files", mode = "n" },
			{ "<leader>fw", require("telescope.builtin").live_grep, desc = "Live ripgrep", mode = "n" },
			{ "<leader>fb", require("telescope.builtin").buffers, desc = "Find buffers", mode = "n" },
			{ "<leader>fh", require("telescope.builtin").help_tags, desc = "Find help", mode = "n" },
			{ "<leader>fo", require("telescope.builtin").oldfiles, desc = "Find old files (previously opened)" },
			{
				"<leader>fs",
				require("telescope.builtin").lsp_document_symbols,
				desc = "Find symbols in the current document",
			},
			{
				"<leader>fS",
				require("telescope.builtin").lsp_workspace_symbols,
				desc = "Find symbols in the current workspace",
			},
		},
	},
	{
		"j-hui/fidget.nvim",
		tag = "v1.4.5",
		opts = {},
		dependencies = "neovim/nvim-lspconfig",
		event = "VeryLazy",
	},
	{
		"akinsho/bufferline.nvim",
		tag = "v4.6.1",
		requires = "nvim-tree/nvim-web-devicons",
		event = "VeryLazy",
		opts = {},
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {
			bind = true,
			border = "rounded",
			hint_prefix = "  ",
		},
	},
	{
		"goolord/alpha-nvim",
		enabled = true,
		lazy = true,
		event = "VimEnter",
		opts = {
			layout = {
				{
					type = "padding",
					val = headerPadding,
				},
				{
					type = "text",
					val = generate_maze(19, 41),
					opts = {
						position = "center",
						hl = "AlphaHeader",
					},
				},
				{
					type = "padding",
					val = 2,
				},
				{
					type = "group",
					val = {
						button("Enter", "  Just type", ":enew<CR>"),
						button("SPC f", "  Find File  ", ":Telescope find_files<CR>"),
						button("SPC o", "  Recent File  ", ":Telescope oldfiles<CR>"),
						button("SPC w", "  Find Word  ", ":Telescope live_grep<CR>"),
					},
					opts = {
						spacing = 1,
					},
				},
			},
		},
	},
}
