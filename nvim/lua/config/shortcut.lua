
vim.g.mapleader = " "

vim.keymap.set('n', '<leader>tt', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>ff', ':FzfLua files<CR>')
vim.keymap.set('n', '<leader>fe', ':FzfLua live_grep<CR>')

-- copy/paste to/from clipboard
vim.keymap.set({"n", "v"}, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })

vim.keymap.set("n", "<leader>te", "<cmd>Tterm<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>:TtermClose<CR>", { noremap = true, silent = true })

-- Show error or lsp info
vim.keymap.set("n", "<leader>dd", ":FzfLua diagnostics_document<CR>", { desc = "Show the diagnostic on the current document" })
vim.keymap.set("n", "<leader>dw", ":FzfLua diagnostics_workspace<CR>", { desc = "Show the diagnostic on the current workspace" })

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



-- ========= Filetype-aware Build (Shift+F5) =========
local utils = require("config.utils")

-- Run a shell command from the project root
local function run_in_root(cmd, bufnr)
  local root = utils.get_project_root(bufnr)
  local esc_root = vim.fn.shellescape(root)
  vim.cmd("write") -- save first
  vim.cmd("!" .. "cd " .. esc_root .. " && " .. cmd)
end

-- Registry of build commands per filetype (easy to extend later)
local build_cmd_by_ft = {
  cs   = "dotnet build",
  -- rust = "cargo build",   -- <--- reserve for future enhancement
}

-- Create buffer-local Shift+F5 mapping per filetype
local grp = vim.api.nvim_create_augroup("BuildKeymaps", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = { "cs" }, -- add "rust" later when you’re ready
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    local build_cmd = build_cmd_by_ft[ft]
    if not build_cmd then return end

    vim.keymap.set("n", "<leader>bu", function()
      run_in_root(build_cmd, ev.buf)
    end, { buffer = ev.buf, desc = "Build project (<leader>bu)" })
  end,
})

-- ===== End filetype-aware build =====
