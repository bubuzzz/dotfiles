return {
  -- Mason + LSP
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },

  {
  "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("config.lsp").setup()
    end,
  },

  -- Completion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "rafamadriz/friendly-snippets" },

  -- Formatting
  { "stevearc/conform.nvim" },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Debugging
  { "mfussenegger/nvim-dap" },


  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      require("config.dap").setup()
    end,
  },

  { "mfussenegger/nvim-dap-python" }, 

  { "jay-babu/mason-nvim-dap.nvim" },

  -- Testing (optional)
  { "nvim-neotest/neotest" },
  { "Issafalcon/neotest-dotnet" },
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    config = function()

    local border_chars = {
      { "+", "FloatBorder" },
      { "-", "FloatBorder" },
      { "+", "FloatBorder" },
      { "|", "FloatBorder" },
      { "+", "FloatBorder" },
      { "-", "FloatBorder" },
      { "+", "FloatBorder" },
      { "|", "FloatBorder" },
    }

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover,
      { border = border_chars }
    )

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help,
      { border = border_chars }
    )

    -- Colors (no shadow)
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#b8bb26", bg = "none" }) 

      require("lsp_signature").setup({
        bind = true,
        handler_opts = {
          border = border_chars
        },
        hint_enable = false,          -- no inline virtual text
        floating_window = true,
        select_signature_key = "<C-n>",  -- next overload
        toggle_key = "<C-s>",             -- toggle popup
        zindex = 60,
      })
    end,
  }
}
