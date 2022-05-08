#!/usr/bin/env bash

# Bash "strict" mode
set -euo pipefail
IFS=$'\n\t'

# Run commands from current directory
cd "$(dirname "$0")"

touch ~/.zshrc_local

