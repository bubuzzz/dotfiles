local M = {} 

function M.set(conf) 
    for _, entry in ipairs(conf) do 
        vim.api.nvim_create_autocmd("FileType", {
            pattern=entry[1], 
            callback=function() 
                vim.bo.tabstop = entry[2]
                vim.bo.shiftwidth = entry[2]
                vim.bo.softtabstop = entry[2]
            end,
        })
    end
end

return M
