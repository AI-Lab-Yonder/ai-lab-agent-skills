# Skill Folder Anatomy

Guide to structuring a Claude Code skill folder. Every skill is a folder, not a single file.

---

## Minimal Skill (any category)

```
my-skill/
├── SKILL.md        # Required: frontmatter + description + constraints + phases
└── gotchas.md      # Recommended: known failure points
```

Use for simple skills that encode a single workflow with few edge cases.

## Standard Skill

```
my-skill/
├── SKILL.md
├── gotchas.md
├── references/     # Detailed knowledge Claude reads on-demand
│   └── *.md
└── config.json     # Optional: user-specific setup state
```

Use when the skill needs domain knowledge beyond what fits in SKILL.md.

## Rich Skill (scaffolding, verification, infrastructure)

```
my-skill/
├── SKILL.md
├── gotchas.md
├── references/     # Domain knowledge, API docs, symptom maps
│   └── *.md
├── templates/      # File templates with placeholders
│   └── *.tmpl
├── scripts/        # Executable helpers (bash, python, etc.)
│   └── *.sh / *.py
├── examples/       # Reference implementations
│   └── *.md
└── config.json     # Setup state
```

Use when the skill generates files, runs automation, or handles complex multi-step workflows.

---

## SKILL.md Anatomy

```markdown
---
name: kebab-case-name
description: Action verb + what + trigger condition. Under 200 chars.
version: 1.0.0
level: beginner
category: documentation
---

# Skill Name

Brief overview (2-3 sentences). What does this skill do and why does it exist?

## Constraints

- Hard rules the skill must follow
- What it must NOT do
- Dependencies it requires

## Phase 0 — [First Phase Name]

What happens in this phase. Reference sub-files:
"Read `references/X.md` for detailed information about Y."

## Phase 1 — [Second Phase Name]
...

## Phase N — Summary & Next Steps

Print results and suggest what to do next.
```

### Frontmatter Fields

| Field | Required | Notes |
|-------|----------|-------|
| `name` | Yes | kebab-case, verb-noun preferred |
| `description` | Yes | Trigger condition, not summary. Under 200 chars. |
| `version` | Yes | semver, start at 1.0.0 |
| `level` | Yes | `beginner` or `advanced` |
| `category` | Yes | One of `ai`, `architecture`, `backend`, `code-quality`, `database`, `debugging`, `documentation`, `frontend`, `fullstack`, `meta`, `security`, `testing` |

### Sections

**Constraints**: Hard rules. What the skill must NOT do. What assumptions it makes. What it requires to be installed/available.

**Phases**: The skill's workflow broken into logical steps. Each phase should:
- Have a clear purpose (one concern per phase)
- Reference sub-files for detailed knowledge
- Allow Claude flexibility in execution
- Include user checkpoints where decisions are needed

---

## Naming Conventions

| Item | Convention | Examples |
|------|-----------|----------|
| Skill name | kebab-case, verb-noun preferred | `gen-crud-slice`, `verify-signup`, `deploy-service` |
| SKILL.md | Always capitalized | `SKILL.md` |
| References | Descriptive, kebab-case | `api-reference.md`, `symptom-map.md` |
| Templates | Match output file name + `.tmpl` | `SKILL.md.tmpl`, `migration.sql.tmpl` |
| Scripts | Match purpose | `run-tests.sh`, `fetch-data.py` |
| Gotchas | Always `gotchas.md` | `gotchas.md` |
| Config | Always `config.json` | `config.json` |

---

## Where to Install

| Location | Scope | Shared via | Use for |
|----------|-------|-----------|---------|
| `~/.claude/skills/` | Global (all projects) | Manual copy | Workflow automation, code quality, CI/CD |
| `.claude/skills/` | Project (one repo) | Git | Codebase-specific scaffolding, internal APIs |

**Decision guide**:
- Is this useful across multiple projects? → Global
- Does it reference project-specific patterns, APIs, or conventions? → Project
- Should teammates have it automatically? → Project (committed to git)
- Is it personal workflow automation? → Global

---

## Progressive Disclosure Pattern

SKILL.md should be a **table of contents** that points to detailed sub-files, not a monolith.

```markdown
## Phase 2 — Generate the API Layer

Read `references/api-patterns.md` for the endpoint conventions used in this project.
Use `templates/route.py.tmpl` as the starting template for new routes.

Generate the route handler, service function, and repository method.
```

This way, Claude only loads `api-patterns.md` and `route.py.tmpl` when it reaches Phase 2 — not upfront.
