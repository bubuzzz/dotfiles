local M = {}

local term_buf = nil
local term_win = nil

function M.toggle()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
    return
  end

  term_buf = vim.api.nvim_create_buf(false, true) -- not listed, scratch buffer

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  term_win = vim.api.nvim_open_win(term_buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'solid',
  })

  vim.api.nvim_buf_set_option(term_buf, 'bufhidden', 'wipe')

  vim.fn.termopen(os.getenv('SHELL')) 

  vim.cmd("startinsert")
end


return M

