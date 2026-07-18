
local M = {}

function M.set(theme)
    if theme == "homage-black" then
        -- Override the floating pane to match with the theme 
        local set_hl = vim.api.nvim_set_hl
        set_hl(0, "MiniPickNormal",       { fg = "#bbc2cf", bg = "#000000" })  -- fg, bg
        set_hl(0, "MiniPickBorder",       { fg = "#3f444a", bg = "#000000" })  -- base4 border on black
        set_hl(0, "MiniPickPrompt",       { fg = "#DFDFDF", bg = "#000000", bold = true })
        set_hl(0, "MiniPickMatchCurrent", { bg = "#1c1f24" })                  -- base1, the selected row

        -- Pull the scheme's green from Comment's fg so everything below follows the colorscheme.
        local green = vim.api.nvim_get_hl(0, { name = "Comment" }).fg 

        -- Markdown headers: all levels green + bold
        for i = 1, 6 do
          set_hl(0, "@markup.heading." .. i .. ".markdown", { fg = green, bold = true })
        end
        set_hl(0, "@markup.heading", { fg = green, bold = true })

        -- Status line
        set_hl(0, "StFile", { fg = "#000000", bg = green, bold = true })  -- green block
        set_hl(0, "StAccent",   { fg = "#DFDFDF", bg = "#202328", bold = true })  -- base8 on base2
        set_hl(0, "StMid",    { fg = "#bbc2cf", bg = "#000000" })               -- fg on black
    end

    vim.cmd.colorscheme(theme)
end

return M
