---
name: code-review-codex
description: Run an independent Codex review of your changes, then plan and fix selected issues
invocation: /code-review-codex [--commit <sha> | --base <branch> | --uncommitted]
requires:
  - Codex CLI — `npm install -g @openai/codex`
hooks: none
---

# Code Review via Codex

Get an independent second opinion on your code from Codex, then selectively fix what matters. Unlike asking Claude to review its own work, this delegates the review to a separate agent with no context of how the code was written.

## Invocation

```
/code-review-codex                        # review last commit (default)
/code-review-codex --uncommitted          # review staged/unstaged changes
/code-review-codex --commit abc123        # review a specific commit
/code-review-codex --base main            # review all commits since branching from main
```

## Arguments

| Argument | What it reviews |
|----------|----------------|
| _(none)_ | Last commit (`HEAD`) |
| `--uncommitted` | All staged, unstaged, and untracked changes |
| `--commit <sha>` | A specific commit by SHA |
| `--base <branch>` | All commits since diverging from `<branch>` |

## What Happens

1. **Sets up** a timestamped review file (`reviews/review-<id>.md`)
2. **Runs Codex** non-interactively via `codex exec` — Codex reads the git diff and writes findings to the review file
3. **Presents findings** grouped by severity: CRITICAL → HIGH → MEDIUM → LOW
4. **Asks you** which issues to fix (you choose — nothing is auto-fixed)
5. **Enters plan mode** before making any changes — you confirm the plan first
6. **Fixes** selected issues, then cleans up the review file

## Severity Levels

| Severity | Examples |
|----------|---------|
| CRITICAL | Hardcoded credentials, SQL injection, XSS, path traversal, missing auth |
| HIGH | Functions >50 lines, nesting >4 levels, missing error handling, debug statements |
| MEDIUM | Mutation patterns, missing tests, accessibility issues |
| LOW | Naming inconsistencies, minor style issues |

## Prerequisites

Codex CLI must be installed and authenticated:

```bash
npm install -g @openai/codex
codex login
```

## Notes

- You are always in control — Codex reviews, you decide what to fix
- The review file is deleted automatically after the session
