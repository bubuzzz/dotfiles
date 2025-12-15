
local M = {}

-- --- prettifier: keep it simple + readable in a panel
local function prettify_diag(msg)
  msg = msg:gsub("\r", ""):gsub("\194\160", " "):gsub("\t", "  ")

  -- Add structure without getting too clever
  msg = msg
    :gsub(" cannot be assigned to ", "\n\ncannot be assigned to ")
    :gsub(" of type ", "\nexpected type: ")
    :gsub("\n%s*Type ", "\n\nDetails:\nType ")
    :gsub("\n%s*\"([^\"]+)\" is not assignable to ", "\n- %1 is not assignable to ")
    :gsub("\n%s*\"__await__\" is not present", "\n  - missing: __await__()")

  -- Avoid excessive blank lines
  msg = msg:gsub("\n\n\n+", "\n\n")
  return msg
end

-- --- panel state
local state = {
  buf = nil,
  win = nil,
}

local function ensure_buf()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    return state.buf
  end

  state.buf = vim.api.nvim_create_buf(false, true) -- scratch, nofile
  vim.api.nvim_buf_set_name(state.buf, "Diagnostics Panel")
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].bufhidden = "hide"
  vim.bo[state.buf].swapfile = false
  vim.bo[state.buf].modifiable = false
  vim.bo[state.buf].filetype = "markdown" -- nice wrapping + readability
  return state.buf
end

local function open_panel(height)
  height = height or 12
  local buf = ensure_buf()

  -- open bottom split
  vim.cmd(height .. "split")
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, buf)

  -- panel behavior
  vim.wo[state.win].number = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].signcolumn = "no"
  vim.wo[state.win].wrap = true
  vim.wo[state.win].linebreak = true
  vim.wo[state.win].spell = false
  vim.wo[state.win].foldenable = false

  -- prevent accidental edits
  vim.bo[buf].modifiable = false

  -- easy close inside panel
  vim.keymap.set("n", "q", function()
    M.close()
  end, { buffer = buf, silent = true })
end

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

function M.toggle(height)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    M.close()
  else
    open_panel(height)
  end
end

function M.show_current_line(copy_to_clipboard)
  local buf = ensure_buf()

  local d = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })[1]
  local text
  if not d then
    text = "No diagnostic on the current line."
  else
    text = prettify_diag(d.message)
  end

  local lines = vim.split(text, "\n", { plain = true })

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  if copy_to_clipboard then
    vim.fn.setreg("+", text)
    vim.notify("Diagnostic copied to clipboard")
  end

  -- if panel isn't open, open it
  if not (state.win and vim.api.nvim_win_is_valid(state.win)) then
    open_panel(12)
  end

  -- keep cursor at top of panel
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_set_cursor(state.win, { 1, 0 })
  end
end

return M
