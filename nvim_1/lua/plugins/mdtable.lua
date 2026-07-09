return {
	{ "nvim-lua/plenary.nvim" },
	{
		dir = vim.fn.stdpath("config") .. "/lua/customs/mdtable",
		name = "mdtable-custom",
		config = function()
			require("customs.mdtable").setup()
		end,
	},
}
