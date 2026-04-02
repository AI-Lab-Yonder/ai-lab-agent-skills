# Best Practices for Claude Code Skills

Distilled from Anthropic's official skill-building guidance and real-world experience.

---

## Writing the Description

The description is a **trigger condition** for the model, not a human summary. It determines when Claude activates the skill.

**Format**: `[Action verb] [what]. Use when [specific scenario].`

**Bad examples**:
- "A helpful tool for managing deployments" (summary, not trigger)
- "Deployment skill" (too vague, no trigger condition)
- "This skill helps you deploy services to staging and production environments using our internal CI/CD pipeline" (too wordy)

**Good examples**:
- "Deploy a service with gradual traffic rollout and auto-rollback. Use when deploying to staging or production."
- "Generate a full CRUD slice following project conventions. Use when adding a new entity to the project."
- "Investigate production incidents from symptom to structured report. Use when on-call or triaging alerts."

**Rules**:
- Start with an action verb
- Under 200 characters
- Include the trigger scenario after "Use when"
- Specific enough to avoid false triggers on unrelated requests
- Broad enough to catch all relevant requests

---

## Don't State the Obvious

Claude already knows standard coding patterns, popular libraries, and common CLI tools. A skill that restates this knowledge adds noise without value.

**Focus the skill on**:
- Your organization's specific patterns and conventions
- Internal tools and APIs Claude can't know about
- Non-obvious gotchas and edge cases
- Decisions that deviate from library/framework defaults
- Domain knowledge specific to your business

**Test**: If Claude would do it correctly without the skill, that section adds no value. Remove it.

---

## Build a Gotchas Section

The highest-signal content in any skill. Gotchas capture knowledge that's expensive to rediscover.

**Critical rule**: Gotchas must come from **real failures**, not speculation. When creating a new skill, start with empty sections — do not fabricate plausible-sounding gotchas. Speculative gotchas dilute the file's value as a source of truth.

**When to add gotchas**:
- After the skill produces incorrect output during actual use
- When a user reports a failure mode during the build session
- When you hit an edge case while testing the skill

**Format each gotcha**:
- **What goes wrong**: description of the failure
- **Why**: root cause explanation
- **Fix**: how to avoid or work around it

**Growth pattern**: Start empty. Add gotchas one at a time as real failures surface. The gotchas file should be the most-updated file in any skill — but only with verified issues, never guesses.

---

## Use Progressive Disclosure

Not all information should be in SKILL.md. Structure knowledge by when it's needed:

| Layer | Contents | When loaded |
|-------|----------|-------------|
| `SKILL.md` | Overview, constraints, phase structure, pointers to sub-files | Always (on skill activation) |
| `references/` | Detailed domain knowledge, API docs, architecture guides | On-demand ("Read `references/X.md` for details") |
| `templates/` | File templates, starter code | During generation phases |
| `examples/` | Concrete reference implementations | When Claude needs patterns to follow |
| `scripts/` | Executable helpers | During execution phases |

**Key principle**: SKILL.md tells Claude **what files exist** and **when to read them**. It does not contain their full contents.

**Anti-pattern**: Dumping everything into SKILL.md. This bloats initial context and wastes tokens on information that may not be needed for every execution.

---

## Avoid Railroading

Give Claude information and context, not rigid step-by-step scripts.

**Bad** (railroading):
```
Step 1: Run exactly `npm run build`.
Step 2: Parse the output with this regex: /error: (.+)/
Step 3: For each match, create a file called fix-{n}.md
```

**Good** (informative + flexible):
```
The build system uses npm. Common error patterns include type errors
(fix in source), missing deps (run install), and config issues (check
tsconfig.json). Prioritize type errors as they block other fixes.
```

Claude can adapt to the specific situation when given context rather than commands.

---

## Setup & Configuration

If the skill needs user-specific configuration:

1. **First run**: Detect missing `config.json`, ask user via AskUserQuestion
2. **Subsequent runs**: Read config silently, proceed with execution
3. **Store in**: `config.json` in the skill directory

For structured questions, use AskUserQuestion with predefined options when possible.

**What to configure**: Slack channels, API endpoints, default branches, team names, output preferences.
**What NOT to configure**: Things derivable from the project (language, framework, file structure).

---

## Memory & Data Storage

Some skills benefit from remembering previous executions:

- **Append-only logs**: `executions.log` with timestamps and outcomes — useful for business process skills that need consistency
- **JSON state**: `state.json` for configuration that evolves over time
- **Execution artifacts**: Store in a predictable location so users can review

Note: Data stored in the skill directory may be deleted on skill upgrade. For durable storage, use paths outside the skill folder.

---

## Scripts & Code

Include scripts/libraries that let Claude compose rather than reconstruct:

- Python helpers for common operations
- Shell scripts for multi-step workflows
- SQL templates for query patterns
- Assertion libraries for verification skills

Claude can generate code on-the-fly that imports or calls your scripts, saving time and reducing errors.

---

## On-Demand Hooks

Skills can define hooks active only during skill execution:

- **PreToolUse**: Block dangerous commands (e.g., prevent `rm -rf` during a careful refactor)
- **PostToolUse**: React to outputs (auto-format, validate, run checks)

**Only add hooks when genuinely useful**. Always-on hooks that trigger on every tool call are annoying and slow. Reserve hooks for safety-critical operations.

---

## Composition

Skills can reference other skills by name. Claude will invoke them if installed.

**Design for composability**:
- Keep skills focused on one concern
- Use clear input/output contracts
- Reference other skills in SKILL.md: "If X is installed, use it for Y"
- Don't duplicate functionality that another skill handles well

---

## Pre-Finalization Checklist

Before considering a skill complete:

- [ ] Description is a trigger condition, not a summary
- [ ] SKILL.md doesn't state what Claude already knows
- [ ] Gotchas section exists with empty sections ready for real failures
- [ ] Progressive disclosure: detailed info in sub-files, not all in SKILL.md
- [ ] Flexible instructions: gives info + room to adapt, not rigid commands
- [ ] Folder structure matches the category pattern
- [ ] Setup/config handled if needed
- [ ] No overlap with existing skills
- [ ] Templates use clear placeholder markers
- [ ] Examples are concrete, not abstract
