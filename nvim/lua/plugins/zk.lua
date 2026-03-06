return {
  "zk-org/zk-nvim",
  config = function()
    require("zk").setup({
      picker = "fzf_lua",

      lsp = {
        config = {
          cmd = {
            "zk",
            "lsp",
          },
        },

        auto_attach = {
          enabled = true,
        },
      },
    })
  end
}
