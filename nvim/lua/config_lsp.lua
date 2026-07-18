-- Lsp 
local M = {}
function M.set() 
    vim.lsp.config("basedpyright", {
        settings = {
            basedpyright = {
                analysis = {
                    typeCheckingMode = "basic"
                },
            },
        },
    })
    vim.lsp.enable("basedpyright") -- python
    vim.lsp.enable("ols") -- odin
    vim.lsp.enable("elixirls")

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
