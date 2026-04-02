# Example: ERP Adapter Application

A real-world session where docs-scaffold was used to structure documentation for a greenfield Spring Boot middleware project.

## Input

Two raw markdown files:

1. **`architecture_ai_compatible.md`** (~180 lines)
   - System overview with mermaid diagram
   - Outbound and inbound message flows
   - Layer descriptions (Translation, Queue, Delivery)
   - Data model: Message (parent) → MessageHandling (child) records
   - Architectural constraints (async comms, RabbitMQ compatibility, legacy ERP dependency)
   - Notes on priority lanes and virtual threading

2. **`USERSTORIES.md`** (~190 lines)
   - 4 user stories: Translation Layer, Queue Layer, Delivery Layer, Mock Financial Partner
   - Each with acceptance criteria and AI-assisted testing notes
   - References to Financial System API (external financial application)
   - Cross-cutting patterns: MessageHandling status tracking + Elasticsearch logging in every story

Additionally, a large external reference:
- **Financial System OpenAPI spec** (~4.3MB, 393 endpoints) — fetched from public URL, not auto-loaded

## Output

14 files across 6 subdirectories + AGENTS.md at project root:

```
docs/
├── INDEX.md                           # TOC with "how to use" navigation instructions
├── architecture/
│   ├── overview.md                    # Mermaid diagram, layer table, constraints
│   ├── data-model.md                  # Message/MessageHandling, status lifecycle, storage
│   └── cross-cutting-concerns.md      # Polling, idempotency, retry/DLQ, backpressure, priority, virtual threading
├── domain/
│   ├── glossary.md                    # Domain term translations and definitions
│   └── message-types.md              # Tax codes + tax rates, type-driven behavior per layer
├── stories/
│   ├── translation-layer.md           # Summary, Context (links), Acceptance Criteria, Testing notes
│   ├── queue-layer.md
│   ├── delivery-layer.md
│   └── mock-financial-partner.md
├── api/
│   ├── financial-system-api.md        # Distilled: auth flow, /v1/vat, /v1/vatCategory, /v1/vatZone + schemas
│   └── specs/
│       └── financial-system-service.json  # Full 4.3MB spec (never auto-loaded)
├── conventions/
│   └── logging-status-tracking.md     # Dual-write pattern: Oracle DB + Elasticsearch append-only log
└── decisions/
    └── open-questions.md              # 19 gaps across 6 categories

AGENTS.md (project root)               # Points to docs/INDEX.md, project summary, key rules
```

## Key Decisions Made During Scaffolding

1. **Glossary created first** — The legacy ERP domain uses non-English terms while the codebase uses English. Without the glossary, every generated doc would use inconsistent naming.

2. **Cross-cutting concern extracted early** — Every story mentioned "insert MessageHandling record + append to Elasticsearch" at every step. This was extracted into `conventions/logging-status-tracking.md` before writing story files, preventing duplication across 4 stories.

3. **API spec distilled, not loaded** — The 4.3MB OpenAPI spec was searched for specific paths (`/v1/vat`, `/v1/vatCategory`, `/v1/vatZone`) and only those endpoints + schemas were distilled into `financial-system-api.md`. A mapping table connected endpoints to stories.

4. **19 open questions identified** — Gaps fell into 6 categories: Architecture (4), Data Model (3), Integration (3), Project Setup (5), Testing (2), CI/CD (2). These became the starting point for `/resolve-docs` sessions.

## What Went Well

- The two-checkpoint confirmation (understanding + structure) caught a misunderstanding about sync direction before files were created
- Story files with context links meant each developer could read their story and find everything they needed via links
- The glossary prevented the agent from inconsistently mixing domain terms across docs

## What Would Be Done Differently

- Should have extracted cross-cutting-concerns.md content MORE aggressively from stories — some patterns were partially duplicated
- The open-questions should have been prioritized (blocking vs nice-to-have) rather than flat-listed
