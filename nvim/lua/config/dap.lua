-- lua/config/dap.lua
local M = {}

function M.setup()
  local ok_dap, dap = pcall(require, "dap")
  if not ok_dap then
    vim.notify("nvim-dap not found", vim.log.levels.ERROR)
    return
  end

  local ok_dapui, dapui = pcall(require, "dapui")
  if not ok_dapui then
    vim.notify("nvim-dap-ui not found", vim.log.levels.ERROR)
    return
  end

  -- Ensure netcoredbg is installed automatically
  local ok_mnd, mnd = pcall(require, "mason-nvim-dap")
  if ok_mnd then
    mnd.setup({
      ensure_installed = { "netcoredbg" },
      automatic_setup = true,
    })
  end

  dapui.setup()

  -- Configure coreclr adapter for C#
  dap.adapters.coreclr = {
    type = "executable",
    command = "netcoredbg", -- mason-nvim-dap adds it to PATH
    args = { "--interpreter=vscode" },
  }

  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "Launch - netcoredbg",
      request = "launch",
      program = function()
        return vim.fn.input("Path to dll: ",
          vim.fn.getcwd() .. "/bin/Debug/net8.0/YourApp.dll", "file")
      end,
    },
  }

  -- Keymaps
  vim.keymap.set("n", "<F5>", dap.continue)
  vim.keymap.set("n", "<F10>", dap.step_over)
  vim.keymap.set("n", "<F11>", dap.step_into)
  vim.keymap.set("n", "<F12>", dap.step_out)
  vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
  vim.keymap.set("n", "<leader>du", dapui.toggle)
end

return M
