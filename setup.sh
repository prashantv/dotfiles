#!/bin/sh
# setup.sh — install and configure dotfiles
#
# Usage:
#   Fresh install (no git required):
#     curl -fsSL https://raw.githubusercontent.com/prashantv/dotfiles/main/setup.sh | bash
#   Fresh install with git:
#     curl -fsSL https://raw.githubusercontent.com/prashantv/dotfiles/main/setup.sh | bash -s -- --git
#   From existing clone:
#     ./setup.sh

set -eu

REPO_URL="https://github.com/prashantv/dotfiles"
DOTFILES_DIR="$HOME/dotfiles"
BRANCH="main"
PROFILE=""
USE_GIT=0

usage() {
  cat <<EOF
Usage: setup.sh [OPTIONS]
  --branch NAME      Branch to use (default: main)
  --git              Clone via git instead of downloading tarball
  --profile NAME     Machine profile for zshrc_local (default: hostname)
  --repo URL         Git repo URL (default: $REPO_URL)
  --dir PATH         Install directory (default: $DOTFILES_DIR)
  --help             Show usage
EOF
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    --branch)  BRANCH="$2"; shift 2 ;;
    --git)     USE_GIT=1; shift ;;
    --profile) PROFILE="$2"; shift 2 ;;
    --repo)    REPO_URL="$2"; shift 2 ;;
    --dir)     DOTFILES_DIR="$2"; shift 2 ;;
    --help)    usage ;;
    *)         echo "Unknown option: $1" >&2; usage ;;
  esac
done

[ -z "$PROFILE" ] && PROFILE="$(hostname)"

BACKUP_DIR="$HOME/dotfiles.bak"
HOME_DIR="$DOTFILES_DIR/home"

# --- Acquire dotfiles ---

# Check if we're running from inside the repo already.
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
if [ -f "$script_dir/home/.zshrc" ]; then
  DOTFILES_DIR="$script_dir"
  HOME_DIR="$DOTFILES_DIR/home"
  echo "Using existing dotfiles at $DOTFILES_DIR"
elif [ -d "$DOTFILES_DIR/home" ]; then
  echo "Dotfiles already present at $DOTFILES_DIR"
elif [ "$USE_GIT" = 1 ]; then
  echo "Cloning dotfiles to $DOTFILES_DIR (branch: $BRANCH)..."
  git clone --branch "$BRANCH" "$REPO_URL" "$DOTFILES_DIR"
else
  echo "Downloading dotfiles to $DOTFILES_DIR..."
  tmptar="$(mktemp)"
  curl -fsSL "$REPO_URL/archive/refs/heads/${BRANCH}.tar.gz" -o "$tmptar"
  mkdir -p "$DOTFILES_DIR"
  tar xzf "$tmptar" --strip-components=1 -C "$DOTFILES_DIR"
  rm -f "$tmptar"
fi

# --- Symlink home/ → ~/ ---

echo "Symlinking dotfiles..."
(cd "$HOME_DIR" && find . -type f | while read -r rel; do
  # Strip leading ./
  rel="${rel#./}"

  # Skip .profiles directory (handled separately)
  case "$rel" in .profiles/*) continue ;; esac

  src="$HOME_DIR/$rel"
  dst="$HOME/$rel"

  # Already symlinked to us — skip
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    continue
  fi

  # Back up existing file
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$dst" "$BACKUP_DIR/$rel"
    echo "  backed up ~/$rel → $BACKUP_DIR/$rel"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
done)
echo "  done"

# --- Profile setup ---

profile_dir="$HOME_DIR/.profiles/$PROFILE"
if [ -d "$profile_dir" ]; then
  echo "Setting profile: $PROFILE"
  ln -sf "$profile_dir/zshrc_local" "$HOME/.zshrc_local"
else
  echo "Warning: profile '$PROFILE' not found at $profile_dir" >&2
  echo "Available profiles:"
  ls "$HOME_DIR/.profiles/" 2>/dev/null || echo "  (none)"
fi

# --- Generate .gitconfig_gen ---

echo "Generating ~/.gitconfig_gen..."
if command -v delta >/dev/null 2>&1; then
  cat > "$HOME/.gitconfig_gen" <<'GITCFG'
[core]
	pager = delta

[interactive]
	diffFilter = delta --color-only
GITCFG
else
  : > "$HOME/.gitconfig_gen"
fi

# --- External dependencies ---

echo "Installing external dependencies..."

# zprezto
if [ ! -d "$HOME/.zprezto" ]; then
  echo "  Cloning zprezto..."
  git clone --depth=100 \
    --shallow-submodules \
    --recurse-submodules=modules/completion/external \
    "--recurse-submodules=modules/prompt/*" \
    https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto"
else
  echo "  zprezto already installed"
fi

# fzf-tab
if [ ! -d "$HOME/.zprezto-contrib/fzf-tab" ]; then
  echo "  Cloning fzf-tab..."
  mkdir -p "$HOME/.zprezto-contrib"
  git clone --depth=100 https://github.com/Aloxaf/fzf-tab "$HOME/.zprezto-contrib/fzf-tab"
else
  echo "  fzf-tab already installed"
fi

# direnv
if [ ! -f "$HOME/bin/direnv" ]; then
  echo "  Downloading direnv..."
  direnv_version="2.32.3"
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"
  case "$arch" in x86_64) arch="amd64" ;; aarch64|arm64) arch="arm64" ;; esac
  mkdir -p "$HOME/bin"
  curl -fsSL "https://github.com/direnv/direnv/releases/download/v${direnv_version}/direnv.${os}-${arch}" -o "$HOME/bin/direnv"
  chmod +x "$HOME/bin/direnv"
else
  echo "  direnv already installed"
fi

# fasd
if [ ! -f "$HOME/bin/fasd" ]; then
  echo "  Downloading fasd..."
  mkdir -p "$HOME/bin"
  curl -fsSL "https://raw.githubusercontent.com/clvv/fasd/master/fasd" -o "$HOME/bin/fasd"
  chmod +x "$HOME/bin/fasd"
else
  echo "  fasd already installed"
fi

# fzf-git
if [ ! -f "$HOME/bin/pkgs/fzf-git/fzf-git.sh" ]; then
  echo "  Downloading fzf-git.sh..."
  mkdir -p "$HOME/bin/pkgs/fzf-git"
  curl -fsSL "https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh" -o "$HOME/bin/pkgs/fzf-git/fzf-git.sh"
else
  echo "  fzf-git.sh already installed"
fi

# mise
if ! command -v mise >/dev/null 2>&1; then
  echo "  Installing mise..."
  curl -fsSL https://mise.run | sh
fi
export PATH="$HOME/.local/bin:$PATH"
echo "  Running mise install..."
mise install

# --- Misc setup ---

mkdir -p "$HOME/tmp"

# Disable brew analytics on macOS
if command -v brew >/dev/null 2>&1; then
  brew analytics off
fi

echo ""
echo "Setup complete!"
echo "Open a new shell to start using your dotfiles."
