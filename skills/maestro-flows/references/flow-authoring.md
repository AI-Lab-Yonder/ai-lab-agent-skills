# Flow Authoring

Non-obvious rules for writing Maestro flows that pass reliably. Assumes basic Maestro YAML knowledge.

## File layout

- One scenario per file, named after the behavior: `login-happy-path.yaml`, `login-empty-fields.yaml`.
- Group related scenarios in a subfolder of the flows dir (e.g. `.maestro/login/`) so a whole suite can run with one command.
- Every flow starts with the `appId:` header matching `.maestro-flows.local.json`.
- Tag every flow (`tags:` list in the header, e.g. feature name + `smoke`) so subsets run via `--include-tags` — see `running-flows.md`.

## Selectors — priority order

1. Element ID (for example: `id: "btn_login"`) — stable across copy changes and locales.
2. Tolerant text regex anchored on the stable part — only when no ID exists.
3. Never index-based selection unless the structure is guaranteed.

Verify IDs against app source (`AutomationId`/`testID`/`resource-id`) or a live hierarchy (`maestro studio`, `maestro hierarchy`) before using them. Do not invent them.

## Input fields

Always `eraseText` before `inputText` — debug builds persist field state between launches. This applies even to tests that *depend* on empty fields: clear them explicitly instead of assuming a clean launch.

For a truly clean session use:

```yaml
- launchApp:
    clearState: true
```

but be aware this wipes login sessions, databases, and onboarding state — often you want the persisted state.

## Taps and visibility

- Keyboard covering the target? Prefer `scrollUntilVisible` to bring it into view. Avoid `hideKeyboard` — on Android it can be implemented as a Back press, which exits the app instead of dismissing the keyboard.
- `scrollUntilVisible` before tapping elements that may be below the fold on small screens.
- After actions that trigger navigation or network calls, assert on an element of the *destination* screen rather than adding fixed waits.

## Assertions

- Assert outcomes, not implementation: after login assert an element unique to the home screen, not the absence of the login button.
- Text assertions: tolerant regex on the stable substring — exact strings break on every copy/version change.
- Negative tests (e.g. "login rejected") must assert the error indicator, not just "still on the same screen".

## Template

Start new flows from `templates/flow.yaml.tmpl`.
