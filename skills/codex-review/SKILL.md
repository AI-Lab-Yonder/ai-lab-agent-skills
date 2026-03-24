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

This skill has three phases. Follow them exactly in order.

## Constraints

- Do NOT run git commands yourself (no `git status`, `git diff`, etc.)
- Do NOT read source files to perform your own review
- Do NOT guess at issues without Codex data
- Your ONLY job is: send the prompt to Codex, present results, and ask the user what to fix

---

## Phase 1 — Delegate to Codex MCP

Call `mcp__codex__codex` exactly once with the parameters below.

**Parameters:**

| Parameter         | Value            |
|-------------------|------------------|
| `sandbox`         | `"read-only"`    |
| `approval-policy` | `"on-failure"`   |
| `prompt`          | See template below, with `{{SCOPE_CLAUSE}}` replaced |

**Scope clause substitution:**
- If the user specified a scope (e.g., "frontend only", "just the API layer"), replace `{{SCOPE_CLAUSE}}` with `, focusing only on <user's scope description>`
- If no scope was specified, replace `{{SCOPE_CLAUSE}}` with an empty string

### Codex Prompt Template

```
You are a code reviewer. Analyze all uncommitted changes in this git repository{{SCOPE_CLAUSE}}.

## Steps
1. Run `git status --short` to list changed files
2. Run `git diff --name-only` to get the file list
3. For each changed file, run `git diff -- <file>` to get the full diff
4. Analyze each diff for: bugs, regressions, performance risks, security issues, test gaps, and completeness gaps
5. Include exact file paths and line numbers for every finding
6. If practical, run quick validation checks (typecheck, lint, test) and report their status

## Output
Return ONLY a single valid JSON object matching this exact schema (no markdown fences, no commentary before or after):

{
  "summary": {
    "scope": "<what was reviewed>",
    "files_reviewed": 0,
    "high_severity_count": 0,
    "medium_severity_count": 0,
    "low_severity_count": 0
  },
  "findings": [
    {
      "id": "REV-001",
      "severity": "high|medium|low",
      "category": "bug|regression|performance|security|test-gap|completeness-gap",
      "title": "<short issue title>",
      "impact": "<user-visible or system impact>",
      "evidence": [
        {
          "file": "<path>",
          "start_line": 1,
          "end_line": 1,
          "snippet": "<short snippet>"
        }
      ],
      "why_it_happens": "<root cause>",
      "fix_recommendation": "<actionable fix>",
      "confidence": 0.0
    }
  ],
  "checks_run": [
    {
      "name": "typecheck|test|lint|other",
      "status": "passed|failed|not_run",
      "details": "<what was run / why not run>"
    }
  ],
  "out_of_scope": [],
  "overall_confidence": 0.0
}

Rules:
- Use sequential IDs: REV-001, REV-002, ...
- Every finding MUST include all fields shown above
- Every evidence item MUST include file, start_line, end_line, snippet
- Use empty arrays for no items
- Numeric values for all numeric fields
- If no issues found: findings=[], zeroed severity counts
- Output must be valid JSON (no trailing commas, no comments)
```

---

## Phase 2 — Present Findings

After receiving the Codex response:

1. **Parse** the JSON report from the response. If the response contains markdown fences or extra text, extract the JSON object from it.
2. **Show a summary header:**
   - Scope reviewed
   - Number of files reviewed
   - Severity counts: high / medium / low
   - Overall confidence score
3. **List each finding** in a readable format:
   - `[REV-XXX]` ID, severity badge, and title
   - Impact description
   - Evidence: file path, line range, snippet
   - Root cause and fix recommendation
   - Confidence score
4. **List checks run** (typecheck, lint, test) with their status
5. **If `findings` is empty**, say "No issues found in the uncommitted changes." and stop — do not proceed to Phase 3.

---

## Phase 3 — Select Issues and Plan Fixes

1. Ask the user which finding IDs they want to fix. Phrase it conversationally, e.g.:
   > "Which issues would you like me to fix? You can list IDs (e.g., REV-001, REV-003) or say 'all'."

2. **CRITICAL — next turn action:** When the user replies with their selection, your **very first tool call** MUST be `EnterPlanMode`. Do not output any text or call any other tool before entering plan mode. The plan you write must:
   - Reference the specific findings selected by the user
   - Use the evidence (file paths, line numbers, snippets) from the report
   - Include the recommended fixes from the report as a starting point
   - Lay out concrete steps to resolve each selected issue
