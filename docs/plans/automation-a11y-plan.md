# Automation & accessibility plan

Branch: `feat/automation-a11y` (off `testnet`). Lead: orchestrator session, 2026-09-26.

## Goal

Make the VFX GUI drivable by Claude for automated testing, on both targets, without upgrading Flutter (pinned 3.7.12):

- Web wallet: a semantics tree Claude in Chrome can read, enabled automatically in an automation build.
- Desktop (macOS): `integration_test` scaffolding, a Flutter Driver flavor for interactive driving, and isolation so tests never touch the real testnet databases.
- Labels and keys on interactive controls so finders work by label or key instead of pixels.

## Hard constraints (read before touching anything)

- Flutter 3.7.12. `fvm` is NOT on PATH in agent shells. Use the absolute SDK binary: `$HOME/fvm/versions/3.7.12/bin/flutter` (and `.../bin/dart`). Makefile targets keep the project's `fvm flutter ...` spelling.
- Baseline (recorded 2026-09-26 on `testnet` before phase 1): `flutter analyze` reports 390 issues, none of them errors; `flutter test` is 177 passing and 1 pre-existing failure (`test/widget_test.dart`, the stale template counter test). Do not add analyzer issues or test failures beyond that baseline.
- Follow `.claude/context/conventions.md`. In particular: user-facing strings (tooltips included) are l10n keys in BOTH `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` with an `@key` description, then `flutter gen-l10n`; generated files under `lib/l10n/generated/` are committed. Reuse the feature's existing 3-letter key prefix (grep the ARB for the feature's screen names to find it).
- Do not commit. The lead commits after review.
- Do not refactor while building. Note anything worth refactoring in your report instead.
- Write tests alongside implementation where a unit test is meaningful (e.g. `Env.isAutomation`, any pure helper).
- Web-only code uses the conditional-import pattern in `lib/utils/html_helpers.dart` (`_web.dart` + `_mock.dart` + interface). Never import `dart:html` from code that compiles for desktop.
- Nothing may start a second Core CLI while the user's wallet is running. Before launching the desktop app or an integration test, check for a running CLI process (find the binary name in `lib/core/providers/session_provider.dart` near the `Shell(` call, then `pgrep -f`) and stop with a clear message if one is running.

## Commands

- Analyze: `$HOME/fvm/versions/3.7.12/bin/flutter analyze`
- Unit tests: `$HOME/fvm/versions/3.7.12/bin/flutter test`
- l10n: `$HOME/fvm/versions/3.7.12/bin/flutter gen-l10n`
- Web dev server (after phase 1): `make run_web_automation`, then open `http://localhost:42069/?automation=1`
- macOS integration tests (after phase 1): `make test_integration_macos`

## Background facts (verified by the lead)

- The app has zero explicit `Semantics(` widgets and 35 tooltips. Flutter still emits a semantics tree from standard widgets once semantics are on; icon-only buttons come out unlabeled.
- Flutter web (3.7.12) keeps semantics OFF until the hidden `flt-semantics-placeholder` ("Enable accessibility") is clicked. A synthetic `.click()` on it works. The Dart API `setSemanticsEnabled(true)` is ignored by this engine version on web.
- In 3.7.12 the whole engine DOM, including `flt-semantics-host`, lives in the `flt-glass-pane` shadow root. Claude in Chrome's page reader does not traverse it. The engine's `FlutterViewEmbedder._createHostNode` falls back to `ElementHostNode` (light DOM, a `flt-element-host-node` child of the glass pane) when the root element has no `attachShadow` property.
- macOS embedder (3.7.12) only creates its accessibility bridge when an AX client sets `AXEnhancedUserInterface` on the app. Do NOT force semantics on from Dart in the macOS build: the embedder's `updateSemantics:` asserts the bridge exists and has no guard.
- Desktop CLI launch: `lib/core/providers/session_provider.dart` builds `options` and runs the CLI through `Shell.run` (binary `VerifiedXCore` inside `/Applications/VFXWallet.app`). Testnet data lives under `~/rbxtest/` on macOS (`DatabasesTestNet`, `ConfigTestNet`, `AssetsTestNet`, ...; mainnet under `~/vfx/`), see `lib/core/utils.dart` and `open_log_button.dart`. Until phase 3 lands, every desktop integration run touches the user's real `~/rbxtest/DatabasesTestNet`.
- macOS builds from agent shells need CocoaPods on PATH: prefix commands with `LANG=en_US.UTF-8 PATH="$HOME/.rbenv/versions/3.4.4/bin:$PATH"`. CocoaPods also rewrites `macos/Runner.xcodeproj/project.pbxproj` (4 empty-array lines) on every build; revert that file, do not include it in phase changes.
- `Env` reads dart-defines with `const String.fromEnvironment('TESTNET') == 'true'` (`lib/core/env.dart`).
- Key convention: `lib/core/components/buttons.dart` builds `Key('elevated:$key')` style keys; follow whatever it does.

## Phases

### Phase 1: Foundation (tasks 1 and 3 in parallel; task 1 owns the Makefile)

**Task 1: Automation flag + Makefile targets.**
- `lib/core/env.dart`: add `AUTOMATION` dart-define → `Env.isAutomation`, same style as `TESTNET`/`DEVNET`.
- Unit test for the getter's default (false).
- Makefile targets (keep `fvm flutter` spelling, and put them next to the existing run/build targets):
  - `run_web_automation`: `-d web-server --web-port 42069 --dart-define TESTNET=true --dart-define AUTOMATION=true` (web-server, not chrome, so an external Chrome with the Claude extension can attach).
  - `run_macos_automation`: `-d macos --dart-define TESTNET=true --dart-define AUTOMATION=true`, plus whatever the desktop build needs to select testnet (see `Env.setTestnetFromArgs` in `lib/main.dart`; `flutter run --dart-entrypoint-args` may be needed).
  - `test_integration_macos`: `test integration_test -d macos --dart-define TESTNET=true --dart-define AUTOMATION=true`.
- Acceptance: analyze clean, new test passes, `make -n <target>` prints the expected command.

**Task 3: Desktop integration test scaffold.** (does NOT touch the Makefile)
- Add `integration_test` (sdk: flutter) to dev_dependencies.
- `integration_test/app_smoke_test.dart`: `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`, start the app the same way `lib/main.dart` does (extract a reusable `bootstrap()`/`runVfxApp()` if `main()` cannot be called directly; keep the change minimal), and assert the first desktop screen renders. Do NOT use `pumpAndSettle` for the boot (spinners never settle); write a small `pumpUntilFound(finder, timeout)` helper in `integration_test/helpers.dart`.
- The test must fail fast with a clear message if a Core CLI is already running (see constraints).
- Run it once on this machine: `$HOME/fvm/versions/3.7.12/bin/flutter test integration_test/app_smoke_test.dart -d macos --dart-define TESTNET=true --dart-define AUTOMATION=true`. Report the result honestly, including how long boot took and whether the CLI was launched from the build.
- Acceptance: the smoke test runs and passes locally, or the report states exactly why it cannot yet.

### Phase 2: Web semantics (task 2, then task 4)

**Task 2: Semantics on at startup + light-DOM spike.**
- `web/index.html`: before `main.dart.js` loads, if `new URLSearchParams(location.search).has('automation')`, make the engine take its light-DOM path. Preferred: wrap `document.createElement` so an element created with tag `flt-glass-pane` gets `attachShadow = undefined`. Fallback if that fails: delete `Element.prototype.attachShadow` under the same guard. Nothing changes when the param is absent.
- Dart side, under `Env.isAutomation && kIsWeb`, after the first frame: find `flt-semantics-placeholder` (search the glass pane's `shadowRoot` if present, else the glass pane element itself) and `.click()` it. Implement through the `html_helpers` conditional-import pattern (add a method to the interface, web and mock implementations). Wire it from `lib/main.dart` or the root widget with a post-frame callback.
- Manual verification by the executor: `make run_web_automation`, open `http://localhost:42069/?automation=1` in a normal Chrome, confirm in DevTools that `document.querySelectorAll('flt-semantics').length > 0` within ~10 s without clicking anything, that text input works, and that a payment iframe screen (`HtmlElementView`, see `lib/features/payment/components/`) still renders. Also confirm the app is unchanged without the param.
- The lead verifies with Claude in Chrome that `read_page` lists the nodes. Report the DOM shape you observed.
- Acceptance: nodes in light DOM with the param, none of the above regressions, analyze clean.
- **Lead verification 2026-09-26 (release build served from `build/web` on :42069):** with `?automation=1`, `flt-glass-pane` has no shadow root and one child `flt-element-host-node`; the placeholder is consumed automatically; 11 `flt-semantics` nodes on the landing screen; Claude in Chrome `read_page` lists `button "Login / Create Account"`, then after ref clicks `textbox "VFX Private Key"`, `button "Cancel"`, `button "Submit"`; typing through the extension lands in the Flutter field (textarea value and rendered text both matched). Without the param the shadow root is back and `read_page` is empty. Caveat: the hash router rewrites the URL to `/#./` right after load, so the param must be present on every fresh navigation (reload keeps the rewritten URL and loses automation mode). Icon-only or tile-style tap targets on the login sheet (`Email & Password`, `Mnemonic (HD account)`, ...) surface as `text`, not `button`, which is what phase 4 fixes. Implementation note: the placeholder is clicked with a synthetic MouseEvent aimed at its viewport midpoint. That is required only by the engine's `MobileSemanticsEnabler` (mobile user agents); `DesktopSemanticsEnabler` (Chrome on macOS) accepts any click targeted at the placeholder, so the same event works for both. Review WARN 1: `HtmlElementView` screens (payment iframes) are expected not to render in place under `?automation` because the light-DOM host has no `<slot>` projection; automation sessions must not include those screens, and production without the param is unchanged.

**Task 4: Claude in Chrome helper + doc.**
- `tool/automation/flt_semantics.js`: functions to list labeled nodes with `role`, `aria-label`, and viewport rect; click a node by label; focus/type into an input by label. Must work for both DOM shapes (shadow root and light DOM).
- `docs/automation.md`: how to run the automation web build, the URL param, how Claude drives it (page reader when light DOM works, the JS helper otherwise), and the desktop commands from phase 1. Keep it short and factual.
- Acceptance: doc matches what phase 1 and task 2 actually shipped.

### Phase 3: Desktop data isolation (task 5)

- Find out whether the Core CLI accepts a data-folder override. Check the Core repo (`gh api repos/VerifiedXBlockchain/VerifiedX-Core/contents/...` or raw GitHub; start with `Program.cs` / startup argument parsing) and the existing `options` list in `session_provider.dart`. Check the CLI first before assuming anything.
- If it does: when `Env.isAutomation`, pass a dedicated folder (e.g. `~/Library/Application Support/vfx-gui-automation/testnet`) so integration tests never touch `~/Documents/DatabasesTestNet`. Make sure the GUI's own desktop storage (Hive boxes, media folders under `getApplicationDocumentsDirectory`) follows the same switch where it matters for tests.
- If it does not: document the manual backup step in `docs/automation.md` and make the integration test print a loud warning at start.
- Phase 1 review carry-over (WARN 1): the smoke test's teardown sends `/SendExit` to whatever answers on the testnet API port. In `setUpAll`, also probe `${Env.apiBaseUrl}/CheckStatus` (mirror `_cliIsActive()` in `session_provider.dart`) and `fail()` if anything answers, so a CLI running under another process name is never adopted and then exited by the test.
- Acceptance: a fresh automation run creates data only under the isolated folder (show the directory listing in the report), analyze clean.

### Phase 4: Labels and keys, core flows (task 6)

Scope: `lib/features/{auth,home,navigation,send,receive,wallet,config,root}` (about 27 files with tappable icons).
- Every `IconButton` without a `tooltip` gets one (l10n key, both ARBs, `gen-l10n`).
- Every icon-only `InkWell`/`GestureDetector` tap target gets `Semantics(label: ..., button: true, child: ...)` or an equivalent existing pattern.
- Primary controls on these flows (unlock/password, main nav items, send form fields and submit, receive address copy) get stable keys following `buttons.dart`.
- Do not change layout, behavior, or existing strings.
- Acceptance: analyze clean, `gen-l10n` output committed, no visual change (spot-check on the web dev server), report lists every file touched.

### Phase 5: Labels, full sweep (task 7, three sequential waves, one executor each)

Same rules as phase 4 over the remaining `lib/features/*` directories. Waves are sequential because both ARB files are shared:
- Wave A: `btc`, `btc_web`, `privacy`, `token`, `nft`, `smart_contracts`, `sc_property`.
- Wave B: `adnr`, `asset`, `beacon`, `bridge`, `chat`, `datanode`, `dst`, `encrypt`, `faucet`, `genesis`, `hd`, `health`, `keygen`, `metrics`, `misc`, `moonpay`.
- Wave C: `node`, `operations`, `payment`, `price`, `raw`, `remote_info`, `remote_shop`, `reserve`, `startup`, `transactions`, `validator`, `voting`, `web`, `web_shop`, `adjudicator`, `block`, `debug`, `easter`, `global_loader`, `image_sequencer`, `inspector`, `mother`.
- Acceptance per wave: analyze clean, ARB parity kept, report lists every file touched.

### Phase 6: Flutter Driver flavor (task 8)

- Add `flutter_driver` (sdk: flutter) to dev_dependencies.
- `lib/main_automation.dart`: calls `enableFlutterDriverExtension()` then the shared app bootstrap from phase 1/3. Production `main.dart` must not import the driver extension.
- `tool/drive.dart`: a small Dart CLI (run with the pinned `dart`) that connects with `FlutterDriver.connect(dartVmServiceUrl: ...)` and supports at least: `tap-text`, `tap-key`, `tap-label`, `type`, `get-text`, `screenshot <path>`, `wait-for-text`. Print clear errors.
- Makefile: `run_macos_driver` (`-t lib/main_automation.dart -d macos` with the automation and testnet defines).
- `docs/automation.md`: a section on the driver flow, including how to get the VM service URL from `flutter run` output.
- Phase 3 review carry-over (WARN 1): desktop `SharedPreferences` (NSUserDefaults) are still shared with the installed wallet, so a driver flow that sets a password would write the real wallet's prefs. Bump `shared_preferences` to `^2.1.2` (fits Dart 2.19.6; check `shared_preferences_foundation` with `pub upgrade --dry-run`) and call `SharedPreferences.setPrefix('automation.')` under `Env.isAutomation` before the first `getInstance`. Document it in the data isolation section.
- Phase 3 review carry-over (INFO): the smoke test's outer `Timeout` (5 min) can fire before `pumpUntilGone`'s 3-min pumped-time budget under load, hiding the helper's diagnostic message; raise the outer timeout to 8 min.
- Acceptance: with the app running via `run_macos_driver`, `tool/drive.dart` can tap a labeled control (from phase 4 if merged, otherwise any existing labeled control) and read text back. Show the session transcript in the report.

## Verification reports

Reviewer writes `docs/verification/phase-N-<name>.md` (existing convention in `docs/verification/`). Verdict: PASS, PASS WITH WARNINGS, or FAIL.
