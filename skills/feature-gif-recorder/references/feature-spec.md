# Feature Spec Format

Describe one feature flow without embedding credentials or private session data. Markdown, YAML, and JSON are acceptable when they contain the same information.

## Fields

| Field | Required | Meaning |
|---|---|---|
| `url` | yes | Approved application URL; credentials must not appear in it |
| `slug` | yes | Lowercase kebab-case output name |
| `viewport` | no | Width and height; default `1280x800` |
| `steps` | yes | Ordered actions and observable waits for one feature |
| `storage-state-env` | no | Environment-variable name containing a local storage-state path |
| `mask` | no | Playwright locators to hide in every screenshot |
| `cadence` | no | Timed sampling for a bounded animation segment |
| `notes` | no | Non-sensitive capture guidance |

## Example

```yaml
url: http://localhost:5173
slug: create-item
viewport: { width: 1280, height: 800 }
storage-state-env: FEATURE_GIF_STORAGE_STATE
mask:
  - 'testid=account-identifier'
steps:
  - { action: goto, path: /items }
  - { action: click, selector: 'role=button[name="Create item"]' }
  - { action: type, selector: 'role=textbox[name="Name"]', text: "Example item" }
  - { action: press, key: Enter }
  - { action: expect, kind: text, value: "Item created", state: visible }
```

If a file contains several feature blocks, ask which single feature to record.

## Step Verbs

| Verb | Meaning |
|---|---|
| `goto` | Navigate to a relative path or approved absolute URL |
| `click` | Click a Playwright locator |
| `type` | Focus an input and type synthetic text |
| `press` | Press a key |
| `hover` | Hover an element |
| `focus` | Focus an element |
| `scroll` | Scroll the page or a container |
| `drag` | Perform a bounded drag interaction |
| `wait` | Wait a fixed duration only when no observable state exists |
| `expect` | Wait for text, role, URL, or another observable condition |

## Authentication Rules

- The field names the environment variable; it never contains the storage-state path or content itself.
- Generated scripts read the variable at runtime.
- Raw usernames, passwords, tokens, cookies, and headers are forbidden in the spec.

## Mask Rules

Use the same locator concepts as the flow. Convert each mask entry into a Playwright locator and pass all masks to every screenshot call. If a sensitive region cannot be selected reliably, use safer test data or do not record the flow.

## Slug Rules

- Lowercase kebab-case
- No path separators or traversal segments
- Used as the default run-directory and GIF base name
