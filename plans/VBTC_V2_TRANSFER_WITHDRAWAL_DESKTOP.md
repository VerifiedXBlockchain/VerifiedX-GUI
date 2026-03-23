# vBTC V2 Transfer & Withdrawal — Desktop Plan

## Scope

Implement vBTC V2 token transfer and withdrawal operations on the desktop wallet. The CLI handles all heavy lifting (FROST signing, validator coordination, BTC broadcast). The GUI calls the new `/vbtcapi/vbtc` endpoints and provides appropriate UX.

**Out of scope:** Web wallet (separate plan), bulk/multi-token transfers (TBD with blockchain dev), withdrawal cancellation UI, V1 code changes (V1 remains fully functional).

**Prerequisite:** Desktop creation plan (Phases 1-2 at minimum — `VbtcV2Service` and ceremony model must exist).

---

## Key V1 → V2 Differences

### Transfer
- V1: `POST /btcapi/BTCV2/TransferCoin` — single step, simple POST
- V2: `POST /vbtcapi/vbtc/TransferVBTC` — single step, nearly identical but different endpoint and field names
- **UX impact:** Minimal. Same modal, same fields, same flow. Just routes to a different service method.

### Ownership Transfer
- V1: `GET /btcapi/BTCV2/TransferOwnership/{scUid}/{toAddress}`
- V2: `GET /vbtcapi/vbtc/TransferOwnership/{scUID}/{toAddress}`
- V2 adds: contract must have balance > 0, beacon connectivity required
- **UX impact:** Minimal. Same action, slightly different validation errors possible.

### Withdrawal
- V1: Single step — `POST /btcapi/BTCV2/WithdrawalCoin` (hardcoded fee rate)
- V2: Two steps — `RequestWithdrawal` → `CompleteWithdrawal` (user-transparent, auto-chained)
- V2 `CompleteWithdrawal` triggers FROST signing ceremony (takes time)
- V2: Per-user guard — only 1 active withdrawal per user/contract
- **UX impact:** Significant. Fee rate auto-calculated (not hardcoded), processing indicator for FROST signing, two API calls chained automatically.

### Balance Model
- V1: `balance` and `myBalance` fields
- V2: Owner gets `depositBalance + ledgerDelta`, non-owner gets `ledgerDelta` only
- **UX impact:** None for now — the CLI calculates available balance server-side. GUI displays what the API returns.

---

## Version Routing Strategy

The CLI distinguishes V1 and V2 via the smart contract feature type:
- `FeatureName.Tokenization` = V1 (arbiter-based)
- `FeatureName.TokenizationV2` = V2 (MPC/FROST-based)

The `TokenizationV2Feature` model has an explicit `Version = 2` field.

### Approach

Add a `version` field to the `TokenizedBitcoin` model. When the CLI returns token data, parse the version from the response. Route action button calls to either `BtcService` (V1) or `VbtcV2Service` (V2) based on this field.

**If the CLI doesn't yet include version in `GetTokenizedBTCList` responses:** Default to V1 and add V2 routing once the field is available. The V2 service methods will be ready to use.

---

## Phase 1: Extend `VbtcV2Service` with Transfer & Withdrawal Methods

**Modify:** `lib/features/btc/services/vbtc_v2_service.dart` (created in the creation plan)

Add the following methods:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `transferVbtc({scUid, fromAddress, toAddress, amount})` | `POST /TransferVBTC` | Transfer vBTC balance between VFX addresses |
| `transferOwnership({scUid, toAddress})` | `GET /TransferOwnership/{scUID}/{toAddress}` | Transfer contract ownership |
| `requestWithdrawal({scUid, requestorAddress, btcAddress, amount, feeRate})` | `POST /RequestWithdrawal` | Step 1: Create withdrawal request on-chain |
| `completeWithdrawal({scUid, withdrawalRequestHash})` | `POST /CompleteWithdrawal` | Step 2: Trigger FROST signing + BTC broadcast |

### `transferVbtc` — straightforward POST, returns success/failure + transaction hash.

### `transferOwnership` — GET request, returns success/failure. Note the response says "Transfer has been started" (async beacon upload).

### `requestWithdrawal` — POST, returns `RequestHash` on success (needed for step 2).

### `completeWithdrawal` — POST, returns `VFXTransactionHash` + `BTCTransactionHash`. This is the slow step (FROST signing). May take several seconds to a minute+.

### Combined withdrawal helper

```
Future<WithdrawalResult> withdraw({scUid, requestorAddress, btcAddress, amount, feeRate})
```

Chains both steps: calls `requestWithdrawal`, then immediately calls `completeWithdrawal` with the returned `RequestHash`. Returns a combined result with both hashes. This is what the UI calls — the user never sees the two-step split.

**Files touched:** 1 existing file modified

---

## Phase 2: Withdrawal Result Model

**New file:** `lib/features/btc/models/withdrawal_result.dart`

Simple model (doesn't need freezed — just a data holder):

```
Fields:
- success: bool
- message: String?
- vfxTransactionHash: String?
- btcTransactionHash: String?
- requestHash: String?
- status: String? (e.g., "Pending_BTC")
```

**Files touched:** None (new file only)

---

## Phase 3: Withdrawal Processing Dialog

**New file:** `lib/features/btc/components/withdrawal_processing_dialog.dart`

A dismissible dialog shown during the `CompleteWithdrawal` FROST signing step:

- Text explaining what's happening: "Processing withdrawal — validators are signing the Bitcoin transaction..."
- A circular progress indicator
- **Dismissible** — user can close it; the operation continues in the background
- **No cancel button** — withdrawal cannot be cancelled mid-signing
- When the `withdraw()` future completes:
  - If dialog is still open: update to show success/failure with an "OK" button
  - If dialog was dismissed: show a toast with the result

This is simpler than the MPC ceremony modal (no multi-round progress tracking). It's essentially a "please wait" dialog with a result state.

**Files touched:** None (new file only)

---

## Phase 4: Version Field on `TokenizedBitcoin` Model

**Modify:** `lib/features/btc/models/tokenized_bitcoin.dart`

Add an optional version field:

```dart
@JsonKey(name: "Version") @Default(1) int version,
```

Defaults to `1` so existing V1 tokens that don't include the field still work. When the CLI returns V2 tokens with `Version: 2`, it will be parsed automatically.

Run `fvm dart run build_runner build --delete-conflicting-outputs` after this change.

**Files touched:** 1 existing file modified

---

## Phase 5: Route Action Buttons by Version

**Modify:** `lib/features/btc/components/tokenized_btc_action_buttons.dart`

Update the three action flows to route by `token.version`:

### Transfer vBTC (shares)
- V1 (unchanged): `BtcService().transferTokenShares()`
- V2: `VbtcV2Service().transferVbtc()` — same modal, same form fields, different service call

### Ownership Transfer
- V1 (unchanged): `BtcService().transferTokenOwnership()`
- V2: `VbtcV2Service().transferOwnership()` — same action, different endpoint

### Withdrawal
- V1 (unchanged): `BtcService().withdrawCoin()` with hardcoded `BTC_WITHDRAWL_FEE_RATE`
- V2: `VbtcV2Service().withdraw()` (combined helper) with auto-calculated fee rate
  - Remove the hardcoded fee rate note from the modal for V2
  - Show the withdrawal processing dialog during `CompleteWithdrawal`
  - On success: show both VFX and BTC transaction hashes

### Routing pattern

```dart
if (token.version >= 2) {
  // V2 path
} else {
  // V1 path (existing code, unchanged)
}
```

Keep V1 code paths intact — don't refactor them. Just add V2 branches.

**Files touched:** 1 existing file modified

---

## Phase 6: Fee Rate Handling for V2 Withdrawals

V2 requires a `FeeRate` (sats/vB) for the `RequestWithdrawal` call. Per direction: auto-calculate a sensible default rather than asking the user.

**Approach options (in order of preference):**

1. **Use a sensible hardcoded default** (e.g., 10 sats/vB — "medium" priority). Simple, no extra API call. Can be extracted as a constant `VBTC_V2_DEFAULT_FEE_RATE` for easy adjustment.

2. **Fetch from a fee estimation endpoint** if the CLI provides one (e.g., the existing `/btcapi/BTCV2/CalculateFee` or a Bitcoin fee estimator). This would give a more accurate rate but adds complexity.

**Recommendation:** Start with option 1 (hardcoded sensible default). If users complain about slow confirmations or overpaying fees, add dynamic fee estimation later. Extract as a constant so it's a one-line change.

**Files touched:** Constant added to `lib/core/app_constants.dart` (1 file)

---

## Open Items

- [ ] Confirm `GetTokenizedBTCList` returns a `Version` field for V2 tokens — if not, version routing defaults to V1 until the CLI is updated
- [ ] Determine appropriate default fee rate for V2 withdrawals (10 sats/vB as starting point)
- [ ] Bulk/multi-token transfer for V2 — deferred, pending blockchain dev discussion
- [ ] Withdrawal cancellation UI — deferred (edge case)
- [ ] How long does `CompleteWithdrawal` FROST signing typically take? Needed to calibrate the processing dialog UX

---

## File Summary

| File | Action | Phase |
|------|--------|-------|
| `lib/features/btc/services/vbtc_v2_service.dart` | **Modify** (add methods) | 1 |
| `lib/features/btc/models/withdrawal_result.dart` | **New** | 2 |
| `lib/features/btc/components/withdrawal_processing_dialog.dart` | **New** | 3 |
| `lib/features/btc/models/tokenized_bitcoin.dart` | **Modify** (add version field) | 4 |
| `lib/features/btc/components/tokenized_btc_action_buttons.dart` | **Modify** (version routing) | 5 |
| `lib/core/app_constants.dart` | **Modify** (add fee rate constant) | 6 |
