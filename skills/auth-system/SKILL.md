---
name: auth-system
description: |
  Implement authentication and authorization from scratch. Covers signup,
  login, sessions, JWT, role-based access, and protected routes.
  Use when: adding auth to a new or existing app.
level: beginner
category: security
---

# Auth System

Add authentication and authorization to your app.

## When to Use

- Building a new app that needs user accounts
- Adding login/signup to an existing project
- Protecting API routes from unauthorized access
- Implementing role-based permissions (admin, user, etc.)

## How It Works

### 1. Choose Your Approach

| Approach | When to use | Complexity |
|----------|------------|------------|
| **NextAuth.js / Auth.js** | Next.js apps, need OAuth (Google, GitHub) | Low |
| **JWT + API routes** | Custom API, mobile app backend | Medium |
| **Supabase Auth** | Using Supabase for database | Low |
| **Clerk** | Want hosted auth UI, quick setup | Low |

### 2. NextAuth.js Setup (Recommended for Next.js)

```bash
npm install next-auth @auth/prisma-adapter
```

```typescript
// lib/auth.ts
import NextAuth from 'next-auth'
import GitHub from 'next-auth/providers/github'
import Credentials from 'next-auth/providers/credentials'
import { PrismaAdapter } from '@auth/prisma-adapter'
import { db } from './db'
import bcrypt from 'bcryptjs'

export const { handlers, signIn, signOut, auth } = NextAuth({
  adapter: PrismaAdapter(db),
  providers: [
    GitHub({
      clientId: process.env.GITHUB_ID!,
      clientSecret: process.env.GITHUB_SECRET!,
    }),
    Credentials({
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        const user = await db.user.findUnique({
          where: { email: credentials.email as string },
        })
        if (!user || !user.password) return null
        const valid = await bcrypt.compare(
          credentials.password as string,
          user.password
        )
        return valid ? user : null
      },
    }),
  ],
  session: { strategy: 'jwt' },
  pages: {
    signIn: '/login',
  },
})
```

```typescript
// app/api/auth/[...nextauth]/route.ts
import { handlers } from '@/lib/auth'
export const { GET, POST } = handlers
```

### 3. Protect Server Pages

```typescript
// app/dashboard/page.tsx
import { auth } from '@/lib/auth'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const session = await auth()
  if (!session) redirect('/login')

  return (
    <div>
      <h1>Welcome, {session.user.name}</h1>
    </div>
  )
}
```

### 4. Protect API Routes

```typescript
// app/api/posts/route.ts
import { auth } from '@/lib/auth'
import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  const session = await auth()
  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const body = await request.json()
  const post = await db.post.create({
    data: { ...body, authorId: session.user.id },
  })
  return NextResponse.json(post, { status: 201 })
}
```

### 5. Role-Based Access

```prisma
// Add role to User model
model User {
  id       String @id @default(cuid())
  email    String @unique
  name     String?
  password String?
  role     Role   @default(USER)
}

enum Role {
  USER
  ADMIN
}
```

```typescript
// Middleware for role checking
function requireRole(role: string) {
  return async function checkRole() {
    const session = await auth()
    if (!session) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    if (session.user.role !== role) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
    }
    return null // authorized
  }
}

// Usage in API route
export async function DELETE(req: Request, { params }: { params: { id: string } }) {
  const denied = await requireRole('ADMIN')()
  if (denied) return denied

  await db.user.delete({ where: { id: params.id } })
  return NextResponse.json({ ok: true })
}
```

### 6. User Registration

```typescript
// app/api/register/route.ts
import { db } from '@/lib/db'
import bcrypt from 'bcryptjs'
import { z } from 'zod'
import { NextResponse } from 'next/server'

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  name: z.string().min(1),
})

export async function POST(request: Request) {
  const body = await request.json()
  const parsed = registerSchema.safeParse(body)
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten() }, { status: 400 })
  }

  // Check if user exists
  const existing = await db.user.findUnique({ where: { email: parsed.data.email } })
  if (existing) {
    return NextResponse.json({ error: 'Email already registered' }, { status: 409 })
  }

  // Hash password and create user
  const hashedPassword = await bcrypt.hash(parsed.data.password, 12)
  const user = await db.user.create({
    data: {
      email: parsed.data.email,
      name: parsed.data.name,
      password: hashedPassword,
    },
  })

  return NextResponse.json(
    { id: user.id, email: user.email, name: user.name },
    { status: 201 }
  )
}
```

### 7. Login Form (Client Component)

```tsx
// app/login/page.tsx
'use client'
import { signIn } from 'next-auth/react'
import { useState } from 'react'
import { useRouter } from 'next/navigation'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const router = useRouter()

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    const result = await signIn('credentials', {
      email,
      password,
      redirect: false,
    })
    if (result?.error) {
      setError('Invalid email or password')
    } else {
      router.push('/dashboard')
    }
  }

  return (
    <form onSubmit={handleSubmit} className="max-w-sm mx-auto mt-20 space-y-4">
      <h1 className="text-2xl font-bold">Login</h1>
      {error && <p className="text-red-600 text-sm">{error}</p>}
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={e => setEmail(e.target.value)}
        className="w-full px-3 py-2 border rounded-lg"
        required
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={e => setPassword(e.target.value)}
        className="w-full px-3 py-2 border rounded-lg"
        required
      />
      <button
        type="submit"
        className="w-full py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
      >
        Sign In
      </button>
      <button
        type="button"
        onClick={() => signIn('github', { callbackUrl: '/dashboard' })}
        className="w-full py-2 border rounded-lg hover:bg-gray-50"
      >
        Continue with GitHub
      </button>
    </form>
  )
}
```

## Security Rules

- **Never store plaintext passwords** — always bcrypt with salt rounds >= 12
- **Never expose user passwords** in API responses
- **Use HTTPS** in production
- **Set secure cookie options** (httpOnly, secure, sameSite)
- **Rate limit** login endpoints (5 attempts per minute)
- **Validate all input** with Zod at the API boundary

## Quality Checklist

- [ ] Passwords hashed with bcrypt (salt >= 12)
- [ ] Auth check on every protected route/endpoint
- [ ] Registration validates email format and password strength
- [ ] Duplicate email returns 409, not 500
- [ ] Session/JWT has expiration configured
- [ ] Sensitive env vars in `.env.local` (not committed)
- [ ] Login error messages don't reveal if email exists

## Examples

```
> Add email/password auth to my Next.js app
> Protect the /dashboard and /api routes with authentication
> Add GitHub OAuth login alongside email/password
```
