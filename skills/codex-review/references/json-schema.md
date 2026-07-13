# Output Contract

The Codex review produces a JSON report with the fields below. See `templates/output-schema.json` for the raw report template.

## Field Reference

### `summary`

| Field | Type | Description |
|-------|------|-------------|
| `scope` | string | What was reviewed (e.g., "Uncommitted changes in src/") |
| `files_reviewed` | number | Count of files analyzed |
| `high_severity_count` | number | Findings with severity "high" |
| `medium_severity_count` | number | Findings with severity "medium" |
| `low_severity_count` | number | Findings with severity "low" |

### `findings[]`

| Field | Type | Valid Values |
|-------|------|-------------|
| `id` | string | Sequential: REV-001, REV-002, ... |
| `severity` | string | `high`, `medium`, `low` |
| `category` | string | `bug`, `regression`, `performance`, `security`, `test-gap`, `completeness-gap` |
| `title` | string | Short issue title |
| `impact` | string | User-visible or system impact |
| `evidence[]` | array | At least one entry per finding |
| `evidence[].file` | string | Exact file path |
| `evidence[].start_line` | number | Starting line number |
| `evidence[].end_line` | number | Ending line number |
| `evidence[].snippet` | string | Short code snippet |
| `why_it_happens` | string | Root cause explanation |
| `fix_recommendation` | string | Actionable fix suggestion |
| `confidence` | number | 0.0 to 1.0 |

### `checks_run[]`

| Field | Type | Valid Values |
|-------|------|-------------|
| `name` | string | `typecheck`, `test`, `lint`, `other` |
| `status` | string | `passed`, `failed`, `not_run` |
| `details` | string | What was run or why it wasn't |

### `out_of_scope`

Array of strings describing areas explicitly excluded from the review.

### `overall_confidence`

Number 0.0-1.0 representing aggregate confidence across all findings.

## Validation Rules

- Every finding MUST include all fields — no optional fields
- Every evidence item MUST include file, start_line, end_line, snippet
- Finding IDs must be unique and sequential: `REV-001`, `REV-002`, ...
- `start_line` must be at least 1 and `end_line` must be greater than or equal to `start_line`
- Severity counts must exactly match the corresponding values in `findings[]`
- `confidence` and `overall_confidence` must be between 0.0 and 1.0 inclusive
- Evidence paths must belong to the reviewed scope
- Credential or secret values in snippets must be redacted
- Every skipped file or excluded area must appear in `out_of_scope` with a reason
- Use empty arrays `[]` for no items (never null)
- All numeric fields must be numbers (not strings)
- If no issues found: `findings=[]`, all severity counts zeroed
- Output must be valid JSON (no trailing commas, no comments)
