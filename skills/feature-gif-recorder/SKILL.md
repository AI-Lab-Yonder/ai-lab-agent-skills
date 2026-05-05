---
name: feature-gif-recorder
description: Record a GIF of one specific webapp feature flow with the Playwright CLI, ready to embed in a PR description. Use when shipping/testing a feature that needs a visual demo, changelog GIF, or PR evidence. Auto-trigger before `gh pr create` / `/commit-push-pr` to ask whether to record a demo GIF for the PR body.
version: 2.0.0
---

# Feature GIF Recorder

Drive a running webapp through **one** named feature flow with the Playwright CLI (`npx playwright`), capture frames, stitch into a single labeled GIF, and emit a ready-to-paste PR-embed snippet. Single feature per invocation — no gallery sweep.

## Constraints

- Requires the Playwright CLI on PATH (`npx playwright --version`). If missing, instruct: `npm i -D @playwright/test && npx playwright install chromium`. Do not depend on the Playwright MCP server — talk to the CLI directly.
- Requires `ffmpeg` on PATH (preferred) **or** `magick` (ImageMagick). Refuse to record if neither is available — say so and stop.
- One invocation = one feature = one GIF. Do not enumerate `docs/flows.md` and do not record multiple flows in a single run.
- App must already be running and reachable at a URL the user supplies. Do not start servers.
- Output goes to `recordings/<feature-slug>/` at the project root unless the user overrides. Non-destructive: append a timestamp suffix if the slug folder already has frames.
- Never embed PII or production credentials in flows. If the spec hits an auth screen, ask for test creds — do not hard-code.

## Phase 0a — PR Trigger

When the user is about to create a PR (running `/commit-push-pr`, `gh pr create`, or asking to "open a PR" / "make a PR"), the assistant MUST first ask:

> "Record a demo GIF of the new feature for the PR description?"

- If yes → run this skill on the named feature, then embed the Phase 4 `<img>` snippet in the PR body before calling `gh pr create`.
- If no → proceed without a GIF.

Do not skip the question. The user's answer may differ per PR.

## Phase 0 — Detect & Confirm

1. Confirm the Playwright CLI is available: `npx playwright --version`. If not, tell the user to run `npm i -D @playwright/test && npx playwright install chromium`.
2. Confirm `ffmpeg` (or `magick`) is on PATH.
3. Identify the **single** target feature. In order of preference:
   - User-named feature (slug, name, or "the X feature I just built") → use it.
   - User-provided spec file path → read it; if multiple features, **ask which one** (do not loop over all).
   - Otherwise: ask the user for app URL + the one feature (name, entry path, steps).
4. Read `references/feature-spec.md` for the spec schema this skill expects.

## Phase 1 — Plan the Recording

For the chosen feature:
- Resolve a kebab-case slug (`add-todo`, `dark-mode-toggle`).
- Decide viewport (default `1280x800`, override per-spec).
- Decide frame cadence: capture **before each user-visible state change** plus a final frame. Timed sampling (e.g. every 250 ms) is allowed when the flow is animation-heavy — note this in the spec.
- Read `references/recording-strategy.md` for when to snapshot vs. when to wait.

Print the plan (feature → step count → expected frame count) and ask the user to confirm before driving the browser. Skip confirmation only if the user passed `--yes` / explicitly authorized.

## Phase 2 — Drive Playwright CLI

1. Generate a Playwright capture script at `recordings/<slug>/capture.mjs` that:
   - Imports `chromium` from `@playwright/test` (or `playwright`).
   - Sets the viewport to the spec's chosen size.
   - Navigates to the entry URL.
   - Takes screenshot `frames/000.png` after `load`.
   - Walks the spec's steps using accessibility selectors (`page.getByRole`, `page.getByLabel`, `page.getByText`), screenshotting `frames/NNN.png` after each user-visible state change.
2. Run it: `npx playwright install chromium >/dev/null 2>&1 && node recordings/<slug>/capture.mjs`. Use `node`, not `playwright test`, since these are scripted captures, not assertions.
3. Read `references/playwright-cli.md` for selector patterns, waiting strategies, and headless defaults.
4. On a step error, save what frames exist, mark the run `partial`, and stop. Do not retry forever.

## Phase 3 — Stitch GIF

Run `scripts/frames-to-gif.sh <slug>`. The script handles palette generation and lanczos scaling for sharp output. Read `references/gif-conversion.md` for size/quality knobs (fps, width, dithering) and the ImageMagick fallback.

Output:
```
recordings/<slug>/
├── frames/000.png … NNN.png
├── <slug>.gif
└── meta.json     # url, viewport, steps, timestamps, duration
```

## Phase 4 — PR Embed Snippet

After the GIF exists, the user must commit it on the branch they will PR from, then the skill prints a ready-to-paste HTML `<img>` snippet for the PR body.

**Rule (private repos):** anonymous `https://raw.githubusercontent.com/...` URLs 404 in PR/issue descriptions because they require a signed token query string the viewer does not have. Use a SHA-pinned `github.com/.../blob/<sha>/<path>?raw=true` URL inside an HTML `<img>` tag. Markdown `![alt](url)` is also unreliable for private repos — HTML `<img>` goes through GitHub's authenticated session proxy.

**Build the snippet:**

1. Stage and commit the GIF on the feature branch: `git add recordings/<slug>/<slug>.gif && git commit -m "docs: add <slug> demo gif"`.
2. Get the commit SHA: `git rev-parse HEAD`.
3. Determine `<owner>/<repo>` from the remote: `gh repo view --json nameWithOwner -q .nameWithOwner`.
4. Print:

```html
<img src="https://github.com/<owner>/<repo>/blob/<sha>/recordings/<slug>/<slug>.gif?raw=true" alt="<feature-name> demo" width="720" />
```

Use the SHA, **not** the branch name — branch names containing `/` (e.g. `feat/dark-mode`) get misparsed by GitHub's image proxy.

**Last-resort fallback:** if the HTML-tag form still does not render, drag-drop the GIF into the PR description in the GitHub web UI. That creates a `https://github.com/user-attachments/assets/<uuid>` URL that is publicly CDN-cached and always renders. There is no `gh` CLI / API path to do this upload programmatically.

## Phase 5 — Summary

Print: feature name, slug, frames captured, GIF path, GIF byte size, status (ok / partial / failed), and the embed snippet from Phase 4. Suggest next step: paste the snippet into the PR body. Warn that GIFs can bloat the repo — `.gitattributes` LFS pattern is in `references/gif-conversion.md`.

## Composition

- Pair with `e2e-runner` / `e2e` skill if the user wants pass/fail assertions on top of visual evidence: this skill makes the artifact, that one makes the verdict.
