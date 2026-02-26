---
name: git-spice
description: Stacked Git branch management CLI (gs). Covers stacks, restacking, CRs, all gs commands, configuration, and internals. Use when the user mentions gs commands, stacked branches, restacking, submitting PRs from a stack, rebasing branches, creating or managing commits with gs, or navigating a branch stack.
user-invokable: false
---

# git-spice

CLI tool for managing stacked Git branches and Change Requests (GitHub PRs / GitLab MRs). Written in Go, requires Git 2.38+.

## Core Concepts

- **Stack**: Branches layered on each other; each (except trunk) has a base branch.
- **Trunk**: Default branch (main/master) — no base.
- **CR (Change Request)**: Unified term for PRs and MRs.
- **Restacking**: Rebasing a branch onto its base after divergence.
- **Upstack / Downstack**: Branches above / below current branch in the stack.

## Design Principles

- **Offline-first** — auth only needed for remote operations.
- **One CR per branch** — not per commit. Allows appending review fixes.
- **Git plumbing directly** — no third-party Git libraries. Reliable with worktrees, sparse-checkout, sparse indexes.
- **Idempotent submission** — `submit` creates or updates CRs.

## Storage

Data lives in Git ref `refs/spice/data`. Inspect with `git log --patch refs/spice/data`. Structure: `repo`, `templates`, `rebase-continue`, `branches/<name>`, `prepared/<name>`.

## Command Reference

For detailed commands by category, see:

- **[branch-commands.md](branch-commands.md)** — create, track, checkout, delete, rename, restack, split, fold, onto, submit
- **[stack-commands.md](stack-commands.md)** — navigation (up/down/top/bottom), stack/upstack/downstack submit, restack, sync
- **[commit-commands.md](commit-commands.md)** — create, amend, split, fixup, pick

## Workflow Examples

For command sequences showing how gs commands chain together, see [examples.md](examples.md):

- **Single-branch PR**: create, commit, submit, rebase after sync
- **Stacked PRs**: multi-branch stack, navigation, amend mid-stack, submit all
