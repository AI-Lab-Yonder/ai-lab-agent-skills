---
name: skill-builder
description: "Create well-structured agent skills following cross-platform best practices. Use when building a new skill, improving an existing one, or creating automation for a recurring workflow."
version: 1.1.0
level: advanced
category: meta
---

# Skill Builder

Meta-skill for creating agent skills that follow cross-platform best practices. Ensures consistent quality, proper progressive disclosure, and effective trigger descriptions across all skills.

## Constraints

- Never create a skill that duplicates an existing one — always check the active platform's user-level and repository-level skill roots first
- Skills are folders, not just markdown files — always design the folder structure
- The description field is for model triggering (when to activate), not a summary
- Don't state the obvious — only include knowledge that pushes the executing agent beyond its defaults
- Avoid railroading — give information + flexibility, not rigid step-by-step instructions

## Phase 0 — Understand What the User Wants

Before designing anything, understand the skill's purpose:

1. Ask the user to describe the workflow they want to automate (or the problem the skill solves)
2. Classify into one of the 9 categories — read `references/skill-categories.md` for classification guidance
3. Determine scope: Is this a user-level skill or a repository-specific skill? Use the active platform's corresponding skill roots.
4. Check for existing skills that overlap — search both global and project skill directories

Print the classification and ask the user to confirm before proceeding.

## Phase 1 — Design the Folder Structure

Read `references/anatomy.md` for the folder anatomy guide. Design the skill's folder structure based on its category.

Every skill gets:
- `SKILL.md` — main definition with frontmatter, constraints, and phases
- `gotchas.md` — failure points section (starts minimal, grows over time)

Then add category-specific folders. Read `references/skill-categories.md` for what each category typically needs.

Think about progressive disclosure: what should the executing agent see immediately (SKILL.md) vs. read on-demand (references/, examples/)?

Present the proposed folder structure to the user and confirm.

## Phase 2 — Write the Description

The description field determines when an agent activates the skill. It should answer: "In what situation should this skill be triggered?"

Read `references/best-practices.md` for guidance on writing effective descriptions.

Rules:
- Start with an action verb: "Create...", "Generate...", "Verify...", "Investigate..."
- Include the trigger condition: "Use when [specific scenario]"
- Be specific enough to avoid false triggers, broad enough to catch relevant requests
- Under 200 characters

Show the draft description to the user for feedback.

## Phase 3 — Write the Skill Content

Read `references/best-practices.md` for content writing guidance. Then:

1. **Write SKILL.md** using `templates/SKILL.md.tmpl` as the starting structure:
   - Frontmatter (name, description, version, level, category)
   - Constraints section (what the skill must NOT do)
   - Phases (the step-by-step workflow — but flexible, not railroading)
   - Reference pointers: tell the executing agent which files in the skill folder to read and when

2. **Write reference files** — detailed knowledge the executing agent reads on-demand:
   - Focus on non-obvious knowledge (gotchas, edge cases, decisions)
   - Don't duplicate what a capable agent already knows about standard tools/libraries
   - Use progressive disclosure: SKILL.md says "read references/X.md for details on Y"

3. **Write templates/scripts** — artifacts the skill uses:
   - Templates: files with clear placeholder markers the skill fills in
   - Scripts: executable code the agent can run or compose with
   - Examples: concrete reference implementations (not abstract)

4. **Write gotchas.md** using `templates/gotchas.md.tmpl`:
   - Start with empty sections (topic headings only, no content) — gotchas must come from real failures, never speculation
   - Include instructions for how to add new gotchas over time
   - Organize by sub-topic or phase relevant to the skill

## Phase 4 — Consider Setup & State

Does the skill need persistent configuration?
- If yes: create a `config.json` pattern where the first run asks user questions through the platform's structured question mechanism, or normal conversation when unavailable, and stores answers
- If the skill produces outputs over time: plan where to store data (append-only log, JSON file, etc.)

Does the skill need on-demand hooks?
- If it should block certain actions during execution: define the platform's pre-action lifecycle hooks when supported
- If it should react to tool outputs: define the platform's post-action lifecycle hooks when supported
- Only add hooks if they're genuinely useful — having them always-on is annoying

## Phase 5 — Review Against Best Practices Checklist

Before finalizing, verify against `references/best-practices.md` checklist:

- [ ] Description is a trigger condition, not a summary
- [ ] SKILL.md doesn't state what a capable agent already knows
- [ ] Gotchas section exists with empty sections ready for real failures
- [ ] Progressive disclosure: detailed info in sub-files, not all in SKILL.md
- [ ] Flexible instructions: gives info + room to adapt, not rigid commands
- [ ] Folder structure matches the category pattern
- [ ] Setup/config handled if needed
- [ ] No overlap with existing skills

## Phase 6 — Generate All Files

Create all files in the skill folder. After creation, print:

```
Skill created: <name>

Location: <path>
Category: <category>
Files:
  <tree listing>

To use: Invoke <name> with [arguments] through the active platform's skill mechanism
To improve: Add gotchas as you discover failure points
To share: Place it in the active platform's repository-level skill root for team use
```
