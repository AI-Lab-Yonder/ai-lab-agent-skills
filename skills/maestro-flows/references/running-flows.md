# Running Flows — Token- and Runtime-Efficient Conventions

## Results folder

All run outputs go to a per-run folder inside the project so results can be verified later:

```
<resultsDir>/run-<yyyyMMdd-HHmmss>/
├── console.log      # full redirected console output
├── report.xml       # JUnit report
└── artifacts/       # screenshots (auto-captured on failure), video, commands JSON, maestro.log
```

`resultsDir` comes from `.maestro-flows.local.json` (default `maestro-results/` at repo root, gitignored at setup).

## Failure screenshots are automatic

Maestro captures screenshots and metadata for every run — no flag needed to get failure screenshots. What needs controlling is WHERE they land: default is `~/.maestro/tests/`, uncorrelated with the run. Flag split is non-obvious:

- `--test-output-dir` → screenshots, video, commands JSON (NOT maestro.log)
- `--debug-output` → maestro.log only (when dirs differ)

Point both at the same folder to consolidate everything.

## Token-cheap result parsing: JUnit report, not console scraping

Always run with a machine-readable report and parse that instead of the console stream (example in bash — compose the run-folder timestamp per host shell):

```bash
RUN="<resultsDir>/run-$(date +%Y%m%d-%H%M%S)"
maestro test --format junit --output "$RUN/report.xml" \
  --test-output-dir "$RUN/artifacts" --debug-output "$RUN/artifacts" \
  <flowsDir> > "$RUN/console.log" 2>&1
```

(`--output` is not placed inside `--test-output-dir` automatically — always pass the full report path.)

Read only the JUnit XML — per-flow pass/fail, durations, and failure messages in a few hundred tokens. Open `console.log` or `artifacts/` only when the XML is not enough. When the user wants to eyeball failures, `--format html` produces a human-readable report with failure screenshots embedded.

## Run subsets with tags, not paths

Flows carry `tags:` headers (see `flow-authoring.md`); filter at the CLI instead of running the whole suite:

```bash
maestro test . --include-tags=smoke --exclude-tags=wip
```

Multiple tags in one flag = OR; include + exclude combined = AND. CLI flags override `config.yaml` `includeTags`/`excludeTags`.

Workspace `config.yaml` (in the flows dir) also controls discovery and failure behavior:

```yaml
flows:
  - "login/*"      # glob, "**" for recursive
continueOnFailure: true   # one failed flow doesn't stop the suite
```

## App restarts between flows — when to override

`launchApp` kills and relaunches the app by default (`stopApp: true`), and flow order is non-deterministic by design — every flow must be runnable on a reset device. Keep it that way for state-sensitive suites (login tests need the logged-out state; a prior flow may end elsewhere).

Overriding is a suite-design decision that trades isolation for speed — never apply it silently: ask the user, presenting the trade-off, and only proceed on approval. Valid candidates: long ordered journeys, slow cold-start apps. Both pieces are then required:

```yaml
# in the flow: foreground without restarting
- launchApp:
    stopApp: false
```

```yaml
# config.yaml: force the order the chain depends on
executionOrder:
  continueOnFailure: false   # dependent chain — stop when a step fails
  flowsOrder:
    - step1-flow
    - step2-flow
```

For shared preconditions (e.g. "already logged in"), prefer a nested setup flow via `runFlow` inside each test over leaking state between flow files.

## Credentials via environment, not YAML

`maestro test -e USERNAME=x -e PASSWORD=y flow.yaml` — referenced in flows as `- inputText: ${USERNAME}`.
