#!/usr/bin/env bash

# Bash "strict" mode
set -euo pipefail
IFS=$'\n\t'

# Copy links to files in bin
for f in `pwd`/bin/*
do
  ln -sf $f ~/bin/
done

echo "== FZF =="
mkdir -p .extracted/fzf

# Download the latest fzf release and install it to ~/bin
echo "  binary from release"
./dl-github.sh junegunn/fzf | tar xvz -C .extracted/fzf && install -m 755 .extracted/fzf/fzf ~/bin/
echo "  fzf-tmux binary"
./dl-raw-github.sh junegunn/fzf bin/fzf-tmux > .extracted/fzf/fzf-tmux && install -m 755 .extracted/fzf/fzf-tmux ~/bin/
echo "  zsh completions"
./dl-raw-github.sh junegunn/fzf shell/completion.zsh > .extracted/fzf/completion.zsh
./dl-raw-github.sh junegunn/fzf shell/key-bindings.zsh > .extracted/fzf/key-bindings.zsh

