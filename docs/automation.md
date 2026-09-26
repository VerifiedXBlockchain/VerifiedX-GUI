# Automation

## Purpose

This document describes how to run the VFX GUI in a form that Claude (or any other tool) can drive for automated testing, on both targets, without upgrading Flutter from the pinned 3.7.12. The web wallet exposes a semantics tree that Claude in Chrome can read and click. The desktop app has an `integration_test` scaffold that boots the real app against the testnet Core CLI. The plan behind this is `docs/plans/automation-a11y-plan.md`.

## Web wallet

Start the dev server with `make run_web_automation` and open `http://localhost:42069/?automation=1` in a Chrome that has the Claude in Chrome extension. The target runs `flutter run -d web-server` (not `-d chrome`) with `TESTNET=true` and `AUTOMATION=true`, so an external browser can attach to it. A release build made with the same two defines and served statically from `build/web` (for example `python3 -m http.server 42069 --bind 127.0.0.1`) behaves the same way.

The `?automation` query parameter is read by a small script in `web/index.html` before `main.dart.js` loads. It wraps `document.createElement` so that the `flt-glass-pane` element the engine creates has no `attachShadow` property. The 3.7.12 engine then falls back to a light-DOM host (`flt-glass-pane > flt-element-host-node > flt-semantics-host`) instead of a shadow root, which is what lets a page reader traverse the semantics nodes. Without the parameter nothing is wrapped and the engine uses its shadow root as usual. One known limitation of the light-DOM host: screens that embed an `HtmlElementView` (the payment and on-ramp iframes under `lib/features/payment/`) rely on `<slot>` projection that only exists inside a shadow tree, so under `?automation` the iframe is expected not to render in place. Keep those screens out of automated flows; production without the parameter is unchanged.

The `AUTOMATION=true` dart-define sets `Env.isAutomation`. On web, `enableWebSemanticsForAutomation()` in `lib/core/automation/web_semantics.dart` runs after the first frame and clicks the engine's hidden `flt-semantics-placeholder` ("Enable accessibility") through `HtmlHelpers().enableSemantics()`, retrying up to ten times at 300 ms. That is the only way to turn semantics on in this engine version because `setSemanticsEnabled(true)` is ignored on web. The console prints `[automation] semantics placeholder clicked` when it worked, and the first `flt-semantics` nodes appear a frame or two later. On desktop the define switches the CLI and GUI data paths to an isolated folder (see "Desktop data isolation").

The web router uses hash URLs and rewrites the address to `http://localhost:42069/#./` right after load, which drops the query parameter. Automation mode is decided once, when the page loads, so the running page keeps it. Every fresh navigation or reload must include `?automation=1` again; reloading the rewritten URL brings the shadow root back, the semantics tree is still switched on by the define but the page reader cannot see it.

How Claude drives it, in light DOM (the parameter was present): `read_page` lists the semantics nodes as `button`, `textbox` and `text` entries, `find` locates them by description, and clicks on their refs go through the extension's real pointer input, which Flutter handles through its own hit testing. Typing into a focused textbox through the extension lands in the Flutter field.

How Claude drives it when the tree is inside the shadow root, or when it needs viewport rectangles or a tap on something that is not a button: inject `tool/automation/flt_semantics.js` with the `javascript_tool`. It defines `window.fltA11y` and works in both DOM shapes:

- `fltA11y.status()` returns `{mode, visible, hostFound, nodeCount, hint}`. Check it first: `visible: false` means Chrome has paused frames for the tab (see below).
- `fltA11y.list()` returns every labelled node as `{id, role, label, rect: {x, y, w, h}, hasInput}` (plus `value` for text fields). The rect is in CSS viewport pixels; the extension's screenshot frame may use a different scale, so prefer `tap` over a coordinate click.
- `fltA11y.click(label)` dispatches a DOM click on the node whose `aria-label` equals the label, falling back to a case-insensitive "contains" match, and returns `{ok, id, label, hint}`. Only nodes with `role="button"` react. The engine drops synthetic clicks for 500 ms after any real pointer or keyboard event (it flips to pointer-events gesture mode and back after that idle time), so `ok: true` only means the event was dispatched. If nothing happened, keep the mouse off the page, wait about 600 ms and retry, or use `tap`.
- `fltA11y.tap(label)` dispatches a synthetic `pointerdown`/`pointerup` pair at the node's centre on the glass pane. That goes through Flutter's hit testing, does not depend on the gesture mode, and also works on `text` nodes such as the login sheet tiles.
- `await fltA11y.type(label, text)` focuses the text field, waits up to 2 s for the engine to attach its editing connection (it does so in the first semantics update after the framework focused the field), then sets the value and fires an `input` event. It resolves `ok: false` with a hint when the connection never came.
- `fltA11y.root()` returns the `flt-semantics-host` element, `fltA11y.mode()` reports `light`, `shadow` or `none`, and `fltA11y.enable()` clicks the placeholder for a build that did not do it itself.
- `fltA11y.find(label)` returns the matching `flt-semantics` DOM node (or `null`) for scripts that need the element itself.

Chrome pauses `requestAnimationFrame` for a hidden tab (another tab in front, or the window fully covered), and Flutter then renders nothing: a click or tap is accepted, but the screen and the semantics tree only change once frames run again. Keep the automation tab visible. A screenshot through the extension forces a few frames even while the tab stays hidden, which is enough to flush a pending change and is what the verification below relied on.

## Desktop (macOS)

`make test_integration_macos` runs `flutter test integration_test -d macos` with `TESTNET=true` and `AUTOMATION=true`. `make run_macos_automation` runs the app itself with the same defines. Both need a build of the macOS runner.

The smoke test in `integration_test/app_smoke_test.dart` refuses to run while a Core CLI is already up: its `setUpAll` runs `pgrep -fl VerifiedXCore` and fails with the matching process lines, because a second CLI would open the same databases. Quit the VFX wallet before running it. The test then starts the app through `main()`, waits for the boot screen, checks the `[TESTNET]` label, waits for the launched CLI to answer, and in teardown asks that CLI to exit. A run takes about 40 seconds on a warm build.

Agent shells do not have CocoaPods on `PATH`, so prefix the desktop commands with `LANG=en_US.UTF-8 PATH="$HOME/.rbenv/versions/3.4.4/bin:$PATH"`. Every macOS build also lets CocoaPods rewrite `macos/Runner.xcodeproj/project.pbxproj` (four empty-array lines); that change is noise and is reverted with `git checkout macos/Runner.xcodeproj/project.pbxproj`, never committed.

Testnet data on macOS lives under `~/rbxtest/` (`DatabasesTestNet`, `ConfigTestNet`, `AssetsTestNet`, ...), see `lib/core/utils.dart`. Until the data isolation below lands, every desktop integration run launches the CLI against those real folders.

## What Claude sees

Verified on 2026-09-26 with the release build served from `build/web` and `?automation=1`. `flt-glass-pane` has no shadow root and one `flt-element-host-node` child, the placeholder is consumed automatically, and the landing screen produces 11 `flt-semantics` nodes. Claude in Chrome's `read_page` lists `button "Login / Create Account"`. After a ref click on it, the import sheet shows `textbox "VFX Private Key"`, `button "Cancel"` and `button "Submit"`, and text typed through the extension appears both in the textarea value and in the rendered field. Without the parameter the shadow root is back and `read_page` is empty.

The same session through the helper: `fltA11y.list()` on the landing screen returns `img ""`, `text "Verified"`, `text "X"`, `text "Web Wallet Testnet 7.0.2"`, `button "Login / Create Account"` and `text "TESTNET"`, each with its rect. `fltA11y.click('Login / Create Account')` opens the login sheet, whose tiles list as `text "Email & Password"`, `text "Mnemonic (HD account)"`, `text "VFX Private Key"`, `text "Bitcoin Private Key / WIF Key"` plus a full-screen `text "Dismiss"` scrim. `fltA11y.tap('VFX Private Key')` opens the Import Wallet dialog (`group "Dismiss"`, `text "Import Wallet"`, `textbox "VFX Private Key"`, `button "Cancel"`, `button "Submit"`), whose field is autofocused, and `await fltA11y.type('VFX Private Key', 'xyz')` renders `xyz` in the Flutter field. `fltA11y.click('Cancel')` closes it.

Tile-style tap targets on the login sheet (`Email & Password`, `Mnemonic (HD account)`, ...) currently surface as `text` rather than `button`, because they are `InkWell`/`GestureDetector` targets without button semantics, so `click` cannot reach them and `tap` is needed. Phase 4 of the plan adds the labels and keys that turn them into buttons.

## Desktop data isolation (automation builds)

The Core CLI has no data-folder argument or environment variable. On macOS it derives every folder from the user's home directory (`~/rbxtest/...` on testnet), which .NET resolves from `$HOME`. An automation build (`--dart-define AUTOMATION=true`, set by `make test_integration_macos` and `make run_macos_automation`) launches the CLI with `HOME` pointed at `~/Library/Application Support/vfx-gui-automation`, so the CLI writes to `.../vfx-gui-automation/rbxtest/{DatabasesTestNet,ConfigTestNet,...}` and the GUI's own log, config and media paths (`lib/core/data_home.dart`) resolve there too. The real `~/rbxtest` is never touched; verified on 2026-09-26 by comparing mtimes before and after a smoke run.

- First run in a fresh folder downloads the PLONK params (about 250 MB) and starts syncing the testnet chain into the isolated folder. The folder persists between runs and grows with the sync; delete it to start over.
- The smoke test refuses to run when a `VerifiedXCore` process exists or anything answers on `http://localhost:17292/api/V1/CheckStatus/`, and prints a loud warning when run without `AUTOMATION=true` (it would then use the real `~/rbxtest`; back that folder up first).
- Not isolated: the GUI's own preferences (NSUserDefaults for the app's bundle id, e.g. the stored password hash and encryption flags) are shared with the installed wallet because the pinned `shared_preferences` has no prefix API. Windows has no isolation at all.
- Launching the CLI by hand with a custom `HOME`: create the folder first. .NET treats a missing home directory as empty and the CLI crashes trying to write `/rbxtest`.

## Flutter Driver (phase 6, placeholder)

To be filled in by phase 6: `make run_macos_driver`, `lib/main_automation.dart`, `tool/drive.dart` commands, and how to get the VM service URL from the `flutter run` output.
