return {
  --
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, },

  -- 
  {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_transparent_background = 1
      vim.g.gruvbox_material_foreground = "mix"
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_ui_contrast = "high"
      vim.g.gruvbox_material_float_style = "bright"
      vim.g.gruvbox_material_statusline_style = "material"
      vim.g.gruvbox_material_cursor = "auto"

      vim.g.gruvbox_material_better_performance = 1
    end
  },
  --
  { 
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {}
      
      vim.api.nvim_create_user_command("Ntt", "NvimTreeToggle", {})
    end,
  },
 
  --
  { "mhinz/vim-startify" },
 
  --
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  
  --
  {'akinsho/toggleterm.nvim', version = "*", config = true}
}
