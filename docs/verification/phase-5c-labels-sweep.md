# Phase 5 Wave C Verification — Final Labels Sweep: node, operations, payment, remote_shop, reserve, transactions, validator, voting, web, web_shop, block, easter + lib/core components + l10n consolidation (task 7)

**Phase:** 5, wave C of three — tooltips, button semantics, stable keys, the `lib/core` components pass, the `action*` consolidation, widget tests
**Plan:** `docs/plans/automation-a11y-plan.md`
**Repo:** vfx-gui
**Branch:** `feat/automation-a11y` (wave C is STAGED in the index on top of the phase 6 commit `28298d51`)
**Base:** `testnet`
**Verifier:** reviewer agent (spawned by the orchestrator lead; no commit)
**Date:** 2026-09-26

## Verdict: **PASS WITH WARNINGS**

The last wave completes the sweep. Every live `IconButton` in the twelve wave C folders and in `lib/core` has a tooltip except the two documented validator cases, every `InkWell`/`GestureDetector` with a handler is wrapped except the three dismiss scrims, the five checkbox labels and the idle detector, the diff adds only `Semantics`, `Key` and `ValueKey` constructors, and the `lib/core` components now carry the button role or a tooltip without adding any label to controls that already have visible text. The consolidation is clean: four feature-prefixed keys became `action*` keys with identical values, the removed keys have zero references, no existing value or description changed, and the lead's `tkbOpenAsset` restoration leaves the asset card's visible label byte-identical to the pre-wave commit in both languages. ARB parity holds at 3387, the staged `gen-l10n` output equals a fresh run, the analyzer set equals the baseline, and 219 tests pass including the four new ones. One warning, which is a follow-up rather than a defect in this wave: the executor's own note that `ListTile(onTap:)` rows were never in any wave's scan is right, and my count puts it at 114 tappable list rows across the app without a button role.

---

## Checks run

| Check | Result |
|---|---|
| `flutter analyze` | 390 issues, 0 errors; identical to the phase 1 baseline after stripping line:col |
| `flutter test test/core test/features` | 219 passed, 0 failed (lead: full suite 226 passing, only `test/widget_test.dart` failing) |
| `flutter gen-l10n` then `git diff -- lib/l10n/generated` | No difference; index restored |
| ARB parity (script) | en 3387, es 3387; 10 keys added (`actionShowPassword`, `actionHidePassword`, `actionPrevious`, `actionNext`, `actionViewOnExplorer`, `webOpenMenu`, `actionPickDate`, `actionPickTime`, `actionViewAsset`, `actionOpenAsset`), all with descriptions in both files and distinct Spanish values; 4 removed (`scwPickDate`, `scwPickTime`, `nftViewAsset`, `scwOpenAsset`); no existing value changed in either file; no existing description changed |
| References to the removed keys (`lib/` and `test/`, generated excluded) | None |
| `tkbOpenAsset` | `git show cd0cd213:lib/l10n/app_en.arb` "Open Asset", es "Abrir recurso"; staged files identical; used only at `asset/asset_card.dart:110` (visible button label); `actionOpenAsset` used only for the `sc_wizard_card.dart:197` tooltip |
| Coverage scan (comments excluded), wave C folders + `lib/core` | Live `IconButton`: node 2, operations 2, payment 3, remote_shop 11, reserve 1, transactions 6, validator 2, voting 3, web 2, web_shop 22, core 7; all with `tooltip:` except `validator_screen.dart:274` (invisible spacer) and `:291` (inside a `Tooltip`). Tap targets with a handler: 51, wrapped 40; the 11 unwrapped are listed under 1a |
| Added constructors (`lib/`) | `Key(` 58, `Semantics(` 48, `ValueKey(` 2; `InkWell(`, `Icon(` and `PrettyIconButton(` on `+` lines are re-indented |
| Removed lines that are not a bare opener | The repointed `scwPick*`/`scwOpenAsset`/`nftViewAsset` usages, the two dropped `send_form.dart` wrappers, and `icon: Icon(...))` closers re-indented after a tooltip was inserted |
| Staged paths outside `lib/features/`, `lib/core/`, `lib/l10n/`, `test/` | None |
| Files sampled in full diff | `lib/core/theme/pretty_icons.dart`, `lib/core/dialogs.dart`, `lib/core/theme/components.dart`, `lib/core/components/{big_button,simple_expandable_text,back_to_home_button}.dart`, `lib/core/services/password_prompt_service.dart`, `encrypt/utils.dart`, `send/components/send_form.dart`, `reserve/screens/manage_reserve_accounts_screen.dart`, `reserve/screens/reserve_account_overview_screen.dart`, `web_shop/screens/web_shop_detail_screen.dart`, `web_shop/components/web_listing_detail.dart`, `operations/screens/operations_screen.dart`, `transactions/components/vfx_transaction_filter_button.dart` |

---

## 1. Coverage, layout, ARB, keys

### 1a. Tooltips and wrappers
**PASS.** The eleven unwrapped tap targets are all documented skips and all correct:
- Dismiss scrims (3): `remote_shop/components/listing_details.dart:319` and `web_shop/components/web_listing_detail.dart:385` (a `GestureDetector` around a full-size image preview that pops the dialog) and `web/components/web_qr_scanner.dart:60` (a `Positioned.fill` overlay calling `onClose`).
- Checkbox labels (5): `web_shop/components/create_web_listing_form.dart:128,159,214,245` and `web_shop/components/web_create_collection_form_group.dart:71`, each a text label toggling the adjacent checkbox.
- `lib/core/components/idle_detector_wrapper.dart:128`: the interaction detector, not a control.
- `validator_screen.dart:274` is `IgnorePointer > Opacity(0) > IconButton(onPressed: null)`, a spacer; `:291` is an `IconButton` inside `Tooltip(message: validatorRenameTooltip)`, which already gives it a name, and `IconButton` supplies the role itself.

### 1b. No layout or behaviour change
**PASS.** Only the three key/wrapper constructors were introduced. The `Icon(` re-adds are the same icon lines re-indented because a `tooltip:` line now follows them. The two `PrettyIconButton(` re-adds are the send form's buttons after their external wrappers were removed (section 2).

### 1c. Keys
**PASS.** 56 keys: `validator:*`, `voting:*`, `tx:{filter,filter_clear,filter_close,filter_address}` plus `tx:filter_type_${t.type}`, `remote_shop:*`, `web_shop:{share_listing,edit_listing,delete_listing,buy_now,bid_now,auction_details,bid_history,publish_shop,delete_shop,edit_shop,create_collection,...}`, `reserve:{setup_new_account,restore,manage_vault_accounts}` and the per-row `reserve:<action>:<address>` keys (`send_funds`, `manage_assets`, `receive_assets`, `activate`, `awaiting_funds`, `recover`). The dynamic keys are the right call: constant keys on `AppButton`s inside a `ListView.builder` row would be siblings-of-siblings with the same value and `tap-key` would hit "Too many elements". Repeated static values are never on screen together: `reserve:restore` appears on the manage screen, on the overview's empty state (`_Top`, `reserve_account_overview_screen.dart:364-366`, only when `wallets.isEmpty`) and after the overview's list (line 181, only in the `wallets.isNotEmpty` branch chosen at line 90); `reserve:setup_new_account` is on two different screens; `auth:password`/`auth:password_submit` are the two secondary prompts (section 2).

---

## 2. The `lib/core` component changes

| Component | Change | Behaviour for composing screens |
|---|---|---|
| `AppVerticalIconButton` (`theme/components.dart:98-99`), `VBtcButton` (`:200-201`), `BigButton` (`big_button.dart:40-41`), `SimpleExpandableText` (`simple_expandable_text.dart:38-39`) | `Semantics(button: true)` with no label around the existing tap target | Each renders its own `Text`, so the visible text stays the accessible name and only the role is added; 7, 2, 4 and 0 composing files respectively |
| `PrettyIconButton` (`theme/pretty_icons.dart:102,111,141-143`) | New `String? label` parameter, default null; `Semantics(label: widget.label, button: true)` inside | `label: null` annotates nothing, so an unlabelled use is a role-only change; the only two usages (`send_form.dart:413,422`) pass the labels the phase 4 wrappers used to supply, and those wrappers are gone, so there is no double label. `test/core/pretty_icon_button_test.dart` covers both cases |
| `BackToHomeButton` (`back_to_home_button.dart:19`) | `tooltip: actionBack` | 12 composing screens gain a name |
| `dialogs.dart` | `actionBack` on the `InfoDialog` back arrow (`:47`), `actionShowPassword`/`actionHidePassword` flipping with the obscured state on both reveal toggles (`:460-462`, `:640-642`), `actionClose` on `SpecialDialog` (`:892`) and `ButterflyOptionsDialog` (`:925`) | Tooltips only |
| `PasswordPromptService.requirePasswordFor` (`password_prompt_service.dart:107-108`), `passwordRequiredGuardV2` (`encrypt/utils.dart:81-82`) | Pass `auth:password`/`auth:password_submit` | Closes wave B INFO 2; one finder now reaches every password prompt |

Every wave B WARN 1 item is done. **PASS.**

---

## 3. The consolidation

**PASS.** All repointed usages compile (analyzer clean); `grep` finds no `scwPickDate`, `scwPickTime`, `nftViewAsset` or `scwOpenAsset` outside the generated files, which were regenerated. Values are unchanged (`Pick a date`, `Pick a time`, `View asset`, `Open asset` and their Spanish forms moved verbatim), so nothing a user sees changed. The lead's post-merge fix is correct and necessary: the merge had pointed `asset_card.dart:110`, a visible button label, at the sentence-case `actionOpenAsset`, which the plan forbids; `tkbOpenAsset` is restored in both ARBs with its description and the card renders exactly the pre-wave string. One pre-existing wrinkle to note for the glossary, not for this wave: the tooltip's Spanish "Abrir archivo" and the button's "Abrir recurso" translate "asset" differently.

---

## 4. The filter-button test's overflow handling

**Acceptable.** `vfx_transaction_filter_button.dart:225-236` lays each transaction type out as `SizedBox(width: 180) > Row(mainAxisSize: min, [Checkbox, Text])`, and the longer type names overflow the fixed box. That is a pre-existing layout bug, independent of the screen size, so the test cannot avoid it by resizing the surface, and fixing it is a layout change the sweep must not make. The test replaces `FlutterError.onError` only for the interval while the sheet is open, forwards every report that does not contain "overflowed" to the original handler, and restores it in `finally`. That is as narrow as the workaround can be. Recommended: fix the overflow (a `Flexible` around the `Text`, or `overflow: TextOverflow.ellipsis`) in the post-sweep bug-fix commit and delete the workaround with it (INFO 1).

The other tests: `pretty_icon_button_test.dart` (label, role, tap; unlabelled still a button), `prompt_modal_test.dart` (+1: the reveal tooltip flips between "Show password" and "Hide password" on tap), `butterfly_link_card_test.dart` (card is a button named by its amount and message; tap invokes the callback), `vfx_transaction_filter_button_test.dart` (key, tooltip name, role; opens the sheet with the four keyed controls; closes). All meaningful.

---

## Conventions and hard constraints

| Rule | Status |
|---|---|
| l10n keys in both ARBs with descriptions, `gen-l10n` committed | 10/10, generated files in sync, 4 removals clean |
| Existing strings unchanged | No value or description of a surviving key changed; the one visible-label regression from the merge was caught and reverted by the lead |
| No new analyzer issues | Same set as baseline |
| No new test failures | 219 pass; four new test files |
| No refactors, no behaviour change | `PrettyIconButton` gains an optional parameter; otherwise wrappers, tooltips, keys |
| Tests alongside code | Yes, including the `lib/core` component change |
| Report lists every file touched | See "Files reviewed" |
| Do not commit | Nothing committed |

---

## Findings

### WARN 1 — 114 tappable `ListTile` rows have no button role (follow-up, not a defect of this wave)
The waves' rule covered icon-only `InkWell`/`GestureDetector` targets, and phase 4 wrapped the five login `ListTile`s because the plan named them. A scan for `ListTile(` with a non-null `onTap:` across `lib/` finds 119, of which those 5 are wrapped. Per feature: wallet 19, root 10, reserve 10, token 9, btc_web 9, btc 8, home 8, auth 8 (5 wrapped), mother 6, smart_contracts 5, web_shop 4, web 4, remote_shop 3, privacy 3, dst 3, asset 2, chat 2, nft 2, voting 1, transactions 1, send 1, core 1. Each row is already named by its visible text and reachable through `fltA11y.tap` and `tap-text`, but `read_page` lists it as text, `fltA11y.click` cannot target it, and a role-based finder skips it. The wallet, token and reserve lists are the rows an automated flow will most often need.

The pattern is proven: `Semantics(button: true, child: ListTile(...))`, verified in phase 4 (single node, title as label, role button) and pinned by `test/features/auth/auth_type_modal_test.dart`. Rows with their own `key` should keep it on the `ListTile`. Recommend one more mechanical pass as its own task after this branch merges, using the scan above as its checklist.

### INFO 1 — Pre-existing overflow behind the filter-button test workaround
`vfx_transaction_filter_button.dart:225-236`; see section 4. Add to the bug-fix commit queued after the sweep, then remove the `FlutterError.onError` block from the test.

### INFO 2 — Cross-feature reuse of feature-prefixed keys
`walletRevealPrivateKey`, `webRenameAccountTitle`, `reserveWebVaultBalanceTitle`, `txpTxFilters`, `homeJoinDiscord` and `homeFooterGithubTooltip` are reused as tooltips or labels outside their feature. That follows the "reuse an existing string" rule and changes nothing visible. If any of them is touched again, promote it to `action*` in the same change; no separate pass is needed.

### INFO 3 — Executor-flagged leftovers, correctly untouched
- Hardcoded `'Chat'` labels in `remote_shop` (an l10n gap, not a labels issue).
- `WebMyListingList` and `SimpleExpandableText` have no references; the latter received a role wrapper anyway, which is harmless. Both are dead-code candidates for a separate cleanup.
- Spanish "archivo" versus "recurso" for "asset" (section 3).

---

## Files reviewed (all 66 staged files)

**lib/core (7):** `components/back_to_home_button.dart`, `components/big_button.dart`, `components/simple_expandable_text.dart`, `dialogs.dart`, `services/password_prompt_service.dart`, `theme/components.dart`, `theme/pretty_icons.dart`

**Consolidation repoints (7):** `asset/asset_thumbnail.dart`, `dst/components/create_listing_form_group.dart`, `nft/modals/nft_management_modal.dart`, `smart_contracts/components/sc_evolve_dialog.dart`, `smart_contracts/components/sc_wizard_card.dart`, `smart_contracts/features/evolve/evolve_modal.dart`, `smart_contracts/features/ticket/ticket_modal.dart`

**Carry-overs (2):** `encrypt/utils.dart`, `send/components/send_form.dart`

**block (1):** `latest_block.dart`. **easter (1):** `secret_button.dart`. **node (1):** `screens/node_list_screen.dart`. **operations (1):** `screens/operations_screen.dart`

**payment (2):** `components/butterfly_link_card.dart`, `components/butterfly_link_form.dart`

**remote_shop (4):** `components/listing_details.dart`, `screens/remote_shop_collection_screen.dart`, `screens/remote_shop_detail_screen.dart`, `screens/remote_shop_list_screen.dart`

**reserve (3):** `screens/manage_reserve_accounts_screen.dart`, `screens/reserve_account_overview_screen.dart`, `screens/web_reserve_account_overview_screen.dart`

**transactions (4):** `components/notification_overlay.dart`, `components/transaction_list_tile.dart`, `components/vfx_transaction_filter_button.dart`, `screens/web_transaction_detail_screen.dart`

**validator (1):** `screens/validator_screen.dart`

**voting (4):** `components/topic_card.dart`, `components/topic_form.dart`, `components/topic_vote_actions.dart`, `screens/topic_list_screen.dart`

**web (7):** `components/new_web_wallet_selector.dart`, `components/web_mobile_drawer_button.dart`, `components/web_multi_account_selector.dart`, `components/web_qr_scanner.dart`, `components/web_wallet_details.dart`, `components/web_wallet_mobile_account_info.dart`, `components/web_wallet_type_switcher.dart`

**web_shop (12):** `components/create_web_listing_form.dart`, `components/web_listing_detail.dart`, `components/web_listing_list.dart`, `components/web_my_shop_list.dart`, `components/web_shop_list.dart`, `screens/create_web_listing_screen.dart`, `screens/create_web_shop_container_screen.dart`, `screens/my_create_collection_container_screen.dart`, `screens/my_web_shops_list_screen.dart`, `screens/web_collection_detail_screen.dart`, `screens/web_shop_detail_screen.dart`, `screens/web_shop_list_screen.dart`

**l10n (5):** `app_en.arb`, `app_es.arb`, `generated/app_localizations.dart`, `generated/app_localizations_en.dart`, `generated/app_localizations_es.dart`

**tests (4):** `test/core/pretty_icon_button_test.dart`, `test/core/prompt_modal_test.dart`, `test/features/payment/butterfly_link_card_test.dart`, `test/features/transactions/vfx_transaction_filter_button_test.dart`

## Not reviewed
- Visual spot-check in the running app (no layout change is possible from this diff).

## Recommendation
Commit wave C as staged; the sweep is complete. Queue three follow-ups after the branch merges: the `ListTile` role pass (WARN 1), the bug-fix commit (INFO 1 plus the items carried from waves A and B: the description-title condition in `sc_wizard_card.dart`, the `btcWifCopiedToast` toasts, the `create_adnr_dialog.dart` length check, the hardcoded adnr and remote_shop strings), and the dead-code cleanup (INFO 3).
