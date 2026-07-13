---
name: spa-day
description: Audit rules and skills for semantic contradictions, redundancy, and staleness, then interactively resolve with the user. Use periodically when agent performance degrades or after adding many rules/skills.
version: 1.1.0
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
- Use the platform's structured question mechanism for user interactions when available; otherwise ask in normal conversation and wait for the response

---

## Phase 0 — Determine Scope

Use the available structured question mechanism, or normal conversation, to ask the user what to audit. Options:
- **User-level only** (the active platform's user-level configuration root)
- **Project only** (the active platform's repository-level configuration root)
- **Both**

Then scan the chosen locations:
- Detected instruction entry files, such as `AGENTS.md` or a platform equivalent
- Markdown rule files beneath the platform's rules location
- `SKILL.md` files beneath the platform's skills location

Build an inventory table: file path, purpose (first line or heading), line count.

---

## Phase 1 — Contradiction Detection

Read `references/contradiction-patterns.md` for the 6 pattern types to check.

Cross-reference all inventoried files for:
- Direct contradictions (rule A says X, rule B says NOT X)
- Implicit conflicts (skill uses approach A, rule bans approach A)
- Scope overlaps (global and project say opposite things)
- Stale references (an instruction entry file points to files that don't exist)

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

For each finding, use the available structured question mechanism, or normal conversation, to present the issue with evidence and ask for an action:
- **Rewrite** — edit the conflicting file(s) to resolve
- **Delete** — remove the redundant file
- **Merge** — combine files covering the same concern
- **Update refs** — fix instruction entry-file pointers
- **Skip** — defer this item, no action now

Consolidation guidance:
- When merging: keep the more specific/recent version
- When splitting: extract if a file covers >2 unrelated concerns
- When deleting: verify nothing references it first
- Global vs project conflict: project-level wins (intentional override)

---

## Phase 5 — Summary

Print before/after metrics: file count, total lines, changes made. If the `context-budget` skill is available, suggest invoking it through the platform's skill mechanism for token impact verification.
