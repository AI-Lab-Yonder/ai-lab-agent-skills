---
name: autoresearch
description: "Optimize an agent skill through bounded repeated trials, binary evaluations, targeted prompt mutations, and auditable keep/discard decisions. Use when asked to optimize, benchmark, evaluate, or systematically improve an existing skill. Produces an improved candidate skill, run artifacts, a results log, and a mutation changelog without overwriting the original."
version: 1.1.0
level: advanced
category: meta
---

# Autoresearch for Skills

Improve an existing agent skill through controlled experiments. Establish a baseline, change one instruction at a time, evaluate every candidate with the same suite, and retain only demonstrated improvements.

This workflow is platform-neutral. It does not assume a particular agent product, delegation tool, shell, browser, or operating system.

## Core Job

1. Define representative development and holdout scenarios.
2. Define binary pass/fail evaluations.
3. Establish a reproducible baseline.
4. Mutate a copy of the skill one targeted change at a time.
5. Keep improvements and revert regressions.
6. Stop at the approved boundary.
7. Deliver the candidate and the evidence needed to review it.

The original skill is never overwritten by this workflow.

---

## Before Starting

Do not run experiments until the user has confirmed the following:

1. **Target skill** — exact path to its main instruction file.
2. **Candidate name** — filename for the optimized copy.
3. **Runner** — how a skill plus a test input will be executed and how its output will be captured.
4. **Development scenarios** — 3-5 representative inputs used during optimization.
5. **Holdout scenarios** — 1-3 inputs used only for the baseline and final generalization check.
6. **Evaluation criteria** — 3-6 binary checks; see [references/eval-guide.md](references/eval-guide.md).
7. **Runs per scenario** — default: 5.
8. **Experiment cap** — default: 10 mutation cycles. Never default to an unlimited run.
9. **Invocation cap** — default: the planned executions plus a 20% reserve for confirmation runs and one-time retries.
10. **Additional boundary** — optional wall-clock or monetary cap when the runtime can enforce it.
11. **Artifact sensitivity** — whether prompts, outputs, or source files need redaction or restricted retention.
12. **Dashboard** — optional; disabled by default.

Explain the estimated number of executions before starting:

```text
planned development executions = development scenarios × runs per scenario × (baseline + experiment cap)
planned holdout executions = holdout scenarios × runs per scenario × 2
default invocation cap = round up((planned development + planned holdout) × 1.20)
```

Confirmation runs and retries consume the invocation cap. Allow at most one automatic retry for a failed invocation, and never start an experiment that would leave too little capacity for the final holdout run. If the user changes a cap later, recalculate the estimate.

---

## Runner and Evaluator Contract

### Runner

Use one of these platform-neutral execution modes:

- **Native runner** — the current runtime can execute the candidate skill with a supplied input and capture the result in a fresh context.
- **User-approved adapter** — a documented command or program accepts the candidate path and scenario, then writes a result artifact.

Record the selected mode and exact reproducibility details in `run-config.json`: runtime and model identifiers when available, adapter version or command template, generation settings, environment assumptions, and random seed when supported. Never put credentials in command arguments or logs.

Use the same runner configuration for the incumbent and every candidate. If there is no repeatable way to execute and capture the target skill, stop before mutation and explain what adapter is missing. Do not simulate runs and report them as experiments.

### Evaluator

Prefer checks that can be executed deterministically. For checks requiring judgment:

- Prefer a separate evaluator context that does not know which output is the candidate.
- If only same-context evaluation is possible, continue only after disclosing reduced assurance.
- Use the same evaluator configuration throughout the run.
- Record a pass/fail result and specific evidence for every check.

When output is stochastic and a candidate's improvement is only one passing check, rerun both the candidate and incumbent before deciding. Record both comparisons.

---

## Safety and Privacy

- Keep working files local by default.
- Do not introduce external services, uploads, or hosted dashboards without user approval.
- If the approved runner sends content to a hosted service, state what target content and test data will be transmitted.
- Redact secrets, personal data, private hostnames, organization names, and proprietary identifiers from shareable logs and dashboards.
- Preserve raw sensitive artifacts only in the approved working directory and retention window.
- Stop on repeated runner errors, evaluator failures, corrupted artifacts, or an exhausted budget. Report partial results instead of silently continuing.

---

## Step 1 — Read the Target Skill

Before changing anything:

1. Read the complete main instruction file.
2. Read every referenced file needed to execute the skill.
3. Identify its purpose, process, output contract, dependencies, and existing quality checks.
4. Note platform assumptions, privacy concerns, and known failure modes.
5. Record a hash or version identifier for the original.

Do not copy unrelated project content into the experiment workspace.

---

## Step 2 — Build the Evaluation Suite

Use separate development and holdout scenarios:

- **Development scenarios** drive failure analysis and mutation decisions.
- **Holdout scenarios** are evaluated only at baseline and final comparison. Do not use their failures to tune mutations.

Format each evaluation as:

```text
EVAL [number]: [Short name]
Question: [Yes/no question about the output]
Pass condition: [Specific observable evidence for yes]
Fail condition: [Specific observable evidence for no]
Evidence to record: [Command output, file path, excerpt, or observation]
```

Rules:

- Use binary checks only.
- Keep criteria distinct and tied to user value.
- Prefer observable behavior over style judgments.
- Do not encode project names, private data, or secrets in reusable eval definitions.
- Freeze the suite before the baseline. Changing it creates a new research run.

For a suite that runs every development scenario the same number of times:

```text
max_development_score = evaluations × development scenarios × runs per scenario
```

---

## Step 3 — Create the Workspace and Baseline

Create `autoresearch-[skill-name]/` in the user-approved location.

1. Copy the original instruction file to `[candidate-name].md`; mutate only this copy.
2. Save the unchanged original as `SKILL.md.baseline`.
3. Write `run-config.json` with the frozen runner, evaluator, scenarios, evals, limits, and privacy settings.
4. Create `results.tsv`, `results.json`, `changelog.md`, and `artifacts/`.
5. Run every development and holdout scenario against the unchanged candidate.
6. Save each input, complete output or output manifest, evaluation result, and evidence under `artifacts/experiment-000/`.
7. Record development and holdout baseline scores.

After the baseline, show the user the score and any runner or evaluator limitations. If the development score is already at least 90%, ask whether optimization is worth the remaining executions.

Use this `results.tsv` header:

```text
experiment\tdevelopment_score\tmax_score\tpass_rate\tstatus\tdescription
```

---

## Step 4 — Run the Bounded Experiment Loop

Repeat only within the approved limits:

1. **Analyze development failures.** Inspect failed outputs and evidence. Do not inspect holdout results for mutation ideas.
2. **Form one hypothesis.** Identify one instruction-level change likely to address the most important recurring failure.
3. **Mutate the candidate.** Make one targeted change to `[candidate-name].md`.
4. **Execute the suite.** Run all development scenarios with the frozen runner configuration.
5. **Evaluate and preserve evidence.** Store artifacts under `artifacts/experiment-[N]/` and score every check.
6. **Compare with the incumbent.**
   - Higher confirmed score: **KEEP** and make the candidate the new incumbent.
   - Lower score: **DISCARD** and restore the incumbent.
   - Equal score: **DISCARD** by default. Keep only when a secondary objective defined in `run-config.json` before baseline—such as fewer instructions, lower latency, or lower cost—measurably improves without weakening any primary check.
7. **Log the decision.** Update `results.tsv`, `results.json`, and `changelog.md`.
8. **Check stop conditions.** Stop instead of starting another mutation when any condition is met.

Good mutations include clarifying an ambiguous instruction, moving a critical constraint earlier, removing a conflicting rule, or adding one focused example. Avoid broad rewrites and bundles of unrelated changes because they make causality unclear.

Stop when:

- The user cancels the run.
- Any approved experiment, execution, time, or cost cap is reached.
- Development pass rate is at least 95% for three consecutive kept/incumbent measurements.
- The runner or evaluator repeatedly fails.
- No defensible single-change hypothesis remains.

Set the final status to `complete`, `budget_exhausted`, `cancelled`, `runner_failed`, or `ideas_exhausted` as appropriate. Never label a partial or failed run complete.

---

## Step 5 — Run the Final Holdout Check

After the loop, run the frozen holdout suite against the final incumbent using the baseline configuration.

- If holdout performance improves or remains stable, report it as evidence of generalization.
- If holdout performance declines, do not claim the skill improved generally. Keep the original untouched and present the candidate as a development-only result requiring review.
- Do not tune on the holdout after seeing the result. A revised holdout or eval suite starts a new run.

---

## Step 6 — Maintain the Changelog

After every experiment, append:

```markdown
## Experiment [N] — [keep/discard]

**Development score:** [X]/[max] ([percent]%)
**Change:** [One sentence]
**Hypothesis:** [Why it might help]
**Evidence:** [Artifact paths and material observations]
**Decision:** [Why it was kept or discarded]
**Remaining failures:** [What still fails]
```

The changelog must include discarded experiments and operational failures, not only successful mutations.

---

## Step 7 — Optional Offline Dashboard

Generate `dashboard.html` only if the user requested it.

The dashboard must:

- Be a single self-contained file with inline CSS, JavaScript, and data.
- Use no CDN, remote font, analytics, or network request.
- Show development score progression, keep/discard status, experiment descriptions, per-eval results, current state, and configured limits.
- Reload itself every 10 seconds if live updates are desired; rewrite the embedded data after each experiment.
- Display only redacted information approved for the dashboard.

Do not invoke an operating-system-specific opener. Print the file path, or use a runtime-provided local preview capability when available and requested.

---

## Step 8 — Deliver Results

Present:

1. Development baseline and final scores.
2. Holdout baseline and final scores.
3. Number of experiments, keeps, discards, and failed runs.
4. Runner mode, evaluator mode, limits reached, and assurance caveats.
5. The most effective mutations.
6. Remaining failure patterns.
7. Paths to the candidate, configuration, logs, artifacts, and optional dashboard.

Do not overwrite or offer to overwrite the original automatically. The user reviews and applies the candidate separately.

## Workspace Layout

```text
autoresearch-[skill-name]/
├── [candidate-name].md
├── SKILL.md.baseline
├── run-config.json
├── results.tsv
├── results.json
├── changelog.md
├── artifacts/
│   ├── experiment-000/
│   └── experiment-001/
└── dashboard.html          # optional
```

## Quality Gate

A valid run:

1. Measures the unchanged baseline.
2. Uses a documented, consistent runner and evaluator.
3. Stores outputs and scoring evidence.
4. Uses frozen binary evaluations.
5. Changes one thing per experiment.
6. Operates within explicit limits.
7. Separates development and holdout decisions.
8. Leaves the original skill unchanged.
9. Reports uncertainty and failures honestly.

If scores improve but holdout quality declines, the result is overfitting—not a successful optimization.
