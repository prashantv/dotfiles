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

This requires an SSH key to be setup, and added to GitHub,
 * `ssh-keygen`, then get the key, `cat ~/.ssh/id_rsa.pub` 
 * Add to [GitHub](https://github.com/settings/ssh/new).

## Dependencies

* curl (for any install)
* git + ssh key added to GitHub (for writable clone)

## Tips
- Pass `--branch <branch>` to to initialize from a specific branch (useful when developing).
- [GitHub SSH Key Management](https://github.com/settings/keys)
- Install `zsh` and change shell using `chsh`.


## Quick testing on ephemeral Debian instance

```bash
$ sudo apt update && sudo apt --yes install git-core curl zsh
$ ssh-keygen
$ cat ~/.ssh/id_rsa.pub

## Open https://github.com/settings/keys and copy above key

$ sh -c "$(curl -fsLS chezmoi.io/get)" -- init --branch dev --ssh --apply prashantv

$ sudo chsh $(whoami) --shell $(which zsh)

## Restart shell to open up zsh
```

## Download GitHub SSH keys to authorized keys
```
$ mkdir -p ~/.ssh && curl https://github.com/prashantv.keys | tee -a ~/.ssh/authorized_keys
```
