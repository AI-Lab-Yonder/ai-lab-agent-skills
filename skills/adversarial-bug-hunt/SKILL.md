---
name: adversarial-bug-hunt
description: Use when reviewing code for bugs with finder, challenger, and referee roles, especially when independent review is needed to reduce false positives.
version: 1.1.0
level: advanced
category: code-quality
---

# Adversarial Bug Hunt

Three-role bug discovery pipeline. A bug-finder over-reports, an adversarial reviewer challenges, and a referee resolves. Prefer clean, isolated contexts; when the runtime cannot provide them, use the documented reduced-assurance fallback instead of inventing platform-specific tools.

## Constraints

- Read `gotchas.md` before starting
- Select an execution mode before reviewing; use the strongest mode the current runtime actually supports
- Prefer a separate clean context for each role to prevent cross-contamination
- Same-context sequential execution is allowed only as the disclosed reduced-assurance fallback
- Scoring numbers are a **prompt technique** — they bias agent behavior via sycophancy, they are not tracked
- The referee is told "ground truth exists" — this is **intentional design** that makes it more careful, not a mistake
- Do not add an extra, unstructured review outside the selected three-role pipeline
- All roles must produce structured JSON output

---

## Runtime Mode

Choose the first available mode. Do not assume tool names or ask the user to install another agent runtime.

| Mode | How to run the roles | Assurance |
|---|---|---|
| **Isolated workers** | Launch each role with the runtime's native delegation mechanism in a separate clean context | Preferred |
| **External isolated sessions** | Run each role in a separate available process or session that can read the review scope | Preferred |
| **Sequential fallback** | Run the three prompt templates as separate passes in the current context, preserving each JSON handoff | Reduced |

For sequential fallback, tell the user before Phase 1:

> This runtime cannot isolate the three reviewers. I can run the same finder → adversarial → referee pipeline sequentially, but the roles may influence one another, so the result has reduced assurance.

Record the selected mode in the final report. Never describe sequential fallback as independent or clean-context review.

---

## Phase 0 — Determine Scope

If the user provided a scope (files, directory, "uncommitted changes"), use it. Otherwise ask. Default: uncommitted changes.

---

## Phase 1 — Bug-Finder Agent

Read `references/agent-prompts.md` for the bug-finder prompt template.

Run the bug-finder prompt with the selected execution mode, passing the scope. In an isolated mode, start a fresh worker or session. In sequential fallback, run it as the first pass. The role is incentivized to over-report and produces the **superset** of possible bugs.

Receives: JSON array of findings using the schema in `templates/finding-schema.json`.

---

## Phase 2 — Adversarial Agent

Read `references/agent-prompts.md` for the adversarial prompt template.

Run the adversarial prompt with the selected execution mode, passing the bug-finder's full JSON output. Use a fresh context in either isolated mode; otherwise run it as the second sequential pass. The role is incentivized to disprove and produces the **subset** of likely real bugs.

Receives: same findings array, each annotated with `adversarial_verdict` and `adversarial_reasoning`.

---

## Phase 3 — Referee Agent

Read `references/agent-prompts.md` for the referee prompt template.

Run the referee prompt with the selected execution mode, passing both prior outputs. Use a fresh context in either isolated mode; otherwise run it as the third sequential pass. The referee resolves each dispute.

Receives: same findings array, each annotated with `referee_verdict` and `referee_reasoning`.

---

## Phase 4 — Present Results

Read `references/report-format.md` for display format. See `examples/` for concrete samples.

Show only CONFIRMED + UNCERTAIN findings. If all findings are DISPROVED: say "No confirmed issues found in the reviewed code." and **stop**.

Otherwise, ask the user which finding IDs to fix:
> "Which issues would you like me to fix? You can list IDs (e.g., BUG-001, BUG-003) or say 'all'."

When the user replies, prepare a fix plan before editing. Use the runtime's native planning mode when one exists; otherwise present the plan directly in chat and wait for approval. The plan must reference the selected findings, evidence, and fix recommendations from the report.
