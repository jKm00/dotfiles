-- neotest.lua
--
-- Run tests from inside the editor: put the cursor on a test and press a
-- keybind to run just that test, the whole file, or everything. Results show
-- up as inline signs next to each test plus an output/summary panel.
--
-- For this Kotlin + Gradle project we use the community `neotest-gradle`
-- adapter, which shells out to `./gradlew test --tests <pattern>` and parses
-- the JUnit XML reports Gradle writes to build/test-results/.
--
-- Keymaps (all under <leader>t = [T]est):
--   <leader>tr  run nearest test (under cursor)
--   <leader>tf  run all tests in the current file
--   <leader>tA  run the whole suite
--   <leader>tl  re-run the last test run
--   <leader>ts  toggle the summary panel (tree of tests)
--   <leader>to  show output for the nearest test
--   <leader>tO  toggle the output panel
--   <leader>tw  toggle watch mode for the current file

return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- Kotlin/Java Gradle adapter.
		"weilbith/neotest-gradle",
	},
	keys = {
		{
			"<leader>tr",
			function()
				require("neotest").run.run()
			end,
			desc = "[T]est [R]un nearest",
		},
		{
			"<leader>tf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "[T]est run [F]ile",
		},
		{
			"<leader>tA",
			function()
				require("neotest").run.run(vim.fn.getcwd())
			end,
			desc = "[T]est run [A]ll",
		},
		{
			"<leader>tl",
			function()
				require("neotest").run.run_last()
			end,
			desc = "[T]est run [L]ast",
		},
		{
			"<leader>ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "[T]est [S]ummary panel",
		},
		{
			"<leader>to",
			function()
				require("neotest").output.open({ enter = true, auto_close = true })
			end,
			desc = "[T]est [O]utput (nearest)",
		},
		{
			"<leader>tO",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "[T]est [O]utput panel",
		},
		{
			"<leader>tw",
			function()
				require("neotest").watch.toggle(vim.fn.expand("%"))
			end,
			desc = "[T]est [W]atch file",
		},
	},
	config = function()
		local lib = require("neotest.lib")
		local find_project_directory = require("neotest-gradle.hooks.find_project_directory")
		local original_build_spec = require("neotest-gradle.hooks.build_run_specification")

		-- The upstream neotest-gradle adapter discovers the JUnit results
		-- directory by running `gradle properties --property testResultsDir`
		-- and parsing the output. On Gradle 9.x that property prints as
		-- "null", so the adapter builds the path "null/test" and crashes when
		-- it tries to scan that (non-existent) directory for XML reports.
		--
		-- We wrap the original build_spec and overwrite the results directory
		-- with the conventional location Gradle actually writes to:
		--   <subproject>/build/test-results/test
		-- (`find_project_directory` already resolves to the nearest module
		-- containing a build.gradle[.kts], e.g. the `app/` subproject.)
		local patched_build_spec = function(arguments)
			local spec = original_build_spec(arguments)
			if spec == nil then
				return spec
			end

			local position = arguments.tree:data()
			local project_directory = find_project_directory(position.path)
			local sep = lib.files.sep
			local results_dir = table.concat(
				{ project_directory, "build", "test-results", "test" },
				sep
			)

			spec.context = spec.context or {}
			-- NOTE: the upstream key is misspelled "test_resuls_directory".
			-- collect_results.lua reads that exact key, so we must match it.
			spec.context.test_resuls_directory = results_dir
			return spec
		end

		local gradle_adapter = require("neotest-gradle")
		gradle_adapter.build_spec = patched_build_spec

		-- Reject generated/output copies of test files. `filter_dir` (below)
		-- only applies when neotest RECURSES directories during discovery; it
		-- does NOT apply when a file is opened directly in a buffer (neotest
		-- auto-attaches to any open buffer whose path passes `is_test_file`).
		--
		-- We no longer run jdtls at all (it couldn't import this Gradle 9
		-- composite build and was scattering Eclipse .project/.classpath/bin
		-- artifacts), so `bin/` copies of test sources shouldn't appear. This
		-- filter stays as a cheap safety net: it also rejects `build/` output,
		-- and guards against any tool that mirrors sources into bin/.
		local original_is_test_file = gradle_adapter.is_test_file
		gradle_adapter.is_test_file = function(file_path)
			local norm = vim.fs.normalize(file_path or "")
			if norm:match("/bin/") or norm:match("/build/") then
				return false
			end
			return original_is_test_file(file_path)
		end

		require("neotest").setup({
			adapters = {
				gradle_adapter,
			},
			-- Inline pass/fail marks next to each test.
			status = { virtual_text = true },
			output = { open_on_run = false },
			-- Don't scan generated/output directories for tests. Skipping
			-- bin/ (legacy Eclipse output), build/, .gradle/ and .kotlin/
			-- keeps discovery fast and avoids ever finding a mirrored copy of
			-- a test source outside of src/.
			discovery = {
				filter_dir = function(name, _rel_path, _root)
					return name ~= "bin"
						and name ~= "build"
						and name ~= ".gradle"
						and name ~= ".kotlin"
				end,
			},
		})
	end,
}
