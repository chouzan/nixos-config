---
name: skill-creator
description: >-
  Create or review an agent skill that follows the conventions of this
  repository. Use when adding a skill, changing an existing SKILL.md or its
  frontmatter, or checking whether a skill follows the conventions. Do not use
  for version-control change descriptions or code review.
---

# Skill Creator

Requirement keywords in capitals follow BCP 14 (RFC 2119, RFC 8174). Lowercase
forms of these words state no requirement.

Apply repository rules first. A repository rule or an explicit user instruction
MAY replace a rule in this skill. Otherwise these rules are the minimum for a
skill. If a repository rule and a user instruction conflict, you MUST state the
conflict before you write. Another skill MAY set the voice, but MUST NOT relax
these rules.

Here, review means review the skill. It does not mean review the subject that
the skill covers.

## Inspect the need

You MUST collect concrete examples of the task before you write. Establish what
the task covers, what a user says that starts the task, and what a correct
result looks like.

You MUST read the description of every sibling skill, so that the new
description can exclude the subjects that they own.

## Know how a skill loads

A skill loads in three levels:

1. The name and the description stay in context for every session.
2. The body loads when the description matches the task.
3. A bundled file loads only when the skill reads it.

Only the description decides whether a skill loads, so the description carries
the whole trigger. A rule in the body routes nothing.

## Write the frontmatter

The description:

- MUST state what the skill does, when to use it, and what not to use it for.
- MUST exclude a subject that a sibling skill owns, so that two skills never
  state rules for the same aspect of one task.
- MUST NOT depend on the body to state when the skill applies.

## Write the body

A skill serves its task alone. Skills load independently, so a rule that lives
only in a sibling skill is a rule that the agent does not have, and the same
rule in a second skill is correct rather than duplication to remove.

Measure a rule against the task, never against what an agent already does.
Skills serve several agents, and one agent changes between versions, so a rule
left out because an agent happens to comply is a rule that the next agent
lacks.

Writing a skill is also a documentation task. This skill states only what a
skill needs beyond the documentation rules of this repository.

The body:

- MUST state every rule that the task of the skill needs.
- MUST order the sections as the work happens: inspect first, then write,
  then verify, with names that fit the subject.
- MUST put one main point in each bullet.
- MUST order bullets MUST, then MUST NOT, then SHOULD.
- MUST address the agent as "you" for an action, and name the artifact for a
  property of the result.
- MUST keep two clauses in one bullet when they can only be violated together,
  and split them when either one can be violated alone.
- MUST NOT state a rule for a subject that the skill does not own.
- MUST NOT state a requirement whose violation cannot be identified.
- SHOULD carry a lead-in that names the subject of a bulleted section, so that
  each bullet starts with its keyword.
- SHOULD stay under 500 lines.

## Write the header of a skill that states requirements

A skill that states requirement levels MUST open with these two paragraphs:

```markdown
Requirement keywords in capitals follow BCP 14 (RFC 2119, RFC 8174). Lowercase
forms of these words state no requirement.

Apply repository rules first. A repository rule or an explicit user instruction
MAY replace a rule in this skill. Otherwise these rules are the minimum for
<artifact>. If a repository rule and a user instruction conflict, you MUST
state the conflict before you write. Another skill MAY set the voice, but MUST
NOT relax these rules.
```

The skill MUST name its own artifact in place of `<artifact>`.

A skill that holds only a procedure or reference material MUST NOT include
these paragraphs, because they bind nothing there.

## Choose bundled resources

Put content in the body when the agent needs it for every task. Put content in
a bundled file when the agent needs it for some tasks:

- `scripts/` holds code that must run the same way each time, or that the agent
  would otherwise write again for each task.
- `references/` holds material that the agent reads while it works, such as a
  schema or an interface description.
- `assets/` holds files that appear in the result, such as a template.

Content MUST live in the body or in a bundled file, and MUST NOT live in both.

## Verify the skill

You MUST read the result back and confirm that the description alone routes the
task, that the skill states every rule it needs without a sibling skill, and
that each requirement level matches the cost of breaking the rule.

These rules govern this skill as well. When you change this skill, you MUST
check it against every rule that it states.

## Improve the skill

A rule earns its place from use, so a skill is not complete when it is written.

You MUST run the skill on a real task before you treat it as complete. When the
task needed a rule that the skill does not state, add that rule. When a rule
states something outside the task, or repeats another rule, remove it.
