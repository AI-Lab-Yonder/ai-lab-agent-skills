# Handling Reference Files

Use this protocol for OpenAPI specifications, database schemas, data dictionaries, and other reference material.

## Check Before Loading

Inspect the file's size, format, relevance, and sensitivity first. File size is only a rough proxy for context cost.

- **Small and relevant:** Read directly when it fits comfortably in the available context.
- **Large, highly structured, or only partly relevant:** Search or read targeted sections instead of loading the full file.
- **Sensitive or restricted:** Confirm permitted handling before reading, copying, summarizing, or exposing content in generated docs.

A threshold around 200 KB can trigger caution, but do not treat it as universal. Compressed formats, generated JSON, binary files, and the runtime's remaining context can require a lower threshold.

## Protocol

1. Report the file name, approximate size, format, and why it may be relevant.
2. For large or sensitive files, ask before loading or distilling them.
3. If approved, search for the specific paths, schemas, sections, or terms needed by the documentation.
4. Distill only the relevant material into a readable document.
5. Add a mapping to related documents or approved work units when it improves navigation.
6. Do not copy the raw reference into the repository by default.
7. Copy it only when the user approves and confidentiality, licensing, repository policy, and version-control impact allow it. Otherwise link to its approved existing location.

## Distilled Document

Include only applicable sections:

1. A scope note explaining what was distilled and what remains in the full reference
2. The approved location and access warning for the full reference
3. Relevant connection, authentication, or format details
4. Relevant endpoints, schemas, tables, or definitions
5. A mapping table when relationships to other docs or work units matter

Example mapping:

```markdown
| Related document or work unit | Reference item | Purpose |
|---|---|---|
| [Import guide] | `GET /v1/items` | Retrieve records for the documented import flow |
```

## INDEX.md Warning

When a large or restricted reference is retained or linked, add a concise warning to the relevant optional INDEX section:

```markdown
- [Distilled Reference](api/external-api.md) — Relevant material; read this first
- Full reference — Stored at the approved location. Check size and access restrictions before loading.
```

Do not create a raw-spec INDEX entry when no raw reference was copied or linked.
