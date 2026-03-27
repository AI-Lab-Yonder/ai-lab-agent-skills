# Codex Prompt Template

The prompt sent to `mcp__codex__codex` for code review. Replace `{{SCOPE_CLAUSE}}` before sending.

## Scope Clause Substitution

- If the user specified a scope (e.g., "frontend only", "just the API layer"), replace `{{SCOPE_CLAUSE}}` with `, focusing only on <user's scope description>`
- If no scope was specified, replace `{{SCOPE_CLAUSE}}` with an empty string

## Prompt

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
