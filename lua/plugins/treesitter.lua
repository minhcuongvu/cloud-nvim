-- nvim-treesitter v1 (rewrite) — the old `configs` module no longer exists.
-- Install parsers manually with :TSInstall <lang> or run :TSUpdate to refresh.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,   -- plugin explicitly does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      -- Enable treesitter highlighting for every filetype (no-ops if no parser installed)
      vim.api.nvim_create_autocmd("FileType", {
        desc = "Start treesitter highlighting",
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      -- Enable treesitter-based indentation for every filetype
      vim.api.nvim_create_autocmd("FileType", {
        desc = "Enable treesitter indentation",
        callback = function(ev)
          vim.bo[ev.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        end,
      })
    end,
  },
}
