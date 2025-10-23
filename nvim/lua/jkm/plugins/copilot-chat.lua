return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		build = "make tiktoken",
		config = function()
			require("copilot-chat").setup({})
		end,
		keys = {
			{ "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
			{ "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
			{
				"<leader>aa",
				function()
					return require("CopilotChat").toggle()
				end,
				desc = "Toggle (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>ax",
				function()
					return require("CopilotChat").reset()
				end,
				desc = "Clear (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>aq",
				function()
					vim.ui.input({
						prompt = "Quick Chat: ",
					}, function(input)
						if input ~= "" then
							require("CopilotChat").ask(input)
						end
					end)
				end,
				desc = "Quick Chat (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>ap",
				function()
					require("CopilotChat").select_prompt()
				end,
				desc = "Prompt Actions (CopilotChat)",
				mode = { "n", "v" },
			},
		},
	},
}
