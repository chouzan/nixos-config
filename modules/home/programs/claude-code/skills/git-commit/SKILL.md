---
name: git-commit
description: Apply when committing changes or writing commit messages.
---

# Git Commit

## Commit Messages

1. Check branch for issue prefix:
```bash
git branch --show-current
```
Extract `PREFIX-NUMBER` (e.g., `JIRA-123`, `GH-456`) → prepend as `[PREFIX-NUMBER]`

2. If user provides PR ID (#XXX), append it.

3. Rules:
   - Imperative mood ("Add" not "Added")
   - Stand-alone without conversation context
   - Never add Co-authored-by attribution
   - Body only when explaining "why" beyond subject

**Input:** Branch `JIRA-1234/add-auth`, added JWT login
**Output:**
```
[JIRA-1234] Add JWT authentication flow

Implement login endpoint with token validation middleware.
```

**Input:** Branch `feat/dark-mode`, added theme toggle, PR #567
**Output:**
```
Add dark mode theme toggle (#567)
```
