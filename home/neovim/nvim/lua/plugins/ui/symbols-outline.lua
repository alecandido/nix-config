local M = {}

M.keys = {
  { "<A-s>", "<Cmd>Outline<CR>", desc = "Open [S]ymbols outline" },
}

M.opts = {
  symbols = {
    icons = {
      File = { icon = " ", hl = "@text.uri" },
      Module = { icon = " ", hl = "@namespace" },
      Namespace = { icon = "⁙", hl = "@namespace" },
      Package = { icon = "", hl = "@namespace" },
      Class = { icon = "𝓒", hl = "@type" },
      Method = { icon = "ƒ", hl = "@method" },
      Property = { icon = "", hl = "@method" },
      Field = { icon = " ", hl = "@field" },
      Constructor = { icon = "", hl = "@constructor" },
      Enum = { icon = " ", hl = "@type" },
      Interface = { icon = " ", hl = "@type" },
      Function = { icon = "", hl = "@function" },
      Variable = { icon = "", hl = "@constant" },
      Constant = { icon = "", hl = "@constant" },
      String = { icon = "𝓐", hl = "@string" },
      Number = { icon = "#", hl = "@number" },
      Boolean = { icon = "⊨", hl = "@boolean" },
      Array = { icon = " ", hl = "@constant" },
      Object = { icon = "⦿", hl = "@type" },
      Key = { icon = "→", hl = "@type" },
      Null = { icon = "", hl = "@type" },
      EnumMember = { icon = " ", hl = "@field" },
      Struct = { icon = " ", hl = "@type" },
      Event = { icon = "", hl = "@type" },
      Operator = { icon = "+", hl = "@operator" },
      TypeParameter = { icon = "𝙏", hl = "@parameter" },
      Component = { icon = " ", hl = "@function" },
      Fragment = { icon = " ", hl = "@constant" },
    },
  },
}

M.cmd = { "Outline" }

return M
