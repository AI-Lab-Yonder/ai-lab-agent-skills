# Example: Product Verification Skill

## Use Case

Verify that a user-facing flow works correctly end-to-end (signup, checkout, onboarding, etc.) with programmatic assertions and evidence capture.

## Folder Structure

```
verify-<flow>/
├── SKILL.md                  # Orchestrate verification
├── gotchas.md                # Common false positives/negatives
├── scripts/
│   ├── setup.sh              # Start dev servers, seed test data
│   ├── run-flow.py           # Playwright/browser automation
│   └── assert-state.py       # Verify final state (DB, API, etc.)
└── fixtures/
    └── test-data.json        # Seed data for the flow
```

## Key Pattern: Programmatic Assertions

Don't just check if pages render — assert on actual system state:

- **Database records**: Were the right rows created/updated?
- **API responses**: Do endpoints return expected data after the flow?
- **Side effects**: Were emails sent? Webhooks fired? Logs written?
- **Error states**: Does invalid input produce the right error? Does network failure degrade gracefully?

Each assertion should produce a clear pass/fail with context on what was checked.

## Key Pattern: Evidence Capture

Record evidence of what was tested for debugging and audit:

- **Screenshots** at each major step (before/after actions)
- **Video** of the full flow for visual regression
- **Network logs**: request/response pairs for API calls
- **Final report**: structured pass/fail per step with evidence links

Store evidence in a timestamped folder for easy comparison across runs.

## SKILL.md Excerpt

**Phase 0 — Check Prerequisites**
Verify dev servers are running, test database is seeded, required services are available. If not, run `scripts/setup.sh` to prepare the environment.

**Phase 1 — Execute the Flow**
Run the user flow via browser automation (`scripts/run-flow.py`). Capture screenshots at each step. Log all network requests.

**Phase 2 — Assert State at Each Step**
Don't just check the final state — verify intermediate states too. Run `scripts/assert-state.py` after each major action in the flow.

**Phase 3 — Capture Evidence**
Collect screenshots, video, network logs, and assertion results into a timestamped evidence folder.

**Phase 4 — Report Results**
Print a structured report:
```
Flow: signup
Status: PASS (7/7 steps)

Step 1: Load signup page .......... PASS
Step 2: Fill form ................. PASS
Step 3: Submit .................... PASS
Step 4: Verify email sent ......... PASS
Step 5: Click confirmation link ... PASS
Step 6: Check user in database .... PASS
Step 7: Verify welcome screen ..... PASS

Evidence: /tmp/verify-signup/2026-03-18T14:30:00/
```

## Why This Works

- Catches regressions that unit tests miss (integration boundaries)
- Evidence makes failures easy to diagnose
- Scriptable assertions are deterministic — no "it looks right to me"
- Reusable across environments (dev, staging, prod)
