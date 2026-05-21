---
name: skill-creator
description: "Generate new reusable skills from git history, coding patterns, and team practices. The meta-skill: teaches the AI to create new skills. Use when: you have recurring patterns worth capturing, want to codify team knowledge, or need to create custom workflows for your project."
version: 1.0.0
level: advanced
category: meta
---

# Skill Creator

Create reusable skills that capture your team's patterns and knowledge.

## When to Use

- You find yourself giving the same instructions repeatedly
- Your team has coding patterns that should be standardized
- You want to extract wisdom from your git history
- You need a custom workflow for a specific project or domain
- After a successful session, to capture what worked

## How It Works

### 1. Identify the Pattern

Skills come from recurring needs. Look for:

```
Signals that a skill is needed:
- "I keep telling the AI to..."
- "Every time we build a [X], we follow these steps..."
- "New team members always get [X] wrong"
- "Our best PRs always include [X]"
```

### 2. Skill File Structure

Every skill lives in `skills/<skill-name>/SKILL.md`:

```markdown
---
name: skill-name
description: "One-paragraph description of what this skill does and when to use it. Be specific — this text is used to decide when to activate the skill."
version: 1.0.0
level: beginner | advanced
category: ai | architecture | backend | code-quality | database | debugging | documentation | frontend | fullstack | meta | security | testing
---

# Skill Title

One-line summary of what this skill does.

## When to Use

- Bullet list of specific triggers
- When the user asks to [specific task]
- When working with [specific technology]

## How It Works

### Step 1: [First Phase]
Explanation with code examples...

### Step 2: [Next Phase]
More explanation...

## Quality Checklist
- [ ] Verification steps

## Examples
\`\`\`
> Example prompts that would trigger this skill
\`\`\`
```

### 3. Extract from Git History

Analyze your repo to find patterns worth capturing:

```bash
# Find your most-changed files (hot spots)
git log --pretty=format: --name-only | sort | uniq -c | sort -rn | head -20

# Find common commit message patterns
git log --oneline -100 | grep -oP '^\w+ \K\w+' | sort | uniq -c | sort -rn

# Find files that change together (coupling)
git log --pretty=format:'%H' | while read hash; do
  git diff-tree --no-commit-id --name-only -r $hash
done | sort | uniq -c | sort -rn | head -20
```

**Patterns to look for:**
- Files that always change together → skill for that workflow
- Repeated commit message patterns → skill for that task type
- Complex files with many changes → skill with guidelines for that area

### 4. Extract from a Session

After a successful AI session:

```
1. Review what you built together
2. Identify the approach that worked:
   - What context did you provide?
   - What constraints mattered?
   - What steps did the AI follow?
   - What quality checks caught issues?
3. Generalize it into a reusable skill
```

### 5. Quality Criteria for Skills

A good skill:

| Criteria | Check |
|----------|-------|
| **Specific trigger** | Clear "When to Use" — not everything |
| **Actionable steps** | Concrete code examples, not just principles |
| **Tested patterns** | Based on real code that works, not theory |
| **Appropriate scope** | Solves one problem well, not everything poorly |
| **Reusable** | Works across projects, not tied to one codebase |
| **Maintainable** | Easy to update as practices evolve |

### 6. Skill Levels

**Beginner skills** should:
- Be self-contained (no prerequisite knowledge)
- Include complete code examples
- Cover the happy path thoroughly
- Have a clear, linear workflow

**Advanced skills** should:
- Handle edge cases and error scenarios
- Include decision trees (if X, do Y)
- Reference other skills where relevant
- Cover debugging and troubleshooting

### 7. Testing Your Skill

```
1. Use the skill in a fresh session with no other context
2. Try it on 3 different projects/scenarios
3. Check: Does it produce consistent, good results?
4. Check: Is any step confusing or skipped by the AI?
5. Iterate on the parts that don't work
```

## Process Summary

```
1. Identify a recurring pattern (from git, sessions, or team feedback)
2. Draft the SKILL.md with the standard structure
3. Add real code examples from your codebase
4. Test it in 3 different scenarios
5. Refine based on results
6. Share with the team
```

## Examples

```
> Create a skill for our team's API endpoint pattern
> Extract a skill from the last 50 commits on the auth module
> Build a skill for our deployment checklist
> Turn this session's approach into a reusable skill
```
