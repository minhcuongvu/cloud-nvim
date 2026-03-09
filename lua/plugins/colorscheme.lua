-- lua/plugins/colorscheme.lua
return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",           -- storm, moon, night, day
      transparent = true,
      terminal_colors = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")

      -- Distinguish types/classes from functions
      vim.api.nvim_set_hl(0, "@type", { fg = "#2ac3de" })
      vim.api.nvim_set_hl(0, "@type.qualifier", { fg = "#2ac3de" })
      vim.api.nvim_set_hl(0, "@lsp.type.class", { fg = "#2ac3de" })
      vim.api.nvim_set_hl(0, "@lsp.type.struct", { fg = "#2ac3de" })
      vim.api.nvim_set_hl(0, "@lsp.type.enum", { fg = "#2ac3de" })
      vim.api.nvim_set_hl(0, "@lsp.type.interface", { fg = "#2ac3de" })
      vim.api.nvim_set_hl(0, "@lsp.type.namespace", { fg = "#2ac3de", italic = true })
      vim.api.nvim_set_hl(0, "@function", { fg = "#7aa2f7" })
      vim.api.nvim_set_hl(0, "@function.method", { fg = "#7aa2f7" })
      vim.api.nvim_set_hl(0, "@lsp.type.method", { fg = "#7aa2f7" })
      vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#5c6370", italic = true })
      vim.api.nvim_set_hl(0, "TelescopeResultsIdentifier", { fg = "#e0af68" })
      vim.api.nvim_set_hl(0, "TelescopeResultsLineNr", { fg = "#565f89" })
      vim.api.nvim_set_hl(0, "TelescopeResultsSpecialComment", { fg = "#565f89" })
    end,
  },
}
