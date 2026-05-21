---
name: frontend-dev
description: "Build modern frontend applications with React, Next.js, and Tailwind CSS. Use when: creating web apps, UI components, landing pages, dashboards, or any browser-based interface."
version: 1.0.0
level: beginner
category: frontend
---

# Frontend Dev

Build production-ready frontend applications with modern web technologies.

## When to Use

- Building a new web application from scratch
- Creating React or Next.js components
- Styling with Tailwind CSS
- Adding interactivity, animations, or responsive layouts
- Building dashboards, forms, or data-driven UIs

## How It Works

### 1. Project Setup

Choose the right stack based on the requirement:

| Need | Stack |
|------|-------|
| Static site / landing page | Next.js + Tailwind |
| Interactive SPA | React + Vite + Tailwind |
| Full app with SSR | Next.js App Router |
| Quick prototype | Single HTML + CDN (Tailwind, Alpine.js) |

```bash
# Next.js (recommended default)
npx create-next-app@latest my-app --typescript --tailwind --app --src-dir

# React + Vite
npm create vite@latest my-app -- --template react-ts
```

### 2. Component Structure

Always follow this pattern:

```
src/
├── app/                    # Next.js App Router pages
│   ├── layout.tsx          # Root layout
│   ├── page.tsx            # Home page
│   └── dashboard/
│       └── page.tsx
├── components/
│   ├── ui/                 # Reusable primitives (Button, Card, Input)
│   ├── layout/             # Layout components (Header, Sidebar, Footer)
│   └── features/           # Feature-specific components
├── hooks/                  # Custom React hooks
├── lib/                    # Utilities, API clients, helpers
└── styles/                 # Global styles, Tailwind config
```

### 3. Component Patterns

**Keep components small and focused:**

```tsx
// components/ui/Button.tsx
interface ButtonProps {
  children: React.ReactNode
  variant?: 'primary' | 'secondary' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  onClick?: () => void
  disabled?: boolean
}

export function Button({
  children,
  variant = 'primary',
  size = 'md',
  onClick,
  disabled
}: ButtonProps) {
  const base = 'rounded-lg font-medium transition-colors focus:outline-none focus:ring-2'
  const variants = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500',
    ghost: 'bg-transparent text-gray-600 hover:bg-gray-100 focus:ring-gray-500'
  }
  const sizes = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg'
  }

  return (
    <button
      className={`${base} ${variants[variant]} ${sizes[size]}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  )
}
```

### 4. Styling with Tailwind

**Principles:**
- Use Tailwind utility classes directly — avoid custom CSS
- Extract repeated patterns into components, not @apply
- Use `cn()` helper for conditional classes (clsx + tailwind-merge)
- Mobile-first: start with base styles, add `sm:`, `md:`, `lg:` breakpoints

```tsx
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

### 5. Data Fetching

```tsx
// Server Component (Next.js App Router) — preferred
async function Dashboard() {
  const data = await fetch('https://api.example.com/stats')
  const stats = await data.json()
  return <StatsGrid stats={stats} />
}

// Client Component with SWR
'use client'
import useSWR from 'swr'

function UserProfile({ userId }: { userId: string }) {
  const { data, error, isLoading } = useSWR(`/api/users/${userId}`)
  if (isLoading) return <Skeleton />
  if (error) return <ErrorMessage error={error} />
  return <ProfileCard user={data} />
}
```

### 6. Quality Checklist

Before shipping:
- [ ] Responsive on mobile, tablet, desktop
- [ ] Keyboard navigation works
- [ ] Loading and error states handled
- [ ] Images optimized (next/image or WebP)
- [ ] No console errors or warnings
- [ ] Lighthouse score > 90

## Examples

```
> Build a dashboard with a sidebar, header, and a grid of stat cards
> Create a multi-step form with validation using react-hook-form and zod
> Build a responsive pricing page with three tiers
```
