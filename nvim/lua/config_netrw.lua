local M = {} 
local function create()  
    local dir = vim.b.netrw_curdir or vim.fn.getcwd()
    vim.ui.input({prompt="Create (end with / for a directory): "}, function(name)
        if not name or name == "" then return end 
        local path = dir .. "/" .. name 
        if vim.uv.fs_stat(path) then 
            vim.notify("already exists: " .. name, vim.log.levels.ERROR)
            return 
        end 

        if vim.endswith(path, "/") then 
            vim.fn.mkdir(path, "p")

        else
            vim.fn.mkdir(vim.fn.fnamemodify(path,":h"), "p")
            vim.fn.writefile({}, path)

        end

        vim.cmd.edit()
    end)
end 

local function nudge()
    vim.notify("use + to create (trailing / = directory)", vim.log.levels.WARN)
end 

function M.set() 

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "netrw", 
        callback = function(ev) 
            local opts = {buffer = ev.buf, nowait = true}
            vim.keymap.set("n", "+", create, opts)
            vim.keymap.set("n", "gr", "<C-l>", vim.tbl_extend("force", opts, {remap = true}))

            vim.keymap.set("n", "d", nudge, opts)
            vim.keymap.set("n", "%", nudge, opts)
        end,
    })
end 

return M 
