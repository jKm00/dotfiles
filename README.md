# Dotfiles

Personal configuration for a terminal-first development setup.

The repo is the source of truth. Active config files in `$HOME` are symlinked back into this repo.

## Setup

| Config        | Purpose                                                       | Source               |
| ------------- | ------------------------------------------------------------- | -------------------- |
| Ghostty       | Terminal theme, wallpaper, opacity and shaders                | `.config/ghostty`    |
| tmux          | Multiplexer config, Oasis Twilight theme, spotify_player integration | `.config/tmux`       |
| zsh           | Shell config and aliases                                      | `.zshrc`             |
| Powerlevel10k | Prompt layout and Oasis Twilight color overrides              | `.p10k.zsh`          |
| Nvim          | Editor config, Oasis theme, opencode.nvim integration         | `.config/nvim`       |
| opencode      | TUI config, transparent Oasis Twilight theme, output-style plugin, AGENTS.md, slash commands | `.config/opencode`   |
| wallpapers    | Shared terminal wallpaper assets                              | `.config/wallpapers` |
| VS Code       | Settings, keybindings and extensions list                     | `vscode`             |

## Symlinks

Main symlinks:

```text
~/.config/nvim -> ~/dev/repos/personal/dotfiles/.config/nvim
~/.config/ghostty -> ~/dev/repos/personal/dotfiles/.config/ghostty
~/.config/wallpapers -> ~/dev/repos/personal/dotfiles/.config/wallpapers
~/.zshrc -> ~/dev/repos/personal/dotfiles/.zshrc
~/.p10k.zsh -> ~/dev/repos/personal/dotfiles/.p10k.zsh
```

Selective symlinks keep generated/runtime files out of git:

```text
~/.config/tmux/tmux.conf -> ~/dev/repos/personal/dotfiles/.config/tmux/tmux.conf
~/.config/tmux/hooks -> ~/dev/repos/personal/dotfiles/.config/tmux/hooks
~/.config/opencode/opencode.json -> ~/dev/repos/personal/dotfiles/.config/opencode/opencode.json
~/.config/opencode/tui.json -> ~/dev/repos/personal/dotfiles/.config/opencode/tui.json
~/.config/opencode/AGENTS.md -> ~/dev/repos/personal/dotfiles/.config/opencode/AGENTS.md
~/.config/opencode/themes -> ~/dev/repos/personal/dotfiles/.config/opencode/themes
~/.config/opencode/plugin -> ~/dev/repos/personal/dotfiles/.config/opencode/plugin
~/.config/opencode/command/*.md -> ~/dev/repos/personal/dotfiles/.config/opencode/command/*.md
```

Local-only paths:

```text
~/.config/tmux/plugins
~/.config/opencode/node_modules
~/.config/opencode/opencode.local.json
~/.config/opencode/agent/*.md (except those tracked in the repo)
~/.local/share/nvim/lazy
```

## Install

Base tools:

```sh
brew install ghostty tmux neovim lazygit
```

Shell and prompt:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install powerlevel10k zsh-autosuggestions zsh-syntax-highlighting
```

tmux plugin manager:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

After opening tmux, install plugins with `prefix + I`.

## Spotify integration (tmux)

The tmux status bar shows the currently playing Spotify track, and `prefix + s`
opens a control menu (play/pause, next, previous, shuffle, repeat, like, open TUI).
Both are driven by [`spotify_player`](https://github.com/aome510/spotify-player)
via its CLI — there is no tmux plugin involved.

### Prerequisites

```sh
brew install spotify_player jq
```

- `spotify_player` — the player and CLI that reports playback state.
  Requires **0.24.1 or newer**; older versions relied on a shared Spotify
  client ID that has since been revoked (symptoms: the TUI does nothing and the
  CLI returns persistent `429 Too Many Requests`).
- `jq` — used by the status script to parse the playback JSON.

### First-time authentication

Authenticate once with your personal Spotify account (no Premium required for the
status bar; playback control needs an active Spotify device):

```sh
spotify_player authenticate
```

This caches credentials under `~/.cache/spotify-player/`. Config lives in
`~/.config/spotify-player/app.toml` (managed by `spotify_player`, not this repo).

### How it is wired

- `.config/tmux/hooks/spotify-now-playing.sh` runs `spotify_player get key playback`,
  formats it as `▶ Track — Artist` (`▌▌` when paused), truncates long titles, and
  caches the result for ~6s so frequent status redraws do not hit the Spotify API.
  It prints nothing when idle, rate-limited, or if `spotify_player`/`jq` are missing.
- `tmux.conf` sets `status-right` to call that script, ahead of the Oasis modules.
  It is set **directly** (not via `run-shell`) so tmux stores the `#(...)` and
  `#{E:...}` placeholders literally and evaluates them at render time.
  `status-right-length` is bumped to `200` so the combined string is not truncated.
- `prefix + s` is bound to a `display-menu` whose entries shell out to
  `spotify_player playback ...` / `spotify_player like`.

The `hooks` directory is already symlinked (see [Symlinks](#symlinks)), so the
script is picked up automatically with no extra linking.

## Machine-specific config

`.zshrc` is shared across machines (work and personal). Anything that only applies
to a single machine — work certs, cloud profiles, machine-local overrides — lives in
`~/.zshrc.local`, which is git-ignored and never committed.

The shared `.zshrc` sources it at the end if it exists:

```sh
# Machine-specific config (work vs personal). Not tracked in the repo.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

Because it is sourced last, `~/.zshrc.local` can also override shared defaults
(e.g. redefine an alias). Example work `~/.zshrc.local`:

```sh
export NODE_EXTRA_CA_CERTS="$HOME/.certs/corp-root.pem"
export AWS_PROFILE=work
. "$HOME/.local/bin/env"
alias jarvis="raicode"
```

On a machine with no `~/.zshrc.local`, the shared defaults apply unchanged.

### opencode machine-specific config

The shared `opencode.json` in this repo is symlinked to
`~/.config/opencode/opencode.json` and contains all the settings opencode
loads by default. Machine-specific overrides can be defined in
`~/.config/opencode/opencode.local.json` (git-ignored), which opencode
automatically merges over the base config. The local config is optional; if it
does not exist, the shared defaults apply unchanged.

The things that are machine-specific:

- **MCP auth tokens** — stored by opencode in
  `~/.local/share/opencode/mcp-auth.json`, never in config and never in this
  repo. You authenticate once per machine.
- **Custom agents** — markdown files under `~/.config/opencode/agent/`. Only
  individual files in `~/.config/opencode/` are symlinked from this repo, so
  any agent file you add to `~/.config/opencode/agent/` that is not tracked
  stays local to the machine (see the `git-cheap` agent below).
- **Local config overrides** — `~/.config/opencode/opencode.local.json`
  (git-ignored) for machine-only settings like work MCP servers or alternate
  model selections.

MCP servers live in the tracked `opencode.json`. The Atlassian server is
enabled for every machine:

```json
"mcp": {
  "atlassian": {
    "type": "remote",
    "url": "https://mcp.atlassian.com/v1/sse",
    "oauth": {}
  }
}
```

On a new machine, authenticate the server once:

```sh
opencode mcp auth atlassian
```

Until you authenticate, the server is configured but its tools are unusable on
that machine. Check status with `opencode mcp list` and the full merged config
with `opencode debug config`.

### opencode command models (`git-cheap` agent)

The tracked `/commit`, `/pr`, and `/docs` slash commands
(`.config/opencode/command/*.md`) run cheaper work that does not need the
default model, so they reference `agent: git-cheap`. Model names are provider-
and machine-specific, so the `git-cheap` agent is not tracked in this repo — it
is defined per machine as a markdown agent file at
`~/.config/opencode/agent/git-cheap.md`, which opencode loads automatically from
the global agent directory.

To set this up on a new machine, create that file pointing at whatever cheap
model the machine has:

```md
---
description: Cheap primary agent for routine git tasks like committing and opening PRs.
mode: primary
model: anthropic/claude-3-5-sonnet-latest
---

You are a focused git assistant. Perform the requested git task carefully and
concisely. Inspect the working tree before staging, never commit secrets, and
follow the repository's existing commit and PR conventions.
```

If a machine does not define `git-cheap`, the `/commit`, `/pr`, and `/docs` commands will
fail to resolve the agent — create the file (any model works) before using them.

## opencode

`jarvis` starts opencode with a local server so Nvim can connect to the existing tmux pane:

```sh
alias jarvis="opencode --port"
```

## Validation

Useful checks after changing config:

```sh
zsh -n ~/.zshrc
zsh -n ~/.p10k.zsh
ghostty +validate-config --config-file ~/.config/ghostty/config
nvim --headless "+quit"
opencode debug startup
tmux source-file ~/.config/tmux/tmux.conf
```

## Notes

- The theme direction is Oasis Twilight across Ghostty, tmux, Nvim, Powerlevel10k and opencode.
- Do not commit plugin/runtime directories such as tmux plugins, Lazy.nvim checkouts or opencode `node_modules`.
- Check opencode config for credentials before committing changes.
