# Example: Code Scaffolding Skill

## Use Case

Generate boilerplate for a new entity/component/module in a specific tech stack, following the project's existing conventions rather than generic templates.

## Folder Structure

```
gen-<thing>/
├── SKILL.md                  # Detect stack → find reference → generate
├── gotchas.md                # Stack-specific pitfalls
├── references/
│   ├── layer-anatomy.md      # What layers to generate per stack
│   └── naming-rules.md       # Naming derivation per language
└── examples/
    ├── backend.md            # Generic backend layer pseudocode
    └── frontend.md           # Generic frontend layer pseudocode
```

## Key Pattern: Reference Entity Discovery

The most effective scaffolding skills don't use static templates. Instead:

1. **Detect** the project's tech stack from config files (package.json, pyproject.toml, etc.)
2. **Find** the simplest existing entity of the same type (the "reference entity")
3. **Read** the reference entity's full implementation across all layers
4. **Generate** the new entity by replicating those exact patterns

This adapts to any project's conventions without hardcoded templates. It also evolves as the project evolves — no template maintenance needed.

## SKILL.md Excerpt

```yaml
---
name: gen-<thing>
description: Generate a full [thing] following project conventions. Detects tech stack and replicates existing patterns. Use when adding a new [thing] to the project.
---
```

**Phase 0 — Detect Project Stack**
Read config files to determine language, framework, and project structure. Identify where each layer lives (routes, services, repositories, models, tests).

**Phase 1 — Find Reference Entity**
Find the simplest existing implementation of the same type. Prefer entities with:
- Few fields (easy to understand)
- Standard CRUD operations (no special logic)
- Full layer coverage (all layers implemented)

**Phase 2 — Parse Entity Definition**
Understand the user's new entity: name, fields, relationships, any special behavior.

**Phase 3 — Generate Each Layer**
Read the reference entity's implementation for each layer, then generate the equivalent for the new entity. Adapt naming conventions, imports, and patterns.

**Phase 4 — Update Registration Files**
Update dependency injection, route registration, test fixtures, and any other files that need to know about the new entity.

**Phase 5 — Verify + Summary**
Run linter and type checker. Print a summary of all generated files.

## Why This Works

- No template maintenance — the codebase IS the template
- Automatically follows whatever conventions the team has adopted
- Handles edge cases that static templates miss (custom base classes, middleware, etc.)
- New team members get code that looks like it was written by the team
