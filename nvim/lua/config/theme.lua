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


vim.cmd [[
  colorscheme gruvbox-material
  highlight NvimTreeNormal guibg=#1a1a1a
  highlight NvimTreeNormalNC guibg=#1a1a1a
  highlight NvimTreeWinSeparator guibg=NONE guifg=NONE
  set fillchars+=vert:\ 
]]

