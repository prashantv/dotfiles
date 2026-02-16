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
SSH_REPO_URL="git@github.com:prashantv/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
BRANCH="main"
PROFILE=""
USE_GIT=0

usage() {
  cat <<EOF
Usage: setup.sh [OPTIONS]
  --branch NAME      Branch to use (default: main)
  --git              Clone via SSH instead of downloading tarball
  --profile NAME     Machine profile for zshrc_local (default: hostname)
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
  git clone --branch "$BRANCH" "$SSH_REPO_URL" "$DOTFILES_DIR"
else
  echo "Downloading dotfiles to $DOTFILES_DIR..."
  tmptar="$(mktemp)"
  curl -fsSL "$REPO_URL/archive/refs/heads/${BRANCH}.tar.gz" -o "$tmptar"
  mkdir -p "$DOTFILES_DIR"
  tar xzf "$tmptar" --strip-components=1 -C "$DOTFILES_DIR"
  rm -f "$tmptar"
fi

# Symlink every file in the given directory to the corresponding path under $HOME.
# Existing files are backed up to $BACKUP_DIR; existing correct symlinks are skipped.
symlink_dir() {
  dir="$1"
  (cd "$dir" && find . -type f | while read -r rel; do
    rel="${rel#./}"
    target="$dir/$rel"
    link="$HOME/$rel"

    # Already symlinked to target — skip
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
      continue
    fi

    # Back up existing file
    if [ -e "$link" ] || [ -L "$link" ]; then
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$link" "$BACKUP_DIR/$rel"
      echo "  backed up ~/$rel → $BACKUP_DIR/$rel"
    fi

    mkdir -p "$(dirname "$link")"
    ln -sf "$target" "$link"
  done)
}

# --- Symlink common files ---
echo "Symlinking dotfiles..."
symlink_dir "$HOME_DIR"
echo "  done"

# --- Symlink profile-specific files ---
profile_dir="$DOTFILES_DIR/profiles/$PROFILE"
if [ -d "$profile_dir" ]; then
  echo "Symlink for profile: $PROFILE"
  symlink_dir "$profile_dir"
  echo "  done"
else
  echo "Warning: profile '$PROFILE' not found at $profile_dir" >&2
  echo "Available profiles:"
  ls "$DOTFILES_DIR/profiles/" 2>/dev/null || echo "  (none)"
fi

# --- Generate .gitconfig_delta ---

echo "Generating ~/.gitconfig_delta..."
if command -v delta >/dev/null 2>&1; then
  cat > "$HOME/.gitconfig_delta" <<'GITCFG'
[core]
	pager = delta

[interactive]
	diffFilter = delta --color-only
GITCFG
else
  : > "$HOME/.gitconfig_delta"
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
  echo "  Updating zprezto..."
  git -C "$HOME/.zprezto" pull
  git -C "$HOME/.zprezto" submodule update --init --recursive
fi

# fzf-tab
if [ ! -d "$HOME/.zprezto-contrib/fzf-tab" ]; then
  echo "  Cloning fzf-tab..."
  mkdir -p "$HOME/.zprezto-contrib"
  git clone --depth=100 https://github.com/Aloxaf/fzf-tab "$HOME/.zprezto-contrib/fzf-tab"
else
  echo "  Updating fzf-tab..."
  git -C "$HOME/.zprezto-contrib/fzf-tab" pull
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
echo "  Running mise install for shell dependencies"
mise install fzf

# --- Misc setup ---

mkdir -p "$HOME/tmp"

# Disable brew analytics on macOS
if command -v brew >/dev/null 2>&1; then
  brew analytics off
fi

echo ""
echo "Setup complete!"
echo "Open a new shell to start using your dotfiles."
