# Feature Spec Format

How to describe **one** feature flow so the skill can drive the Playwright CLI without ambiguity. One invocation = one feature = one GIF.

Two equivalent formats are accepted: a markdown block with key/value lines, or a small YAML/JSON object.

## Markdown variant

```markdown
# App URL
http://localhost:5173

# Feature: Add a todo
slug: add-todo
viewport: 1280x800
steps:
  - goto /
  - click  role=button[name="New todo"]
  - type   role=textbox[name="Title"] "Buy milk"
  - press  Enter
  - expect text "Buy milk" visible
notes: First-load empty state should be captured as frame 000.
```

## YAML variant

```yaml
url: http://localhost:5173
slug: add-todo
viewport: { w: 1280, h: 800 }
steps:
  - { action: goto,   path: / }
  - { action: click,  selector: 'role=button[name="New todo"]' }
  - { action: type,   selector: 'role=textbox[name="Title"]', text: "Buy milk" }
  - { action: press,  key: Enter }
  - { action: expect, kind: text, value: "Buy milk", state: visible }
```

If the user points the skill at a file containing multiple feature blocks, the skill must ask which one to record — it does not loop.

## Step verbs

| Verb     | Meaning                                                                  |
|----------|--------------------------------------------------------------------------|
| `goto`   | Navigate to a path (relative to base URL) or absolute URL.              |
| `click`  | Click a Playwright accessibility-tree selector (preferred over CSS).    |
| `type`   | Focus an input + type text.                                              |
| `press`  | Press a key (`Enter`, `Escape`, `Tab`, `ArrowDown`).                    |
| `hover`  | Hover an element; useful for menu reveals.                              |
| `scroll` | Scroll a container or the page (`scroll: down 400`).                    |
| `wait`   | Sleep N milliseconds. Use sparingly — prefer `expect`.                  |
| `expect` | Wait for a condition (text visible, role present, URL matches).         |

## Slug rules

- Lowercase kebab-case, no spaces.
- Becomes the folder name and the GIF filename.

## Selector preference

Use Playwright accessibility locators (`page.getByRole`, `page.getByText`, `page.getByLabel`) over CSS. They survive markup churn.
