-- HTTP client for .http files (JetBrains HTTP Client syntax).
-- https://github.com/rest-nvim/rest.nvim
--
-- Keymaps only exist in http buffers, under <leader>r.
-- Variables are read from a `.env` (or `<file>.env`) next to the .http file.
-- The `http` tree-sitter parser (syntax highlighting) is installed in init.lua.
--
-- The rockspec install is skipped (`build = false`): its tree-sitter-http rock
-- fails to build with lazy's luarocks, and nvim-treesitter already provides the
-- parser. The runtime dependencies are declared as normal plugins instead.
-- `xml2lua` and `mimetypes` are plain Lua libraries with their modules in the
-- repo root (no lua/ dir), so their folder is added to package.path on load.
local function add_repo_root_to_lua_path(plugin)
	package.path = plugin.dir .. "/?.lua;" .. package.path
end

return {
	"rest-nvim/rest.nvim",
	ft = "http",
	build = false,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/nvim-nio",
		"j-hui/fidget.nvim",
		{ "manoelcampos/xml2lua", tag = "v1.6-2", build = false, config = add_repo_root_to_lua_path },
		{ "lunarmodules/lua-mimetypes", tag = "v1.1.0", build = false, config = add_repo_root_to_lua_path },
	},
	init = function()
		---@type rest.Opts
		vim.g.rest_nvim = {}

		-- rest.nvim pretty-prints response bodies with `gq`, which needs a
		-- formatter for the body's filetype.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("rest-nvim-json-format", { clear = true }),
			pattern = "json",
			callback = function(ev)
				if vim.fn.executable("jq") == 1 and vim.bo[ev.buf].formatprg == "" then
					vim.bo[ev.buf].formatprg = "jq --indent 2"
				end
			end,
		})
	end,
	config = function()
		-- `# @prompt` variables are asked for through nio.ui.input, which nvim-nio
		-- builds around whatever vim.ui.input is when nio is first loaded. If that
		-- happens before dressing.nvim replaces vim.ui.input (VeryLazy), prompts
		-- fall back to the command line. Look vim.ui.input up on every call so the
		-- dressing input box at the cursor is used whenever it is available.
		--
		-- The input is opened on the next tick: `:Rest run` opens the result pane
		-- (split + wincmd p) right after the request pauses at the prompt, and that
		-- focus change would close a dressing box that was already open.
		local nio = require("nio")
		nio.ui.input = nio.wrap(function(opts, on_confirm)
			vim.schedule(function()
				vim.ui.input(opts, on_confirm)
			end)
		end, 2)
	end,
	keys = {
		{ "<leader>rr", "<cmd>Rest run<cr>", ft = "http", desc = "[R]un request under cursor" },
		{ "<leader>rl", "<cmd>Rest last<cr>", ft = "http", desc = "Run [l]ast request" },
		{ "<leader>ro", "<cmd>Rest open<cr>", ft = "http", desc = "[O]pen result pane" },
		{ "<leader>re", "<cmd>Rest env select<cr>", ft = "http", desc = "Select [e]nv file" },
		{ "<leader>rE", "<cmd>Rest env show<cr>", ft = "http", desc = "Show [E]nv file in use" },
		{ "<leader>rc", "<cmd>Rest curl yank<cr>", ft = "http", desc = "Yank request as [c]url" },
		{ "<leader>rL", "<cmd>Rest logs<cr>", ft = "http", desc = "Open [L]ogs" },
	},
}
