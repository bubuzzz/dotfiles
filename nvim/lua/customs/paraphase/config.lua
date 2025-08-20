
return {
  endpoint = "http://localhost:11434/api/chat",
  model = "llama3.1:8b-instruct-q4_K_M",
  system_prompt = "You are a concise, careful writing assistant. Improve clarity and grammar; preserve meaning and formatting. Keep code blocks intact.",
  options = { temperature = 0.2, num_ctx = 8192 }, -- bump ctx if your paragraphs get long
}
