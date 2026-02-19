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
SKIP_BINARIES=""

usage() {
  cat <<EOF
Usage: setup.sh [OPTIONS]
  --branch NAME      Branch to use (default: main)
  --git              Clone via SSH instead of downloading tarball
  --profile NAME     Profile for environment-specified overrides (saved to profile.local, defaults to hostname)
  --dir PATH         Install directory (default: $DOTFILES_DIR)
  --skip-binaries    Don't download binaries; expect them to be user-installed
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
    --skip-binaries) SKIP_BINARIES=1; shift ;;
    --help)    usage ;;
    *)         echo "Unknown option: $1" >&2; usage ;;
  esac
done

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

# Back up an existing file or symlink at $1, storing it under $BACKUP_DIR
# at the relative path $2. No-op if nothing exists at $1.
backup_existing() {
  link="$1" rel="$2"
  if [ -e "$link" ] || [ -L "$link" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$link" "$BACKUP_DIR/$rel"
    echo "  backed up ~/$rel → $BACKUP_DIR/$rel"
  fi
}

# Symlink files and directories from $1 into $HOME.
# - Files get per-file symlinks (so local files can coexist, e.g. in bin/).
# - Directories with a ".managed" suffix (e.g., .zsh.managed) are symlinked as
#   a whole directory. Other directories are walked recursively per-file.
# Existing files are backed up to $BACKUP_DIR; existing correct symlinks are skipped.
symlink_dir() {
  dir="$1"

  # Use find to walk files and directories in one pass.
  # -name '*.managed' dirs are symlinked whole and not descended into (-prune).
  # Everything else is symlinked per-file.
  (cd "$dir" && find . \( -name '*.managed' -type d -prune \) -o -type f -print | while read -r entry; do
    entry="${entry#./}"
    target="$dir/$entry"
    link="$HOME/$entry"

    if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
      continue
    fi

    backup_existing "$link" "$entry"
    mkdir -p "$(dirname "$link")"
    ln -sf "$target" "$link"
  done)

  # Symlink *.managed directories as a whole.
  (cd "$dir" && find . -maxdepth 1 -name '*.managed' -type d -print | while read -r entry; do
    entry="${entry#./}"
    target="$dir/$entry"
    link="$HOME/$entry"

    if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
      continue
    fi

    backup_existing "$link" "$entry"
    ln -sf "$target" "$link"
  done)
}

# Clone or update a git repo at $2 from URL $1.
git_update() {
  if [ ! -d "$2" ]; then
    echo "  Cloning $1..."
    git clone --depth=1 "$1" "$2"
  else
    echo "  Updating $1..."
    git -C "$2" pull
  fi
}

# Warn if command $1 is not found, with install URL $2.
warn_missing() {
  command -v "$1" >/dev/null || echo "  WARNING: $1 not found on PATH. Install it: $2"
}

# --- Resolve profile ---
# Precedence: --profile flag > profile.local file > hostname.
# The resolved profile is persisted to profile.local for future runs.
PROFILE_FILE="$DOTFILES_DIR/profile.local"
if [ -z "$PROFILE" ] && [ -f "$PROFILE_FILE" ]; then
  PROFILE="$(cat "$PROFILE_FILE")"
fi
[ -z "$PROFILE" ] && PROFILE="$(hostname)"
echo "Using profile: $PROFILE"
echo "$PROFILE" > "$PROFILE_FILE"

# --- Load and persist options ---
OPTIONS_FILE="$DOTFILES_DIR/options.local"
CLI_SKIP_BINARIES="$SKIP_BINARIES"
if [ -f "$OPTIONS_FILE" ]; then
  . "$OPTIONS_FILE"
fi
# CLI flag overrides file; default to 0 if unset
if [ -n "$CLI_SKIP_BINARIES" ]; then
  SKIP_BINARIES="$CLI_SKIP_BINARIES"
fi
: "${SKIP_BINARIES:=0}"
# Persist
cat > "$OPTIONS_FILE" <<EOF
SKIP_BINARIES=$SKIP_BINARIES
EOF

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
if command -v delta >/dev/null; then
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

git_update https://github.com/romkatv/powerlevel10k.git "$HOME/.local/share/powerlevel10k"
git_update https://github.com/Aloxaf/fzf-tab "$HOME/.local/share/fzf-tab"

# direnv
if [ "$SKIP_BINARIES" != "1" ] && [ ! -f "$HOME/bin/direnv" ]; then
  echo "  Downloading direnv..."
  curl -fsSL "https://direnv.net/install.sh" | bash
fi
warn_missing direnv "https://direnv.net/docs/installation.html"

# fzf-git
if [ ! -f "$HOME/bin/pkgs/fzf-git/fzf-git.sh" ]; then
  echo "  Downloading fzf-git.sh..."
  mkdir -p "$HOME/bin/pkgs/fzf-git"
  curl -fsSL "https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh" -o "$HOME/bin/pkgs/fzf-git/fzf-git.sh"
else
  echo "  fzf-git.sh already installed"
fi

# mise
if [ "$SKIP_BINARIES" != "1" ]; then
  if ! command -v mise >/dev/null; then
    echo "  Installing mise..."
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # use mise to install dependencies
  if ! command -v fzf >/dev/null; then
    mise install fzf
  fi
  if ! command -v zoxide >/dev/null; then
    mise install zoxide
  fi
fi

# zoxide — one-time import from fasd/autojump if zoxide db is empty
if command -v zoxide >/dev/null; then
  zoxide_db="${XDG_DATA_HOME:-$HOME/.local/share}/zoxide/db.zo"
  if [ ! -f "$zoxide_db" ] || [ ! -s "$zoxide_db" ]; then
    autojump_db="$HOME/.local/share/autojump/autojump.txt"
    fasd_db="$HOME/.fasd"
    if [ -s "$autojump_db" ]; then
      echo "  Importing autojump database into zoxide..."
      zoxide import --from=autojump "$autojump_db"
    elif [ -s "$fasd_db" ]; then
      echo "  Importing fasd database into zoxide..."
      zoxide import --from=z "$fasd_db"
    fi
  fi
fi

warn_missing fzf "https://github.com/junegunn/fzf#installation"
warn_missing zoxide "https://github.com/ajeetdsouza/zoxide#installation"

# --- Misc setup ---

mkdir -p "$HOME/tmp"

# Disable brew analytics on macOS
if command -v brew >/dev/null; then
  brew analytics off
fi

echo ""
echo "Setup complete!"
echo "Open a new shell to start using your dotfiles."
