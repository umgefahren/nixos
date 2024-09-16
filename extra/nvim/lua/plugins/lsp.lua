local function setup_lspconfig()
	local on_attach = function(client, _)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false

		if not client.supports_method("textDocument/semanticTokens") then
			client.server_capabilities.semanticTokensProvider = nil
		end
	end

	local capabilities = vim.lsp.protocol.make_client_capabilities()

	capabilities.textDocument.completion.completionItem = {
		documentationFormat = { "markdown", "plaintext" },
		snippetSupport = true,
		preselectSupport = true,
		insertReplaceSupport = true,
		labelDetailsSupport = true,
		deprecatedSupport = true,
		commitCharactersSupport = true,
		tagSupport = { valueSet = { 1 } },
		resolveSupport = {
			properties = {
				"documentation",
				"detail",
				"additionalTextEdits",
			},
		},
	}

	require("lspconfig").lua_ls.setup({
		on_attach = on_attach,
		capabilities = capabilities,

		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
						[vim.fn.stdpath("data") .. "/lazy/ui/nvchad_types"] = true,
						[vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
					},
					maxPreload = 100000,
					preloadFileSize = 10000,
				},
			},
		},
	})

	local lspconfig = require("lspconfig")

	local servers = {
		"html",
		"cssls",
		"tsserver",
		"dockerls",
		"docker_compose_language_service",
		"gopls",
		"hls",
		"svelte",
		"pyright",
		"julials",
		"crystalline",
		"cmake",
		"fsautocomplete",
		"svelte",
		"ruby_lsp",
		"sourcekit",
		"omnisharp",
		"yamlls",
		"ocamllsp",
		"tailwindcss",
		"astro",
		"mdx_analyzer",
		"nil_ls",
	}

	for _, lsp in ipairs(servers) do
		lspconfig[lsp].setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
	end

	lspconfig.taplo.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		keys = {
			{
				"K",
				function()
					if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
						require("crates").show_popup()
					else
						vim.lsp.buf.hover()
					end
				end,
				desc = "Show Crate Documentation",
			},
		},
	})

	-- Fix clangd 'multiple different client offset encodings' warning
	local clangd_capabilities = capabilities
	clangd_capabilities.offsetEncoding = "utf-8"
	lspconfig.clangd.setup({
		on_attach = on_attach,
		capabilities = clangd_capabilities,
	})

	-- Custom config for eslint
	local eslint_capabilities = capabilities
	eslint_capabilities.formatting = true
	lspconfig.eslint.setup({
		on_attach = on_attach,
		capabilities = eslint_capabilities,
	})
end

local prettier_fmt = { "prettierd", "prettier" }

return {

	-- Lsp configuration presets
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		config = setup_lspconfig,
		keys = {
			{
				"gD",
				vim.lsp.buf.declaration,
				desc = "LSP declaration",
			},
			{
				"gd",
				vim.lsp.buf.definition,
				desc = "LSP definition",
			},
			{
				"gi",
				vim.lsp.buf.implementation,
				desc = "LSP implementation",
			},
			{
				"<leader>ls",
				vim.lsp.buf.signature_help,
				desc = "LSP signature help",
			},
			{
				"<leader>D",
				vim.lsp.buf.type_definition,
				desc = "LSP definition type",
			},
			{
				"gr",
				vim.lsp.buf.references,
				desc = "LSP references",
			},
			{
				"<leader>lf",
				function()
					vim.diagnostic.open_float({ border = "rounded" })
				end,
				desc = "Floating diagnostic",
			},
			{
				"[d",
				function()
					vim.diagnostic.goto_prev({ float = { border = "rounded" } })
				end,
				desc = "Goto prev",
			},
			{
				"]d",
				function()
					vim.diagnostic.goto_next({ float = { border = "rounded" } })
				end,
				desc = "goto next",
			},
		},
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		lazy = true,
		keys = {
			{
				"<leader>fm",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			formatters_by_ft = {
				svelte = prettier_fmt,
				html = prettier_fmt,
				-- markdown = prettier_fmt,
				css = prettier_fmt,
				typescript = prettier_fmt,
				javascript = prettier_fmt,
				lua = { "stylua" },
				cpp = { "clang-format" },
				go = { "gofmt" },
				nix = { "alejandra" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	},

	-- Collection of useful stuff around lsp (renamer, code actions, doc hover, ..)
	-- Mappings are in mappings.lua for them to be in the same place as other lsp mappings
	{
		"glepnir/lspsaga.nvim",
		dependencies = "neovim/nvim-lspconfig",
		event = "LspAttach",
		opts = {
			border_style = "rounded",
			preview_lines_above = 3,
			rename_action_quit = "<ESC>",
			definition_action_keys = {
				edit = "<CR>",
				vsplit = "s",
				split = "i",
				tabe = "t",
				quit = "q",
			},
			symbol_in_winbar = { enable = true },
			lightbulb = { virtual_text = false },
		},
		cmd = "Lspsaga",
		keys = {
			{
				"gpd",
				"<cmd>Lspsaga peek_definition<cr>",
				desc = "Peek definition",
			},
			{
				"<leader>pD",
				"<cmd>Lspsaga peek_type_definition<cr>",
				desc = "Peek type defintion",
			},
			{
				"<leader>ra",
				"<cmd>Lspsaga rename<cr>",
				desc = "Rename symbol",
			},
			{
				"K",
				"<cmd>Lspsaga hover_doc<cr>",
				desc = "Show documentation",
			},
			{
				"<leader>ca",
				"<cmd>Lspsaga code_action<cr>",
				desc = "LSP code action",
			},
			{
				"<leader>ci",
				"<cmd>Lspsaga incoming_calls<cr>",
				desc = "See incoming calls",
			},
			{
				"<leader>co",
				"<cmd>Lspsaga outgoing_calls<cr>",
				desc = "See outgoing calls",
			},
			{
				"<leader>lO",
				"<cmd>Lspsaga outline<cr>",
				desc = "See outline",
			},
		},
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		lazy = true,
		opts = {
			suggestion = {
				auto_trigger = true,
				keymap = {
					accept = "<C-CR>",
				},
			},
		},
	},
}
