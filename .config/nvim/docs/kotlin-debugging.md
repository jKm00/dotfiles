# Kotlin / JVM debugging in Neovim

This documents how Kotlin breakpoint debugging is wired in this config, why it's
done this way, and the alternative to watch for a cleaner future setup.

Config lives in `lua/kickstart/plugins/debug.lua` (the "Kotlin / JVM debugging"
section). Test *running* (not debugging) is separate — see
`lua/custom/plugins/neotest.lua`.

## TL;DR

- Active setup: **fwcd/kotlin-debug-adapter** (Mason: `kotlin-debug-adapter`) in
  **attach** mode over JDWP. You start the JVM with `--debug-jvm`; nvim attaches.
- No jdtls, no Eclipse artifacts in the repo.
- Keymap `<leader>dk` opens a **modal** (`vim.ui.select`) for the current
  file's module:
  - **Debug TESTS** — `:<module>:test --debug-jvm`
  - **Debug RUN** — `:<module>:run --debug-jvm` (needs the `application`
    plugin / a `run` task; e.g. a service's `:production:local` module)
  - **Debug a CUSTOM gradle task** — type task + args, e.g.
    `:production:local:run --args=--port 9000`
  - **Attach to an already-running JVM on :5005**
- Or start gradle yourself and use `<leader>dc` → "Kotlin: attach to JVM
  (port 5005)".

### Debugging a running service (not just tests)

Every domain here is its **own** Gradle build (own `gradlew`), and the services
are http4k/Jetty apps with the `application` plugin — so `run` tasks work. The
simplest place to try RUN debugging is `digital-advisory`'s local dev server
(mocked deps, no AWS creds, no args, port 8999):

```sh
cd frontline-apis/savings-and-investments/digital-advisory
./gradlew :production:local:run --debug-jvm
```

Entry point: `LocalApp.kt` → `fun main` (`no.dnb.frontline.digitaladvisory.local.LocalAppKt`).
In practice: open any file under `digital-advisory/`, `<leader>dk` → "Debug RUN".

Other runnable `:production:local` servers: `ips`, `securities-financing`,
`portfolio-insights` (the last needs `--env sit|uat` and hits real AWS SSM).

## Why not the "normal" nvim Java/Kotlin debug path (jdtls + microsoft/java-debug)

microsoft/java-debug is an Eclipse JDT plugin with **no standalone launcher** —
it only runs hosted by jdtls (confirmed by the nvim-dap Java wiki and the
java-debug README). On this repo (`pm-server-side`, a large **Gradle 9.x
composite build**), jdtls's import fails:

```
Resolution of the configuration ':si-api:annotationProcessor' was attempted
without an exclusive lock. This is unsafe and not allowed.
  at GradleAnnotationProcessorPatchPlugin ... init.gradle:88
```

jdtls injects its own `init.gradle` (the APT patch) that eagerly resolves
annotation-processor configs, which Gradle 9 forbids. Two consequences:

1. **No project model** → breakpoints never bind → attach connects then
   immediately disconnects → the debug UI never opens.
2. As a fallback, jdtls runs the Eclipse builder and scatters
   `.project` / `.classpath` / `.settings/` / `bin/` (hundreds of files)
   through the source tree. This repo's `.gitignore` only covers IntelliJ
   artifacts, so these show up as untracked noise for everyone.

There is no jdtls setting that fixes this on Gradle 9, so jdtls was removed
entirely for Kotlin (kept for Go/Python/JS via their own adapters).

## Why fwcd/kotlin-debug-adapter in ATTACH mode works here

- It's a **standalone** Kotlin DAP server (stdio). No jdtls, no Eclipse files.
- Crucially, in fwcd's adapter **`attach()` does not run Gradle classpath
  resolution** — only `launch()` does. Attach just connects to host/port over
  JDWP (JDI) and uses `projectRoot` for source mapping. So the Gradle-9 import
  problem is bypassed.

### Verified working

Smoke-tested against this repo's Gradle 9.5.1 composite build:

```sh
./gradlew :si-kotlinx-serialization:test --debug-jvm
```

Attaching the fwcd adapter and setting a breakpoint on
`ZonedDateTimeSerializer.deserialize` (`ZonedDateTimeSerializer.kt:28`) produced
a real `stopped` (reason: breakpoint) event — the JVM halted inside the test
run. **Zero** Eclipse artifacts were generated (git tree stayed clean).

RUN (non-test) debugging was also verified: `digital-advisory`'s
`./gradlew :production:local:run --debug-jvm` with a breakpoint at
`LocalApp.kt:45` in `fun main` fired on startup. Also zero artifacts.

### Caveats / risks

- The adapter is effectively **unmaintained** (last release 0.4.4, Oct 2023;
  built against Kotlin 1.9.10 / Gradle 8.3). It runs fine on JDK 25, but newer
  Kotlin metadata / coroutine stepping / source mapping on a big composite build
  is not guaranteed. If a breakpoint doesn't map or a frame looks wrong, that's
  the likely cause.
- Only **attach** is wired here on purpose (launch would hit the Gradle
  resolution path and is fragile).
- **Test tasks must be forced to re-run.** Gradle caches test results, so a
  `test` task often reports `UP-TO-DATE` and never starts a JVM — meaning
  `--debug-jvm` opens no JDWP port and the attach poll waits forever (looks like
  a hang after the "starting…" notice). The launch helper appends
  `--rerun-tasks` whenever the task list contains a `test` task. `run` doesn't
  need it (always launches a fresh JVM). Cold runs still take ~30s (compile +
  test JVM startup); a heartbeat notice every 5s shows it's alive.
- The launch-and-attach helper polls for the JDWP port with an **async libuv
  timer** (`vim.uv`), never `vim.wait`. Blocking with `vim.wait` busy-loops the
  main thread and freezes the whole nvim/tmux pane; streaming gradle stdout
  through `vim.notify` line-by-line trips the "Press ENTER to continue"
  hit-enter prompt, which then can't be dismissed (total freeze). If you
  re-touch this helper, keep it async and keep build output out of `vim.notify`
  (it's collected silently; check `:messages` for the state-change notices).
- **`source.name` must be set on `setBreakpoints`.** The adapter's
  `DAPConverter.toInternalSource` (DAPConverter.kt:45) requires a non-null
  `Source.name` and throws `NullPointerException: getName(...) must not be null`
  if it's missing, which fails the whole `setBreakpoints` request. nvim-dap
  populates `source.name` by default, so this is a non-issue in normal use — but
  if breakpoints silently stop binding, check the adapter's console output for
  that NPE first.

## The alternative to watch: JetBrains kotlin-lsp DAP

We already use JetBrains' official **kotlin-lsp** for code intelligence
(`init.lua`, `kotlin_lsp`). It now ships an **experimental attach-mode DAP** that
would be the ideal setup: IntelliJ-grade Gradle 9 / composite import, no jdtls,
no manual gradle step, and reuse of the same server we run for LSP.

**It does not work yet.** On a Gradle `--debug-jvm` attach, `setBreakpoints`
returns `verified: true` but the JVM never halts — no `stopped` event is ever
emitted. Reproduced from both VS Code and Neovim, so it's server-side.

- Issue: <https://github.com/Kotlin/kotlin-lsp/issues/198> (internal: **LSP-934**)
- Maintainer (`fedochet`, May 4 2026): *"it is currently being fixed, and we
  hope to deliver the fix in the next release."*
- Status as of last check (kotlin-lsp **v262.9593.0**, Jul 27 2026): issue still
  **open**; the three releases after the promise (Jun 9, Jun 19, Jul 27) make
  **no mention of a DAP / breakpoint fix** in their changelogs. No committed date.
- nvim front-end (ready and waiting on the fix):
  <https://github.com/AlexandrosAlexiou/kotlin.nvim> (`:KotlinDebug [port]`).

### How to re-check whether it's fixed

1. Update kotlin-lsp: `:MasonUpdate` then `:MasonInstall kotlin-lsp` (or check
   the release notes for a version > v262.9593.0 mentioning DAP).
2. Reproduce issue #198 directly (smallest possible test):
   ```sh
   ./gradlew :si-common:si-kotlinx-serialization:test --debug-jvm
   ```
   Set a breakpoint in `ZonedDateTimeSerializer.deserialize` (or any test),
   attach, and see whether it actually stops.
3. Or just watch issue #198 for a close + a confirming comment.

If/when it works: switch to `kotlin.nvim` (or drive `start_debug_server` +
nvim-dap attach directly), and this whole fwcd section can be retired.

## Quick command reference

| Action | How |
| --- | --- |
| Run Kotlin tests (no debug) | neotest: `<leader>tr` / `<leader>tf` / `<leader>tA` |
| Debug (modal: test / run / custom / attach) | `<leader>dk` |
| Attach to a JVM you started | `<leader>dc` → "Kotlin: attach to JVM (port 5005)" |
| Start JVM manually (tests) | `./gradlew :<module>:test --debug-jvm` |
| Start JVM manually (service) | `./gradlew :production:local:run --debug-jvm` |
| Toggle breakpoint | `<leader>db` |
| Toggle debug UI | `<leader>du` |
| Terminate session | `<leader>dq` |

`--debug-jvm` listens on port **5005** and suspends the JVM until you attach.
