#!/usr/bin/env bash

# Bash "strict" mode
set -euo pipefail
IFS=$'\n\t'

# Run commands from current directory
cd "$(dirname "$0")"

# tmux
ln -sf `pwd`/.tmux*.conf ~/

# vim
ln -sf `pwd`/.vimrc ~/
cp -R .vim ~/

# zsh
ln -sf `pwd`/.zshrc ~/
ln -sf `pwd`/.inputrc ~/
touch ~/.zshrc_local
[ -d ~/.zprezto ] &&
  (cd ~/.zprezto; git pull; git submodule update --init --recursive) \
  || git clone --recursive https://github.com/sorin-ionescu/prezto.git ~/.zprezto

# git
ln -sf `pwd`/.git* ~/

