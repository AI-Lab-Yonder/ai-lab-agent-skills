---
name: pre-merge-review
description: "Run a portable, evidence-based review of the changes intended for merge. Use before merging a branch to inspect correctness, security, maintainability, tests, documentation, and review coverage without modifying the changes."
version: 1.1.0
level: advanced
category: code-quality
---

# Pre-Merge Review Pipeline

Review the exact changes intended for merge, run the checks supported by the repository, and produce one consolidated report. The pipeline is platform-neutral: use the skills, tools, commands, or manual inspection available in the current environment and identify what provided each result.

## Constraints

- Review the complete merge diff against a verified base branch.
- Detect staged, unstaged, and untracked files; never silently exclude them.
- Do not edit source files, auto-fix findings, install dependencies, commit, push, or merge.
- Prefer repository-defined commands and existing environments over invented commands or global tooling.
- Treat an inapplicable phase, an unavailable capability, and a failed check as different outcomes.
- Support findings with evidence from the diff, repository, or command output.
- Do not report `READY FOR MERGE` when required coverage is incomplete.
- Do not expose secrets or proprietary source excerpts in the report.

## Phase 0 — Establish scope

### Identify the base

Use the first reliable source:

1. A base branch supplied by the user or merge-request context.
2. The branch's configured upstream or the remote's symbolic default branch.
3. An existing conventional branch such as `main` or `master`.

Verify that the selected reference exists and compute its merge base with `HEAD`. If detection remains ambiguous, ask the user instead of choosing silently. Report the selected base and how it was determined.

### Inventory changes

Build separate inventories for:

- committed branch changes from `<base>...HEAD`;
- staged changes;
- unstaged changes; and
- untracked, non-ignored files.

The committed merge diff is the default review scope. If local changes exist, explain that they are not part of the committed branch and ask whether they should also be reviewed. Regardless of that choice, disclose them because they can affect local test results.

Record renames, deletions, generated files, vendored code, binaries, migrations, configuration, documentation, and tests rather than assuming that every changed file is ordinary source code.

### Discover repository guidance

Read the repository's contributor or agent guidance and inspect build manifests, lockfiles, task runners, continuous-integration configuration, and test configuration. Use these to determine:

- languages and frameworks affected by the changes;
- repository-supported lint, formatting-check, type-check, test, build, and E2E commands;
- generated or vendored paths that require special handling; and
- any documented review or merge requirements.

Print a scope summary before starting: current branch, base, merge base, included and excluded local changes, changed-file categories, and planned checks.

## Phase 1 — Inspect the diff

Review the complete included diff and relevant surrounding code for:

- incorrect behavior, regressions, edge cases, and error handling;
- security, privacy, authorization, validation, and data-loss risks;
- interface, schema, migration, configuration, and compatibility changes;
- concurrency, lifecycle, resource, and performance problems;
- dead code, duplication, unnecessary complexity, and maintainability issues;
- missing or misleading tests; and
- documentation that no longer matches behavior.

Use available review skills or integrations when they fit, but do not require a platform-specific command. If no specialized reviewer is available, perform the inspection directly and record that implementation in the phase results.

## Phase 2 — Run repository checks

Select checks from repository guidance and the affected technologies. Typical categories are:

- formatting verification without auto-fix;
- linting and static analysis;
- type checking;
- focused tests for changed behavior;
- the broader test suite when proportionate;
- build or compile verification; and
- schema or migration validation.

Use the project's existing environment and dependency state. Do not install missing tools automatically. For every command, record the exact command, exit status, and relevant result.

Classify each planned check as:

- **passed** — ran successfully;
- **failed** — ran and found a problem or could not complete;
- **not applicable** — does not relate to the changes;
- **unavailable** — required tool, environment, service, or credential is missing; or
- **not run** — deliberately omitted, with the reason.

A required check that is `failed`, `unavailable`, or `not run` makes review coverage incomplete unless equivalent evidence is obtained another way.

## Phase 3 — Validate affected flows

Run E2E or integration coverage when the changes affect a user-visible or cross-system flow and the repository provides a safe, configured way to do so. Examples include authentication, authorization, payments, destructive actions, migrations, imports, exports, and communication with external services.

Do not run checks that would mutate production data, send real messages, incur charges, or require undisclosed credentials. Mark such coverage as unavailable and state what a reviewer should verify in an appropriate environment.

For cosmetic, documentation-only, or isolated test changes, mark E2E as not applicable and explain why.

## Phase 4 — Check documentation

Compare behavior and interfaces in the diff with relevant READMEs, guides, API references, examples, changelogs, configuration documentation, and operational instructions.

Report documentation gaps as findings. Do not update documentation during this read-only pipeline.

## Phase 5 — Optional independent review

When a genuinely independent reviewer or review integration is available, run it against the same scope and provide the same base and inclusion rules. This phase is optional; absence alone does not make the review incomplete.

Validate imported findings against the actual diff and surrounding code. Do not treat another reviewer's output as established fact.

## Phase 6 — Consolidate findings

Merge overlapping findings that share a root cause. Keep distinct consequences separate only when they require different fixes or have materially different severity.

Each actionable finding must contain:

- a stable ID and severity;
- file and line or the narrowest available location;
- the observed behavior or failure mode;
- evidence and the relevant conditions;
- impact;
- a focused remediation proposal; and
- confidence: high, medium, or low.

Do not inflate severity because a finding came from a specialized tool. Omit speculative concerns that cannot be tied to changed code, or list them separately as questions requiring confirmation.

## Phase 7 — Report

Use this structure:

```markdown
# Pre-Merge Review Report

**Branch:** <branch>
**Base:** <verified base and detection source>
**Merge base:** <commit>
**Scope:** <committed diff plus any approved local changes>
**Files reviewed:** <count>

## Coverage
| Phase or check | Implementation or command | Status | Evidence or limitation |
|---|---|---|---|

## Blocking Findings
- [ID] severity · confidence — file:line — finding, evidence, impact, remediation

## Non-Blocking Findings
- [ID] severity · confidence — file:line — finding, evidence, impact, remediation

## Documentation Gaps
- <location and required update>

## Open Questions
- <unverified assumption or decision needed>

## Excluded Changes and Coverage Limitations
- <what was not reviewed or could not run, and why>

## Recommendation
DO NOT MERGE / MERGE WITH FIXES / READY FOR MERGE / REVIEW INCOMPLETE
```

### Recommendation logic

- **DO NOT MERGE:** a confirmed critical security, privacy, corruption, or data-loss risk exists.
- **MERGE WITH FIXES:** confirmed blocking findings must be resolved first.
- **READY FOR MERGE:** no blocking findings remain and all required coverage passed or has equivalent evidence.
- **REVIEW INCOMPLETE:** missing, failed, or excluded required coverage prevents a reliable recommendation.

State that `READY FOR MERGE` reflects the reviewed scope and evidence; it is not proof that the change is defect-free.
