---
allowed-tools: Write
description: Guide for creating new slash commands
argument-hint: [command-name] [description]
---

# Slash Command Creator Guide

## How This Command Works
The `/add-command` command shows this guide for creating new slash commands. It includes:
- Command structure and syntax
- Common patterns and examples
- Security restrictions and limitations
- Frontmatter options

**Note for AI**: When creating commands, you CAN use bash tools like `Bash(mkdir:*)`, `Bash(ls:*)`, `Bash(git:*)` in the `allowed-tools` frontmatter of NEW commands - but ONLY for operations within the current project directory. This command itself doesn't need bash tools since it's just documentation.

## Command Locations
- **Personal**: `~/.claude/commands/` (available across all projects)
- **Project**: `.claude/commands/` (shared with team, shows "(project)")

## Basic Structure

```markdown
---
allowed-tools: Read, Edit, Write, Bash(git:*)
description: Brief description of what this command does
argument-hint: [required-arg] [optional-arg]
model: claude-sonnet-4-6
---

# Command Title

Your command instructions here.

Arguments: $ARGUMENTS
```

## Frontmatter Options
- `allowed-tools`: Tools this command can use
- `description`: Brief description (shows in /help)
- `argument-hint`: Help text for arguments (shown as hint when typing the command)
- `model`: Specific model to use for this command

## Security Restrictions

**Bash Commands**: Limited to current working directory only.
- ✅ Works: `` `git status` `` (in project dir)
- ❌ Blocked: `` `ls /outside/project` `` (outside project)

**File References (`@` prefix)**: No directory restrictions.
- ✅ Works: `@/path/to/any/file.md`
- ✅ Works: `@../other-project/file.js`

## Common Patterns

### Command with Arguments
```markdown
Fix issue #$ARGUMENTS following our coding standards
```

### Command with Bash Output
```markdown
---
allowed-tools: Bash(git:*)
---
Current branch: `!git branch --show-current`
Recent commits: `!git log --oneline -5`

Create a commit for these changes.
```

### Namespaced Command
Save to `~/.claude/commands/ai/summarize.md` → invoked as `/ai:summarize`

## Usage
After creating: `/<command-name> [arguments]`
