# Contradiction Patterns

Six pattern types to check when auditing rules and skills. For each finding, quote the conflicting directives from both files.

---

## 1. Testing Strategy Conflicts

**What to look for**: One file says to use mocks/stubs, another says to use real dependencies. Or one mandates TDD while another describes a different testing workflow.

**How to detect**: Search for keywords: `mock`, `stub`, `real database`, `integration test`, `unit test`, `TDD`, `test-first`, `test-after`.

**Typical resolution**: Usually the more specific file wins (e.g., `python/testing.md` overrides `common/testing.md` for Python projects). If both are at the same specificity level, ask the user.

---

## 2. Code Style Conflicts

**What to look for**: Contradictory patterns — functional vs class-based, mutation vs immutability, verbose vs terse naming, file size limits that conflict.

**How to detect**: Search for keywords: `immutable`, `mutate`, `class`, `functional`, `max lines`, `file size`, `naming convention`.

**Typical resolution**: Check if the conflict is language-specific (acceptable) or universal (contradiction). Language-specific overrides of universal rules are intentional, not contradictions.

---

## 3. Process Conflicts

**What to look for**: Different instructions for the same workflow step — commit frequency, PR strategy, review process, branch naming.

**How to detect**: Search for keywords: `commit`, `PR`, `pull request`, `branch`, `review`, `merge`, `push`.

**Typical resolution**: Usually one file is outdated. Ask the user which reflects their current preference.

---

## 4. Tool Conflicts

**What to look for**: A skill instructs using tool X, but a rule bans or restricts tool X. Or two skills claim the same trigger scenario.

**How to detect**: Compare skill descriptions for overlapping trigger conditions. Search rules for `do NOT use`, `never use`, `avoid`.

**Typical resolution**: If a rule bans a tool, skills using it need updating. If two skills overlap, one should be scoped more narrowly or merged.

---

## 5. Scope Conflicts

**What to look for**: A global rule says one thing, a project-level rule says the opposite. This may be intentional (project overrides global) or accidental.

**How to detect**: Compare global (`~/.claude/rules/`) against project (`.claude/rules/`) files with the same name or covering the same topic.

**Typical resolution**: Project-level rules intentionally override global rules. Flag for user confirmation but default to "this is intentional" unless the content looks like a copy-paste error.

---

## 6. Stale Preferences

**What to look for**: Rules or skills that reference deprecated tools, removed files, old API patterns, or approaches the user has moved past.

**How to detect**:
- CLAUDE.md references files that don't exist (dead references)
- Rules mention tools/libraries no longer in use
- Skills reference patterns that conflict with more recent rules
- Gotchas entries that have been addressed by rule changes

**Typical resolution**: Delete stale content or update to reflect current state. Always verify the replacement exists before deleting.
