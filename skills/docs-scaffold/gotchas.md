# Gotchas

Known failure points for this skill. **Update this file** whenever the skill produces incorrect output or hits a new edge case.

## Format

Each gotcha follows this pattern:
- **What goes wrong**: description of the failure
- **Why**: root cause
- **Fix**: how to avoid or work around it

---

## Large Reference Files

- **What goes wrong**: Agent auto-loads a 4.3MB OpenAPI spec, consuming most of the context window, degrading quality of all subsequent output.
- **Why**: The agent sees a JSON file referenced in the docs and reads it eagerly without checking size.
- **Fix**: Always ask the user before loading any file in `api/specs/`. Add explicit "do not auto-load" warnings in INDEX.md, the distilled API doc, and AGENTS.md. Search for specific paths/schemas instead of reading the full file.

- **What goes wrong**: Distilled API doc lacks a mapping table connecting endpoints to stories, so developers don't know which endpoints matter for their story.
- **Why**: The distillation focused on extracting schemas and endpoint details but forgot to bridge back to the stories.
- **Fix**: Always include a "Mapping to Stories" table at the bottom of distilled API docs showing: Story | Primary Endpoint | Operation.

## Cross-Cutting Concerns

- **What goes wrong**: Logging/status tracking pattern is described separately in each story file, creating duplication and inconsistency.
- **Why**: Cross-cutting concerns feel like "part of each story" during splitting, so they get copied into every story instead of extracted into `conventions/`.
- **Fix**: Before writing story files, identify patterns that appear in 2+ stories. Extract these into `conventions/` first, then link from each story.

## Story Splitting

- **What goes wrong**: Two short stories get combined into one file "for convenience", causing confusion when different developers own different stories.
- **Why**: The stories seemed related or small enough to merge.
- **Fix**: One story per file, always. Even a 10-line story gets its own file. Stories are the unit of work assignment.

## Domain Glossary

- **What goes wrong**: Agent uses inconsistent naming throughout the generated docs — mixing Dutch and English terms, or using different English translations for the same Dutch term.
- **Why**: Without a glossary created first, the agent has no canonical mapping to follow.
- **Fix**: If the source material contains non-English terms or domain jargon, create `domain/glossary.md` BEFORE writing other files. Reference it during all subsequent file creation.

## INDEX.md Quality

- **What goes wrong**: INDEX.md is a flat file list with no navigation guidance. AI agents don't know which file to read first for their task.
- **Why**: The skill generated a table of contents but skipped the "How to Use" instructions.
- **Fix**: INDEX.md must start with a "How to Use This Index" section with scenario-based instructions: "Starting a story? Read X. Need API details? Read Y first."

## Confirmation Checkpoints

- **What goes wrong**: Agent creates 14 files based on a misunderstanding of the project, then the user has to ask for all of them to be redone.
- **Why**: The skill skipped the confirmation step and went straight to file creation.
- **Fix**: Always present understanding (Phase 0) AND planned structure (Phase 1) for explicit user confirmation before creating any files. Two checkpoints, not one.

## Content Invention

- **What goes wrong**: Agent fills in plausible-looking technical details that were not in the source material (e.g., inventing database schema fields, guessing API response formats).
- **Why**: The agent tries to be helpful by filling gaps rather than flagging them.
- **Fix**: Anything not explicitly in the source material goes into `open-questions.md` as a gap, never into the docs as assumed fact. The strict rule: if you can't point to the source line, it's an open question.

## AGENTS.md vs CLAUDE.md

- **What goes wrong**: Skill creates CLAUDE.md, which only works with Claude Code. Other AI tools (Codex, etc.) don't read it.
- **Why**: CLAUDE.md is a Claude Code-specific convention.
- **Fix**: Use AGENTS.md for the project root file. This is tool-universal. If a CLAUDE.md already exists, ask the user how to reconcile rather than overwriting.
