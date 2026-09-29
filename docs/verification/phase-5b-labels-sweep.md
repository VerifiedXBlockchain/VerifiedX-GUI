# Phase 5 Wave B Verification — Labels Sweep: adnr, asset, beacon, bridge, chat, dst, encrypt, faucet, hd, keygen + lib/core pass (task 7)

**Phase:** 5, wave B of three — tooltips, button semantics, stable keys, `PromptModal` keys, widget tests
**Plan:** `docs/plans/automation-a11y-plan.md`
**Repo:** vfx-gui
**Branch:** `feat/automation-a11y` (wave B is STAGED in the index on top of the wave A commit; unstaged phase 6 work ignored)
**Base:** `testnet`
**Verifier:** reviewer agent (spawned by the orchestrator lead; no commit)
**Date:** 2026-09-26

## Verdict: **PASS WITH WARNINGS**

The feature sweep is complete: every live `IconButton` in the ten folders has a tooltip, every `InkWell`/`GestureDetector` with a handler is wrapped except the five dst checkbox-label toggles (the same class of skip accepted in earlier waves), the diff adds only `Semantics`, `ValueKey` and `Key` constructors plus the three repointed key usages, ARB parity holds at 3381 with the two new keys described and translated, the three removed keys have no reference left anywhere in `lib/` or `test/`, the staged `gen-l10n` output equals a fresh run, the analyzer set equals the baseline, and 214 tests pass including the four new ones, all of which assert something real. The `lib/core` changes are backward compatible: two optional null-default `Key?` parameters on `PromptModal.show` and `PasswordPromptService.promptAndVerifyPassword`, with the 101 existing `PromptModal.show` call sites untouched and a test that the default path stays unkeyed and the keyed submit still pops the value. One warning: the `lib/core` pass stopped at the two items the lead named, and my scan of `lib/core` shows the shared controls that would label the most screens are still bare: the `BackToHomeButton` used by 12 screens has no tooltip, and `AppVerticalIconButton` (7 files), `BigButton` (4 files) and `VBtcButton` render as text rather than buttons. On the cross-feature key reuse: accept as-is and fold the promotion into the post-sweep consolidation.

---

## Checks run

| Check | Result |
|---|---|
| `flutter analyze` | 390 issues, 0 errors; identical to the phase 1 baseline after stripping line:col |
| `flutter test test/core test/features` | 214 passed, 0 failed (lead: full suite 221 passing, only `test/widget_test.dart` failing) |
| `flutter gen-l10n` then `git diff -- lib/l10n/generated` | No difference; index restored |
| ARB parity (script) | en 3381, es 3381; new `chatSendMessage`, `mktCopyShopUrl` with descriptions and Spanish values; removed `prvBridgeHideDetails`, `prvBridgeShowDetails`, `prvRefresh` absent from both files |
| References to the removed keys (`grep -rn` over `lib/` and `test/`, generated excluded) | None |
| `r3eCopySignature` | Kept; used at `lib/core/utils.dart:495`. Correct call by the executor |
| Coverage scan (comments excluded) over the 16 wave B folders | Live `IconButton`: bridge 2, chat 12, dst 9, encrypt 1, keygen 3, all with `tooltip:`; tap targets with a handler: asset 1/1 wrapped, bridge 10/10 wrapped, dst 0/5 wrapped (documented skips) |
| Added constructors (`lib/`) | `Key(` 39, `ValueKey(` 24, `Semantics(` 11; `InkWell(` on `+` lines are re-indented openers |
| Removed lines that are not a bare opener | Exactly the three repointed usages (`prvRefresh` x2, `prvBridgeHideDetails`/`ShowDetails`) |
| Staged paths outside the declared scope | None |
| Files sampled in full diff | `bridge_preflight_form.dart`, `bridge_history_list.dart`, `bridge_history_item.dart`, `bridge_result.dart`, `bridge_progress.dart`, `encrypt/components/unlock_wallet.dart`, `encrypt/utils.dart`, `auth/screens/web_auth_screen.dart`, `keygen_cta.dart`, `asset_thumbnail.dart`, `new_chat_message.dart`, `my_collection_list_screen.dart`, `faucet_form.dart`, `create_adnr_dialog.dart`, `vfx_adnr_component.dart`, `web_adnr_screen.dart`, and the three `lib/core` files |

---

## 1. Coverage, layout, ARB, access pattern, keys

### 1a. Tooltips and wrappers
**PASS.** The five unwrapped `GestureDetector`s (`dst/components/create_listing_form_group.dart:106,137,168,199` and `dst/components/create_collection_form_group .dart:92`) each toggle a checkbox through its text label; a button role would misdescribe them. Wrapped targets carry a label only when their child is icon-only (`bridge_preflight_form.dart:474-477,632-635,646-649`, `bridge_result.dart:86-89,100-103`, `bridge_progress.dart:428-431,439-442`, `asset_thumbnail.dart:26-29` image branch) and none otherwise (`bridge_history_item.dart:80-82`, `_DetailsToggle`, the gas-funding refresh row), so no visible text is doubled.

### 1b. No layout or behaviour change
**PASS.** Only the three constructor kinds were added. The repointed strings ("Refresh", "Show details", "Hide details") are byte-identical in both languages between the removed `prv*` keys and the `action*` keys they now use, so nothing the user sees changed.

### 1c. ARB
**PASS.** `chat` is the chat feature's existing prefix (9 keys) and `mkt` is dst's (`mktGalleryOnly`, `mktEnableAuction`, ...). The removal of the three bridge keys is the consolidation the wave A review suggested, done cleanly.

### 1d. l10n access pattern
**PASS.** Added lines use `l10n.` where the file has a local (`keygen_cta.dart`, `bridge_result.dart`, `bridge_progress.dart`, `bridge_preflight_form.dart` `_Form`/`_GasFundingSection`) and `AppLocalizations.of(context)` where the file does (`new_chat_message.dart`, `my_collection_list_screen.dart`, `unlock_wallet.dart`, `bridge_preflight_form.dart` `_DetailsToggle`/`_NetworkInfo`, `lib/core/utils.dart`).

### 1e. Keys
**PASS.** `<feature>:<detail>` throughout: `adnr:{create,transfer,delete,domain_name,create_submit,transfer_address,transfer_submit}`, `auth:password`/`auth:password_submit`, `beacon:*`, `bridge:{amount,max,destination,review,done}`, `chat:{message,send}`, `faucet:{verification_code,verify,amount,phone,request}`, `hd:*`, `keygen:{import,generate,recover,email,email_submit,private_key,private_key_submit,mnemonic,mnemonic_submit,copy_mnemonic,copy_address,copy_private_key,done}`. Values that appear more than once (`adnr:create/transfer/delete` on the desktop component and the web screen; `auth:password` on the web unlock, the desktop unlock widget and `promptForPassword`; `keygen:email` on three sequential prompts) are never on screen at the same time.

---

## 2. The `lib/core` changes

| Check | Result |
|---|---|
| `PromptModal.show` signature (`lib/core/dialogs.dart:307-308`) | Two new named parameters `Key? fieldKey, Key? submitKey`, no default other than null; every one of the 101 existing call sites compiles unchanged (analyze clean) |
| Keys land on the right widgets | `key: fieldKey` on the `TextFormField` (`dialogs.dart:418`), `key: submitKey` on the confirm `TextButton` (`dialogs.dart:495`) |
| `PasswordPromptService.promptAndVerifyPassword` (`password_prompt_service.dart:17-18,31-32`) | Same two optional parameters, passed straight through; the only external caller (`web_auth_screen.dart:260`) now supplies them |
| Behaviour | `test/core/prompt_modal_test.dart`: keyed field and submit are found, entering text and tapping the keyed submit pops the dialog with the value; with no keys, the field and button exist and neither key is present |
| `AddressChoosingIconButton` (`lib/core/utils.dart:131`) | Tooltip `sendChooseAddressTitle` ("Choose an address"), the string phase 4 used for the same control in the send form |
| Unlock flows keyed | Web: `web_auth_screen.dart:264-265`. Desktop unlock widget: `unlock_wallet.dart:107` (field), `:156` (submit `IconButton`, plus tooltip "Unlock Account"). Desktop `promptForPassword`: `encrypt/utils.dart:107-108` |

Two secondary password prompts still go through `PromptModal` without keys: `passwordRequiredGuardV2` (`encrypt/utils.dart:49`; callers `token/components/change_token_ownership_button.dart:45`, `btc/components/tokenized_btc_action_buttons.dart:730`) and `PasswordPromptService.requirePasswordFor` (`password_prompt_service.dart:96`; callers `lib/core/utils.dart:143`, `auth/auth_utils.dart:830,1001`). See INFO 2.

---

## 3. The four tests

| Test | Asserts | Verdict |
|---|---|---|
| `test/core/prompt_modal_test.dart` | Keys applied when passed; keyed submit pops the entered value and closes the dialog; default call leaves field and button unkeyed | Meaningful: covers the compatibility contract and the behaviour path |
| `test/features/bridge/bridge_history_item_test.dart` | Row is a button, named by amount, destination and status, tap invokes the callback | Meaningful; uses the `rootNavigatorKey` reset from conventions so `globalL10n` falls back to English |
| `test/features/bridge/bridge_result_test.dart` | Copy icon labelled "Copy address" and explorer icon "View on Basescan", both buttons with tap; `bridge:done` tap invokes `onDone` | Meaningful |
| `test/features/asset/asset_thumbnail_test.dart` | Non-image branch: the file name is the accessible name, button, tap | Meaningful; the image branch (label "View asset" over a `PollingImagePreview` with no text, `asset_thumbnail.dart:48-51`) has no text to double, verified by reading |

---

## 4. Cross-feature key reuse: decision

`scwPickDate`/`scwPickTime` now serve dst (`create_listing_form_group.dart`, 4 uses) as well as smart_contracts (8 uses), and `nftViewAsset` serves asset (`asset_thumbnail.dart`) as well as nft. Under the rule recorded in phase 4 these are shared control labels and belong under `action*`.

**Recommendation: accept as staged; promote in one consolidation pass after wave C.** Wave C covers 22 more folders and will likely add further users of "Pick a date", "View asset" and "Open asset"; renaming now and again later is churn with no user-visible effect. The consolidation list so far: `scwPickDate`, `scwPickTime`, `nftViewAsset` (promote to `action*` and repoint), `scwOpenAsset`/`tkbOpenAsset` (merge under `action*`). `r3eCopySignature` stays as is (used in `lib/core`). `nftPauseMedia`/`r3hPause` stay separate (different actions).

---

## Conventions and hard constraints

| Rule | Status |
|---|---|
| l10n keys in both ARBs with descriptions, `gen-l10n` committed | 2/2, generated files in sync, 3 removals clean |
| Existing strings unchanged | Repointed usages render identical text; no value edited |
| No new analyzer issues | Same set as baseline |
| No new test failures | 214 pass; four new tests |
| No refactors, no behaviour change | `PromptModal` gains optional parameters only; wrappers, tooltips, keys otherwise |
| Tests alongside code | Yes, including the `lib/core` change |
| Report lists every file touched | See "Files reviewed" |
| Do not commit | Nothing committed |

---

## Findings

### WARN 1 — The `lib/core` pass leaves the shared controls that label the most screens
The executor did the two named items. My scan of `lib/core` (comments excluded) still finds:

| Control | Location | Used by | Gap | Fix |
|---|---|---|---|---|
| `BackToHomeButton` | `lib/core/components/back_to_home_button.dart:9` | 12 files | `IconButton` without tooltip | `tooltip: actionBack` (existing key) |
| `AppVerticalIconButton` | `lib/core/theme/components.dart:98` | 7 files (dashboard action buttons) | `GestureDetector` with a `Text` label, no button role: reads as text | `Semantics(button: true)` around the `GestureDetector` |
| `BigButton` | `lib/core/components/big_button.dart:40` | 4 files | `InkWell` with text, no role | same |
| `VBtcButton` | `lib/core/theme/components.dart:197` | 2 files | same | same |
| `PrettyIconButton` | `lib/core/theme/pretty_icons.dart:139` | 1 file (already wrapped externally in phase 4) | no role inside the component | `Semantics(button: true)` inside; the external wrapper merges harmlessly |
| Modal back/close buttons | `lib/core/dialogs.dart:42,879,911` | every dialog using them | `IconButton` without tooltip | `actionBack`, `actionClose` (existing keys) |
| Password reveal toggles | `lib/core/dialogs.dart:448,625` | `PromptModal` and one other dialog | `IconButton` without tooltip | one new key pair, e.g. `actionShowPassword`/`actionHidePassword` |

Not gaps: `idle_detector_wrapper.dart:128` (interaction detector, correctly not a button) and `simple_expandable_text.dart:38` (no usages).

These are one-line changes in seven files and they label or role every screen that composes them, which is more coverage than any single feature folder. Recommend adding them to wave C as a "lib/core components" item, before phase 6 starts driving flows through the dashboard's vertical buttons and the back arrows.

### INFO 1 — Cross-feature key reuse
Decision in section 4. Nothing to change in this wave.

### INFO 2 — Two secondary password prompts are unkeyed
`passwordRequiredGuardV2` and `requirePasswordFor` (locations in section 2) open the same `PromptModal` for reserve-account and sensitive operations. Passing the same `auth:password`/`auth:password_submit` pair is two lines each and lets a driven flow unlock through either prompt with one finder. Candidate for wave C with WARN 1.

### INFO 3 — Pre-existing issues the executor correctly left alone
- `adnr/screens/web_adnr_screen.dart`: hardcoded English confirmation bodies (an l10n gap, not a labels issue).
- `adnr/components/create_adnr_dialog.dart:124`: `address.length > 65` where the domain name was probably meant.
- `lib/features/dst/components/create_collection_form_group .dart` is tracked with a space in its name; it works but trips shell tooling. Rename in a separate commit.
Add the first two to the bug-fix commit queued after the sweep.

---

## Files reviewed (all 46 staged files)

**lib/core (3):** `dialogs.dart`, `services/password_prompt_service.dart`, `utils.dart`

**adnr (3):** `components/create_adnr_dialog.dart`, `components/vfx_adnr_component.dart`, `screens/web_adnr_screen.dart`

**asset (1):** `asset_thumbnail.dart`

**auth (1):** `screens/web_auth_screen.dart`

**beacon (3):** `components/add_beacon_modal.dart`, `components/create_beacon_modal.dart`, `screens/beacon_list_screen.dart`

**bridge (7):** `components/bridge_confirmation.dart`, `components/bridge_history_item.dart`, `components/bridge_history_list.dart`, `components/bridge_preflight_form.dart`, `components/bridge_progress.dart`, `components/bridge_result.dart`, `components/bridge_to_base_dialog.dart`

**chat (8):** `components/new_chat_message.dart`, `screens/buyer_chat_thread_list_screen.dart`, `screens/seller_chat_screen.dart`, `screens/seller_chat_thread_list_screen.dart`, `screens/shop_chat_screen.dart`, `screens/web_seller_chat_screen.dart`, `screens/web_seller_chat_thread_list_screen.dart`, `screens/web_shop_chat_screen.dart`

**dst (6):** `components/create_listing_form_group.dart`, `screens/create_collection_container_screen.dart`, `screens/create_dec_shop_container_screen.dart`, `screens/create_listing_container_screen.dart`, `screens/listing_auction_detail_screen.dart`, `screens/my_collection_list_screen.dart`

**encrypt (2):** `components/unlock_wallet.dart`, `utils.dart`

**faucet (1):** `components/faucet_form.dart`

**hd (1):** `components/restore_hd_wallet_button.dart`

**keygen (1):** `components/keygen_cta.dart`

**l10n (5):** `app_en.arb`, `app_es.arb`, `generated/app_localizations.dart`, `generated/app_localizations_en.dart`, `generated/app_localizations_es.dart`

**tests (4):** `test/core/prompt_modal_test.dart`, `test/features/asset/asset_thumbnail_test.dart`, `test/features/bridge/bridge_history_item_test.dart`, `test/features/bridge/bridge_result_test.dart`

## Not reviewed
- Visual spot-check in the running app (no layout change is possible from this diff).
- Unstaged phase 6 work in progress.

## Recommendation
Commit wave B as staged. Add the `lib/core` components item (WARN 1) and the two secondary password prompts (INFO 2) to wave C's scope, then run the l10n consolidation (INFO 1) and the bug-fix commit (INFO 3) after wave C.
