local M = {}

table.unpack = table.unpack or unpack -- https://github.com/hrsh7th/nvim-cmp/issues/1017#issuecomment-1141368442 

function M.set(shortcuts) 
    vim.g.mapleader = " "
    _G.is_maximized = false

    for _, map in ipairs(shortcuts) do
        vim.keymap.set(table.unpack(map))
    end
end

return M
