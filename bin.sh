#!/usr/bin/env bash

# Bash "strict" mode
set -euo pipefail
IFS=$'\n\t'

# Download the latest releases and install it to ~/bin

echo "== FZF =="
mkdir -p .extracted/fzf
./dl-github.sh junegunn/fzf | tar xvz -C .extracted/fzf && install -m 755 .extracted/fzf/fzf ~/bin/

echo "  binary from release"
./dl-github.sh junegunn/fzf | tar xvz -C .extracted/fzf && install -m 755 .extracted/fzf/fzf ~/bin/
echo "  fzf-tmux binary"
./dl-raw-github.sh junegunn/fzf bin/fzf-tmux > .extracted/fzf/fzf-tmux && install -m 755 .extracted/fzf/fzf-tmux ~/bin/
echo "  zsh completions"
./dl-raw-github.sh junegunn/fzf shell/completion.zsh > .extracted/fzf/completion.zsh
./dl-raw-github.sh junegunn/fzf shell/key-bindings.zsh > .extracted/fzf/key-bindings.zsh

echo "== tmux-fastcopy =="
mkdir -p .extracted/tmux-fastcopy
echo "  binary from release"
./dl-github.sh abhinav/tmux-fastcopy | tar xvz -C .extracted/tmux-fastcopy && install -m 755 .extracted/tmux-fastcopy/tmux-fastcopy ~/bin/

