# Presentation Format

How to display the Codex review report to the user.

## Parsing

The Codex response should be a JSON object. If the response contains markdown fences or extra text, extract the JSON object from it before parsing.

## Summary Header

Show first, before any findings:

- Scope reviewed
- Number of files reviewed
- Severity counts: **high** / **medium** / **low**
- Overall confidence score

## Findings List

For each finding, display:

1. **ID and severity badge**: `[REV-XXX]` with severity indicator (e.g., `[REV-001] HIGH`)
2. **Title**: Short issue title
3. **Impact**: User-visible or system impact description
4. **Evidence**: File path, line range, and code snippet
5. **Root cause**: Why it happens
6. **Fix recommendation**: Actionable fix suggestion
7. **Confidence**: Score (0.0-1.0)

## Checks Run

After findings, list each check (typecheck, lint, test) with its status:
- passed / failed / not_run
- Include details of what was run

## Empty Findings

If `findings` is empty, say:

> "No issues found in the uncommitted changes."

**Stop here** — do not proceed to Phase 3.

## Examples

See `examples/` for concrete output samples:
- `sample-frontend.md` — typical review with regression and test gap findings
- `sample-no-issues.md` — clean review with no findings
- `sample-security.md` — security-focused findings
