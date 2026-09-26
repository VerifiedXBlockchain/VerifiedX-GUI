# Phase 5 Wave D Verification — ListTile Button Roles (task 7 follow-up)

**Phase:** 5, wave D — `Semantics(button: ...)` around every tappable `ListTile`, from the wave C review's WARN 1
**Plan:** `docs/plans/automation-a11y-plan.md`
**Repo:** vfx-gui
**Branch:** `feat/automation-a11y` (wave D is STAGED in the index on top of the wave C commit `92e53925`; no unstaged changes)
**Base:** `testnet`
**Verifier:** reviewer agent (spawned by the orchestrator lead; no commit)
**Date:** 2026-09-26

## Verdict: **PASS**

The pass is complete and exact. My own rescan finds 111 `ListTile`s whose own `onTap` is non-null across `lib/features` and `lib/core`, and all 111 are wrapped: the 106 added here plus the 5 phase 4 login tiles. The wave C count of 114 unwrapped included 8 tiles whose only tap lives on an inner icon, which the rescan now distinguishes by reading only the tile's top-level arguments. The whitespace-insensitive diff contains nothing but `Semantics(`, `button:`, `child: ListTile(` and closing lines, and every removed line is a bare `ListTile(` opener. A structural check of all 106 new wrappers confirms each `Semantics` takes exactly `button:` and `child:`, with its `ListTile` as the direct and only child, so no tile argument or key moved onto the wrapper. Each of the eight conditional roles matches its tile's `onTap` nullability exactly. The two files the executor's first scripted pass corrupted are correct. Analyze is at the baseline and 188 feature tests pass, including the two new tests, which pin both the positive and the negative case.

---

## Checks run

| Check | Result |
|---|---|
| `flutter analyze` | 390 issues, 0 errors; identical to the phase 1 baseline after stripping line:col |
| `flutter test test/features` | 188 passed, 0 failed (lead: full suite 230 passing, only `test/widget_test.dart` failing) |
| Staged paths | 49 files, all under `lib/features/`, `lib/core/` or `test/`; no unstaged changes |
| Whitespace-insensitive diff, `lib/` | Added lines: only `Semantics(` / `return Semantics(` / `child: Semantics(`, `button: <expr>`, `child: ListTile(`, and closers. Removed lines: only `ListTile(` / `return ListTile(` openers |
| `button:` expressions | 98 `true`, 8 conditional (section 2) |
| Rescan (top-level `onTap` of each `ListTile`, comments excluded, `CheckboxListTile` excluded) | 111 with a non-null own `onTap`, 111 wrapped, 0 unwrapped |
| Structural check of the 106 new `Semantics > ListTile` wrappers | Top-level arguments exactly `{button, child}`; the `ListTile` call closes immediately before the `Semantics` closes; 0 problems |

---

## 1. Coverage and layout

**PASS.** Per feature, matching the executor's counts: wallet 19, root 9, reserve 9, token 8, btc 8, home 8, btc_web 7, mother 6, smart_contracts 5, web_shop 4, auth 3 (plus the 5 from phase 4), dst 3, privacy 3, remote_shop 3, web 3, asset 2, chat 2, nft 1, transactions 1, voting 1, core 1. `Semantics` without a label is a `RenderProxyBox` with no size or paint effect, so no layout can change.

Skips are correct:
- The 4 `CheckboxListTile`s: the framework already exposes them as checkboxes with a checked state, and a button role would misdescribe them.
- The 8 tiles with no `onTap` of their own: their tappable icon was wrapped in earlier waves, and wrapping the tile would give a role to a row that does nothing on tap.

---

## 2. Conditional roles

Each `button:` must be true exactly when the tile's `onTap` is non-null. All eight match:

| Site | `button:` | `onTap` | Match |
|---|---|---|---|
| `token/components/token_list_tile.dart:65` | `interactive` | `interactive ? () async {...} : null` | Exact |
| `btc_web/screens/web_tokenized_btc_detail_screen.dart:232` | `isRequested \|\| unrecorded != null` | `isRequested \|\| unrecorded != null ? () {...} : null` (line 244) | Exact |
| `dst/components/create_dec_shop_form_group.dart:58` | `model.id == 0` | `model.id == 0 ? () async {...} : null` | Exact |
| `transactions/components/web_transaction_card.dart:66` | `!tx.isPending` | `tx.isPending ? null : () {...}` (line 140) | Exact |
| `smart_contracts/components/sc_creator/modals/feature_chooser_modal.dart:171` | `feature.isAvailable` | `feature.isAvailable ? () {...} : null` | Exact |
| `wallet/components/manage_wallet_bottom_sheet.dart:132` (BTC row) | `!isSelected` | `isSelected ? null : () {...}` | Exact; key `btc_wallet_<address>_<isSelected>` stays on the `ListTile` |
| `wallet/components/manage_wallet_bottom_sheet.dart:266` (VFX row) | `!isSelected` | `isSelected ? null : () {...}` | Exact; key `vfx_wallet_<address>_<isSelected>` stays on the `ListTile` |
| `nft/components/nft_list_tile.dart:70` | `onPressedOverride != null \|\| !(isBurned \|\| (isTransferred && !manageOnPress))` | `onPressedOverride ?? (isBurned \|\| (isTransferred && !manageOnPress) ? null : () {...})` | Exact: the `??` yields non-null iff the override is non-null or the inner condition is false |

---

## 3. Nested tiles and the two re-done files

**PASS.**
- `token/components/token_list_tile.dart`: the outer tile is wrapped with `button: interactive`, and the topic tiles built inside the voting bottom sheet (a separate route, not a child in the widget tree) are wrapped with `button: true`. The re-indentation in the full diff is exactly the two wrapper levels; the whitespace-insensitive diff is wrapper lines only, and the `onTap: interactive ? ... : null` block is unchanged.
- `token/screens/token_management_screen.dart`: the two action tiles in the topics sheet ("Create topic", "View topics") and the per-topic tiles in the nested sheet opened from "View topics" are each wrapped once, with their `onTap` bodies unchanged (including the double `pop()`).
- Trailing controls inside a wrapped tile (`TransferTokensButton`, `BurnTokensButton`, the voting `AppButton`) keep their own nodes because their tap actions conflict with the tile's, so wrapping the tile does not absorb them. `test/features/token/token_list_tile_test.dart` confirms the tile's node carries only the title and balance as its label.

---

## 4. Tests

| Test | Asserts | Verdict |
|---|---|---|
| `test/features/wallet/manage_wallet_list_tile_test.dart` | Unselected row: found by its kept key, named by its visible label and address, button with tap, tapping switches the session's wallet (through a stub `SessionProvider` that never starts the CLI). Selected row: neither button nor tap | Meaningful; pins the conditional role in both directions and proves the key stayed on the `ListTile` |
| `test/features/token/token_list_tile_test.dart` | Interactive row: named "[TKR] Test Token ... Balance: 12.5", button with tap. Non-interactive row: neither | Meaningful; pins the conditional role in both directions |

The positive cases fail without the wrappers, because a bare `ListTile` in 3.7.12 contributes a tap action but no `isButton` flag; that is why the phase 2 browser session saw the login tiles as `text`. This matches the executor's report that both files fail with the wrappers removed.

---

## Conventions and hard constraints

| Rule | Status |
|---|---|
| No new analyzer issues | Same set as baseline |
| No new test failures | 188 pass in `test/features`; two new test files |
| No layout, behaviour or string change | Wrappers only; no ARB change |
| No refactors | None |
| Tests alongside code | Both conditional patterns are pinned |
| Keys on the control, following earlier waves | Keys stay on the `ListTile`; structural check confirms nothing moved to the wrapper |
| Do not commit | Nothing committed |

---

## Findings

No warnings.

### INFO 1 — The NFT tile's role duplicates its tap condition
`nft/components/nft_list_tile.dart:70` restates the `onTap` logic as a boolean. It is correct today, but a later edit to one expression and not the other would give the row a button role without a tap, or the reverse. Hoisting the condition into a local such as `final canTap = onPressedOverride != null || !(...)` used by both would remove the drift risk. That is a small refactor, so it belongs in a later change, not in this wave.

### INFO 2 — Phase 5 is complete
With this wave, every tap target class the sweep set out to cover carries a name and the correct role: `IconButton` tooltips, icon-only `InkWell`/`GestureDetector` targets, the `lib/core` components, and now every tappable `ListTile`. The remaining post-merge queue from the wave C report is the bug-fix commit (the `sc_wizard_card.dart` description condition, the `btcWifCopiedToast` toasts, the `create_adnr_dialog.dart` length check, the filter-sheet overflow and its test workaround, the hardcoded adnr and remote_shop strings) and the dead-code cleanup.

---

## Files reviewed (all 49 staged files)

**lib/core (1):** `components/language_selector.dart`

**asset (1):** `download_or_associate_asset.dart`. **auth (2):** `auth_utils.dart`, `components/imported_key_accounts_dialog.dart`

**btc (2):** `components/tokenized_btc_action_buttons.dart`, `screens/tokenized_btc_list_screen.dart`

**btc_web (5):** `components/web_btc_create_wallet_modal.dart`, `components/web_btc_tokenized_action_buttons.dart`, `components/web_btc_transaction_list_tile.dart`, `components/web_tokenized_btc_list_tile.dart`, `screens/web_tokenized_btc_detail_screen.dart`

**chat (2):** `components/buyer_chat_thread_list.dart`, `components/seller_chat_thread_list.dart`

**dst (3):** `components/collection_list.dart`, `components/create_dec_shop_form_group.dart`, `components/listing_list.dart`

**home (3):** `components/home_buttons/backup_button.dart`, `screens/all_tokens_screen.dart`, `screens/web_home_screen.dart`

**mother (1):** `components/mother_modal.dart`. **nft (1):** `components/nft_list_tile.dart`

**privacy (3):** `components/privacy_settings_menu.dart`, `components/unshield_dialog.dart`, `components/unshield_vbtc_dialog.dart`

**remote_shop (3):** `components/listing_details_list_tile.dart`, `components/remote_shop_details.dart`, `components/remote_shop_list_tile.dart`

**reserve (2):** `screens/manage_reserve_accounts_screen.dart`, `screens/web_reserve_account_overview_screen.dart`

**root (1):** `navigation/components/web_drawer.dart`

**smart_contracts (4):** `components/sc_creator/modals/feature_chooser_modal.dart`, `components/sc_wizard_list.dart`, `screens/my_smart_contracts_screen.dart`, `screens/smart_contract_drafts_screen.dart`

**token (4):** `components/token_list_tile.dart`, `components/web_token_list.dart`, `components/web_token_management_actions.dart`, `screens/token_management_screen.dart`

**transactions (1):** `components/web_transaction_card.dart`. **voting (1):** `components/topic_list_tile.dart`

**wallet (2):** `components/manage_wallet_bottom_sheet.dart`, `utils.dart`

**web (1):** `components/web_multi_account_selector.dart`

**web_shop (4):** `components/web_collection_list_tile.dart`, `components/web_listing_detail_tile.dart`, `components/web_listing_list_tile.dart`, `components/web_shop_list_tile.dart`

**tests (2):** `test/features/token/token_list_tile_test.dart`, `test/features/wallet/manage_wallet_list_tile_test.dart`

Sampled in full or by wrapper context beyond the conditional sites: `token_list_tile.dart`, `token_management_screen.dart`, `wallet/utils.dart`, `web_drawer.dart`, `mother_modal.dart`, `all_tokens_screen.dart`, `web_reserve_account_overview_screen.dart`, `web_multi_account_selector.dart`, `language_selector.dart`, `tokenized_btc_action_buttons.dart`, `nft_list_tile.dart`, `web_transaction_card.dart`.

## Not reviewed
- Visual spot-check in the running app (no layout change is possible from this diff).

## Recommendation
Commit wave D as staged. Phase 5 is complete; the remaining work is the queued bug-fix commit and dead-code cleanup, plus the optional hoist in INFO 1.
