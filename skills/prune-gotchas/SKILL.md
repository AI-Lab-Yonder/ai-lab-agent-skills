---
name: prune-gotchas
description: "Interactive review and consolidation of gotchas.md files across skills. Auto-suggested when any gotchas exceeds 30 entries, or invoke manually anytime. Use when: gotchas files are growing large, entries overlap, or you want to clean up accumulated lessons."
version: 1.0.0
level: advanced
category: meta
---

# Gotchas Pruning — Interactive Review

## Step 1: Scan all gotchas files

Run: `ls -la <skills-directory>/*/gotchas.md`

For each file, count entries: `grep -c "^- \*\*" <file>`

Present a summary table:

| Skill | Entries | Status |
|-------|---------|--------|
| api-builder | 34 | Over threshold |
| auth-system | 12 | Fine |
| ... | ... | ... |

Ask the user: "Which skill(s) do you want to review? Or should I start
with the largest?"

## Step 2: Review one skill at a time

For the selected skill's gotchas.md:

1. Read the full file
2. Group entries by category (BUG, ARCHITECTURE, MISUNDERSTANDING)
3. Identify candidates for action:
   - **MERGE**: entries that say roughly the same thing in different words
   - **REMOVE**: entries that are obvious, outdated, or project-specific
     rather than universal
   - **REFINE**: entries that are vague and could be made sharper
   - **KEEP**: entries that are clear, specific, and still relevant

## Step 3: Present proposals one group at a time

For each proposed action, show the user exactly what will change:

**Merge proposal:**
> These 3 entries overlap:
> 1. `- **[BUG]** Prisma findUnique returns null → check with if (!user)`
> 2. `- **[BUG]** Prisma queries return null not undefined → always null-check`
> 3. `- **[BUG]** ORM returns null when no match → don't check === undefined`
>
> Proposed merge:
> `- **[BUG]** ORM queries (Prisma, Drizzle, etc.) return null not undefined when no match → Always use if (!result) not if (result === undefined)`
>
> Accept / Edit / Skip?

**Removal proposal:**
> This entry seems obvious:
> `- **[BUG]** Missing await on async function → Always await async calls`
>
> Remove? Yes / Keep

**Refinement proposal:**
> This entry is vague:
> `- **[ARCHITECTURE]** Don't put logic in wrong layer`
>
> Suggested refinement:
> `- **[ARCHITECTURE]** Business logic belongs in service layer, not route handlers or middleware → Route handlers only parse input and call services`
>
> Accept / Edit / Skip?

## Step 4: Apply changes

After all proposals are reviewed:
1. Back up the original: copy gotchas.md to gotchas.md.bak
2. Apply all accepted changes
3. Show a final summary:
   - Entries before: X
   - Entries after: Y
   - Merged: N, Removed: N, Refined: N
4. Ask: "Move to the next skill, or done for now?"

## Rules
- NEVER remove or merge without explicit user approval
- Show exact before/after for every change
- Preserve the newest timestamp when merging entries
- Keep entries grouped by category: ## BUG, ## ARCHITECTURE, ## MISUNDERSTANDING
- Always create a .bak backup before writing changes
- If user says "skip" on a proposal, leave those entries untouched
