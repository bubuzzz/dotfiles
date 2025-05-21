vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

-- Enable line numbers
vim.opt.number = true

-- Hide ~ symbols after the end of the buffer
vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
  callback = function()
    vim.cmd("highlight EndOfBuffer guifg=bg")
  end,
})

