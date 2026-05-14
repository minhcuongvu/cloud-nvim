-- nvim-treesitter v1 (rewrite)
-- NOTE: Treesitter highlighting is DISABLED due to a Neovim 0.12.2 runtime bug
-- that causes an uncatchable async crash: "attempt to call method 'range' (a nil value)"
-- in the decoration provider. This keeps parsers installed/updated and enables
-- treesitter indentation, but disables the built-in syntax highlighter.
--
-- To re-enable highlighting later (once Neovim/parsers are fixed), remove the
-- `vim.treesitter.start = function() end` line below.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = "*",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- ========================================================================
      -- NUCLEAR FIX for Neovim 0.12.2 treesitter crash.
      -- The highlighter crashes asynchronously in the decoration provider;
      -- no Lua pcall can catch it. The only reliable fix is to prevent
      -- vim.treesitter.start() from attaching the highlighter.
      -- ========================================================================
      vim.treesitter.start = function() end
      -- ========================================================================

      -- Parsers to auto-install
      local ensure_installed = {
        "c", "cpp", "rust", "lua", "vim", "vimdoc",
        "query", "markdown", "markdown_inline",
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

      -- Enable treesitter-based indentation for every filetype
      vim.api.nvim_create_autocmd("FileType", {
        desc = "Enable treesitter indentation",
        callback = function(ev)
          local ok = pcall(vim.treesitter.get_parser, ev.buf)
          if not ok then
            return
          end
          vim.bo[ev.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        end,
      })

      -- Auto-update parsers weekly
      local ts_update_file = vim.fn.stdpath("data") .. "/treesitter_last_update"
      local last_update = 0
      pcall(function()
        last_update = vim.fn.getftime(ts_update_file)
      end)
      if (os.time() - last_update) > (7 * 24 * 60 * 60) then
        vim.defer_fn(function()
          vim.cmd("TSUpdate")
          vim.fn.writefile({}, ts_update_file)
        end, 1000)
      end
    end,
  },
}
