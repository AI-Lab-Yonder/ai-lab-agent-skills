# Sample: Backend Review — Mixed Verdicts

4 findings from a Node.js backend review. 2 confirmed, 1 uncertain, 1 disproved.

```json
{
  "findings": [
    {
      "id": "BUG-001",
      "severity": "high",
      "category": "security",
      "title": "Unsanitized user input in SQL query",
      "impact": "SQL injection via the search endpoint allows arbitrary database queries.",
      "evidence": [
        {
          "file": "src/routes/search.ts",
          "start_line": 42,
          "end_line": 44,
          "snippet": "const results = await db.query(`SELECT * FROM products WHERE name LIKE '%${query}%'`)"
        }
      ],
      "why_it_happens": "Template literal interpolation bypasses parameterized query protection.",
      "fix_recommendation": "Use parameterized query: db.query('SELECT * FROM products WHERE name LIKE $1', [`%${query}%`])",
      "confidence": 0.99,
      "finder_score": 10,
      "adversarial_verdict": "CONCEDED",
      "adversarial_reasoning": "Verified the code path. No input sanitization middleware exists for this route. The template literal directly interpolates req.query.q. This is a genuine SQL injection vector.",
      "referee_verdict": "CONFIRMED",
      "referee_reasoning": "Both agents agree. Verified that no middleware sanitizes input before it reaches this query. The adversarial agent correctly conceded."
    },
    {
      "id": "BUG-002",
      "severity": "medium",
      "category": "race-condition",
      "title": "Concurrent inventory updates can oversell",
      "impact": "Two simultaneous purchases of the last item could both succeed, creating negative inventory.",
      "evidence": [
        {
          "file": "src/services/order.ts",
          "start_line": 67,
          "end_line": 78,
          "snippet": "const stock = await getStock(itemId); if (stock > 0) { await decrementStock(itemId); }"
        }
      ],
      "why_it_happens": "Check-then-act without a transaction or lock. Two requests can read stock=1 simultaneously.",
      "fix_recommendation": "Wrap in a database transaction with SELECT ... FOR UPDATE, or use atomic decrement: UPDATE stock SET qty = qty - 1 WHERE qty > 0.",
      "confidence": 0.88,
      "finder_score": 5,
      "adversarial_verdict": "CHALLENGED",
      "adversarial_reasoning": "The code path exists but the application runs behind a single-threaded event loop. Concurrent database operations would need to be triggered by overlapping HTTP requests, which is possible but the traffic volume may be too low for this to manifest in practice.",
      "referee_verdict": "CONFIRMED",
      "referee_reasoning": "The adversarial's argument about traffic volume is irrelevant to correctness. The race condition exists regardless of current traffic. Node.js handles concurrent requests via async I/O, so two overlapping requests absolutely can interleave the check-then-act. Bug is real."
    },
    {
      "id": "BUG-003",
      "severity": "medium",
      "category": "logic-error",
      "title": "Discount calculation rounds incorrectly for multi-item orders",
      "impact": "Customers could be overcharged by up to $0.03 per item due to floating point rounding.",
      "evidence": [
        {
          "file": "src/services/pricing.ts",
          "start_line": 23,
          "end_line": 25,
          "snippet": "const discount = price * discountRate; const final = price - discount;"
        }
      ],
      "why_it_happens": "Floating point arithmetic without rounding to cents.",
      "fix_recommendation": "Round to 2 decimal places: Math.round((price - discount) * 100) / 100",
      "confidence": 0.72,
      "finder_score": 5,
      "adversarial_verdict": "CHALLENGED",
      "adversarial_reasoning": "While floating point precision is a known concern, the final price is formatted with toFixed(2) in the response serializer at src/middleware/response.ts:15. The display value is correct. However, the raw value stored in the database may still have precision issues.",
      "referee_verdict": "UNCERTAIN",
      "referee_reasoning": "The adversarial correctly identifies that display formatting masks the issue. However, the database stores the unrounded value, which could cause discrepancies in refund calculations or financial reporting. Flagged for human review — the impact depends on how stored values are used downstream."
    },
    {
      "id": "BUG-004",
      "severity": "low",
      "category": "resource-leak",
      "title": "Database connection not released on error in batch import",
      "impact": "Connection pool exhaustion during failed batch imports.",
      "evidence": [
        {
          "file": "src/jobs/import.ts",
          "start_line": 45,
          "end_line": 60,
          "snippet": "const conn = await pool.getConnection(); const results = await conn.query(...);"
        }
      ],
      "why_it_happens": "No try/finally to release connection on query failure.",
      "fix_recommendation": "Wrap in try/finally: try { ... } finally { conn.release(); }",
      "confidence": 0.85,
      "finder_score": 1,
      "adversarial_verdict": "DISPROVED",
      "adversarial_reasoning": "Checked src/jobs/import.ts. The actual code uses a connection wrapper from src/db/pool.ts that implements automatic release via Symbol.dispose (using the TC39 Explicit Resource Management proposal). The pool.getConnection() returns a disposable connection that releases itself when the enclosing scope exits. Line 43: 'using conn = await pool.getConnection();'",
      "referee_verdict": "DISPROVED",
      "referee_reasoning": "Verified src/db/pool.ts. The 'using' declaration at line 43 ensures automatic cleanup. The bug-finder's snippet was incomplete — it omitted the 'using' keyword. False positive."
    }
  ],
  "summary": {
    "confirmed_count": 2,
    "disproved_count": 1,
    "uncertain_count": 1,
    "overall_confidence": 0.87
  }
}
```
