vim.pack.add({
  "https://github.com/bubuzzz/homage-black.git",
  "https://github.com/nvim-mini/mini.pairs",
  "https://github.com/nvim-mini/mini.pick",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/luochen1990/rainbow",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/rebelot/kanagawa.nvim",
})

-- Theme
local theme = "kanagawa-dragon"
-- local theme = "homage-black"

local config_theme = require("config_theme")
config_theme.set(theme)

---- patch theme

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

-- Conform setup (for formatting)
require("conform").setup({
  formatters_by_ft = {
    python = { "ruff_fix", "ruff_format" },
    elixir = { "mix" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  }
})

require("mini.pick").setup({
  window = {
    config = function()
      local height = math.floor(0.3 * vim.o.lines)
      local width = vim.o.columns
      return {
        anchor = "NW",        
        row = 0, 
        col = 0,
        height = height,
        width = width,
        border = "single",     
      }
    end,
  },
})

require("mini.pairs").setup({})
require("nvim-treesitter").setup({})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "elixir", "eelixir", "heex", "python", "odin", "markdown" },
  callback = function() vim.treesitter.start() end,
})

-- Lsp 
vim.lsp.config("basedpyright", {
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = "basic"
            },
        },
    },
})
vim.lsp.enable("basedpyright") -- python
vim.lsp.enable("ols") -- odin
vim.lsp.enable("elixirls")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.lsp.completion.enable(true, ev.data.client_id, ev.data.bufnr, { autotrigger = true })
  end,
})

vim.opt.completeopt = { "menuone", "noselect", "popup" }

vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })


-- Shortcuts
vim.g.mapleader = " "
---- Find files and buffers
vim.keymap.set("n", "<leader>fb", ":ls<CR>:b ", {desc="List buffers, pick by number"}) -- list buffer and set to navigate to
vim.keymap.set("n", "<leader>ff", function() 
    MiniPick.builtin.files()
end)

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>co", ":copen<CR>")
vim.keymap.set("n", "<leader>cc", ":cclose<CR>")

---- Explore
vim.keymap.set("n", "<leader>ee", ":Ex<CR>", {desc="Open the current directory buffer"})


-- Status line
vim.opt.statusline = table.concat({
  "%#StAccent# [%n] ",   -- buffer number
  "%#StFile# %f %m ",    -- filename + modified flag
  "%#StMid# %=",         -- stretch middle
  "%#StAccent# %l:%c ",  -- line:col, green block
})
