---
name: feature-gif-recorder
description: Record one web application feature flow as a compact GIF using an existing Playwright installation. Use when the user asks for a visual demo, changelog artifact, documentation asset, or pull-request evidence. Creates local capture artifacts first; installation, publication, commits, uploads, and pull-request edits always require separate approval.
version: 2.1.0
level: advanced
category: testing
---

# Feature GIF Recorder

Drive one named feature flow in a running web application, capture user-visible states, convert the frames into a labeled GIF, and optionally prepare host-specific publishing instructions.

## Constraints

- One invocation records one feature and produces one GIF
- The application must already be running at a user-approved URL; do not start servers
- Prefer a non-production environment with synthetic or approved test data
- Never install packages, download browsers, commit, push, upload, or modify a pull request without explicit approval for that separate action
- Never place credentials, tokens, session values, or production data in the spec, generated script, metadata, frames, or chat
- Supply authentication through approved environment variables or a local Playwright storage-state path
- Mask sensitive UI regions during capture and inspect the frames before any publication step
- Use one resolved run directory throughout capture, conversion, metadata, and summary
- Default output is `recordings/<feature-slug>/`; if it already exists, use a timestamped sibling unless the user chooses another location
- Read `gotchas.md` before starting

## Optional PR Suggestion

When the user explicitly wants visual pull-request evidence, offer this skill once. Declining or skipping a GIF must never block or delay pull-request creation. Do not hook into a named command or assume a particular agent platform or git host.

## Phase 0 — Detect and Confirm

1. Identify the single feature, application URL, entry path, steps, and desired output location.
2. Confirm the environment and data are safe to capture. If the URL appears to be production or the flow can display real user data, stop and ask for a safe alternative.
3. Confirm Node.js is available.
4. Detect an already-installed `@playwright/test` or `playwright` package without using a command that can download packages.
5. Confirm an installed Playwright browser can launch. If the package or browser is missing, read the installation-decision section in `references/playwright-capture.md`, show the exact package-manager-specific commands and their side effects, and ask whether the agent should run them. Do not proceed without the user's decision.
6. Confirm `ffmpeg` or ImageMagick's `magick` command is available. The converter prefers ffmpeg.
7. Read `references/feature-spec.md` and normalize the flow into one spec.

If the user provides a file containing several features, ask which single feature to record.

## Phase 1 — Plan the Recording

For the selected feature:

- Resolve a kebab-case slug and one exact run directory
- Choose a viewport; default to `1280x800`
- Choose state-change capture by default and timed sampling only for animation-heavy segments
- Identify how authentication is supplied without exposing secrets
- Identify selectors that must be masked in every screenshot
- Estimate the step count, frame count, duration, and final output size

Read `references/recording-strategy.md`, present the plan, and wait for confirmation before driving the browser unless the user has already explicitly authorized the exact plan.

## Phase 2 — Capture with Playwright

Generate `<run-dir>/capture.mjs` that:

1. Imports `chromium` from the installed `@playwright/test` package, falling back to `playwright`.
2. Creates `<run-dir>/frames/`.
3. Uses the chosen viewport before navigation.
4. Optionally loads storage state from a named environment variable containing a local path. It must not embed storage-state content.
5. Navigates to the entry URL without storing query parameters, fragments, headers, cookies, or tokens in metadata.
6. Uses Playwright accessibility locators and explicit state waits.
7. Passes the approved locator list to Playwright's screenshot `mask` option.
8. Captures `000.png` after the initial stable state and one numbered frame after each planned visible state change.
9. Wraps execution in `try/catch/finally`, closes the browser, and writes sanitized `meta.json` on both success and failure.

The metadata should contain only: feature name, slug, sanitized origin and path, viewport, planned step descriptions without secrets, frame count, start/end timestamps, duration, Playwright/browser versions when available, and status (`ok`, `partial`, or `failed`).

Run only:

```text
node <run-dir>/capture.mjs
```

Do not prepend an installation command. On a step failure, preserve the existing frames and metadata, mark the run `partial`, and stop this invocation.

Read `references/playwright-capture.md` for the capture-script pattern, selectors, authentication, masking, waiting, and recovery guidance.

## Phase 3 — Convert Frames

Resolve this skill's own directory, then run its cross-platform Node helper with the exact run directory:

```text
node <skill-dir>/scripts/frames-to-gif.mjs <run-dir> [fps] [width]
```

Defaults are 4 fps and 720 pixels wide. The helper validates arguments and frame continuity, prefers ffmpeg, and falls back to ImageMagick.

Read `references/gif-conversion.md` for size and quality guidance.

Expected output:

```text
<run-dir>/
├── capture.mjs
├── frames/
│   ├── 000.png
│   └── NNN.png
├── <run-directory-name>.gif
└── meta.json
```

## Phase 4 — Privacy Review

Before suggesting publication:

1. Inspect every captured frame, the final GIF, and sanitized metadata.
2. Check for personal data, internal hostnames, access tokens, account identifiers, confidential content, and unintended notifications or background tabs.
3. If anything sensitive appears, do not publish. Re-record with synthetic data or additional masks.
4. Tell the user that the local artifact is ready and ask whether they want publishing instructions or an authorized publication action.

## Phase 5 — Optional Publishing

Local artifact creation is the default completion point. Publishing is a separate, opt-in phase.

### Repository-hosted asset

If the user wants the GIF stored in the repository:

1. Explain repository-size implications and confirm the final GIF is the only artifact intended for version control.
2. Ask before staging or committing. Never commit frames, capture scripts, metadata, or `.gitattributes` changes unless explicitly requested.
3. After the GIF is committed, use the exact commit SHA and detected remote host to prepare an embed URL supported by that host.

For a GitHub remote, a SHA-pinned example is:

```html
<img src="https://github.com/<owner>/<repo>/blob/<sha>/<path-to-gif>?raw=true" alt="<feature-name> demo" width="720" />
```

Do not require the `gh` CLI merely to determine the remote; inspect the configured git remote. Do not modify the pull-request body without explicit approval.

### Host attachment

If the user prefers a web-hosted attachment, follow the host's authenticated upload flow only with approval. Warn that attachment URLs can have access controls different from the repository and may be accessible to anyone who receives the URL. Never claim an attachment is private or universally rendered without verifying the host's behavior.

For unsupported or unknown hosts, provide the local artifact path and let the user choose the publication method instead of guessing.

## Phase 6 — Summary

Report:

- Feature name and slug
- Exact run directory and GIF path
- Frames captured and GIF byte size
- Status: `ok`, `partial`, or `failed`
- Privacy-review result
- Playwright and conversion engine used
- Whether the artifact remains local, was committed, or was uploaded
- Embed snippet only when a valid published location exists

If the user also needs pass/fail assertions, pair the recording with the project's existing end-to-end testing workflow rather than assuming a named skill is installed.
