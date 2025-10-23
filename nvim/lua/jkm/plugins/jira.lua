return {
	"kid-icarus/jira.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim", -- optional
		"folke/snacks.nvim", -- optional
	},
	opts = {
		jira_api = {
			domain = "dnb-asa.atlassian.net",
			username = "joakim.edvardsen@dnb.no",
			token = "",
		},
	},
}
