-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
	-- NOTE: Yes, you can install new plugins here!
	"mfussenegger/nvim-dap",
	-- NOTE: And you can specify dependencies as well
	dependencies = {
		-- Creates a beautiful debugger UI
		"rcarriga/nvim-dap-ui",

		-- Required dependency for nvim-dap-ui
		"nvim-neotest/nvim-nio",

		-- Installs the debug adapters for you
		"mason-org/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",

		-- Add your own debuggers here
		"leoluz/nvim-dap-go",
		-- Python
		"mfussenegger/nvim-dap-python",
		-- TS
		"mxsdev/nvim-dap-vscode-js",
	},
	keys = {
		-- Basic debugging keymaps, feel free to change to your liking!
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "[D]ebug Start/[C]ontinue",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "[D]ebug Step [I]nto",
		},
		{
			"<leader>do",
			function()
				require("dap").step_over()
			end,
			desc = "[D]ebug Step [O]ver",
		},
		{
			"<leader>dO",
			function()
				require("dap").step_out()
			end,
			desc = "[D]ebug Step [O]ut",
		},
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "[D]ebug Toggle [B]reakpoint",
		},
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "[D]ebug Set [B]reakpoint",
		},
		{
			"<leader>dx",
			function()
				require("dap").clear_breakpoints()
				vim.notify("DAP: cleared all breakpoints")
			end,
			desc = "[D]ebug Set [B]reakpoint",
		},
		{
			"<leader>dq",
			function()
				require("dap").terminate()
			end,
			desc = "[D]ebug [Q]uit / Terminate",
		},
		{
			"<leader>du",
			function()
				require("dapui").toggle()
			end,
			desc = "[D]ebug Toggle [U]I",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("mason-nvim-dap").setup({
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_installation = true,

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			handlers = {},

			-- You'll need to check that you have the required things installed
			-- online, please don't ask me how to install them :)
			ensure_installed = {
				-- Update this to ensure that you have the debuggers for the langs you want
				"delve",
				"js-debug-adapter",
			},
		})

		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup({
			-- Set icons to characters that are more likely to work in every terminal.
			--    Feel free to remove or use ones that you like more! :)
			--    Don't feel like these are good choices.
			icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
			controls = {
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
		})

		vim.fn.sign_define("DapBreakpoint", {
			text = "",
			texthl = "DiagnosticSignError",
			linehl = "",
			numhl = "",
		})

		vim.fn.sign_define("DapBreakpointRejected", {
			text = "", -- or "❌"
			texthl = "DiagnosticSignError",
			linehl = "",
			numhl = "",
		})

		vim.fn.sign_define("DapStopped", {
			text = "", -- or "→"
			texthl = "DiagnosticSignWarn",
			linehl = "Visual",
			numhl = "DiagnosticSignWarn",
		})

		dap.listeners.after.event_initialized["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		-- Install golang specific config
		require("dap-go").setup({
			delve = {
				-- On Windows delve must be run attached or it crashes.
				-- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
				detached = vim.fn.has("win32") == 0,
			},
		})

		-- Install python specific config
		require("dap-python").setup("python3")

		-- ============================================================
		-- Kotlin / JVM debugging (attach over JDWP)
		-- ------------------------------------------------------------
		-- Why THIS setup (and not jdtls + microsoft/java-debug):
		--   * jdtls cannot import this repo's Gradle 9 composite build
		--     (its bundled APT init.gradle illegally resolves the
		--     `annotationProcessor` configuration -> "Resolution ...
		--     without an exclusive lock"), and as a side effect of that
		--     failed import it scatters Eclipse .project/.classpath/
		--     .settings/bin artifacts through the source tree. See the
		--     git history / notes for the full investigation.
		--   * We instead use fwcd/kotlin-debug-adapter (Mason:
		--     `kotlin-debug-adapter`), a STANDALONE Kotlin DAP server.
		--     It needs no jdtls and writes no Eclipse files.
		--
		-- How it works:
		--   * The adapter is a plain stdio DAP server (a shell launcher
		--     that runs a bundled Kotlin/JDI app). nvim-dap talks DAP to
		--     it; it talks JDWP (via JDI) to the JVM.
		--   * We ATTACH only. In fwcd's adapter, attach() does NOT run a
		--     Gradle classpath resolution (only launch() does) -- it just
		--     connects to host/port over JDWP and uses `projectRoot` for
		--     source mapping. That's exactly why it works on a Gradle 9
		--     composite build where jdtls's importer chokes.
		--
		-- Usage:
		--   1. Set breakpoints (<leader>db).
		--   2. Press <leader>dk to open a modal and pick what to debug:
		--        - Debug TESTS for the current file's module
		--        - Debug RUN for the current file's module (needs the
		--          `application` plugin / a `run` task, e.g. a service's
		--          :production:local module)
		--        - Debug a CUSTOM gradle task (type task + args)
		--        - Attach to an already-running JVM on :5005
		--      The first three start `./gradlew <task> --debug-jvm` (JDWP
		--      on 5005, suspend=y), wait for the socket, then attach.
		--   3. Or start gradle yourself and use <leader>dc ->
		--      "Kotlin: attach to JVM (port 5005)".
		--
		-- NOTE: each domain here is its OWN Gradle build (its own gradlew),
		-- so run tasks resolve within the current file's build. A runnable
		-- example to try: open any file under digital-advisory/ and pick
		-- "Debug RUN" -> it launches :production:local:run (a mocked local
		-- HTTP server on :8999) under the debugger.
		--
		-- Alternative to watch: JetBrains' official kotlin-lsp now ships
		-- an experimental DAP (attach) that would remove the manual
		-- gradle step and reuse the IntelliJ-grade project model. It is
		-- NOT usable yet: breakpoints verify but never fire on Gradle
		-- JDWP attach. Tracking:
		--   https://github.com/Kotlin/kotlin-lsp/issues/198  (LSP-934)
		--   plugin front-end: AlexandrosAlexiou/kotlin.nvim
		-- Re-check when a kotlin-lsp release changelog mentions a DAP /
		-- breakpoint fix; see docs/kotlin-debugging.md in this config.
		-- ============================================================

		local kdbg = vim.fn.stdpath("data") .. "/mason/bin/kotlin-debug-adapter"

		-- Standalone stdio DAP server (no jdtls).
		dap.adapters.kotlin = {
			type = "executable",
			command = kdbg,
			-- The launcher speaks DAP on stdio; no extra args needed.
		}

		-- Find the Gradle project root (dir with settings/build/wrapper).
		local function kotlin_gradle_root(from)
			from = from or vim.fn.expand("%:p")
			return vim.fs.root(from ~= "" and from or 0, {
				"settings.gradle.kts",
				"settings.gradle",
				"gradlew",
				"build.gradle.kts",
				"build.gradle",
			}) or vim.fn.getcwd()
		end

		-- Static attach config for the <leader>dc picker. Use this when
		-- you've already started `./gradlew ... --debug-jvm` yourself.
		dap.configurations.kotlin = {
			{
				type = "kotlin",
				request = "attach",
				name = "Kotlin: attach to JVM (port 5005)",
				-- fwcd adapter attach options:
				hostName = "127.0.0.1",
				port = 5005,
				-- projectRoot is used only for source mapping (NOT a
				-- Gradle import), resolved lazily from the current buffer.
				projectRoot = function()
					return kotlin_gradle_root()
				end,
				timeout = 2000,
			},
		}

		-- Derive the Gradle module path (":app", ":a:b", or ":" root) for
		-- a file: nearest ancestor with a build script, in Gradle ":"-form.
		local function kotlin_module_for(file_path)
			local root = kotlin_gradle_root(file_path)
			local module_dir = vim.fs.root(file_path, { "build.gradle.kts", "build.gradle" })
			if not module_dir then
				return ":"
			end
			local root_norm = vim.fs.normalize(root)
			local mod_norm = vim.fs.normalize(module_dir)
			if mod_norm == root_norm then
				return ":"
			end
			local rel = mod_norm:sub(#root_norm + 2)
			if rel == "" then
				return ":"
			end
			return ":" .. rel:gsub("/", ":")
		end

		-- Start `./gradlew <task> --debug-jvm` (JDWP on 5005, suspend=y),
		-- wait for the socket, then attach the kotlin adapter. Mirrors the
		-- Go/Python one-key flow but for Kotlin over JDWP.
		--
		-- IMPORTANT: this must NOT block the UI. We poll for the JDWP port
		-- with an async libuv timer (NOT vim.wait, which busy-loops the main
		-- thread and freezes nvim/tmux). We also must NOT stream gradle's
		-- stdout through vim.notify line-by-line: multi-line messages trip
		-- Neovim's "Press ENTER to continue" hit-enter prompt, and if the UI
		-- is blocked that prompt can never be dismissed -> total freeze.
		-- Progress goes to :messages only on state changes.
		local function kotlin_launch_gradle_and_attach(gradle_args)
			local cwd = kotlin_gradle_root()
			local port = 5005

			local function port_open()
				return os.execute("lsof -iTCP:" .. port .. " -sTCP:LISTEN >/dev/null 2>&1") == 0
			end

			if port_open() then
				vim.notify(
					"Port " .. port .. " already in use. Run `./gradlew --stop` or use the attach config.",
					vim.log.levels.WARN
				)
			end

			local gradlew = cwd .. "/gradlew"
			local gradle_exe = (vim.fn.filereadable(gradlew) == 1) and "./gradlew" or "gradle"

			local cmd = { gradle_exe }
			vim.list_extend(cmd, gradle_args)
			vim.list_extend(cmd, { "--debug-jvm", "--console=plain" })

			-- Force test tasks to actually execute. Gradle caches test
			-- results, so a `test` task can report UP-TO-DATE and NEVER start
			-- a JVM -- which means `--debug-jvm` opens no JDWP port and the
			-- poll below waits forever. `--rerun-tasks` guarantees execution.
			-- (Not needed for `run`, which always launches a fresh JVM.)
			local has_test_task = false
			for _, a in ipairs(gradle_args) do
				if a:match("test$") or a:match("test%s") or a == "test" then
					has_test_task = true
					break
				end
			end
			if has_test_task then
				table.insert(cmd, "--rerun-tasks")
			end

			vim.notify("Kotlin debug: starting `" .. table.concat(cmd, " ") .. "` (waiting on :" .. port .. ")…")

			-- Capture build output for diagnostics, but do NOT notify per
			-- line (that floods the message area / triggers hit-enter).
			local output = {}
			local job = vim.fn.jobstart(cmd, {
				cwd = cwd,
				on_stdout = function(_, data)
					if data then
						vim.list_extend(output, data)
					end
				end,
				on_stderr = function(_, data)
					if data then
						vim.list_extend(output, data)
					end
				end,
				on_exit = function(_, code)
					-- If gradle exits non-zero before the port opened, surface it.
					if code ~= 0 and not port_open() then
						vim.schedule(function()
							vim.notify(
								"Kotlin debug: gradle exited (code " .. code .. ") before JDWP opened. "
									.. "Check `:messages` / the build output.",
								vim.log.levels.ERROR
							)
						end)
					end
				end,
			})
			if job <= 0 then
				vim.notify("Kotlin debug: failed to start gradlew in " .. cwd, vim.log.levels.ERROR)
				return
			end

			-- Async poll for the JDWP socket, then attach. 250ms interval,
			-- up to 120s. Never blocks the main thread.
			local timer = vim.uv.new_timer()
			local elapsed = 0
			local interval = 250
			local deadline = 120000
			timer:start(
				interval,
				interval,
				vim.schedule_wrap(function()
					elapsed = elapsed + interval
					if port_open() then
						timer:stop()
						timer:close()
						vim.notify("Kotlin debug: JDWP up, attaching…")
						require("dap").run({
							type = "kotlin",
							request = "attach",
							name = "Kotlin: attach (auto)",
							hostName = "127.0.0.1",
							port = port,
							projectRoot = cwd,
							timeout = 2000,
						})
					elseif elapsed >= deadline then
						timer:stop()
						timer:close()
						vim.notify(
							"Kotlin debug: JDWP port " .. port .. " never opened; build may have failed. "
								.. "Check `:messages`.",
							vim.log.levels.ERROR
						)
					elseif elapsed % 5000 == 0 then
						-- Heartbeat every 5s so a slow cold build (compile +
						-- test JVM startup can take ~30s) is visibly alive and
						-- not mistaken for a hang.
						vim.notify(
							"Kotlin debug: still building/waiting for :" .. port .. " (" .. (elapsed / 1000) .. "s)…"
						)
					end
				end)
			)
		end

		-- <leader>dk = [D]ebug [K]otlin: open a modal to pick what to debug.
		-- Each choice either launches `./gradlew <task> --debug-jvm` for the
		-- current file's module and attaches, or attaches to a JVM you
		-- already started. Modules that use the `application` plugin expose a
		-- `run` task; every module has a `test` task.
		vim.keymap.set("n", "<leader>dk", function()
			local file = vim.fn.expand("%:p")
			local module_path = kotlin_module_for(file)
			local mod_label = (module_path == ":" and "(root)" or module_path)
			local test_task = (module_path == ":" and "test" or module_path .. ":test")
			local run_task = (module_path == ":" and "run" or module_path .. ":run")

			local choices = {
				{
					label = "Debug TESTS for module " .. mod_label .. "  (" .. test_task .. " --debug-jvm)",
					action = function()
						kotlin_launch_gradle_and_attach({ test_task })
					end,
				},
				{
					label = "Debug RUN for module " .. mod_label .. "  (" .. run_task .. " --debug-jvm)",
					action = function()
						kotlin_launch_gradle_and_attach({ run_task })
					end,
				},
				{
					label = "Debug a CUSTOM gradle task…  (--debug-jvm)",
					action = function()
						vim.ui.input({ prompt = "Gradle task(s) + args (space-separated): " }, function(input)
							if not input or input == "" then
								return
							end
							-- Split on whitespace so you can pass e.g.
							-- ":production:local:run --args=--port 9000".
							local args = {}
							for tok in input:gmatch("%S+") do
								table.insert(args, tok)
							end
							kotlin_launch_gradle_and_attach(args)
						end)
					end,
				},
				{
					label = "Attach to an ALREADY-RUNNING JVM on :5005",
					action = function()
						require("dap").run({
							type = "kotlin",
							request = "attach",
							name = "Kotlin: attach to JVM (port 5005)",
							hostName = "127.0.0.1",
							port = 5005,
							projectRoot = kotlin_gradle_root(file),
							timeout = 2000,
						})
					end,
				},
			}

			vim.ui.select(choices, {
				prompt = "Kotlin debug:",
				format_item = function(item)
					return item.label
				end,
			}, function(choice)
				if choice then
					choice.action()
				end
			end)
		end, { desc = "[D]ebug [K]otlin (modal: test / run / custom / attach)" })
	end,
}
