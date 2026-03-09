vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- Fix shell flags for bash on Windows (default shellcmdflag "/s /c" is for cmd.exe)
if vim.fn.has("win32") == 1 and vim.o.shell:find("bash") then
  vim.opt.shellcmdflag = "-c"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.signcolumn = "yes"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

-- Mouse support
vim.opt.mouse = "a"

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.inccommand = "split"   -- live preview of :s substitutions

-- Editing
vim.opt.breakindent = true     -- wrapped lines preserve indentation
vim.opt.undofile = true        -- persistent undo across sessions
vim.opt.cursorline = true      -- highlight the current line
vim.opt.scrolloff = 10         -- keep 10 lines visible above/below cursor
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Splits open naturally
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Detect CRLF/LF line endings properly (prevents ^M in files on Windows)
vim.opt.fileformats = "dos,unix"
