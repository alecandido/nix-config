local M = {}

M.branch = "main"

M.keys = {
  {
    "<leader>y",
    function()
      require("osc52").copy_operator()
    end,
    expr = true,
    desc = "Cop[y] through OSC52",
  },
  {
    "<leader>yy",
    "<leader>y_",
    remap = true,
    desc = "Cop[y] line through OSC52",
  },
  {
    "<leader>y",
    function()
      require("osc52").copy_visual()
    end,
    mode = "v",
    desc = "Cop[y] through OSC52",
  },
}

return M
