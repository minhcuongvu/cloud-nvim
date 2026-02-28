return {
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      spec = {
        { "<leader>c",  group = "code" },
        { "<leader>ch", group = "cheat sheet", icon = "?" },
        { "<leader>f",  group = "find" },
        { "<leader>g",  group = "git" },
        { "<leader>gh", group = "hunk" },
        { "<leader>gt", group = "toggle" },
        { "<leader>l", group = "lsp" },
        { "<leader>t", group = "todo" },
      },
    },
  },
}
