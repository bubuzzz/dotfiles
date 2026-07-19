local M = {}

function M.set(params) 
    -- Formatting
    require("conform").setup({
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_format" },
        elixir = { "mix" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      }
    })

    -- File picker
    require("mini.pick").setup({
      window = {
        config = function()
          local height = math.floor(0.3 * vim.o.lines)
          local width = vim.o.columns
          return {
            anchor = "NW",        
            row = 0, 
            col = 0,
            height = height,
            width = width,
            border = "single",     
          }
        end,
      },
    })
    
    -- Pair bracket
    require("mini.pairs").setup({})
    
    require("nvim-treesitter").setup({})
    vim.api.nvim_create_autocmd("FileType", {
      pattern = params.treesitter_pattern,
      callback = function() vim.treesitter.start() end,
    })
end

return M
