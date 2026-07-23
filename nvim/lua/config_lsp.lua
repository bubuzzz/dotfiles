-- Lsp 
local M = {}

function M.set(servers_conf) 
    for _, server in pairs(servers_conf) do
        if next(server[2] ) ~= nil then
            vim.lsp.config(server[1], server[2])
        end
        vim.lsp.enable(server[1])
    end
    
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, ev.data.bufnr, { autotrigger = true })
      end,
    })

    vim.opt.completeopt = { "menuone", "noselect", "popup" }

    vim.keymap.set("i", "<Tab>", function()
      return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
    end, { expr = true })
end 

return M
