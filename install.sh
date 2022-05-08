#!/usr/bin/env bash

# Bash "strict" mode
set -euo pipefail
IFS=$'\n\t'

# Run commands from current directory
cd "$(dirname "$0")"

touch ~/.zshrc_local

# create .tmp
[ -d ~/tmp ] || mkdir ~/tmp

# disable homebrew analytics always
command -v brew >/dev/null 2>&1 && brew analytics off
