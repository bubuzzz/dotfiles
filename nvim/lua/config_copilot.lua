local M = {}

function M.set(params)
    require("supermaven-nvim").setup({
        keymaps = params.keymaps,
        ignore_filetypes = {},
        color = {
            suggestion_color = "#5c6370",  -- muted grey ghost text
            cterm = 244,
        },
        disable_inline_completion = false,
        disable_keymaps = false,
    })
end

return M
