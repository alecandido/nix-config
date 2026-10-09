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
