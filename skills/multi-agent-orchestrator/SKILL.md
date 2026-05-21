---
name: multi-agent-orchestrator
description: "Coordinate multiple AI agents to tackle complex tasks. Split work across specialized agents, merge results, and maintain quality. Use when: a task is too complex for a single prompt, needs parallel work streams, or requires different expertise at different stages."
version: 1.0.0
level: advanced
category: architecture
---

# Multi-Agent Orchestrator

Break complex tasks into specialized agent workflows.

## When to Use

- A task requires multiple areas of expertise (frontend + backend + database)
- Work can be parallelized across independent streams
- Sequential pipeline: research → plan → implement → review
- Complex refactoring across many files

## How It Works

### 1. Workflow Patterns

#### Sequential Pipeline

```
[Research] → [Plan] → [Implement] → [Test] → [Review]
```

Best for: feature development, bug investigation

```
Step 1: Research the codebase to understand existing patterns
Step 2: Create a detailed implementation plan
Step 3: Implement the changes following the plan
Step 4: Write tests for the implementation
Step 5: Review code for quality and security
```

#### Parallel Fan-Out

```
         ┌→ [Frontend Agent] ─┐
[Plan] ──┤→ [Backend Agent]  ─├→ [Integration]
         └→ [Database Agent] ─┘
```

Best for: full-stack features, multi-concern tasks

#### Review Chain

```
[Code] → [Security Review] → [Performance Review] → [Final Check]
```

Best for: high-stakes changes, compliance-sensitive code

### 2. Agent Specialization

Define clear boundaries for each agent:

```markdown
## Agent: Backend Builder
**Scope:** API routes, database queries, server logic
**Tools:** Read, Write, Edit, Bash (for running tests)
**Constraint:** Never modify frontend files (src/components/*)
**Output:** Working API endpoints with tests

## Agent: Frontend Builder
**Scope:** React components, pages, styling
**Tools:** Read, Write, Edit, Bash (for running dev server)
**Constraint:** Never modify API routes or database code
**Output:** Working UI components connected to API

## Agent: Code Reviewer
**Scope:** Review all changed files
**Tools:** Read, Grep, Glob (read-only)
**Constraint:** No file modifications — only report findings
**Output:** Review comments with severity and fix suggestions
```

### 3. Orchestration in Claude Code

Use subagents for parallel work:

```
# In your prompt to Claude Code:

I need to build a user dashboard. Orchestrate this as follows:

1. **Planning agent**: Read the codebase and create an implementation plan
   for a user dashboard with profile, settings, and activity history.

2. **Backend agent**: Build the API endpoints:
   - GET /api/dashboard/profile
   - GET /api/dashboard/activity
   - PUT /api/dashboard/settings

3. **Frontend agent**: Build the dashboard pages:
   - /dashboard (overview)
   - /dashboard/settings

4. **Test agent**: Write tests for both backend and frontend.

5. **Review agent**: Review all changes for quality and security.
```

### 4. Coordination Rules

- **Shared contract first** — define the API interface before agents start
- **No overlapping files** — each agent owns specific directories
- **Integration point** — one agent merges the work and resolves conflicts
- **Quality gate** — nothing ships without review agent approval

### 5. Error Recovery

```
If an agent fails:
1. Check its output for the error
2. Fix the issue in the specific agent's scope
3. Re-run only that agent (don't restart the whole pipeline)
4. Verify integration after the fix
```

## Example: Full-Stack Feature

```
Task: "Add a comments feature to blog posts"

Agent 1 — Planner:
  Read existing Post model, API routes, and UI
  Output: plan.md with schema changes, endpoints, components

Agent 2 — Backend (after planner):
  Add Comment model to Prisma schema
  Create GET/POST /api/posts/:id/comments
  Write API tests

Agent 3 — Frontend (after planner, parallel with backend):
  Create CommentList, CommentForm components
  Add comments section to PostPage
  Wire up to API endpoints

Agent 4 — Integration (after both):
  Run full test suite
  Fix any integration issues
  Verify end-to-end flow

Agent 5 — Reviewer (after integration):
  Security check (XSS in comments, auth)
  Performance check (N+1 queries, pagination)
  Code quality check
```

## Examples

```
> Build a notification system using a multi-agent pipeline
> Refactor the auth module — plan, implement, test, review in stages
> Add real-time chat: backend agent for WebSocket, frontend agent for UI
```
