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

# Prompt theming
autoload -Uz promptinit
promptinit

setopt prompt_subst
#
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


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

# Prashant's custom settings
export PATH="$HOME/bin:$PATH"

# Aliases

# fast with autojump aliases
eval "$(fasd --init auto)"
alias j='fasd_cd -d'     # cd, same functionality as j in autojump
alias jj='fasd_cd -d -i' # cd with interactive selection

# vim quit
alias ':q'=exit
alias g=git
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

# install fzf
source ~/dotfiles/.extracted/fzf/completion.zsh
source ~/dotfiles/.extracted/fzf/key-bindings.zsh

# Copy the current output, can be used with $P. Can be added to the end
# of a pipeline, and it will still echo the original input.
function c() {
  tee >(cat) | read P
}

function gb() {
  git branch -l | cut -c3- | fzf
}

function gch() {
  git checkout $(gb)
}

function gcb() {
  git branch --show-current
}

function grb() {
  git rebase -i $(gb)
}

function git-delete-current-branch {
  cur_branch=$(git branch --show-current)
  git checkout master
  git branch -D "$cur_branch"
}
function git-dcb { git-delete-current-branch }

function git-root {
  cd $(git rev-parse --show-toplevel)
}


# Env-specific settings
source ~/.zshrc_local
