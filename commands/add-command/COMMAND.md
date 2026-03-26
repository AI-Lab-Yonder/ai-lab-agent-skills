---
name: add-command
description: Interactive guide for creating a new slash command
invocation: /add-command [command-name] [description]
requires: none
hooks: none
---

# Add Command

A meta-command that teaches you how to create your own slash commands. Run it when you want to build a new command and Claude will walk you through the structure, options, and patterns.

## Invocation

```
/add-command                              # opens the guide
/add-command deploy "Run deployment"      # starts with a name and description pre-filled
```

## Commands vs Skills

Before building, know which one you need:

| | Commands | Skills |
|--|--|--|
| How it runs | You invoke it explicitly with `/` | Loaded automatically into every session |
| Best for | Workflows you trigger on demand | Patterns you always want the agent to follow |

If you want the agent to *always* follow a pattern, build a skill. If you want to *trigger* a workflow when you decide, build a command.

## Command File Structure

Commands are Markdown files with optional YAML frontmatter:

```markdown
---
allowed-tools: Read, Edit, Bash(git:*)
description: What this command does (shown in /help)
argument-hint: <required-arg> [optional-arg]
---

# Command Title

Instructions for Claude when this command is invoked.

Use $ARGUMENTS to reference what the user typed after the command name.
```

## Frontmatter Fields

| Field | Purpose |
|-------|---------|
| `allowed-tools` | Which tools Claude can use. Restrict to what's needed. |
| `description` | One-liner shown in `/help` |
| `argument-hint` | Hint text shown when typing the command |
| `model` | Override the model for this command only |

## Where to Save

| Location | Scope |
|----------|-------|
| `~/.claude/commands/name.md` | Personal — available in all projects |
| `.claude/commands/name.md` | Project — shared with your team via git |

Subdirectories create namespaced commands: `~/.claude/commands/ai/summarize.md` → `/ai:summarize`

## Security

- `Bash` commands are sandboxed to the current project directory
- Use `@path/to/file` (not bash) to reference files outside the project
- Scope `allowed-tools` tightly — only list what the command actually needs

## Examples

**Simple command with arguments:**
```markdown
---
description: Fix a GitHub issue
argument-hint: <issue-number>
---
Fix issue #$ARGUMENTS following our coding standards and conventions.
```

**Command with git context:**
```markdown
---
allowed-tools: Bash(git:*)
description: Summarize today's commits
---
Commits today:
`!git log --oneline --since="00:00" --until="23:59"`

Write a one-sentence summary of what was worked on.
```
