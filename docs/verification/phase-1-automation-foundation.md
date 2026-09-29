# Phase 1 Verification — Automation Foundation (tasks 1 and 3)

**Phase:** 1 — Automation flag, Makefile targets, desktop integration test scaffold
**Plan:** `docs/plans/automation-a11y-plan.md`
**Repo:** vfx-gui
**Branch:** `feat/automation-a11y` (uncommitted working tree on top of `466d1cae`)
**Base:** `testnet`
**Verifier:** reviewer agent (spawned by the orchestrator lead; no commit)
**Date:** 2026-09-26

## Verdict: **PASS WITH WARNINGS**

Both tasks meet their acceptance criteria. Analyze is at the recorded baseline (390 issues, 0 errors, none in the changed files), the 26 unit tests in the phase's scope pass, and `make -n` prints the exact commands the plan asked for. The smoke test's fail-fast guard and its teardown are implemented as specified, and the accepted `cli_exit.dart` deviation is a real bug fix with a regression test that fails on the pre-fix code (verified). Two warnings: the teardown's SendExit is only as safe as the process-name guard, and adding `integration_test` silently downgrades the production `archive` package from 3.3.6 to 3.3.2.

---

## Checks run

| Check | Result |
|---|---|
| `flutter analyze` | 390 issues, 0 errors (baseline 390). No issues in `lib/core/env.dart`, `cli_exit.dart`, `integration_test/`, or the new tests |
| `flutter test test/core test/integration_helpers_test.dart test/features/bridge` | 26 passed, 0 failed |
| `make -n run_web_automation` | `fvm flutter run -d web-server --web-port 42069 --dart-define TESTNET=true --dart-define AUTOMATION=true` |
| `make -n run_macos_automation` | `fvm flutter run -d macos --dart-define TESTNET=true --dart-define AUTOMATION=true` |
| `make -n test_integration_macos` | `fvm flutter test integration_test -d macos --dart-define TESTNET=true --dart-define AUTOMATION=true` |
| Regression test vs. pre-fix `cli_exit.dart` | Fails on HEAD code (see Task 3 deviation below) |
| Integration smoke test | Not re-run by the reviewer (launches the real CLI against `~/rbxtest`); executor result accepted with corroborating evidence |

Full-suite count reported by the lead (183 passing, 1 pre-existing failure) matches the plan baseline of 177 plus the 6 tests this phase adds (1 env, 4 helpers, 1 cli_exit).

---

## Task 1: Automation flag + Makefile targets

### 1. `Env.isAutomation` dart-define
**PASS.** `lib/core/env.dart:10-13` declares `static const bool _isAutomation = String.fromEnvironment('AUTOMATION') == 'true'`; the getter is at `lib/core/env.dart:115-117`, placed with the other network getters. The field is `const` rather than the mutable `static bool` used by `_isTestnet`/`_isDevnet`. That is a deliberate, commented deviation: there is no CLI-arg override for automation, so nothing needs to mutate it. Acceptable.

### 2. Unit test for the default
**PASS.** `test/core/env_test.dart` asserts `Env.isAutomation` is false without the define. Passes.

### 3. Makefile targets
**PASS.** `Makefile:161-170`. Keeps the `fvm flutter` spelling, uses the file's underscore naming, and sits between `run_web_cors` and `run_cli_mainnet` as the plan asked. The comment explains why `web-server` is used instead of `chrome`.

`run_macos_automation` has no `--dart-entrypoint-args`. That is correct: `Env.setTestnetFromArgs` (`lib/core/env.dart:15-25`) only ever sets the flag to true when `--testnet` is present and never resets it, so the `TESTNET=true` dart-define alone selects testnet. The smoke test's `[TESTNET]` assertion confirms the define reaches the app through this path.

### 4. Analyze clean
**PASS.** See the table above.

---

## Task 3: Desktop integration test scaffold

### 1. `integration_test` dev dependency
**PASS.** `pubspec.yaml:91-92`, alphabetical within `dev_dependencies`. `pubspec.lock` gains `integration_test`, `flutter_driver`, `fuchsia_remote_debug_protocol`, `sync_http`, `vm_service`, `webdriver`. See WARN 2 for the `archive` side effect.

### 2. `integration_test/app_smoke_test.dart`
**PASS.**
- `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` at line 21.
- Starts the app by calling `app.main(const [])` (line 48). `lib/main.dart`'s `main(List<String> args)` is directly callable, so no `bootstrap()` extraction was needed and `lib/main.dart` is untouched by this phase. This is the minimal change the plan asked for.
- Asserts the first desktop screen: waits for `BootContainer` (line 50-54), checks the `[TESTNET]` label the boot screen renders from `Env.isTestNet` (`lib/core/components/boot_container.dart:42`), then waits up to 3 minutes for the boot screen to clear, which only happens once the launched CLI answers.
- No `pumpAndSettle`. Boot progress is logged with elapsed time via `printToConsole`.

### 3. `integration_test/helpers.dart`
**PASS.** `pumpUntilFound` (lines 13-26) and `pumpUntilGone` (lines 31-44) share `_pumpUntil` (lines 58-77), which pumps in fixed steps and throws a `TimeoutException` that includes every visible `Text` on screen. On the boot screen that is the CLI launch log, which makes a timeout self-explanatory. The helpers depend only on `flutter_test`, so `test/integration_helpers_test.dart` can exercise them under the fake clock (4 tests: found, found-timeout with message, gone, gone-timeout). All pass.

### 4. Fail fast when a Core CLI is already running
**PASS.** `setUpAll` (lines 23-30) runs `pgrep -fl VerifiedXCore` and calls `fail()` with the matching process lines when the exit code is 0. `VerifiedXCore` is the binary name from `getCliPath()` at `lib/core/providers/session_provider.dart:812`, and it also matches the Makefile's `run_cli_testnet` invocation. `pgrep` excludes itself and the flutter test harness's command line does not contain the name, so there is no self-match. See WARN 1 for the limit of this guard.

### 5. Teardown only stops a CLI the test launched
**PASS with a caveat (WARN 1).** Reasoning, since the test was not re-run:
- `cliLaunchedByTest` (line 18) is only set to true inside the test body (line 47), after `setUpAll` has passed. If the guard fails, the body never runs and `tearDownAll` (lines 32-41) returns immediately.
- `LaunchedCli.terminate()` (`lib/core/services/launched_cli.dart:27-32`) only signals the `Shell` recorded by `launchedOnMac`, which `_startCli` calls right after `shell.run(cmd)` (`session_provider.dart:978-979`). When the app reattaches to an existing CLI instead (`session_provider.dart:874-884`), no shell is recorded and `terminate()` is a no-op. This half of the teardown is strictly limited to a test-launched process.
- `BridgeService().killCli()` (`bridge_service.dart:346`) sends `/SendExit` to whatever answers on the testnet API port. It is not tied to the launched process; it relies on the `pgrep` guard having proven nothing else was listening. That dependency is the subject of WARN 1.
- Calling `terminate()` unconditionally after `killCli()` is correct for the case the executor named: `_cliStillAnswering` (`bridge_service.dart:360`) returns false on a connection error, so a CLI that is still booting and has not opened its port makes `killCli()` return true immediately while the process is alive. In the accepted-exit path the process has exited by the time `waitUntilCliStops` returns, and `Shell.kill` returns false when it has no current process, so the extra call is harmless.

### 6. Ran once on this machine
**Accepted from the executor, not re-run.** exec-3 reported: passes, about 37 s, CLI launched by the test and stopped cleanly, against the real `~/rbxtest` testnet data. Corroborating evidence found read-only: `build/macos/Build/Products/Debug/.last_build_id` was written at 15:48 today, and `~/rbxtest/TrilliumTestNet` has a directory mtime of 15:48 today, consistent with a CLI launch at that time. `macos/Runner.xcodeproj/project.pbxproj` is clean, so the CocoaPods rewrite the plan warns about was reverted or did not occur.

### 7. Accepted deviation: `lib/features/bridge/utils/cli_exit.dart`
**PASS, verified as a real fix.**
- Bug: `killCli()` passes `() => getText("/SendExit")`, and `getText` returns `Future<String>` (`lib/core/services/base_service.dart:80`). The old `sendExit().catchError((Object error) { ... })` handler returned null, so the runtime rejected it. Reproduced against the HEAD version of the file with the new test scenario:
  ```
  Invalid argument(s) (onError): The error handler of Future.catchError must return a value of the future's type
  ```
  Reproduction was done with a temporary copy of the HEAD file under `test/`, run once and deleted; no implementation file was stashed or modified.
- Behavior preserved: in the old code the handler body (`exitRefused = true`) executed before the return-type check threw, so the exit/terminate decision was already correct. The fix (`cli_exit.dart:36-44`, `await` inside `try/catch` in an unawaited async closure) removes only the spurious unhandled `ArgumentError`, which fired on every GUI quit in production and failed the integration test's teardown.
- Regression test `test/features/bridge/cli_exit_test.dart:67-82` uses `Future<String>.error(...)`, the same shape as production. It fails without the fix and passes with it. The other four `exitCli` tests are unchanged and still pass.
- Scope: 15-line change, no refactor, commented with the reason. Within the plan's constraints.

---

## Conventions and hard constraints

| Rule | Status |
|---|---|
| Flutter 3.7.12, absolute SDK binary in agent shells, `fvm` in Makefile | Followed |
| No new analyzer issues (baseline 390) | 390, 0 errors |
| No new test failures (baseline 1, `test/widget_test.dart`) | Unchanged |
| Tests alongside code | Yes: env, helpers, cli_exit |
| No refactors while building | None; `cli_exit.dart` is a targeted fix |
| No `dart:html` in desktop-compiled code | No web code in this phase |
| Never start a second Core CLI | Guard present (`app_smoke_test.dart:23-30`) |
| `snake_case` files, existing dir layout | Followed (`integration_test/`, `test/core/`) |
| Explicit error handling | `cli_exit.dart` catch is intentional and documented; test guard uses `fail()` with context |
| Do not commit | Nothing committed by executors or reviewer |

---

## Findings

### WARN 1 — Teardown's SendExit is only as safe as the process-name guard
`tearDownAll` calls `BridgeService().killCli()` whenever the test body started, and `killCli()` sends `/SendExit` to the testnet API port regardless of which process is listening. If a CLI is listening under a name `pgrep -fl VerifiedXCore` does not match (for example a Core built from source under a different binary or DLL name), `_startCli` reattaches to it (`session_provider.dart:874-884`), the test still sets `cliLaunchedByTest = true`, and teardown exits the user's CLI. `LaunchedCli.terminate()` stays safe in that case; only the HTTP path is exposed.

With the shipped wallet and the Makefile's `run_cli_*` targets the name always matches, so this is a gap for non-standard setups, not the normal case.

Suggested fix (test-only, mirrors the app's own `_cliIsActive()` at `session_provider.dart:824`): in `setUpAll`, after the `pgrep` check, also probe `${Env.apiBaseUrl}/CheckStatus` (`http://localhost:17292/api/V1/CheckStatus` for testnet) with a short timeout and `fail()` if anything answers. That catches any listening CLI before the app can reattach, and it is the condition `killCli()` actually depends on.

### WARN 2 — `archive` downgraded from 3.3.6 to 3.3.2 in the production graph
`pubspec.lock` moves the direct main dependency `archive` from 3.3.6 to 3.3.2. Cause: the SDK's `integration_test` and `flutter_driver` packages in 3.7.12 pin `archive: 3.3.2` (`$HOME/fvm/versions/3.7.12/packages/integration_test/pubspec.yaml:18`), and pub resolves one version for the whole graph, dev dependencies included. The project constraint `^3.3.1` allows it, so pub did it silently.

This ships to users: `ZipDecoder`/`ZipEncoder` in `lib/core/utils.dart:207,266` (NFT asset zips) and `GZipDecoder` in `lib/features/nft/models/web_nft.dart:172` and `lib/features/btc/screens/tokenized_btc_detail_screen.dart:449`. Fixes lost between the two versions, from the package changelog: symlinks in ZIP archives and a ZipCrypto decryption fix (3.3.3), "Fix file content when decoding zips" (3.3.5), XZ decoding (3.3.6).

Options for the lead:
1. Add `dependency_overrides: archive: 3.3.6` to `pubspec.yaml` and re-run `pub get`. Pub honors overrides against SDK-package pins and prints a warning. Keeps production identical to before this phase.
2. Accept the downgrade knowingly and spot-check NFT asset zip extraction on desktop before the next release.

Either way this should be a conscious decision, not a side effect of a dev dependency.

### INFO 1 — `pgrep` is macOS/Linux only
On Windows `Process.run('pgrep', ...)` throws a `ProcessException` in `setUpAll`, which fails the test before the app starts. That is the safe direction, but the message would not say why. The test is macOS-scoped via `test_integration_macos`, so no change is needed now; worth a one-line comment if a Windows target is ever added.

### INFO 2 — `lib/main.dart` unchanged by this phase
The phase 1 diff does not touch `lib/main.dart`. During this review a phase 2 edit (an `enableWebSemanticsForAutomation()` call and its import) appeared on disk from a parallel executor. It is outside this phase and was not reviewed here.

### INFO 3 — `docs/plans/automation-a11y-plan.md` is untracked
The lead's plan file shows in `git status` as untracked. Not part of the phase deliverable; the lead should decide whether it is committed with phase 1.

---

## Files reviewed
- `lib/core/env.dart` (+8: const field and getter)
- `Makefile` (+11: three targets and a comment)
- `pubspec.yaml` (+2: `integration_test`), `pubspec.lock` (+43/-2, see WARN 2)
- `lib/features/bridge/utils/cli_exit.dart` (+11/-4, verified fix)
- `test/features/bridge/cli_exit_test.dart` (+17, regression test)
- `test/core/env_test.dart` (new)
- `integration_test/helpers.dart` (new), `test/integration_helpers_test.dart` (new)
- `integration_test/app_smoke_test.dart` (new)
- Read for context: `lib/main.dart` (as of the phase 1 diff), `lib/core/services/launched_cli.dart`, `lib/core/providers/session_provider.dart:807-990`, `lib/features/bridge/services/bridge_service.dart:346-370`, `lib/core/components/boot_container.dart`

## Not reviewed
- The integration smoke test was not executed by the reviewer (real CLI, real `~/rbxtest` data). Result accepted from exec-3 with the evidence in Task 3 item 6.
- Whether `flutter run -d web-server` with the automation define serves correctly (phase 2 verifies the web path).

## Recommendation
Proceed to phase 2. Before committing phase 1, decide on WARN 2 (override or accept). WARN 1 can be folded into phase 3, which already owns test isolation, or fixed now with the four-line probe described above.
