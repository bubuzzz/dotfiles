-- lua/config/lsp.lua
local M = {}

-- Helper to check if a file exists
local function exists(p)
  local stat = vim.loop.fs_stat(p)
  return stat and stat.type == "file"
end

-- Find OmniSharp binary
local function find_omnisharp()
  -- Try mason-registry safely
  local ok, mr = pcall(require, "mason-registry")
  if ok and mr.has_package and mr.has_package("omnisharp") then
    local pkg = mr.get_package("omnisharp")
    if pkg and pkg.get_install_path then
      local pkg_path = pkg:get_install_path()
      local candidates = {
        pkg_path .. "/OmniSharp",
        pkg_path .. "/omnisharp/OmniSharp",
        pkg_path .. "/run",
        pkg_path .. "/OmniSharp.exe",
      }
      for _, p in ipairs(candidates) do
        if exists(p) then
          return p
        end
      end
    end
  end

  -- Fallback paths
  local data = vim.fn.stdpath("data")
  local fallbacks = {
    data .. "/mason/packages/omnisharp/OmniSharp",
    data .. "/mason/packages/omnisharp/omnisharp/OmniSharp",
    data .. "/mason/bin/omnisharp", -- mason shim
  }
  for _, p in ipairs(fallbacks) do
    if exists(p) then
      return p
    end
  end

  return nil
end

function M.setup()
  require("mason").setup()

  local mason_lspconfig = require("mason-lspconfig")
  mason_lspconfig.setup({
    -- add pyright here
    ensure_installed = { "omnisharp", "pyright" },
    automatic_installation = true,
  })

  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  local lspconfig = require("lspconfig")

  ---------------------------------------------------------------------------
  -- C# (OmniSharp)
  ---------------------------------------------------------------------------
  local omnisharp_bin = find_omnisharp()
  if not omnisharp_bin then
    vim.notify("[OmniSharp] Could not find binary. Run :Mason and install omnisharp.", vim.log.levels.WARN)
  else
    local pid = vim.fn.getpid()
    lspconfig.omnisharp.setup({
      cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) },
      capabilities = capabilities,
      enable_editorconfig_support = true,
      enable_roslyn_analyzers = true,
      organize_imports_on_format = true,
      enable_import_completion = true,
      handlers = {
        ["textDocument/semanticTokens/full"] = function() end,
      },
    })
  end

  ---------------------------------------------------------------------------
  -- Python (Pyright)
  ---------------------------------------------------------------------------
  if lspconfig.pyright then
    lspconfig.pyright.setup({
      capabilities = capabilities,
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic", -- or "strict"
            autoImportCompletions = true,
          },
        },
      },
    })
  end

  ---------------------------------------------------------------------------
  -- Per-filetype indentation tweaks (optional)
  ---------------------------------------------------------------------------
  -- C#: 4 spaces
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "cs",
    callback = function()
      vim.bo.shiftwidth = 4
      vim.bo.tabstop = 4
      vim.bo.softtabstop = 4
      vim.bo.expandtab = true
    end,
  })

  -- Python: 4 spaces
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
      vim.bo.shiftwidth = 4
      vim.bo.tabstop = 4
      vim.bo.softtabstop = 4
      vim.bo.expandtab = true
    end,
  })
end

return M
