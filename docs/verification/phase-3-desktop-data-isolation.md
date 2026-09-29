# Phase 3 Verification — Desktop Data Isolation (task 5)

**Phase:** 3 — Keep automation runs of the desktop app away from the real testnet data
**Plan:** `docs/plans/automation-a11y-plan.md`
**Repo:** vfx-gui
**Branch:** `feat/automation-a11y` (uncommitted working tree on top of `5bc93bdc`; `.claude/worktrees/` ignored)
**Base:** `testnet`
**Verifier:** reviewer agent (spawned by the orchestrator lead; no commit)
**Date:** 2026-09-26

## Verdict: **PASS WITH WARNINGS**

The acceptance criterion is met and evidenced: a fresh automation run created the Core CLI's data only under `~/Library/Application Support/vfx-gui-automation/rbxtest` (listing below), nothing under the real `~/rbxtest` is newer than the phase 1 run, and analyze is at the 390 baseline with an issue set identical to the phase 1 run. Outside automation every touched path helper still performs the exact `replaceAll('/Documents', ...)` it did before, and the automation branch is compiled out of production builds by the const `Env.isAutomation`. The executor's findings about the Core CLI and .NET check out against the sources. The Shell environment override is confined to the macOS branch under automation, with explicit error handling. The phase 1 teardown gap (WARN 1) is closed by the CheckStatus probe. One warning: the GUI's own preferences (NSUserDefaults) are still shared with the installed wallet, and a `shared_preferences` release that fixes this fits the pinned SDK, so it should be scheduled before any automated flow writes preferences.

---

## Checks run

| Check | Result |
|---|---|
| `flutter analyze` | 390 issues, 0 errors. Issue set byte-identical to the phase 1 run |
| `flutter test test/core test/integration_helpers_test.dart` | 25 passed, 0 failed (6 new in `data_home_test.dart`, 2 new `probeHttp` tests) |
| Integration smoke test | Not re-run by the reviewer; exec-5's result (passed in 34 s) accepted with the on-disk evidence below |
| Core CLI sources (GitHub, `VerifiedXBlockchain/VerifiedX-Core` at HEAD) | `Utilities/GetPathUtility.cs`, `Program.cs`, `Globals.cs`, `Config/Config.cs`, `VerifiedXCore.csproj` |
| .NET runtime source | `Environment.GetFolderPathCore.Unix.cs` (dotnet/runtime, release/8.0; the Core targets net6.0, same logic) |
| `process_run` 0.12.3+2 | `Shell` environment merge order |
| `integration_test` 3.7.12 | `overrideHttpClient` |

Lead-reported full suite: 197 passing, only the pre-existing `test/widget_test.dart` failing.

---

## Acceptance: data created only under the isolated folder

Inspected read-only after exec-5's run. Folder created 16:32:10 today by the CLI launched with the overridden `HOME`:

```
~/Library/Application Support/vfx-gui-automation/rbxtest/
  BeaconAssetTestNet/    4.0K
  CheckpointTestNet/       0B
  ConfigTestNet/         4.0K
  DatabasesTestNet/      6.2M   (54 entries: rsrv*.db and their -log.db files)
  LogosTestNet/           68K
  PlonkParamsTestNet/    255M   (vfx_plonk_v1.params, downloaded on this first run)
```

Real `~/rbxtest`: directory mtimes are Aug 22 to Sep 11 except `TrilliumTestNet` (15:48 today, from the phase 1 run before isolation existed). `find ~/rbxtest -newer <isolated folder>` returns nothing; the newest files anywhere under it are `DatabasesTestNet/*-log.db` at 15:48:53 today, again the phase 1 run. Nothing was written there by the isolated run. **PASS.**

---

## 1. Executor's findings against the sources

| Claim | Source | Result |
|---|---|---|
| The CLI has no data-folder argument | `Program.cs` argument loop (lines 209-260, 287-340, 539-560): `testnet`, `warden`, `version`, `startgui`, `stunmessages`, `stunport`, `gui`, `blockv2`, `unsafe`, `skip`, `revertblock=`, `rebuildstate`, `snapshot=`, `enableapi`, `logmemory`, `stun`, `testurl`. No path or folder argument | Confirmed |
| macOS paths derive from `SpecialFolder.UserProfile` | `GetPathUtility.cs:24-26, 60-62, 96-98, 132-134, 167-169, 203-205`: every folder (database, checkpoint, beacon, config, ABL, params) starts from `Environment.GetFolderPath(SpecialFolder.UserProfile)` under `IsOSPlatform(OSX)` | Confirmed |
| `CustomPath` is only settable from the config file inside the default folder | `Globals.cs:298` declares it null; the only assignment is `Config/Config.cs:106`, reading key `CustomPath` from the parsed config file, whose own location comes from `GetPathUtility` | Confirmed |
| .NET reads the home from `$HOME` and returns `""` for a missing directory | `Environment.GetFolderPathCore.Unix.cs`: `UserProfile` comes from `PersistedFiles.GetHomeDirectory()` (`$HOME` first); `GetFolderPathCore` verifies with `Access(path, R_OK)` and, for the default `SpecialFolderOption.None`, returns `string.Empty` on failure | Confirmed. The `createSync` before launch is required, not defensive |

---

## 2. Outside automation, byte-identical behaviour

`DataHome.fromDocuments(path, replacement)` (`lib/core/data_home.dart:62-68`) passes `automationHome: Env.isAutomation ? cliHome() : null`; with the const false, `rewriteDocumentsPath` (lines 34-43) returns `documentsPath.replaceAll('/Documents', replacement)`, the same call the six sites made before:

| Site | Before | After |
|---|---|---|
| `lib/utils/files.dart:54` (`dbPath`) | `replaceAll("/Documents", "/rbxtest" or "/rbx")` | `DataHome.fromDocuments(path, same)` |
| `lib/utils/files.dart:81` (`configPath`) | `replaceAll("/Documents", "/RBXTest/ConfigTestNet/config.txt" or "/RBX/Config/config.txt")` | same replacement |
| `lib/utils/files.dart:96` (`startupProgressPath`) | `replaceAll("/Documents", "/RBXTest/DatabasesTestNet/statesynclog.txt" or ...)` | same replacement |
| `lib/core/utils.dart:253-254` (`backupMedia`) | `replaceAll("/Documents", "/rbxtest" or "/vfx")` | same replacement |
| `lib/features/home/components/home_buttons/open_log_button.dart:31-32` | same | same |
| `lib/features/nft/components/nft_card.dart:317` | same | same |

All six sit inside `if (Platform.isMacOS)` branches as before; the Windows branches are untouched. `cliHome()` (which reads `$HOME` and can throw) is never evaluated outside automation because the const guard eliminates the call. `test/core/data_home_test.dart` pins both replacement shapes (`/rbxtest` and `/RBXTest/ConfigTestNet/config.txt`) and the no-define behaviour of `cliHome` and `fromDocuments`. A grep for other `replaceAll("/Documents"` or `rbxtest` literals in `lib/` finds only commented-out code in `open_db_button.dart`. **PASS.**

---

## 3. Shell environment override

`lib/core/providers/session_provider.dart:966-984, 991`. Inside the non-Windows (`else`) branch of `_startCli`, only under `if (Env.isAutomation)`: resolves `DataHome.cliHome()`, `createSync(recursive: true)` on it, logs "Automation: CLI data isolated under ..." and passes `environment: {'HOME': cliHome}` to `Shell`. Any exception (unset `HOME`, unwritable folder) is caught, logged as a `Danger` entry on the boot screen, and `_startCli` returns false; the caller (`session_provider.dart:245-248`) then stops the boot with "CLI Could not start". Nothing is swallowed. The Windows branch (lines 899-960) is unchanged and never sees the override.

`process_run` applies the map as an override on top of the parent environment: `Shell(environment:, includeParentEnvironment: true)` builds `ShellEnvironment.full`, which starts from the parent environment and `merge`s the given map (`shell_environment.dart:30-37`), then runs with that merged map. `PATH` and the rest are preserved; only `HOME` changes. The executable is an absolute path, so no lookup depends on `HOME`. **PASS.**

---

## 4. Smoke test guards

- **pgrep name check**: unchanged from phase 1 (`app_smoke_test.dart:25-31`).
- **CheckStatus probe** (lines 33-42, phase 1 WARN 1 carry-over): `probeHttp('${Env.apiBaseUrl}/CheckStatus/')`, i.e. `http://localhost:17292/api/V1/CheckStatus/` on testnet, and `fail()` when anything answers, whatever the status (a CLI holding another token answers 401 and is still a CLI). `probeHttp` (`integration_test/helpers.dart:47-70`) returns null only on `SocketException` (connection refused) or `TimeoutException`; an `HttpException` counts as an answer; any other exception propagates and fails `setUpAll`. The integration binding does not stub `HttpClient` (`integration_test.dart:92`, `overrideHttpClient => false`), so the probe is real. The unit tests run it against a local `HttpServer` under `HttpOverrides.runWithHttpOverrides` with a plain `HttpOverrides` subclass, which is the correct way to get the real client back inside `flutter test`. **PASS; WARN 1 from phase 1 is closed.**
- **Teardown**: unchanged. `cliLaunchedByTest` is set only after both guards passed; `LaunchedCli.terminate()` still only signals the shell the app recorded. **PASS.**
- **Warning without `AUTOMATION`** (lines 59-70): a seven-line starred block via `printToConsole` naming the real `~/rbxtest` folders and the fix (`make test_integration_macos`). It prints at the start of the test body, after the guards. **PASS.**
- **Post-boot isolation assertion** (lines 99-115): under automation, asserts `<cliHome>/rbxtest/DatabasesTestNet` exists with a reason that names the failure mode, and prints the sibling folder list. That is what produced exec-5's six-folder listing. **PASS.**

---

## Conventions and hard constraints

| Rule | Status |
|---|---|
| Flutter 3.7.12, absolute SDK binary in agent shells | Followed |
| No new analyzer issues (baseline 390) | 390, identical issue set |
| No new test failures | Only the pre-existing `test/widget_test.dart` |
| Tests alongside code | `data_home_test.dart` (6), `probeHttp` (2) |
| No refactors while building | The six call sites are the minimal switch; `DataHome` is new code, not a rewrite |
| Explicit error handling | `cliHome()` throws a `StateError` with a message; the launch site catches, logs `Danger`, returns false |
| `Platform.isX` only with `kIsWeb` | Existing `Platform.isMacOS` branches reused; `Env.isAutomation` is the switch |
| `snake_case` files, shared code in `lib/core/` | `lib/core/data_home.dart` |
| Never start a second CLI while the wallet runs | Both guards present |
| Doc prose: one line per paragraph | The new "Desktop data isolation" section and the edited web sentence comply |
| Do not commit | Nothing committed |

---

## Findings

### WARN 1 — GUI preferences (NSUserDefaults) are still shared with the installed wallet
`shared_preferences` is locked at 2.0.20, which has no `setPrefix`, so an automation run reads and writes the same `NSUserDefaults` domain as the user's real wallet (stored password hash, encryption flags, settings). The smoke test only boots and does not write preferences, so this does not affect the phase's acceptance, and `docs/automation.md` states the limitation. It becomes a hazard the moment a driven flow (phase 6) sets a password or changes settings: that would land in the real wallet's preferences.

A fix fits the pinned SDK. `setPrefix` arrived in `shared_preferences` 2.1.0; on pub.dev, 2.1.0 and 2.1.1 require Dart `>=2.17.0` and Flutter `>=3.0.0`, and 2.1.2 requires Dart `>=2.18.0` and Flutter `>=3.3.0`. Flutter 3.7.12 ships Dart 2.19.6, so `shared_preferences: ^2.1.2` resolves (verify the transitive `shared_preferences_foundation` bump with `pub upgrade --dry-run`). Then, before the first `getInstance()`, call `SharedPreferences.setPrefix('automation.')` under `Env.isAutomation`. The prefix is applied in the Dart layer, so it works on macOS without platform changes. Recommend scheduling this before phase 6, or as its first step.

### INFO 1 — Windows is not isolated
The override lives on the macOS launch branch and the Windows path helpers are unchanged. The plan scopes desktop automation to macOS and the doc says so. No action for this phase.

### INFO 2 — `RBXTest` vs `rbxtest` casing (pre-existing)
`configPath` and `startupProgressPath` rewrite to `/RBXTest/...` while the CLI creates `rbxtest/`. On the default case-insensitive APFS volume these are the same folder, in automation and outside it. On a case-sensitive volume they were already different for `~/RBXTest`; the phase preserves the behaviour rather than changing production paths, which is correct for "no refactors". Worth a one-line fix in a separate change.

### INFO 3 — Outer timeout versus the pumped-time budget
`pumpUntilFound` (30 s) plus `pumpUntilGone` (3 min) count pumped frame time, not wall time, and each 100 ms pump in the live binding also waits for a frame, so the wall time is longer than 3.5 min under load. The outer `Timeout(Duration(minutes: 5))` can fire first, which loses the helper's message listing the on-screen text. Suggested: raise the outer timeout to 7 or 8 minutes so the helper's `TimeoutException` is what a reader sees. On a first run in a fresh folder the 255 MB params download makes the wait longer still, although exec-5's run shows the CLI answers before that download finishes.

### INFO 4 — `probeHttp` treats a response timeout as "nothing listening"
A listener that accepts the connection but does not answer within 5 s returns null and the guard passes. On localhost a CLI answers CheckStatus immediately (200 or 401), and the pgrep check covers a stalled CLI with the expected name, so this is a corner case. If the guard is ever tightened, split the connect and response awaits and treat a response timeout as an answer.

---

## Files reviewed
- `lib/core/data_home.dart` (new, 69 lines)
- `lib/core/providers/session_provider.dart` (+22)
- `lib/utils/files.dart` (3 sites), `lib/core/utils.dart` (1 site), `lib/features/home/components/home_buttons/open_log_button.dart` (1 site), `lib/features/nft/components/nft_card.dart` (1 site)
- `integration_test/helpers.dart` (+26, `probeHttp`), `integration_test/app_smoke_test.dart` (+44)
- `test/core/data_home_test.dart` (new, 6 tests), `test/integration_helpers_test.dart` (+38)
- `docs/automation.md` (new section, one edited sentence)
- Read for context: `session_provider.dart:230-250` (caller of `_startCli`), Core CLI and .NET sources listed under "Checks run", `process_run` `shell.dart` and `shell_environment.dart`, `integration_test.dart:92`

## Not reviewed
- The integration smoke test was not executed by the reviewer. exec-5's result is accepted with the on-disk evidence in the acceptance section.
- `.claude/worktrees/` (phase 4 in progress by another agent).

## Recommendation
Commit phase 3. Schedule the `shared_preferences` bump and `setPrefix` (WARN 1) before phase 6 starts driving flows that persist preferences. The three INFO items are optional follow-ups.
