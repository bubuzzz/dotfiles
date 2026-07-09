local M = {}

M.config = {
	endpoint = "http://localhost:11434/api/chat",
	model = "llama3.1:8b-instruct-q4_K_M",
	options = {
		temperature = 0.2,
		num_ctx = 8192,
	},
}

return M
