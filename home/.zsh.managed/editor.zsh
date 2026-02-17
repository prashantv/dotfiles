#
# Sets key bindings.
#
# Based on zprezto's editor module:
# https://github.com/sorin-ionescu/prezto/blob/master/modules/editor/init.zsh
#
# Removed: vi-mode bindings and functions (vi-insert, vi-replace, vi-insert-bol,
#   zle-keymap-select, overwrite-mode, F-key/PageUp/PageDown noop bindings).
# Removed: editor-info / zle-reset-prompt (p10k handles prompt state).
# Removed: dot-expansion, glob-alias, pound-toggle, expand-or-complete-with-indicator,
#   bindkey-all, expand-cmd-path.
# Removed: prezto zstyle lookups for key-bindings and wordchars.
# Changed: hardcoded emacs mode instead of zstyle-driven layout.
# Changed: zle-line-init/finish no longer call editor-info.
# Changed: keybinds use emacs keymap only instead of looping over emacs+viins.
#

# Return if requirements are not found.
if [[ "$TERM" == 'dumb' ]]; then
  return 1
fi

#
# Variables
#

# Treat these characters as part of a word.
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Use human-friendly identifiers.
zmodload zsh/terminfo
typeset -gA key_info
key_info=(
  'Control'         '\C-'
  'ControlLeft'     '\e[1;5D \e[5D \e\e[D \eOd'
  'ControlRight'    '\e[1;5C \e[5C \e\e[C \eOc'
  'Escape'       '\e'
  'Meta'         '\M-'
  'Backspace'    "^?"
  'Delete'       "^[[3~"
  'Insert'       "$terminfo[kich1]"
  'Home'         "$terminfo[khome]"
  'End'          "$terminfo[kend]"
  'Up'           "$terminfo[kcuu1]"
  'Left'         "$terminfo[kcub1]"
  'Down'         "$terminfo[kcud1]"
  'Right'        "$terminfo[kcuf1]"
  'BackTab'      "$terminfo[kcbt]"
)

# Set empty $key_info values to an invalid UTF-8 sequence to induce silent
# bindkey failure.
for key in "${(k)key_info[@]}"; do
  if [[ -z "$key_info[$key]" ]]; then
    key_info[$key]=$'\xC0\x80'
  fi
done
unset key

# Allow command line editing in an external editor. (Ctrl+X, Ctrl+e).
autoload -Uz edit-command-line
zle -N edit-command-line

# Enables terminal application mode and updates editor information.
function zle-line-init {
  # The terminal must be in application mode when ZLE is active for $terminfo
  # values to be valid.
  if (( $+terminfo[smkx] )); then
    # Enable terminal application mode.
    echoti smkx
  fi
}
zle -N zle-line-init

# Disables terminal application mode and updates editor information.
function zle-line-finish {
  # The terminal must be in application mode when ZLE is active for $terminfo
  # values to be valid.
  if (( $+terminfo[rmkx] )); then
    # Disable terminal application mode.
    echoti rmkx
  fi
}
zle -N zle-line-finish

# Reset to default key bindings.
bindkey -d

#
# Emacs Key Bindings
#

for key in "$key_info[Escape]"{B,b} "${(s: :)key_info[ControlLeft]}" \
  "${key_info[Escape]}${key_info[Left]}"
  bindkey -M emacs "$key" emacs-backward-word
for key in "$key_info[Escape]"{F,f} "${(s: :)key_info[ControlRight]}" \
  "${key_info[Escape]}${key_info[Right]}"
  bindkey -M emacs "$key" emacs-forward-word

# Edit command in an external editor.
bindkey -M emacs "$key_info[Control]X$key_info[Control]E" edit-command-line

if (( $+widgets[history-incremental-pattern-search-backward] )); then
  bindkey -M emacs "$key_info[Control]R" \
    history-incremental-pattern-search-backward
  bindkey -M emacs "$key_info[Control]S" \
    history-incremental-pattern-search-forward
fi

#
# Emacs Key Bindings (from shared emacs+viins section, emacs-only here)
#

bindkey -M emacs "$key_info[Home]" beginning-of-line
bindkey -M emacs "$key_info[End]" end-of-line

bindkey -M emacs "$key_info[Delete]" delete-char
bindkey -M emacs "$key_info[Backspace]" backward-delete-char

bindkey -M emacs "$key_info[Left]" backward-char
bindkey -M emacs "$key_info[Right]" forward-char

# Expand history on space.
bindkey -M emacs ' ' magic-space

# Clear screen.
bindkey -M emacs "$key_info[Control]L" clear-screen

# Bind Shift + Tab to go to the previous menu item.
bindkey -M emacs "$key_info[BackTab]" reverse-menu-complete

#
# Layout
#
bindkey -e
