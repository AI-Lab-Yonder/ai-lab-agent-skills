# Project Discovery

How to determine the app setup on first run. Ask the user only when a step is ambiguous or fails — never ask for something discoverable.

## 1. Flows directory

Look for an existing Maestro directory, in order: `.maestro/`, `maestro/`, `**/maestro/flows/`. If none exists and the task is authoring, propose creating `.maestro/` (Maestro's default).

## 2. Build system → install command

Detect by marker file at repo root (or nearest app subfolder):

| Marker | Stack | Full install command |
|---|---|---|
| `*.csproj` with `net*-android` TFM | .NET MAUI | `dotnet build <proj> -f <tfm> -c Debug -t:Install --no-incremental` |
| `build.gradle`/`build.gradle.kts` + `gradlew` | Android native / RN | `./gradlew installDebug` (add `--rerun-tasks` for guaranteed freshness) |
| `pubspec.yaml` | Flutter | `flutter install -d <deviceId>` |
| `package.json` with `react-native` dep | React Native | `./gradlew installDebug` from `android/` |
| `*.xcodeproj`/`*.xcworkspace` | iOS | `xcodebuild ... -destination 'id=<udid>'` then `xcrun simctl install` |

If multiple app projects match, ask the user which one is the target. On Windows use `gradlew.bat` instead of `./gradlew`.

## 3. App ID

- MAUI: `<ApplicationId>` in the csproj.
- Gradle: `applicationId` in `build.gradle`/`defaultConfig`.
- Flutter/RN: same Gradle location under `android/app/`.
- Fallback: `AndroidManifest.xml` `package` attribute, or an existing flow's `appId:` header.

## 4. adb and device

`adb` is often NOT on PATH (e.g. Homebrew's android-commandlinetools does not link it). Resolve it in this order, stop at the first hit, and record the full path in the config file so no later run repeats the search:

1. `command -v adb` (Windows: `where adb` / `Get-Command adb`)
2. `$ANDROID_HOME/platform-tools/adb` (if `ANDROID_HOME` is set)
3. Common SDK roots + `/platform-tools/adb`:
   - macOS: `~/Library/Android/sdk`, `/opt/homebrew/share/android-commandlinetools`
   - Linux: `~/Android/Sdk`
   - Windows: `%LOCALAPPDATA%\Android\Sdk`

Then: `<adb> devices` — exactly one device → use it; several → ask.

No device → try to start an emulator before asking:

1. Emulator binary lives at `<sdk root>/emulator/emulator` (same SDK root as adb).
2. `<emulator> -list-avds` — exactly one AVD (or one cached as `avd` in config) → start it. Compose the launch command for the host OS yourself: set `ANDROID_HOME` to the SDK root in the launch environment, start it fully detached so it survives your command returning, run headless-friendly (disable snapshot load, audio, boot animation), and redirect output to a log file in the results folder — never into chat.
3. ~10s later confirm the process is still alive (process lookup by name/pattern for your OS). If it died immediately — log cut off right after the startup banner — your environment cannot start it (sandboxed harnesses kill the emulator); do not retry or improvise workarounds, ask the user to start the emulator themselves.
4. Wait for boot (the while-loop runs on the device shell, so it works from any host OS): `<adb> wait-for-device shell 'while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 2; done'` (give it ~120s).
5. Multiple AVDs → ask which. No AVDs, emulator binary missing, or boot still fails → ask the user to connect/start a device.

- iOS: `xcrun simctl list devices booted`; none booted → `xcrun simctl boot <name>` for the sole available simulator, else ask.

## 5. Maestro binary

Try `maestro --version` on PATH. If not found, check common locations: `~/.maestro/bin/maestro`, `C:\maestro\bin\maestro.bat`. If still not found, ask — do not attempt to install it without confirmation.

## 6. Persist

Write all resolved values to `.maestro-flows.local.json` at the repo root. This file is machine-local state — never put it inside the skill folder (the skill ships without it) and never commit it (add it to `.gitignore` along with `resultsDir`):

```json
{
  "platform": "android",
  "deviceId": "<from adb devices>",
  "avd": "<AVD name if an emulator was started, for later auto-start>",
  "maestro": "<binary path or 'maestro' if on PATH>",
  "adb": "<full path from step 4, or 'adb' if on PATH>",
  "androidHome": "<SDK root from step 4>",
  "flowsDir": ".maestro",
  "appId": "<application id>",
  "installCommand": "<full non-incremental build+install command>",
  "resultsDir": "maestro-results"
}
```

On later runs, validate cached values instead of trusting them blindly: check the `adb` and `maestro` paths still exist and re-verify the device (devices come and go). Any value that fails validation → re-run just that discovery step and update the file.
