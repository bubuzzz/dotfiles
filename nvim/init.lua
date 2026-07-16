vim.pack.add({
  "https://github.com/bubuzzz/homage-black.git",
  "https://github.com/nvim-mini/mini.pairs",
  "https://github.com/nvim-mini/mini.pick",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/luochen1990/rainbow",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
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

---- Explore
vim.keymap.set("n", "<leader>ee", ":Ex<CR>", {desc="Open the current directory buffer"})

-- Override the floating pane to match with the theme 
local set_hl = vim.api.nvim_set_hl
set_hl(0, "MiniPickNormal",       { fg = "#bbc2cf", bg = "#000000" })  -- fg, bg
set_hl(0, "MiniPickBorder",       { fg = "#3f444a", bg = "#000000" })  -- base4 border on black
set_hl(0, "MiniPickPrompt",       { fg = "#DFDFDF", bg = "#000000", bold = true })
set_hl(0, "MiniPickMatchCurrent", { bg = "#1c1f24" })                  -- base1, the selected row

-- Pull the scheme's green from Comment's fg so everything below follows the colorscheme.
local green = vim.api.nvim_get_hl(0, { name = "Comment" }).fg or 0x98be65

-- Markdown headers: all levels green + bold
for i = 1, 6 do
  set_hl(0, "@markup.heading." .. i .. ".markdown", { fg = green, bold = true })
end
set_hl(0, "@markup.heading", { fg = green, bold = true })

-- Status line
set_hl(0, "StFile", { fg = "#000000", bg = green, bold = true })  -- green block
set_hl(0, "StAccent",   { fg = "#DFDFDF", bg = "#202328", bold = true })  -- base8 on base2
set_hl(0, "StMid",    { fg = "#bbc2cf", bg = "#000000" })               -- fg on black

vim.opt.statusline = table.concat({
  "%#StAccent# [%n] ",   -- buffer number
  "%#StFile# %f %m ",    -- filename + modified flag
  "%#StMid# %=",         -- stretch middle
  "%#StAccent# %l:%c ",  -- line:col, green block
})

