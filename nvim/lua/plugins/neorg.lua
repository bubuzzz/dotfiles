return {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    config = true,
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        { "nvim-neorg/tree-sitter-norg-meta", build = ":TSUpdate" },
    },
}
