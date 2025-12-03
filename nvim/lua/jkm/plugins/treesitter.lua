return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		-- configure treesitter
		treesitter.setup({ -- enable syntax highlighting
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			-- enable indentation
			indent = { enable = true },
			-- ensure these language parsers are installed
			ensure_installed = {
				"bash",
				"bicep",
				"c",
				"css",
				"dockerfile",
				"gitignore",
				"graphql",
				"html",
				"json",
				"javascript",
				"typescript",
				"tsx",
				"lua",
				"markdown",
				"markdown_inline",
				"prisma",
				"python",
				"query",
				"svelte",
				"vim",
				"vimdoc",
				"yaml",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})

		-- use bash parser for zsh files
		vim.treesitter.language.register("bash", "zsh")

		-- Register filetype and parse
		vim.filetype.add({
			extension = {
				bicep = "bicep",
			},
		})
	end,
}
