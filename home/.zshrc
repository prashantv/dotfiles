# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Shell configuration modules (see comments in each file for upstream links).
source ~/.zsh.managed/environment.zsh  # Smart URLs, interactive comments, stty
source ~/.zsh.managed/history.zsh      # History dedup options and variables
source ~/.zsh.managed/directory.zsh    # Directory navigation options (auto_cd, pushd)
source ~/.zsh.managed/editor.zsh       # Emacs keybindings and terminfo key setup
source ~/.zsh.managed/completion.zsh   # compinit, case-insensitive matching, caching
source ~/.zsh.managed/glob.zsh

# Don't overwrite existing files with > and >>. Use >! or >| and >>! to bypass.
unsetopt CLOBBER

# Disable Ctrl+S/Ctrl+Q flow control (prevents terminal freezing on Ctrl+S).
# FLOW_CONTROL disables it in ZLE; stty -ixon disables it at the terminal level.
unsetopt FLOW_CONTROL
[[ -r ${TTY:-} && -w ${TTY:-} && $+commands[stty] == 1 ]] && stty -ixon <$TTY >$TTY

# Prompt
autoload -Uz promptinit && promptinit
source ~/.local/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fzf-tab (must be after compinit, before fzf-tab zstyles)
source ~/.local/share/fzf-tab/fzf-tab.plugin.zsh

# fzf-tab completion settings — these override some zstyles from completion.zsh
# (descriptions format, menu no) which is intentional for fzf-tab to work.
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# preview files and directories using bat/eza with fallbacks
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'fzf-preview $realpath'
zstyle ':fzf-tab:complete:vim:*' fzf-preview 'fzf-preview $realpath'

#
# User config
#

export GITHUB_USER=prashantv

refresh_tmux_env() {
  for key in DISPLAY SSH_AUTH_SOCK SSH_CONNECTION SSH_CLIENT; do
    if (tmux show-environment | grep "^${key}" > /dev/null); then
      value=`tmux show-environment | grep "^${key}" | sed -e "s/^[A-Z_]*=//"`
      export ${key}="${value}"
    fi
  done
}

# Speed up zsh+git autocomplete.
# Disable remote branches in checkout completion (__git_heads_remote is slow):
# https://stackoverflow.com/questions/12175277/disable-auto-completion-of-remote-branches-in-zsh
zstyle :completion::complete:git-checkout:argument-rest:headrefs command "git for-each-ref --format='%(refname)' refs/heads 2>/dev/null"
# Override __git_files to use local files only (the default walks the entire repo):
# https://itecnote.com/tecnote/bash-zsh-auto-completion-for-git-takes-significant-amount-of-time-can-i-turn-it-off-or-optimize-it/
__git_files () {
    _wanted files expl 'local files' _files
}

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Aliases

# zoxide (directory jumping by frecency)
eval "$(zoxide init zsh)"
alias j=z
alias jj=zi

# vim quit
alias ':q'=exit
alias g=git
alias gb='git branches'
alias gbc='git branches | read C'
alias gcm='git commits'
alias gcmc='git commits | read C'
alias gcb='git current-branch'
alias l=ls
alias ll='ls -al'
alias ag='ag --path-to-ignore=~/.agignore'
alias pg='ping google.com'

# Always use vim for everything
export VISUAL=vim
export EDITOR=vim

# Disable brew analytics on OSX
export HOMEBREW_NO_ANALYTICS=1

# source fzf completions & keybindings
source <(fzf --zsh)
# source fzf-git
source $HOME/bin/pkgs/fzf-git/fzf-git.sh

# Copy the last pipeline output into $P. Can be appended to any pipeline
# and still passes through the original output. Usage: some_cmd | c; echo $P
function c() {
  tee >(cat) | read P
}

function cdd() {
  if [[ -d "$1" ]]; then
    cd "$1"
  else
    echo "$1 is a file, cd to dir instead" >&2
    cd $(dirname "$1")
  fi
}

function gch() {
  git checkout $(gb $1)
}

function grb() {
  git rebase -i $(gb)
}

function grbm() {
  git rebase -i "$(git main)"
}

function git-delete-merged-branches {
  for b in $(git remote prune origin --dry-run |
    sed 's/.*origin\///g' |
    grep "^prashant")
    do
      git branch -D $b
      git branch -r --delete origin/$b
    done
}

function git-root {
  cd $(git rev-parse --show-toplevel)
}

# Prettify a JSON file in-place using jq.
function json-fmt {
  cat $1 | jq -r . | sponge $1
}

function cdnew {
  mkdir -p -- "$1" && cd -P -- "$1"
}

function cddel {
  dir=$(pwd)
  cd ..
  rm -r "$dir" "$@"
}

# enable direnv if installed
if type direnv > /dev/null
then
  eval "$(direnv hook zsh)"
fi

# Env-specific settings
[[ -f ~/.zshrc_local ]] && source ~/.zshrc_local
