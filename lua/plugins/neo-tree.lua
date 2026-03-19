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
    -- Patch neo-tree source files on install/update to fix Windows/MSYS2 issues.
    -- This runs after every :Lazy install/update so changes persist across updates.
    build = function(plugin)
      local function patch_file(relative_path, pattern, replacement)
        local filepath = plugin.dir .. "/" .. relative_path
        local f = io.open(filepath, "r")
        if not f then return end
        local content = f:read("*a")
        f:close()
        local new_content, count = content:gsub(pattern, replacement)
        if count > 0 and new_content ~= content then
          local fw = io.open(filepath, "w")
          if fw then
            fw:write(new_content)
            fw:close()
          end
        end
      end

      -- 1. Downgrade noisy "git status exited abnormally" warn -> trace
      patch_file(
        "lua/neo-tree/git/init.lua",
        "log%.at%.warn%.format(%b())",
        function(args)
          if args:find("git status async process exited abnormally") then
            return "log.at.trace.format(" .. args .. ")"
          end
          return "log.at.warn.format(" .. args .. ")"
        end
      )

      -- 2. Replace assert on git ls-files failure with graceful return
      patch_file(
        "lua/neo-tree/git/ls-files.lua",
        "assert%(vim%.v%.shell_error == 0%)",
        "if vim.v.shell_error ~= 0 then\n    return {}\n  end"
      )

      -- 3. Guard against nil state.tree in open_with_cmd
      patch_file(
        "lua/neo-tree/sources/common/commands.lua",
        "(local tree = state%.tree)\n(  local success, node = pcall%(tree%.get_node, tree%))",
        "%1\n  if not tree then\n    return\n  end\n%2"
      )
    end,
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
