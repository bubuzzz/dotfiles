vim.pack.add({
  "https://github.com/bubuzzz/homage-black.git",
  "https://github.com/rebelot/kanagawa.nvim",

  "https://github.com/nvim-mini/mini.pairs",
  "https://github.com/nvim-mini/mini.pick",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/luochen1990/rainbow",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/neovim/nvim-lspconfig",
})

-- Space and indentation
vim.opt.tabstop = 4  
vim.opt.shiftwidth = 4  
vim.opt.softtabstop = 4 
vim.opt.expandtab = true

vim.o.ignorecase = true
vim.o.smartcase = true

-- Misc
vim.opt.clipboard = "unnamedplus"
vim.opt.confirm = true
vim.opt.number = true
vim.g.rainbow_active = 1 -- from luochen1990/rainbow"

vim.opt.autochdir = false
vim.opt.relativenumber = true

-- Configuration
require("config_shortcut").set()

local themes = {"kanagawa-dragon", "homage-black"}
require("config_theme").set(themes[1])

require("config_plugin").set({
    treesitter_pattern = { "elixir", "eelixir", "heex", "python", "odin" },
})
require("config_lsp").set()
require("config_statusline").set()
