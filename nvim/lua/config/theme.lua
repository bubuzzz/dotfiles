vim.o.background = "dark" 
vim.opt.number = true
vim.opt.fillchars:append { eob = " " }
vim.opt.termguicolors = true 

vim.opt.expandtab = true     -- convert tabs to spaces
vim.opt.shiftwidth = 4       -- number of spaces per indentation level
vim.opt.softtabstop = 4      -- number of spaces a <Tab> feels like
vim.opt.tabstop = 4          -- render tabs as 4 spaces

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.tabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "make",
  callback = function()
    vim.opt_local.tabstop = 4  
    vim.opt_local.shiftwidth = 4  
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "h", "hpp" }, 
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})


-- colorscheme gruvbox-material
-- colorscheme catppuccin
-- colorscheme gruber-darker
-- colorscheme accent

-- doom-homage-black port (defined in colors/homage-black.lua). Owns all syntax,
-- LSP semantic-token, and nvim-tree highlights, so no post-hoc `hi` overrides
-- are needed here.
vim.cmd.colorscheme("homage-black")
vim.opt.fillchars:append({ vert = " " })
