-- lua/config/utils.lua
local M = {}

-- Find the project root (prefer LSP root; fallback to common markers)
function M.get_project_root(bufnr)
  bufnr = bufnr or 0

  -- 1) LSP root if available
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, c in ipairs(clients) do
    if c.config and c.config.root_dir then
      return c.config.root_dir
    end
  end

  -- 2) Fallback: look for common markers upward from file
  local file = vim.api.nvim_buf_get_name(bufnr)
  local start = (file ~= "" and vim.fs.dirname(file)) or vim.uv.cwd()

  local markers = {
    ".git",
    "pyproject.toml",
    "Cargo.toml",
    "package.json",
    "*.sln",
    "*.csproj",
    "pom.xml",
    "build.gradle",
  }

  local found = vim.fs.find(markers, {
    path = start,
    upward = true,
    type = "file",
    stop = vim.uv.os_homedir(),
  })
  if #found > 0 then
    return vim.fs.dirname(found[1])
  end

  -- Last resort: current working dir
  return vim.uv.cwd()
end

return M
