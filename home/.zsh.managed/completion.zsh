#
# Sets completion options and caching.
#
# Based on zprezto's completion module:
# https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh
#

# Return if requirements are not found.
if [[ $TERM == dumb ]]; then
  return 1
fi

# Complete words.
setopt COMPLETE_IN_WORD     # Complete from both ends of a word.
setopt ALWAYS_TO_END        # Move cursor to the end of a completed word.

# Load and initialize the completion system. Regenerate the dump at most once
# per day; use the cached dump (-C) otherwise.
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Load bash completion compatibility layer (for tools that only ship bash completions).
autoload -Uz bashcompinit && bashcompinit

# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# Case-insensitive (all), partial-word, and then substring completion.
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:upper:]}={[:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
