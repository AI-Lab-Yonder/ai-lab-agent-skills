# Recording Strategy

Choose frames that explain the feature without capturing noise or sensitive information.

## Default Cadence: State Changes

Capture once after each planned user-visible state:

- After navigation reaches a stable initial state
- After an action and the resulting locator, URL, or load state confirms the next state
- After a deliberate hover, focus, drag, or scroll state that matters to the demonstration
- After the final completion condition

Use Playwright Node APIs such as `locator.waitFor`, `page.waitForURL`, `locator.hover`, `locator.focus`, and `page.setViewportSize`. Do not reference browser-control tools from another runtime.

## Animation-Heavy Segments

For a transition, drag, canvas animation, or other motion that is itself the feature:

1. Trigger the animation.
2. Capture at a confirmed interval, usually 100-250 ms, for a bounded duration.
3. Resume state-change capture afterward.

Record the interval and duration in the spec. Keep the whole GIF near ten seconds unless the user requests otherwise.

## Hover and Focus

Use `await locator.hover()` or `await locator.focus()`, wait for the observable visual state, then capture. A short fixed delay is acceptable only when the state has no better observable signal.

## Stable Initial State

- Wait for the relevant content, not just initial paint.
- Wait for `document.fonts.ready` when font swapping affects the capture.
- Close unrelated notifications before the first frame.
- Set viewport and device scale factor before navigation; do not resize mid-flow.

## Privacy by Construction

- Use synthetic test records.
- Define masking locators before capture and apply them to every frame.
- Avoid browser chrome, unrelated tabs, notification centers, and developer tools.
- Do not include URL query strings or fragments in metadata.
- Re-record rather than editing around accidentally captured sensitive data.

## Frame Budget

State-driven flows usually need 5-15 frames. If a flow approaches hundreds of frames, reduce timed sampling or narrow the feature. Desktop and mobile demonstrations should be separate invocations with separate run directories.
