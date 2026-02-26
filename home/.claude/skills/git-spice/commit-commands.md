# Commit Commands

## gs commit create (`gs cc`)

Create a new commit and automatically restack upstack branches.

Flags: `-m` (message), `-a` (stage tracked files), `--fixup`, `--allow-empty`, `--no-verify`

## gs commit amend (`gs ca`)

Amend the topmost commit. Auto-restacks upstack branches.

Flags: `-a`, `-m`, `--no-edit`, `--allow-empty`

## Simple commands

| Command | Notes |
|---|---|
| `gs commit split` | Interactively split a commit. Launches interactive rebase |
| `gs commit fixup` | Apply staged changes as fixup to earlier commit (experimental, requires `commitFixup`) |
| `gs commit pick` | Cherry-pick from other branches with auto-restacking (experimental, requires `commitPick`) |
