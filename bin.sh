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
./dl-github.sh junegunn/fzf | tar xvz -C .extracted/fzf && install -m 755 .extracted/fzf/fzf ~/bin/fzf

