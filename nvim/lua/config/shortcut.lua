
vim.g.mapleader = " "

vim.keymap.set('n', '<leader>tt', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>ff', ':FzfLua files<CR>')
vim.keymap.set('n', '<leader>fe', ':FzfLua live_grep<CR>')

-- copy/paste to/from clipboard
vim.keymap.set({"n", "v"}, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })

vim.keymap.set("n", "<leader>te", "<cmd>Tterm<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>:TtermClose<CR>", { noremap = true, silent = true })

-- LSP buffer-local keymaps
local lsp_grp = vim.api.nvim_create_augroup("LspKeymaps", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_grp,
  callback = function(ev)
    local buf = ev.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    -- Jump to implementation
    -- map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")

    -- (optional but handy — uncomment if you want them)
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gr", vim.lsp.buf.references, "List references")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gt", vim.lsp.buf.type_definition, "Type definition")
    
    map("n", "K",  vim.lsp.buf.hover, "Hover docs")
    map("n", "gK", function()
      -- if plugin is there, use it; else fallback to builtin
      local ok, sig = pcall(require, "lsp_signature")
      if ok then sig.toggle_float_win() else vim.lsp.buf.signature_help() end
    end, "Show function overloads")

    -- (optional) dedicated keys to cycle when using lsp_signature.nvim
    map("n", "]s", function()
      local ok, sig = pcall(require, "lsp_signature")
      if ok then sig.select_signature(1) end
    end, "Next overload")
    map("n", "[s", function()
      local ok, sig = pcall(require, "lsp_signature")
      if ok then sig.select_signature(-1) end
    end, "Prev overload")

    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")


    -- map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    -- map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    -- map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  end,
})
