-- homage-black: a Neovim port of Doom Emacs' doom-homage-black theme.
-- Near-monochrome on pure black. Keywords / functions / builtins / types are
-- near-white (#DFDFDF) and BOLD; strings/numbers are muted orange; comments
-- green; everything else is plain fg. Color is used sparingly, weight does the
-- work — exactly the homage aesthetic.

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.g.colors_name = "homage-black"

-- ---------- palette (from doom-homage-black-theme.el) ----------
local c = {
  bg        = "#000000",
  bg_alt    = "#000000",
  base0     = "#1B2229",
  base1     = "#1c1f24",
  base2     = "#202328",
  base3     = "#23272e",
  base4     = "#3f444a",
  base5     = "#5B6268",
  base6     = "#73797e",
  base7     = "#9ca0a4",
  base8     = "#DFDFDF",
  fg        = "#bbc2cf",
  fg_alt    = "#5B6268",
  grey      = "#5B6268",
  red       = "#ff6c6b",
  orange    = "#b4916d",
  green     = "#98be65",
  teal      = "#4db5bd",
  yellow    = "#ECBE7B",
  blue      = "#0170bf",
  dark_blue = "#003c64",
  magenta   = "#c678dd",
  violet    = "#a9a1e1",
  cyan      = "#46D9FF",
  dark_cyan = "#5699AF",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- The four "loud" categories: near-white + bold.
local strong = { fg = c.base8, bold = true }

-- ---------- editor / UI ----------
hi("Normal",       { fg = c.fg, bg = c.bg })
hi("NormalNC",     { fg = c.fg, bg = c.bg })
hi("NormalFloat",  { fg = c.fg, bg = c.base0 })
hi("FloatBorder",  { fg = c.base4, bg = c.base0 })
hi("FloatTitle",   { fg = c.base8, bg = c.base0, bold = true })
hi("ColorColumn",  { bg = c.base2 })
hi("Cursor",       { fg = c.bg, bg = c.fg })
hi("CursorLine",   { bg = c.base1 })
hi("CursorColumn", { bg = c.base1 })
hi("CursorLineNr", { fg = c.base8, bold = true })
hi("LineNr",       { fg = c.base5 })
hi("SignColumn",   { bg = c.bg })
hi("FoldColumn",   { fg = c.base5, bg = c.bg })
hi("Folded",       { fg = c.base6, bg = c.base1 })
hi("VertSplit",    { fg = c.base4, bg = c.bg })
hi("WinSeparator", { fg = c.base4, bg = c.bg })
hi("Visual",       { bg = c.base4 })
hi("VisualNOS",    { bg = c.base4 })
hi("MatchParen",   { fg = c.yellow, bold = true })
hi("NonText",      { fg = c.base4 })
hi("Whitespace",   { fg = c.base4 })
hi("SpecialKey",   { fg = c.base4 })
hi("EndOfBuffer",  { fg = c.bg })
hi("Directory",    { fg = c.base8, bold = true })
hi("Title",        { fg = c.base8, bold = true })
hi("Conceal",      { fg = c.base5 })
hi("Search",       { fg = c.bg, bg = c.yellow })
hi("IncSearch",    { fg = c.bg, bg = c.orange })
hi("CurSearch",    { fg = c.bg, bg = c.orange })
hi("WildMenu",     { fg = c.base8, bg = c.base4 })
hi("QuickFixLine", { bg = c.base2 })

-- statusline / tabline / popup menu
hi("StatusLine",   { fg = c.fg,   bg = c.base2 })
hi("StatusLineNC", { fg = c.base5, bg = c.base1 })
hi("TabLine",      { fg = c.base6, bg = c.base1 })
hi("TabLineSel",   { fg = c.base8, bg = c.bg, bold = true })
hi("TabLineFill",  { bg = c.base1 })
hi("Pmenu",        { fg = c.fg,   bg = c.base2 })
hi("PmenuSel",     { fg = c.base8, bg = c.base4 })
hi("PmenuSbar",    { bg = c.base3 })
hi("PmenuThumb",   { bg = c.base5 })

-- messages
hi("ErrorMsg",   { fg = c.red })
hi("WarningMsg", { fg = c.yellow })
hi("ModeMsg",    { fg = c.fg })
hi("MoreMsg",    { fg = c.teal })
hi("Question",   { fg = c.green })

-- ---------- syntax (legacy groups; your config has no treesitter) ----------
hi("Comment",        { fg = c.green })
hi("SpecialComment", { fg = c.base7 })
hi("Todo",           { fg = c.yellow, bold = true })

-- constants & literals
hi("Constant",  { fg = c.fg })        -- True / False / None land here
hi("String",    { fg = c.orange })
hi("Character", { fg = c.orange })
hi("Number",    { fg = c.orange })
hi("Float",     { fg = c.orange })
hi("Boolean",   { fg = c.fg })

-- identifiers
hi("Identifier", { fg = c.fg })       -- variables: plain fg, no bold
hi("Function",   strong)              -- function/method names + builtins: white bold

-- statements / keywords: white bold ...
hi("Statement",   strong)
hi("Conditional", strong)
hi("Repeat",      strong)
hi("Label",       strong)
hi("Keyword",     strong)
hi("Exception",   strong)
-- ... except operators, which stay plain fg
hi("Operator",    { fg = c.fg })

-- preprocessor / imports: keyword-like, so bold white
hi("PreProc",   strong)
hi("Include",   strong)
hi("Define",    strong)
hi("Macro",     strong)
hi("PreCondit", strong)

-- types: white bold
hi("Type",         strong)
hi("StorageClass", strong)
hi("Structure",    strong)
hi("Typedef",      strong)

-- specials
hi("Special",     { fg = c.fg })
hi("SpecialChar", { fg = c.orange })
hi("Tag",         { fg = c.fg })
hi("Delimiter",   { fg = c.fg })
hi("Debug",       { fg = c.red })
hi("Underlined",  { fg = c.blue, underline = true })
hi("Ignore",      { fg = c.base4 })
hi("Error",       { fg = c.red, bold = true })

-- ---------- diagnostics ----------
hi("DiagnosticError", { fg = c.red })
hi("DiagnosticWarn",  { fg = c.yellow })
hi("DiagnosticInfo",  { fg = c.blue })
hi("DiagnosticHint",  { fg = c.teal })
hi("DiagnosticOk",    { fg = c.green })
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.yellow })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.blue })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = c.teal })

-- ---------- diff / git ----------
hi("DiffAdd",    { fg = c.green })
hi("DiffChange", { fg = c.yellow })
hi("DiffDelete", { fg = c.red })
hi("DiffText",   { fg = c.blue, bg = c.base2 })
hi("Added",      { fg = c.green })
hi("Changed",    { fg = c.yellow })
hi("Removed",    { fg = c.red })

-- ---------- treesitter (only matters if you add nvim-treesitter later) ----------
local ts_links = {
  ["@keyword"]            = "Keyword",
  ["@keyword.function"]   = "Keyword",
  ["@keyword.return"]     = "Keyword",
  ["@keyword.operator"]   = "Operator",
  ["@conditional"]        = "Conditional",
  ["@repeat"]             = "Repeat",
  ["@exception"]          = "Exception",
  ["@function"]           = "Function",
  ["@function.call"]      = "Function",
  ["@function.builtin"]   = "Function",
  ["@function.method"]    = "Function",
  ["@method"]             = "Function",
  ["@constructor"]        = "Type",
  ["@type"]               = "Type",
  ["@type.builtin"]       = "Type",
  ["@variable"]           = "Identifier",
  ["@variable.builtin"]   = "Identifier",
  ["@parameter"]          = "Identifier",
  ["@field"]              = "Identifier",
  ["@property"]           = "Identifier",
  ["@constant"]           = "Constant",
  ["@constant.builtin"]   = "Constant",
  ["@boolean"]            = "Boolean",
  ["@number"]             = "Number",
  ["@string"]             = "String",
  ["@comment"]            = "Comment",
  ["@operator"]           = "Operator",
  ["@punctuation"]        = "Delimiter",
  ["@punctuation.bracket"]= "Delimiter",
}
for from, to in pairs(ts_links) do
  hi(from, { link = to })
end

-- ---------- LSP semantic tokens (pyright emits these — this is what
-- was coloring True/len/print blue before) ----------
local lsp_links = {
  ["@lsp.type.keyword"]        = "Keyword",
  ["@lsp.type.function"]       = "Function",
  ["@lsp.type.method"]         = "Function",
  ["@lsp.type.class"]          = "Type",
  ["@lsp.type.type"]           = "Type",
  ["@lsp.type.builtinType"]    = "Type",
  ["@lsp.type.interface"]      = "Type",
  ["@lsp.type.struct"]         = "Type",
  ["@lsp.type.enum"]           = "Type",
  ["@lsp.type.namespace"]      = "Identifier",
  ["@lsp.type.variable"]       = "Identifier",
  ["@lsp.type.parameter"]      = "Identifier",
  ["@lsp.type.property"]       = "Identifier",
  ["@lsp.type.enumMember"]     = "Constant",
  ["@lsp.type.string"]         = "String",
  ["@lsp.type.number"]         = "Number",
  ["@lsp.type.comment"]        = "Comment",
}
for from, to in pairs(lsp_links) do
  hi(from, { link = to })
end

-- ---------- nvim-tree ----------
hi("NvimTreeNormal",       { fg = c.fg, bg = c.bg })
hi("NvimTreeNormalNC",     { fg = c.fg, bg = c.bg })
hi("NvimTreeWinSeparator", { fg = c.bg, bg = c.bg })
hi("NvimTreeRootFolder",   { fg = c.base8, bold = true })
hi("NvimTreeFolderName",   { fg = c.fg })
hi("NvimTreeFolderIcon",   { fg = c.base6 })
hi("NvimTreeOpenedFolderName", { fg = c.base8, bold = true })
hi("NvimTreeGitDirty",     { fg = c.yellow })
hi("NvimTreeGitNew",       { fg = c.green })
hi("NvimTreeGitDeleted",   { fg = c.red })
hi("NvimTreeSpecialFile",  { fg = c.base8, bold = true })
hi("NvimTreeIndentMarker", { fg = c.base4 })
