source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"


autoload -Uz promptinit
promptinit

# %F{magenta}%n%f@%F{yellow}%m%f %F{green}%~%f ${git_info:+${(e)git_info[prompt]}}$

# Customization over sorin:
export PS1="%F{blue}%/%f [%n@%m] %F{gray} [%T]$f
%F{white}>%f "
# Should be set by sorin theme:
export RPROMPT="$python_info[virtualenv]${editor_info[overwrite]}%(?:: %F{1}✘ %? %f)${VIM:+" %B%F{6}V%f%b"}${_prompt_sorin_git}"


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
command -v brew >/dev/null 2>&1 && brew analytics off 2>&1 >/dev/null

# Env-specific settings
source ~/.zshrc_local

