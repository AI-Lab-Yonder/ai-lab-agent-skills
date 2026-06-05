# Recording Strategy

When to snap a frame, how many, how fast.

## Default cadence: state-change driven

Snap once after **every user-visible change**:

- After `goto` once the page is loaded.
- After every `click` / `press` / `type` once the next state is visible (use `browser_wait_for` on the new text/role rather than a fixed sleep).
- After every `expect` that succeeds.

This usually produces 5–15 frames per feature — small GIFs, sharp transitions.

## Animation-heavy flows: timed sampling

If the feature includes a CSS transition, drag, or canvas animation that's the whole point of the demo, switch to timed sampling for that segment:

- Trigger the animation.
- Snap every 100–250 ms for the animation duration.
- Resume state-change cadence after.

Mark this in the spec with a `cadence: timed 200ms for 2000ms` directive on the step that triggers it.

## Hover & focus

Browsers don't show hover/focus states in screenshots taken during navigation. To capture them: `browser_hover` (or `browser_focus`) → `browser_wait_for time=200ms` → snap frame.

## Don't capture noise

Skip frames during:
- Page initial paint (snap once `load` fires, not before).
- Font swap flashes — wait `document.fonts.ready` if a custom font is in use.
- Toast notifications you don't want in the demo — close them before snapping the next state.

## Consistent pixel ratio

Always set `browser_resize` before navigation. Resizing mid-flow re-layouts and breaks the sequence. If both desktop and mobile flows are needed, run two separate features with different slugs.

## Keep the flow under ~10 seconds of GIF

A 4 fps GIF with 30 frames is ~7.5 seconds — readers' attention span. If a flow needs more, split it into sub-features (`checkout-step-1`, `checkout-step-2`).
