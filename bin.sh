#!/usr/bin/env bash

# Bash "strict" mode
set -euo pipefail
IFS=$'\n\t'

# Download the latest releases and install it to ~/bin

echo "== tmux-fastcopy =="
mkdir -p .extracted/tmux-fastcopy
echo "  binary from release"
./dl-github.sh abhinav/tmux-fastcopy | tar xvz -C .extracted/tmux-fastcopy && install -m 755 .extracted/tmux-fastcopy/tmux-fastcopy ~/bin/

