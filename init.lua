vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Ensure dotnet and ucrt64 tools (rg, etc.) are on PATH
vim.env.PATH = "C:\\msys64\\ucrt64\\bin;C:\\Program Files\\dotnet;" .. vim.env.PATH

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = { { import = "plugins" } },
    install = { colorscheme = { "tokyonight" } },
    checker = { enabled = true, notify = false, frequency = 3600 },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip", "matchit", "matchparen", "netrwPlugin",
                "tarPlugin", "tohtml", "tutor", "zipPlugin",
            },
        },
    },
})

require("config.options")
require("config.keymaps")
require("config.autocmds")
