return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Gclog" },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>",           desc = "Git status" },
      { "<leader>gp", "<cmd>Git push<CR>",      desc = "Git push" },
      { "<leader>gl", "<cmd>Git log --oneline<CR>", desc = "Git log" },
      { "<leader>gf", "<cmd>Git fetch<CR>",     desc = "Git fetch" },
      { "<leader>gc", "<cmd>Git commit<CR>",    desc = "Git commit" },
    },
  },
}
