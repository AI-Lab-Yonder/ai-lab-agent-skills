---
name: code-reviewer
description: "Automated code review for security, quality, and performance. Catches bugs, vulnerabilities, and anti-patterns before they ship. Use when: reviewing PRs, auditing code before release, or checking your own work."
version: 1.0.0
level: advanced
category: code-quality
---

# Code Reviewer

Review code systematically for bugs, security issues, and quality problems.

## When to Use

- Before merging a pull request
- After finishing a feature (self-review)
- Auditing code for security or compliance
- Onboarding to an unfamiliar codebase
- Before deploying to production

## How It Works

### 1. Review Checklist

Go through these categories in order:

```
Priority 1 — Security
├── SQL injection (raw queries, string concatenation)
├── XSS (unescaped user input in HTML/JSX)
├── Auth bypass (missing middleware, broken checks)
├── Secrets in code (API keys, passwords, tokens)
├── Insecure dependencies (known CVEs)
└── CSRF / CORS misconfiguration

Priority 2 — Correctness
├── Logic errors (off-by-one, wrong operator, inverted condition)
├── Null/undefined access without checks
├── Race conditions (async operations, shared state)
├── Error handling (uncaught exceptions, silent failures)
├── Edge cases (empty arrays, zero values, large inputs)
└── Type safety (any casts, missing types)

Priority 3 — Performance
├── N+1 queries (loop with DB call inside)
├── Missing pagination on list endpoints
├── Unnecessary re-renders (React)
├── Large bundle imports (import entire library for one function)
├── Missing indexes on queried columns
└── Memory leaks (uncleared intervals, listeners, subscriptions)

Priority 4 — Maintainability
├── Function length (> 30 lines = too long)
├── Naming clarity (can you understand it without context?)
├── Duplication (same logic in 2+ places)
├── Dead code (unused imports, unreachable branches)
├── Missing tests for new logic
└── Consistent patterns with rest of codebase
```

### 2. Security Deep Dive

**SQL Injection:**
```typescript
// BAD — string interpolation
const users = await db.query(`SELECT * FROM users WHERE name = '${name}'`)

// GOOD — parameterized query
const users = await db.query('SELECT * FROM users WHERE name = $1', [name])

// GOOD — ORM (Prisma)
const users = await db.user.findMany({ where: { name } })
```

**XSS:**
```tsx
// BAD — renders raw HTML from user input
<div dangerouslySetInnerHTML={{ __html: userComment }} />

// GOOD — React auto-escapes by default
<div>{userComment}</div>

// If HTML is needed — sanitize first
import DOMPurify from 'dompurify'
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userComment) }} />
```

**Auth Checks:**
```typescript
// BAD — no auth on sensitive endpoint
export async function DELETE(req: Request, { params }: { params: { id: string } }) {
  await db.user.delete({ where: { id: params.id } })
  return NextResponse.json({ ok: true })
}

// GOOD — verify authentication and authorization
export async function DELETE(req: Request, { params }: { params: { id: string } }) {
  const session = await getServerSession()
  if (!session) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  if (session.user.id !== params.id && session.user.role !== 'admin') {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
  }
  await db.user.delete({ where: { id: params.id } })
  return NextResponse.json({ ok: true })
}
```

### 3. Performance Checks

**N+1 Query:**
```typescript
// BAD — N+1: one query per post to get author
const posts = await db.post.findMany()
for (const post of posts) {
  post.author = await db.user.findUnique({ where: { id: post.authorId } })
}

// GOOD — single query with include
const posts = await db.post.findMany({
  include: { author: { select: { name: true, email: true } } }
})
```

**React Re-renders:**
```tsx
// BAD — new object on every render triggers child re-render
<UserCard style={{ padding: 16 }} />

// GOOD — stable reference
const cardStyle = { padding: 16 } // outside component
// or
const cardStyle = useMemo(() => ({ padding: 16 }), [])
```

### 4. Review Output Format

For each issue found:

```markdown
### [SEVERITY] Issue title

**File:** `src/api/users/route.ts:24`
**Category:** Security / Correctness / Performance / Maintainability

**Problem:** Description of what's wrong and why it matters.

**Fix:**
\`\`\`typescript
// suggested fix
\`\`\`
```

Severity levels:
- **CRITICAL** — Must fix before merge (security vulnerability, data loss)
- **WARNING** — Should fix (bug risk, performance issue)
- **INFO** — Consider improving (readability, convention)

### 5. Quick Commands

```bash
# Check for known vulnerabilities in dependencies
npm audit

# Find TODO/FIXME/HACK comments
grep -rn "TODO\|FIXME\|HACK" src/

# Check TypeScript errors
npx tsc --noEmit

# Run linter
npx eslint src/

# Check for unused exports
npx knip
```

## Quality Checklist

- [ ] No hardcoded secrets or API keys
- [ ] All user input is validated/sanitized
- [ ] Auth checks on every protected endpoint
- [ ] No N+1 queries
- [ ] Error states handled (try/catch, error boundaries)
- [ ] Tests cover the new/changed code
- [ ] No `console.log` left in production code

## Examples

```
> Review all uncommitted changes for security issues
> Do a full code review of the /api directory
> Check this PR for performance problems
```
