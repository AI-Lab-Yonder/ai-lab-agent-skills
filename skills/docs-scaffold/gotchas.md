# Gotchas

Known failure points for this skill. **Update this file** whenever the skill produces incorrect output or hits a new edge case.

## Format

Each gotcha follows this pattern:
- **What goes wrong**: description of the failure
- **Why**: root cause
- **Fix**: how to avoid or work around it

---

## Large Reference Files

- **What goes wrong**: The agent auto-loads a multi-megabyte structured reference, consuming too much context and degrading later output.
- **Why**: A referenced file is read eagerly without checking its size, relevance, format, or sensitivity.
- **Fix**: Inspect metadata first. For large or restricted files, ask before loading and search targeted sections instead of reading the whole file.

- **What goes wrong**: A distilled reference has no connection to the documents or approved work units that use it.
- **Why**: Distillation captures technical details but omits navigation back to the rest of the documentation.
- **Fix**: Add a mapping table when relationships matter: related document or work unit, reference item, and purpose.

- **What goes wrong**: A raw specification is copied into version control even though it is restricted, licensed separately, or already stored elsewhere.
- **Why**: The workflow treats `api/specs/` as a required destination rather than an optional approved location.
- **Fix**: Do not copy by default. Confirm confidentiality, licensing, repository policy, and user intent; otherwise link to the approved existing location.

## Cross-Cutting Concerns

- **What goes wrong**: The same logging, status, retry, or security guidance is repeated across several documents or work units.
- **Why**: Shared concerns are handled locally while splitting instead of being identified across the complete source set.
- **Fix**: Extract system rationale into architecture and actionable repeated rules into conventions, then link instead of duplicating.

## Forced Work Units

- **What goes wrong**: The skill creates a `stories/` or `slices/` folder for reference-only documentation that has no work assignments.
- **Why**: Earlier constraints, templates, and examples treated stories as the default structure.
- **Fix**: Default to no work-unit folder. Preserve `stories/` only for explicit source stories; create `slices/` only after the user approves an incremental breakdown.

## Domain Glossary

- **What goes wrong**: Generated docs use inconsistent names for the same concept across languages or teams.
- **Why**: No canonical glossary is established before other documents are written.
- **Fix**: When the source uses mixed languages or domain jargon, create the glossary before documents that depend on those terms.

## INDEX.md Quality

- **What goes wrong**: INDEX.md contains empty template sections or a flat list with no navigation guidance.
- **Why**: The template is treated as a required folder checklist rather than an adaptive starting point.
- **Fix**: Remove unused blocks and write task-oriented navigation for the folders that actually exist.

## Confirmation Checkpoints

- **What goes wrong**: Many files are created from a mistaken understanding or an unwanted work-unit model.
- **Why**: The workflow skips confirmation of the source summary or planned tree.
- **Fix**: Confirm understanding and structure separately. The structure checkpoint must explicitly show whether stories, slices, or neither will be created.

## Content Invention

- **What goes wrong**: Generated docs contain plausible technical details that were neither present in the source nor confirmed by the user.
- **Why**: The agent fills gaps to make documents appear complete.
- **Fix**: Put unsupported details in `open-questions.md`; do not present them as facts.

## Project Instruction Files

- **What goes wrong**: The skill overwrites an existing instruction file or creates duplicated, conflicting guidance across several root files.
- **Why**: It assumes one filename must replace every existing convention.
- **Fix**: Recommend AGENTS.md as the general default, inspect existing instruction files, and let the user choose one canonical source plus short pointers where needed.
