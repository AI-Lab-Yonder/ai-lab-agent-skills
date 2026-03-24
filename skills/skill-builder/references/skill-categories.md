# Skill Categories

9 categories for classifying Claude Code skills. Use this to determine the right structure and patterns for a new skill.

---

## 1. Library & API Reference

**What it is**: Skills explaining how to correctly use a library, CLI, or internal SDK — focusing on what Claude gets wrong without guidance.

**When to use**: The user repeatedly corrects Claude on API usage, or an internal tool has non-obvious patterns that Claude can't discover from public docs.

**Typical folder structure**:
```
references/     # API docs, code snippets, pattern guides
snippets/       # Working examples Claude can copy/adapt
```

**Key success factors**:
- Focus on gotchas and edge cases, not basic usage docs
- Include real code snippets that work as-is
- Document decisions that deviate from library defaults

**Examples**: billing-lib, internal-platform-cli, frontend-design-system

---

## 2. Product Verification

**What it is**: Skills that test or verify code is working correctly end-to-end.

**When to use**: A critical user flow needs automated verification, or manual QA is a bottleneck.

**Typical folder structure**:
```
scripts/        # Test runners, assertion helpers, browser automation
fixtures/       # Test data, seed scripts
```

**Key success factors**:
- Include programmatic assertions (not just "does the page render")
- Assert on system state (DB records, API responses), not just UI
- Capture evidence: screenshots, videos, network logs

**Examples**: signup-flow-driver, checkout-verifier, tmux-cli-driver

---

## 3. Data Fetching & Analysis

**What it is**: Skills connecting to data sources, monitoring stacks, and analytics tools.

**When to use**: Investigation requires querying specific dashboards, databases, or log systems with org-specific access patterns.

**Typical folder structure**:
```
scripts/        # Query helpers, data fetchers
references/     # Schema docs, dashboard IDs, connection patterns
```

**Key success factors**:
- Include credentials pattern (env vars, config files)
- Document common query workflows and table schemas
- Map dashboard names to IDs for programmatic access

**Examples**: funnel-query, cohort-compare, grafana-dashboard

---

## 4. Business Process & Team Automation

**What it is**: Skills automating repetitive team workflows into single commands.

**When to use**: A task is done regularly (daily standup, weekly recap, ticket creation) and follows a consistent pattern.

**Typical folder structure**:
```
config.json     # Setup state (channels, templates, preferences)
logs/           # Execution history for consistency across runs
```

**Key success factors**:
- Save results in log files so the skill can reflect on previous executions
- First-run setup via AskUserQuestion to capture user-specific config
- Idempotent where possible — safe to re-run

**Examples**: standup-post, create-ticket, weekly-recap

---

## 5. Code Scaffolding & Templates

**What it is**: Skills generating framework boilerplate that matches a specific codebase's patterns.

**When to use**: Adding a new entity/component/module requires touching many files with consistent patterns.

**Typical folder structure**:
```
templates/      # File templates with placeholders
examples/       # Reference implementations
references/     # Layer anatomy, naming rules
```

**Key success factors**:
- Prefer reference entity discovery over static templates (read existing code, replicate patterns)
- Combine templates with natural language requirements that pure code can't cover
- Update registration files (DI, routes, test fixtures) as part of scaffolding

**Examples**: new-workflow, new-migration, create-app, gen-crud-slice

---

## 6. Code Quality & Review

**What it is**: Skills enforcing code quality standards and reviewing code for issues.

**When to use**: The team has specific quality standards beyond what linters catch, or reviews follow a consistent checklist.

**Typical folder structure**:
```
rules/          # Style rules, patterns to check, checklists
scripts/        # Linters, analyzers, custom checks
```

**Key success factors**:
- Consider deterministic scripts for maximum robustness
- Can run via hooks (PostToolUse) or CI for continuous enforcement
- Separate "must fix" from "nice to have" findings

**Examples**: adversarial-review, code-style, testing-practices

---

## 7. CI/CD & Deployment

**What it is**: Skills for building, deploying, and monitoring releases.

**When to use**: Deployment involves multiple steps, environment-specific config, or monitoring that benefits from automation.

**Typical folder structure**:
```
scripts/        # Build/deploy scripts, rollback helpers
templates/      # Workflow YAML templates, Dockerfiles
```

**Key success factors**:
- May reference other skills for data collection (monitoring, verification)
- Include rollback procedures for every deploy action
- Build in confirmation steps before production changes

**Examples**: babysit-pr, deploy-service, cherry-pick-prod

---

## 8. Runbooks

**What it is**: Skills that take a symptom and walk through investigation to produce a structured report.

**When to use**: On-call investigation follows patterns that can be encoded (symptom → tools → diagnosis → report).

**Typical folder structure**:
```
references/     # Symptom-to-tool mappings, architecture overview
checklists/     # Investigation steps per symptom type
```

**Key success factors**:
- Map symptoms to specific tools and query patterns
- Always produce a structured report, even if root cause is unknown
- Include severity classification and escalation criteria

**Examples**: service-debugging, oncall-runner, log-correlator

---

## 9. Infrastructure Operations

**What it is**: Skills performing routine maintenance with guardrails for destructive actions.

**When to use**: Maintenance tasks are repetitive and benefit from automation, but require safety checks before execution.

**Typical folder structure**:
```
scripts/        # Maintenance scripts, health checks
guardrails/     # Confirmation logic, soak-period definitions
```

**Key success factors**:
- Build in confirmation steps and soak periods before destructive operations
- Dry-run mode by default, require explicit flag for real execution
- Log all actions for audit trail

**Examples**: orphan-cleanup, dependency-management, cost-investigation
