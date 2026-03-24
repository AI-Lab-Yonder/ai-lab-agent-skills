# AI Coding Agent Commands Cheatsheet

Not the basics — the commands that actually change how you work.

---

## Claude Code

| # | Command | What it does |
|---|---------|-------------|
| 1 | `/model sonnet \| opus \| haiku` | Switch models mid-session based on task complexity |
| 2 | `@path/to/file` | Add any file or folder directly into context instantly |
| 3 | `Shift+Tab` then `Tab` | Enter plan mode — Claude reads and analyzes but can't edit files |
| 4 | `/btw [question]` | Ask a side question mid-task without touching conversation history |
| 5 | `Esc` + `Esc` | Rewind to any prior turn — restore code, conversation, or both |
| 6 | `/context` | Visual fuel gauge of your context window — know when to compact |
| 7 | `/compact [focus area]` | Compress history, keep what matters. Run at ~70%, don't wait for 95% |
| 8 | `/clear` | Nuke everything, fresh session. Use between unrelated tasks |
| 9 | `/insights` | HTML report of your past month: costs, patterns, tool usage, habits |

---

## Codex

| # | Command | What it does |
|---|---------|-------------|
| 1 | `/model gpt-5.4 \| gpt-5.3-codex` | Switch models mid-session, also adjust reasoning effort level |
| 2 | `/mention path/to/file` | Add any file to conversation so Codex references it directly |
| 3 | `Shift+Tab` or `/plan` | Enter plan mode — Codex reads, questions, and plans before coding |
| 4 | `/reasoning low \| med \| high \| xhigh` | Control how deeply Codex thinks. xhigh for hard problems, low for speed |
| 5 | `/personality friendly \| pragmatic \| none` | Change communication style without rewriting your prompt |
| 6 | `/review` | Code review of uncommitted changes — flags issues, missing tests |
| 7 | `Cmd+J` / `Ctrl+J` | Toggle the integrated terminal panel |
| 8 | `Cmd+Option+B` / `Ctrl+Alt+B` | Toggle the diff panel to see file changes side-by-side |
| 9 | `/status` | Show active model, approval policy, context usage, rate limits |
