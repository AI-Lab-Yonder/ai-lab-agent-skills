---
name: test-writer
description: "Write comprehensive tests for existing code. Covers unit, integration, and E2E tests. Use when: adding tests to untested code, improving coverage, or ensuring a feature works before shipping."
version: 1.0.0
level: beginner
category: testing
---

# Test Writer

Add tests to existing code quickly and effectively.

## When to Use

- Code has no tests and needs coverage
- Shipping a feature and want confidence it works
- Preparing for a refactor (safety net)
- CI requires tests before merging

## How It Works

### 1. Identify What to Test

Prioritize by risk:

```
High priority (test first):
├── User-facing features (auth, payments, forms)
├── Data transformations (calculations, formatting)
├── API endpoints (request/response contracts)
└── Business logic (pricing, permissions, workflows)

Lower priority:
├── Simple getters/setters
├── UI-only components (styling)
└── Third-party library wrappers
```

### 2. Test Structure (AAA Pattern)

Every test follows Arrange-Act-Assert:

```typescript
describe('calculatePrice', () => {
  it('applies 10% discount for orders over $100', () => {
    // Arrange — set up the inputs
    const items = [{ name: 'Widget', price: 120 }]

    // Act — call the function
    const result = calculatePrice(items)

    // Assert — check the output
    expect(result.discount).toBe(12)
    expect(result.total).toBe(108)
  })
})
```

### 3. Unit Tests

Test individual functions in isolation:

```typescript
// lib/utils.test.ts
import { formatCurrency, slugify, truncate } from './utils'

describe('formatCurrency', () => {
  it('formats dollars with two decimals', () => {
    expect(formatCurrency(1234.5)).toBe('$1,234.50')
  })

  it('handles zero', () => {
    expect(formatCurrency(0)).toBe('$0.00')
  })

  it('handles negative values', () => {
    expect(formatCurrency(-50)).toBe('-$50.00')
  })
})

describe('slugify', () => {
  it('converts to lowercase kebab-case', () => {
    expect(slugify('Hello World')).toBe('hello-world')
  })

  it('removes special characters', () => {
    expect(slugify('Hello, World!')).toBe('hello-world')
  })
})
```

### 4. API / Integration Tests

Test endpoints with real request/response:

```typescript
// app/api/users/route.test.ts
import { GET, POST } from './route'

describe('GET /api/users', () => {
  it('returns a list of users', async () => {
    const response = await GET()
    const body = await response.json()

    expect(response.status).toBe(200)
    expect(body.data).toBeInstanceOf(Array)
    expect(body.meta).toHaveProperty('total')
  })
})

describe('POST /api/users', () => {
  it('creates a user with valid data', async () => {
    const request = new Request('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({ email: 'test@example.com', name: 'Test' }),
    })

    const response = await POST(request)
    expect(response.status).toBe(201)
  })

  it('rejects invalid email', async () => {
    const request = new Request('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({ email: 'not-an-email', name: 'Test' }),
    })

    const response = await POST(request)
    expect(response.status).toBe(400)
  })
})
```

### 5. Component Tests

```typescript
// components/UserCard.test.tsx
import { render, screen } from '@testing-library/react'
import { UserCard } from './UserCard'

describe('UserCard', () => {
  const user = { name: 'Alice', email: 'alice@example.com', role: 'admin' }

  it('renders user name and email', () => {
    render(<UserCard user={user} />)
    expect(screen.getByText('Alice')).toBeInTheDocument()
    expect(screen.getByText('alice@example.com')).toBeInTheDocument()
  })

  it('shows admin badge for admin users', () => {
    render(<UserCard user={user} />)
    expect(screen.getByText('Admin')).toBeInTheDocument()
  })
})
```

### 6. Setup

```bash
# Install testing dependencies
npm install -D jest @types/jest ts-jest @testing-library/react @testing-library/jest-dom

# Run tests
npx jest
npx jest --coverage
npx jest --watch
```

## Quality Checklist

- [ ] Happy path tested
- [ ] Edge cases covered (empty input, null, boundaries)
- [ ] Error cases tested (invalid input, network failure)
- [ ] Tests are independent (no shared mutable state)
- [ ] Test names describe the behavior, not the implementation

## Examples

```
> Write tests for all functions in lib/utils.ts
> Add integration tests for the /api/posts endpoints
> Write component tests for the signup form
```
