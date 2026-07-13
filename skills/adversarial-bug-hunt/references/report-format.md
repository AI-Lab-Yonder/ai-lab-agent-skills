# Report Format

How to present the adversarial bug hunt results to the user.

## Summary Header

Show first, before any findings:

- Scope reviewed
- Pipeline: Bug-Finder → Adversarial → Referee
- Execution mode: isolated workers / external isolated sessions / sequential fallback
- Assurance: preferred / reduced
- Verdict counts: **confirmed** / **uncertain** / **disproved** (total)
- Overall confidence score

## Findings List

Show only CONFIRMED and UNCERTAIN findings. For each:

1. **ID and verdict badge**: `[BUG-XXX] CONFIRMED` or `[BUG-XXX] UNCERTAIN`
2. **Severity**: high / medium / low
3. **Title**: Short issue title
4. **Impact**: User-visible or system impact
5. **Evidence**: File path, line range, code snippet
6. **Bug-Finder's case**: Why they reported it
7. **Adversarial challenge**: What the adversarial agent argued
8. **Referee reasoning**: Why the referee confirmed or marked uncertain
9. **Fix recommendation**: Actionable fix

## Disproved Findings (Collapsed)

After the main findings, optionally list disproved findings in a collapsed/summary format:
- Just ID, title, and one-line reason for dismissal
- This lets the user spot-check the adversarial's work

## All Findings Disproved

If every finding has `referee_verdict: "DISPROVED"`:

> "No confirmed issues found in the reviewed code. The adversarial agent successfully challenged all findings from the bug-finder."

**Stop here** — do not proceed to the fix selection phase.

## Fix Selection

> "Which issues would you like me to fix? You can list IDs (e.g., BUG-001, BUG-003) or say 'all'."

When the user replies, prepare a fix plan before editing. Use the runtime's native planning mode when available; otherwise present the plan in chat and wait for approval.

## Examples

See `examples/` for concrete output samples:
- `sample-backend-bugs.md` — mix of confirmed, uncertain, and disproved
- `sample-clean-codebase.md` — all findings disproved
- `sample-security-mix.md` — security-focused findings with mixed verdicts
