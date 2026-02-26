# Branch Commands

## gs branch create (`gs bc`)

Create, commit, and track a new branch in one step.

The branch can be specified as an argument, or is auto-inferred from the message.

Flags: `--insert`, `--below`, `--target`, `-a` (stage tracked files), `-m` (message)

## gs branch submit (`gs bs`)

Submit current branch as a CR. Idempotent - creates or updates.

Using `--title` with `--body`, or `--fill` (title & body from commit message) will create a CR
without any user interactive prompts, so verify the title and body first.

Flags: `--reviewers`, `--draft`, `--dry-run`, `--no-publish`, `--update-only`, `--label`, `--assignees`, `--web`, `--force`

## gs branch split

Split a branch into multiple branches. `--at` to specify commits, `--branch` to name new branches. Supports interactive and non-interactive modes.

## Simple commands

| Command | Shorthand | Notes |
|---|---|---|
| `gs branch track` | `gs btr` | Track an existing branch. `--base` to set base |
| `gs branch untrack` | - | Stop tracking without deleting |
| `gs branch checkout` | `gs bco` | Interactive picker if no name given. `-u` to show untracked |
| `gs branch delete` | - | Handles upstack relinking. `--force` for unmerged |
| `gs branch rename` | - | |
| `gs branch restack` | `gs br` | Rebase single branch onto its base |
| `gs branch onto` | - | Relocate to a new base, preserving upstack |
| `gs branch fold` | - | Fold commits into base branch |
| `gs branch squash` | - | Squash all commits into one. `-m`, `--no-edit` |
| `gs branch edit` | - | Interactive rebase of commits within branch |

Note: Only frequently used shorthands are included above.