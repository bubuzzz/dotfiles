local M = {}

function M.set() 
    -- Shortcuts
    vim.g.mapleader = " "
    ---- Find files and buffers
    vim.keymap.set("n", "<leader>fb", ":ls<CR>:b ", {desc="List buffers, pick by number"}) -- list buffer and set to navigate to
    vim.keymap.set("n", "<leader>ff", function() 
        MiniPick.builtin.files()
    end)

    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
    vim.keymap.set("n", "<leader>co", ":copen<CR>")
    vim.keymap.set("n", "<leader>cc", ":cclose<CR>")

    ---- Explore
    vim.keymap.set("n", "<leader>ee", ":Ex<CR>", {desc="Open the current directory buffer"})

    -- Toogle maxmiuize 
    ---- Track the maximized state globally
    _G.is_maximized = false

    vim.keymap.set("n", "<leader>mm", function()
      if _G.is_maximized then
        -- Equalize all windows (Restore layout)
        vim.cmd("wincmd =")
        _G.is_maximized = false
      else
        -- Maximize horizontally and vertically
        vim.cmd("wincmd |")
        vim.cmd("wincmd _")
        _G.is_maximized = true
      end
    end, { desc = "Toggle maximize current pane" })
end

return M
