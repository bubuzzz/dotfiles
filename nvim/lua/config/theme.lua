vim.o.background = "dark" -- or "light" for light mode
vim.opt.number = true
vim.opt.fillchars:append { eob = " " }
vim.opt.termguicolors = true 

-- lua/config/ft_make.lua
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

