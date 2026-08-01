# Dotfiles

Personal configuration for a terminal-first development setup.

The repo is the source of truth. Active config files in `$HOME` are symlinked back into this repo.

## Setup

| Config        | Purpose                                                       | Source               |
| ------------- | ------------------------------------------------------------- | -------------------- |
| Ghostty       | Terminal theme, wallpaper, opacity and shaders                | `.config/ghostty`    |
| tmux          | Multiplexer config, Oasis Twilight theme, Spotify integration | `.config/tmux`       |
| zsh           | Shell config and aliases                                      | `.zshrc`             |
| Powerlevel10k | Prompt layout and Oasis Twilight color overrides              | `.p10k.zsh`          |
| Nvim          | Editor config, Oasis theme, opencode.nvim integration         | `.config/nvim`       |
| opencode      | TUI config and transparent Oasis Twilight theme               | `.config/opencode`   |
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
~/.config/opencode/themes -> ~/dev/repos/personal/dotfiles/.config/opencode/themes
```

Local-only paths:

```text
~/.config/tmux/plugins
~/.config/opencode/node_modules
~/.config/opencode/package.json
~/.config/opencode/package-lock.json
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
