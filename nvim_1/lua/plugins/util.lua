return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup {
        winopts = {
          height = 0.3,
          width = 1.0,
          row = 0.0,
          col = 0.0,
          border = "rounded",
          preview = {
            hidden = true
          }
        },
      }
    end,
  },

  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Rainbow parentheses: each bracket pair gets a color by nesting depth, so
  -- matching pairs share a color at a glance (Emacs rainbow-delimiters feel).
  -- Regex/syntax-based — no treesitter, matching the homage-black setup.
  {
    "luochen1990/rainbow",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.rainbow_active = 1
    end,
  },
}

