---
allowed-tools: Bash(git:*), Bash(codex:*), Bash(mkdir:*), Bash(rm:*), Bash(date:*), Bash(openssl:*), Read
description: Code review using Codex agents (security + quality), then plan and fix selected issues
argument-hint: [--base <branch> | --commit <sha> | --uncommitted]
---

# Code Review via Codex

Run an independent Codex code review, read the findings, fix issues, then clean up.

## Step 1 — Set up review file path

```bash
REVIEW_ID="$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 3 2>/dev/null || head -c 3 /dev/urandom | od -An -tx1 | tr -d ' \n')" && mkdir -p reviews && echo "reviews/review-${REVIEW_ID}.md"
```

Save the resulting path as REVIEW_FILE for use in later steps.

## Step 2 — Determine what to review

Based on the argument:
- No argument or `--commit HEAD` → review last commit
- `--commit <sha>` → review that specific commit
- `--base <branch>` → review all commits since diverging from that branch
- `--uncommitted` → review staged/unstaged/untracked changes

## Step 3 — Run Codex review non-interactively

Use `codex exec` with `--dangerously-bypass-approvals-and-sandbox`. Pass a prompt that instructs Codex to write findings to REVIEW_FILE. Example for `--commit HEAD`:

```bash
codex --dangerously-bypass-approvals-and-sandbox exec "You are an independent code reviewer. Review the changes introduced by the last commit (run: git show HEAD and git diff HEAD~1..HEAD).

Review for:
- CRITICAL: hardcoded credentials, SQL/command injection, XSS, path traversal, missing auth
- HIGH: functions >50 lines, nesting >4 levels, missing error handling, debug print statements, TODO/FIXME in production code
- MEDIUM: mutation patterns (prefer immutable), missing tests for new code, accessibility issues
- LOW: naming inconsistencies, minor style issues

For each issue include: severity, file path + line number, description, suggested fix.

End with a summary table: total issues by severity.

Write the COMPLETE review to: ${REVIEW_FILE}"
```

Adjust the git command in the prompt to match the selected review scope.

## Step 4 — Read the review file

After `codex exec` completes, read REVIEW_FILE and present the findings grouped by severity (CRITICAL → HIGH → MEDIUM → LOW).

## Step 5 — Select issues to fix

Ask the user which issues they want to fix, e.g.:
> "Which issues would you like me to fix? You can list severities (e.g., all CRITICAL), specific items by file/line, or say 'all'."

If the user says none or wants to stop, skip to Step 7.

## Step 6 — Plan then fix

**CRITICAL — next turn action:** When the user replies with their selection, your **very first tool call** MUST be `EnterPlanMode`. Do not output any text or call any other tool before entering plan mode. The plan must:
- Reference the specific issues selected
- Use the file paths and line numbers from the review
- Include the suggested fixes from the report as a starting point
- Lay out concrete steps to resolve each selected issue

Wait for the user to confirm the plan before making any edits.

## Step 7 — Clean up

After all fixes are implemented (or the user decides to stop), delete the review file and directory (if empty):

```bash
rm -f "${REVIEW_FILE}" && rmdir reviews 2>/dev/null || true
```

**Never approve code with security vulnerabilities.**
