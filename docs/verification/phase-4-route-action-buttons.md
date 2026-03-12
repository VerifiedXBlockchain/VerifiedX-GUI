# Phase 4: Route Action Buttons by Version — Verification Report

**Plan:** vBTC V2 Transfer & Withdrawal (majestic-noodling-cloud)
**Phase:** 4 — Route Action Buttons by Version
**Reviewer:** reviewer agent
**Date:** 2026-03-12
**Verdict:** PASS WITH WARNINGS

---

## Checklist

### Imports (lines 33-38)

| Criteria | Status | Notes |
|----------|--------|-------|
| `vbtc_v2_service.dart` imported | PASS | Line 33 |
| `btc_fee_rate_preset.dart` imported | PASS | Line 35 |
| `btc_recommended_fees.dart` imported | PASS | Line 36 |
| `session_provider.dart` imported | PASS | Line 37 |
| `withdrawal_processing_dialog.dart` imported | PASS | Line 38 |

### Version Routing Pattern

| Criteria | Status | Notes |
|----------|--------|-------|
| Uses `token.version >= 2` for V2 path | PASS | Lines 396, 560, 646, 970, 1101 |
| V1 path in `else` block (untouched) | PASS | Lines 443, 597, 671 — original V1 code preserved |

### Transfer vBTC (V2 path, lines 646-670)

| Criteria | Status | Notes |
|----------|--------|-------|
| Calls `VbtcV2Service().transferVbtc()` | PASS | Line 649 |
| Passes `scUid`, `fromAddress`, `toAddress`, `amount` | PASS | Lines 650-654 |
| Surfaces transaction hash in toast | PASS | Line 659: `"vBTC V2 Transfer TX Broadcasted. Hash: $txHash"` |
| Logs entry with `textToCopy: txHash` | PASS | Line 666 |
| Calls `refresh()` after success | PASS | Line 669: `tokenizedBitcoinListProvider.notifier.refresh()` |
| Uses `globalLoadingProvider` for loading state | PASS | Lines 648, 655 |

### Ownership Transfer (V2 path, lines 560-596)

| Criteria | Status | Notes |
|----------|--------|-------|
| Calls `VbtcV2Service().transferOwnership()` | PASS | Line 580 |
| Passes `scUid`, `toAddress` | PASS | Lines 581-583 |
| Prompts for destination address | PASS | Lines 562-567 — `PromptModal.show()` |
| Confirmation dialog before executing | PASS | Lines 571-577 |
| Surfaces V2-specific errors via toast | PASS | Errors come through `VbtcV2Service.transferOwnership` which shows `Toast.error` |
| Calls `refresh()` after success | PASS | Line 595 |
| Logs entry | PASS | Lines 588-594 |

### Withdrawal (V2 path, lines 396-442)

| Criteria | Status | Notes |
|----------|--------|-------|
| Uses same `_TransferSharesModal` with `forWithdrawl: true` | PASS | Lines 378-381 |
| Calls `VbtcV2Service().requestWithdrawal()` | PASS | Line 398 |
| Shows `WithdrawalProcessingDialog` for FROST step | PASS | Lines 425-429 |
| Passes `ownerAddress` only if `isOwner` | PASS | Line 428: `isOwner ? token.rbxAddress : null` |
| Calls `refresh()` after dialog closes | PASS | Line 431 |
| Logs success with BTC tx hash | PASS | Lines 433-441 |
| Does NOT use `globalLoadingProvider` | PASS | Correct — dialog handles its own loading state |
| Active withdrawal recovery (regex parsing) | PASS | Lines 408-418 — parses `requestHash` from error message |

### _TransferSharesModal Changes

| Criteria | Status | Notes |
|----------|--------|-------|
| Accepts `TokenizedBitcoin token` | PASS | Line 897 |
| V2 withdrawal: fee rate preset dropdown | PASS | Lines 970-1050: `PopupMenuButton<BtcFeeRatePreset>` |
| V1 withdrawal: hardcoded fee rate text | PASS | Lines 1052-1062: `BTC_WITHDRAWL_FEE_RATE` display, unchanged |
| Uses `sessionProvider.btcRecommendedFees` | PASS | Line 974 |
| Defaults to `BtcFeeRatePreset.economy` | PASS | Line 1142: `_v2FeeRatePresetProvider` defaults to economy |
| Filters out `custom` preset from dropdown | PASS | Line 1016 |
| Shows fee estimate (SATS + BTC) | PASS | Lines 1044-1046 |
| `_TransferShareModalResponse` includes `feeRate` | PASS | Line 887, populated at line 1127 with `resolvedFee` |
| Resolves fee from preset on submit | PASS | Lines 1099-1124 — re-reads preset and computes fee |

### _v2FeeRatePresetProvider (lines 1141-1143)

| Criteria | Status | Notes |
|----------|--------|-------|
| `StateProvider.autoDispose` | PASS | Local widget state, auto-disposed — matches plan |
| Default: `BtcFeeRatePreset.economy` | PASS | Line 1142 |

### V1 Paths Unchanged

| Criteria | Status | Notes |
|----------|--------|-------|
| Withdrawal V1: `BtcService().withdrawCoin()` | PASS | Lines 446-452 — untouched |
| Transfer V1: `BtcService().transferTokenShares()` | PASS | Lines 674-679 — untouched |
| Ownership V1: existing NFT transfer flow | PASS | Lines 597+ — untouched |

---

## Scope Check

- Only `tokenized_btc_action_buttons.dart` modified — correct per plan
- New imports are minimal and necessary
- V1 code paths preserved in `else` blocks
- No new files created (fee rate provider is file-private)

## Warnings

### WARN-1: Duplicated active withdrawal regex (line 411)

The V2 withdrawal path at line 411 creates a new `RegExp(r'Request Hash:\s*(0x[a-fA-F0-9]+)')` inline, duplicating the pattern already defined as `VbtcV2Service._activeWithdrawalPattern` (which is private). This is functionally correct but creates a maintenance risk — if the error format changes, two places need updating.

**Severity:** Low — the regex is simple and unlikely to change. Phase 5 (Pending Withdrawal Recovery) may consolidate this.

**Suggested fix (optional):** Make `_activeWithdrawalPattern` public on `VbtcV2Service` and reference it here, or extract a shared utility.

### WARN-2: Fee rate resolution duplicated (lines 976-995 and 1104-1123)

The switch statement mapping `BtcFeeRatePreset` to fee values appears twice — once in the display builder (lines 976-995) and again in the submit handler (lines 1104-1123). This is because `fee` is a local variable that may not survive the rebuild cycle. Functionally correct but verbose.

**Severity:** Low — both switch statements are identical and read from the same source of truth.

## Issues Found

None that block shipping. Two low-severity warnings noted above.

## Summary

Phase 4 implementation is correct and complete. All three action types (transfer, ownership transfer, withdrawal) are properly routed by `token.version >= 2`. V2 transfer surfaces the transaction hash in toast and log. V2 ownership transfer prompts for address with confirmation. V2 withdrawal separates the request step from the FROST signing step, showing `WithdrawalProcessingDialog` for the latter with correct `ownerAddress` gating. The fee rate preset dropdown works correctly with `BtcFeeRatePreset` enum and `sessionProvider.btcRecommendedFees`, defaulting to economy. V1 paths are completely untouched. Two low-severity warnings about duplicated regex and fee resolution logic.
