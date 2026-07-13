# Gotchas

Known failure points for this skill. **Update this file** whenever an agent runtime hits a new edge case or the skill produces incorrect output.

## Format

Each gotcha follows this pattern:
- **What goes wrong**: description of the failure
- **Why**: root cause
- **Fix**: how to avoid or work around it

---

## Role Prompts

_No gotchas yet. Add them as you discover issues._

## Inter-Role Handoff

_No gotchas yet._

## Runtime Mode

- **What goes wrong**: The pipeline stops because a runtime has no tool with the expected worker name.
- **Why**: The orchestration assumed one platform's tool contract instead of checking available capabilities.
- **Fix**: Select isolated workers, external isolated sessions, or the disclosed sequential reduced-assurance fallback.

## Presentation

_No gotchas yet._

## Fix Planning Transition

- **What goes wrong**: The workflow cannot continue after issue selection because the runtime has no dedicated planning mode.
- **Why**: Fix planning was coupled to a named platform tool.
- **Fix**: Use native planning when available; otherwise present the plan in chat and wait for approval before editing.
