---
name: postmortem
description: "Capture a lesson learned from a bug, architecture mistake, or misunderstanding into the relevant skill's gotchas.md. Use after any correction or failure to build persistent knowledge across sessions."
version: 1.0.0
level: advanced
category: meta
---

# Post-Mortem Protocol

Capture lessons from mistakes so they're never repeated. AI agents have no memory across sessions — a gotchas.md file is lightweight persistent learning.

## 1. Classify
- **BUG** — code didn't work (test, runtime, type, or lint error)
- **ARCHITECTURE** — wrong structural choice (abstraction, pattern, layer, coupling)
- **MISUNDERSTANDING** — misinterpreted user's intent (built wrong thing, wrong conventions)

## 2. Identify the target skill
- Check conversation context for which skill was active
- List available gotchas files in your skills directory
- If ambiguous, ask: "Which skill does this belong to?"

## 3. Read existing gotchas
Read the target skill's gotchas.md. Check for:
- Duplicates → skip
- Similar entries → refine instead of adding
- Contradictions → resolve (keep the newer, more accurate one)

## 4. Write the entry

**BUG:** `- **[BUG]** <what broke> → <prevention rule>`
**ARCHITECTURE:** `- **[ARCHITECTURE]** <wrong choice> → <correct approach>: <why>`
**MISUNDERSTANDING:** `- **[MISUNDERSTANDING]** Interpreted "<input>" as <wrong> → Correct: <right>`

Rules:
- Max 2 sentences — specific, actionable
- MUST be project-agnostic — universal lesson, not current-project-specific
- Timestamp: `<!-- ISO-8601 -->`

## 5. Confirm
"Captured to <skill>/gotchas.md: <one-line summary>"
