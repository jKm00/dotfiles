<div align="center">

# 🎨 Dotfiles

**Personal development environment configuration files**

[![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Shell](https://img.shields.io/badge/Shell-Zsh-89e051?style=flat&logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Neovim](https://img.shields.io/badge/Neovim-57A143?style=flat&logo=neovim&logoColor=white)](https://neovim.io/)
[![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=flat&logo=visual-studio-code&logoColor=white)](https://code.visualstudio.com/)

</div>

---

## 📦 What's Inside

This repository contains my personal configuration files for a streamlined and efficient development workflow.

### 🖥️ Terminal & Shell

| Tool | Description | Status |
|------|-------------|--------|
| **[Kitty](https://sw.kovidgoyal.net/kitty/)** | GPU-accelerated terminal emulator with custom themes and configurations | Inactive 💤 |
| **[Tmux](https://github.com/tmux/tmux)** | Terminal multiplexer for managing multiple sessions and panes | Inactive 💤 |
| **[Zsh](https://www.zsh.org/)** | Powerful shell with enhanced features and customization | ✅ **Daily Driver** |

### ✏️ Editors

| Tool | Description | Status |
|------|-------------|--------|
| **[Neovim](https://neovim.io/)** | Hyperextensible Vim-based text editor with custom plugins | Inactive 💤 |
| **[VS Code](https://code.visualstudio.com/)** | Primary editor with Vim plugin and custom keybindings | ✅ **Daily Driver** |

> **Note:** Currently using VS Code as my primary editor with the Vim extension and heavily customized keyboard shortcuts for a Vim-like experience.

### 🛠️ CLI Tools

| Tool | Description |
|------|-------------|
| **[lazygit](https://github.com/jesseduffield/lazygit)** | Simple terminal UI for Git operations |
| **[spotify_player](https://github.com/aome510/spotify-player)** | Spotify client for the terminal |


---

## 🚀 Quick Start

### Prerequisites

Install the required tools using [Homebrew](https://brew.sh/):

```bash
# Terminal & Shell
brew install kitty tmux zsh

# Editors
brew install neovim
# VS Code: Download from https://code.visualstudio.com/

# CLI Tools
brew install lazygit
brew install spotify_player
```

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/jKm00/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Backup existing configurations (optional but recommended):**
   ```bash
   mkdir -p ~/.config/backup
   mv ~/.config/kitty ~/.config/backup/ 2>/dev/null || true
   mv ~/.config/nvim ~/.config/backup/ 2>/dev/null || true
   mv ~/.config/tmux ~/.config/backup/ 2>/dev/null || true
   mv ~/.zshrc ~/.zshrc.backup 2>/dev/null || true
   ```

3. **Copy configuration files:**
   ```bash
   # Create config directory if it doesn't exist
   mkdir -p ~/.config

   # Copy configurations
   cp -r kitty/ ~/.config/
   cp -r nvim/ ~/.config/
   cp -r tmux/ ~/.config/
   cp .zshrc ~/
   ```

4. **Apply VS Code settings:**
   ```bash
   # macOS
   cp vscode/settings.json ~/Library/Application\ Support/Code/User/
   cp vscode/keybindings.json ~/Library/Application\ Support/Code/User/
   ```

5. **Reload shell configuration:**
   ```bash
   source ~/.zshrc
   ```

---

## 🎨 Features

### Kitty Terminal
- 🎭 Multiple theme configurations (Tokyo Night, Cyberdream, Catppuccin, etc.)
- 🔄 Theme switching scripts
- 🪟 Transparency toggle support
- 📺 Separate coding and screencasting profiles

### Neovim
- 📦 Plugin management with Lazy.nvim
- 🌳 File explorer with nvim-tree
- 🔍 Fuzzy finding with Telescope
- 💬 GitHub Copilot integration
- 🎨 Custom colorscheme
- ⚡ LSP support via Mason
- And much more!

### VS Code
- ⌨️ Vim keybindings and workflow
- 🔧 Heavily customized keyboard shortcuts
- 📋 Custom settings for optimal workflow

### Tmux
- 🪟 Efficient window and pane management
- 🎨 Catppuccin theme integration
- 🔄 Custom hooks and scripts

---

**Made with ❤️ and ☕**
