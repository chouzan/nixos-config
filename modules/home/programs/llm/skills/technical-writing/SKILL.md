---
name: technical-writing
description: >-
  Write or review technical documentation with clear, consistent language. Use
  for README files, guides, runbooks, architecture and API documentation,
  module documentation, code comments, docstrings, configuration comments,
  migration notes, and similar documentation artifacts. Do not use for
  version-control change descriptions or commit messages.
---

# Technical Writing

Requirement keywords in capitals follow BCP 14 (RFC 2119, RFC 8174). Lowercase
forms of these words state no requirement. When a document states requirements,
use BCP 14 keywords for the requirement levels.

Apply repository rules first. A repository rule or an explicit user instruction
MAY replace a rule in this skill. Otherwise these rules are the minimum for
documentation. If a repository rule and a user instruction conflict, you MUST
state the conflict before you write. Another skill MAY set the voice, but MUST
NOT relax these rules.

Match the needs of the intended reader.

Here, review means review the documentation. It does not mean review the
implementation.

## Inspect the subject

You MUST read the implementation, configuration, or interface before you write.
You MUST confirm behavior against the source rather than from assumption or
memory.

## Make documentation independent

Documentation:

- MUST preserve exact commands, identifiers, paths, code, and quoted output.
- MUST be context-free and stand-alone within its declared scope.
- MUST NOT rely on a conversation, implementation session, or undocumented
  prior decision.
- MUST NOT use references such as "as discussed", "the current work", or
  "the earlier change".
- SHOULD treat the enclosing document, module, and repository as established
  context, and SHOULD NOT repeat what this context states clearly.
- SHOULD state only the purpose, boundaries, assumptions, constraints,
  trade-offs, prerequisites, and expected results that the reader needs.

## Use clear technical English

Apply the general principles of ASD-STE100 Simplified Technical English.

Documentation:

- MUST use one term for one meaning, and MUST NOT vary terms only for style.
- MUST define uncommon abbreviations and project-specific terms at first use.
- MUST replace ambiguous pronouns and references with explicit nouns.
- SHOULD use short, direct sentences.
- SHOULD put one instruction or main point in each sentence.
- SHOULD use active voice, and the imperative form for procedures.
- SHOULD separate requirements, procedures, results, notes, warnings, and
  examples.
- SHOULD use established technical names and technical verbs consistently.

These principles alone do not make text ASD-STE100 compliant. Strict compliance
needs the official rules, the controlled dictionary, and a validator. If a task
requires it, read `https://www.asd-ste100.org/` first and state what you could
not verify.

## Structure for the reader

Documentation:

- MUST follow repository rules for line length, markup, and generated
  documentation.
- SHOULD use exactly one Diátaxis mode for each document: tutorial, how-to
  guide, reference, or explanation. See `https://diataxis.fr/`.
- SHOULD put the purpose and outcome before implementation detail.
- SHOULD use headings that identify their content.
- SHOULD use numbered steps for sequences, and bullets for unordered items.
- SHOULD keep related information together.
- SHOULD put an example next to the rule or behavior that it demonstrates.

## Use reserved and standard values

When an example needs a domain name or an IP address, the example MUST use a
value that is reserved for documentation:

- `example.com`, `example.net`, `example.org`, and the `.test`, `.example`,
  `.invalid`, and `.localhost` top-level domains (RFC 2606)
- `192.0.2.0/24`, `198.51.100.0/24`, and `203.0.113.0/24` (RFC 5737)
- `2001:DB8::/32` (RFC 3849)

A timestamp that the documentation states itself MUST use RFC 3339, such as
`2026-08-13` or `2026-08-13T09:30:00+07:00`. Quoted output keeps the format of
the source.

## Review the documentation

You MUST check documentation against the implementation and other authoritative
sources, and verify technical accuracy, required context, terminology, sequence,
and expected results. You MUST remove stale claims and conversation-dependent
wording. You MUST NOT change implementation behavior during a documentation-only
task.
