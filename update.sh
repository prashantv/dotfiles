#!/bin/bash
# update.sh — rebase current branch onto latest main, then re-run setup.
set -euo pipefail

DOTFILES_DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
cd "$DOTFILES_DIR"

current_branch="$(git rev-parse --abbrev-ref HEAD)"

echo "Fetching latest main..."
git fetch origin main

echo "Rebasing $current_branch onto origin/main..."
git rebase origin/main

echo "Running setup.sh..."
./setup.sh "$@"
