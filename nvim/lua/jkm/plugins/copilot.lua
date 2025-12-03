return {
	"github/copilot.vim",
	config = function()
		vim.g.copilot_enterprise_uri = "https://dnb.ghe.com" -- replace with your actual enterprise URI
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "solarized",
			-- group = ...,
			callback = function()
				vim.api.nvim_set_hl(0, "CopilotSuggestion", {
					fg = "#555555",
					ctermfg = 8,
					force = true,
				})
			end,
		})

		vim.keymap.set("i", "<C-f>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
		})
		vim.g.copilot_no_tab_map = true
	end,
}
