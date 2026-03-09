return {
	-- Lua LSP aware of the Neovim runtime/API (replaces neodev)
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			-- Keymaps and features that activate when an LSP attaches to a buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					local builtin = require("telescope.builtin")
					map("gd", builtin.lsp_definitions, "Go to definition")
					map("gr", builtin.lsp_references, "Find references")
					map("gI", builtin.lsp_implementations, "Go to implementation")
					map("<leader>lt", builtin.lsp_type_definitions, "Type definition")
					map("<leader>ls", builtin.lsp_document_symbols, "Document symbols")
					map("<leader>lw", builtin.lsp_dynamic_workspace_symbols, "Workspace symbols")
					map("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
					map("<leader>la", vim.lsp.buf.code_action, "Code action", { "n", "x" })
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("K", function()
						vim.lsp.buf.hover({
							border = "rounded",
							max_width = math.floor(vim.o.columns * 0.6),
							max_height = math.floor(vim.o.lines * 0.6),
						})
					end, "Hover documentation")

					-- Highlight references of the word under the cursor
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = hl_group,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = hl_group,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- Toggle inlay hints if the server supports them
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>lh", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "Toggle inlay hints")
					end
				end,
			})

			-- nvim-cmp extends LSP capabilities; let servers know about it
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
			if ok then
				capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
			end

			-- Servers to install and configure automatically via mason
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
						},
					},
				},
			}

			require("mason").setup()
			local ensure_installed = vim.tbl_keys(servers)
			vim.list_extend(ensure_installed, { "stylua", "netcoredbg", "codelldb", "delve", "omnisharp" })
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						if server_name == "omnisharp" then return end
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})

			-- Disable lspconfig's omnisharp — we manage it manually
			vim.lsp.enable("omnisharp", false)

			-- OmniSharp: start manually per .cs file with the correct solution
		-- Name avoids "omnisharp" so vim.lsp.enable("omnisharp", false) won't interfere
			local dll = vim.fn.stdpath("data") .. "/mason/packages/omnisharp/libexec/OmniSharp.dll"
			local omnisharp_common = {
				on_init = function(client)
					client.offset_encoding = "utf-16"
				end,
				capabilities = capabilities,
				settings = {
					omnisharp = {
						enableRoslynAnalyzers = true,
						organizeImportsOnFormat = true,
					},
				},
			}

			local vs_msbuild = "C:/Program Files/Microsoft Visual Studio/18/Community/MSBuild/Current/Bin/MSBuild.exe"

			local function start_csharp_lsp(bufnr)
				if not vim.api.nvim_buf_is_valid(bufnr) then return end
				local fname = vim.api.nvim_buf_get_name(bufnr):lower()
				if not fname:match("%.cs$") then return end
				local sln, root, cmd_env
				if fname:find("mycommunitydirectory") then
					sln = "C:/Dev/CISS/MyCommunityDirectory/All.sln"
					root = "C:/Dev/CISS/MyCommunityDirectory"
					-- Old-style .csproj needs VS MSBuild for WebApplication.targets
					cmd_env = {
						MSBUILD_EXE_PATH = vs_msbuild,
						VSToolsPath = "C:/Program Files/Microsoft Visual Studio/18/Community/MSBuild/Microsoft/VisualStudio/v18.0",
					}
				else
					sln = "C:/Dev/CISS/CieCore/All.sln"
					root = "C:/Dev/CISS/CieCore"
				end
				vim.lsp.start(vim.tbl_deep_extend("force", omnisharp_common, {
					name = "csharp",
					cmd = { "dotnet", dll, "--languageserver", "-s", sln },
					cmd_env = cmd_env,
					root_dir = root,
				}), { bufnr = bufnr })
			end

			-- Start OmniSharp for .cs files
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
				group = vim.api.nvim_create_augroup("omnisharp-start", { clear = true }),
				pattern = "*.cs",
				callback = function(ev)
					start_csharp_lsp(ev.buf)
				end,
			})

			-- Handle the first buffer (BufEnter may have fired before this config ran)
			vim.schedule(function()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(buf) then
						start_csharp_lsp(buf)
					end
				end
			end)
		end,
	},
}
