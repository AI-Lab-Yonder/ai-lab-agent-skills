# Health Metrics

Thresholds for what a "healthy" rules/skills setup looks like. Flag anything exceeding these.

## File Size Thresholds

| Component | Healthy | Warning | Critical |
|-----------|---------|---------|----------|
| Instruction entry file | <100 lines | 100–200 lines | >200 lines |
| Rule file (`.md`) | <100 lines | 100–150 lines | >150 lines |
| Skill SKILL.md | <100 lines | 100–150 lines | >150 lines |
| Skill folder total | <800 lines | 800–1200 lines | >1200 lines |

## Structure Thresholds

| Metric | Healthy | Flag |
|--------|---------|------|
| Total rule + skill files | <50 | >50 (context loading concern) |
| Dead references in instruction entry files | 0 | Any |
| Contradictions | 0 | Any |
| Redundancies | <3 instances | >3 instances |
| Skills with overlapping descriptions | 0 | Any (false trigger risk) |

## Instruction Entry-File Structure

A healthy instruction entry file is a **lean IF-ELSE directory** pointing to context files:
- Mostly conditional pointers: "if X, read Y.md"
- Minimal inline instructions (those belong in rule/skill files)
- No large code blocks or detailed procedures inline

**Flag if**: An instruction entry file contains >20 lines of inline instructions that could be extracted to a rule file.

## Gotchas Health

| Metric | Healthy | Flag |
|--------|---------|------|
| Entries per gotchas.md | <30 | >30 (suggest the `prune-gotchas` skill through the platform's skill mechanism) |
| Gotchas duplicating rules | 0 | Any (the rule is authoritative, the gotcha is redundant) |
| Empty gotchas sections | Fine | Not a problem — gotchas grow from real failures |
