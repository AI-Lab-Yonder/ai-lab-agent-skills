---
name: api-builder
description: "Design and implement REST APIs with proper routing, validation, error handling, and documentation. Use when: building backend services, microservices, or adding API endpoints to existing applications."
version: 1.0.0
level: beginner
category: backend
---

# API Builder

Design and implement clean, well-structured REST APIs.

## When to Use

- Creating a new API or backend service
- Adding endpoints to an existing application
- Building a microservice
- Designing an API for a mobile app or third-party integration

## How It Works

### 1. API Design First

Before writing code, define the resources and endpoints:

```
# Resource: Users
GET    /api/users          # List users (with pagination)
GET    /api/users/:id      # Get single user
POST   /api/users          # Create user
PUT    /api/users/:id      # Update user
DELETE /api/users/:id      # Delete user

# Resource: Posts (nested under users)
GET    /api/users/:id/posts    # List user's posts
POST   /api/users/:id/posts   # Create post for user
```

**Naming conventions:**
- Use plural nouns: `/users` not `/user`
- Use kebab-case: `/user-profiles` not `/userProfiles`
- Nest logically: `/users/:id/posts` not `/user-posts`
- Keep depth <= 2 levels

### 2. Request Validation

Always validate input at the boundary:

```typescript
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(['user', 'admin']).default('user'),
})

const querySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().optional(),
})
```

### 3. Response Format

Use consistent response shapes:

```typescript
// Success (single item)
{ "data": { "id": "1", "name": "Alice" } }

// Success (list with pagination)
{
  "data": [{ "id": "1", "name": "Alice" }],
  "meta": { "page": 1, "limit": 20, "total": 42 }
}

// Error
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [{ "field": "email", "message": "Invalid email" }]
  }
}
```

### 4. Status Codes

| Code | When to use |
|------|------------|
| `200` | Successful GET, PUT |
| `201` | Successful POST (created) |
| `204` | Successful DELETE (no content) |
| `400` | Validation error, bad request |
| `401` | Not authenticated |
| `403` | Not authorized (authenticated but no permission) |
| `404` | Resource not found |
| `409` | Conflict (duplicate email, etc.) |
| `500` | Server error (unhandled) |

### 5. Error Handling

```typescript
// Centralized error handler
class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string
  ) {
    super(message)
  }
}

function handleError(error: unknown) {
  if (error instanceof AppError) {
    return Response.json(
      { error: { code: error.code, message: error.message } },
      { status: error.statusCode }
    )
  }
  console.error('Unhandled error:', error)
  return Response.json(
    { error: { code: 'INTERNAL_ERROR', message: 'Something went wrong' } },
    { status: 500 }
  )
}
```

### 6. Complete Example

```typescript
// app/api/users/route.ts
import { db } from '@/lib/db'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const page = Math.max(1, Number(searchParams.get('page') || 1))
  const limit = Math.min(100, Math.max(1, Number(searchParams.get('limit') || 20)))
  const skip = (page - 1) * limit

  const [users, total] = await Promise.all([
    db.user.findMany({ skip, take: limit, orderBy: { createdAt: 'desc' } }),
    db.user.count(),
  ])

  return NextResponse.json({
    data: users,
    meta: { page, limit, total, pages: Math.ceil(total / limit) },
  })
}
```

## Quality Checklist

- [ ] All inputs validated with Zod
- [ ] Consistent error response format
- [ ] Proper HTTP status codes
- [ ] Pagination on list endpoints
- [ ] No sensitive data in responses (passwords, tokens)
- [ ] Rate limiting on public endpoints

## Examples

```
> Build a REST API for a todo app with CRUD operations
> Create an API with authentication and role-based access
> Design an API for a marketplace with products, orders, and reviews
```
