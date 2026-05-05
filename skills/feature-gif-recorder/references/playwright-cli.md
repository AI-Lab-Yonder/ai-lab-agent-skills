# Playwright CLI Reference

Notes on using the Playwright CLI (`npx playwright`) and the Node API to capture frames for GIF assembly. Full docs: <https://playwright.dev/>.

## Install

```bash
npm i -D @playwright/test
npx playwright install chromium
# verify
npx playwright --version
```

If the user is on a fresh machine, the first browser launch will trigger a Chromium download — `npx playwright install chromium` makes that explicit and one-time.

## Capture script shape

For each feature, write `recordings/<slug>/capture.mjs` and run it with `node`:

```js
import { chromium } from '@playwright/test';
import { mkdir } from 'node:fs/promises';

const out = (n) => `recordings/<slug>/frames/${String(n).padStart(3, '0')}.png`;

await mkdir('recordings/<slug>/frames', { recursive: true });

const browser = await chromium.launch({ headless: true });
const ctx = await browser.newContext({ viewport: { width: 1280, height: 800 } });
const page = await ctx.newPage();

await page.goto('http://localhost:5173/');
await page.screenshot({ path: out(0) });

await page.getByRole('button', { name: 'New todo' }).click();
await page.screenshot({ path: out(1) });

// ...one screenshot after each user-visible state change

await browser.close();
```

Use `node` (not `playwright test`) — these are scripted captures, not assertions.

## Selector preference

Prefer accessibility locators over CSS — they survive class-name churn:

| Locator                           | Use for                              |
|-----------------------------------|--------------------------------------|
| `page.getByRole('button', {name})` | Buttons, links, switches             |
| `page.getByLabel(text)`           | Form inputs                          |
| `page.getByText(text)`            | Visible text                         |
| `page.getByTestId(id)`            | App-supplied test ids                |
| `page.locator(css)`               | Last-resort CSS                      |

## Frame numbering

Snap PNGs as zero-padded 3-digit names: `000.png`, `001.png`, … This keeps `ls` and ffmpeg's pattern matcher in lockstep:

```
ffmpeg -framerate 4 -i recordings/<slug>/frames/%03d.png ...
```

If a flow exceeds 999 frames the cadence is wrong — increase the screenshot interval, do not jump to 4-digit padding.

## Headless vs headed

Headless is the default and gives identical pixel output across machines, which is what you want for GIFs. Only switch to `headless: false` if the app refuses to render in headless (e.g. WebGL with `webgl: 'fail'`).

## Waiting strategies

Prefer `await locator.waitFor({ state: 'visible' })` or `await page.waitForLoadState('networkidle')` over `await page.waitForTimeout(N)`. Fixed sleeps make GIFs dance to your latency, not the app's.

## Recovery

If a step throws mid-flow:
1. Catch the error in the capture script.
2. Snap one final frame (`page.screenshot`).
3. `await browser.close()`.
4. Exit with code 1 so the parent skill marks this feature `partial`.
5. Continue with the next feature. Do not retry forever.
