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
KEY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/atuin"
KEY_FILE="$KEY_DIR/key"

if [ ! -f "$KEY_ENC" ]; then
  echo "Error: encrypted key not found at $KEY_ENC" >&2
  exit 1
fi

if ! command -v atuin >/dev/null; then
  echo "Error: atuin not found on PATH" >&2
  exit 1
fi

# Decrypt the atuin key
mkdir -p "$KEY_DIR"
echo "Decrypting atuin key..."
openssl enc -aes-256-cbc -pbkdf2 -d -in "$KEY_ENC" -out "$KEY_FILE"
chmod 600 "$KEY_FILE"
echo "Key written to $KEY_FILE"

# Login to atuin
echo "Logging in to atuin..."
atuin login -u prashant

echo ""
echo "Atuin setup complete! Run 'atuin sync' to sync history."
