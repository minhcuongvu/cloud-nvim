-- nvim-treesitter v1 (rewrite) — the old `configs` module no longer exists.
-- Parsers are auto-installed for configured languages; run :TSUpdate to refresh.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false, -- plugin explicitly does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      -- Parsers to auto-install
      local ensure_installed = {
        "c",
        "cpp",
        "rust",
        "lua",
        "vim",
        "vimdoc",
        "query",      -- treesitter query language
        "markdown",
        "markdown_inline",
      }

      -- Auto-install missing parsers on startup
      local installed = require("nvim-treesitter.info").installed_parsers()
      local installed_set = {}
      for _, p in ipairs(installed) do
        installed_set[p] = true
      end
      for _, lang in ipairs(ensure_installed) do
        if not installed_set[lang] then
          vim.cmd("TSInstall " .. lang)
        end
      end

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
