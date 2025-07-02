vim.o.background = "dark" -- or "light" for light mode
vim.opt.number = true
vim.opt.fillchars:append { eob = " " }

vim.cmd [[
  colorscheme gruvbox-material
  highlight NvimTreeNormal guibg=#1a1a1a
  highlight NvimTreeNormalNC guibg=#1a1a1a
  highlight NvimTreeWinSeparator guibg=NONE guifg=NONE
  set fillchars+=vert:\ 
]]

