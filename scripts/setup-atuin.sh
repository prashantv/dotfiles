#!/bin/sh
# setup-atuin.sh — decrypt atuin key and login to atuin sync server
#
# Usage:
#   ./scripts/setup-atuin.sh
#
# Requires: openssl, atuin

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEY_ENC="$SCRIPT_DIR/atuin-key.enc"

if [ ! -f "$KEY_ENC" ]; then
  echo "Error: encrypted key not found at $KEY_ENC" >&2
  exit 1
fi

if ! command -v atuin >/dev/null; then
  echo "Error: atuin not found on PATH" >&2
  exit 1
fi

# Decrypt the atuin key into a variable
echo "Decrypting atuin key..."
KEY="$(openssl enc -aes-256-cbc -pbkdf2 -d -in "$KEY_ENC")"

# Login to atuin (passes the key inline, avoiding conflicts with existing key files)
echo "Logging in to atuin..."
atuin login -u prashant -k "$KEY"

echo ""
echo "Atuin setup complete! Run 'atuin sync' to sync history."
