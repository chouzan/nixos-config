---
name: skill-creator
description: Guide for creating effective skills. Use when creating a new skill or updating an existing skill that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.
---

# Skill Creator

## About Skills

Skills are modular, self-contained packages that extend Claude's capabilities by providing specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific domains or tasks.

### What Skills Provide

1. **Specialized workflows** - Multi-step procedures for specific domains
2. **Tool integrations** - Instructions for working with specific file formats or APIs
3. **Domain expertise** - Company-specific knowledge, schemas, business logic
4. **Bundled resources** - Scripts, references, and assets for complex and repetitive tasks

## Core Principles

### Concise is Key

Context window is shared with everything else. **Claude is already very smart.** Only add context Claude doesn't already have.

Challenge each piece: "Does Claude really need this?" and "Does this justify its token cost?"

Prefer concise examples over verbose explanations.

### Degrees of Freedom

Match specificity to task fragility:

- **High freedom** (text guidelines): Multiple valid approaches, context-dependent decisions
- **Medium freedom** (pseudocode/parameters): Preferred pattern exists, some variation OK
- **Low freedom** (specific scripts): Fragile operations, consistency critical

Think of Claude as exploring a path: a narrow bridge with cliffs needs specific guardrails (low freedom), while an open field allows many routes (high freedom).

### Progressive Disclosure

Skills use a three-level loading system:

1. **Metadata** (name + description) - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words, aim for <500 lines)
3. **Bundled resources** - As needed (unlimited, scripts can execute without loading)

## Skill Structure

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/      - Executable code (Python/Bash/etc.)
    ├── references/   - Documentation loaded as needed
    └── assets/       - Files for output (templates, icons, etc.)
```

### Frontmatter

```yaml
---
name: skill-name
description: What it does AND when to use it. This is the trigger mechanism.
---
```

- `description` is the primary triggering mechanism
- Include both what the skill does and specific triggers/contexts
- Do NOT put "when to use" in the body - it's only loaded after triggering

### Body

- Under 500 lines
- Imperative/infinitive form ("Create...", "Use...", not "Creating...", "You should...")
- Examples over explanations

### Resources

#### scripts/

Executable code for tasks requiring deterministic reliability or repeatedly rewritten.

- **When to include**: Same code rewritten repeatedly, or deterministic reliability needed
- **Example**: `scripts/rotate_pdf.py` for PDF rotation tasks
- **Benefits**: Token efficient, deterministic, may execute without loading into context
- **Note**: Scripts may still need to be read for patching or environment-specific adjustments

#### references/

Documentation loaded as needed into context.

- **When to include**: Documentation Claude should reference while working
- **Examples**: `references/schema.md` for database schemas, `references/api_docs.md` for API specs
- **Use cases**: Database schemas, API documentation, domain knowledge, company policies
- **Best practice**: For files >10k words, include grep search patterns in SKILL.md
- **Avoid duplication**: Information lives in SKILL.md OR references, not both

#### assets/

Files used in output, not loaded into context.

- **When to include**: Files used in final output
- **Examples**: `assets/logo.png`, `assets/template.pptx`, `assets/frontend-template/`
- **Use cases**: Templates, images, icons, boilerplate code, fonts

## What NOT to Include

- README.md, CHANGELOG.md, or auxiliary docs
- Setup/installation instructions
- User-facing documentation
- Process documentation

The skill is for an AI agent to do the job - nothing else.

## Progressive Disclosure Patterns

Keep SKILL.md lean. Move variant-specific details into reference files.

### Pattern 1: High-level guide with references

```markdown
# PDF Processing

## Quick start
Extract text with pdfplumber:
[code example]

## Advanced features
- **Form filling**: See [references/forms.md]
- **API reference**: See [references/api.md]
```

### Pattern 2: Domain-specific organization

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── references/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    └── product.md (API usage, features)
```

When user asks about sales metrics, Claude only reads sales.md.

### Pattern 3: Framework/variant organization

```
cloud-deploy/
├── SKILL.md (workflow + provider selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

When user chooses AWS, Claude only reads aws.md.

**Guidelines:**
- Keep references one level deep from SKILL.md
- For files >100 lines, include table of contents at top

## Creation Process

### Step 1: Understand with Concrete Examples

Gather concrete examples of how the skill will be used. Example questions:

- "What functionality should this skill support?"
- "Can you give examples of how this would be used?"
- "What would a user say that should trigger this skill?"

Conclude when there's a clear sense of the functionality the skill should support.

### Step 2: Plan Reusable Contents

For each example, analyze:
1. How to execute from scratch
2. What scripts, references, and assets would help when executing repeatedly

**Example**: Building a `pdf-editor` skill for "Help me rotate this PDF":
- Rotating requires rewriting the same code each time
- Solution: `scripts/rotate_pdf.py`

**Example**: Building a `big-query` skill for "How many users logged in today?":
- Querying requires rediscovering table schemas each time
- Solution: `references/schema.md`

### Step 3: Implement

1. Create the skill directory with SKILL.md
2. Implement identified resources (scripts/, references/, assets/)
3. Test scripts by actually running them
4. Write SKILL.md with proper frontmatter and instructions

**Design pattern references:**
- [references/workflows.md](references/workflows.md) - Sequential and conditional workflow patterns
- [references/output-patterns.md](references/output-patterns.md) - Template and example patterns for consistent output

### Step 4: Iterate

1. Use the skill on real tasks
2. Notice struggles or inefficiencies
3. Update SKILL.md or bundled resources
4. Test again
