# AI Lab Agent Skills

A curated collection of agent skills for AI-powered development workshops. Designed for use with **Claude Code** and **Codex**.

## Quick Start

**Skills** (passive — loaded automatically into context):
```bash
# Copy skills/ into your project's .claude/skills/
cp -r skills/ /path/to/your-project/.claude/skills/
```

**Commands** (active — invoked explicitly with `/`):
```bash
# Copy commands into your personal Claude Code setup
cp .claude/commands/* ~/.claude/commands/
# Or into your project for team sharing
cp .claude/commands/* /path/to/your-project/.claude/commands/
```

**Codex:**
```bash
# Copy .codex/ config into your project
cp -r .codex/ /path/to/your-project/.codex/
# Skills are referenced from .codex/instructions.md
```

## Skills vs Commands

| | Skills | Commands |
|--|--------|---------|
| How it activates | Automatically loaded into context | Explicitly invoked with `/command-name` |
| Best for | Patterns the agent always follows | Workflows you trigger on demand |
| Format | `skills/<name>/SKILL.md` | `.claude/commands/<name>.md` |

## Structure

```
ai-lab-agent-skills/
├── cheatsheet/                  # Quick reference for Claude Code & Codex
├── .claude/
│   ├── commands/                # Runnable slash commands (copy to use)
│   │   ├── code-review-codex.md # Codex-powered code review
│   │   ├── review-loop.md       # Implement → auto-review → address loop
│   │   ├── cancel-review.md     # Cancel an active review loop
│   │   └── add-command.md       # Guide for creating new commands
│   └── settings.json
├── .codex/                      # Codex config
│   ├── config.toml
│   └── instructions.md
├── commands/                    # Command documentation
│   ├── code-review-codex/
│   │   └── COMMAND.md
│   ├── review-loop/
│   │   └── COMMAND.md
│   └── add-command/
│       └── COMMAND.md
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

## Commands Overview

| Command | Description |
|---------|-------------|
| `code-review-codex` | Codex-powered review of any commit, branch, or uncommitted changes — you choose what to fix |
| `review-loop` | Implement a task, get automatic Codex review via Stop hook, address feedback |
| `cancel-review` | Cancel an active review loop and clean up state |
| `add-command` | Interactive guide for creating your own slash commands |

## Workshop Usage

1. Review the [Cheatsheet](cheatsheet/) for essential commands
2. Start with beginner skills to build something
3. Graduate to advanced skills for deeper workflows
4. Use commands for on-demand workflows (`/code-review-codex`, `/review-loop`)
5. Use `skill-creator` or `add-command` to build your own skills and commands

## License

MIT
