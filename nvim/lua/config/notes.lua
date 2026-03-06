local M = {}

local notes_dir = vim.fn.expand("~/Projects/notes/")
local scratch_dir = notes_dir .. "scratch/"
local ignore_dirs = { ".zk", ".git", "templates", "scratch" }

local function get_folders()
  local folders = { "." }
  local handle = vim.loop.fs_scandir(notes_dir)
  if not handle then return folders end
  while true do
    local name, typ = vim.loop.fs_scandir_next(handle)
    if not name then break end
    if typ == "directory" and not vim.tbl_contains(ignore_dirs, name) then
      table.insert(folders, name)
    end
  end
  table.sort(folders, function(a, b)
    if a == "." then return true end
    if b == "." then return false end
    return a < b
  end)
  return folders
end

local function float_input(title_text, callback)
  local width = 40
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = math.floor((vim.o.lines - 1) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = title_text,
    title_pos = "center",
  })
  vim.cmd("startinsert")
  vim.keymap.set("i", "<CR>", function()
    local val = vim.trim(vim.api.nvim_get_current_line())
    vim.cmd("stopinsert")
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
    if val ~= "" then callback(val) end
  end, { buffer = buf })
  vim.keymap.set({ "i", "n" }, "<Esc>", function()
    vim.cmd("stopinsert")
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
  end, { buffer = buf })
end

local function create_note(folder)
  float_input(" New Note (" .. folder .. ") ", function(title)
    require("zk").new({ title = title, dir = folder })
  end)
end

function M.new_note()
  local folders = get_folders()
  table.insert(folders, "+ New folder")
  vim.ui.select(folders, { prompt = "Select folder:" }, function(choice)
    if not choice then return end
    if choice == "+ New folder" then
      float_input(" New Folder ", function(name)
        vim.fn.mkdir(notes_dir .. name, "p")
        create_note(name)
      end)
    else
      create_note(choice)
    end
  end)
end

function M.scratchpad()
  local date = os.date("%Y-%m-%d")
  local path = scratch_dir .. date .. ".md"
  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile({ "# Scratchpad " .. date, "" }, path)
  end
  vim.cmd("edit " .. path)
end

return M
