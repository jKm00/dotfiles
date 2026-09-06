# ------
# Prompt
# ------

# Enable Powerlevel10k instant prompt. Keep this close to the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----------
# Oh My Zsh
# ----------

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  macos
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# -----------
# Completions
# -----------

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C `which aws_completer` aws

# -----------
# Environment
# -----------

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PGUSER=postgres

# ----
# PATH
# ----

# cargo
export PATH="$HOME/.cargo/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/joakimedvardsen/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH=/Users/joakimedvardsen/.opencode/bin:$PATH

# -------------------
# Tool Initialization
# -------------------

# bun completions
[ -s "/Users/joakimedvardsen/.bun/_bun" ] && source "/Users/joakimedvardsen/.bun/_bun"

# TheFuck
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# fzf
eval "$(fzf --zsh)"

# --- setup fzf theme ---
fg="#efe6f4"
bg="#261a32"
bg_highlight="#362343"
purple="#d2adff"
blue="#b8a6c9"
cyan="#f7997d"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"


# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# -------
# Aliases
# -------

alias gg="lazygit"
alias sp="spotify_player"
alias oc="opencode"
alias jarvis="opencode --port"

if [ -x "$(command -v eza)" ]; then
  alias l="eza --group-directories-first"
  # alias la="eza -a --group-directories-first"
  alias ll="eza -l --group-directories-first"
  alias lla="eza -la --group-directories-first"
  alias tree="eza --tree"
  alias ltree="eza -l --tree"
fi

if command -v bat &>/dev/null; then
  alias cat="bat"
fi

# ---------
# Functions
# ---------

whoisonport() { sudo lsof -i :"$1" } # whoisonport 3000
killport() { sudo kill -9 $(sudo lsof -t -i :"$1") } # killport 3000

swagger() {
  if ! command -v openapi-tui &>/dev/null; then
    echo "openapi-tui not installed — run: cargo install openapi-tui"
    return 1
  fi
  openapi-tui "$@"
}

# --------------------------
# Machine-Specific Overrides
# --------------------------

# Keep this last so local machine config can override anything above.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
