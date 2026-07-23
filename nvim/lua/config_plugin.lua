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
    
    -- Markdown rendering
    require("render-markdown").setup({
        enabled = false,
        anti_conceal = { enabled = false },
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
        desc = "Turn off markdown rendering until explicitly toggled back on",
        callback = function(ev)
            local state = require("render-markdown.state")
            if not vim.tbl_contains(state.file_types, vim.bo[ev.buf].filetype) then
                return
            end
            if state.get(ev.buf).enabled then
                require("render-markdown.api").buf_disable()
            end
        end,
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
