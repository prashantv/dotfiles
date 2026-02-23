#!/bin/sh
# test-setup.sh — spin up a Debian container, run setup.sh, and drop into zsh
#
# Usage:
#   ./test-setup.sh                  # test current branch
#   ./test-setup.sh --branch flatten # test a specific branch

set -eu

BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")"

while [ $# -gt 0 ]; do
  case "$1" in
    --branch)  BRANCH="$2"; shift 2 ;;
    --help)
      echo "Usage: test-setup.sh [--branch NAME]"
      echo "  --branch NAME   Branch to test (default: current branch)"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

echo "Testing setup from branch: $BRANCH"

exec docker run --rm -it debian:stable-slim sh -c "
  apt-get update && apt-get install -y curl git zsh
  curl -fsSL https://raw.githubusercontent.com/prashantv/dotfiles/${BRANCH}/setup.sh | bash -s -- --branch ${BRANCH}
  exec zsh -l
"
