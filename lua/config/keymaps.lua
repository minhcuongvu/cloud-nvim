local map = vim.keymap.set

map("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear highlights" })
map("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<leader>/", "gc",  { remap = true, desc = "Toggle comment" })

-- Exit insert/terminal mode
map("i", "jk", "<Esc>",               { desc = "Normal mode" })
map("t", "jk", "<C-\\><C-n>",         { desc = "Normal mode" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Normal mode" })

-- Save / quit
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<CR><ESC>", { desc = "Save file" })
map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit all" })

-- Keep visual selection after indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move lines up/down
map("n", "<A-j>", "<cmd>m .+1<CR>==",  { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==",  { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv",  { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv",  { desc = "Move selection up" })

-- Diagnostics
map("n", "[d", vim.diagnostic.goto_prev,          { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next,          { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Telescope pickers
map("n", "<leader>fw", function() require("telescope.builtin").grep_string() end,  { desc = "Find word under cursor" })
map("n", "<leader>fk", function()
  require("telescope.builtin").keymaps({
    modes = { "n", "v", "i", "t" },
    filter = function(m) local d = m.desc or ""; return d ~= "" and not d:match("^%u%l+%u") end,
  })
end, { desc = "Find keymaps" })
map("n", "<leader>fd", function() require("telescope.builtin").diagnostics() end,  { desc = "Find diagnostics" })
map("n", "<leader>fs", function() require("telescope.builtin").resume() end,       { desc = "Resume last search" })
map("n", "<leader>sn", function()
  require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Search nvim config files" })

-- Terminal (split in current file's directory)
map("n", "<leader>tt", function()
  vim.cmd("split")
  vim.cmd("lcd " .. vim.fn.fnameescape(vim.fn.expand("%:p:h")))
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Open terminal (current dir)" })

-- Cheat sheet: only keymaps that have a human-readable description
map("n", "<leader>ch", function()
  require("telescope.builtin").keymaps({
    modes = { "n", "v", "i", "t" },   -- skip c/o modes (plugin internals live there)
    filter = function(map)
      -- drop entries with no desc or where desc looks like a CamelCase command name
      local d = map.desc or ""
      return d ~= "" and not d:match("^%u%l+%u")
    end,
  })
end, { desc = "Cheat sheet (all keymaps)" })
