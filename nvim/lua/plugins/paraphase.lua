return {
  { "nvim-lua/plenary.nvim" },
  {
    dir = vim.fn.stdpath("config") .. "/lua/customs/paraphase",
    name = "enh-custom",
    config = function()
      require("customs.paraphase").setup()
    end,
  }
}
