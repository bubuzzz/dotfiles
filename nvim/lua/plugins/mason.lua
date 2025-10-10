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


  -- {
  --     "mfussenegger/nvim-dap-python",
  --     ft = "python",
  --     dependencies = {
  --       "mfussenegger/nvim-dap",
  --     },
  --     config = function(_, opts)
  --       require("dap-python").setup(opts)
  --       -- Further configuration if needed
  --     end,
  -- },

  { "jay-babu/mason-nvim-dap.nvim" },

  -- Testing (optional)
  { "nvim-neotest/neotest" },
  { "Issafalcon/neotest-dotnet" },
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap" },
    config = function()
      require("config.flutter")  -- your lua/config/flutter.lua
    end,
  }
}
