# Phase 5 Wave A Verification — Labels Sweep: btc, btc_web, privacy, token, nft, smart_contracts, sc_property (task 7)

**Phase:** 5, wave A of three — tooltips, button semantics, stable keys and widget tests
**Plan:** `docs/plans/automation-a11y-plan.md`
**Repo:** vfx-gui
**Branch:** `feat/automation-a11y` (wave A is STAGED in the index on top of the phase 4 commit; unstaged phase 6 work ignored)
**Base:** `testnet`
**Verifier:** reviewer agent (spawned by the orchestrator lead; no commit)
**Date:** 2026-09-26

## Verdict: **PASS WITH WARNINGS**

The wave is complete: every one of the 76 live `IconButton`s in the seven folders has a tooltip, 38 of the 40 tap targets with a handler are wrapped in `Semantics` and the other two are the documented checkbox labels, the staged diff adds only `Semantics`, `ValueKey` and `Key` constructors, no existing ARB line changed, the two ARB files hold 3382 keys each with all 24 new keys described and translated, the staged `gen-l10n` output is byte-identical to a fresh run, the analyzer set equals the baseline once line numbers are removed, and 178 feature tests pass, including the four new widget tests, which assert what the phase 4 report asked for. One warning: the new tooltip on the description edit button in `sc_wizard_card.dart` copies the wrong condition (`entry.name.isEmpty`) from the pre-existing dialog title, so it reads "Add description" or "Edit description" based on the name instead of the description. One-token fix. On the duplicate-string keys: accept all six (the executor listed three; my scan found three more exact duplicates of `prv*` bridge keys), for the reasons in section 4.

---

## Checks run

| Check | Result |
|---|---|
| `flutter analyze` | 390 issues, 0 errors; identical to the phase 1 baseline after stripping line:col |
| `flutter test test/features` | 178 passed, 0 failed (lead: full suite 215 passing, only `test/widget_test.dart` failing) |
| `flutter gen-l10n` then `git diff -- lib/l10n/generated` | No difference; index restored, nothing changed |
| ARB parity (script) | en 3382, es 3382, none one-sided; 24 new keys, all with `@key` descriptions in both files, none left untranslated; 0 existing lines removed or edited |
| Coverage scan (script over the seven folders, comment lines excluded) | 76 live `IconButton(`, 0 without `tooltip:`; 40 `InkWell`/`GestureDetector` with a tap handler, 38 wrapped in `Semantics` |
| Added constructors in the staged diff (`lib/features`) | `Semantics(` 38, `ValueKey(` 27, `Key(` 20; the `InkWell(`/`GestureDetector(`/`Icon(` on `+` lines are re-indented openers whose old lines are on the matching `-` lines (including the two `.map((x) => InkWell(` lambdas) |
| Staged paths outside `lib/features/`, `lib/l10n/`, `test/features/` | None |
| Files sampled in full diff | `sc_wizard_card.dart` (14 tooltips, 2 wrappers), `sc_wizard_card_preview.dart`, `private_transfer_dialog.dart`, `commitment_list.dart`, `tokenized_btc_list_screen.dart`, `nft_management_modal.dart`, `web_btc_transaction_list_tile.dart`, `token_list.dart`, `evolve_modal.dart`, `web_asset_thumbnail.dart` |

---

## 1. Coverage, layout, ARB, access pattern, keys

### 1a. Tooltips and wrappers
**PASS.** No live `IconButton` lacks a tooltip. The two unwrapped tap targets are `token/components/token_form.dart:104` (toggles `mintable`, child is a checkbox row) and `smart_contracts/features/fractional/fractional_modal.dart:71` (toggles `allowVoting`, child is the label text): the same class of skip accepted in phase 4 for the config checkbox labels, where a button role would misdescribe them.

### 1b. No layout or behaviour change
**PASS.** Only `Semantics`, `ValueKey` and `Key` were introduced. The one non-trivial rewrite, `web_btc_transaction_list_tile.dart:270-276`, re-indents the existing `Icon(expanded ? arrow_drop_up : arrow_drop_down)` line inside the new wrapper and adds the closing paren. The `.map((w) => InkWell(` lambdas in `tokenize_btc_onboarding_steps.dart:397-403` and `:716-722` become `.map((w) => Semantics(button: true, child: InkWell(` with matching closers. Tooltips add hover bubbles, as specified.

### 1c. ARB parity and descriptions
**PASS.** 24 keys: `actionCopySignature`, `actionGridView`, `actionHelp`, `actionHideDetails`, `actionListView`, `actionRefresh`, `actionShowDetails`, `nftCopySmartContractId`, `nftPauseMedia`, `nftPlayMedia`, `nftViewAsset`, `prvCopyViewingKey`, `tokenDecreaseDecimalPlaces`, `tokenIncreaseDecimalPlaces`, `scwAddAdditionalAsset`, `scwDeletePrimaryAsset`, `scwOpenAsset`, `scwPickColor`, `scwPickDate`, `scwPickTime`, `scwRemoveAsset`, `scwRemovePhase`, `scwRemoveProperty`, `scwRemoveRoyalty`. Sentence case throughout, Spanish values present and distinct. Reused existing keys where a string existed (`scwAddName`/`scwEditName`, `scwQuantityToMint`, `scwAddRoyalty`, `scwAddEvolvingPhase`, `scwAddProperty`, `r3aCreateInstance`, `r3aDeleteStage`, `actionCopyAddress`, ...).

### 1d. l10n access pattern per file
**PASS.** Added lines follow each file's dominant style: `sc_wizard_card.dart` (42 existing `l10n.` uses, 14 added `l10n.`), `sc_wizard_card_preview.dart` (`l10n.`), `web_btc_transaction_list_tile.dart` (8 existing `AppLocalizations.of(context)`, 3 added the same), `token_list.dart` (same), `evolve_modal.dart` (19 existing `globalL10n`, 4 added the same), `nft_management_modal.dart` (mixed file, added `l10n.` where `l10n` is in scope). `withdrawal_processing_dialog.dart` was already mixed (19 `l10n.`, 4 `AppLocalizations.of`) and gains one of each; acceptable.

### 1e. Keys
**PASS.** 47 keys in the `<feature>:<detail>` style: `vbtc:{withdraw,transfer,submit,amount,address}`, `vbtc:bulk_{address,amount,submit}`, `token:{create,mint,name,ticker,transfer}`, `nft:{transfer,transfer_now}`, `privacy:{shield,unshield,transfer,consolidate}` with `_amount`/`_address`/`_recipient`/`_submit` fields and `_vbtc` variants, `sc:compile_mint`. The five `vbtc:*` values that appear twice sit on the desktop (`btc/components/tokenized_btc_action_buttons.dart`) and web (`btc_web/components/web_btc_tokenized_action_buttons.dart`) variants of the same control, never on one screen, the same arrangement phase 4 accepted for `receive:copy_address`. Privacy dialogs key the `TextField`s and the submit `TextButton` directly (`private_transfer_dialog.dart:92,103,132`).

---

## 2. Conditional-role wrappers

| Site | Wrapper | Assessment |
|---|---|---|
| `btc/screens/tokenized_btc_list_screen.dart:415-417` | `Semantics(button: entry.addresses.length == 1, child: InkWell(onTap: length == 1 ? ... : null))` | Correct: the role follows the tap. With several addresses the group tile is inert and each address row below (lines 491-493) is its own button |
| `nft/modals/nft_management_modal.dart:332-335` | `Semantics(label: kIsWeb ? null : nftViewAsset, button: !kIsWeb, child: InkWell(onTap: kIsWeb ? null : ...))` | Correct: on web the thumbnail is not interactive and gets neither role nor label; on desktop the child is an image plus `Text("")`, and an empty label does not concatenate, so the name is exactly "View asset" |
| `nft/modals/nft_management_modal.dart:454-456` | `Semantics(button: showMedia, child: InkWell(onTap: showMedia ? ... : null, child: Text(...)))` | Correct: no label, the visible text is the name; role follows the tap |

A `Semantics(button: true)` with no tap action would be a mislabel, but none of the three produces that state.

---

## 3. The four widget tests

| Test | Asserts | Verdict |
|---|---|---|
| `test/features/auth/auth_type_modal_test.dart` | Tile found by `auth:type_mnemonic`; `find.bySemanticsLabel('Mnemonic (HD account)')` matches; node label equals the title, `isButton`, has `tap`; tapping the tile invokes the handler once. Second test loops the five tiles for role, tap and a non-empty label | Matches the phase 4 sketch exactly, plus the tap round-trip |
| `test/features/navigation/root_container_side_nav_item_test.dart` | Collapsed: `tooltip == 'Dashboard'`, `isButton`, `tap`. Expanded: `label == 'Dashboard'`, `isButton`, `tap` | Matches the sketch; pins the opacity-0 behaviour the phase 4 review reasoned about |
| `test/features/nft/web_asset_thumbnail_test.dart` | The thumbnail node's label is the file name, `isButton`, `tap` | Meaningful: proves the visible file name becomes the accessible name through the new wrapper (`web_asset_thumbnail.dart:22-24`) |
| `test/features/token/token_detail_row_test.dart` | Copyable row: the copy icon's node contains both the value and "Copy", is a button with `tap`. Non-copyable row: no icon, not a button, no tap | Meaningful: documents the merge behaviour flagged as INFO 2 in phase 4 as intended, with a negative case |

All four use the `pumpHost` pattern from `fee_rate_picker_test.dart` where l10n is needed, and run under the default `semanticsEnabled: true`.

---

## 4. Duplicate-string keys: decision

My scan compares every new value against every existing value, case-insensitively. Six matches, not three:

| New key (sentence case) | Existing twin | Existing twin used in | Decision |
|---|---|---|---|
| `actionCopySignature` "Copy signature" | `r3eCopySignature` "Copy Signature" | nowhere in `lib/features` (orphan) | Keep new key; the orphan is a cleanup candidate |
| `actionHideDetails` "Hide details" | `prvBridgeHideDetails` "Hide details" | `bridge/components/bridge_preflight_form.dart` | Keep new key |
| `actionShowDetails` "Show details" | `prvBridgeShowDetails` "Show details" | same | Keep new key |
| `actionRefresh` "Refresh" | `prvRefresh` "Refresh" | `bridge/components/bridge_history_list.dart`, `bridge_preflight_form.dart` | Keep new key |
| `nftPauseMedia` "Pause" | `r3hPause` "Pause" | `token/components/pause_token_button.dart` | Keep both: pausing media and pausing a token are different actions with different translator context |
| `scwOpenAsset` "Open asset" | `tkbOpenAsset` "Open Asset" | `asset/asset_card.dart` | Keep new key |

**Recommendation: accept all six new keys as staged.** The `action*` ones are used across btc, btc_web, nft, smart_contracts and token, which is exactly the shared-control case the phase 4 review assigned to the generic prefix; the `prv*`/`r3e*`/`tkb*` twins are feature-prefixed keys owned by bridge, asset and token, and reusing them from other features would spread feature-prefixed keys around, which the generic namespace exists to prevent. Sentence case is consistent with every tooltip added in phases 4 and 5. Nothing in the existing keys needs to change now. Suggested follow-up outside the sweep: a small l10n consolidation that points the bridge form and history list at `actionShowDetails`/`actionHideDetails`/`actionRefresh`, deletes the `prvBridge*`/`prvRefresh` keys and the orphan `r3eCopySignature`, and leaves `tkbOpenAsset` (a button label) and `r3hPause` alone.

---

## Conventions and hard constraints

| Rule | Status |
|---|---|
| l10n keys in both ARBs with descriptions, `gen-l10n` committed | 24/24, generated files in sync |
| Existing strings unchanged | 0 removed or edited ARB lines |
| No new analyzer issues | Same set as baseline |
| No new test failures | 178 pass; four new tests |
| No refactors, no behaviour change | Only wrappers, tooltips, keys; hover bubbles as specified |
| Tests alongside code | The two tests the phase 4 review asked for plus two more |
| Report lists every file touched | See "Files reviewed" |
| Do not commit | Nothing committed |

---

## Findings

### WARN 1 — The description edit tooltip mirrors the wrong condition
`smart_contracts/components/sc_wizard_card.dart:310`: `tooltip: entry.name.isEmpty ? l10n.scwAddDescription : l10n.scwEditDescription`. The executor copied the condition from the pre-existing dialog title at line 296, which it also reported as a bug. The display two lines earlier (lines 281 and 285) uses `entry.description.isEmpty`, which is the right field. As staged, a contract with a name but no description gets an "Edit description" tooltip on the button that adds one, and one with a description but no name gets "Add description". New code should not inherit a known wrong condition.

Fix: change the tooltip to `entry.description.isEmpty ? ... : ...` (new code, no behaviour change). Fix the dialog title at line 296 the same way in a separate bug-fix commit, together with the other pre-existing bug the executor found (INFO 2).

### INFO 1 — Six duplicate-string keys, all acceptable
Decision and reasoning in section 4. Nothing to change in this wave.

### INFO 2 — Pre-existing bugs the executor found and correctly left alone
- `btc/screens/tokenize_btc_onboarding_steps.dart:299` and `btc/screens/web_tokenize_btc_onboarding_steps.dart:275`: the address copy toasts `btcWifCopiedToast`.
- `sc_wizard_card.dart:296`: the description dialog title tests `entry.name.isEmpty` (see WARN 1).
Both are one-line fixes for a separate commit after the sweep; not part of the labels work.

### INFO 3 — Follow-ups in `lib/core`, outside the sweep's directories
`AddressChoosingIconButton` (`lib/core/utils.dart:119`) has no tooltip, and `PromptModal` (`lib/core/dialogs.dart:279`) still has no keys (phase 4 INFO 3, planned for wave B). Both belong in a short `lib/core` pass; one key pair on `PromptModal` covers every flow that uses it, including the unlock flow phase 6 will drive.

---

## Files reviewed (all 69 staged files)

**btc (11):** `components/btc_transaction_list_tile.dart`, `components/mpc_ceremony_progress_modal.dart`, `components/tokenized_btc_action_buttons.dart`, `components/withdrawal_processing_dialog.dart`, `screens/bulk_vbtc_transfer_screen.dart`, `screens/tokenize_btc_onboarding_screen.dart`, `screens/tokenize_btc_onboarding_steps.dart`, `screens/tokenized_btc_detail_screen.dart`, `screens/tokenized_btc_list_screen.dart`, `screens/web_tokenize_btc_onboarding_screen.dart`, `screens/web_tokenize_btc_onboarding_steps.dart`

**btc_web (5):** `components/web_btc_tokenized_action_buttons.dart`, `components/web_btc_transaction_list_tile.dart`, `components/web_mpc_ceremony_dialog.dart`, `components/web_v2_withdrawal_dialog.dart`, `screens/web_tokenized_btc_detail_screen.dart`

**nft (8):** `components/nft_card.dart`, `components/nft_navigator.dart`, `components/nft_qr_code.dart`, `components/web_asset_card.dart`, `components/web_asset_thumbnail.dart`, `modals/nft_management_modal.dart`, `screens/nft_detail_screen.dart`, `screens/nft_list_screen.dart`

**privacy (12):** `components/commitment_list.dart`, `components/consolidate_dialog.dart`, `components/consolidate_vbtc_dialog.dart`, `components/privacy_dashboard.dart`, `components/privacy_settings_menu.dart`, `components/private_transfer_dialog.dart`, `components/private_transfer_vbtc_dialog.dart`, `components/shield_dialog.dart`, `components/shield_vbtc_dialog.dart`, `components/unshield_dialog.dart`, `components/unshield_vbtc_dialog.dart`, `components/vbtc_balance_card.dart`

**sc_property (1):** `components/property_modal.dart`

**smart_contracts (16):** `components/sc_creator/common/help_button.dart`, `components/sc_creator/smart_contract_creator_main.dart`, `components/sc_evolve_dialog.dart`, `components/sc_property_dialog.dart`, `components/sc_wizard_card.dart`, `components/sc_wizard_card_preview.dart`, `components/sc_wizard_royalty_dialog.dart`, `features/evolve/evolve_modal.dart`, `features/royalty/royalty_modal.dart`, `features/soul_bound/soul_bound_modal.dart`, `features/ticket/ticket_modal.dart`, `screens/my_smart_contracts_screen.dart`, `screens/smart_contract_creator_container_screen.dart`, `screens/smart_contract_drafts_screen.dart`, `screens/smart_contract_wizard_screen.dart`, `screens/template_chooser_screen.dart`

**token (7):** `components/manage_token_navigator.dart`, `components/mint_tokens_button.dart`, `components/token_card.dart`, `components/token_form.dart`, `components/token_list.dart`, `components/transfer_tokens_button.dart`, `screens/token_management_screen.dart`

**l10n (5):** `app_en.arb`, `app_es.arb` (+96 lines each), `generated/app_localizations.dart`, `generated/app_localizations_en.dart`, `generated/app_localizations_es.dart`

**tests (4):** `test/features/auth/auth_type_modal_test.dart`, `test/features/navigation/root_container_side_nav_item_test.dart`, `test/features/nft/web_asset_thumbnail_test.dart`, `test/features/token/token_detail_row_test.dart`

## Not reviewed
- Visual spot-check in the running app (no layout change is possible from this diff).
- Unstaged phase 6 work in progress.

## Recommendation
Commit wave A after the one-token fix in WARN 1. Start wave B with the same scan; add the `lib/core` pass (INFO 3) to wave B's scope or run it as a short separate task. Queue the two pre-existing bug fixes (INFO 2) and the l10n consolidation (INFO 1) for after the sweep.
