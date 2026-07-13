---
name: multi-agent-orchestrator
description: "Coordinate specialized agent roles across complex tasks using dependency-aware planning, explicit ownership, structured handoffs, safe integration, and evidence-based quality gates. Use when work has multiple independent streams or genuinely benefits from isolated expertise; fall back transparently when the runtime cannot provide separate workers."
version: 1.1.0
level: advanced
category: architecture
---

# Multi-Agent Orchestrator

Break complex work into bounded roles, run only independent tasks concurrently, integrate results safely, and verify the combined outcome.

## When to Use

Use orchestration when at least two work streams are meaningfully separable, such as:

- Several independent areas of expertise
- Research, implementation, testing, and review stages that benefit from clean contexts
- Disjoint components that can be developed concurrently
- Independent review perspectives for high-risk work

Do not orchestrate when:

- One agent can complete the task directly with less coordination overhead
- The change is small, single-file, or tightly coupled
- Every step depends on the previous step's detailed output
- Workers would need to edit the same files concurrently
- The runtime cannot provide needed isolation and the user does not accept the sequential fallback

## Constraints

- Select an execution mode before assigning work
- Define dependencies, ownership, and integration order before parallel execution
- Never allow concurrent writes to the same file or shared mutable resource
- Give each role only the context and capabilities it needs
- Obtain approval before sending project content to an external agent service
- Treat worker reports as claims to verify, not proof of completion
- Use checks and evidence for quality gates; reviewer approval alone is insufficient
- Retry a failed assignment automatically at most once, and only when the corrective change is clear
- Do not create branches, commits, merges, uploads, or other external side effects unless the user's task authorizes them

## Phase 0 — Select the Execution Mode

Choose the strongest available mode:

| Mode | Execution | Independence |
|---|---|---|
| **Native isolated workers** | Use the runtime's delegation capability with a clean context for each role | Preferred |
| **External isolated sessions** | Use separate approved sessions or processes with an explicit handoff | Preferred, but requires approval before sharing project content externally |
| **Sequential same-context fallback** | Execute each role as a separate pass in the current context | Reduced |

For the sequential fallback, tell the user:

> This runtime cannot provide isolated workers for the planned roles. I can execute the same dependency and handoff plan sequentially, but the roles may influence one another and there is no true parallelism.

Record the selected mode in the final summary. Never describe same-context role passes as independent agents.

## Phase 1 — Decompose the Work

Build a dependency graph before dispatching anything.

For each proposed assignment, determine:

- Whether it is required
- What must finish before it starts
- What files or resources it owns
- Whether it is read-only or may write
- What contract it consumes from earlier work
- What artifact or structured result it must return
- How its result will be verified

Dispatch tasks concurrently only when they have no unresolved dependency and no write conflict.

### Common Workflow Patterns

#### Sequential Pipeline

```text
[Research] → [Plan] → [Implement] → [Test] → [Review]
```

Use when each stage consumes the previous stage's result. Different roles can still provide clean contexts even though the work is serial.

#### Parallel Fan-Out

```text
                 ┌→ [Component A] ─┐
[Shared Contract] ┼→ [Component B] ─┼→ [Integration] → [Verification]
                 └→ [Component C] ─┘
```

Use only after the shared contract is stable and ownership is disjoint.

#### Review Chain

```text
[Candidate] → [Correctness Review] → [Security Review] → [Integrated Checks]
```

Reviews may run in parallel when they are read-only. Consolidate duplicate or contradictory findings before asking for fixes.

## Phase 2 — Define the Workspace and Ownership Model

Choose one model explicitly:

### Shared Workspace

- Parallel roles may be read-only or own disjoint files
- Give each writable file one primary owner
- Route shared contract files, manifests, schemas, lockfiles, and generated indexes through one serial integration owner
- Recheck the worktree before applying each handoff because another role may have changed it

### Isolated Workspaces

- Give each writable role its own isolated workspace when the runtime supports it
- Record the base revision and owned scope
- Integrate results in dependency order
- Resolve conflicts deliberately; never discard another role's work to make integration easier

### Sequential Fallback

- Use one workspace and complete one role before starting the next
- Preserve the same task contracts and handoffs
- Re-evaluate downstream assignments when an earlier result changes the plan

“No overlapping files” is a planning preference, not an absolute rule. Shared files are allowed when one owner edits them serially after dependent results are available.

## Phase 3 — Write a Task Contract

Every assignment must receive a compact contract:

```markdown
## Task: [ID and role]

**Objective:** [One bounded outcome]
**Execution mode:** [native worker / external session / sequential pass]
**Inputs:** [Required files, prior artifacts, and decisions]
**Dependencies:** [Task IDs or none]
**Owned scope:** [Files, directories, or read-only review scope]
**Forbidden scope:** [Files, resources, and side effects that must not change]
**Capabilities:** [Filesystem read/write, search, commands, browser, or other generic capabilities]
**Deliverables:** [Files, report, decision, or patch]
**Verification:** [Specific commands or checks]
**Completion criteria:** [Observable definition of done]
```

Avoid product-specific tool names. Describe the capability needed and let the runtime map it to available tools.

## Phase 4 — Execute and Monitor

1. Start only assignments whose dependencies are satisfied.
2. Run read-only or disjoint work concurrently when the selected mode permits it.
3. Keep the user informed about active roles, completed handoffs, and material blockers.
4. Validate each handoff before unlocking dependent work.
5. If a role fails, determine whether the contract was unclear, an input was missing, or the task itself failed.
6. Retry once only when a bounded correction is available. Otherwise replan or report the blocker.

Do not restart the entire pipeline because one role failed unless its output invalidates every downstream task.

## Phase 5 — Require a Structured Handoff

Each role returns:

```markdown
## Handoff: [Task ID]

**Status:** complete / blocked / failed
**Summary:** [What was accomplished]
**Changed files:** [Paths, or none]
**Artifacts:** [Reports, plans, schemas, or other outputs]
**Checks run:** [Command/check and result]
**Assumptions:** [Material assumptions]
**Unresolved issues:** [Remaining risks or blockers]
**Recommended next step:** [What the dependent role should do]
```

A `complete` status without the required deliverables or verification evidence is incomplete. Inspect the actual files and fresh check output before accepting it.

## Phase 6 — Integrate

The coordinator or designated integration owner:

1. Confirms every required handoff is present and valid.
2. Applies or reconciles results in dependency order.
3. Updates shared files serially.
4. Checks that interfaces and assumptions agree across work streams.
5. Runs focused checks after each risky integration step.
6. Runs the combined validation suite after all required work is integrated.

If two roles disagree, compare their evidence and the shared contract. Do not choose a result merely because one role sounds more confident.

## Phase 7 — Evidence-Based Quality Gate

Before declaring success, require evidence appropriate to the task:

- Expected files or artifacts exist
- Focused tests and static checks pass
- Cross-component integration checks pass
- Security or privacy checks are complete when relevant
- Review findings are resolved, accepted explicitly, or documented as remaining risks
- The final worktree contains no unintended changes from another role

A review role reports findings; it does not grant release approval. The user or owning workflow makes the final release or merge decision using the evidence.

## Example — Full-Stack Change

```text
Task A — Contract planner (read-only)
  Define request/response contracts and acceptance criteria

Task B — Service implementation (depends on A)
  Own server implementation and focused service tests

Task C — Interface implementation (depends on A)
  Own client implementation and focused interface tests

Task D — Integration owner (depends on B and C)
  Own shared types and integration fixes; run combined checks

Task E — Reviewer (depends on D, read-only)
  Report correctness, security, and performance findings with evidence
```

Tasks B and C may run in parallel only when their writable scope is disjoint. Task D owns shared files serially. Task E's findings feed the final evidence-based quality gate.

## Final Summary

Report:

- Execution mode and independence level
- Assignments completed, blocked, or failed
- Ownership and integration model used
- Files and artifacts produced
- Checks run and their results
- Retries performed
- Unresolved risks and assumptions
- Recommended next action
