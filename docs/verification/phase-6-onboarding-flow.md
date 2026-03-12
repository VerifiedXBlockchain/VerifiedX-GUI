# Phase 6 Verification: Onboarding Flow Update

**Verdict: PASS WITH WARNINGS**

**File reviewed:** `lib/features/btc/providers/tokenized_btc_onboard_provider.dart` (modified)

---

## Checklist

| Requirement | Status | Notes |
|-------------|--------|-------|
| Replace `tokenizeBtc()` call with V2 ceremony flow | PASS | Listener changed from `tokenizedBitcoinListProvider` to `mpcCeremonyProvider` |
| Listener watches `mpcCeremonyProvider` for `contractCreated` | PASS | Lines 250-271 |
| On ceremony failure: error inline, user stays on step 5, can retry | PASS | Lines 265-269; resets processing state to `ready` |
| `waitingForTokenization` covers full ceremony + contract creation | PASS | Processing message updated to "MPC ceremony and contract creation in progress." |
| Token list refresh on `contractCreated` | PASS | Line 257: `ref.invalidate(tokenizedBitcoinListProvider)` |
| Wait for token to appear in list before advancing | PASS | Lines 273-290: `_waitForTokenInList()` listens to token list |
| Reset cleans up ceremony provider | PASS | Line 322: `ref.read(mpcCeremonyProvider.notifier).reset()` |
| Only 1 file modified | PASS | Only `tokenized_btc_onboard_provider.dart` changed |

## How the V2 Flow Works in Onboarding

The onboarding wizard embeds `TokenizeBtcForm` (Phase 5) for step 5. The flow:

1. User fills form, presses "Start Ceremony" -> Phase 5's `submit()` starts ceremony
2. Phase 5's `ref.listen` in `TokenizeBtcForm.build()` auto-calls `createContractFromCeremony()` on `ceremonyCompleted`
3. Phase 5's `ref.listen` calls `onSuccess()` on `contractCreated`
4. `onSuccess()` in onboarding = `setProcessingState(VBtcProcessingState.waitingForTokenization)`
5. This triggers `setupTokenizationListener()` -> watches `mpcCeremonyProvider` for `contractCreated`
6. When detected -> `_waitForTokenInList()` -> advances to step 6 when token appears

## Warnings

### 1. Timing issue in `setupTokenizationListener` (MEDIUM)

`setupTokenizationListener()` attaches a `ref.listen` on `mpcCeremonyProvider` to detect `contractCreated`. However, by the time this listener is set up (triggered by `onSuccess()` in `TokenizeBtcForm`), the ceremony state is **already** `contractCreated` -- the `onSuccess` callback only fires when `isContractCreated` is true (Phase 5 screen logic, line 61-63).

Riverpod's `ref.listen` only fires on **subsequent** state changes, not the current value. So the listener will miss the `contractCreated` state and never call `_waitForTokenInList()`.

**Impact:** The onboarding wizard will get stuck on step 5 with the "MPC ceremony and contract creation in progress" message, even though the contract is already created. The token will eventually appear in the list from background polling, but the wizard won't advance to step 6.

**Fix options (pick one):**
- Add `fireImmediately: true` to the `ref.listen` call at line 251
- Check the current ceremony state immediately after attaching the listener and call `_waitForTokenInList()` if already `contractCreated`
- Since `onSuccess` only fires when contract is already created, skip the ceremony listener entirely and call `_waitForTokenInList()` directly from `setupTokenizationListener()`

### 2. `_waitForTokenInList` subscription not stored (LOW)

The `ref.listen` at line 275 inside `_waitForTokenInList()` does not store its return value in a field. Unlike the other listeners (`vfxTransferListener`, `btcTransferListener`, `ceremonyCeremonyListener`, `btcToVbtcListener`), this subscription cannot be explicitly cancelled in `reset()`.

**Impact:** Low. The Riverpod provider lifecycle will handle cleanup when the provider is disposed, and the listener has a guard clause (`state.step == VBtcOnboardStep.tokenize`), but a stale listener could accumulate if `reset()` is called and the wizard restarted multiple times. Not a functional bug, but a resource cleanup concern.

## Changes Summary

| Change | Description |
|--------|-------------|
| Import added | `mpc_ceremony_provider.dart` |
| Listener type changed | `btcTokenizationListener` (TokenizedBitcoin list) -> `ceremonyCeremonyListener` (MpcCeremonyState) |
| `setupTokenizationListener()` rewritten | Now watches ceremony provider for `contractCreated` and `failed` |
| New `_waitForTokenInList()` method | Listens for token to appear in list after contract creation |
| Processing message updated | "Waiting for vBTC Tokenization to compile." -> "MPC ceremony and contract creation in progress." |
| `reset()` enhanced | Closes `ceremonyCeremonyListener`, resets `mpcCeremonyProvider` |
| Old transaction check removed | No longer checks for transaction in list to verify tokenization success |

## No Regressions

- All other listeners (`vfxTransferListener`, `btcTransferListener`, `btcToVbtcListener`) unchanged
- All other steps (1-4, 6) unchanged
- State class, enums, step titles, step details all preserved (except tokenization processing message)
- `transferBtcToVbtc()` unchanged
