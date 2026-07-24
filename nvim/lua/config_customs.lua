local M = {}

local conf = {}
local ns = vim.api.nvim_create_namespace("config_customs")

local function notify(msg, level)
    vim.notify("[llm] " .. msg, level or vim.log.levels.INFO)
end

local function exit_visual()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
end

local function visual_selection()
    local s, e = vim.fn.getpos("'<"), vim.fn.getpos("'>")
    local s_row, s_col = s[2] - 1, s[3] - 1
    local e_row, e_col = e[2] - 1, e[3] - 1
    if s_row < 0 or e_row < 0 then
        return nil
    end
    if e_row < s_row or (e_row == s_row and e_col < s_col) then
        s_row, e_row = e_row, s_row
        s_col, e_col = e_col, s_col
    end

    local lines
    local mode = vim.fn.visualmode()
    if mode == "v" then
        local last = vim.api.nvim_buf_get_lines(0, e_row, e_row + 1, false)[1] or ""
        lines = vim.api.nvim_buf_get_text(0, s_row, s_col, e_row, math.min(e_col + 1, #last), {})
    else
        lines = vim.api.nvim_buf_get_lines(0, s_row, e_row + 1, false)
    end
    return table.concat(lines, "\n"), e_row
end

local function append_below(buf, mark, header, content)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    local pos = vim.api.nvim_buf_get_extmark_by_id(buf, ns, mark, {})
    vim.api.nvim_buf_del_extmark(buf, ns, mark)
    if not pos[1] then
        return
    end

    local lines = { "", header }
    for _, l in ipairs(vim.split(vim.trim(content), "\n", { plain = true })) do
        table.insert(lines, l)
    end
    table.insert(lines, "")
    vim.api.nvim_buf_set_lines(buf, pos[1] + 1, pos[1] + 1, false, lines)
end

local function post(payload, cb)
    vim.system(
        { "curl", "-sS", "-X", "POST", "-H", "Content-Type: application/json",
          "--data-binary", "@-", conf.endpoint },
        { stdin = vim.json.encode(payload), text = true },
        vim.schedule_wrap(function(out)
            if out.code ~= 0 then
                notify("request failed: " .. (out.stderr or out.code), vim.log.levels.ERROR)
                return
            end
            local ok, decoded = pcall(vim.json.decode, out.stdout)
            local content = ok and decoded and decoded.message and decoded.message.content
            if not content or content == "" then
                notify("empty response", vim.log.levels.ERROR)
                return
            end
            cb(content)
        end)
    )
end

local function input(spec, visual)
    if visual then
        exit_visual()
        return visual_selection()
    end
    if spec and spec.cword then
        return vim.fn.expand("<cword>"), vim.fn.line(".") - 1
    end
end

function M.run(name, visual)
    local spec = conf.actions[name]
    if not spec then
        return
    end

    local text, row = input(spec, visual)
    if not text or text == "" then
        notify("no text selected", vim.log.levels.WARN)
        return
    end

    local prompt = spec.prefix .. text
    if spec.max_words then
        prompt = ("Answer in at most %d words.\n\n%s"):format(spec.max_words, prompt)
    end

    local buf = vim.api.nvim_get_current_buf()
    local mark = vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {})

    notify(name .. "…")
    post({
        model = conf.model,
        stream = false,
        options = conf.options,
        messages = {
            { role = "system", content = spec.system },
            { role = "user", content = prompt },
        },
    }, function(content)
        append_below(buf, mark, spec.header, content)
        notify(name .. " done")
    end)
end

function M.say(visual)
    local text = visual and select(1, input(nil, true)) or vim.fn.expand("<cword>")
    if not text or text == "" then
        notify("no word found", vim.log.levels.WARN)
        return
    end
    local cmd = vim.list_extend(vim.deepcopy(conf.say_command), { text })
    vim.system(cmd)
end

function M.set(params)
    conf = params

    for name, _ in pairs(conf.actions) do
        vim.api.nvim_create_user_command(
            "Llm" .. name:sub(1, 1):upper() .. name:sub(2),
            function(o) M.run(name, o.range > 0) end,
            { range = true, desc = "llm: " .. name }
        )
    end
    vim.api.nvim_create_user_command("LlmSay", function(o) M.say(o.range > 0) end,
        { range = true, desc = "llm: say" })

    for name, lhs in pairs(conf.keymaps) do
        local desc = "llm: " .. name
        if name == "say" then
            vim.keymap.set("n", lhs, function() M.say(false) end, { desc = desc })
            vim.keymap.set("x", lhs, function() M.say(true) end, { desc = desc })
        else
            vim.keymap.set("n", lhs, function() M.run(name, false) end, { desc = desc })
            vim.keymap.set("x", lhs, function() M.run(name, true) end, { desc = desc })
        end
    end
end

return M
