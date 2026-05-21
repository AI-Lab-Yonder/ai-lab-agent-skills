---
name: docs-scaffold
description: "Scaffold a structured docs/ folder from initial markdown files (architecture, stories, API specs). Splits monolithic docs into focused, cross-linked files with an INDEX.md entry point and AGENTS.md at project root. Use when starting a project with raw documentation, onboarding a codebase to AI-assisted development, or restructuring scattered docs for AI-DLC workflows."
level: advanced
category: documentation
version: 1.0.0
---

# Docs Scaffold

Take raw project documentation and produce a structured `docs/` folder that AI agents can navigate efficiently. Splits monolithic files into focused, cross-linked documents with an INDEX.md entry point and AGENTS.md at the project root.

Companion skill to `/resolve-docs` — this skill creates the structure, `/resolve-docs` fills the gaps.

## Constraints

- Never invent content — unknowns become entries in `decisions/open-questions.md`, not guesses
- Check reference file sizes before loading — read `references/large-files.md` for the protocol
- Always confirm understanding AND planned structure before creating any files (two checkpoints)
- One story per file — never combine stories even if short
- Use AGENTS.md (not CLAUDE.md) at project root for tool-universality
- Do not duplicate content — one canonical location, link from others
- Read `gotchas.md` before starting

## Phase 0 — Read Source Material

Read every input file the user provides. Build a mental model:

- What is this project? Purpose, domain, landscape position
- What are the components/layers? Responsibilities and boundaries
- What stories/tasks exist? Grouped by feature or layer
- What external systems are involved? APIs, databases, services
- What cross-cutting concerns exist? Patterns appearing in 2+ stories (logging, retry, auth, status tracking)
- What domain terminology is used? Mixed languages, jargon

Present a structured summary and wait for confirmation before proceeding.

## Phase 1 — Plan Folder Structure

Design the `docs/` structure based on source content. Only include folders that have content — not every project needs every folder. Always include `decisions/open-questions.md`.

Present the planned tree to the user and get confirmation before creating files.

See `examples/erp-adapter-session.md` for a real-world example of the output structure.

## Phase 2 — Split and Create Files

Read `references/splitting-rules.md` for detailed routing rules: which content goes where, story file structure, and cross-reference conventions.

Key principle: identify cross-cutting concerns FIRST and extract them into `conventions/` BEFORE writing story files. This prevents duplication.

## Phase 3 — Create INDEX.md

Use `templates/INDEX.md.tmpl` as the starting structure. INDEX.md must contain:

- "How to Use" navigation instructions (not just a file list)
- A section per folder with file links and one-line descriptions
- Warnings about large reference files that should not be auto-loaded

## Phase 4 — Create AGENTS.md

Use `templates/AGENTS.md.tmpl` as the starting structure. Create at the **project root** (not inside `docs/`).

If an AGENTS.md or CLAUDE.md already exists, present the proposed additions and ask the user how to reconcile.

## Phase 5 — Populate Open Questions

Use `templates/open-questions.md.tmpl` as the starting structure. Populate with gaps discovered during scaffolding: undefined terms, missing decisions, contradictions, vague sections, "TBD" markers.

Number questions sequentially (OQ-1, OQ-2, ...) grouped by category.

## Phase 6 — Handle Large Reference Files

Read `references/large-files.md` for the full protocol. Key points:

- Check file size first — small files (under ~200KB) can be loaded directly; for large files, ask the user with file name and approximate size
- Distill only relevant endpoints/schemas into a readable markdown doc
- Include a mapping table connecting endpoints to stories
- Store the original in `api/specs/` with clear warnings

## Phase 7 — Summary and Next Steps

Present a summary of all created files, highlight the most critical open questions, and recommend:

```
Recommended next step: Run /resolve-docs to work through the open questions interactively.
```
