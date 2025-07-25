-- -- lua/config/lsp.lua
-- local M = {}
--
-- function M.setup()
--   -- Mason core
--   require("mason").setup()
--
--   -- Mason LSP config
--   local mason_lspconfig = require("mason-lspconfig")
--   mason_lspconfig.setup({
--     ensure_installed = { "omnisharp" },
--     automatic_installation = true,
--   })
--
--   -- Capabilities for nvim-cmp
--   local capabilities = require("cmp_nvim_lsp").default_capabilities()
--
--   -- LSP setup
--   local lspconfig = require("lspconfig")
--
--   -- Setup OmniSharp (C#)
--   lspconfig.omnisharp.setup({
--     capabilities = capabilities,
--     enable_editorconfig_support = true,
--     enable_roslyn_analyzers = true,
--     organize_imports_on_format = true,
--     enable_import_completion = true,
--     handlers = {
--       ["textDocument/semanticTokens/full"] = function() end,
--     },
--   })
-- end
--
-- return M
--

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
    ensure_installed = { "omnisharp" },
    automatic_installation = true,
  })

  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  local lspconfig = require("lspconfig")

  -- Find OmniSharp binary
  local omnisharp_bin = find_omnisharp()
  if not omnisharp_bin then
    vim.notify("[OmniSharp] Could not find binary. Run :Mason and install omnisharp.", vim.log.levels.WARN)
    return
  end

  -- Setup OmniSharp
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

return M
