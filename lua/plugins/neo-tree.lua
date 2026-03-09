return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree filesystem reveal left toggle<CR>", desc = "Toggle file tree" },
    },
    opts = {
      git_status_async = true,
      filesystem = {
        follow_current_file = { enabled = false },
        use_libuv_file_watcher = false,
        filtered_items = {
          hide_dotfiles = false,
          hide_by_name = { "bin", "obj", "packages", "node_modules", ".vs" },
          hide_by_pattern = { "*.user" },
        },
        scan_mode = "shallow",
      },
      default_component_configs = {
        git_status = {
          symbols = {
            added = "+",
            modified = "~",
            deleted = "x",
            renamed = "r",
            untracked = "?",
            ignored = "!",
            unstaged = "U",
            staged = "S",
            conflict = "C",
          },
        },
      },
    },
  },
}
