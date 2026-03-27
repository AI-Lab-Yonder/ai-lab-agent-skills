# Sample: Security-Focused Review — Mixed Verdicts

5 security findings from a web API review. 3 confirmed, 1 uncertain, 1 disproved.

```json
{
  "findings": [
    {
      "id": "BUG-001",
      "severity": "high",
      "category": "security",
      "title": "SSRF via unvalidated redirect URL",
      "impact": "Attacker can make the server issue requests to internal services by crafting a redirect URL.",
      "evidence": [
        {
          "file": "src/auth/oauth.ts",
          "start_line": 55,
          "end_line": 58,
          "snippet": "const callbackUrl = req.query.redirect; await fetch(callbackUrl, { headers: { Authorization: token } });"
        }
      ],
      "why_it_happens": "User-controlled URL passed directly to server-side fetch without allowlist validation.",
      "fix_recommendation": "Validate callbackUrl against an allowlist of permitted domains. Reject internal/private IP ranges.",
      "confidence": 0.98,
      "finder_score": 10,
      "adversarial_verdict": "CONCEDED",
      "adversarial_reasoning": "No URL validation exists anywhere in the request chain. The redirect parameter is user-controlled and directly fetched server-side with the auth token attached. Clear SSRF.",
      "referee_verdict": "CONFIRMED",
      "referee_reasoning": "Both agents agree. The server-side fetch with user-controlled URL and attached credentials is a textbook SSRF vulnerability."
    },
    {
      "id": "BUG-002",
      "severity": "high",
      "category": "security",
      "title": "Missing CSRF token on state-changing POST endpoint",
      "impact": "Cross-site request forgery allows attackers to perform actions on behalf of authenticated users.",
      "evidence": [
        {
          "file": "src/routes/settings.ts",
          "start_line": 12,
          "end_line": 20,
          "snippet": "router.post('/settings/update', requireAuth, async (req, res) => { await updateSettings(req.user.id, req.body); });"
        }
      ],
      "why_it_happens": "CSRF middleware not applied to this route.",
      "fix_recommendation": "Add CSRF middleware: router.post('/settings/update', requireAuth, csrfProtection, ...)",
      "confidence": 0.85,
      "finder_score": 10,
      "adversarial_verdict": "CHALLENGED",
      "adversarial_reasoning": "The API uses token-based authentication (Bearer JWT) rather than cookies. CSRF attacks require cookie-based session auth because the browser automatically sends cookies. If the JWT is only sent via Authorization header, CSRF is not exploitable. However, I noticed src/middleware/auth.ts:8 also accepts the token from a cookie named 'session_token' as a fallback.",
      "referee_verdict": "CONFIRMED",
      "referee_reasoning": "The adversarial's initial reasoning about Bearer tokens is correct — pure header-based auth is CSRF-safe. However, the adversarial itself discovered the cookie fallback at src/middleware/auth.ts:8. Since the API accepts auth via cookies, CSRF is exploitable on this endpoint. Confirmed."
    },
    {
      "id": "BUG-003",
      "severity": "medium",
      "category": "security",
      "title": "Rate limiting missing on password reset endpoint",
      "impact": "Brute-force attacks against password reset tokens.",
      "evidence": [
        {
          "file": "src/routes/auth.ts",
          "start_line": 45,
          "end_line": 52,
          "snippet": "router.post('/reset-password', async (req, res) => { const { token, newPassword } = req.body; ... });"
        }
      ],
      "why_it_happens": "Rate limiter middleware applied to /login but not /reset-password.",
      "fix_recommendation": "Add rate limiter: router.post('/reset-password', rateLimiter({ max: 3, window: '15m' }), ...)",
      "confidence": 0.90,
      "finder_score": 5,
      "adversarial_verdict": "CHALLENGED",
      "adversarial_reasoning": "While no rate limiter exists on the route, the reset tokens are UUID v4 (122 bits of entropy) and expire after 15 minutes. Brute-forcing a UUID v4 in 15 minutes is computationally infeasible. However, rate limiting would still prevent enumeration attempts that waste server resources.",
      "referee_verdict": "CONFIRMED",
      "referee_reasoning": "The adversarial correctly notes that token entropy prevents brute-force success. However, missing rate limiting still allows denial-of-service via flooding the endpoint, generates excessive password reset emails (which costs money and annoys users), and violates defense-in-depth. Rate limiting should be applied regardless."
    },
    {
      "id": "BUG-004",
      "severity": "medium",
      "category": "security",
      "title": "Sensitive user data in error response",
      "impact": "Stack traces and internal user IDs leaked in production error responses.",
      "evidence": [
        {
          "file": "src/middleware/error.ts",
          "start_line": 8,
          "end_line": 15,
          "snippet": "res.status(500).json({ error: err.message, stack: err.stack, userId: req.user?.id });"
        }
      ],
      "why_it_happens": "Error handler doesn't check NODE_ENV before including debug information.",
      "fix_recommendation": "Conditionally include stack/userId: only in development. In production, return generic error message.",
      "confidence": 0.75,
      "finder_score": 5,
      "adversarial_verdict": "CHALLENGED",
      "adversarial_reasoning": "The error handler at src/middleware/error.ts does include stack traces. However, there's a reverse proxy config in nginx.conf that strips response bodies on 5xx errors and returns a generic error page. The sensitive data never reaches the client in production.",
      "referee_verdict": "UNCERTAIN",
      "referee_reasoning": "The nginx stripping claim needs verification. If the reverse proxy config is correct, the data never reaches clients. But relying on infrastructure to mask application-level leaks is fragile — a misconfiguration or direct-to-app access would expose the data. Flagged for human review."
    },
    {
      "id": "BUG-005",
      "severity": "low",
      "category": "security",
      "title": "CORS wildcard allows any origin",
      "impact": "Any website can make authenticated requests to the API.",
      "evidence": [
        {
          "file": "src/app.ts",
          "start_line": 12,
          "end_line": 12,
          "snippet": "app.use(cors({ origin: '*' }));"
        }
      ],
      "why_it_happens": "Permissive CORS configuration.",
      "fix_recommendation": "Restrict to known origins: cors({ origin: ['https://app.example.com'] })",
      "confidence": 0.88,
      "finder_score": 1,
      "adversarial_verdict": "DISPROVED",
      "adversarial_reasoning": "Checked src/app.ts. Line 12 reads: app.use(cors({ origin: config.ALLOWED_ORIGINS }));. The config at src/config/index.ts:20 reads ALLOWED_ORIGINS from an environment variable and splits on comma. The wildcard does not exist in the current code. The bug-finder reported incorrect code.",
      "referee_verdict": "DISPROVED",
      "referee_reasoning": "Verified src/app.ts and src/config/index.ts. CORS is configured from environment variable, not a hardcoded wildcard. The bug-finder's snippet doesn't match the actual code. False positive."
    }
  ],
  "summary": {
    "confirmed_count": 3,
    "disproved_count": 1,
    "uncertain_count": 1,
    "overall_confidence": 0.90
  }
}
```
