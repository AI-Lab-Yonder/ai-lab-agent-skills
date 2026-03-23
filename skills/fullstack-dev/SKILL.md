---
name: fullstack-dev
description: |
  Complete full-stack development with frontend, backend, database, and deployment.
  Use when: building apps that need both a UI and a server, APIs with a database,
  or any project that spans the entire stack.
level: beginner
category: fullstack
---

# Full-Stack Dev

Build complete applications from database to UI.

## When to Use

- Building a new app with both frontend and backend
- Adding a database-backed feature to an existing project
- Creating CRUD applications
- Setting up authentication and user management
- Building real-time features (chat, notifications, live updates)

## How It Works

### 1. Choose Your Stack

| Component | Recommended | Alternatives |
|-----------|-------------|-------------|
| Frontend | Next.js + Tailwind | React + Vite, Vue |
| Backend | Next.js API Routes | Express, Fastify, Hono |
| Database | PostgreSQL | SQLite, MySQL |
| ORM | Prisma | Drizzle, TypeORM |
| Auth | NextAuth.js / Auth.js | Clerk, Supabase Auth |
| Deployment | Vercel | Railway, Fly.io |

### 2. Project Structure

```
my-app/
├── src/
│   ├── app/                    # Pages and layouts
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── api/                # API routes
│   │   │   ├── users/
│   │   │   │   └── route.ts
│   │   │   └── auth/
│   │   │       └── [...nextauth]/route.ts
│   │   └── dashboard/
│   │       └── page.tsx
│   ├── components/             # UI components
│   ├── lib/
│   │   ├── db.ts               # Database client
│   │   ├── auth.ts             # Auth configuration
│   │   └── validations.ts      # Zod schemas
│   └── types/                  # Shared TypeScript types
├── prisma/
│   ├── schema.prisma           # Database schema
│   └── migrations/
├── .env.local                  # Environment variables
└── package.json
```

### 3. Database Layer

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  String
  createdAt DateTime @default(now())
}
```

```typescript
// lib/db.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as { prisma?: PrismaClient }
export const db = globalForPrisma.prisma ?? new PrismaClient()
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db
```

### 4. API Routes

```typescript
// app/api/posts/route.ts
import { db } from '@/lib/db'
import { NextResponse } from 'next/server'
import { z } from 'zod'

const createPostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().optional(),
})

export async function GET() {
  const posts = await db.post.findMany({
    include: { author: { select: { name: true, email: true } } },
    orderBy: { createdAt: 'desc' },
  })
  return NextResponse.json(posts)
}

export async function POST(request: Request) {
  const body = await request.json()
  const parsed = createPostSchema.safeParse(body)
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 })
  }
  const post = await db.post.create({ data: parsed.data })
  return NextResponse.json(post, { status: 201 })
}
```

### 5. Connect Frontend to Backend

```tsx
// app/dashboard/page.tsx
import { db } from '@/lib/db'

export default async function DashboardPage() {
  const posts = await db.post.findMany({
    orderBy: { createdAt: 'desc' },
    take: 10,
  })

  return (
    <div className="max-w-4xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Dashboard</h1>
      <div className="space-y-4">
        {posts.map(post => (
          <article key={post.id} className="p-4 border rounded-lg">
            <h2 className="text-lg font-semibold">{post.title}</h2>
            <p className="text-gray-600 mt-1">{post.content}</p>
          </article>
        ))}
      </div>
    </div>
  )
}
```

### 6. Quality Checklist

- [ ] Input validation on both client and server (Zod)
- [ ] Error handling for all API routes
- [ ] Environment variables for secrets (never hardcoded)
- [ ] Database migrations are clean and reversible
- [ ] Auth protects sensitive routes
- [ ] Loading and error states in the UI

## Examples

```
> Build a blog app with user auth, posts, and comments
> Create a task manager with drag-and-drop and real-time updates
> Build an e-commerce store with products, cart, and checkout
```
