return {
	-- {
	--   "zbirenbaum/copilot.lua",
	--   requires = {
	--     "copilotlsp-nvim/copilot-lsp", -- optional, for NES functionality
	--   },
	--   cmd = "Copilot",
	--   event = "InsertEnter",
	--   config = function()
	--     require("copilot").setup({
	--       -- Dummy BYOK provider, replace with real credentials
	--       provider = {
	--         name = "custom-ollama",
	--         models = { "llama3.2" },
	--         request = {
	--           endpoint = "http://localhost:11434/v1",
	--           headers = { Authorization = "Bearer dummy-key" },
	--         },
	--       },
	--     })
	--   end,
	-- },

	{
		"olimorris/codecompanion.nvim",
		opts = {
			interactions = {
				chat = { adapter = "qrcoui" },
				inline = { adapter = "qrcoui" },
				background = { adapter = "qrcoui" },
			},
			adapters = {
				http = {
					qrcoui = function()
						return require("codecompanion.adapters").extend("openai_compatible", {
							env = {
								-- the match is required to trim the "/v1" part, which is required for
								-- copilot, and it has to be omitted for this adapter
								url = os.getenv("COPILOT_PROVIDER_BASE_URL"):match("(.*)/"),
								api_key = "COPILOT_PROVIDER_API_KEY",
							},
							schema = {
								model = {
									default = os.getenv("COPILOT_MODEL"),
								},
							},
						})
					end,
				},
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion" },
		opts = {
			link = {
				icon_highlight = "RenderMarkdownLinkIcon",
			},
			anti_conceal = {
				ignore = {
					link = true,
				},
			},
		},
		config = function(_, opts)
			require("render-markdown").setup(opts)

			local function set_markdown_colors()
				-- Blend nord colors with black background
				vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#0d0d0e" })
				vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = "#1b1b1c" })
				-- Hued headers background (blended 20% with aurora colors)
				vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#241c22" }) -- purple
				vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = "#20261c" }) -- green
				vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { bg = "#2f281b" }) -- yellow
				vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { bg = "#291b16" }) -- orange
				vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { bg = "#261315" }) -- red
				vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { bg = "#1b2629" }) -- cyan

				-- headlines.nvim compatibility
				vim.api.nvim_set_hl(0, "CodeBlock", { bg = "#0d0d0e" })
				vim.api.nvim_set_hl(0, "Headline1", { bg = "#241c22" })
				vim.api.nvim_set_hl(0, "Headline2", { bg = "#20261c" })
				vim.api.nvim_set_hl(0, "Headline3", { bg = "#2f281b" })
				vim.api.nvim_set_hl(0, "Headline4", { bg = "#291b16" })
				vim.api.nvim_set_hl(0, "Headline5", { bg = "#261315" })
				vim.api.nvim_set_hl(0, "Headline6", { bg = "#1b2629" })

				-- Fix for link URL underline bleeding through conceal after hover
				for _, hl_group in ipairs({ "@markup.link", "@markup.link.url", "markdownUrl", "RenderMarkdownLink" }) do
					local url_hl = vim.api.nvim_get_hl(0, { name = hl_group, link = false })
					url_hl.underline = false
					url_hl.undercurl = false
					if type(url_hl.cterm) == "table" then
						url_hl.cterm.underline = false
						url_hl.cterm.undercurl = false
					end
					vim.api.nvim_set_hl(0, hl_group, url_hl)
				end

				-- Ensure the visible label (link text) stays underlined
				local label_hl = vim.api.nvim_get_hl(0, { name = "@markup.link.label", link = false })
				label_hl.underline = true
				if type(label_hl.cterm) == "table" then
					label_hl.cterm.underline = true
				else
					label_hl.cterm = { underline = true }
				end
				vim.api.nvim_set_hl(0, "@markup.link.label", label_hl)
				
				-- Ensure the link icon is NOT underlined (used when link is concealed)
				local icon_hl = vim.deepcopy(label_hl)
				icon_hl.underline = false
				icon_hl.undercurl = false
				if type(icon_hl.cterm) == "table" then
					icon_hl.cterm.underline = false
					icon_hl.cterm.undercurl = false
				end
				vim.api.nvim_set_hl(0, "RenderMarkdownLinkIcon", icon_hl)
			end

			set_markdown_colors()

			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = set_markdown_colors,
			})
		end,
	},

	{
		"HakonHarnes/img-clip.nvim",
		opts = {
			filetypes = {
				codecompanion = {
					prompt_for_file_name = false,
					template = "[Image]($FILE_PATH)",
					use_absolute_path = true,
				},
			},
		},
	},
}
