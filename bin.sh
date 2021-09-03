#!/usr/bin/env bash

# Bash "strict" mode
set -euo pipefail
IFS=$'\n\t'

echo "== FZF =="
mkdir -p .extracted/fzf

# Download the latest fzf release and install it to ~/bin
./dl-github.sh junegunn/fzf | tar xvz -C .extracted/fzf && install -m 755 .extracted/fzf/fzf ~/bin/fzf

