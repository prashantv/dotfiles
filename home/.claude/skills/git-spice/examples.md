# Examples

## Typical workflows

Create a branch, do work, submit a PR — git-spice works fine without stacks:

```bash
gs bc foo -m "foo"   # create branch + initial commit (any staged changes or empty).
# ... git operations as usual, like `git add` ...
gs cc -m "fix"       # commit (no restack needed — nothing upstack)
gs bs                # create a PR, prompts for title & body.
```

Keeping up with the latest trunk changes or after PRs are merged:

```bash
gs repo sync      # update trunk, delete merged branches
gs br             # rebase current branch onto updated trunk
gs bs             # update the PR
```

## Workflows with stacked PRs

Build features off an existing branch:

```bash
# work off an existing submitted branch
gs bco base
gs bc add-api -m "add API"
# ... work ...
gs cc -m "Implement handler"

# rebase and submit branch once ready
gs br
gs bs
```

If there's feedback on the PR off `base`,

```bash
# navigate down to the branch below.
gs down
# ... fix review feedback ...
gs cc -m "fix"
# ... another related fix ...
gs ca     # Note: This will open an editor.
gs bs

# or to update all PRs in the stack
gs ss
```

After trunk moves forward:

```bash
gs repo sync
gs stack restack   # rebase all branches in the stack.
gs ss
```
