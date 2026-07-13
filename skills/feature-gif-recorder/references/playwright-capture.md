# Playwright Capture Reference

Use the Playwright Node API from an existing project dependency. Do not use commands that can download a package merely to test whether Playwright is installed.

## Dependency Detection

Check Node.js first, then resolve either `@playwright/test` or `playwright` from the project. A generated capture script can use this import fallback:

```js
let chromium;
let playwrightVersion = 'unknown';

try {
  const module = await import('@playwright/test');
  chromium = module.chromium;
  playwrightVersion = module._version ?? 'installed @playwright/test';
} catch {
  const module = await import('playwright');
  chromium = module.chromium;
  playwrightVersion = module._version ?? 'installed playwright';
}
```

If neither package resolves, or if Chromium is missing, detect the project's package manager from its lockfile or ask the user. Show the exact applicable commands and explain that they download a package and/or browser binary before asking whether the agent should run them.

## Installation Decision

Use the project's existing package manager. Do not silently substitute another one.

| Package manager | Install Playwright package | Install Chromium browser |
|---|---|---|
| npm | `npm install --save-dev @playwright/test` | `npx playwright install chromium` |
| pnpm | `pnpm add --save-dev @playwright/test` | `pnpm exec playwright install chromium` |
| Yarn | `yarn add --dev @playwright/test` | `yarn playwright install chromium` |
| Bun | `bun add --dev @playwright/test` | `bunx playwright install chromium` |

Before running anything, surface:

1. Which component is missing: Node.js, the Playwright package, Chromium, or more than one.
2. Which package manager was detected and why.
3. The exact command or commands needed.
4. That the package command changes dependency metadata and the browser command performs a network download and uses local disk space.
5. The choice: let the agent run the approved commands, let the user run them, or stop the recording.

If the package exists and only Chromium is missing, show only the browser-install command. After installation, rerun dependency detection before generating the capture script.

## Capture Script Shape

Write `<run-dir>/capture.mjs` and execute it with `node`:

```js
import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

let chromium;
try {
  ({ chromium } = await import('@playwright/test'));
} catch {
  ({ chromium } = await import('playwright'));
}

const runDir = fileURLToPath(new URL('.', import.meta.url));
const framesDir = join(runDir, 'frames');
await mkdir(framesDir, { recursive: true });

const storageStatePath = process.env.FEATURE_GIF_STORAGE_STATE;
const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({
  viewport: { width: 1280, height: 800 },
  ...(storageStatePath ? { storageState: storageStatePath } : {}),
});
const page = await context.newPage();

const mask = [page.getByTestId('private-value')];
const framePath = (number) => join(framesDir, `${String(number).padStart(3, '0')}.png`);

try {
  await page.goto('http://localhost:5173/');
  await page.waitForLoadState('load');
  await page.screenshot({ path: framePath(0), mask });

  await page.getByRole('button', { name: 'Create item' }).click();
  await page.getByText('Item created').waitFor({ state: 'visible' });
  await page.screenshot({ path: framePath(1), mask });
} finally {
  await browser.close();
}
```

The complete generated script must also catch failures and write sanitized `meta.json`. Store only the URL origin and pathname; omit query parameters and fragments.

## Selector Preference

Prefer accessibility locators over CSS:

| Locator | Use for |
|---|---|
| `page.getByRole('button', { name })` | Buttons, links, and switches |
| `page.getByLabel(text)` | Form inputs |
| `page.getByText(text)` | Visible text |
| `page.getByTestId(id)` | Stable application-provided test IDs |
| `page.locator(css)` | Last-resort CSS or explicit masking |

## Authentication

- Prefer a dedicated test account with synthetic data.
- Pass a local storage-state path through an environment variable.
- Never copy the storage-state JSON into the feature spec, capture script, metadata, or chat.
- Do not record login form values unless the user explicitly needs a login demonstration and all values are synthetic and masked.

## Screenshot Masking

Build the mask list from approved Playwright locators and pass it to every `page.screenshot` call. Typical masks include account identifiers, avatars, email addresses, tokens, internal hostnames, and variable data unrelated to the feature.

Masking is not a substitute for the Phase 4 privacy review.

## Waiting

Prefer observable state:

```js
await locator.waitFor({ state: 'visible' });
await page.waitForURL(expectedUrl);
await page.waitForLoadState('networkidle');
```

Use `page.waitForTimeout` only for a deliberate timed-animation segment.

## Frame Numbering

Use contiguous zero-padded names beginning at `000.png`. The converter rejects missing numbers because ffmpeg's `%03d.png` sequence stops at a gap.

## Headless Rendering

Headless mode is the default for repeatability within the same environment. Output can still vary across operating systems, browser builds, fonts, GPU settings, and device scale factors. Record available environment versions in metadata and avoid claiming pixel identity across machines.

## Recovery

If a step fails:

1. Catch the error and attempt one final masked screenshot.
2. Write sanitized metadata with status `partial` or `failed`.
3. Close the browser in `finally`.
4. Exit nonzero.
5. Stop this one-feature invocation and preserve the artifacts for diagnosis.
