-- lua/config/lsp.lua
local M = {}

-- ---------- helpers ----------
-- Get an executable from Mason's bin (fallback to PATH)
local function mason_exe(bin)
  local p = vim.fn.stdpath("data") .. "/mason/bin/" .. bin
  if vim.fn.executable(p) == 1 then return p end
  p = vim.fn.exepath(bin)
  return p ~= "" and p or nil
end

-- Nearest project root for current buffer
local function root_dir(markers, fallback)
  return vim.fs.root(0, markers) or fallback or vim.loop.cwd()
end

function M.setup()
  require("mason").setup()

  -- Auto-install LSP servers via Mason
  require("mason-lspconfig").setup({
    ensure_installed = { "pyright", "ruff", "svelte", "ts_ls" },
    automatic_installation = true,
  })


  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  ---------------------------------------------------------------------------
  -- Python (Pyright) via vim.lsp.start
  ---------------------------------------------------------------------------
  do
    local pyright = mason_exe("pyright-langserver")
    if not pyright then
      vim.notify("[Pyright] pyright-langserver not found. Install with :Mason.", vim.log.levels.WARN)
    else
      vim.lsp.start({
        name = "pyright",
        cmd = { pyright, "--stdio" },
        root_dir = root_dir({
          "pyproject.toml",
          "setup.cfg",
          "setup.py",
          "requirements.txt",
          ".git",
          ".venv",
        }),
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic", -- or "strict"
              autoImportCompletions = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true,
              autoSearchPaths = true,
            },
          },
        },
      })
    end
  end

  ---------------------------------------------------------------------------
  -- (Optional) Ruff LSP for linting/quick-fixes
  ---------------------------------------------------------------------------
  do
    local ruff = mason_exe("ruff-lsp")
    if ruff then
      vim.lsp.start({
        name = "ruff_lsp",
        cmd = { ruff },
        root_dir = root_dir({ "pyproject.toml", ".git" }),
        capabilities = capabilities,
        init_options = { settings = { args = {} } },
      })
    end
  end
end

return M
