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
    ft = { "markdown", "codecompanion" }
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
