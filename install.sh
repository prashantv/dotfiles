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
cp -R .vim ~/.vim || echo "vim failed, continue"

# zsh
ln -sf `pwd`/.zshrc ~/
ln -sf `pwd`/.p10k.zsh ~/
ln -sf `pwd`/.zpreztorc ~/
ln -sf `pwd`/.inputrc ~/
touch ~/.zshrc_local
[ -d ~/.zprezto ] &&
  (cd ~/.zprezto; git pull; git submodule update --init --recursive) \
  || git clone --depth 1 --recursive --shallow-submodules https://github.com/sorin-ionescu/prezto.git ~/.zprezto
# zsh plugin
[ -d ~/.zprezto-contrib/zsh-z ] &&
  (cd ~/.zprezto-contrib/zsh-z; git pull) \
  || git clone --depth 1 https://github.com/agkozak/zsh-z.git ~/.zprezto-contrib/zsh-z

# git
ln -sf `pwd`/.gitconfig ~/
ln -sf `pwd`/.gitignore_global ~/

# create .tmp
[ -d ~/tmp ] || mkdir ~/tmp

# disable homebrew analytics always
command -v brew >/dev/null 2>&1 && brew analytics off
