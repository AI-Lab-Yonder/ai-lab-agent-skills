---
name: docs-scaffold
description: "Organize raw project documentation into a focused, cross-linked docs/ structure with an adaptive INDEX.md and a recommended AGENTS.md entry point. Preserve the source's natural document types; create stories only when they already exist and incremental slices only when the user wants them. Use when starting from raw documentation or restructuring scattered project docs."
level: advanced
category: documentation
version: 1.1.0
---

# Docs Scaffold

Take raw project documentation and produce a structured `docs/` folder that people and AI agents can navigate efficiently. Split monolithic files into focused documents without forcing every project into the same folder model.

This skill creates the structure. The companion `resolve-docs` skill can help resolve gaps afterward.

## Constraints

- Never invent content; unsupported details become entries in `decisions/open-questions.md`
- Check reference file sizes before loading; read `references/large-files.md` for the protocol
- Confirm both the source understanding and the planned structure before creating files
- Preserve the source's natural content types; do not manufacture stories, tasks, or slices to fill a template
- Create `stories/` only for explicit source stories and `slices/` only after the user approves an incremental breakdown
- When work units are selected, keep one independently assignable work unit per file
- Recommend AGENTS.md as the general project-instructions entry point, but inspect existing instruction files and help the user choose before creating or changing one
- Do not duplicate content; keep one canonical location and link from related documents
- Do not add source-file or heading provenance to generated documents unless the user explicitly requests it
- Read `gotchas.md` before starting

## Phase 0 — Understand the Source Material

Read every input file the user provides, following the large-file protocol when necessary. Identify:

- Project purpose, domain, and boundaries
- Existing content types: architecture, requirements, guides, operations, decisions, API material, reference data, or others
- Components and responsibilities
- Explicit stories, tasks, milestones, or delivery phases, if any
- Whether an incremental slice plan would be useful or was requested
- External systems, APIs, databases, and services
- Cross-cutting concerns that appear in multiple places
- Domain terminology, mixed languages, and jargon
- Sensitive or restricted reference material that should not be copied

Present a structured summary and wait for confirmation before planning files.

## Phase 1 — Plan an Adaptive Folder Structure

Design the `docs/` tree from the confirmed content. Only include folders and INDEX sections that have content. Always include `decisions/open-questions.md`, even when it initially states that no open questions were found.

Choose the work-unit treatment explicitly:

| Source and user intent | Result |
|---|---|
| Reference or explanatory documentation only | No `stories/` or `slices/` folder |
| Source contains explicit user stories that should remain stories | `stories/`, one source story per file |
| User wants independently deliverable increments and approves the proposed boundaries | `slices/`, one incremental slice per file |
| Intent is unclear | Show the options and ask; do not choose a work-unit folder by default |

Present the planned tree, label optional choices, explain why each folder exists, and get confirmation before creating files.

See `examples/synthetic-docs-session.md` for documentation-only and optional-slice examples.

## Phase 2 — Split and Create Files

Read `references/splitting-rules.md` for content routing, work-unit structures, and cross-reference rules.

Identify shared concerns before writing documents. Put system-wide rationale and constraints in architecture docs; put actionable repeated rules in `conventions/`. Link between them instead of duplicating text.

When using the templates, remove every unused optional block, placeholder, and template comment from the final files.

## Phase 3 — Create INDEX.md

Use `templates/INDEX.md.tmpl` as a flexible starting point, not a required section list.

INDEX.md must contain:

- Task-oriented navigation instructions based on the folders that actually exist
- One section per included folder, with links and one-line descriptions
- No empty or placeholder sections
- Warnings for large or restricted references that should not be auto-loaded

## Phase 4 — Create or Reconcile AGENTS.md

Use `templates/AGENTS.md.tmpl` as an adaptive starting point. Recommend `AGENTS.md` at the project root as the general default, then inspect existing root instruction files before writing.

| Existing state | Recommendation to present |
|---|---|
| No project instruction file | Create AGENTS.md from the template |
| AGENTS.md exists | Propose a merge; never overwrite it |
| A different instruction file exists | Offer to keep it, add AGENTS.md, or make one canonical and keep the other as a short pointer |
| Multiple instruction files exist | Choose one canonical source with the user and remove duplicated guidance from the others |

Individual tools may use additional filenames, so explain the trade-off and let the user decide. Keep AGENTS.md sections only when their corresponding docs or rules exist.

## Phase 5 — Populate Open Questions

Use `templates/open-questions.md.tmpl`. Capture undefined terms, missing decisions, contradictions, vague sections, and explicit placeholders.

- Number questions sequentially: OQ-1, OQ-2, ...
- Group them by useful categories
- Assign a priority and status
- If none exist, state that clearly instead of leaving template placeholders

## Phase 6 — Handle Large or Restricted References

Read `references/large-files.md` for the full protocol.

- Check size, format, relevance, and sensitivity before loading
- Distill only material relevant to the generated documentation or approved work units
- Map distilled material to related documents or work units when that helps navigation
- Do not copy raw references into the repository without user approval and a confidentiality, licensing, and version-control check
- Prefer linking to an existing approved location when copying is unnecessary

## Phase 7 — Verify and Summarize

Before presenting the result:

1. Remove unused template sections, comments, and placeholders.
2. Check that every INDEX link resolves.
3. Check that cross-links do not create duplicate canonical content.
4. Confirm that no stories or slices were created without the selected work-unit mode.
5. List created and modified files, important open questions, skipped references, and any remaining limitations.

Recommended next step: use the `resolve-docs` skill to work through unresolved questions.
