# Phase 4 Verification — Labels and Keys, Core Flows (task 6)

**Phase:** 4 — Tooltips, button semantics and stable keys on `lib/features/{auth,home,navigation,send,receive,wallet,config,root}`
**Plan:** `docs/plans/automation-a11y-plan.md`
**Repo:** vfx-gui
**Branch:** `feat/automation-a11y` (phase 4 is STAGED in the index on top of the phase 3 commit; unstaged phase 6 work ignored)
**Base:** `testnet`
**Verifier:** reviewer agent (spawned by the orchestrator lead; no commit)
**Date:** 2026-09-26

## Verdict: **PASS WITH WARNINGS**

The sweep is complete and mechanically sound. Every live `IconButton` in scope has a tooltip except the one documented invisible spacer; 23 of 28 `InkWell`/`GestureDetector` tap targets are wrapped in `Semantics`, and of the five that are not, three are the executor's documented skips. The staged diff introduces only `Semantics`, `ValueKey` and `Key` constructors, so layout cannot have changed; no existing ARB line was modified; the two ARB files have 3358 keys each with all 15 new keys described in both; the staged `gen-l10n` output is byte-identical to a fresh run; the analyzer's 390 issues are the baseline set with only line numbers moved; 190 tests pass. I confirmed against the framework and web engine sources that the two patterns the executor relied on do what the plan needs: a tooltip becomes the aria-label, and `Semantics(button: true)` is what gives a node the button role. Two warnings: the two "copy current address" icons in the desktop wallet-selector header keep only their pre-existing `Tooltip` and never get the button role, and no widget test pins the wrapper patterns that phase 5 will repeat across forty feature folders.

---

## Checks run

| Check | Result |
|---|---|
| `flutter analyze` | 390 issues, 0 errors. After stripping line:col from every issue the set is identical to the phase 1 baseline (raw diff shows only line shifts in touched files) |
| `flutter test test/core test/features` | 190 passed, 0 failed |
| `flutter gen-l10n` then `git diff -- lib/l10n/generated` | No difference; staged generated files match a fresh run (index restored afterwards, nothing changed) |
| ARB parity (script) | en 3358 keys, es 3358 keys, none one-sided; 15 new keys present in both with `@key` descriptions; only `homeFooterGithubTooltip` is identical in es (the brand name "GitHub") |
| Coverage scan (script over the eight scope directories) | 40 `IconButton(` matches = 37 live + 3 in commented-out code; 36 live ones have `tooltip:`; 28 `InkWell`/`GestureDetector` with a tap handler, 23 wrapped in `Semantics` |
| Added constructors in the staged diff | `Semantics(` 30, `ValueKey(` 29, `Key(` 5; every other constructor on a `+` line is a re-indented wrapped widget whose old opener is on the matching `-` line |
| Existing ARB lines removed or changed | 0 |
| Framework/engine reads | `material/tooltip.dart:741-744`, `material/icon_button.dart:608,667,674`, `rendering/proxy_box.dart` (`RenderAnimatedOpacityMixin.visitChildrenForSemantics`), engine `semantics/tappable.dart:28-45`, `semantics/label_and_value.dart:36-49` |

Lead-reported: full suite 197 passing with only `test/widget_test.dart` failing; ARB parity 3358; visual spot-check pending on the lead's side (no layout change is possible from this diff, see below).

---

## 1. Plan acceptance for Task 6

### 1a. Every `IconButton` without a tooltip gets one
**PASS.** The four scan hits without `tooltip:` are:
- `home/screens/all_tokens_screen.dart:126`: `IgnorePointer(ignoring: true) > Opacity(opacity: 0) > IconButton`, a spacer that balances the back arrow. Documented skip; correct to skip (Opacity 0 excludes its semantics anyway).
- `home/screens/home_screen.dart:51`, `home/components/home_buttons/hd_wallet_button.dart:191`, `receive/screens/web_receive_screen.dart:121`: inside `//` comments.

Tooltips reach the accessible name on web: `IconButton` wraps its `Semantics(button: true)` in a `Tooltip` (`icon_button.dart:608,667,674`), `Tooltip` emits `Semantics(tooltip: message)` (`tooltip.dart:741-744`), and the engine's `LabelAndValue.update` writes the tooltip into `aria-label` (`label_and_value.dart:36-49`). Tooltip strings are l10n keys in both ARBs; existing keys were reused where a matching string existed (`homeJoinDiscord`, `actionClose`, `walletRevealPrivateKey`, `walletHideAccountTitle`, ...), and their values read correctly for the control they label.

### 1b. Every icon-only `InkWell`/`GestureDetector` gets `Semantics(label, button: true)` or an equivalent
**PASS with one gap (WARN 1).** Wrapped: 23. Not wrapped:
- `home/screens/web_home_screen.dart:210`: the full-screen dismiss scrim (documented skip, correct).
- `config/components/configuration_form_group.dart:147,175`: text labels that toggle the adjacent checkbox (documented skip; a button role would misdescribe them).
- `wallet/components/wallet_selector.dart:64-98`: two copy icons (`Tooltip > InkWell(onTap) > Icon`). The tooltip supplies the name, the InkWell supplies the tap action, but nothing sets `isButton`, and the engine sets `role="button"` only from that flag (`tappable.dart:28-29`). Not an "equivalent existing pattern" for the role. See WARN 1.

Labelled wrappers are on icon-only targets (`Icon` children only, no `Text`), so no label is duplicated: `log_item.dart:32-34`, `print_addresses_button.dart:47-50`, `manage_wallet_bottom_sheet.dart:160-162,300-302,326-328`, `web_dashboard_container.dart:1240-1243`, `wallet_selector.dart:466-469,517-520`, `send_form.dart:413-416,425-428` (`PrettyIconButton` renders no text: `pretty_icons.dart:96-160`), `root_container_expander.dart:22-24` (icon-only row). Unlabelled `Semantics(button: true)` wrappers are on targets with visible text (login tiles, nav items, tx and price cards, "docs" and "View Metrics" links, bulk-import link, the wallet-selector header), so the visible text stays the name.

### 1c. Primary controls get stable keys following `buttons.dart`
**PASS.** `buttons.dart:434-448` builds `Key('elevated:$key')`-style `<kind>:<detail>` strings; the new keys follow it: `auth:enter_password`, `auth:logout`, `auth:login`, `auth:resume_session`, `auth:type_{email_password,mnemonic,vfx_private_key,btc_private_key,extension}`, `nav:{dashboard,vault_accounts,domains,send,receive,butterfly,crypto_com,transactions,vbtc_tokens,privacy,fungible_tokens,smart_contracts,nfts,p2p_auctions,validator,operations,sign_out}` plus `nav:expander`, `send:{address,amount,submit}`, `receive:{copy_address,copy_btc_address,copy_domain}`. `Key('x')` and `ValueKey('x')` are both `ValueKey<String>`, so `find.byKey` in widget tests and Flutter Driver's `byValueKey` (phase 6) resolve them the same way. Keys were added to widgets that had none, with constant values, so element identity and state are unchanged.

The unlock password field and its submit live in `PromptModal` (`lib/core/dialogs.dart:279`) and `PasswordPromptService` (`lib/core/services/password_prompt_service.dart`), outside the phase's directory scope; the executor keyed the buttons that open them and reported the rest. See INFO 3.

### 1d. No layout, behaviour or string change
**PASS.** `Semantics` is a `RenderProxyBox` with no size or paint effect; `Tooltip` adds no padding; keys change nothing at runtime. The only behavioural addition is the one the plan asks for: hovering an icon button now shows its tooltip bubble. No `Container`, `Padding`, `SizedBox` or constraint was added (constructor tally above), and no existing string was edited (0 removed ARB lines). The lead's web spot-check is the remaining visual confirmation.

### 1e. Analyze clean, `gen-l10n` output committed, every file listed
**PASS.** See the table. The generated files are staged and identical to a fresh run. The 31 staged files are listed under "Files reviewed".

---

## 2. Semantic correctness of the wrappers (sample, checked against sources)

| Pattern | What the tree does | Result |
|---|---|---|
| `Semantics(button: true) > ListTile(onTap, title: Text)` (login tiles) | `ListTile` emits `Semantics(selected, enabled)` and an `InkWell` tap action, neither a boundary; the outer button flag, the tap action and the title text merge into one node: role button, label = title. Before this phase the same node existed without the flag, which is why the lead saw `text "Email & Password"` in phase 2 | Correct, no double label |
| `Semantics(button: true) > GestureDetector > ... Text` (nav items, cards) | Same merge; `GestureDetector` already contributes the tap action | Correct |
| Collapsed side nav (`isExpanded == false`) | The title `Text` sits in `AnimatedOpacity(opacity: 0)`, and `RenderAnimatedOpacityMixin.visitChildrenForSemantics` skips the child at alpha 0, so the text label is gone. The pre-existing `Tooltip(message: isExpanded ? "" : title)` on the icon (`root_container_side_nav_item.dart:98-99`) supplies `tooltip: title` in that state, and the engine writes it to `aria-label`; when expanded the tooltip is empty (`hasTooltip` false) and the text label is used | Correct in both states |
| `Semantics(label: X, button: true) > InkWell > Icon` | Single node, label X, role button, tap action | Correct |
| `Semantics(label: 'Paste', button: true) > PrettyIconButton` | `PrettyIconButton` is `MouseRegion > GestureDetector(onTap)` with no text | Correct |
| Wallet-selector header `Semantics(button: true) > GestureDetector > Tooltip > Row(Text(address), Text(balance)) + Icon` (`root_container.dart:380-475`) | One node: button, label "address / [balance]", tooltip "Selected VFX address" | Correct; the address is the visible name |
| Labelled copy icon inside a tile without its own tap (`_WalletListItem`, `web_dashboard_container.dart:1229-1262`) | The tile's `ListTile` has no `onTap`, so its `Semantics(selected, enabled)` node and the icon's node are compatible and merge: one button labelled "address / Copy address" whose tap copies. In `manage_wallet_bottom_sheet.dart` the tiles have `onTap` (lines 132, 265), so the tap actions conflict and the copy icon stays a separate child node | Acceptable (INFO 2) |
| `excludeSemantics` | Not used anywhere in the diff | Nothing hidden |

---

## 3. The `action*` prefix deviation

**Recommendation: accept, and record it as a convention.** The ARB already has a generic `action` namespace from the phase 1C i18n work (`actionCancel`, `actionClose`, `actionCopy`, `actionPaste`, `actionSend`, `actionDelete`, `actionSearch`, ...), used across features. The conventions rule "reuse the feature's existing prefix" governs feature-specific strings, and the executor followed it there: `homeFooterGithubTooltip` matches `homeJoinDiscord`, `nav*` matches the navigation keys, and `status` is the dominant prefix in `lib/features/root` (23 uses versus 21 `nav`, 10 `web`). "Copy address" appears in six features; six per-feature copies would be six identical strings to translate and keep in sync, which is the outcome the reuse rule exists to prevent. Suggested one-liner for `.claude/context/conventions.md`: "Shared control labels (copy/back/close tooltips and button labels used by more than one feature) live under the generic `action` prefix; feature-specific tooltips use the feature prefix."

---

## 4. Conventions, hard constraints, and tests

| Rule | Status |
|---|---|
| l10n keys in both ARBs with `@key` descriptions, `gen-l10n` output committed | 15/15, generated files in sync |
| Existing strings unchanged | 0 removed or edited ARB lines |
| No new analyzer issues (baseline 390) | Same set, line numbers only |
| No new test failures | 190 pass in scope; lead reports the full suite unchanged |
| No refactors while building | Only wrappers, tooltips, keys; no widget restructured |
| No behaviour change | Only tooltip bubbles on hover, as specified |
| l10n access pattern consistent per file | Files that already had `final l10n = ...` use `l10n.`; files using `AppLocalizations.of(context)` inline keep that; provider code uses `globalL10n` as its neighbours do; three files gained the `app_localizations.dart` import they needed (`footer.dart`, `log_item.dart`, `reload_button.dart`, `root_container_expander.dart`) |
| Tests alongside code where meaningful | None added. See WARN 2 |
| Do not commit | Nothing committed |

On tests: adding tooltips and keys is declarative and does not warrant tests. The `Semantics(button: true)` wrappers are different: they encode two non-obvious assumptions (a tile's title merges into the wrapper as its label; a collapsed nav item keeps a name through its icon tooltip), and phase 5 will repeat the pattern across three waves. The repo already has a widget-test precedent with the l10n setup needed (`test/features/btc/fee_rate_picker_test.dart:16-28`, `pumpHost`). Two short tests would have made this phase self-verifying; recommended in WARN 2 rather than required, because I verified both behaviours against the framework and engine sources and found no defect.

---

## Findings

### WARN 1 — The wallet-selector header copy icons never get the button role
`lib/features/wallet/components/wallet_selector.dart:64-98`: the two "copy current address" icons (VFX and BTC) are `Tooltip > InkWell(onTap) > Icon`. They have a name (from the tooltip) and a tap action, but no `isButton` flag, so the engine renders them without `role="button"` (`tappable.dart:28-29`). In practice: Claude in Chrome's `read_page` lists them without a button role, and `fltA11y.click(label)` (which only reacts to `role="button"`) cannot target them; only `tap` can. These are primary address-copy controls in the desktop header, the same job the plan singled out for the receive screen.

Fix (two lines each, no string change): wrap each `Tooltip` in `Semantics(button: true, child: Tooltip(...))`. That mirrors what `IconButton` does internally (`Semantics(button: true)` around a `Tooltip`) and keeps the hover bubble.

### WARN 2 — No widget test pins the wrapper patterns before phase 5 scales them
Two tests, modelled on `fee_rate_picker_test.dart`'s `pumpHost`, would cover the assumptions phase 5 inherits:
1. Pump `AuthTypeModal` with the l10n delegates and assert that `find.bySemanticsLabel('Mnemonic (HD account)')` matches a node with `isButton` and a tap action (and that `find.byKey(const ValueKey('auth:type_mnemonic'))` finds the tile).
2. Pump `RootContainerSideNavItem(title: 'Dashboard', isExpanded: false, ...)` and assert its semantics carry `tooltip: 'Dashboard'` with `isButton`; pump again with `isExpanded: true` and assert `label: 'Dashboard'`.

Both run under the default `semanticsEnabled: true` of `testWidgets`. Recommended before or alongside phase 5's first wave.

### INFO 1 — `AppButton` interpolates the widget key into the inner button's key
`buttons.dart:434-448` builds `Key('elevated:$key')` from the widget's `Key?`, so `AppButton(key: Key('auth:login'))` gives the inner `ElevatedButton` the key `elevated:[<'auth:login'>]`. Pre-existing and harmless: tests and the driver target the `AppButton` by `auth:login`. A later cleanup could interpolate `(key as ValueKey).value`; out of scope for this phase ("no refactors").

### INFO 2 — Icon labels merge into a tile that has no tap of its own
`_WalletListItem` (`web_dashboard_container.dart:1229-1262`) has no `onTap`, so the "Copy address" button node merges with the tile: one button labelled "address / Copy address" whose tap copies. That is standard Flutter merging and reads acceptably; `fltA11y.click('Copy address')` still matches by "contains". If a separate node is wanted later, `Semantics(explicitChildNodes: true)` on the tile does it. The same applies to the lead's note about copy icons inside `PopupMenuItem`'s `MergeSemantics`.

### INFO 3 — Unlock/password keys are a follow-up in `lib/core`
The plan lists "unlock/password" among the primary controls to key. The field and submit are in `PromptModal` (`lib/core/dialogs.dart:279`, `TextFormField` at lines 415, 592, 606, 637) and `PasswordPromptService`, outside the phase's directory scope, so the executor keyed the buttons that open them (`auth:enter_password`, `auth:resume_session`). One key pair on `PromptModal` (for example `prompt:input`, `prompt:submit`) would cover every flow that uses it. Suggest folding it into phase 5 wave B or the phase 6 driver work, which needs it to drive the unlock flow.

---

## Files reviewed (all 31 staged files)
- auth: `auth_utils.dart` (9 tooltips), `components/auth_type_modal.dart` (5 tiles wrapped + keyed), `screens/web_auth_screen.dart` (4 keys)
- home: `components/footer.dart` (2 tooltips, 1 wrapper), `components/home_buttons/print_addresses_button.dart` (1 labelled wrapper), `components/log_item.dart` (1 labelled wrapper), `screens/all_tokens_screen.dart` (1 tooltip), `screens/web_home_screen.dart` (2 wrappers)
- navigation: `components/root_container_balance_row.dart` (2 wrappers), `components/root_container_expander.dart` (labelled wrapper), `components/root_container_side_nav.dart` (`nav:expander` key), `components/root_container_side_nav_item.dart` (wrapper), `components/root_container_side_nav_list.dart` (17 keys), `root_container.dart` (wrapper)
- send: `components/send_form.dart` (2 field keys, submit key, 3 wrappers), `providers/send_form_provider.dart` (2 tooltips)
- receive: `screens/receive_screen.dart` (2 keys, 3 tooltips), `screens/web_receive_screen.dart` (2 keys, 2 tooltips)
- wallet: `components/manage_wallet_bottom_sheet.dart` (3 labelled wrappers, 4 tooltips), `components/wallet_selector.dart` (1 wrapper, 2 labelled wrappers, 6 tooltips), `providers/wallet_list_provider.dart` (1 tooltip), `utils.dart` (1 wrapper, 4 tooltips)
- config: `screens/config_container_screen.dart` (1 tooltip)
- root: `components/reload_button.dart` (1 tooltip), `status/components/status_container.dart` (1 wrapper), `web_dashboard_container.dart` (3 wrappers, 1 labelled wrapper)
- l10n: `app_en.arb`, `app_es.arb` (+60 lines each, 15 keys), `generated/app_localizations.dart`, `generated/app_localizations_en.dart`, `generated/app_localizations_es.dart`

## Not reviewed
- The visual spot-check on the web dev server (lead). From the diff no layout change is possible.
- Unstaged phase 6 work in progress (`pubspec`, `Makefile`, `tool/`, `lib/main*.dart`, `integration_test/`, `docs/`).

## Recommendation
Commit phase 4 after the two-line fix in WARN 1 (or note it for phase 5 wave B, which owns `wallet`-adjacent folders anyway, if the lead prefers not to touch the squash). Add the two widget tests from WARN 2 before phase 5's first wave. Record the `action` prefix convention.
