# Sample: Security-Focused Findings

Demonstrates the `security` category with high-confidence findings requiring immediate attention.

```json
{
  "summary": {
    "scope": "Uncommitted changes in src/server/",
    "files_reviewed": 4,
    "high_severity_count": 2,
    "medium_severity_count": 1,
    "low_severity_count": 0
  },
  "findings": [
    {
      "id": "REV-001",
      "severity": "high",
      "category": "security",
      "title": "SQL query built with string concatenation",
      "impact": "Attacker-controlled input can execute arbitrary SQL via the search endpoint.",
      "evidence": [
        {
          "file": "src/server/routes/search.ts",
          "start_line": 34,
          "end_line": 36,
          "snippet": "const query = `SELECT * FROM items WHERE name LIKE '%${req.query.q}%'`"
        }
      ],
      "why_it_happens": "User input interpolated directly into SQL string without parameterization.",
      "fix_recommendation": "Use parameterized queries: db.query('SELECT * FROM items WHERE name LIKE $1', [`%${q}%`])",
      "confidence": 0.99
    },
    {
      "id": "REV-002",
      "severity": "high",
      "category": "security",
      "title": "API key hardcoded in source file",
      "impact": "Secret exposed in version control; anyone with repo access can use the key.",
      "evidence": [
        {
          "file": "src/server/services/external-service.ts",
          "start_line": 5,
          "end_line": 5,
          "snippet": "const serviceCredential = '[redacted hardcoded value]'"
        }
      ],
      "why_it_happens": "Developer added key directly instead of reading from environment variable.",
      "fix_recommendation": "Load the credential from a protected environment or secret store and keep local secret files out of version control.",
      "confidence": 1.0
    },
    {
      "id": "REV-003",
      "severity": "medium",
      "category": "security",
      "title": "Missing rate limiting on authentication endpoint",
      "impact": "Brute-force attacks against login are not throttled.",
      "evidence": [
        {
          "file": "src/server/routes/auth.ts",
          "start_line": 12,
          "end_line": 30,
          "snippet": "router.post('/login', async (req, res) => { ... }) // no rate limiter middleware"
        }
      ],
      "why_it_happens": "Rate limiting middleware applied to other routes but not the new auth route.",
      "fix_recommendation": "Add rate limiting middleware: router.post('/login', rateLimiter({ max: 5, window: '15m' }), ...)",
      "confidence": 0.91
    }
  ],
  "checks_run": [
    {
      "name": "typecheck",
      "status": "passed",
      "details": "npx tsc --noEmit"
    },
    {
      "name": "lint",
      "status": "failed",
      "details": "eslint reported 1 warning: no-hardcoded-credentials in external-service.ts"
    },
    {
      "name": "test",
      "status": "passed",
      "details": "npm test — 28 tests passed"
    }
  ],
  "out_of_scope": [],
  "overall_confidence": 0.95
}
```
