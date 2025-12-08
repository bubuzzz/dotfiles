
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup {
      ensure_installed = { "c_sharp", "lua", "json", "yaml", "svelte", "typescript", "javascript", "css", "html" },
      highlight = { enable = true },
    }
  end,
}
