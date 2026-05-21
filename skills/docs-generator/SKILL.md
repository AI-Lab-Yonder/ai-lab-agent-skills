---
name: docs-generator
description: "Auto-generate documentation from code. Creates READMEs, API docs, and architecture overviews. Use when: a project lacks documentation, onboarding new team members, or preparing code for open source."
version: 1.0.0
level: beginner
category: documentation
---

# Docs Generator

Generate clear, useful documentation from existing code.

## When to Use

- Project has no README or outdated docs
- Onboarding new team members
- Preparing a repo for open source
- Documenting an API for consumers
- Creating architecture overviews

## How It Works

### 1. README.md

Every project needs a README with these sections:

```markdown
# Project Name

One-line description of what this project does.

## Quick Start

\`\`\`bash
# Install
npm install

# Run locally
npm run dev

# Run tests
npm test
\`\`\`

## Project Structure

\`\`\`
src/
├── app/          # Pages and routes
├── components/   # UI components
├── lib/          # Utilities and helpers
└── types/        # TypeScript types
\`\`\`

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `NEXTAUTH_SECRET` | Auth encryption key | Yes |

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/users` | List all users |
| POST | `/api/users` | Create a user |

## Contributing

1. Fork the repo
2. Create a feature branch
3. Submit a pull request
```

### 2. API Documentation

For each endpoint, document:

```markdown
### POST /api/users

Create a new user account.

**Request:**
\`\`\`json
{
  "email": "alice@example.com",
  "name": "Alice",
  "role": "user"
}
\`\`\`

**Response (201):**
\`\`\`json
{
  "data": {
    "id": "clx123",
    "email": "alice@example.com",
    "name": "Alice",
    "createdAt": "2024-01-15T10:00:00Z"
  }
}
\`\`\`

**Errors:**
| Status | Code | Description |
|--------|------|-------------|
| 400 | VALIDATION_ERROR | Invalid input |
| 409 | DUPLICATE_EMAIL | Email already exists |
```

### 3. Code Comments

Add JSDoc only where the code isn't self-explanatory:

```typescript
// DON'T document the obvious
/** Gets the user name */  // ❌ unnecessary
function getUserName() {}

// DO document non-obvious behavior
/**
 * Calculates shipping cost with regional multipliers.
 * Free shipping for orders over $100 in the US.
 * International orders have a 2.5x base rate multiplier.
 */
function calculateShipping(order: Order, region: Region): number {}
```

### 4. Architecture Docs

For complex projects, create a brief architecture overview:

```markdown
## Architecture

### Data Flow
User → Next.js Page → API Route → Service Layer → Prisma → PostgreSQL

### Key Decisions
- **Next.js App Router** for server components and streaming
- **Prisma** for type-safe database access
- **Zod** for runtime validation at API boundaries
- **NextAuth** for session-based authentication
```

## Process

```
1. Read the codebase structure (package.json, src/, key files)
2. Identify the tech stack and frameworks
3. Map the project structure
4. Document setup steps (verified by reading scripts)
5. List API endpoints (from route files)
6. Add environment variable docs (from .env.example)
7. Write it in clear, scannable markdown
```

## Examples

```
> Generate a README for this project
> Document all API endpoints with request/response examples
> Create an architecture overview of this codebase
```
