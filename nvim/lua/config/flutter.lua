
-- somewhere in your config after plugins load (e.g., lua/config/flutter.lua)
local has_flutter, flutter_tools = pcall(require, "flutter-tools")
if has_flutter then
  flutter_tools.setup({
    fvm = true,                 -- <— use per-project FVM SDK automatically
    -- flutter_path = "fvm",    -- optional; auto when fvm=true
    widget_guides = { enabled = true },
    closing_tags = { enabled = true, prefix = "</", highlight = "Comment" },
    dev_log = { enabled = true, open_cmd = "tabedit" },

    lsp = {
      color = { enabled = true },
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      on_attach = function(client, bufnr)
        local map = function(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
        end
        map("n", "K", vim.lsp.buf.hover)
        map("n", "gd", vim.lsp.buf.definition)
        map("n", "gr", require("telescope.builtin").lsp_references)
        map("n", "<leader>rn", vim.lsp.buf.rename)
        map("n", "<leader>ca", vim.lsp.buf.code_action)
        map({ "n", "v" }, "<leader>f", function() vim.lsp.buf.format({ async = true }) end)
      end,
      settings = {
        dart = {
          completeFunctionCalls = true,
          renameFilesWithClasses = "prompt",
          analysisExcludedFolders = { vim.fn.getcwd() .. "/build" },
        },
      },
    },

    -- Debugger (DAP) – optional but handy
    debugger = {
      enabled = true,
      run_via_dap = true,  -- :FlutterRun will use nvim-dap
      exception_breakpoints = { "uncaught" },
      register_configurations = function(paths)
        local dap = require("dap")
        dap.adapters.dart = dap.adapters.dart or {
          type = "executable",
          command = paths.dart_sdk .. "/bin/dart",
          args = { "debug_adapter" },
        }
        dap.configurations.dart = {
          {
            type = "dart",
            request = "launch",
            name = "Launch Flutter",
            dartSdkPath = paths.dart_sdk,
            flutterSdkPath = paths.flutter_sdk,
            program = "${workspaceFolder}/lib/main.dart",
            cwd = "${workspaceFolder}",
          },
        }
      end,
    },
  })
end
