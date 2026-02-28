return {
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      -- Better text objects: vai/vii (indent), va"/ vi" (quotes), etc.
      require("mini.ai").setup({ n_lines = 500 })

      -- Surround: gsa (add), gsd (delete), gsr (replace), gsf/gsF (find)
      require("mini.surround").setup()

      -- Simple, clean statusline
      local statusline = require("mini.statusline")
      statusline.setup({ use_icons = true })
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end
    end,
  },
}
