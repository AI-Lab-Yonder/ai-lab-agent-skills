---
name: bug-fixer
description: "Systematic approach to finding and fixing bugs in any codebase. Use when: debugging errors, investigating unexpected behavior, fixing failing tests, or resolving production issues."
version: 1.0.0
level: beginner
category: debugging
---

# Bug Fixer

Find and fix bugs systematically instead of guessing.

## When to Use

- An error or exception is thrown
- A feature doesn't work as expected
- Tests are failing
- Users report unexpected behavior
- Something worked before but broke after a change

## How It Works

### 1. Reproduce First

Never fix what you can't reproduce:

```
1. Get the exact error message or unexpected behavior
2. Find the minimal steps to trigger it
3. Confirm you can see the bug consistently
```

### 2. Read the Error

Most bugs tell you exactly what's wrong:

```
Error: Cannot read properties of undefined (reading 'map')
  at UserList (src/components/UserList.tsx:12:24)
  at Dashboard (src/app/dashboard/page.tsx:8:5)
```

**Parse it:**
- **What**: trying to call `.map()` on `undefined`
- **Where**: `UserList.tsx`, line 12
- **Why**: the data hasn't loaded yet (undefined instead of array)

### 3. Narrow the Scope

Work from the error outward:

```
1. Go to the exact file and line from the error
2. Trace the data flow backward:
   - Where does this variable come from?
   - What function returns it?
   - What API provides it?
3. Find where expected value diverges from actual value
```

### 4. Common Bug Patterns

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `undefined is not a function` | Wrong import or typo | Check import path and export name |
| `Cannot read property of undefined` | Missing null check or data not loaded | Add optional chaining (`?.`) or loading state |
| `Too many re-renders` | State update in render body | Move to useEffect or event handler |
| `Hydration mismatch` | Server/client HTML differs | Use `useEffect` for client-only content |
| API returns 500 | Unhandled error in backend | Check server logs, add try/catch |
| Stale data in UI | Missing cache invalidation | Revalidate after mutation |
| Works locally, fails in CI | Environment difference | Check env vars, Node version, dependencies |

### 5. Fix and Verify

```
1. Make the smallest possible change that fixes the bug
2. Run the failing test / reproduce steps — confirm it passes
3. Check for similar patterns elsewhere in the code
4. Add a test that would catch this bug in the future
```

### 6. Debugging Commands

```bash
# Check recent changes that may have caused the bug
git log --oneline -10
git diff HEAD~3

# Find where a variable is used
grep -rn "variableName" src/

# Check TypeScript errors
npx tsc --noEmit

# Run a specific test
npx jest path/to/test --verbose
```

## Quality Checklist

- [ ] Bug is reproducible before fixing
- [ ] Fix is minimal (no unrelated changes)
- [ ] Existing tests still pass
- [ ] New test added to prevent regression
- [ ] No console.log left in code

## Examples

```
> Fix this error: TypeError: Cannot read properties of null (reading 'id')
> The login form submits but nothing happens — debug it
> Tests pass locally but fail in CI — investigate
```

