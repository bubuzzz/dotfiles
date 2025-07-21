local M = {}

local term_buf = nil
local term_win = nil
local has_started_term = false

function M.toggle()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    M.close()
    return
  end

  if not (term_buf and vim.api.nvim_buf_is_valid(term_buf)) then
    term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(term_buf, 'bufhidden', 'hide')
    has_started_term = false
  end

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

  if not has_started_term then
    vim.fn.termopen(os.getenv("SHELL"))
    has_started_term = true
  end

  vim.cmd("startinsert")
end

function M.close()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
  end
end

vim.api.nvim_create_user_command("Tterm", function()
  M.toggle()
end, {})

vim.api.nvim_create_user_command("TtermClose", function()
  M.close()
end, {})

return M
