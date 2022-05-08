# prashantv's dotfiles

This repo uses [chezmoi](https://www.chezmoi.io/) to manage my dotfiles.

## Install

For a read-only copy:
```bash
$ sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply prashantv
```

For a git clone that can be used for pushes:
```bash
$ sh -c "$(curl -fsLS chezmoi.io/get)" -- init --ssh --apply prashantv
```

## Dependencies

* curl (for any install)
* git + ssh key added to GitHub (for writable clone)

## Tips
- Pass `--branch <branch>` to to initialize from a specific branch (useful when developing).
- [GitHub SSH Key Management](https://github.com/settings/keys)


