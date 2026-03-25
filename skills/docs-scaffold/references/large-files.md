# Handling Large Reference Files

How to handle OpenAPI specs, database schemas, and other large reference files. Read this during Phase 6 or whenever the user provides a file that might be large.

## Detection

Large files include:
- OpenAPI / Swagger specs (typically 1-5MB+)
- Database schema dumps / DDL files
- WSDL files
- Large configuration files
- Data dictionaries

## Protocol

1. **Never auto-load.** Ask the user: "I see [file name] (~[size]). Should I load it to distill the relevant parts?"
2. If approved, **search for specific paths/schemas** — do not read the entire file
3. Distill only endpoints/schemas **relevant to the current stories** into a readable markdown file
4. Store the original file in `api/specs/` (or equivalent subfolder)

## Distilled Doc Structure

The distilled doc should contain:

1. **Warning banner** at the top:
   ```
   > This doc covers only the endpoints relevant to current stories.
   > The full spec is at `specs/[filename]` (~[size]).
   > **Do not auto-load.** Ask the user before reading.
   > If this doc doesn't answer your question, ask whether to distill more.
   ```

2. **Base URL and auth flow** — server URL, auth mechanism, token endpoints
3. **Relevant endpoints only** — path, method, description, request/response schemas
4. **Mapping table** bridging API endpoints to stories:
   ```markdown
   | Story | Primary Endpoint | Operation |
   |-------|-----------------|-----------|
   | [Story name] | `GET /v1/resource` | Read resources for transformation |
   ```

## INDEX.md Warning

INDEX.md must include a warning about the specs folder:

```markdown
## API
- [API Reference](api/api-name.md) — Distilled endpoints (read this first)
- [Full Spec](api/specs/) — Raw JSON/YAML (~X MB). **Do not auto-load.** Ask the user before reading.
```
