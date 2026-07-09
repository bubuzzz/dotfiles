return {
  --
  { "blazkowolf/gruber-darker.nvim" },
  { 'ntk148v/komau.vim' },
  {
    "ellisonleao/gruvbox.nvim", priority = 1000, config = true,
  },

  {'alligator/accent.vim', 
    config = function()
      vim.g.accent_colour = 'green'
      vim.g.accent_darken = 1
      vim.g.accent_no_bg = 1

      -- @function / @variable bolding lives in config/theme.lua's ColorScheme
      -- autocmd so it survives the colorscheme being re-applied.
    end

  },
  --
  {
   "catppuccin/nvim", name = "catppuccin", priority = 1000 ,
   config = function()
      require("catppuccin").setup{
        flavour = "mocha",
        color_overrides = {
          mocha = {
            base = "#000000",
          },
        },
      }
    end
  },
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
      require("nvim-tree").setup {
        view = {
          side = "right",
        },
        filters = {
          dotfiles = true,
          custom = {
            "__pycache__",
            ".pytest_cache",
            ".mypy_cache",
            ".ruff_cache",
          },
        },

      }
      
      vim.api.nvim_create_user_command("Tt", "NvimTreeToggle", {})
    end,
  },
 
  --
  {
    "mhinz/vim-startify",
    config = function()
      -- No MRU / file lists, and drop the <empty buffer>/<quit> special entries.
      -- A single list whose type-function returns nothing renders zero lines but
      -- keeps lists[0] valid, avoiding startify's E684 on the cursor-offset calc.
      vim.g.startify_lists = { { type = function() return {} end } }
      vim.g.startify_enable_special = 0

      -- Keep only the cowsay fortune, centered horizontally and vertically.
      local cow = vim.fn["startify#center"](vim.fn["startify#fortune#cowsay"]())
      local pad = math.max(math.floor((vim.o.lines - #cow) / 2) - 1, 0)
      local header = {}
      for _ = 1, pad do
        table.insert(header, "")
      end
      vim.list_extend(header, cow)
      vim.g.startify_custom_header = header
    end,
  },
 
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
