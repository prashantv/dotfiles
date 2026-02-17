#
# General shell environment settings.
#
# Smart URLs section based on zprezto's environment module:
# https://github.com/sorin-ionescu/prezto/blob/master/modules/environment/init.zsh
#

#
# Smart URLs
#

# This logic comes from an old version of zim. Essentially, bracketed-paste was
# added as a requirement of url-quote-magic in 5.1, but in 5.1.1 bracketed
# paste had a regression. Additionally, 5.2 added bracketed-paste-url-magic
# which is generally better than url-quote-magic so we load that when possible.
autoload -Uz is-at-least
if [[ $ZSH_VERSION != 5.1.1 && $TERM != dumb ]]; then
  if is-at-least 5.2; then
    autoload -Uz bracketed-paste-url-magic
    zle -N bracketed-paste bracketed-paste-url-magic
  elif is-at-least 5.1; then
    autoload -Uz bracketed-paste-magic
    zle -N bracketed-paste bracketed-paste-magic
  fi
  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic
fi

#
# Options
#

setopt INTERACTIVE_COMMENTS # Enable comments in interactive shell.
