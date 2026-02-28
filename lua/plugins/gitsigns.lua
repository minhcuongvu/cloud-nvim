return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add          = { text = "+" },
        change       = { text = "~" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, l, r, opts)
          opts = vim.tbl_extend("force", { buffer = bufnr }, opts or {})
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, { desc = "Next git hunk" })
        map("n", "[h", gs.prev_hunk, { desc = "Previous git hunk" })

        -- Hunk actions (gh = git hunk)
        map("n", "<leader>ghs", gs.stage_hunk,                                                    { desc = "Stage hunk" })
        map("n", "<leader>ghr", gs.reset_hunk,                                                    { desc = "Reset hunk" })
        map("v", "<leader>ghs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage hunk" })
        map("v", "<leader>ghr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset hunk" })
        map("n", "<leader>ghS", gs.stage_buffer,                                                   { desc = "Stage buffer" })
        map("n", "<leader>ghR", gs.reset_buffer,                                                   { desc = "Reset buffer" })
        map("n", "<leader>ghp", gs.preview_hunk,                                                   { desc = "Preview hunk" })
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end,                     { desc = "Blame line" })
        map("n", "<leader>ghd", gs.diffthis,                                                       { desc = "Diff this" })
        map("n", "<leader>ghD", function() gs.diffthis("~") end,                                   { desc = "Diff this ~" })
        map("n", "<leader>gtb", gs.toggle_current_line_blame,                                      { desc = "Toggle line blame" })
        map("n", "<leader>gtd", gs.toggle_deleted,                                                 { desc = "Toggle deleted" })
      end,
    },
  },
}
