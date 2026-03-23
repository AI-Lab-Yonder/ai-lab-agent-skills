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
│   └── skill-creator/             # Advanced - Create new skills
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

### Advanced (5 skills)

| Skill | Description |
|-------|-------------|
| `tdd-workflow` | Full test-driven development cycle (Red-Green-Refactor) |
| `multi-agent-orchestrator` | Coordinate multiple AI agents for complex tasks |
| `prompt-engineer` | Craft and optimize prompts for better AI output |
| `code-reviewer` | Automated code review for security, quality, and performance |
| `skill-creator` | Generate new reusable skills from git history and patterns |

## Workshop Usage

1. Review the [Cheatsheet](cheatsheet/) for essential commands
2. Start with beginner skills to build something
3. Graduate to advanced skills for deeper workflows
4. Use `skill-creator` to build your own custom skills

## License

MIT
