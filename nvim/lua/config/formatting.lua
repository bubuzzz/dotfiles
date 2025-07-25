
-- lua/config/formatting.lua
local conform = require("conform")

local mason_bin     = vim.fn.stdpath("data") .. "/mason/bin/csharpier"
local dotnet_tool   = vim.fn.expand("~/.dotnet/tools/csharpier")

local function exec_exists(p) return vim.fn.executable(p) == 1 end

-- Prefer Mason's csharpier; fall back to the global dotnet tool
local csharpier_cmd = exec_exists(mason_bin) and mason_bin
                   or (exec_exists(dotnet_tool) and dotnet_tool)
if csharpier_cmd == nil then
  vim.notify(
    "[conform] No csharpier found. Install it via :MasonInstall csharpier or `dotnet tool install -g csharpier`.",
    vim.log.levels.ERROR
  )
end

conform.setup({
  formatters_by_ft = {
    cs = { "csharpier_format" },
  },
  formatters = {
    -- Use `csharpier format <file>` (no stdin)
    csharpier_format = {
      command = csharpier_cmd or "csharpier",
      stdin = false,
      args = { "format", "$FILENAME" },
    },
  },
})

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.cs",
  callback = function(args)
    require("conform").format({ bufnr = args.buf, lsp_fallback = true })
  end,
})

