# Sample: Security-Focused Findings

Demonstrates the `security` category with high-confidence findings requiring immediate attention.

```json
{
  "summary": {
    "scope": "Uncommitted changes in server/",
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
          "file": "server/src/routes/search.ts",
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
          "file": "server/src/services/payment.ts",
          "start_line": 5,
          "end_line": 5,
          "snippet": "const STRIPE_KEY = 'sk_live_abc123...'"
        }
      ],
      "why_it_happens": "Developer added key directly instead of reading from environment variable.",
      "fix_recommendation": "Move to environment variable: process.env.STRIPE_SECRET_KEY. Add .env to .gitignore.",
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
          "file": "server/src/routes/auth.ts",
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
      "details": "eslint reported 1 warning: no-hardcoded-credentials on payment.ts:5"
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
