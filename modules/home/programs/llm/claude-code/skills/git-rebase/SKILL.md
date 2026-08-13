---
name: git-rebase
description: Apply when modifying commits that aren't HEAD - fixup, squash, reword older commits, or rebase branches. Use for non-interactive rebase workflows.
---

# Git Rebase

## Rebasing to Main

```bash
git fetch origin
git rebase origin/main
```

## Autosquash (Non-Interactive)

Create fixup commit for content changes, then autosquash:
```bash
git commit --fixup=<sha>
GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <sha>^
```

`GIT_SEQUENCE_EDITOR=:` accepts the default todo - use when todo is already correct.

## Reword Commit Message

Change older commit's message (no content changes):
```bash
GIT_SEQUENCE_EDITOR='sed -i "/^pick <sha>/a exec git commit --amend -m \"New message\""' git rebase -i <sha>^
```

For multiline messages, write to a file and use `-F`:
```bash
cat > /tmp/commit-msg.txt <<'EOF'
Title

Body with proper formatting.
- bullet points
- work correctly
EOF
GIT_SEQUENCE_EDITOR='sed -i "/^pick <sha>/a exec git commit --amend -F /tmp/commit-msg.txt"' git rebase -i <sha>^
```

Note: Multiple `-m` flags create separate paragraphs with blank lines between them - avoid for formatted messages.

## Squashing Commits

Squash last N commits:
```bash
GIT_SEQUENCE_EDITOR="sed -i '2,\$s/^pick/squash/'" git rebase -i HEAD~N
```

## Stacked Branches

Rebase entire stack with `--update-refs`:
```bash
git rebase origin/main --update-refs
git push --force-with-lease origin branch-a branch-b branch-c
```

For conflict handling and advanced patterns, see [references/rebase.md](references/rebase.md).
