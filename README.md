# prashantv's dotfiles

## Install

Fresh install (no git required):
```bash
curl -fsSL https://raw.githubusercontent.com/prashantv/dotfiles/main/setup.sh | bash
```

With git (clones via SSH for a writable clone):
```bash
curl -fsSL https://raw.githubusercontent.com/prashantv/dotfiles/main/setup.sh | bash -s -- --git
```

From an existing clone:
```bash
./setup.sh
```

### Options

```
  --branch NAME      Branch to use (default: main)
  --git              Clone via SSH instead of downloading tarball
  --profile NAME     Machine profile for zshrc_local (default: hostname)
  --dir PATH         Install directory (default: ~/dotfiles)
```

To test a branch on a clean VM:
```bash
curl -fsSL https://raw.githubusercontent.com/prashantv/dotfiles/<branch>/setup.sh | bash -s -- --branch <branch>
```

## How it works

- Files in `home/` are symlinked to `~/`, so edits in the repo immediately take effect.
- Machine-specific config lives in `profiles/<name>/zshrc_local`, selected via `--profile`.
- External dependencies (zprezto, fzf-tab, direnv, fasd, fzf-git, mise) are installed automatically.
- `~/.gitconfig_delta` is generated with delta config if delta is available.

## Dependencies

- curl (for any install)
- git (for `--git` mode and external dependency cloning)

## Tips

- Install `zsh` and change shell: `chsh -s $(which zsh)`
- [GitHub SSH Key Management](https://github.com/settings/keys)

## Download GitHub SSH keys to authorized keys
```bash
mkdir -p ~/.ssh && curl https://github.com/prashantv.keys | tee -a ~/.ssh/authorized_keys
```
