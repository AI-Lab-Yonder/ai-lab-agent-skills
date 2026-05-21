---
name: adversarial-bug-hunt
description: Discover bugs through a 3-agent adversarial pipeline (finder → adversarial → referee) that exploits sycophancy for high-fidelity results. Use when reviewing code for bugs, especially when single-agent review isn't sufficient.
version: 1.0.1
level: advanced
category: code-quality
---

# Adversarial Bug Hunt

Three-agent bug discovery pipeline. A bug-finder over-reports, an adversarial agent disproves, a referee resolves. Each agent runs in a clean context to prevent cross-contamination.

## Constraints

- Read `gotchas.md` before starting
- Each agent MUST be a separate `Agent` tool launch — never reuse context between agents
- Scoring numbers are a **prompt technique** — they bias agent behavior via sycophancy, they are not tracked
- The referee is told "ground truth exists" — this is **intentional design** that makes it more careful, not a mistake
- Do NOT perform your own code review — your job is orchestration and presentation only
- All agents must produce structured JSON output

---

## Phase 0 — Determine Scope

If the user provided a scope (files, directory, "uncommitted changes"), use it. Otherwise ask. Default: uncommitted changes.

---

## Phase 1 — Bug-Finder Agent

Read `references/agent-prompts.md` for the bug-finder prompt template.

Launch an `Agent` (general-purpose) with the bug-finder prompt, passing the scope. This agent is incentivized to over-report — it produces the **superset** of all possible bugs.

Receives: JSON array of findings using the schema in `templates/finding-schema.json`.

---

## Phase 2 — Adversarial Agent

Read `references/agent-prompts.md` for the adversarial prompt template.

Launch an `Agent` (general-purpose) with the adversarial prompt, passing the bug-finder's full output. This agent is incentivized to disprove — it produces the **subset** of likely real bugs.

Receives: same findings array, each annotated with `adversarial_verdict` and `adversarial_reasoning`.

---

## Phase 3 — Referee Agent

Read `references/agent-prompts.md` for the referee prompt template.

Launch an `Agent` (general-purpose) with both agents' outputs. The referee resolves each dispute.

Receives: same findings array, each annotated with `referee_verdict` and `referee_reasoning`.

---

## Phase 4 — Present Results

Read `references/report-format.md` for display format. See `examples/` for concrete samples.

Show only CONFIRMED + UNCERTAIN findings. If all findings are DISPROVED: say "No confirmed issues found in the reviewed code." and **stop**.

Otherwise, ask the user which finding IDs to fix:
> "Which issues would you like me to fix? You can list IDs (e.g., BUG-001, BUG-003) or say 'all'."

**CRITICAL — next turn action:** When the user replies, your **very first tool call** MUST be `EnterPlanMode`. The plan must reference the specific findings, evidence, and fix recommendations from the report.
