# Enable Powerlevel10k instant prompt. 
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set to "random" for random theme each time Oh My Zsh is loaded
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    macos
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C `which aws_completer` aws

# Aliases
alias gg="lazygit"
alias sp="spotify_player"

# Tree commands
if [ -x "$(command -v eza)" ]; then
    alias l="eza --group-directories-first"
    # alias la="eza -a --group-directories-first"
    alias ll="eza -l --group-directories-first"
    alias lla="eza -la --group-directories-first"
    alias tree="eza --tree"
    alias ltree="eza -l --tree"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Paths
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH
export PGUSER=postgres

# pnpm
export PNPM_HOME="/Users/joakimedvardsen/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
