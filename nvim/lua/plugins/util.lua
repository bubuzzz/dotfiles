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
        },
        preview_opts = 'hidden',
      }

      -- Create alias :Ff to run :FzfLua files
      vim.api.nvim_create_user_command("Ff", function()
        require("fzf-lua").files()
      end, {})
    end,
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
  },
}

