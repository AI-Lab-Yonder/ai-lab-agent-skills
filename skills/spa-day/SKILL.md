---
name: spa-day
description: Audit rules and skills for semantic contradictions, redundancy, and staleness, then interactively resolve with the user. Use periodically when agent performance degrades or after adding many rules/skills.
version: 1.0.1
level: advanced
category: meta
---

# Spa Day

Periodic health audit for your rules and skills. Finds contradictions, redundancies, dead references, and oversized files, then walks you through resolving each one interactively.

## Constraints

- Read `gotchas.md` before starting
- NEVER modify files without explicit user approval for each change
- Read-heavy, write-light — most work is analysis
- Do NOT load all files upfront — read progressively as needed
- Stateless — no config, no logs, ask scope each time
- Use `AskUserQuestion` tool for ALL user interactions — never just print a question and wait

---

## Phase 0 — Determine Scope

Use `AskUserQuestion` to ask the user what to audit. Options:
- **Global only** (`~/.claude/`)
- **Project only** (`.claude/`)
- **Both**

Then scan the chosen locations:
- `CLAUDE.md`
- `rules/**/*.md`
- `skills/*/SKILL.md`

Build an inventory table: file path, purpose (first line or heading), line count.

---

## Phase 1 — Contradiction Detection

Read `references/contradiction-patterns.md` for the 6 pattern types to check.

Cross-reference all inventoried files for:
- Direct contradictions (rule A says X, rule B says NOT X)
- Implicit conflicts (skill uses approach A, rule bans approach A)
- Scope overlaps (global and project say opposite things)
- Stale references (CLAUDE.md points to files that don't exist)

---

## Phase 2 — Redundancy Detection

Scan for:
- Duplicate or near-duplicate directives across files
- Rules that are subsets of other rules
- Skills with overlapping descriptions (false trigger risk)
- Gotchas that restate existing rules

---

## Phase 3 — Health Report

Read `references/health-metrics.md` for thresholds. Present a report covering:
- Total files, total lines
- Contradictions found (with evidence: quotes from both files)
- Redundancies found (with both locations)
- Oversized files exceeding thresholds
- Dead references
- Recommendation per finding: consolidate / split / delete / update ref

See `examples/` for concrete report samples.

If no issues found: "All healthy. No contradictions or redundancies found." and **stop**.

---

## Phase 4 — Interactive Resolution

For each finding, use `AskUserQuestion` to present the issue with evidence and ask for an action:
- **Rewrite** — edit the conflicting file(s) to resolve
- **Delete** — remove the redundant file
- **Merge** — combine files covering the same concern
- **Update refs** — fix CLAUDE.md pointers
- **Skip** — defer this item, no action now

Consolidation guidance:
- When merging: keep the more specific/recent version
- When splitting: extract if a file covers >2 unrelated concerns
- When deleting: verify nothing references it first
- Global vs project conflict: project-level wins (intentional override)

---

## Phase 5 — Summary

Print before/after metrics: file count, total lines, changes made. Suggest running `/context-budget` for token impact verification.
