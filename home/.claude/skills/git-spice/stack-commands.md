# Stack, Navigation, and Repo Commands

## Navigation

| Command | Purpose |
|---|---|
| `gs up [N]` | Move up N branches in the stack |
| `gs down [N]` | Move down N branches |
| `gs top` | Jump to top of stack |
| `gs bottom` | Jump to bottom of stack |
| `gs trunk` | Check out trunk branch |

All support `--dry-run` and `--detach`.

## Stack Commands

| Command | Shorthand | Purpose |
|---|---|---|
| `gs stack submit` | `gs ss` | Submit entire stack as CRs |
| `gs stack restack` | - | Rebase all branches in the stack. `--branch` to pick starting branch |
| `gs stack edit` | - | Reorder/drop branches in an editor. `--editor`, `--branch` |
| `gs stack delete` | - | Delete all branches in the stack. Requires `--force` |

## Upstack Commands

| Command | Shorthand | Purpose |
|---|---|---|
| `gs upstack submit` | `gs uss` | Submit current + upstack branches |
| `gs upstack restack` | - | Rebase current branch and everything above it. `--skip-start`, `--branch` |
| `gs upstack onto [<onto>]` | - | Relocate current branch and its upstack to a new base |
| `gs upstack delete` | - | Delete all branches above current. Requires `--force` |

## Downstack Commands

| Command | Shorthand | Purpose |
|---|---|---|
| `gs downstack submit` | `gs dss` | Submit current + downstack branches |
| `gs downstack edit` | - | Reorder downstack branches in an editor |
| `gs downstack track [<branch>]` | - | Track an existing stack from topmost branch down |

All submission is idempotent. Navigation comments are added to CRs automatically.

## Restacking

| Command | Scope |
|---|---|
| `gs branch restack` | Single branch |
| `gs upstack restack` | Current + upstack |
| `gs stack restack` | Entire stack |
| `gs repo restack` | All tracked branches in dependency order |

## Repository

| Command | Purpose |
|---|---|
| `gs repo init` | Initialize git-spice (trunk branch, optional remote). `--reset` to discard data |
| `gs repo sync` | Pull latest trunk, delete branches with merged CRs. `--restack` to restack after |
| `gs repo restack` | Rebase all tracked branches maintaining linear history |

## Logging

| Command | Shorthand | Purpose |
|---|---|---|
| `gs log short` | `gs ls` | List branches in stack |
| `gs log long` | `gs ll` | List branches with commits |

Both support `-a/--all`, `-S/--cr-status`, `--json`. JSON output goes to stdout.

## Rebase Recovery

- `gs rebase continue` - resume interrupted operations. `--edit` to open editor
- `gs rebase abort` - cancel ongoing operations
