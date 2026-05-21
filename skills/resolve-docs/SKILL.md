---
name: resolve-docs
description: "Interactively resolve open questions and documentation gaps in project docs. Scans all docs for unknowns, proposes resolutions from existing sources, and interviews the user for the rest. Writes answers back into the correct doc files. Use when: onboarding to a project with incomplete docs, preparing docs for AI-DLC, or stress-testing a design by walking through every open question."
level: advanced
category: documentation
---

# Resolve Docs

Interactively find and resolve documentation gaps. Reads all project docs, identifies unknowns, proposes answers from existing sources, and interviews the user for the rest — writing everything back into the correct files.

## When to Use

- After setting up a `docs/` folder for a new project — fill in the gaps
- Before a sprint starts — ensure all stories have enough detail for implementation
- When onboarding to an unfamiliar codebase with partial documentation
- When preparing documentation for AI-DLC / specsmd workflows
- To stress-test a design by systematically walking every open question

## Prerequisites

This skill expects a `docs/` folder with:

- An `INDEX.md` (or similar entry point) linking to all doc files
- A `decisions/open-questions.md` file tracking unresolved items (can be empty)
- Documentation files organized by topic (architecture, stories, domain, API, conventions, etc.)

If this structure doesn't exist yet, **stop and tell the user** that a structured docs/ folder is a prerequisite. Recommend running `/docs-scaffold` first to create it from their initial documentation files.

## How It Works

### Step 1: Present your understanding

Read the docs index file and follow every link to read all documentation files. Then present a structured summary of your current understanding to the user before doing anything else:

- **What is this project?** — One paragraph describing the system, its purpose, and where it sits in the landscape.
- **How does it work?** — The main flows and processes in plain language.
- **What are the components/layers?** — List each component with a one-line description of its responsibility.
- **What are the current stories/tasks?** — List each story and what it delivers.
- **What external systems are involved?** — And what you know about their APIs.
- **What cross-cutting patterns apply?** — Logging, error handling, auth, etc.

End this summary with: *"Is this understanding correct? Let me know if anything is wrong or missing before I continue."*

Wait for the user to confirm or correct before proceeding. If they correct something, update the relevant doc immediately.

### Step 2: Scan for gaps

Read all documentation files (if not already done in Step 1). Identify:

- Explicit open questions in the open-questions file
- TODOs, placeholders, or vague sections in any doc
- Missing cross-references between docs
- Acceptance criteria that reference undefined concepts
- Sections marked with "to be defined" or similar language

Present a numbered list of all gaps found, grouped by category.

### Step 3: Propose auto-resolutions (requires approval)

For each gap, check whether it can be answered from:

1. **The codebase** — if code already exists, read it to extract the answer
2. **Other docs** — the answer may already exist in a different file
3. **API specs or config files** — for integration or configuration questions

If you find an answer from these sources, **do NOT write it yet**. You MUST call the AskUserQuestion tool to present the proposed resolution. Structure the AskUserQuestion call as:

- **question**: State the question ID, what you found, and from which source
- **options**: Include "Yes, write it (Recommended)", "Skip", and let the user type their own adjustment via the built-in Other option
- **header**: Use the question ID (e.g., "OQ-8")

Only write the resolution after the user approves via the tool. If they provide a custom answer via Other, use their version instead.

### Step 4: Interview the user

For each gap that requires human input, you MUST call the **AskUserQuestion tool** — one question at a time. NEVER print questions as text output and wait for typed responses. Always use the tool.

Structure each AskUserQuestion call as:

- **question**: State the question ID, describe the gap and why it matters
- **header**: Use the question ID (e.g., "OQ-1")
- **options**: Always include your recommended answer as the first option with "(Recommended)" suffix, plus "Skip" as the last option. The user can always type their own answer via the built-in Other option.
- If the question has natural multiple-choice answers (e.g., "Maven or Gradle?"), list those as options with your recommendation first

Do not batch questions. Wait for the AskUserQuestion response before moving to the next question.

### Step 5: Write answers back

After the user approves or provides an answer (not on "skip"):

1. **Check if the answer is already in the target doc.** If the correct doc file already contains the resolved information, no edit is needed there — just note this.
2. **If the answer is new information**, write it into the **correct doc file** first (not just the open-questions file). State which file you updated and what you added.
3. **Update the open-questions file** — remove fully resolved items, or narrow the scope if only partially resolved.
4. If a new question emerged during the conversation, add it to the open-questions file.

Always tell the user exactly which files were updated and why, so there's a clear audit trail per resolution.

### Step 6: Handle reference files (e.g., OpenAPI specs)

Projects often have reference files such as OpenAPI/Swagger specs, database schemas, or configuration dumps. These are valuable for resolving gaps but vary widely in size.

If resolving a gap requires information from a reference file:

1. **Check the actual file size first.** Not all reference files are large — some OpenAPI specs are under 100KB and perfectly safe to load.
2. **If the file is small (under ~200KB):** load it directly into context. No need to ask the user or distill — just read it and extract what you need.
3. **If the file is large (200KB+):** do NOT auto-load it. Tell the user: "I need to check [file name] to answer this. It's approximately [size] — should I load it?"
4. If the user approves a large file, **load only the relevant section** — search for specific paths, schemas, or keys rather than reading the entire file
5. **Distill the findings** into the appropriate doc file (e.g., extract relevant endpoints into an API reference doc) so future queries don't need the full reference
6. Add a note in the distilled doc pointing to the full reference file, with a warning not to auto-load it if it's large

## Rules

- **CRITICAL: Always use the AskUserQuestion tool for Steps 3 and 4.** Never print a question as plain text and wait for the user to type. Every question must go through AskUserQuestion so the user gets a structured UI with selectable options.
- Never guess or fabricate answers — if you don't know, ask
- Keep doc edits minimal and focused — don't rewrite entire files
- Preserve existing structure and cross-references
- After completing a session, summarize: how many gaps resolved, how many remaining, what was added to which files

## Example Session

```
User: /resolve-docs

Agent: [Reads all docs, presents understanding summary]
       "Is this understanding correct?"

User: "Yes"

Agent: [Scans for gaps, finds 12 open questions + 3 undocumented gaps]
       "Found 15 gaps. 2 can be resolved from existing docs."

       [AskUserQuestion: "OQ-8 is already answered in the API spec. Write it?"]
User: "Yes"
Agent: [Updates open-questions.md, notes API doc already had the info]

       [AskUserQuestion: "OQ-1: How does the app connect to the database?
        Recommended: Use H2 for local dev, real instance for integration tests"]
User: "Yes"
Agent: [Writes to architecture doc, updates open-questions.md]

       ... continues through all gaps ...

Agent: "Session complete. 11 resolved, 4 skipped. Updated: architecture.md,
        data-model.md, open-questions.md"
```
