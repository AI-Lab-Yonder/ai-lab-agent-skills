# AI Lab Agent Skills

A curated collection of agent skills for AI-powered development workshops. Designed for use with **Claude Code** and **Codex**.

## Quick Start

**Claude Code:**
```bash
# Install as Claude Code skill
claude install-skill /path/to/ai-lab-agent-skills
# Or copy skills/ into your project's .claude/skills/
```

**Codex:**
```bash
# Copy .codex/ config into your project
cp -r .codex/ /path/to/your-project/.codex/
# Skills are referenced from .codex/instructions.md
```

## Structure

```
ai-lab-agent-skills/
├── cheatsheet/                  # Quick reference for Claude Code & Codex
├── .claude/                       # Claude Code config
│   └── settings.json
├── .codex/                        # Codex config
│   ├── config.toml
│   └── instructions.md
├── skills/
│   ├── frontend-dev/              # Beginner - Build frontend apps
│   ├── fullstack-dev/             # Beginner - Full-stack development
│   ├── api-builder/               # Beginner - REST API design
│   ├── landing-page/              # Beginner - Quick landing pages
│   ├── bug-fixer/                 # Beginner - Systematic debugging
│   ├── test-writer/               # Beginner - Write tests
│   ├── docs-generator/            # Beginner - Generate documentation
│   ├── refactorer/                # Beginner - Code refactoring
│   ├── database-designer/         # Beginner - Schema & migrations
│   ├── auth-system/               # Beginner - Authentication & authorization
│   ├── tdd-workflow/              # Advanced - Full TDD cycle
│   ├── multi-agent-orchestrator/  # Advanced - Multi-agent workflows
│   ├── prompt-engineer/           # Advanced - Optimize AI prompts
│   ├── code-reviewer/             # Advanced - Security & quality review
│   ├── skill-creator/             # Advanced - Create new skills
│   ├── codex-review/              # Advanced - AI code review via Codex MCP
│   ├── pre-merge-review/          # Advanced - Multi-phase pre-merge pipeline
│   ├── skill-builder/             # Advanced - Create skills with templates & examples
│   ├── postmortem/                # Advanced - Capture lessons to gotchas.md
│   ├── autoresearch/              # Advanced - Auto-optimize skills with evals
│   ├── prune-gotchas/             # Advanced - Consolidate gotchas.md entries
│   ├── docs-scaffold/             # Advanced - Scaffold structured docs/ folder
│   ├── resolve-docs/              # Advanced - Resolve documentation gaps interactively
│   ├── spa-day/                   # Advanced - Rules & skills health audit
│   ├── adversarial-bug-hunt/      # Advanced - 3-agent adversarial bug discovery
│   └── feature-gif-recorder/      # Advanced - Record single-feature demo GIF for PR
└── specs.md                       # Workshop showcase spec (separate)
```

## Skills Overview

### Beginner (10 skills)

| Skill | Description |
|-------|-------------|
| `frontend-dev` | Build modern frontend apps with React, Next.js, and Tailwind CSS |
| `fullstack-dev` | Complete full-stack development with frontend + backend + database |
| `api-builder` | Design and implement REST APIs with proper structure |
| `landing-page` | Create polished landing pages quickly |
| `bug-fixer` | Systematic approach to finding and fixing bugs |
| `test-writer` | Write comprehensive tests for existing codebases |
| `docs-generator` | Auto-generate documentation from code |
| `refactorer` | Clean up and improve existing code safely |
| `database-designer` | Design schemas, write migrations, model relationships |
| `auth-system` | Authentication & authorization (signup, login, roles, protected routes) |

### Advanced (16 skills)

| Skill | Description |
|-------|-------------|
| `tdd-workflow` | Full test-driven development cycle (Red-Green-Refactor) |
| `multi-agent-orchestrator` | Coordinate multiple AI agents for complex tasks |
| `prompt-engineer` | Craft and optimize prompts for better AI output |
| `code-reviewer` | Automated code review for security, quality, and performance |
| `skill-creator` | Generate new reusable skills from git history and patterns |
| `codex-review` | AI-to-AI code review via Codex MCP with structured JSON report |
| `pre-merge-review` | Multi-phase pre-merge review pipeline (refactor, code review, Codex, docs) |
| `skill-builder` | Create well-structured Claude Code skills with templates and examples |
| `postmortem` | Capture lessons learned (bugs, architecture, misunderstandings) into gotchas.md |
| `autoresearch` | Autonomously optimize skills by running evals and mutating prompts |
| `prune-gotchas` | Review and consolidate accumulated gotchas.md entries across skills |
| `docs-scaffold` | Scaffold a structured docs/ folder with templates, splitting rules, and cross-references |
| `resolve-docs` | Interactively resolve open questions and documentation gaps in project docs |
| `spa-day` | Audit rules and skills for contradictions, redundancy, and staleness |
| `adversarial-bug-hunt` | 3-agent adversarial pipeline (finder → adversarial → referee) for high-fidelity bug discovery |
| `feature-gif-recorder` | Record a GIF of one specific feature flow via Playwright CLI; emits a PR-ready SHA-pinned `<img>` snippet |

## Workshop Usage

1. Review the [Cheatsheet](cheatsheet/) for essential commands
2. Start with beginner skills to build something
3. Graduate to advanced skills for deeper workflows
4. Use `skill-builder` or `skill-creator` to build your own custom skills
5. Run `pre-merge-review` before merging feature branches
6. Use `docs-scaffold` + `resolve-docs` for comprehensive project documentation

## License

MIT
