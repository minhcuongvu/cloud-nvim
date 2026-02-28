return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree filesystem reveal left toggle<CR>", desc = "Toggle file tree" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)

      -- Open neo-tree when nvim is started with a directory argument (e.g. `nvim .`)
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          if vim.fn.argc() == 1 then
            local arg = tostring(vim.fn.argv(0))
            local stat = vim.uv.fs_stat(arg)
            if stat and stat.type == "directory" then
              vim.cmd("bwipeout")
              require("neo-tree.command").execute({
                action = "focus",
                source = "filesystem",
                position = "left",
                dir = arg,
              })
            end
          end
        end,
      })
    end,
  },
}
