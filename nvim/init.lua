vim.pack.add({
  "https://github.com/bubuzzz/homage-black.git",
  "https://github.com/nvim-mini/mini.pairs",
  "https://github.com/nvim-mini/mini.pick",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/luochen1990/rainbow",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/OXY2DEV/markview.nvim",
})

-- Theme
vim.cmd.colorscheme("homage-black")

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
require("markview").setup({
    preview = { enable = false }
})

-- Lsp 
vim.lsp.enable("basedpyright") -- python
vim.lsp.enable("ols") -- odin


-- Shortcuts
vim.g.mapleader = " "
---- Find files and buffers
vim.keymap.set("n", "<leader>fb", ":ls<CR>:b ", {desc="List buffers, pick by number"}) -- list buffer and set to navigate to
vim.keymap.set("n", "<leader>ff", function() 
    MiniPick.builtin.files()
end)

---- Explore
vim.keymap.set("n", "<leader>ee", ":Ex<CR>", {desc="Open the current directory buffer"})

---- Markdown render
vim.keymap.set("n", "<leader>mr", "<CMD>Markview splitToggle<CR>", {desc="Toggle the current markdown file to rendered mode"})



-- Override the floating pane to match with the theme 
local set_hl = vim.api.nvim_set_hl
set_hl(0, "MiniPickNormal",       { fg = "#bbc2cf", bg = "#000000" })  -- fg, bg
set_hl(0, "MiniPickBorder",       { fg = "#3f444a", bg = "#000000" })  -- base4 border on black
set_hl(0, "MiniPickPrompt",       { fg = "#DFDFDF", bg = "#000000", bold = true })
set_hl(0, "MiniPickMatchCurrent", { bg = "#1c1f24" })                  -- base1, the selected row

-- Status line
local set_hl = vim.api.nvim_set_hl
set_hl(0, "StFile", { fg = "#000000", bg = "#98be65", bold = true })  -- green block
set_hl(0, "StAccent",   { fg = "#DFDFDF", bg = "#202328", bold = true })  -- base8 on base2
set_hl(0, "StMid",    { fg = "#bbc2cf", bg = "#000000" })               -- fg on black

vim.opt.statusline = table.concat({
  "%#StAccent# [%n] ",   -- buffer number
  "%#StFile# %f %m ",    -- filename + modified flag
  "%#StMid# %=",         -- stretch middle
  "%#StAccent# %l:%c ",  -- line:col, green block
})
