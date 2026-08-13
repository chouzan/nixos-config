# Rebase Reference

## Conflict Handling

Identify potential conflicts before rebasing:
```bash
comm -12 \
  <(git diff --name-only origin/main...HEAD | sort) \
  <(git diff --name-only HEAD...origin/main | sort)
```

During resolution:
```bash
git checkout --theirs <file>    # accept main's version
git checkout --ours <file>      # accept branch's version
git add <resolved-files>
git rebase --continue
git rebase --abort              # if needed
```

## Fixup Markers

`--fixup=<sha> -m "dev note"` adds a note that gets discarded on autosquash.

Note: `--fixup=amend:<sha>` and `--fixup=reword:<sha>` open editors - not suitable for non-interactive workflows.

## Content + Message Changes

Use `--squash` with `GIT_EDITOR` to set final message:
```bash
git commit --squash=<sha> -m "note"
GIT_EDITOR='printf "%s\n\n%s" "Title" "Body" >' GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <sha>^
```

## Sed Patterns

```bash
# Squash all except first
GIT_SEQUENCE_EDITOR="sed -i '2,\$s/^pick/squash/'" git rebase -i HEAD~N

# Drop commit
GIT_SEQUENCE_EDITOR="sed -i '/^pick <sha>/d'" git rebase -i HEAD~N

# Reword via exec (message only, no content)
GIT_SEQUENCE_EDITOR='sed -i "/^pick <sha>/a exec git commit --amend -m \"msg\""' git rebase -i <sha>^

# Reword with multiline message (use -F to preserve formatting)
GIT_SEQUENCE_EDITOR='sed -i "/^pick <sha>/a exec git commit --amend -F /tmp/commit-msg.txt"' git rebase -i <sha>^
```

## Stacked Branches Example

```bash
git checkout -b feature-a main   # commits...
git checkout -b feature-b        # commits...
git checkout -b feature-c        # commits...

git rebase origin/main --update-refs
git push --force-with-lease origin feature-a feature-b feature-c
```
