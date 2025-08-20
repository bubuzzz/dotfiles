local cfg = require("customs.paraphase.config")

-- utils
local function split_lines(s)
  local out = {}
  for line in (s .. "\n"):gmatch("([^\n]*)\n") do table.insert(out, line) end
  if #out > 0 and out[#out] == "" then table.remove(out) end
  return out
end

local function get_visual_text_and_range()
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")
  local s_row, s_col = s[2]-1, s[3]-1
  local e_row, e_col = e[2]-1, e[3]-1
  if (e_row < s_row) or (e_row == s_row and e_col < s_col) then
    s_row, e_row = e_row, s_row; s_col, e_col = e_col, s_col
  end
  local lines = vim.api.nvim_buf_get_text(0, s_row, s_col, e_row, e_col+1, {})
  return table.concat(lines, "\n"), s_row, s_col, e_row, e_col
end

local function append_below(row, lines)
  vim.api.nvim_buf_set_lines(0, row + 1, row + 1, false, lines)
end

local function curl_post_json(url, body_tbl, cb)
  local ok_curl, curl = pcall(require, "plenary.curl")
  if not ok_curl then
    vim.notify("[Paraphase] plenary.nvim is required.", vim.log.levels.ERROR)
    return
  end
  curl.post(url, {
    headers = { ["Content-Type"] = "application/json" },
    body = vim.fn.json_encode(body_tbl),
    timeout = 30000,
    callback = function(res) vim.schedule(function() cb(res) end) end,
  })
end

local function run_on_selection(action, header, sys_prompt, user_prefix)
  local text, _, _, e_row = get_visual_text_and_range()
  if not text or text == "" then
    vim.notify("[Paraphase] No visual selection found.", vim.log.levels.WARN)
    return
  end

  local msg_user = user_prefix .. text
  if action == "summary" and cfg.summary_max_words then
    msg_user = ("Summarize in at most %d words.\n\n%s"):format(cfg.summary_max_words, msg_user)
  end

  local body = {
    model = cfg.model,
    stream = false,
    messages = {
      { role = "system", content = sys_prompt },
      { role = "user",   content = msg_user },
    },
    options = cfg.options,
  }

  local notif = vim.notify("[Paraphase] Working…", vim.log.levels.INFO, { title = "Paraphase" })

  curl_post_json(cfg.endpoint, body, function(res)
    if notif then pcall(vim.notify, "", vim.log.levels.INFO, { replace = notif }) end

    if not res or (res.status ~= 200 and res.status ~= 201) then
      local msg = res and (res.body or ("HTTP " .. tostring(res.status))) or "no response"
      vim.notify("[Paraphase] API error: " .. tostring(msg), vim.log.levels.ERROR)
      return
    end

    local ok, decoded = pcall(vim.fn.json_decode, res.body)
    local content = ok and decoded and decoded.message and decoded.message.content or nil
    if not content or content == "" then
      vim.notify("[Paraphase] Unexpected/empty response.", vim.log.levels.ERROR)
      return
    end

    local lines = { "", header }
    for _, l in ipairs(split_lines(content)) do table.insert(lines, l) end
    append_below(e_row, lines)
    vim.notify("[Paraphase] Appended result.", vim.log.levels.INFO)
  end)
end

-- public
local M = {}

function M.setup(opts)
  if opts then cfg.setup(opts) end

  -- commands use the *last* visual selection (marks persist even after <Esc>)
  vim.api.nvim_create_user_command("Enh", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    run_on_selection("enhance", "=== Enhanced ===", cfg.enhance_system_prompt, cfg.enhance_user_prefix)
  end, { desc = "Enhance last Visual selection", range = true })

  vim.api.nvim_create_user_command("Sum", function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    run_on_selection("summary", "=== Summary ===", cfg.summary_system_prompt, cfg.summary_user_prefix)
  end, { desc = "Summarize last Visual selection (bullets)", range = true })

  -- Optional visual-mode mappings (type Enh/Sym while still in Visual)
  -- vim.keymap.set("x", "Enh", ":<C-u>Enh<CR>", { desc = "Enhance selection" })
  -- vim.keymap.set("x", "Sym", ":<C-u>Sym<CR>", { desc = "Summarize selection" })
end

return M
