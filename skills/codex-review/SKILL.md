---
name: codex-review
description: |
  Review uncommitted git changes for bugs/regressions via Codex MCP and present
  a structured report. Use when asked to review local changes or find bugs in
  current work. Requires Codex MCP to be configured.
level: advanced
category: code-quality
---

# Codex Review Skill

Delegates code review of uncommitted changes to Codex MCP, presents a structured report, and helps the user plan fixes. Three phases, executed in order.

> **Note:** An official `codex-review` skill also ships with the Codex CLI plugin.
> This version uses Codex MCP directly and offers structured JSON output and a
> fix-planning workflow, which the official one does not.

## Constraints

- Read `gotchas.md` before starting
- Do NOT run git commands yourself (no `git status`, `git diff`, etc.)
- Do NOT read source files to perform your own review
- Do NOT guess at issues without Codex data
- Your ONLY job is: send the prompt to Codex, present results, and ask the user what to fix

---

## Phase 1 — Delegate to Codex MCP

Read `references/codex-prompt.md` for the full prompt template and scope clause substitution rules.

Call `mcp__codex__codex` exactly once with these parameters:

| Parameter         | Value            |
|-------------------|------------------|
| `sandbox`         | `"read-only"`    |
| `approval-policy` | `"on-failure"`   |
| `prompt`          | From `references/codex-prompt.md`, with `{{SCOPE_CLAUSE}}` replaced |

See `references/json-schema.md` for the output schema field reference and validation rules. The raw schema template is at `templates/output-schema.json`.

---

## Phase 2 — Present Findings

Read `references/presentation-format.md` for the display format. See `examples/` for concrete output samples.

If `findings` is empty: say "No issues found in the uncommitted changes." and **stop** — do not proceed to Phase 3.

---

## Phase 3 — Select Issues and Plan Fixes

1. Ask the user which finding IDs they want to fix:
   > "Which issues would you like me to fix? You can list IDs (e.g., REV-001, REV-003) or say 'all'."

2. **CRITICAL — next turn action:** When the user replies with their selection, your **very first tool call** MUST be `EnterPlanMode`. Do not output any text or call any other tool before entering plan mode. The plan you write must:
   - Reference the specific findings selected by the user
   - Use the evidence (file paths, line numbers, snippets) from the report
   - Include the recommended fixes from the report as a starting point
   - Lay out concrete steps to resolve each selected issue
