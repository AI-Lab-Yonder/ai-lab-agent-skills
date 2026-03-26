---
name: review-loop
description: Implement a task, then get an automatic independent Codex review via Stop hook, then address feedback
invocation: /review-loop <task description>
requires:
  - Codex CLI — `npm install -g @openai/codex`
  - review-loop plugin — `claude install review-loop`
hooks:
  - Stop — automatically triggers Codex review when Claude finishes implementing the task
---

# Review Loop

A two-phase implement-then-review workflow where Claude implements your task and a Stop hook automatically fires Codex to review the changes — without you having to ask.

## Invocation

```
/review-loop Add pagination to the users API endpoint
/review-loop Fix the race condition in the cache layer
/review-loop Refactor auth middleware to use the new token format
```

## What Happens

```
You: /review-loop <task>
  ↓
Claude implements the task fully
  ↓
Claude stops → Stop hook fires automatically
  ↓
Codex independently reviews all changes
  ↓
Claude presents the review and addresses feedback
  ↓
Done
```

The key insight: **the review is triggered by a hook, not by you**. You don't need to remember to ask for a review — it happens automatically every time.

## The Stop Hook

The review-loop plugin installs a Stop hook that runs after every Claude response. When a review loop is active (state file present), the hook:

1. Detects that the task phase is complete
2. Runs Codex non-interactively against the changed files
3. Injects the review findings back into Claude's context
4. Prompts Claude to address the feedback before finishing

The hook changes the control flow of the session itself — implementation and review happen in one uninterrupted flow.

## State Management

The review loop tracks state in `.claude/review-loop.local.md`:
- Created when `/review-loop` is invoked
- Contains the current phase (`task` or `addressing`) and review ID
- Deleted automatically when the loop completes

If something goes wrong mid-loop, use `/cancel-review` to clean up the state file and start fresh.

## Prerequisites

**Codex CLI:**
```bash
npm install -g @openai/codex
codex login
```

**review-loop plugin:**
```bash
claude install review-loop
```

The plugin installs the Stop hook automatically. No manual hook configuration needed.

## Plan Mode and Review Loop

The review loop doesn't enter plan mode automatically — it goes straight to implementation. If you want to think through the approach first, use plan mode before starting the loop:

```
# 1. Plan the approach first (Shift+Tab to enter plan mode)
> Plan how to add pagination to the users API endpoint

# 2. Review and confirm the plan with Claude

# 3. Then start the review loop for the actual implementation + review
/review-loop Add pagination to the users API endpoint
```

This way you get the benefit of a confirmed plan going in, and an independent Codex review coming out.
