local M = {}

local saved_path = nil 

local function reload_lsp() 
    local bufs = {}

    for _, client in ipairs(vim.lsp.get_clients()) do 
        for buf in pairs(client.attached_buffers or {}) do 
            bufs[buf] = true 

        end 
        vim.lsp.stop_client(client.id)

    end

    vim.defer_fn(function() 
        for buf in pairs(bufs) do 
            if vim.api.nvim_buf_is_valid(buf) then 
                vim.api.nvim_exec_autocmds("FileType", {buffer = buf})
            end
        end
    end, 200)
end

function M.activate(dir)
    dir = vim.fn.fnamemodify(dir, ":p"):gsub("/$", "")
    if vim.fn.executable(dir .. "/bin/python") == 0 then
        vim.notify("no venv at " .. dir, vim.log.levels.ERROR)
        return
    end

    saved_path = saved_path or vim.env.PATH
    vim.env.VIRTUAL_ENV = dir
    vim.env.PATH = dir .. "/bin:" .. saved_path 
    reload_lsp() 
    vim.notify("venv: " .. vim.fn.fnamemodify(dir, ":~"))
end

function M.deactivate() 
    if not saved_path then 
        vim.notify("no venv active", vim.log.levels.ERROR)
        return 
    end

    vim.env.PATH = saved_path 
    vim.env.VIRTUAL_ENV = nil
    saved_path = nil 
    reload_lsp()

    vim.notify("venv deactivated")
end 

function M.set()
    vim.api.nvim_create_user_command("VenvActivate", function(o) 
        if o.args ~= "" then 
            M.activate(o.args)
            return 
        end

        local default = vim.fn.getcwd() .. "/.venv"
        if vim.fn.isdirectory(default) == 0 then 
            default = vim.fn.getcwd() .. "/"
        end 

        vim.ui.input({prompt = "Activate venv", default = default, completion = "dir"}, function(dir) 
            if dir and dir ~= "" then 
                M.activate(dir)
            end
        end)
    end, {nargs = "?", complete = "dir", desc="venv: activate"})

    vim.api.nvim_create_user_command("VenvDeactivate", function() 
        M.deactivate()
    end, {desc="venv: deactivate"} )
end

return M 
