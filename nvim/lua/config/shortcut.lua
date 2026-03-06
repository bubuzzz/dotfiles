
vim.g.mapleader = " "

local notes = require("config.notes")

vim.keymap.set("n", "<leader>nn", notes.new_note, { desc = "New zk note" })
vim.keymap.set("n", "<leader>ns", notes.scratchpad, { desc = "Open daily scratchpad" })

vim.keymap.set("n", "<leader>no", "<cmd>ZkNotes<CR>")
vim.keymap.set("n", "<leader>nb", "<cmd>ZkBacklinks<CR>")
vim.keymap.set("n", "<leader>zl", "<cmd>ZkLinks<CR>")
vim.keymap.set("n", "<leader>nt", "<cmd>ZkTags<CR>")

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
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    -- map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    -- map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    -- map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  end,
})

-- copy error to clipboard 
-- vim.keymap.set("n", "<leader>cp", function()
--   local diags = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
--   if diags and diags[1] then
--     vim.fn.setreg("+", diags[1].message)
--     vim.notify("Diagnostic copied to clipboard")
--   else
--     vim.notify("No diagnostic on this line", vim.log.levels.WARN)
--   end
-- end, { desc = "Copy diagnostic message" })
--


local diag_panel = require("customs.error_panel")
vim.keymap.set("n", "<leader>cc", function()
  diag_panel.show_current_line(true)
end, { desc = "Show + copy diagnostic" })
