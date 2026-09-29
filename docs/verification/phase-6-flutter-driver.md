# Phase 6 Verification — Flutter Driver Flavor (task 8) + phase 3 carry-overs

**Phase:** 6 — `lib/main_automation.dart`, `tool/drive.dart`, `run_macos_driver`, preferences isolation, smoke-test timeout
**Plan:** `docs/plans/automation-a11y-plan.md`
**Repo:** vfx-gui
**Branch:** `feat/automation-a11y` (unstaged working tree on top of the wave B commit; `.claude/worktrees/` ignored)
**Base:** `testnet`
**Verifier:** reviewer agent (spawned by the orchestrator lead; no commit; did not run the app or the CLI)
**Date:** 2026-09-26

## Verdict: **PASS WITH WARNINGS**

Every Task 8 item and both carry-overs are delivered. Production `lib/main.dart` cannot reach `flutter_driver`: the only two files importing it are `lib/main_automation.dart` and `lib/core/automation/driver_label_finder.dart`, and only the former imports the latter. The `shared_preferences` bump from 2.0.20 to 2.2.2 has no API change the app uses (the app calls `getInstance`, `getString`, `setString`, `remove`), its new macOS 10.14 minimum equals the project's existing deployment target, and `setPrefix` runs only for desktop automation builds and before the single `getInstance` in `initSingletons`. `tool/drive.dart` is correct, has explicit exit codes and no silent catches, and its usage paths behave as documented. The 22 automation and helper tests pass and are meaningful, the analyzer set equals the baseline, and the on-disk evidence of the executor's live run is consistent (three `automation.*` preference keys beside the wallet's `flutter.*` keys, the isolated `DatabasesTestNet` modified at 18:10 today, the real `~/rbxtest` untouched since the phase 1 run). One warning: `get-text` advertises a `label:` finder that can never succeed, because the driver's `getText` accepts only `Text`, `RichText`, `TextField`, `TextFormField` and `EditableText` and a label finder yields a `Semantics` or `Tooltip` widget.

---

## Checks run

| Check | Result |
|---|---|
| `flutter analyze` | 390 issues, 0 errors; identical to the phase 1 baseline after stripping line:col; nothing in the phase 6 files |
| `flutter test test/core/automation test/integration_helpers_test.dart` | 22 passed, 0 failed (lead: full suite 221 passing, only `test/widget_test.dart` failing) |
| `dart run tool/drive.dart --help` / no args | Usage printed, exit 0 |
| `... frobnicate` / `... tap-text` (missing arg) / `... health` with no URL | `error: unknown command "frobnicate"`, `error: tap-text takes 1 argument(s): tap-text <text>`, `error: pass --vm-service-url <url> or set VM_SERVICE_URL`; each followed by the usage, exit 2 |
| `make -n run_macos_driver` | `fvm flutter run -t lib/main_automation.dart -d macos --dart-define TESTNET=true --dart-define AUTOMATION=true` |
| Import graph | `grep` for `flutter_driver`, `flutter_test`, `driver_label_finder` under `lib/`: only `main_automation.dart` and `driver_label_finder.dart`; `main.dart`'s imports and their imports (`prefs_isolation.dart`, `web_semantics.dart`) never reach them |
| SDK sources read | `flutter_driver`: `extension/extension.dart:221-224,395-402`, `driver/driver.dart:746`, `driver/vmservice_driver.dart:360`, `common/handler_factory.dart:406-430`, `common/find.dart:249-251`; `flutter_test`: `test_text_input.dart:207-218` |
| `shared_preferences` 2.2.2 changelog (pub cache) | 2.1.0 `setPrefix`; 2.1.2 macOS minimum 10.14, Flutter 3.3/Dart 2.18; 2.2.0 `allowList`; 2.2.1 Flutter 3.7/Dart 2.19; no removed or changed API |
| Live run | Not repeated (the lead's instruction); executor's transcript accepted with the evidence below |

---

## 1. Backward compatibility and production safety

### 1a. `shared_preferences` bump
**PASS.**
- Resolved set: `shared_preferences` 2.2.2, `_platform_interface` 2.3.1, `_foundation` 2.3.4, `_web` 2.2.1, `_windows` 2.3.2, `_linux` 2.3.2, `_android` 2.2.1. `macos/Podfile.lock` changes only the `shared_preferences_foundation` checksum.
- The app's usage (`grep` over `lib/`): one `SharedPreferences.getInstance()` (`lib/core/singletons.dart:13`), `getString`, `setString`, `remove`, and the new `setPrefix`. None of these changed between 2.0.20 and 2.2.2.
- SDK floors: 2.2.1 requires Flutter 3.7 / Dart 2.19; the project pins 3.7.12 / 2.19.6. macOS minimum 10.14 (from 2.1.2): `macos/Podfile:1` is `platform :osx, '10.14'` and all six `MACOSX_DEPLOYMENT_TARGET` entries in `project.pbxproj` are 10.14, so nothing changes for users.
- The production web wallet now ships `shared_preferences_web` 2.2.1 instead of 2.0.x, with the same default `flutter.` prefix (INFO 4).

### 1b. `setPrefix` scope and ordering
**PASS.** `lib/core/automation/prefs_isolation.dart:20-28`: the prefix is `'automation.'` only when `isAutomation && !isWeb`, otherwise null and `setPrefix` is never called (lines 33-41). `Env.isAutomation` is a compile-time constant, so production builds evaluate a function that returns null. `lib/main.dart:31-36,52`: `isolatePreferencesForAutomation()` runs after `ensureInitialized()` and before `initSingletons()`, which holds the only `getInstance` in the code base, so the plugin's "setPrefix after getInstance" `StateError` cannot occur. The driver flavor and the smoke test both enter through `app.main`, so they get the same ordering.

### 1c. No driver code in the production entrypoint
**PASS.** See the import-graph row above. `driver_label_finder.dart` also imports `flutter_test` (needed for `find.byWidgetPredicate`); it is reachable only from `main_automation.dart`, and the finder is registered only there (`main_automation.dart:15`). `enableFlutterDriverExtension` constructs `_DriverBinding` (`extension.dart:222`), which must precede any other binding initialisation; `main_automation.dart` calls it before `app.main`, whose `ensureInitialized()` then returns that binding.

---

## 2. `tool/drive.dart`

**PASS with one warning.** Read in full (375 lines).
- Structure: a table of seven commands plus `health`, each a `DriveCommand` with an argument count checked in `parseArgs` (`drive.dart:243-247`). Options may precede or follow the command; `--timeout` must be a positive integer; unknown `--options` are rejected.
- Connection: `FlutterDriver.connect(dartVmServiceUrl:)` under a 30 s `connectTimeout`; a `TimeoutException` prints a message that names the two usual causes (wrong URL, app not started from `main_automation.dart`) and exits 1; any other connect error is described and exits 1 (lines 337-353).
- Execution: every command runs inside `driver.runUnsynchronized(..., timeout:)` (`driver.dart:746` confirms the signature) because the boot cube animates forever; `UsageException` from `parseFinder` exits 2, any other failure exits 1 with the innermost `DriverError` message and a hint for the three common shapes (no match, too many matches, timeout); `driver.close()` runs in `finally` (lines 355-374). No catch swallows anything.
- `screenshot` writes the bytes with `flush: true`; the two-second pre-capture delay the doc mentions is real (`vmservice_driver.dart:360`).
- `type` uses `enterText`, which goes through the extension's text-entry emulation; with no focused client `TestTextInput.updateEditingValue` sends client `-1` (`test_text_input.dart:213`) and the framework ignores it, which is the "dropped silently" the doc describes.
- `find.byType` takes a `String` (`find.dart:251`), so `type:<WidgetType>` is valid.
- `get-text label:<label>`: see WARN 1.

---

## 3. Tests

| Test | Asserts | Verdict |
|---|---|---|
| `test/core/automation/prefs_isolation_test.dart` | `preferencesPrefixFor` for the four combinations; then with an `InMemorySharedPreferencesStore` seeded with `flutter.password`, `setPrefix('automation.')` + `getInstance` sees no keys, a `setString('password')` lands under `automation.password`, and the store still holds the wallet's `flutter.password` unchanged | Meaningful: proves the isolation contract on the plugin's own read and write paths |
| `test/core/automation/driver_label_finder_test.dart` | `widgetHasLabel` matches `Semantics(label:)` and `Tooltip(message:)` exactly and rejects `Text` and `Semantics(tooltip:)`; the wire format is `{finderType: ByLabel, label}`; round-trip through the extension; missing label rejected; a pumped tree shows the finder resolving an `IconButton` tooltip, a `Semantics` wrapper and an `Icon.semanticLabel`, finding nothing for an absent label, and taps through both controls | Meaningful: covers the only two label conventions phases 4 and 5 used, plus the tap path |

The `Semantics(tooltip:)` negative documents a real limit: a bare `Semantics(tooltip:)` is not matched, only the `Tooltip` widget is. Nothing in the app labels controls that way.

---

## 4. `docs/automation.md`

**PASS with one inaccuracy (INFO 1).** One line per paragraph throughout. Checked against what shipped:
- The `flutter run` line: "An Observatory debugger and profiler on macOS is available at: http://127.0.0.1:PORT/TOKEN=/" is the 3.7.12 wording (newer SDKs say "A Dart VM Service"); the executor observed it live. The `--vm-service-url`/`VM_SERVICE_URL` instructions match `drive.dart:323-329`.
- The command list, default timeout (30 s), exit codes (0/1/2), `--verbose`, frame sync off, exact text matching, "Too many elements" and the screenshot delay all match the code and the SDK.
- The quit procedure (`osascript ... io.reserveblock.wallet ... quit`) matches the executor's observation and the app's close handler in `main.dart`.
- The preferences paragraph (line 58) matches `prefs_isolation.dart` and the ordering in `main.dart`, and correctly excludes web.
- The stale sentence about every run touching `~/rbxtest` is fixed (line 39).
- Line 55, "Not isolated: Windows, for the CLI data and the preferences alike", contradicts `prefs_isolation.dart:24`: the prefix applies on every non-web platform, so a Windows automation build would isolate preferences but not CLI data. INFO 1.
- The `get-text` bullet lists `label:<label>` as a finder kind; see WARN 1.

---

## 5. Plan acceptance for Task 8 and the carry-overs

| Item | Status |
|---|---|
| `flutter_driver` (sdk: flutter) in dev_dependencies | `pubspec.yaml:86-87` |
| `lib/main_automation.dart` calls `enableFlutterDriverExtension()` then the shared bootstrap; production `main.dart` never imports the extension | Done; import graph verified |
| `tool/drive.dart` connects with `FlutterDriver.connect(dartVmServiceUrl:)`; `tap-text`, `tap-key`, `tap-label`, `type`, `get-text`, `screenshot <path>`, `wait-for-text`; clear errors | All present plus `health`; errors and exit codes verified |
| Makefile `run_macos_driver` with `-t lib/main_automation.dart -d macos` and both defines | `Makefile:169-172`, `make -n` verified |
| `docs/automation.md` driver section including how to get the VM service URL | Present |
| Carry-over: `shared_preferences` `^2.1.2`, `setPrefix('automation.')` under `Env.isAutomation` before the first `getInstance`, documented | Done; resolved to 2.2.2; doc line 58 |
| Carry-over: smoke test outer `Timeout` 8 min | `integration_test/app_smoke_test.dart:117` |
| Acceptance: with the app running via `run_macos_driver`, `drive.dart` taps a labelled control and reads text back; transcript in the report | Executor-reported (per the lead): `health`, `screenshot`, `tap-text "No"` dismissing the Import Snapshot dialog, `wait-for-text Dashboard`, `get-text`, `tap-label "Syncing..."` (a tooltip'd indicator), a correct negative on an absent label, and a 3 s `wait-for-text` timeout with exit 1. Not repeated by the reviewer |

Evidence inspected read-only, consistent with that run: `defaults read io.reserveblock.wallet` shows 14 `flutter.*` keys and exactly three `automation.*` keys (`BURNED_NFT_IDS`, `PENDING_ADNRS`, `TRANSFERRED_NFT_IDS`, the keys the app writes at boot), so the automation build wrote under its own prefix; the isolated `.../vfx-gui-automation/rbxtest/DatabasesTestNet` was modified at 18:09-18:10 today and `TrilliumTestNet` was created there at 18:09; the newest file under the real `~/rbxtest` is still from 15:48 (the phase 1 run); `macos/Runner.xcodeproj/project.pbxproj` is clean; `macos/Podfile.lock` changed only the one checksum. That the wallet's `flutter.*` values are byte-identical to before is the executor's observation and cannot be reconstructed after the fact.

### Deviations judged
1. **Custom `ByLabel` finder instead of `find.bySemanticsLabel`: accepted.** The plan forbids forcing semantics on in the macOS build, `bySemanticsLabel` needs the semantics owner, and the phase 4 review confirmed `Tooltip` sets `Semantics.tooltip` rather than `label` in 3.7.12, so a widget-tree match on `Semantics.properties.label` and `Tooltip.message` is the only way to reach the labels phases 4 and 5 added. The `show SerializableFinder` import from the driver-side library is confined to the two automation-only files. The finder is registered only in `main_automation.dart`.
2. **`runUnsynchronized` for every command, exact-text matches, `--timeout`/`--verbose`/`VM_SERVICE_URL`: accepted.** Frame sync would never settle on the boot screen; the per-command timeout bounds the unsynchronised action; exact matching is what the driver's `find.text` does and the doc says so.
3. **`shared_preferences` 2.2.2 / `_foundation` 2.3.4: accepted.** Floors fit the pinned SDK and the deployment target; the prefixed read path needs `getAllWithParameters`, which 2.3.4 implements; the isolation test exercises that path through the in-memory store.

---

## Conventions and hard constraints

| Rule | Status |
|---|---|
| Flutter 3.7.12, `fvm flutter` in Makefile, pinned `dart` for the tool | Followed |
| No new analyzer issues (baseline 390) | Same set |
| No new test failures | 22 pass; two new test files |
| Tests alongside code | Yes, for both new library files |
| No refactors while building | None; one call added to `main.dart`, one line to the smoke test |
| `kIsWeb` for platform branching | `prefs_isolation.dart:36` |
| Explicit error handling | `drive.dart` exits 1 or 2 with a message on every failure path |
| Doc prose: one line per paragraph | Yes |
| Do not commit | Nothing committed |

---

## Findings

### WARN 1 — `get-text label:<label>` is advertised but cannot succeed
`drive.dart:118-122,156-176` and `docs/automation.md` offer `label:<label>` as a `get-text` finder. The `ByLabel` finder resolves to the `Semantics` or `Tooltip` widget that carries the label, and the driver's `getText` handler (`flutter_driver/src/common/handler_factory.dart:413-430`) accepts only widgets whose `runtimeType` is exactly `Text`, `RichText`, `TextField`, `TextFormField` or `EditableText`, throwing `UnsupportedError('Type Semantics is currently not supported by getText')` for anything else. Every `get-text label:...` call therefore exits 1 with that message, which reads like a bug in the app rather than in the tool.

Fix, either one:
- Drop `label` from `parseFinder`'s kinds and from the doc and `--help` text (three lines), or
- Resolve `label:` for `get-text` as `find.descendant(of: ByLabel(value), matching: find.byType('Text'), matchRoot: false)` so it reads the text inside the labelled control. Nested driver finders are deserialized through the registered extensions (`extension.dart:395-402`), so the custom finder works inside `Descendant`.

### INFO 1 — Doc line 55 misstates Windows preference isolation
`prefs_isolation.dart:24` applies the prefix on every non-web platform, so on a Windows automation build the preferences would be isolated while the CLI data would not. Suggested wording: "Not isolated: Windows CLI data (the `HOME` override is macOS-only); the preferences prefix applies on every desktop platform."

### INFO 2 — `drive.dart` with no arguments exits 0
It prints the usage and returns like `--help`. Scripts that call it wrongly get a success code. Exiting 2 for the no-argument case (keeping 0 for an explicit `--help`) is a two-line change; optional.

### INFO 3 — Live acceptance is executor-reported
The reviewer did not run the app (per instruction). The on-disk evidence in section 5 is consistent with the reported session. `type` was not exercised live; the doc's behaviour claim for it follows from the SDK source (section 2), not from a run.

### INFO 4 — Platform package bumps ship to production
The web wallet now builds with `shared_preferences_web` 2.2.1 and desktop with `_foundation` 2.3.4; the default `flutter.` prefix and the four APIs the app calls are unchanged, so no behaviour change is expected. Worth knowing when reading the next release's dependency diff.

---

## Files reviewed
- `pubspec.yaml` (+2 dev dep, `shared_preferences` `^2.1.2`), `pubspec.lock` (resolution listed in 1a), `macos/Podfile.lock` (one checksum)
- `lib/core/automation/prefs_isolation.dart` (new, 41 lines), `test/core/automation/prefs_isolation_test.dart` (new, 4 tests)
- `lib/core/automation/driver_label_finder.dart` (new, 70 lines), `test/core/automation/driver_label_finder_test.dart` (new, 7 tests)
- `lib/main_automation.dart` (new, 17 lines), `lib/main.dart` (+6)
- `tool/drive.dart` (new, 375 lines)
- `Makefile` (+5), `integration_test/app_smoke_test.dart` (timeout), `docs/automation.md` (+21/-4)
- SDK sources listed under "Checks run"

## Not reviewed
- The live driver session and the CLI launch (not repeated).
- Wave C, in its own worktree.

## Recommendation
Commit phase 6 after resolving WARN 1 (either fix is a few lines; the descendant variant keeps the feature). Apply the INFO 1 wording. The other two INFO items are optional.
