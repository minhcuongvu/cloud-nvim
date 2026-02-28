local map = vim.keymap.set

map("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear highlights" })
map("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<leader>/", "gc",  { remap = true, desc = "Toggle comment" })
