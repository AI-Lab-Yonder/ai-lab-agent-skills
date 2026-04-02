# Sample: Frontend Changes with Regression and Test Gap

Typical review of uncommitted frontend changes. Demonstrates `regression` and `test-gap` categories.

```json
{
  "summary": {
    "scope": "Uncommitted frontend changes under apps/web",
    "files_reviewed": 6,
    "high_severity_count": 1,
    "medium_severity_count": 1,
    "low_severity_count": 0
  },
  "findings": [
    {
      "id": "REV-001",
      "severity": "high",
      "category": "regression",
      "title": "Query cache key misses pagination inputs",
      "impact": "Users can see stale page data when changing offset/limit.",
      "evidence": [
        {
          "file": "apps/web/src/hooks/use-approval-inbox.ts",
          "start_line": 58,
          "end_line": 67,
          "snippet": "queryKey omits limit/offset while request uses them"
        }
      ],
      "why_it_happens": "Cache key does not uniquely represent request params.",
      "fix_recommendation": "Include limit and offset in queryKey.",
      "confidence": 0.97
    },
    {
      "id": "REV-002",
      "severity": "medium",
      "category": "test-gap",
      "title": "Migrated hook lacks direct tests",
      "impact": "Refactor regressions may ship undetected.",
      "evidence": [
        {
          "file": "apps/web/src/hooks/use-reports.ts",
          "start_line": 1,
          "end_line": 80,
          "snippet": "hook migrated to query layer; no dedicated hook test found"
        }
      ],
      "why_it_happens": "Migration updated implementation without equivalent focused coverage.",
      "fix_recommendation": "Add hook-level tests for loading/error/success states.",
      "confidence": 0.82
    }
  ],
  "checks_run": [
    {
      "name": "typecheck",
      "status": "passed",
      "details": "npm run typecheck (apps/web)"
    },
    {
      "name": "test",
      "status": "not_run",
      "details": "Skipped in this sample"
    }
  ],
  "out_of_scope": [
    "Backend changes",
    "Generated files"
  ],
  "overall_confidence": 0.9
}
```
