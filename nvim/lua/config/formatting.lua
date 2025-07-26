-- lua/config/formatting.lua
local conform = require("conform")

-- ---------- C# (CSharpier) detection ----------
local mason_csharpier = vim.fn.stdpath("data") .. "/mason/bin/csharpier"
local dotnet_csharpier = vim.fn.expand("~/.dotnet/tools/csharpier")

local function exec_exists(p)
  return vim.fn.executable(p) == 1
end

-- Prefer Mason's csharpier; fall back to the global dotnet tool
local csharpier_cmd = exec_exists(mason_csharpier) and mason_csharpier
  or (exec_exists(dotnet_csharpier) and dotnet_csharpier)

if csharpier_cmd == nil then
  vim.notify(
    "[conform] No csharpier found. Install it via :MasonInstall csharpier or `dotnet tool install -g csharpier`.",
    vim.log.levels.ERROR
  )
end

-- ---------- Python (Ruff) detection ----------
local mason_ruff = vim.fn.stdpath("data") .. "/mason/bin/ruff"
local ruff_cmd = exec_exists(mason_ruff) and mason_ruff or "ruff"

conform.setup({
  formatters_by_ft = {
    cs = { "csharpier_format" },
    -- Ruff only: first apply fixes, then format
    python = { "ruff_fix", "ruff_format" },
  },
  formatters = {
    -- ----- C# -----
    csharpier_format = {
      command = csharpier_cmd or "csharpier",
      stdin = false,
      args = { "format", "$FILENAME" },
    },

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

-- Format on save for both C# and Python
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.cs", "*.py" },
  callback = function(args)
    require("conform").format({ bufnr = args.buf, lsp_fallback = true })
  end,
})
