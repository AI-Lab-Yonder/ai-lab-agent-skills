# Troubleshooting Maestro Failures

Known app/device failure modes and how to diagnose them. Read only after the user selects failures to diagnose (SKILL.md Phase 4).

Diagnostic commands below are Android (`adb`); on iOS use the equivalents (`xcrun simctl spawn booted log stream`, simulator screenshots).

## Installation Staleness

- **Symptom**: Flows fail against behavior that was already fixed; incremental install reported success.
- **Why**: Fast-deployment mechanisms (e.g. MAUI Android Fast Deployment) can skip effective replacement of changed code.
- **Fix**: Rerun the configured `installCommand` (full non-incremental install — see SKILL.md constraint) and retest.

## App Crash Despite Green Build

- **Symptom**: All flows fail with "element not found" on the very first screen; build/install succeeded.
- **Why**: App can crash during startup (e.g. XAML/layout parse error) — the build does not validate runtime resource loading.
- **Fix**: Before debugging selectors: `adb logcat -d -s AndroidRuntime` (add runtime tags like `MonoDroid DOTNET` for MAUI), look for `FATAL EXCEPTION`.

## Stale Input Field State

- **Symptom**: Maestro appends text to pre-filled fields, or an "empty fields" test accidentally succeeds.
- **Why**: Debug builds persist form state between launches.
- **Fix**: `eraseText` before every `inputText` — full rule in `flow-authoring.md`, Input fields.

## System Overlays Steal the Hierarchy

- **Symptom**: Maestro cannot find an element that is visibly on screen.
- **Why**: OS/vendor overlays ("app keeps crashing" dialogs, permission prompts) take over the accessibility hierarchy.
- **Fix**: `adb shell dumpsys window` filtered to `mCurrentFocus|mObscuringWindow`. Dismiss overlay (usually Back); if it is a crash dialog, fix the crash first; rerun affected flow.

## Brittle Text Assertions

- **Symptom**: Flow fails on cosmetic copy changes (version strings, punctuation, casing).
- **Why**: Exact-text assertion on strings that change per build.
- **Fix**: Prefer element IDs; where text must be asserted, tolerant regex anchored on the stable part (e.g. `.*v.*build.*`).
