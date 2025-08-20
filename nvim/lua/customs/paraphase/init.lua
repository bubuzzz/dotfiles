local cfg = require("customs.paraphase.config")

local function split_lines(s)
  local t = {}
  for line in (s .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(t, line)
  end
  if #t > 0 and t[#t] == "" then table.remove(t, #t) end
  return t
end

-- Read the *last* visual selection by using marks '< and '>
local function get_visual_text_and_range()
  local bufnr = 0
  -- getpos returns {bufnum, lnum, col, off}; convert to 0-based row/col
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")
  local s_row, s_col = s[2] - 1, s[3] - 1
  local e_row, e_col = e[2] - 1, e[3] - 1

  -- normalize order if needed
  if (e_row < s_row) or (e_row == s_row and e_col < s_col) then
    s_row, e_row = e_row, s_row
    s_col, e_col = e_col, s_col
  end

  -- include the last character in the slice
  local lines = vim.api.nvim_buf_get_text(bufnr, s_row, s_col, e_row, e_col + 1, {})
  local text = table.concat(lines, "\n")
  return text, s_row, s_col, e_row, e_col
end

local function append_below(row, lines)
  vim.api.nvim_buf_set_lines(0, row + 1, row + 1, false, lines)
end

local function notify_err(msg)
  vim.notify("[Paraphase] " .. msg, vim.log.levels.ERROR)
end

local function enhance_selected_async()
  local ok_curl, curl = pcall(require, "plenary.curl")
  if not ok_curl then
    vim.notify("[Paraphase] plenary.nvim is required.", vim.log.levels.ERROR)
    return
  end

  local text, _, _, e_row = get_visual_text_and_range()
  if not text or text == "" then
    vim.notify("[Paraphase] No visual selection found.", vim.log.levels.WARN)
    return
  end

  local body_tbl = {
    model = cfg.model,
    stream = false,  -- simpler; switch to true if you want token streaming
    messages = {
      { role = "system", content = cfg.system_prompt },
      { role = "user",   content = ("Improve the following text:\n\n%s"):format(text) },
    },
    options = cfg.options,  -- optional; see config.lua
  }

  local notif = vim.notify("[Paraphase] Improving selection…", vim.log.levels.INFO, { title = "Paraphase" })

  curl.post(cfg.endpoint, {
    headers = { ["Content-Type"] = "application/json" },  -- no auth header for local Ollama
    body = vim.fn.json_encode(body_tbl),
    timeout = 30000,
    callback = function(res)
      vim.schedule(function()
        if notif then pcall(vim.notify, "", vim.log.levels.INFO, { replace = notif }) end

        if not res or (res.status ~= 200 and res.status ~= 201) then
          local msg = res and (res.body or ("HTTP " .. tostring(res.status))) or "no response"
          vim.notify("[Paraphase] API error: " .. tostring(msg), vim.log.levels.ERROR)
          return
        end

        local ok, decoded = pcall(vim.fn.json_decode, res.body)
        if not ok or not decoded or not decoded.message or not decoded.message.content then
          vim.notify("[Paraphase] Unexpected response from Ollama.", vim.log.levels.ERROR)
          return
        end

        local content = decoded.message.content
        local lines = { "", "— Enhanced —" }
        for line in (content .. "\n"):gmatch("([^\n]*)\n") do
          if line ~= "" or #lines > 0 then table.insert(lines, line) end
        end
        -- trim trailing empty line
        if lines[#lines] == "" then table.remove(lines) end

        vim.api.nvim_buf_set_lines(0, e_row + 1, e_row + 1, false, lines)
        vim.notify("[Paraphase] Appended enhanced text.", vim.log.levels.INFO)
      end)
    end,
  })
end

local M = {}

function M.setup(opts)
  if opts then cfg.setup(opts) end

  -- User command: works even if ':' exited Visual; uses the last visual marks
  vim.api.nvim_create_user_command("Enh", function()
    -- leave visual mode if still in it; marks remain
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    enhance_selected_async()
  end, { desc = "Enhance last Visual selection", range = true })

  -- Optional: Visual-mode mapping so you can just type 'Enh' after selecting
  -- Put a mapping in your shortcuts if you prefer:
  -- vim.keymap.set("x", "Enh", ":<C-u>Enh<CR>", { desc = "Enhance selection" })
end

return M
