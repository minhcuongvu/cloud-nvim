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
      { "<leader>e", function()
  require("neo-tree.command").execute({
    source = "filesystem",
    position = "left",
    reveal = true,
    toggle = true
  })
end, desc = "Toggle file tree (reveal)" },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)

      -- Auto-reveal current file in neo-tree on buffer switch (without stealing focus)
      local function reveal_in_neo_tree()
        local bufnr = vim.api.nvim_get_current_buf()
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname == "" or vim.bo[bufnr].filetype == "neo-tree" or vim.bo[bufnr].buftype ~= "" then
          return
        end

        -- Resolve to full absolute path with consistent separators
        local filepath = vim.fn.fnamemodify(bufname, ":p")

        -- Only reveal if neo-tree is already open
        local neo_tree_win = nil
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "neo-tree" then
            neo_tree_win = win
            break
          end
        end
        if not neo_tree_win then
          return
        end

        local manager = require("neo-tree.sources.manager")
        local renderer = require("neo-tree.ui.renderer")
        local fs_scan = require("neo-tree.sources.filesystem.lib.fs_scan")
        local state = manager.get_state("filesystem")

        -- Skip if tree isn't ready yet (e.g. just toggled open)
        if not state.path or not state.tree then
          return
        end

        -- Use neo-tree's own path utils for consistent comparison
        local utils = require("neo-tree.utils")
        if not utils.is_subpath(state.path, filepath) then
          return
        end

        -- Scan to expand parent dirs, then highlight without stealing focus
        local current_win = vim.api.nvim_get_current_win()
        fs_scan.get_items(state, nil, filepath, function()
          if not state.tree then
            return
          end
          renderer.focus_node(state, filepath, true)
          -- Ensure focus stays on the file window
          if vim.api.nvim_win_is_valid(current_win) then
            vim.api.nvim_set_current_win(current_win)
          end
        end)
      end

      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("neotree-reveal", { clear = true }),
        callback = function()
          -- Defer to ensure the buffer is fully loaded after navigation
          vim.schedule(reveal_in_neo_tree)
        end,
      })
    end,
    opts = {
      sources = { "filesystem", "buffers" },  -- exclude git_status source (fails with Unicode usernames on MSYS2)
      enable_git_status = true,
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
