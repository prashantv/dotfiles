# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="frisk"

export GITHUB_USER=prashantv

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="false"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"


# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
#plugins=(git tmux web-search)
plugins=()

source $ZSH/oh-my-zsh.sh

# fix for slow git
function git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$ZSH_THEME_GIT_PROMPT_SUFFIX"
}
# don't use bzr and doubt i ever will.
function bzr_prompt_info() {}

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

# Aliases
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

# Env-specific settings
source ~/.zshrc_local

brew analytics off 2>&1 >/dev/null
