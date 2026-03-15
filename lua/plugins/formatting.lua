return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "LSP: Format buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- These filetypes use LSP formatting (clangd, rust-analyzer)
        local lsp_format_filetypes = { c = true, cpp = true, rust = true }
        local filetype = vim.bo[bufnr].filetype
        if lsp_format_filetypes[filetype] then
          return { timeout_ms = 1000, lsp_format = "prefer" }
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        lua        = { "stylua" },
        python     = { "isort", "black" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        jsx        = { "prettierd", "prettier", stop_after_first = true },
        tsx        = { "prettierd", "prettier", stop_after_first = true },
        css        = { "prettierd", "prettier", stop_after_first = true },
        html       = { "prettierd", "prettier", stop_after_first = true },
        json       = { "prettierd", "prettier", stop_after_first = true },
        yaml       = { "prettierd", "prettier", stop_after_first = true },
        markdown   = { "prettierd", "prettier", stop_after_first = true },
        sh         = { "shfmt" },
      },
    },
  },
}
