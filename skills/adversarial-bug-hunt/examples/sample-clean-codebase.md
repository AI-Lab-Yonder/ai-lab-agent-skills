# Sample: Clean Codebase — All Findings Disproved

3 findings from a well-tested codebase. The adversarial agent disproved all of them, and the referee agreed. Demonstrates the all-disproved path where Phase 4 stops early.

```json
{
  "findings": [
    {
      "id": "BUG-001",
      "severity": "medium",
      "category": "edge-case",
      "title": "Empty array not handled in aggregation",
      "impact": "Division by zero when calculating average of empty dataset.",
      "evidence": [
        {
          "file": "src/analytics/aggregate.ts",
          "start_line": 18,
          "end_line": 20,
          "snippet": "const avg = total / items.length;"
        }
      ],
      "why_it_happens": "No guard for empty array before division.",
      "fix_recommendation": "Add guard: if (items.length === 0) return 0;",
      "confidence": 0.80,
      "finder_score": 5,
      "adversarial_verdict": "DISPROVED",
      "adversarial_reasoning": "The function is called from src/analytics/pipeline.ts:34 which filters out empty datasets before calling aggregate(). The guard exists at the call site: 'if (items.length === 0) return { avg: 0, ... }'. Additionally, the schema validation at the API boundary rejects empty arrays.",
      "referee_verdict": "DISPROVED",
      "referee_reasoning": "Verified the call chain. The empty-array guard exists at the call site and at the API validation layer. The function itself cannot receive an empty array in any current code path."
    },
    {
      "id": "BUG-002",
      "severity": "low",
      "category": "performance",
      "title": "N+1 query in user listing endpoint",
      "impact": "Slow response times when listing users with their roles.",
      "evidence": [
        {
          "file": "src/routes/users.ts",
          "start_line": 22,
          "end_line": 28,
          "snippet": "for (const user of users) { user.roles = await getRoles(user.id); }"
        }
      ],
      "why_it_happens": "Sequential database query per user instead of a JOIN or batch query.",
      "fix_recommendation": "Use a single JOIN query or batch fetch roles for all user IDs.",
      "confidence": 0.90,
      "finder_score": 1,
      "adversarial_verdict": "DISPROVED",
      "adversarial_reasoning": "The getRoles function at src/db/roles.ts:10 uses a DataLoader that batches and caches queries. The for-loop triggers individual calls, but the DataLoader coalesces them into a single batch query per tick. This is the standard DataLoader pattern for solving N+1 in Node.js.",
      "referee_verdict": "DISPROVED",
      "referee_reasoning": "Confirmed DataLoader at src/db/roles.ts. The batch window coalesces all getRoles calls from the loop into a single query. No N+1 issue exists."
    },
    {
      "id": "BUG-003",
      "severity": "medium",
      "category": "security",
      "title": "JWT secret hardcoded in config file",
      "impact": "Secret exposed in source code; anyone with repo access can forge tokens.",
      "evidence": [
        {
          "file": "src/config/auth.ts",
          "start_line": 3,
          "end_line": 3,
          "snippet": "export const JWT_SECRET = 'super-secret-key-123';"
        }
      ],
      "why_it_happens": "Developer left hardcoded secret instead of reading from environment.",
      "fix_recommendation": "Use process.env.JWT_SECRET with validation at startup.",
      "confidence": 0.95,
      "finder_score": 5,
      "adversarial_verdict": "DISPROVED",
      "adversarial_reasoning": "Checked src/config/auth.ts. The actual code reads: 'export const JWT_SECRET = process.env.JWT_SECRET ?? throwIfMissing(\"JWT_SECRET\");'. The bug-finder's snippet does not match the current file contents. The hardcoded value may have existed in an earlier version but has been replaced.",
      "referee_verdict": "DISPROVED",
      "referee_reasoning": "Read src/config/auth.ts directly. Line 3 uses process.env with a throwIfMissing guard. The bug-finder reported stale or fabricated code. False positive."
    }
  ],
  "summary": {
    "confirmed_count": 0,
    "disproved_count": 3,
    "uncertain_count": 0,
    "overall_confidence": 0.92
  }
}
```
