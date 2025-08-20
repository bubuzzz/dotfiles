local M = {
  endpoint = "http://localhost:11434/api/chat",
  model = "llama3.1:8b-instruct-q4_K_M",
  options = { temperature = 0.2, num_ctx = 8192 },

  enhance_system_prompt = "You are a careful editing assistant. Improve clarity, grammar, and flow while preserving meaning and formatting. Keep code blocks intact.",
  enhance_user_prefix   = "Improve the following text:\n\n",

  summary_system_prompt = "You are a world-class summarizer.",
  summary_user_prefix   = "Summarize the following text into clear, concise bullet points. Use '*' bullets, no intro line:\n\n",
  summary_max_words     = 120,
}

function M.setup(opts)
  for k, v in pairs(opts or {}) do M[k] = v end
end

return M
