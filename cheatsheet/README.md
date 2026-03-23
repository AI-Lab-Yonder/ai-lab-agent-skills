# Cheatsheet: Claude Code & Codex Commands

Quick reference for the most useful commands in your AI coding workflow.

---

## Claude Code

### Session & Navigation

| Command | What it does |
|---------|-------------|
| `claude` | Start a new Claude Code session |
| `claude "prompt"` | Start with an initial prompt |
| `claude -r` | Resume the most recent conversation |
| `claude -c` | Continue the last conversation |
| `/clear` | Clear conversation history |
| `/exit` or `Ctrl+C` | Exit Claude Code |
| `/compact` | Compress conversation to save context |
| `/context` | Show current context window usage |
| `/cost` | Show token usage and cost for the session |

### File & Code Operations

| Command | What it does |
|---------|-------------|
| `/plan` | Create a step-by-step implementation plan |
| `/code-review` | Review uncommitted code changes |
| `/build-fix` | Automatically fix build/type errors |
| `/test-coverage` | Analyze and improve test coverage |
| `/tdd` | Start test-driven development workflow |
| `/refactor-clean` | Find and remove dead code |

### Configuration & Settings

| Command | What it does |
|---------|-------------|
| `/model` | Switch between models (Opus, Sonnet, Haiku) |
| `/permissions` | View and manage tool permissions |
| `/config` | View or change settings |
| `/help` | Show all available commands |
| `/doctor` | Diagnose common issues |
| `/install-skill <path>` | Install a skill from a directory |

### MCP & Integrations

| Command | What it does |
|---------|-------------|
| `/mcp` | View connected MCP servers |
| `claude mcp add <name> <command>` | Add an MCP server |
| `claude mcp list` | List configured MCP servers |

### Pro Tips

| Tip | Description |
|-----|-------------|
| `@file.ts` | Reference a specific file in your prompt |
| `#codebase` | Search across the entire codebase |
| Shift+Enter | Multi-line input |
| Esc | Cancel current generation |
| Tab | Accept autocomplete suggestion |

---

## Codex (OpenAI)

### Session & Navigation

| Command | What it does |
|---------|-------------|
| `codex` | Start a new Codex session |
| `codex "prompt"` | Start with an initial prompt |
| `/exit` or `Ctrl+C` | Exit Codex |
| `/clear` | Clear conversation |
| `/history` | Show conversation history |

### Modes

| Command | What it does |
|---------|-------------|
| `/mode ask` | Read-only mode - only answers questions, no file changes |
| `/mode suggest` | Suggests changes, asks for approval before applying |
| `/mode auto` | Autonomous mode - applies changes directly |

### File & Code Operations

| Command | What it does |
|---------|-------------|
| `/read <file>` | Read a specific file |
| `/diff` | Show pending changes |
| `/undo` | Undo last change |
| `/apply` | Apply suggested changes |

### Configuration

| Command | What it does |
|---------|-------------|
| `/model` | Switch model |
| `/config` | View or update settings |
| `/help` | Show all available commands |

### Pro Tips

| Tip | Description |
|-----|-------------|
| `codex -a "prompt"` | Run in auto mode from CLI |
| `codex -q "prompt"` | Quick question, no interactive session |
| Pipe input | `cat file.ts \| codex "explain this"` |

---

## Side-by-Side Comparison

| Feature | Claude Code | Codex |
|---------|-------------|-------|
| Start session | `claude` | `codex` |
| Resume session | `claude -r` | N/A |
| Modes | Permission-based | `ask` / `suggest` / `auto` |
| Plan | `/plan` | Ask in prompt |
| Code review | `/code-review` | Ask in prompt |
| Fix builds | `/build-fix` | Ask in prompt |
| Context control | `/compact`, `/context` | `/clear` |
| Exit | `/exit`, `Ctrl+C` | `/exit`, `Ctrl+C` |
| MCP support | Yes (built-in) | Yes |
| Skills/Plugins | `/install-skill` | `.codex/` config |
| File reference | `@file.ts` | Mention in prompt |

---

## Workshop Quick Start

```bash
# 1. Start Claude Code in your project
cd my-project
claude

# 2. Plan your feature
> /plan Add a user authentication system

# 3. Let it build
> Build the auth system following the plan

# 4. Review the code
> /code-review

# 5. Fix any issues
> /build-fix
```

```bash
# 1. Start Codex in auto mode
cd my-project
codex -a "Add user authentication with JWT tokens"

# 2. Or use interactive mode
codex
> /mode suggest
> Add user authentication with JWT tokens
```
