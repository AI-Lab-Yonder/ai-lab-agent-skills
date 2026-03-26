# CLAUDE.md

## Project Overview

This is a skill and command library for AI-powered development workshops. It contains 15 skills (10 beginner, 5 advanced) and 4 commands, designed for use with Claude Code and Codex.

## Structure

- `skills/` — Each subdirectory contains a `SKILL.md` file
- `commands/` — Each subdirectory contains a `COMMAND.md` file (documentation)
- `.claude/commands/` — Runnable slash command files (copy to use)
- `cheatsheet/` — Quick reference for Claude Code & Codex commands

## Skills vs Commands

- **Skills** are loaded automatically into context — they influence agent behavior passively
- **Commands** are invoked explicitly with `/command-name` — they trigger on-demand workflows

## Skill Format

Markdown with YAML frontmatter: `name`, `description`, `level`, `category`

### Skill Levels

- **Beginner**: Self-contained, complete examples, linear workflows
- **Advanced**: Decision trees, edge cases, multi-step orchestration

## Command Format

Markdown with YAML frontmatter: `name`, `description`, `invocation`, `requires`, `hooks`

The `hooks` field documents any hook dependencies (e.g. Stop hooks that change control flow).

## File Naming

- Lowercase with hyphens: `frontend-dev`, `code-review-codex`
- Each skill is a directory with a `SKILL.md` inside it
- Each command is a directory with a `COMMAND.md` inside it
