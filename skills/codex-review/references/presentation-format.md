# Presentation Format

How to validate and display the Codex review report to the user.

## Parsing

The Codex response should be exactly one JSON object. Remove a single outer markdown fence when present. If the response is truncated, contains multiple candidate objects, or cannot be parsed unambiguously, show the parsing error and stop.

Validate the report against `references/json-schema.md` before presentation. Do not silently add missing fields, change severities, or rewrite findings.

## Evidence Verification

Verify each evidence item with read-only inspection:

- The path belongs to the reviewed scope
- The line range is valid for the cited side of the diff
- The snippet is supported by the diff or source file
- Deleted and renamed code is checked against the diff preimage

This is evidence verification, not a second code review. If evidence cannot be verified, keep the finding visible but add an `UNVERIFIED EVIDENCE` label and explain what failed verification.

## Summary Header

Show first, before any findings:

- Scope reviewed
- Number of files reviewed
- Severity counts: **high** / **medium** / **low**
- Overall confidence score
- Any skipped files or other `out_of_scope` limitations

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

> "No issues found in the reviewed scope."

Still show skipped files, `out_of_scope` entries, failed checks, and checks that were not run. An empty findings array does not imply that excluded content was reviewed.

**Stop here** — do not proceed to Phase 3.

## Examples

See `examples/` for concrete output samples:
- `sample-frontend.md` — typical review with regression and test gap findings
- `sample-no-issues.md` — clean review with no findings
- `sample-security.md` — security-focused findings
