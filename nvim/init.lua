vim.pack.add({
  "https://github.com/bubuzzz/homage-black.git",
  "https://github.com/rebelot/kanagawa.nvim",

  "https://github.com/nvim-mini/mini.pairs",
  "https://github.com/nvim-mini/mini.pick",
  "https://github.com/nvim-mini/mini.icons",
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  "https://github.com/luochen1990/rainbow",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/supermaven-inc/supermaven-nvim",
})

-- Space and indentation
vim.opt.tabstop = 4  
vim.opt.shiftwidth = 4  
vim.opt.softtabstop = 4 
vim.opt.expandtab = true

vim.o.ignorecase = true
vim.o.smartcase = true

-- Misc
vim.opt.clipboard = "unnamedplus"
vim.opt.confirm = true
vim.opt.number = true
vim.g.rainbow_active = 1 -- from luochen1990/rainbow"

vim.opt.autochdir = false
vim.opt.relativenumber = true

--------------------------------------------------- 
------------------ Configuration ------------------ 
--------------------------------------------------- 
local shortcuts = {
    {"n", "<leader>fb", ":ls<CR>:b ", {desc = "List buffers, pick by number"}},
    {"n", "<leader>ff", function() MiniPick.builtin.files() end, {desc = "Find files (MiniPick)"}},
    {"n", "<leader>d", vim.diagnostic.open_float, {desc = "Open floating diagnostic message"}},
    {"n", "<leader>co", ":copen<CR>", {desc = "Open quickfix list"}},
    {"n", "<leader>cc", ":cclose<CR>", {desc = "Close quickfix list"}},
    {"n", "<leader>ee", ":Ex<CR>", {desc = "Open the current directory buffer"}},
    {"n", "<leader>mr", ":RenderMarkdown buf_toggle<CR>", {desc = "Toggle markdown rendering (this buffer)"}},
    {"n", "<leader>mm", 
        function()
            if _G.is_maximized then
                vim.cmd("wincmd =")
                _G.is_maximized = false
            else
                vim.cmd("wincmd |")
                vim.cmd("wincmd _")
                _G.is_maximized = true
            end
        end, 
        {desc = "Toggle maximize current pane"}
    }
}
local themes = {"kanagawa-dragon", "homage-black"}
local current_theme = themes[1]
local switch_theme_hour = 18
if os.date("*t").hour >= switch_theme_hour then
    current_theme = themes[2]
end

local treesitter_pattern = { "elixir", "eelixir", "heex", "python", "odin" }
local copilot_keymaps = {
    accept_suggestion = "<C-l>",  -- <Tab> is taken by native completion (config_lsp)
    clear_suggestion  = "<C-]>",
    accept_word       = "<C-j>",
}
 
local llm_conf = {
    endpoint = "http://localhost:11434/api/chat",
    model = "qwen2.5:7b",
    options = { temperature = 0.2, num_ctx = 8192 },
    say_command = { "espeak" },
    keymaps = {
        enhance = "<leader>le",
        summary = "<leader>ls",
        explain = "<leader>lx",
        say     = "<leader>lp",
    },
    actions = {
        enhance = {
            header = "=== Enhanced ===",
            system = "You are a careful editing assistant. Improve clarity, grammar, and flow while preserving meaning and formatting. Keep code blocks intact.",
            prefix = "Improve the following text:\n\n",
        },
        summary = {
            header = "=== Summary ===",
            system = "You are a world-class summarizer.",
            prefix = "Summarize the following text into clear, concise bullet points. Use '-' bullets, no intro line:\n\n",
            max_words = 120,
        },
        explain = {
            header = "=== Explain ===",
            system = "You are a world-class English teacher.",
            prefix = "Explain the following words into a clear, simple English sentence to a 5 years old little girl who does not know English very well:\n\n",
            cword = true,
            max_words = 120,
        },
    },
}

local servers_conf = {
    {"basedpyright", {
        settings = {
            basedpyright = {
                analysis = {
                    typeCheckingMode = "basic"
                },
            },
        },
    }},   
    {"ols", {}}, 
    {"elixirls", {}}
}

require("config_statusline").set()
require("config_shortcut").set(shortcuts)
require("config_theme").set(current_theme)
require("config_lsp").set(servers_conf)
require("config_plugin").set({
    treesitter_pattern = treesitter_pattern 
})
require("config_copilot").set({
    keymaps = copilot_keymaps
})
require("config_customs").set(llm_conf)
