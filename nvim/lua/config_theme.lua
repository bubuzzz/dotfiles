
local M = {}

local function patch_homage_black()
    local set_hl = vim.api.nvim_set_hl

    local green = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
    local black = "#000000"
    local fg    = "#bbc2cf"
    local base1 = "#1c1f24"
    local base2 = "#202328"
    local base4 = "#3f444a"
    local base8 = "#DFDFDF"

    -- Override the floating pane to match with the theme
    set_hl(0, "MiniPickNormal",       { fg = fg,    bg = black })
    set_hl(0, "MiniPickBorder",       { fg = base4, bg = black })                 -- base4 border on black
    set_hl(0, "MiniPickPrompt",       { fg = base8, bg = black, bold = true })
    set_hl(0, "MiniPickMatchCurrent", { bg = base1 })                             -- the selected row

    -- Markdown headers: all levels green + bold
    for i = 1, 6 do
      set_hl(0, "@markup.heading." .. i .. ".markdown", { fg = green, bold = true })
    end
    set_hl(0, "@markup.heading", { fg = green, bold = true })

    -- Status line
    set_hl(0, "StFile",   { fg = black, bg = green, bold = true })  -- green block
    set_hl(0, "StAccent", { fg = base8, bg = base2, bold = true })  -- base8 on base2
    set_hl(0, "StMid",    { fg = fg,    bg = black })               -- fg on black
end

local function patch_kanagawa()
    local set_hl = vim.api.nvim_set_hl

    local green    = vim.api.nvim_get_hl(0, { name = "String" }).fg      -- dragon green accent
    local fg       = vim.api.nvim_get_hl(0, { name = "Normal" }).fg
    local bg       = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
    local barbg    = vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg
    local accentbg = vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg

    set_hl(0, "StFile",   { fg = bg, bg = green,    bold = true })  -- green block
    set_hl(0, "StAccent", { fg = fg, bg = accentbg, bold = true })
    set_hl(0, "StMid",    { fg = fg, bg = barbg })
end

function M.set(theme)
    vim.cmd.colorscheme(theme)

    if theme == "homage-black" then
        patch_homage_black()
    elseif theme == "kanagawa-dragon" then
        patch_kanagawa()
    end

end

return M
