---
name: codex-review
description: "Review uncommitted git changes for bugs/regressions via Codex MCP and present a structured report. Use when asked to review local changes or find bugs in current work. Requires Codex MCP to be configured."
version: 1.0.1
level: advanced
category: code-quality
---

# Codex Review Skill

Delegates code review of uncommitted changes to Codex MCP, presents a structured report, and helps the user plan fixes. Three phases, executed in order.

## Constraints

- Read `gotchas.md` before starting
- Do NOT run git commands or read source files to perform a second code review
- After Codex responds, read-only git and file inspection is allowed solely to verify its cited paths, line ranges, and snippets
- Do NOT guess at issues without Codex data
- Do NOT install dependencies, edit files, or approve expanded permissions during review
- Your job is to send the prompt to Codex, validate and present its results, and ask the user what to fix

---

## Phase 1 — Delegate to Codex MCP

Read `references/codex-prompt.md` for the full prompt template and scope clause substitution rules.

Call `mcp__codex__codex` exactly once with these parameters:

| Parameter         | Value            |
|-------------------|------------------|
| `sandbox`         | `"read-only"`    |
| `approval-policy` | `"never"`        |
| `prompt`          | From `references/codex-prompt.md`, with `{{SCOPE_CLAUSE}}` replaced |

See `references/json-schema.md` for the output contract and validation rules. The raw report template is at `templates/output-schema.json`.

If the MCP call fails, times out, or is unavailable, report the exact failure and stop. Do not fabricate findings or silently substitute a different review method.

---

## Phase 2 — Present Findings

Read `references/presentation-format.md` for the display format. See `examples/` for concrete output samples.

Before presenting findings:

1. Parse exactly one JSON object. A single outer markdown fence may be removed; do not guess when the response is truncated, ambiguous, or contains multiple objects.
2. Validate required fields, types, allowed values, confidence ranges, sequential IDs, and severity counts using `references/json-schema.md`.
3. Verify every cited path, line range, and snippet read-only against the reviewed diff. For deleted or renamed code, verify against the diff preimage rather than only the current file.
4. If the report contract is invalid, show the validation errors and stop. Do not silently rewrite substantive findings.
5. If a finding's evidence cannot be verified, retain the finding but label it `UNVERIFIED EVIDENCE` in the presentation.

If `findings` is empty: say "No issues found in the reviewed scope." Show any skipped files, `out_of_scope` entries, or checks that were not run, then **stop** — do not proceed to Phase 3.

---

## Phase 3 — Select Issues and Plan Fixes

1. Ask the user which finding IDs they want to fix:
   > "Which issues would you like me to fix? You can list IDs (e.g., REV-001, REV-003) or say 'all'."

2. **CRITICAL — next turn action:** When the user replies with their selection, your **very first tool call** MUST be `EnterPlanMode`. Do not output any text or call any other tool before entering plan mode. The plan you write must:
   - Reference the specific findings selected by the user
   - Use the evidence (file paths, line numbers, snippets) from the report
   - Include the recommended fixes from the report as a starting point
   - Lay out concrete steps to resolve each selected issue
