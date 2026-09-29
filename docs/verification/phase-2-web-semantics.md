# Phase 2 Verification — Web Semantics (tasks 2 and 4)

**Phase:** 2 — Semantics on at startup, light-DOM shim, Claude in Chrome helper and doc
**Plan:** `docs/plans/automation-a11y-plan.md`
**Repo:** vfx-gui
**Branch:** `feat/automation-a11y` (uncommitted working tree on top of `466d1cae`; phase 3 files in the same tree were ignored)
**Base:** `testnet`
**Verifier:** reviewer agent (spawned by the orchestrator lead; no commit)
**Date:** 2026-09-26

## Verdict: **PASS WITH WARNINGS**

Task 2 and Task 4 meet their acceptance criteria as far as they were verified: the `index.html` shim is inert without the query parameter, the Dart path is compiled out of desktop builds by a const guard and never imports `dart:html` outside the existing conditional-import files, the light-DOM tree and Claude in Chrome reading were confirmed by the lead in a real browser, the six unit tests pass, and analyze is at the 390 baseline with an issue set identical to the phase 1 run. Two warnings. First, the plan's manual check that a payment `HtmlElementView` screen still renders under `?automation=1` was not reported by anyone, and the engine source predicts it does not render in place in light-DOM mode (automation sessions only; production is unaffected). Second, the comments justifying the synthetic MouseEvent deviation describe the engine's mobile enabler as if it were the desktop one; the code works on both, but the stated reason is wrong for Chrome on macOS.

---

## Checks run

| Check | Result |
|---|---|
| `flutter analyze` | 390 issues, 0 errors. Issue set byte-identical to the phase 1 run (diff empty). Only hit mentioning `html_helpers` is a pre-existing unused import in `btc_web_transaction_list_provider.dart` |
| `flutter test test/core/automation test/utils` | 6 passed, 0 failed |
| `node --check tool/automation/flt_semantics.js` | Syntax OK |
| Engine source read | `semantics_helper.dart`, `embedder.dart`, `host_node.dart`, `platform_views/*.dart`, `platform_dispatcher.dart`, `canvaskit/embedded_views.dart` under `$HOME/fvm/versions/3.7.12/bin/cache/flutter_web_sdk/flutter_web_sdk/lib/_engine/engine/` |
| Browser verification | Not repeated; the lead's record under Task 2 in the plan and exec-4's helper check were accepted |

Lead-reported full suite: 197 passing, only the pre-existing `test/widget_test.dart` failing.

---

## Task 2: Semantics on at startup + light-DOM spike

### 1. `web/index.html` shim
**PASS.** `web/index.html:85-98`. An IIFE returns immediately unless `URLSearchParams(location.search).has("automation")`, so nothing is wrapped without the parameter. With it, `document.createElement` is wrapped and only an element whose tag is `flt-glass-pane` gets an own `attachShadow = undefined`. The engine's `_createHostNode` (`embedder.dart:359-366`) tests `getJsProperty(root, 'attachShadow') != null`, so the own property shadows the prototype method and the engine takes the `ElementHostNode` branch (`host_node.dart:149-187`), which appends a `flt-element-host-node` child. That is the DOM shape the lead observed. The shim is at line 85, ahead of the `main.dart.js` loader at line 105, so it is installed before the engine creates any element.

### 2. Dart side under `Env.isAutomation && kIsWeb`
**PASS.**
- `lib/core/automation/web_semantics.dart:31-38`: `enableWebSemanticsForAutomation()` returns unless `kIsWeb && Env.isAutomation`, both compile-time constants, then registers a post-frame callback. `lib/main.dart:63` calls it right after `runApp`, so the binding exists.
- `_clickSemanticsPlaceholder` (lines 40-45) retries `HtmlHelpers().enableSemantics` through `retryUntilTrue` (10 attempts, 300 ms) and prints the outcome. `retryUntilTrue` (lines 9-23) is a pure helper with four tests, including a `fakeAsync` test that the delay is not applied after the last attempt.
- `lib/utils/html_helpers_web.dart:52-81`: finds `flt-glass-pane`, searches its `shadowRoot` when present and the element itself otherwise (the placeholder sits under `flt-element-host-node`, and `querySelector` is recursive), then dispatches a `click` MouseEvent on the placeholder. `html_helpers_mock.dart:34-37` returns false. The interface method is documented at `html_helpers_interface.dart:9-12`.
- The lead observed the placeholder consumed automatically and 11 `flt-semantics` nodes on the landing screen.

### 3. Deviation: synthetic MouseEvent at the midpoint instead of `.click()`
**Works, but the justification is only half right (WARN 2).** The engine picks its enabler by operating system: `semantics_helper.dart:42-43` uses `DesktopSemanticsEnabler` when `isDesktop` (`browser_detection.dart:182`, macOS/Windows/Linux user agents) and `MobileSemanticsEnabler` otherwise.
- `DesktopSemanticsEnabler.tryEnableSemantics` (file lines 130-170): accepts `click`, `keyup`, `keydown`, `mouseup`, `mousedown`, `pointerdown`, `pointerup`, and the only condition is `event.target == _semanticsPlaceholder`. There is no offset or midpoint check. A bare `placeholder.click()` satisfies it. Its placeholder is a 1x1 px element at (-1,-1).
- `MobileSemanticsEnabler.tryEnableSemantics` (file lines 247-367): for `click` it takes `click.offset` (element-relative) and requires it within 1 px of `rect.left + width/2`, `rect.top + height/2` (viewport-absolute), then enables after a 300 ms timer. Its placeholder covers the whole glass pane. A bare `.click()` has offset (0,0) and is ignored here.

The shipped arithmetic (`clientX = rect.left + midX`, i.e. offset = absolute midpoint) is exactly what the mobile comparison needs, and on desktop the target check passes regardless, so the deviation is correct for both enablers and harmless. What is wrong is the explanation in `html_helpers_web.dart:68-71`, `flt_semantics.js:131-134` and the executor's note relayed by the lead: they attribute the midpoint requirement to the engine in general or to `DesktopSemanticsEnabler`. See WARN 2 for the suggested wording.

### 4. Conditional-import wiring, no `dart:html` on desktop
**PASS.** `lib/utils/html_helpers.dart:1` is the pre-existing `import "html_helpers_web.dart" if (dart.library.io) "./html_helpers_mock.dart"`. Desktop and the VM test runner have `dart:io`, so they compile the mock; only `html_helpers_web.dart` imports `dart:html`, as before. `web_semantics.dart` imports `html_helpers.dart`, never `dart:html`. `test/utils/html_helpers_test.dart` proves the mock is what the VM sees (`enableSemantics()` is false).

### 5. No effect on production builds
**PASS.**
- Without `?automation`: the shim returns before wrapping anything; the Dart call is compiled out of every build without `AUTOMATION=true`; the lead confirmed the shadow root is back and `read_page` is empty.
- With `?automation` on a production build (no define): only the DOM shape changes. Semantics stay off because nothing clicks the placeholder, and the engine's own `ElementHostNode` fallback is what runs. No data or behaviour is exposed. This is the design the plan asked for. See WARN 1 for the one screen type that behaves differently under the parameter.

### 6. Manual verification items from the plan
| Item | Status |
|---|---|
| `flt-semantics` nodes appear within ~10 s without clicking | Lead: placeholder consumed automatically, 11 nodes on the landing screen |
| Text input works | Lead: typing through the extension lands in the Flutter field; exec-4: `fltA11y.type` renders in the field |
| Payment iframe screen (`HtmlElementView`) still renders | **Not reported by anyone.** Engine source predicts it does not render in place under the parameter (WARN 1) |
| App unchanged without the parameter | Lead: shadow root back, `read_page` empty |
| Claude in Chrome `read_page` lists nodes | Lead: `button "Login / Create Account"`, then `textbox "VFX Private Key"`, `button "Cancel"`, `button "Submit"` |
| Analyze clean | 390, 0 errors |

### 7. Tests alongside code
**PASS.** `test/core/automation/web_semantics_test.dart` (5 tests) and `test/utils/html_helpers_test.dart` (1 test). The automation branch of `enableWebSemanticsForAutomation` cannot run on the VM; the guard and the pure retry helper are what is testable, and both are covered.

---

## Task 4: Claude in Chrome helper + doc

### 1. `tool/automation/flt_semantics.js`
**PASS.**
- Both DOM shapes: `scope()` (lines 79-85) returns `pane.shadowRoot || pane`, and every lookup goes through it. `mode()` reports which.
- Globals: a strict-mode IIFE; the only thing written to `window` is `fltA11y` (line 365). No other globals, no storage, no navigation, no network.
- `list()` returns `{id, role, label, rect:{x,y,w,h}, hasInput, value?}` with the rect from `getBoundingClientRect()`; `click(label)`, `tap(label)`, `type(label, text)` match the plan's list/click/type requirement. `find()` does an exact `aria-label` match, then a case-insensitive contains match, preferring buttons and text fields; that is a sensible tie-break for a page with a heading and a button of the same text.
- `tap()` dispatches a `pointerdown`/`pointerup` pair on the glass pane; `find()` returning a node guarantees the pane exists, so the `pane.dispatchEvent` calls cannot hit null.
- `type()` focuses the editable, polls `editingAttached()` (a non-bubbling, cancelable synthetic `mousedown` whose `preventDefault` reveals the engine's editing strategy without reaching the glass pane), then sets the value and fires `input`. exec-4 confirmed it renders in the Flutter field.
- The gesture-mode and hidden-tab caveats in the header match the engine behaviour described in the plan's background and are repeated in every action's `hint`.
- `enable()` has the same midpoint arithmetic and the same comment problem as the Dart side (WARN 2).
- `find` is exported but not listed in the header comment or in `docs/automation.md` (INFO 1).

### 2. `docs/automation.md`
**PASS.** Read against what shipped:
- Web section: `make run_web_automation`, the `?automation=1` URL, the shim's mechanism, the define, the retry (ten times at 300 ms matches the code defaults), the console line, the hash-router caveat the lead found. All accurate.
- Helper section: every listed function and return shape matches the JS. The `click` limitation to `role="button"` and the `tap` fallback for tile-style targets match the code and the lead's observation.
- Desktop section: matches phase 1 (`pgrep -fl VerifiedXCore`, `[TESTNET]` label, teardown exit, about 40 s, `~/rbxtest/`, CocoaPods `PATH` prefix, pbxproj noise).
- "What Claude sees": the lead's and exec-4's transcripts.
- Placeholders for phase 3 (data isolation) and phase 6 (Flutter Driver) are present.
- One line per paragraph throughout, bullets one line each. No hard wrapping.
- Missing: the `HtmlElementView` limitation under the parameter (WARN 1) and the `fltA11y.find` export (INFO 1).

---

## Conventions and hard constraints

| Rule | Status |
|---|---|
| Flutter 3.7.12, absolute SDK binary in agent shells | Followed |
| No new analyzer issues (baseline 390) | 390, identical issue set to phase 1 |
| No new test failures | Only the pre-existing `test/widget_test.dart` |
| Tests alongside code | Yes |
| No refactors while building | None; the html_helpers change is additive (three new methods) |
| Web-only code through the `html_helpers` conditional-import pattern; never `dart:html` in desktop code | Followed |
| `kIsWeb` for platform branching | `web_semantics.dart:32` |
| `snake_case` files, `lib/core/` for shared code | `lib/core/automation/web_semantics.dart` |
| Explicit error handling | Placeholder-not-found is reported by return value and logged; no swallowed exceptions |
| `print` allowed (`avoid_print` disabled) | Used only on the automation path |
| Do not commit | Nothing committed |

---

## Findings

### WARN 1 — `HtmlElementView` screens under `?automation=1` are unverified and predicted not to render in place
The plan's Task 2 manual checks include "a payment iframe screen (`HtmlElementView`) still renders". Neither the executor's note, the lead's browser record, nor exec-4's helper check mentions it. The engine source says it cannot work in light-DOM mode: `platform_dispatcher.dart:536-538` appends every platform view's `flt-platform-view` wrapper to `glassPaneElement` (light DOM), and the scene places a `<slot name="flt-pv-slot-N">` inside the host node (`platform_views/slots.dart:39-45`, used by both `html/platform_view.dart:19` and `canvaskit/embedded_views.dart:186`). A `<slot>` only projects when it lives in a shadow tree. With `ElementHostNode` the slot is in the light DOM and projects nothing, so the iframe wrapper renders as an ordinary child of `flt-glass-pane` in normal flow, not at the widget's position. This affects the three payment containers in `lib/features/payment/components/` (Banxa, crypto.com, onramp) only when the parameter is present. Production without the parameter is unchanged.

Suggested handling: the lead confirms in the existing browser session by opening a payment screen with `?automation=1` (two minutes), then `docs/automation.md` gets one sentence in the web section stating that `HtmlElementView` screens do not render in place in automation mode and must not be part of automated flows. No code change is needed for this phase.

### WARN 2 — The midpoint-click comments describe the wrong enabler
`html_helpers_web.dart:68-71` says "The engine only enables semantics when the click's element-relative offset lands within 1px of the midpoint ... so a bare click() (offset 0,0) is ignored", and `flt_semantics.js:131-134` says the same. Against the 3.7.12 engine that is true of `MobileSemanticsEnabler` (mobile user agents) and false of `DesktopSemanticsEnabler` (Chrome on macOS, which the automation flow uses), where any click whose target is the placeholder enables semantics. The code is correct for both enablers, so nothing breaks, but a maintainer reading the comment will believe the `rect.left + midX` arithmetic is load-bearing on desktop and will not understand why it adds the origin twice.

Suggested wording for both comments: "The engine's MobileSemanticsEnabler (mobile user agents) only accepts a click whose element-relative offset is within 1 px of the placeholder's viewport midpoint, so it compares offset against an absolute point; aim clientX/Y at rect.left + midX to satisfy it. DesktopSemanticsEnabler accepts any click targeted at the placeholder, so the same event works there too." The plan's Task 2 note should say the same so the record is accurate.

### INFO 1 — `fltA11y.find` is exported but undocumented
`flt_semantics.js:374` exports `find`, which is useful for scripting (returns the DOM node). It is missing from the header comment (lines 6-13) and from the function list in `docs/automation.md:21-26`. One line in each.

### INFO 2 — `fake_async` is used from a transitive dependency
`test/core/automation/web_semantics_test.dart:1` imports `package:fake_async`, which comes in through `flutter_test`. The project disables `depend_on_referenced_packages`, so analyze does not flag it, and other tests already rely on the same setup. No action needed; noted so it is not mistaken for a new dev dependency.

### INFO 3 — The parameter is honoured on production builds too
`?automation=1` on the deployed wallet switches the engine to the light-DOM host for that page load. Semantics stay off (no define, nothing clicks the placeholder) and no data is exposed, so the only visible effect would be WARN 1 on payment screens. The plan asked for exactly this design ("Nothing changes when the param is absent"); recorded here so it is a known property, not a surprise.

---

## Files reviewed
- `web/index.html` (+22: guarded shim, lines 80-98)
- `lib/utils/html_helpers_interface.dart` (+5), `lib/utils/html_helpers_web.dart` (+31), `lib/utils/html_helpers_mock.dart` (+6)
- `lib/core/automation/web_semantics.dart` (new, 45 lines)
- `lib/main.dart` (+3: import and one call)
- `test/core/automation/web_semantics_test.dart` (new, 5 tests), `test/utils/html_helpers_test.dart` (new, 1 test)
- `tool/automation/flt_semantics.js` (new, 376 lines)
- `docs/automation.md` (new)
- `docs/plans/automation-a11y-plan.md` (lead's verification record under Task 2, read only)
- Engine sources listed under "Checks run"

## Not reviewed
- Browser behaviour (light DOM shape, `read_page`, typing, the helper's `list`/`click`/`tap`/`type`): accepted from the lead's and exec-4's records.
- Phase 3 work in progress in the same tree (`integration_test/*`, `session_provider.dart`, `utils.dart`, `data_home.dart`, `files.dart`, `home/*`, `nft/*`, `test/core/data_home_test.dart`, `test/integration_helpers_test.dart`).

## Recommendation
Proceed to phase 4 (labels and keys). Before committing phase 2: confirm WARN 1 in the browser and add the one-sentence limitation to `docs/automation.md`; reword the two comments in WARN 2 (and the plan note) so the record matches the engine. Both are small edits the lead can make without re-verification.
