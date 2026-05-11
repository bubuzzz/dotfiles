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
}

