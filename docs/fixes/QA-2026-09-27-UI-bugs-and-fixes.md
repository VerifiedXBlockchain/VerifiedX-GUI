# QA 2026-09-27: UI bugs and how we're fixing them

Every GUI and web wallet issue from today's testnet QA run (MTI numbers from the QA chat), with the cause we found and the fix. Core issues are left out unless they changed what the UI needs.

- **Branch:** `fix/qa-ui-20260927`, PR into `testnet`.
- **Checks on the branch:** analyzer 0 errors (373 issues before, 364 after), tests 541 passing (498 before), the only failure is the old default counter test that already failed on 7.0.5. Web release build passes. macOS debug build compiles (it stops at signing on my machine).
- **Tested against:** Core 8.0.1 (7.0.5 build) on testnet. The branch is rebased onto `testnet` (5d357000); the release/signing commits on `feat/macos-notarization` are not part of it.

## Summary

| MTI | Surface | Bug | Fix | Status |
|---|---|---|---|---|
| #8, #6, #7 | Mac | No password prompt when the node has cleared the unlock (401 on ~70 actions) | Central 401 handler: prompt once, retry once | Committed, passes in the app (incl. concurrent calls and MTI#6) |
| #7.2, #2.2, #8 | Mac + web | Raw `DioException` / English node text in toasts | One error-message helper, node reason shown with a translated lead-in | Committed, passes in the app (incl. Spanish lead-in) |
| #2.5, #10.1 | Mac | Withdraw dead-ends on an expired or unpayable request; no explanation for the missing Cancel | Classify the pending request, explain it, let the user open the form | Committed, unit/widget tests; the expired/unpayable state couldn't be recreated in the app |
| #7.3 | Mac | Bridge preflight Retry and 10 s refresh do nothing after an error | `ref.refresh` instead of `ref.invalidate` | Committed, passes in the app |
| #5 | Web | vBTC tab crashes Chrome ("Aw, Snap!") | Never decode the 1080x1080 default GIF; bundled stills instead | Committed (`1b213f22`), passes in Chrome |
| F6 | Mac + web | Untranslated strings in the smart contract creator | Moved to l10n with Spanish | Committed, passes in the app |
| F7 | Mac | App doesn't show that the wallet locked itself again | Lock indicator + prompt before protected actions (Aaron's suggestion) | Planned |

## MTI#8, #6, #7: no password prompt on a locked wallet

**What happens.** The node keeps the unlock password for `PasswordClearTime` (10 min). After that, Core's `LockedWalletPolicy` answers 401 "You must type in your encryption password first!" to every route outside `AllowedWhileLocked`. Around 70 native actions call such a route without `passwordRequiredGuard` (vBTC withdraw/transfer/ownership, tokenize, privacy, vaults, tokens, NFTs, shop and chat, and more; full list with file:line in `docs/fixes/MTI8-missing-password-prompt.md`). The user sees a raw DioException toast, a generic error, or nothing. MTI#6: `passwordRequiredGuard` trusted a cached state that refreshes every 10 s, and right after encrypting Core keeps the password in memory (`GetEncryptWallet`), so the wallet stayed unlocked.

**Fix (commits `346b269f`, `1a8be020`).**
- New `lib/core/services/locked_wallet_gate.dart`. `BaseService` (`getText`, `getJson`, `postJson`, `patchJson`, `deleteJson`) sends native calls to the local node through it. On a 401 with the locked-wallet body it prompts for the password once and retries the same request once. Retrying is safe: the node refuses before anything is signed or broadcast.
- Concurrent 401s share one prompt. Requests made by the unlock flow itself skip the gate (no deadlock). `postFormData` isn't wrapped because its body can only be sent once. The background CLI update check never prompts.
- If the user cancels, the call fails with `WalletLockedException` (extends DioException so existing handlers still catch it), shown as "Your wallet is locked. Unlock it with your password and try again." (translated).
- The prompt (`unlockForLockedRequest` in `lib/features/encrypt/utils.dart`) is registered from `lib/app.dart`, so `BaseService` stays free of UI code. It doesn't prompt while the startup unlock screen is up, and it hides the global loading overlay while the dialog is open.
- `passwordRequiredGuard` now asks the node every time and only falls back to the cached state if that call fails.
- MTI#6: after a successful encrypt, the app locks the wallet (`GetEncryptLock`), same as the manual Lock button, so the next protected action asks for the password. If the node is validating, Core refuses the lock and the wallet stays unlocked. **Product call for you:** this means users type the new password again right after setting it.

**Tested in the app (driver build, testnet).**
- Wallet locked, vBTC Withdraw submitted: the Unlock Account prompt appears. Cancel: red toast with the locked message (Spanish too: "Tu billetera está bloqueada..."), no DioException. Unlock: the same request is retried once and reaches the node, which refused it for the fee floor, as expected.
- Concurrency: two Prove Ownership calls in flight while locked gave exactly one prompt; after one unlock both finished.
- MTI#6: on a fresh unencrypted wallet, Encrypt Wallet then Reveal Private Key right away shows the Unlock Account prompt; the button reads "Unlock Wallet" and the node reports the password as not stored.
- Related Core behaviour to know for F7: the node clears the password on a fixed timer that starts when the node starts (`ClientCallService.cs` ~l.68: first run at +5 s, then every `PasswordClearTime`), not 10 minutes after the unlock. An unlock at 20:32:24 was cleared at 20:34:34. So "Account unlocked for 10 minutes" can overstate the window.

## MTI#7.2, #2.2, #8: raw or untranslated error text

**What happens.** Services returned `e.toString()` as the user message, so toasts showed `DioException [bad response] ...`. On web, a vBTC withdrawal failure showed "Withdrawal request failed" or a hardcoded English `'Withdrawal request failed: $e'` instead of Spyglass's reason. Node messages appeared in English inside the Spanish UI.

**Fix (commits `346b269f`, `1a8be020`, `cb979e4a`).**
- New `lib/core/utils/user_error_message.dart`: `userErrorMessage(e)` returns the locked message for `WalletLockedException`, the node or Spyglass reason when the body has one (plain text or `Message`/`message`/`detail`/`error`/`title`, capped at 400 chars), a translated "can't reach the node" for connection errors and timeouts, or a translated generic message. It never returns text containing "DioException".
- Node text gets a translated lead-in (`errNodeReason`, Spanish "Mensaje del nodo: ...").
- Used in the catch blocks of `btc_service`, `vbtc_v2_service`, `reserve_account_service`, `smart_contract_service`, `explorer_service`, `btc_web_service_web`, `adnr_service`, `bridge_service`, `faucet_form_provider`, and the privacy providers. The privacy providers no longer treat a locked-wallet error as a shielded-password error.
- Web (#2.2): the ExplorerService V2 transfer, withdrawal-request and cancel calls rethrow, so Spyglass's `{success:false, message}` reaches the helper; the withdrawal dialog now shows it (including the existing "already in progress" notice).
- Not changed: a few English strings in `web_token_actions_manager` ("Completion transaction failed", "FROST signing failed").
- Refusals the node sends as HTTP 200 `{"Success":false,"Message":...}` (fee floor, transfer and withdrawal refusals, bridge preflight) go through `nodeRefusalMessage()`, the same treatment with the lead-in (commit `cb979e4a`). This gap was found by the in-app test; after the fix the Spanish app shows "Mensaje del nodo: vBTC V2 withdrawal request: 0.0000001 BTC cannot pay...".

## MTI#2.5, #10.1: withdrawal dialogs

**What happens.** #2.5: Withdraw showed "Pending withdrawal found" whenever the contract had an active request, with only Complete or Dismiss, so an expired or unpayable request blocked the form for good. (Core now clears expired requests from `GetContractList`, so this mostly stopped, but the UI still had no expiry check.) #10.1: Cancel only shows when the withdrawal has a BTC transaction, so an unpayable request has no Cancel and no explanation.

**Fix (commit `d01c2eea`).**
- New `EscrowedWithdrawal` model reads `EscrowedWithdrawals` from `GetVBTCBalance` (Expired, Unpayable, CancellationPending, from Core 6605b537). `classifyPendingWithdrawal` decides: open the form, offer Complete, expired, or unpayable.
- For this wallet's expired or unpayable request, a dialog explains it can't be completed and that the vBTC stays in escrow until a cancel is approved (or that a cancel is already pending), with "Open Withdrawal Form" and "Close".
- The Complete prompt is unchanged for a live request, an older node, or a failed lookup.
- Processing dialog: an unpayable failure no longer offers Retry, and explains why there's no Cancel. Buttons wrap instead of overflowing the 450 px dialog.
- Note: since Aaron's 9601f132, validators vote on cancels automatically (retested: approved 10 of 13 in about 2 minutes). A Cancel button for unpayable requests could now be added.

## MTI#7.3: bridge preflight Retry does nothing

**What happens.** After the preflight failed, the 10 s refresh stopped and Retry sent no request; only reopening the modal refetched.

**Cause.** All of them called `ref.invalidate(bridgePreflightProvider(_args))`. In Riverpod 2.3.7 that only marks the provider dirty and leaves the refetch to the scheduler on a later frame; while that refetch is pending, further `invalidate` calls return early. Reopening the modal worked because a fresh `ref.watch` read forces it.

**Fix (commit `11c104c4`).** The poll, the gas Refresh button and all three Retry callbacks call `_refetch()`, which uses `ref.refresh(...)` and sends the request right away. Widget test `test/features/bridge/bridge_preflight_retry_test.dart` fails on the old code and passes now.

**Tested in the app.** Node stopped with the modal open: error state; each Retry press sent a new request, the 10 s refresh kept running, and when the node came back the modal recovered without reopening (twice). Two things noticed: a freshly started node takes 25 to 35 s to answer the preflight, and the 10 s poll replaces the request in flight, so recovery waits until one answers; and once the modal opened and closed itself after the first preflight (cause not found).

## MTI#5: web vBTC tab crashes Chrome

**What happens.** Chrome's renderer aborts (`SkBitmap.cpp:252 tryAllocPixels [w:1080 h:1080]`, "Aw, Snap!" error 5). The default token image is `https://vfx-resources.s3.amazonaws.com/defaultvBTC.gif`, 1080x1080 with about 120 frames, used by 16 of the 17 testnet tokens.

**What we learned while fixing it.**
- The crashes (this morning and in tonight's retest) happened on the token **detail** screen, which plays the GIF. One animated 1080x1080 GIF is enough, because every frame is decoded at full size.
- First attempt (commit `c03cabda`): fetch as bytes and decode at display size with `ResizeImage` (plus a first-frame-only provider in lists). It still crashed with the same dump: Chrome's ImageDecoder ignores the requested size for GIFs.
- With stills only in the list, the detail screen still swung between 0.3 and 1.1 GB.

**Fix (commit `1b213f22`).** `WebVbtcTokenImage` never decodes the default GIF: it shows its first frame from bundled files, 256 px (list) or 512 px (detail, sharp at 2x). The 1920 px fallback logo is shrunk to 256 px too. Custom token images still load from the network. In Chrome tonight the tab stayed around 200 to 260 MB with no crash, against 300 MB to 1.1 GB and a crash before.

**Trade-off.** The detail screen no longer animates. To keep the animation, host a small animated version (for example 256 px) on S3 and point the default at it.

## F6: untranslated strings

**Fix (commit `f63161fc`), passes in the app in Spanish.** The smart contract creator's `isValidForCompile()` hardcoded "- Asset is required" and similar; the Spanish keys already existed and are now used. The compile animation's "Minted!" / "Compiled!" use new keys ("¡Emitido!" / "¡Compilado!"). Test: `test/features/smart_contracts/sc_compile_l10n_test.dart`.

## F7 (planned): show that the wallet locked itself

From Aaron's comment in the QA chat: the 401 is intended; the problem is the user can't see the wallet has locked. Plan: a lock indicator driven by `passwordRequiredProvider` (which already asks the node every 10 s, so the GUI doesn't need to know `PasswordClearTime`), and a prompt before protected actions. The 401 handler above stays as the safety net for the 10 s gap and for routes added later.

## Also noticed in the app test

- Spanish only: a debug "BOTTOM OVERFLOWED BY 12 PIXELS" stripe at the Operations footer ("Documentación").

## Not fixed on our side

- **MTI#2.3 / #2.6 (Spyglass):** expired withdrawal requests still show as "requested" (request #16 on round 3 web).
- **MTI#9.3:** no UI change needed; the app shows the node's `AvailableBalance`, which Core 38e73942 fixed.
- **Mac build:** the 7.0.4 I installed was signed with an Apple Development certificate and `spctl` rejects it, so new users need the xattr step.
- **GUI calls two routes that don't exist in Core:** `/GenerateTokenizedAddress` (`btc_service.dart` ~l.425) and `/DownloadNftAssets` (`smart_contract_service.dart` ~l.254). Not checked whether a user can reach them.
