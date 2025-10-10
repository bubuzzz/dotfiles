-- lua/config/lsp.lua
local M = {}

-- ---------- helpers ----------
local function exists(p)
  local stat = vim.loop.fs_stat(p)
  return stat and stat.type == "file"
end

-- Find OmniSharp binary (from Mason or fallbacks)
local function find_omnisharp()
  local ok, mr = pcall(require, "mason-registry")
  if ok and mr.has_package and mr.has_package("omnisharp") then
    local pkg = mr.get_package("omnisharp")
    if pkg and pkg.get_install_path then
      local base = pkg:get_install_path()
      for _, p in ipairs({
        base .. "/OmniSharp",
        base .. "/omnisharp/OmniSharp",
        base .. "/run",
        base .. "/OmniSharp.exe",
      }) do
        if exists(p) then return p end
      end
    end
  end
  local data = vim.fn.stdpath("data")
  for _, p in ipairs({
    data .. "/mason/packages/omnisharp/OmniSharp",
    data .. "/mason/packages/omnisharp/omnisharp/OmniSharp",
    data .. "/mason/bin/omnisharp", -- mason shim
  }) do
    if exists(p) then return p end
  end
  return nil
end

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
    ensure_installed = { "omnisharp", "pyright", "ruff" },
    automatic_installation = true,
  })

  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  ---------------------------------------------------------------------------
  -- C# (OmniSharp) via vim.lsp.start
  ---------------------------------------------------------------------------
  do
    local omnisharp_bin = find_omnisharp()
    if not omnisharp_bin then
      vim.notify("[OmniSharp] Could not find binary. Run :Mason and install omnisharp.", vim.log.levels.WARN)
    else
      local pid = vim.fn.getpid()
      vim.lsp.start({
        name = "omnisharp",
        cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) },
        root_dir = root_dir({ "*.sln", "*.csproj", ".git" }),
        capabilities = capabilities,
        handlers = {
          -- some OmniSharp builds misbehave with full semantic tokens
          ["textDocument/semanticTokens/full"] = function() end,
        },
      })
    end
  end

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
