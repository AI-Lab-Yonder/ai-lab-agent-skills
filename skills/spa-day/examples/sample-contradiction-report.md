# Sample: Contradiction Report

Audit of user-level scope (`<user-config-root>/`). Found 2 contradictions, 1 redundancy, 1 dead reference, 1 oversized file.

---

## Inventory

| File | Purpose | Lines |
|------|---------|-------|
| `AGENTS.md` | User-level instructions directory | 61 |
| `rules/common/testing.md` | Testing requirements | 32 |
| `rules/common/coding-style.md` | Code style rules | 48 |
| `rules/python/testing.md` | Python testing rules | 28 |
| `rules/python/coding-style.md` | Python code style | 35 |
| `rules/typescript/testing.md` | TypeScript testing rules | 30 |
| `skills/review-changes/SKILL.md` | Change review | 55 |
| `skills/investigate-failure/SKILL.md` | Failure investigation | 62 |
| ... | _(16 more files)_ | ... |

**Total**: 24 files, 1,847 lines

---

## Contradictions Found

### CONTRA-001: Testing mock strategy conflict

**File A**: `rules/common/testing.md` (line 14)
> "Integration Tests - API endpoints, database operations"

**File B**: `rules/python/testing.md` (line 8)
> "Always mock external services in unit tests including database calls"

**Conflict**: Common rules expect real database operations in integration tests. Python rules say to mock database calls. Are Python integration tests supposed to use real DBs or mocks?

**Recommendation**: Clarify scope — unit tests mock, integration tests use real DB. Both files need explicit wording.

---

### CONTRA-002: Commit message format inconsistency

**File A**: `rules/common/git-workflow.md` (line 5)
> "Format: `<type>: <description>`"

**File B**: `AGENTS.md` (line 52, Self-Improvement Protocol)
> Gotcha format uses `<!-- timestamp -->` comments in commits

**Conflict**: Minor — git-workflow defines commit format but Self-Improvement Protocol implies appending metadata comments. Not a direct contradiction but could confuse.

**Recommendation**: Skip — these apply to different contexts (commits vs gotchas files).

---

## Redundancies Found

### REDUN-001: Immutability rule duplicated

**Location A**: `rules/common/coding-style.md` (line 5)
> "ALWAYS create new objects, NEVER mutate existing ones"

**Location B**: `rules/python/coding-style.md` (line 12)
> "Use immutable patterns — create new objects instead of mutating"

**Assessment**: Same directive in both files. The Python version is a subset of the common version.

**Recommendation**: Remove from `python/coding-style.md` — the common rule already covers it universally.

---

## Dead References

### DEAD-001: Missing rule file reference

**In**: `AGENTS.md` (line 38)
> "read coding-test-failing-rules.MD"

**Problem**: File `rules/common/coding-test-failing-rules.md` does not exist.

**Recommendation**: Either create the file or remove the reference from `AGENTS.md`.

---

## Oversized Files

### SIZE-001: `rules/common/agents.md`

**Lines**: 142 (threshold: 100)

**Recommendation**: Split into `agents-overview.md` (table + when-to-use) and `agents-parallel-execution.md` (detailed patterns).

---

## Health Summary

| Metric | Value | Status |
|--------|-------|--------|
| Total files | 24 | Healthy |
| Total lines | 1,847 | Healthy |
| Contradictions | 2 | Needs resolution |
| Redundancies | 1 | Needs resolution |
| Dead references | 1 | Needs resolution |
| Oversized files | 1 | Warning |
