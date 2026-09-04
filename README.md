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
| AeroSpace     | Tiling window manager, keybinds, SketchyBar workspace hook    | `.aerospace.toml`    |
| SketchyBar    | Status bar, Oasis Twilight theme, AeroSpace workspace + app icons | `.config/sketchybar` |
| wallpapers    | Shared terminal wallpaper assets                              | `.config/wallpapers` |
| VS Code       | Settings, keybindings and extensions list                     | `vscode`             |

## Symlinks

Main symlinks:

```text
~/.config/nvim -> ~/dev/repos/personal/dotfiles/.config/nvim
~/.config/ghostty -> ~/dev/repos/personal/dotfiles/.config/ghostty
~/.config/sketchybar -> ~/dev/repos/personal/dotfiles/.config/sketchybar
~/.config/wallpapers -> ~/dev/repos/personal/dotfiles/.config/wallpapers
~/.zshrc -> ~/dev/repos/personal/dotfiles/.zshrc
~/.p10k.zsh -> ~/dev/repos/personal/dotfiles/.p10k.zsh
~/.aerospace.toml -> ~/dev/repos/personal/dotfiles/.aerospace.toml
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
~/Library/Fonts/sketchybar-app-font.ttf (installed, not tracked; see SketchyBar prerequisites)
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

Window manager and status bar:

```sh
brew install --cask nikitabobko/tap/aerospace
brew tap FelixKratz/formulae && brew install sketchybar
brew install --cask font-hack-nerd-font
brew install jq
```

See [AeroSpace + SketchyBar](#aerospace--sketchybar) for the app-icon font and
first-run steps.

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

## AeroSpace + SketchyBar

[AeroSpace](https://github.com/nikitabobko/AeroSpace) is the tiling window
manager; [SketchyBar](https://github.com/FelixKratz/SketchyBar) is the status
bar that replaces the native macOS menu bar. They are wired together: the bar
shows one chip per AeroSpace workspace, each rendering the **app icons the
workspace contains**, with the focused workspace highlighted in Oasis coral.
The right side has clock, battery and volume.

### Prerequisites

Install the window manager and bar (also listed under [Install](#install)):

```sh
brew install --cask nikitabobko/tap/aerospace
brew tap FelixKratz/formulae && brew install sketchybar
brew install --cask font-hack-nerd-font
brew install jq
```

- `aerospace` — tiling WM. Config is `.aerospace.toml` (symlinked to `~`).
- `sketchybar` — the bar. Config is `.config/sketchybar` (symlinked).
- `font-hack-nerd-font` — glyphs for the workspace IDs, clock/battery/volume
  icons.
- `jq` — used by the reload/validation checks (already installed for Spotify).

The per-workspace **app icons** need the
[`sketchybar-app-font`](https://github.com/kvndrsslr/sketchybar-app-font). The
font `.ttf` is installed to `~/Library/Fonts` (not tracked in the repo); the
matching `icon_map.sh` (app name → glyph mapping) **is** vendored in
`.config/sketchybar/plugins/icon_map.sh` so the config works out of the box.
Keep the two in sync — install the font from the same release the mapping came
from:

```sh
REL="v2.0.83"   # keep in sync with plugins/icon_map.sh
BASE="https://github.com/kvndrsslr/sketchybar-app-font/releases/download/$REL"
curl -fsSL "$BASE/sketchybar-app-font.ttf" -o "$HOME/Library/Fonts/sketchybar-app-font.ttf"
# Only if updating the mapping too:
# curl -fsSL "$BASE/icon_map.sh" -o "$HOME/.config/sketchybar/plugins/icon_map.sh"
```

### macOS settings

- **Displays have separate Spaces** must stay ON (default): *System Settings →
  Desktop & Dock*. AeroSpace requires it.
- **Hide the native menu bar** so SketchyBar sits alone at the top: *System
  Settings → Control Center → Automatically hide and show the menu bar →
  Always*.

### Starting the services

```sh
brew services start sketchybar   # run the bar at login
```

AeroSpace has `start-at-login = true` in `.aerospace.toml`; enable it once from
the AeroSpace menu or by launching the app.

### How it is wired

- `.aerospace.toml` sets `exec-on-workspace-change` to fire a custom SketchyBar
  event on every workspace switch:

  ```toml
  exec-on-workspace-change = ['/bin/bash', '-c',
      'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE']
  ```

- `sketchybarrc` adds the `aerospace_workspace_change` event, creates one
  `space.<id>` chip per workspace (`aerospace list-workspaces --all`), and a
  hidden `spaces_manager` item that re-renders the chips on
  `aerospace_workspace_change`, `front_app_switched`, and every 15s as a safety
  net (window moves that don't change focus catch up on the next tick).
- `plugins/spaces.sh` does the rendering: one `aerospace list-windows --all`
  query maps each workspace to its app glyphs (via `icon_map.sh`), hides empty
  unfocused workspaces, and highlights the focused one.
- `colors.sh` holds the Oasis Twilight palette in `0xAARRGGBB` form; every item
  sources it. `plugins/{front_app,battery,volume,clock}.sh` handle the
  remaining items.

Clicking a workspace chip runs `aerospace workspace <id>`, so the bar doubles
as a workspace switcher.

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
description: Cheap subagent for routine git tasks like committing and opening PRs.
mode: subagent
model: anthropic/claude-3-5-sonnet-latest
---

You are a focused git assistant. Perform the requested git task carefully and
concisely. Inspect the working tree before staging, never commit secrets, and
follow the repository's existing commit and PR conventions.
```

The agent must be `mode: subagent` (not `primary`), and the `/commit`, `/pr`,
and `/docs` commands set `subtask: true`. This runs each command in a fresh,
isolated context instead of switching the primary agent of your current
session — which would force opencode to compact the whole session first, every
time you invoke the command.

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
aerospace reload-config
brew services restart sketchybar
```

## Notes

- The theme direction is Oasis Twilight across Ghostty, tmux, Nvim, Powerlevel10k, opencode and SketchyBar.
- Do not commit plugin/runtime directories such as tmux plugins, Lazy.nvim checkouts or opencode `node_modules`.
- The SketchyBar app-icon font (`~/Library/Fonts/sketchybar-app-font.ttf`) is installed, not tracked; keep it in sync with the vendored `plugins/icon_map.sh`.
- Check opencode config for credentials before committing changes.
