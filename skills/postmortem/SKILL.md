---
name: postmortem
description: "Draft and, after approval, capture an observed reusable lesson in a skill's gotchas.md, proposing the file when it is missing. Use after a verified bug, architecture error, process failure, or misunderstanding when the lesson can be generalized without exposing project or user information."
version: 1.2.0
level: advanced
category: meta
---

# Post-Mortem Protocol

Turn verified failures into durable, reusable guidance. A gotcha records something that actually went wrong and explains how to avoid repeating it; it is not a place for hypothetical risks, ordinary requirements, or untested preferences.

## Constraints

- Record only observed, evidence-supported failures with a verified cause or prevention.
- If no suitable `gotchas.md` exists, propose creating it with the exact path and initial content, then wait for explicit approval. Never create it automatically.
- Show the exact target and proposed text, then wait for approval before editing.
- Distinguish repository-local files from shared or globally installed skills. Never edit a shared or global skill without explicit approval for that scope.
- Remove secrets, personal information, private infrastructure details, and proprietary context.
- Preserve the target file's structure and conventions.
- Paraphrase user corrections; do not preserve exact user wording.
- Keep the conditions that made the lesson true. Do not turn a contextual lesson into an absolute rule.

## 1. Qualify the lesson

Confirm all of the following:

1. A failure, incorrect result, or user correction was actually observed.
2. The cause or prevention is supported by evidence such as a test, log, diff, reproduced behavior, or clarified requirement.
3. The lesson is likely to recur when the skill is used again.
4. The lesson belongs in operational failure guidance.

Do not create a gotcha for:

- a normal requirement, design decision, or supported mode that should be expressed naturally in the skill's workflow;
- a hypothetical concern that has not occurred;
- a one-off project fact that belongs in project documentation; or
- a guessed root cause that has not been verified.

Classify the failure only when useful to the target file. Common categories include `BUG`, `ARCHITECTURE`, `PROCESS`, `MISUNDERSTANDING`, and `PRIVACY`.

## 2. Locate the target

Use the active skill and conversation context to identify the likely target, then find its `gotchas.md` or determine where that file would belong.

- If more than one existing file is plausible, ask the user which one should receive the lesson.
- If no suitable `gotchas.md` exists, identify the expected path and continue with a `Create` proposal. Do not create the file before approval.
- Identify whether the file is repository-local or part of a shared or globally installed skill.

## 3. Establish the evidence

Summarize three elements before drafting:

- **What happened:** the observable failure or incorrect outcome.
- **Why it happened:** the verified cause, including relevant conditions.
- **What prevents it:** the smallest actionable change that would have avoided or detected it.

If the evidence supports the symptom but not the cause, record neither as a gotcha until the cause or a reliable detection rule is established.

## 4. Sanitize the lesson

Generalize the lesson without destroying the conditions that make it useful. Remove or replace:

- project, organization, person, customer, and product names;
- private file paths, hosts, URLs, repository names, ticket numbers, identifiers, and branch names;
- proprietary code, schemas, data, business rules, and internal terminology;
- credentials, tokens, cookies, keys, and secret values; name only the category of secret when relevant; and
- exact user wording or conversation excerpts.

Use neutral placeholders only when the distinction matters. Re-read the draft specifically for information that could identify the source project or user.

## 5. Compare with existing guidance

If the target exists, read the complete file. Choose one action:

- **Create:** no target file exists; propose a minimal new file containing the verified lesson.
- **Skip:** an equivalent lesson already exists.
- **Refine:** an existing entry is correct but missing an important condition, cause, or prevention.
- **Append:** the lesson is distinct and belongs in the file.
- **Resolve:** the lesson conflicts with existing guidance. Present the conflict and evidence instead of assuming the newer statement is correct.

For an existing target, place the lesson in its existing section and follow its established format. Do not reorganize unrelated content during this workflow.

## 6. Draft for approval

When the target file has no established entry format, use:

```markdown
- **What goes wrong:** <observable failure and relevant conditions>
  **Why:** <verified cause>
  **Fix:** <specific prevention or detection rule>
```

For a new file, propose the complete initial content. Follow neighboring skills' gotchas conventions when they are applicable; otherwise use a minimal `# Gotchas` heading, a relevant topic heading when useful, and the entry above. Do not add empty speculative sections.

Add a category or timestamp only if the target file already uses one. Keep the entry concise, but include enough context for another agent to apply it correctly.

Before editing, show:

- the exact file path;
- whether its scope is repository-local or shared/global;
- the proposed entry text;
- the intended action: create, skip, refine, append, or resolve; and
- any sanitization choices that materially changed the wording.

Wait for explicit approval. Approval to record a repository-local lesson does not imply approval to modify a shared or globally installed skill.

## 7. Write and verify

After approval:

1. Create or edit only the approved path and content.
2. Review the diff for unrelated changes.
3. Re-read the final entry for sensitive or identifying information.
4. Confirm that the entry matches the approved meaning and the file's format.

Report the path, action taken, and a one-line summary. If the action was `skip`, report the matching existing guidance instead of changing the file.
