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
}

