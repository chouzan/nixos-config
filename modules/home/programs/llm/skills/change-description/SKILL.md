---
name: change-description
description: >-
  Write or review version-control change descriptions and commit messages using
  repository conventions. Use when setting, updating, or checking a Jujutsu
  description, drafting a Git commit message, or deciding whether an existing
  description still matches its diff, including when another message-generation
  skill is active. Do not use for documentation, code comments, or general code,
  diff, or pull-request review.
---

# Change Description

Requirement keywords in capitals follow BCP 14 (RFC 2119, RFC 8174). Lowercase
forms of these words state no requirement.

Apply repository rules first. A repository rule or an explicit user instruction
MAY replace a rule in this skill. Otherwise these rules are the minimum for a
change description. If a repository rule and a user instruction conflict, you
MUST state the conflict before you write. Another skill MAY set the voice, but
MUST NOT relax these rules.

Here, review means review the change description or commit message. It does not
mean review the implementation.

## Inspect the change

You MUST read the complete diff and the existing description before you write.

## Write the description

The description:

- MUST describe only the final effect of the diff.
- MUST have a context-free, stand-alone title and body.
- MUST have a brief, imperative title.
- MUST keep every line at 80 characters or fewer.
- MUST NOT narrate the implementation session.
- MUST NOT list mechanical edits.
- MUST NOT restate general project context.
- MUST NOT contain AI attribution.
- MUST NOT use a Conventional Commits prefix.
- MUST NOT use phrases such as "this change", "current", or "previous" when
  their meaning depends on conversation context.
- SHOULD use short sentences and active voice in the body.
- SHOULD rely on established repository terms when their meaning is clear.
- SHOULD have a body only when the reason, scope, or important behavior is not
  clear from the title.
- SHOULD state a boundary, assumption, constraint, or trade-off only when the
  reader needs it to understand the change.

## Do not add external references

The description MUST NOT contain an issue or pull-request reference. This rule
covers every form that GitHub can link or use as an action:

- `#123`, `GH-123`, and `owner/repository#123`
- `Fixes`, `Closes`, `Resolves`, `Refs`, and similar reference trailers
- GitHub issue or pull-request URLs

A necessary upstream reference SHOULD stay in a relevant code comment.

## Apply and verify the description

For Jujutsu, set the description with `jj describe`. For Git, set the message
with `git commit` or `git commit --amend`.

You MUST read the result back and confirm that it matches the diff, stands
alone, respects the line limit, and contains no external reference.
