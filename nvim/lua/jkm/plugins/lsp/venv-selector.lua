return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-telescope/telescope.nvim", -- or another picker
	},
	opts = {
		name = ".venv", -- default name of your venv folder
		auto_refresh = true,
	},
	cmd = { "VenvSelect", "VenvSelectCached" },
	keys = {
		{ "<leader>vs", "<cmd>VenvSelect<cr>" },
		{ "<leader>vc", "<cmd>VenvSelectCached<cr>" },
	},
}
