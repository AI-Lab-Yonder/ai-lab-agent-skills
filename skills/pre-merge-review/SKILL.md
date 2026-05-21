---
name: pre-merge-review
description: "Comprehensive pre-merge review pipeline — runs refactor cleanup, code review, Codex review, doc updates, and language-specific review across all branch changes. Use before merging a feature branch."
version: 1.0.0
level: advanced
category: code-quality
---

# Pre-Merge Review Pipeline

Run this skill before merging a feature branch. It orchestrates multiple review passes across all changes on the branch compared to the base branch, then produces a consolidated findings report.

## Constraints

- Review scope is **all commits on the current branch** vs the base branch (usually `main`)
- For Python code, use your project's virtual environment for tooling (e.g., `ruff`, `mypy`, `pytest`)
- Do NOT auto-fix issues — collect findings and present them at the end
- Do NOT commit or merge anything — this is a read-only review pipeline
- If a phase fails or is not applicable (e.g., no Python files changed), skip it and note it in the report

---

## Phase 0 — Determine Scope

1. Identify the base branch. Default to `main` unless the user specifies otherwise.
2. Run `git diff --name-only <base>...HEAD` to get all changed files on this branch.
3. Categorize files:
   - **Python files** (`.py`) → will be reviewed by Python reviewer
   - **Frontend files** (`.ts`, `.tsx`, `.scss`, `.css`) → will be reviewed by code reviewer
   - **All files** → refactor cleanup, Codex review, doc updates
4. Print a short scope summary: branch name, base branch, number of files changed, categories.

---

## Phase 1 — Refactor & Dead Code Cleanup

Invoke `/everything-claude-code:refactor-clean` on the changed files.

Purpose: Identify unused imports, dead code, duplicate logic, and consolidation opportunities.

Collect all findings — do not fix yet.

---

## Phase 2 — Code Review

Invoke `/everything-claude-code:code-review` on all changed files.

Purpose: Security, quality, best practices, and correctness review.

Collect all findings — do not fix yet.

---

## Phase 3 — Codex Review

Invoke `/codex-review` scoped to the branch changes.

Purpose: Independent AI review for bugs, regressions, performance, and security via Codex MCP.

Collect all findings — do not fix yet.

---

## Phase 4 — Python Review (conditional)

**Only run if Phase 0 found Python files in the changeset.**

Invoke `/everything-claude-code:python-review` on the changed Python files.

Use your project's virtual environment for all Python tooling (ruff, mypy, pytest).

Collect all findings — do not fix yet.

---

## Phase 5 — E2E Testing (optional)

If the changes touch critical user flows (e.g., authentication, checkout, data export), consider running E2E tests to validate end-to-end.

Skip if changes are purely cosmetic, documentation, or test-only.

---

## Phase 6 — Documentation Updates

Invoke `/everything-claude-code:update-docs` to check if documentation needs updating based on the branch changes.

Purpose: Ensure codemaps, READMEs, and guides reflect the current state.

Note any docs that need updating — do not auto-update yet.

---

## Phase 7 — Consolidated Report

After all phases complete, produce a single structured report:

### Report Format

```markdown
# Pre-Merge Review Report

**Branch:** <branch-name>
**Base:** <base-branch>
**Files reviewed:** <count>
**Date:** <today>

## Summary

| Phase | Status | Findings |
|-------|--------|----------|
| Refactor & Cleanup | done/skipped | X issues |
| Code Review | done/skipped | X issues |
| Codex Review | done/skipped | X issues |
| Doc Updates | done/skipped | X items |
| Python Review | done/skipped/n-a | X issues |
| E2E Testing | done/skipped/n-a | X failures |

## Critical Issues (must fix before merge)
- [ID] severity — file:line — description

## High Issues (should fix before merge)
- [ID] severity — file:line — description

## Medium Issues (fix if time permits)
- [ID] severity — file:line — description

## Low Issues (informational)
- [ID] severity — file:line — description

## Documentation Gaps
- List of docs/files that need updating

## Recommendation
MERGE / MERGE WITH FIXES / DO NOT MERGE
```

### Decision Logic

- **DO NOT MERGE**: Any critical security vulnerabilities or data-loss bugs
- **MERGE WITH FIXES**: High-severity issues that should be addressed first
- **MERGE**: Only medium/low issues or no issues found
