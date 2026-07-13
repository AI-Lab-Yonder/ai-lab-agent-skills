---
name: prune-gotchas
description: "Interactively review and consolidate existing gotchas.md files within an explicitly selected skills root. Use when lessons have accumulated, overlap, conflict, contain stale or sensitive context, or need clearer scope and conditions."
version: 1.1.0
level: advanced
category: meta
---

# Gotchas Pruning — Interactive Review

Improve existing gotcha collections without losing useful context or changing guidance without approval. Work one file and one proposal at a time.

## Constraints

- Operate only on existing `gotchas.md` files beneath a skills root selected by the user or established by the current repository.
- Never create a new gotchas file as part of pruning.
- Never merge, remove, refine, sanitize, or relocate an entry without explicit approval for that proposal.
- Show the exact before and proposed after text, except that secret values and sensitive identifiers must always be redacted.
- Preserve the target file's organization and conventions unless the user separately approves restructuring.
- Distinguish repository-local guidance from shared or globally installed skills. Editing a shared or global file requires explicit approval for that scope.
- Base removals and conflict resolution on evidence, not subjective obviousness or timestamp recency.
- Do not create backup files automatically.

## Step 1 — Establish scope

Identify the skills root to inspect and state its absolute path. If multiple repository-local, user-level, or installed roots are plausible, ask the user which root is in scope.

Determine whether the selected root is:

- repository-local;
- user-level or shared; or
- part of an installed package or plugin.

Scan recursively for existing files named `gotchas.md`. Do not assume a one-directory-deep layout or require a particular shell command. Exclude dependency, cache, generated, and version-control directories unless the selected skills root intentionally lives within one.

If no existing files are found, report that there is nothing to prune and stop.

## Step 2 — Inventory the files

Read enough of each file to understand its structure and count its logical entries. Derive the entry boundary from the file's actual conventions, such as headings, list items, numbered records, or structured blocks. Do not assume every entry begins with a bold list marker.

Present a summary:

| Skill or path | Scope | Approximate entries | Structure | Review signal |
|---|---|---:|---|---|
| `<skill>` | repository/shared | `<count>` | `<observed format>` | `<overlap, size, stale context, sensitive content, or none>` |

Label a count as approximate when the format is ambiguous. A size threshold may be used as a configurable review hint, with 30 entries as a default, but it is never proof that pruning is needed. Files with fewer entries may deserve review when they contain conflicts or sensitive information.

Ask which file to review first. Do not edit several files as one approval unit.

## Step 3 — Understand the selected file

Read the complete file and identify its existing:

- sections and category scheme, if any;
- entry format;
- timestamp or provenance conventions;
- intended scope; and
- rules for ordering or grouping.

Do not impose categories such as `BUG`, `ARCHITECTURE`, or `MISUNDERSTANDING` when the file uses another structure.

When an entry refers to behavior that may have changed, verify the current behavior from authoritative local evidence when possible. Examples include current code, tests, configuration, documentation, or tool output. If it cannot be verified, present it as uncertain rather than declaring it obsolete.

## Step 4 — Identify proposals

Assign each candidate one action:

- **MERGE:** multiple entries express the same lesson under the same relevant conditions.
- **REMOVE:** the guidance is demonstrably false, fully duplicated, or no longer applicable and has no continuing historical value.
- **REFINE:** the lesson is useful but vague, overgeneralized, misleading, or missing an important condition or prevention.
- **SANITIZE:** the lesson exposes or unnecessarily preserves identifying, proprietary, or sensitive context.
- **RELOCATE:** the lesson is valid but belongs at a different scope, such as repository-local guidance instead of a shared skill.
- **KEEP:** the entry is distinct, accurate, actionable, appropriately scoped, and safe.

Do not remove an entry merely because it appears simple or project-specific. A project-specific lesson may be valid repository guidance. Before relocating or removing it from a shared file, identify an approved existing repository-local destination or leave it in place until the user chooses a durable home.

## Step 5 — Sanitize safely

Check entries for:

- project, organization, product, person, and customer names;
- private paths, hosts, URLs, repository names, tickets, identifiers, and branch names;
- proprietary code, schemas, business rules, data, and internal terminology; and
- credentials, tokens, cookies, keys, connection strings, or other secret values.

Generalize identifying context while preserving the conditions that make the lesson useful. Name the category of a secret, never its value.

If a secret or sensitive identifier is present, do not reproduce it in the proposal. Show a redacted reference with the file and narrowest available location, propose sanitized replacement text, and warn that exposed credentials may require rotation through the user's normal security process.

## Step 6 — Present one proposal at a time

For each proposed action, show:

- target file and scope;
- action;
- evidence or reasoning;
- current entry or entries, safely redacted when necessary;
- exact proposed replacement, destination, or removal; and
- any uncertainty or information that would be lost.

Use a neutral example format such as:

```markdown
Action: REFINE

Current:
- A request can fail when optional configuration is absent.

Proposed:
- When an optional integration is disabled, skip its request path and report the unavailable capability instead of constructing an incomplete request.

Reason: The current entry identifies a symptom but not the triggering condition or prevention.
```

Ask the user to accept, edit, or skip the proposal. A skipped proposal remains unchanged. Approval for one proposal does not approve later proposals.

For conflicts, present the competing guidance and current evidence. Do not automatically preserve the newest timestamp; retain the entry supported by current behavior, or keep the conflict unresolved when evidence is insufficient.

## Step 7 — Apply approved changes

After the user finishes reviewing proposals for one file:

1. Apply only the accepted changes.
2. Preserve unrelated content, formatting, ordering, and metadata.
3. Use the version-control diff as the reviewable recovery record when available.
4. If version control is unavailable and the user wants a backup, ask where to place it before creating one.
5. Re-read the result for malformed structure, lost conditions, sensitive content, and unintended changes.
6. Show the final diff or exact changed entries.

Report:

- entries before and after, noting approximate counts;
- proposals merged, removed, refined, sanitized, relocated, kept, and skipped;
- unresolved conflicts or uncertain entries; and
- the exact files changed.

Then ask whether to review another existing file or stop.
