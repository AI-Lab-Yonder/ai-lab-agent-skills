---
name: prompt-engineer
description: |
  Craft and optimize prompts for better AI output. Improve clarity, structure,
  and effectiveness of prompts for Claude Code, Codex, and other AI tools.
  Use when: getting poor results from AI, building reusable prompt templates,
  or creating skills and agents.
level: advanced
category: ai
---

# Prompt Engineer

Write prompts that get consistently good results from AI coding tools.

## When to Use

- AI output is vague, wrong, or not what you wanted
- Building reusable prompt templates for your team
- Creating new skills or agent definitions
- Optimizing an existing workflow for better results

## How It Works

### 1. Prompt Structure

Effective prompts have clear structure:

```markdown
## Role (who the AI should be)
You are a senior TypeScript developer specializing in Next.js.

## Context (what the AI needs to know)
We have a Next.js 14 app with App Router, Prisma ORM, and PostgreSQL.
The codebase uses server components by default.

## Task (what to do — be specific)
Add a search endpoint at GET /api/search that:
- Accepts a `q` query parameter
- Searches the `posts` table by title and content
- Returns paginated results (20 per page)
- Uses full-text search with PostgreSQL ts_vector

## Constraints (boundaries and rules)
- Do NOT use client-side filtering
- Use Zod for input validation
- Follow existing patterns in app/api/
- Include error handling for empty queries

## Output format (what the result should look like)
Create the route file and a corresponding test file.
```

### 2. Common Prompt Mistakes

| Mistake | Example | Fix |
|---------|---------|-----|
| Too vague | "Make it better" | "Reduce the function from 50 to <20 lines by extracting validation" |
| No context | "Add search" | "Add search to the /api/posts endpoint using PostgreSQL full-text search" |
| Too many tasks | "Build the whole app" | Break into steps: "First, set up the database schema" |
| No constraints | "Add auth" | "Add JWT auth using NextAuth, session-based, no OAuth" |
| Assumed knowledge | "Fix the bug" | "Fix the TypeError on line 42 of UserList.tsx — data is undefined on first render" |

### 3. Prompt Patterns

#### Step-by-Step

Force the AI to think through the problem:

```
Before writing code:
1. Read the existing UserService and understand its API
2. List the changes needed
3. Implement each change one at a time
4. Run tests after each change
```

#### Few-Shot Examples

Show what you want with examples:

```
Convert these function names from camelCase to snake_case:

Examples:
- getUserById → get_user_by_id
- calculateTotalPrice → calculate_total_price

Now convert:
- fetchAllOrders
- validateUserInput
- sendNotificationEmail
```

#### Negative Constraints

Tell it what NOT to do:

```
Refactor this component:
- Do NOT change the component's public API (props)
- Do NOT add new dependencies
- Do NOT split into multiple files
- Do NOT change test files
```

#### Role + Audience

```
Explain this code as if I'm a junior developer who knows JavaScript
but has never used React. Focus on the state management pattern.
```

### 4. Optimizing Iteratively

```
Draft 1: "Add tests"
  → Too vague, AI writes random tests

Draft 2: "Write unit tests for lib/pricing.ts"
  → Better scope, but tests might be trivial

Draft 3: "Write unit tests for lib/pricing.ts covering:
  - Standard pricing calculation
  - Bulk discount (>100 units)
  - Negative quantities (should throw)
  - Zero price items
  - Currency rounding to 2 decimals
  Use Jest with describe/it blocks."
  → Specific, covers edge cases, defines tool
```

### 5. Prompt Templates

#### Code Generation

```
Create [component/function/endpoint] that:
- [specific behavior 1]
- [specific behavior 2]
- [specific behavior 3]

Follow the patterns in [reference file].
Use [specific libraries/tools].
Include [tests/types/error handling].
```

#### Code Review

```
Review [file/PR] for:
1. Security vulnerabilities (injection, XSS, auth bypass)
2. Performance issues (N+1 queries, unnecessary re-renders)
3. Code quality (readability, naming, duplication)

For each issue: severity (critical/warning/info), location, and fix.
```

#### Debugging

```
This code throws [exact error message] when [steps to reproduce].

Expected behavior: [what should happen]
Actual behavior: [what happens instead]

The relevant files are [file1, file2].
Recent changes: [what changed].
```

## Quality Checklist

- [ ] Task is specific and measurable
- [ ] Context includes the tech stack and relevant files
- [ ] Constraints prevent unwanted changes
- [ ] Output format is defined
- [ ] Prompt works consistently (test 3+ times)

## Examples

```
> Optimize this prompt to get better code generation results
> Create a reusable prompt template for API endpoint generation
> Turn this vague request into a structured, effective prompt
```
