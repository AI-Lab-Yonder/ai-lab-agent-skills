# Example: Runbook Skill

## Use Case

Given a symptom (error, alert, performance degradation), walk through a structured investigation and produce a report — even if the root cause isn't found.

## Folder Structure

```
investigate-<system>/
├── SKILL.md                  # Investigation orchestrator
├── gotchas.md                # False leads to avoid
├── references/
│   ├── symptom-map.md        # Symptom → likely cause → tools to use
│   ├── query-patterns.md     # Common queries for this system
│   └── architecture.md       # System architecture overview
└── checklists/
    ├── high-latency.md       # Step-by-step for latency issues
    └── error-spike.md        # Step-by-step for error spikes
```

## Key Pattern: Symptom → Tool Mapping

Map each symptom to the specific tools and queries that help investigate:

| Symptom | First Check | Deep Dive | Common Cause |
|---------|-------------|-----------|--------------|
| High latency | Dashboard X | Slow query log | Missing index on table Z |
| Error spike | Error logs for service A | Trace ID lookup | Dependency timeout |
| Memory growth | Grafana panel B | Heap dump script | Cache not evicting |
| 5xx on endpoint | Request logs | DB connection pool | Pool exhaustion under load |

This mapping is the core value of a runbook skill — it encodes tribal knowledge that would otherwise live in someone's head.

## Key Pattern: Structured Report Output

Always produce a report, even if the root cause isn't found:

```markdown
# Investigation Report

**Symptom**: High latency on /api/reports endpoint (p99 > 5s)
**Started**: 2026-03-18 14:00 UTC
**Severity**: HIGH — affects all users loading reports

## Timeline
- 14:00 — Alert fired: p99 latency > 5s
- 14:05 — Confirmed via dashboard: latency spike correlates with deploy at 13:55
- 14:10 — Identified slow query: full table scan on `expense_reports` (missing index)
- 14:15 — Fix applied: added index on `tenant_id, created_at`

## Root Cause
**Identified**: Missing composite index on `expense_reports(tenant_id, created_at)`. The new reports listing query added in deploy 13:55 triggers a sequential scan on large tenants.

## Evidence
- Dashboard screenshot: [link]
- Slow query log: `SELECT * FROM expense_reports WHERE tenant_id = ? ORDER BY created_at DESC`
- EXPLAIN ANALYZE output showing Seq Scan (cost: 45000)

## Resolution
Added migration `20260318_add_reports_index.sql` with composite index.
Latency returned to normal (p99 < 200ms) at 14:20.

## Follow-up
- [ ] Review other queries on `expense_reports` for missing indexes
- [ ] Add query performance monitoring alert for this table
```

## SKILL.md Excerpt

**Phase 0 — Classify the Symptom**
Read `references/symptom-map.md` to match the reported symptom to known patterns. If the symptom doesn't match any known pattern, start with general-purpose checks from the architecture overview.

**Phase 1 — Initial Checks**
Run the "First Check" from the symptom map. These are quick, low-cost checks that confirm or rule out the most common causes.

**Phase 2 — Deep Dive**
Based on Phase 1 findings, run the appropriate deep-dive investigation. Read the relevant checklist from `checklists/` for step-by-step guidance.

**Phase 3 — Correlate Across Systems**
Check if the issue correlates with recent deploys, infrastructure changes, or upstream service issues. Cross-reference logs, metrics, and traces.

**Phase 4 — Produce Report**
Generate a structured investigation report regardless of outcome. Include: symptom, severity, timeline, root cause (or "unknown"), evidence, resolution (or recommended next steps), and follow-up items.

## Why This Works

- Encodes tribal knowledge that survives team turnover
- Structured reports create an investigation history for future reference
- Symptom mapping reduces time-to-diagnosis for known issues
- Even "unknown" reports capture what was checked, preventing duplicate investigation
