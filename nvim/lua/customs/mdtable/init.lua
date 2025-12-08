local M = {}
local curl = require("plenary.curl")
local config = require("customs.mdtable.config").config

local function get_visual_selection()
	local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))

	local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

	if #lines == 0 then
		return ""
	end

	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col, end_col)
	else
		lines[1] = string.sub(lines[1], start_col)
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	return table.concat(lines, "\n")
end

local function call_ollama(description, callback)
	local system_prompt = [[You are a markdown table generator. When given a description or request, generate ONLY a properly formatted markdown table.

Rules:
- Return ONLY the markdown table, no explanations or additional text
- Use proper markdown table syntax with | delimiters
- Include a header row with column names
- Include the separator row with --- alignment markers
- Ensure columns are aligned consistently
- If the request is vague, make reasonable assumptions about what data to include
- Keep the table concise but informative

Example output format:
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
| Data 4   | Data 5   | Data 6   |
]]

	local body = {
		model = config.model,
		messages = {
			{
				role = "system",
				content = system_prompt,
			},
			{
				role = "user",
				content = description,
			},
		},
		stream = false,
		options = config.options,
	}

	curl.post(config.endpoint, {
		body = vim.fn.json_encode(body),
		headers = {
			["Content-Type"] = "application/json",
		},
		callback = vim.schedule_wrap(function(response)
			if response.status ~= 200 then
				vim.notify("Error calling Ollama: " .. response.status, vim.log.levels.ERROR)
				return
			end

			local ok, result = pcall(vim.fn.json_decode, response.body)
			if not ok then
				vim.notify("Error parsing response", vim.log.levels.ERROR)
				return
			end

			local content = result.message and result.message.content or ""
			callback(content)
		end),
	})
end

local function append_below_selection(content)
	local _, end_row, _, _ = unpack(vim.fn.getpos("'>"))

	local lines_to_insert = {
		"",
		"### Generated Markdown Table:",
		"",
	}

	for line in content:gmatch("[^\r\n]+") do
		table.insert(lines_to_insert, line)
	end

	vim.api.nvim_buf_set_lines(0, end_row, end_row, false, lines_to_insert)

	vim.notify("Markdown table generated!", vim.log.levels.INFO)
end

function M.generate_table()
	local description = get_visual_selection()

	if description == "" then
		vim.notify("No text selected", vim.log.levels.WARN)
		return
	end

	vim.notify("Generating markdown table...", vim.log.levels.INFO)

	call_ollama(description, function(result)
		if result and result ~= "" then
			append_below_selection(result)
		else
			vim.notify("No table generated", vim.log.levels.WARN)
		end
	end)
end

function M.setup()
	vim.api.nvim_create_user_command("MdTable", function()
		M.generate_table()
	end, { range = true })
end

return M
