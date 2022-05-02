#!/usr/bin/env bash

# Bash "strict" mode
set -euo pipefail
IFS=$'\n\t'

# Run commands from current directory
cd "$(dirname "$0")"

touch ~/.zshrc_local
[ -d ~/.zprezto ] &&
  (cd ~/.zprezto; git pull; git submodule update --init --recursive) \
  || git clone --depth 1 --recursive --shallow-submodules https://github.com/sorin-ionescu/prezto.git ~/.zprezto
# zsh plugin
[ -d ~/.zprezto-contrib/zsh-z ] &&
  (cd ~/.zprezto-contrib/zsh-z; git pull) \
  || git clone --depth 1 https://github.com/agkozak/zsh-z.git ~/.zprezto-contrib/zsh-z


# create .tmp
[ -d ~/tmp ] || mkdir ~/tmp

# disable homebrew analytics always
command -v brew >/dev/null 2>&1 && brew analytics off
