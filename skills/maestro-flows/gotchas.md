# Gotchas

Malfunctions of THIS SKILL observed in real runs — wrong commands composed, misread config, bad assumptions during discovery. Read at the start of every run. Update only from observed failures, never speculation.

Maestro/app failure modes (crashes, overlays, flaky selectors) do NOT belong here — those live in `references/troubleshooting.md`.

Entry format: **What goes wrong** / **Why** / **Fix**.

---

## Flow Authoring / Diagnosis

- **What goes wrong**: Flows are authored and "fixed" by guessing UI behavior (keyboard dismissal, input return actions, when/where labels render), producing repeated trial-and-error runs that keep failing.
- **Why**: The skill verified selectors against source but not *behavior* — event handlers, control properties (e.g. ReturnType), and view structure were never read before writing assertions or diagnosing failures.
- **Fix**: Before authoring a flow AND before every flow "fix", read the feature's source (page markup + code-behind/handlers) and derive the expected behavior from it. Never change a flow based on an unverified hypothesis about how the UI works. <!-- 2026-07-08T15:45:00 -->

## Device / Emulator Startup

- **What goes wrong**: The skill burns many runs retrying emulator launches (and improvising launchd/daemon workarounds) when every launch dies right after the startup banner.
- **Why**: The emulator needs hypervisor access; a sandboxed harness kills it no matter how the command is composed. The log cutting off after the first banner lines with no error is the signature.
- **Fix**: One launch attempt per the step-4 requirements; if the process is dead ~10s later with a truncated log, stop and ask the user to start the emulator — never retry or invent workarounds. <!-- 2026-07-08T17:10:00 -->
