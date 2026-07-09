---
name: maestro-flows
description: Create and run Maestro UI test flows for the app in this repo. Use when writing Maestro YAML flows or verifying app behavior on a device/emulator.
version: 1.4.0
level: advanced
category: testing
---

# Maestro Flows

Create and run Maestro UI test flows for the application in the current repository. Discovers the project setup itself, keeps raw output in a project results folder, and returns only a compact result in chat.

## Constraints

- Never guess credentials or test data. Use what exists in checked-in flows, pass via `-e` env vars, or ask the user.
- Never paste full build output, console streams, `dumpsys window`, or Maestro artifacts into the conversation. Redirect raw output to the results folder and parse the JUnit report instead.
- Before claiming success, run the relevant flows — or state explicitly why they were not run.
- Do not invent element IDs or selectors. Verify them against the app source or a hierarchy dump.
- Do not guess feature behavior. Read the feature's source (markup + handlers) before authoring a flow and before every flow fix — flows test what the code does, not what the UI probably does.
- For verification runs, use a full (non-incremental) install — fast-deploy mechanisms can leave stale code on the device.
- This skill NEVER changes application code. It creates/edits flow YAML, runs flows, and reports. Fixing app code is a separate task that starts only after the user picks what to fix (Phase 4).
- Wherever this skill says "ask the user": stop, surface the question and its options directly to the user in chat, and wait for the answer before proceeding. If the harness provides a structured question tool (e.g. AskUserQuestion in Claude Code), use it; otherwise plain chat is fine. Never proceed on an assumed answer.

## Phase 0 — Load Context & Configure

Read `gotchas.md` first — it logs this skill's own past malfunctions.

Config lives at `<repo root>/.maestro-flows.local.json` — machine-local state, never inside this skill folder (the skill ships without it) and never committed.

If it exists: read it, validate the cached tool paths still exist (`adb`, `maestro`) and the device is connected (run `devices` via the configured `adb` path — do not assume `adb` is on PATH, or `xcrun simctl list devices booted`); re-discover any value that fails validation and write the file back. No device connected → first try to start one yourself (emulator/simulator start steps are in `references/project-discovery.md` step 4); ask the user only if that fails. If the config doesn't exist: follow `references/project-discovery.md` to discover everything and create it; ask the user only for ambiguous values.

## Phase 1 — Create Flows (when authoring)

Read `references/flow-authoring.md` before writing any YAML. Start new flows from `templates/flow.yaml.tmpl`.

## Phase 2 — Run Flows

Read `references/running-flows.md` for the run conventions (results folder layout, JUnit report parsing, tag filtering).

Pick the cheapest valid run:

- App code changed → run `installCommand` first.
- Only flow YAML changed and app already installed → skip install.
- Targeted check → filter with `--include-tags` instead of running the whole suite.
- User only wants the commands → print them, run nothing.

## Phase 3 — Report

Report immediately after the run — do NOT investigate failures first (no log reading, no screenshot inspection, no troubleshooting). Print in chat only:

- command(s) used, whether install was skipped and why;
- pass/fail count and total duration (from the JUnit report);
- for failures: the failure message as stated in the JUnit report (verbatim, no interpretation) and the screenshot path under `artifacts/`;
- the run folder path (`<resultsDir>/run-<timestamp>/`) for later verification.

## Phase 4 — Diagnose & Fix Planning (only if flows failed, only on request)

After the report, ask the user which failing tests to diagnose and plan fixes for. Only for the selected ones: read `references/troubleshooting.md` (most failure modes — startup crash despite green build, system overlays, stale field state, stale installs — are catalogued with exact diagnostic commands), diagnose the root cause, then lay out a plan: root cause, files involved, proposed change, how the fix will be verified (which flows to rerun). Present the plan only — do not modify application code within this skill.
