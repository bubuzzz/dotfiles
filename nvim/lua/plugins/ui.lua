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
      
      vim.api.nvim_create_user_command("Tt", "NvimTreeToggle", {})
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
  {'akinsho/toggleterm.nvim', version = "*", config = true},
  --
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
	  mode = "buffers",
	  separator_style = { "", "" },
	  show_buffer_close_icons = true,
	  show_close_icon = true,
	  always_show_bufferline = true,
	  indicator = {
	    style = "none", 
	  },
	  modified_icon = "", -- remove red dot on modified
	  offsets = {{
	    filetype = "NvimTree",
	    text = "Directory",  -- optional title above the tree
	    highlight = "Directory", -- highlight group for the text
	    text_align = "left",   -- or "left", "right"
	    separator = false,       -- disable separator between tree and tabs
	    highlight = "BufferLineOffset", -- use your custom group here
	  }},
        },
	highlights = {
	  buffer_selected = {
	  underline = false,
	  italic = false,
	  bold = false,
	  fg = "#ffffff",
	},
	tab_selected = {
	  underline = false,
	  italic = false,
	  bold = false,
	  fg = "#ffffff",
	},
	separator = {
	  fg = "NONE",
	  bg = "NONE",
	},
	separator_selected = {
	  fg = "NONE",
	  bg = "NONE",
	},
	separator_visible = {
	  fg = "NONE",
	  bg = "NONE",
	},
      },
    })

    vim.api.nvim_set_hl(0, "BufferLineOffset", {
      fg = "#ffffff",
      bg = "#44475a",
      bold = true,
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        vim.api.nvim_set_hl(0, "BufferLineOffset", {
          fg = "#ffffff",
          bg = "#1a1a1a",
          bold = true,
        })
      end,
    })

    end,
  }
}
