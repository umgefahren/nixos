-- nvim-cmp - everything related to autocompletion
return {
	"hrsh7th/nvim-cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		{
			-- snippet plugin
			"L3MON4D3/LuaSnip",
			dependencies = "rafamadriz/friendly-snippets",
			config = function()
				local ls = require("luasnip")
				require("luasnip.loaders.from_vscode").lazy_load()
				ls.config.set_config({
					history = true,
					updateevents = "TextChanged,TextChangedI",
				})

				-- Exit snippet context when leaving insert mode
				vim.api.nvim_create_autocmd("InsertLeave", {
					callback = function()
						if ls.session.current_nodes[vim.api.nvim_get_current_buf()] and not ls.session.jump_active then
							ls.unlink_current()
						end
					end,
				})
			end,
		},

		-- autopairing of (){}[] etc
		{
			"windwp/nvim-autopairs",
			opts = {
				fast_wrap = {},
				disable_filetype = { "TelescopePrompt", "vim" },
			},
			config = function(_, opts)
				require("nvim-autopairs").setup(opts)

				-- setup cmp for autopairs
				local cmp_autopairs = require("nvim-autopairs.completion.cmp")
				require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end,
		},
		{
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-calc",
		},

		-- nice icons for cmp
		"onsails/lspkind.nvim",
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")
		lspkind.symbol_map["Copilot"] = ""
		lspkind.symbol_map["Codeium"] = ""
		vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { link = "CmpItemKindSnippet" })
		vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { link = "CmpItemKindSnippet" })
		local cmp_kinds = {
			Text = "  ",
			Method = "  ",
			Function = "  ",
			Constructor = "  ",
			Field = "  ",
			Variable = "  ",
			Class = "  ",
			Interface = "  ",
			Module = "  ",
			Property = "  ",
			Unit = "  ",
			Value = "  ",
			Enum = "  ",
			Keyword = "  ",
			Snippet = "  ",
			Color = "  ",
			File = "  ",
			Reference = "  ",
			Folder = "  ",
			EnumMember = "  ",
			Constant = "  ",
			Struct = "  ",
			Event = "  ",
			Operator = "  ",
			TypeParameter = "  ",
		}

		local function border(hl_name)
			return {
				{ "╭", hl_name },
				{ "─", hl_name },
				{ "╮", hl_name },
				{ "│", hl_name },
				{ "╯", hl_name },
				{ "─", hl_name },
				{ "╰", hl_name },
				{ "│", hl_name },
			}
		end

		local opts = {
			mapping = {
				-- ["<C-Enter>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<Enter>"] = function(fallback)
					local ls = require("luasnip")

					if cmp.visible() then
						cmp.confirm({ select = true })
					elseif ls.expand_or_locally_jumpable() then
						ls.expand_or_jump()
					else
						fallback()
					end
				end,
				["<S-Enter>"] = function(fallback)
					local ls = require("luasnip")
					if ls.jumpable(-1) then
						ls.jump(-1)
					else
						fallback()
					end
				end,
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
				["<Tab>"] = cmp.mapping.select_next_item(),
			},
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			completion = {
				keyword_length = 1,
			},
			window = {
				completion = {
					-- border = border("CmpBorder"),
					-- winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
					col_offset = -3,
					side_padding = 0,
				},
				documentation = {
					-- border = border("CmpBorder"),
				},
			},
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(_, vim_item)
					vim_item.kind = (cmp_kinds[vim_item.kind] or "") .. vim_item.kind
					vim_item.abbr = string.sub(vim_item.abbr, 1, 30)
					local widths = {
						abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
						menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
					}

					for key, width in pairs(widths) do
						if vim_item[key] and vim.fn.strdisplaywidth(vim_item[key]) > width then
							vim_item[key] = vim.fn.strcharpart(vim_item[key], 0, width - 1) .. "…"
						end
					end
					return vim_item
				end,
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp", group_index = 1 },
				{ name = "path", group_index = 1 },
				{ name = "luasnip", group_index = 1 },
				{ name = "nvim_lua", group_index = 1 },
				{ name = "buffer", group_index = 2, keyword_length = 3 },
				{ name = "calc" },
				{ name = "crates" },
			}),
			enabled = function()
				-- disable if inside an ephemeral buffer (popups like renamer)
				if vim.o.bufhidden == "wipe" then
					return false
				end
				return true
			end,
			experimental = {
				ghost_text = true,
			},
		}
		cmp.setup(opts)
	end,
}
