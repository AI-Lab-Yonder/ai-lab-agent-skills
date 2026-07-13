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
2. Identify all tracked changes, staged and unstaged, with `git diff --name-only HEAD`
3. Identify untracked files with `git ls-files --others --exclude-standard`
4. For each tracked changed file, inspect the complete staged-plus-unstaged change with `git diff HEAD -- <file>`
5. Read each relevant untracked file directly. Skip binary, generated, or oversized files that cannot be reviewed safely and record each skipped file with a reason in `out_of_scope`
6. If the repository has no `HEAD` yet, combine `git diff --name-only`, `git diff --cached --name-only`, and the untracked-file list instead
7. Analyze every in-scope change for: bugs, regressions, performance risks, security issues, test gaps, and completeness gaps
8. Include exact file paths and line numbers for every finding. For deleted code, cite the deleted line range from the diff
9. If practical, run quick validation checks (typecheck, lint, test) only when they require no dependency installation, repository edits, or permission expansion. Otherwise record the check as `not_run` with the reason

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
- Review staged, unstaged, and untracked changes within scope
- Severity counts MUST exactly match the findings array
- Confidence values MUST be numbers from 0.0 through 1.0
- Redact any credential or secret value in evidence snippets while retaining enough context to support the finding
- Record every skipped file or excluded area with a reason in `out_of_scope`
- Do not install dependencies, edit files, or request expanded permissions
- Use empty arrays for no items
- Numeric values for all numeric fields
- If no issues found: findings=[], zeroed severity counts
- Output must be valid JSON (no trailing commas, no comments)
```
