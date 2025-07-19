
vim.g.mapleader = " "

vim.keymap.set('n', '<leader>tt', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>ff', ':FzfLua files<CR>')
vim.keymap.set('n', '<leader>fe', ':FzfLua live_grep<CR>')

-- copy/paste to/from clipboard
vim.keymap.set({"n", "v"}, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })

vim.keymap.set("n", "<leader>te", function()
  require("customs.tterm").toggle()
end, { noremap = true, silent = true })

