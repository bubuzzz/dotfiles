-- lua/config/formatting.lua
local conform = require("conform")

local function exec_exists(p)
  return vim.fn.executable(p) == 1
end

-- ---------- Python (Ruff) detection ----------
local mason_ruff = vim.fn.stdpath("data") .. "/mason/bin/ruff"
local ruff_cmd = exec_exists(mason_ruff) and mason_ruff or "ruff"

conform.setup({
  formatters_by_ft = {
    -- Ruff only: first apply fixes, then format
    python = { "ruff_fix", "ruff_format" },
  },
  formatters = {
    -- ----- Python (Ruff) -----
    -- Apply autofixes
    ruff_fix = {
      command = ruff_cmd,
      args = {
        "check",
        "--fix",
        "--exit-zero",                    -- don't fail the formatter pipeline
        "--stdin-filename",
        "$FILENAME",
        "-",                              -- read from stdin
      },
      stdin = true,
    },
    -- Then format code
    ruff_format = {
      command = ruff_cmd,
      args = { "format", "-" },           -- read from stdin, write to stdout
      stdin = true,
    },
  },
})

-- Format on save for Python
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.py" },
  callback = function(args)
    require("conform").format({ bufnr = args.buf, lsp_fallback = true })
  end,
})
