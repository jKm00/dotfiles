return {
	{
		"mhersson/CopilotChat.nvim",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		branch = "main",
		cmd = "CopilotChat",
		opts = function()
			local user = vim.env.USER or "User"
			user = user:sub(1, 1):upper() .. user:sub(2)
			return {
				auto_follow_cursor = true,
				auto_insert_mode = false,
				insert_at_end = true,
				auto_fold = true, -- Automatically folds non-assistant messages
				model = "claude-sonnet-4",
				headers = {
					user = "  " .. user .. " ",
					assistant = "  Copilot ",
					tool = " ",
				},
				window = {
					width = 0.4,
					--title = "🤖 AI Assistant",
					-- layout = "float",
					-- width = 85, -- Fixed width in columns
					-- height = 30, -- Fixed height in rows
					-- border = "rounded", -- 'single', 'double', 'rounded', 'solid'
					-- zindex = 100, -- Ensure window stays on top
				},
				separator = "━━",
				-- GitHub Enterprise configuration
				api_endpoints = {
					api_url = "https://copilot-api.dnb.ghe.com/chat/completions",
					auth_url = "https://api.dnb.ghe.com/copilot_internal/v2/token",
					models_url = "https://copilot-api.dnb.ghe.com/models",
				},
				prompts = {
					ConventionalCommit = {
						prompt = [[
You are an expert software engineer and meticulous code reviewer.
 Your task is to generate a single Git commit message that **strictly follows the Conventional Commits v1.0.0 Specification**

### PRIMARY GOAL
Produce one short, complete commit message for the staged changes.

### OUTPUT FORMAT
- Return **only** the commit message text—no code fences, no commentary, no extra markup or explanations.
- The summary (first) line **must** be imperative, present tense, ≤72 characters, and **must not** end with a period.
- The commit message **must always** end with a blank line, and the summary and the body (if any) must be separated with blank line.
- Wrap all body lines at a maximum of 72 characters.
- If a body is included, format it as a clean, concise bullet list, each line starting with - .
- The summary line **must always** contain a scope, e.g. feat(nvim): Add new keybinding for lazygit.
- The first letter of the summary line after the type and scope **must** be capitalized.
- If the current branch name contains a jira ticket number on the format [a-zA-Z]{3,4}-[0-9]{3,} - for example IDD-1234
  then use the ticket as the scope in the summary
- If user has COMMIT_EDITMSG opened, generate diff replacement block for the commit message only.]],
						resources = {
							"gitdiff:staged",
							"buffer",
						},
					},
				},
			}
		end,
		keys = {
			{ "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
			{ "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
			{
				"<leader>ac",
				function()
					return require("CopilotChat").toggle()
				end,
				desc = "Toggle (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>ag",
				function()
					vim.cmd("CopilotChatConventionalCommit")
				end,
				desc = "Generate commit message",
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
		config = function(_, opts)
			local chat = require("CopilotChat")

			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-chat",
				callback = function()
					vim.opt_local.relativenumber = false
					vim.opt_local.number = false
				end,
			})

			chat.setup(opts)
		end,
	},
}
