zmodload zsh/zprof
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

# Bash auto-completion compat
autoload bashcompinit
bashcompinit

autoload -Uz compinit


# Prompt theming
autoload -Uz promptinit
promptinit

setopt prompt_subst
#
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# configure fzf-tab completion
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
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'
# preview files using bat when completing vim
zstyle ':fzf-tab:complete:vim:*' fzf-preview 'cat $realpath'


export GITHUB_USER=prashantv
#
function jg() {
  if [ -d $GOPATH/src/github.com/prashantv/$1 ]; then
    cd $GOPATH/src/github.com/prashantv/$1
    return
  fi
  if [ -d $GOPATH/src/$1 ]; then
    cd $GOPATH/src/$1
    return
  fi

  # Try every directory in $GOPATH to see if there's a match.
  for f in $(echo $GOPATH/src/*); do
    if [ -d $f/$1 ]; then
      cd $f/$1
      return
    fi
  done
  echo "Failed to find match in $GOPATH for $1"
}

refresh_tmux_env() {
  for key in DISPLAY SSH_AUTH_SOCK SSH_CONNECTION SSH_CLIENT; do
    if (tmux show-environment | grep "^${key}" > /dev/null); then
      value=`tmux show-environment | grep "^${key}" | sed -e "s/^[A-Z_]*=//"`
      export ${key}="${value}"
    fi
  done
}

#cache-path must exist
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# speed up zsh+git autocomplete
# __git_heads_remote in zprof so disable remotes in auto-complete, from https://stackoverflow.com/questions/12175277/disable-auto-completion-of-remote-branches-in-zsh
zstyle :completion::complete:git-checkout:argument-rest:headrefs command "git for-each-ref --format='%(refname)' refs/heads 2>/dev/null"
# __git_files in zprof to use local files, from https://itecnote.com/tecnote/bash-zsh-auto-completion-for-git-takes-significant-amount-of-time-can-i-turn-it-off-or-optimize-it/
__git_files () {
    _wanted files expl 'local files' _files
}

# when PATH is large (esp WSL), pathdirs makes auto-complete hang.
unsetopt pathdirs

# Prashant's custom settings
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Use mise + shims
#eval "$(mise activate --shims)"
eval "$(mise activate)"


# Aliases

# fast with autojump aliases
eval "$(fasd --init auto)"
alias j='fasd_cd -d'     # cd, same functionality as j in autojump
alias jj='fasd_cd -d -i' # cd with interactive selection

# vim quit
alias ':q'=exit
alias g=git
alias gb='git branches'
alias gbc='git branches | read C'
alias gcm='git commits'
alias gcmc='git commits | read C'
alias gcb='git current-branch'
alias l=ls
alias ll=ls -al
alias ag='ag --path-to-ignore=~/.agignore'
alias pg='ping google.com'


# disable sharing history
setopt no_share_history

# Always use vim for everything
export VISUAL=vim
export EDITOR=vim

# Disable brew analytics on OSX
export HOMEBREW_NO_ANALYTICS=1

# source fzf completions & keybindings
source <(fzf --zsh)
# source fzf-git
source $HOME/bin/pkgs/fzf-git/fzf-git.sh

# Copy the current output, can be used with $P. Can be added to the end
# of a pipeline, and it will still echo the original input.
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

# use jq to prettify json
function json-fmt {
  cat $1 | jq -r . | sponge $1
}

function cdnew {
  mkdir -p -- "$1" && cd -P -- "$1"
}

function cddel {
  dir=$(pwd)
  cd ..
  rm -r $(dir) $@
}

# enable direnv if installed
if type direnv > /dev/null
then
  eval "$(direnv hook zsh)"
fi


# Env-specific settings
[[ -f ~/.zshrc_local ]] && source ~/.zshrc_local

