# Phase 3: Withdrawal Processing Dialog — Verification Report

**Plan:** vBTC V2 Transfer & Withdrawal (majestic-noodling-cloud)
**Phase:** 3 — Withdrawal Processing Dialog
**Reviewer:** reviewer agent
**Date:** 2026-03-12
**Verdict:** PASS

---

## Checklist

### Structure and Pattern (lines 1-43)

| Criteria | Status | Notes |
|----------|--------|-------|
| New file at correct path | PASS | `lib/features/btc/components/withdrawal_processing_dialog.dart` |
| References `MpcCeremonyProgressModal` pattern | PASS | Static `show()` method, `AlertDialog`, `rootNavigatorKey` fallback — same pattern |
| Static `show()` method | PASS | Lines 24-39: `showDialog<WithdrawalResult>` with `barrierDismissible: false` |
| Returns `Future<WithdrawalResult?>` | PASS | Line 24 — caller can inspect result after dialog closes |
| `StatefulWidget` (needs mutable state) | PASS | Correct choice — manages processing/success/failure transitions |
| Holds `scUid` and `requestHash` internally | PASS | Lines 12-13 — widget fields used for retry |
| Optional `ownerAddress` for cancel feature | PASS | Line 14 — nullable, controls cancel button visibility |

### Three Dialog States (line 45)

| Criteria | Status | Notes |
|----------|--------|-------|
| `processing` state | PASS | Spinner + "Validators are signing..." text (lines 119-142) |
| `success` state | PASS | VFX + BTC tx hashes with copy buttons + "Done" button (lines 144-177) |
| `failure` state | PASS | Error message + "Retry" + "Dismiss" + conditional "Cancel" (lines 179-225) |
| Initial state is `processing` | PASS | Line 48: `_state = _DialogState.processing` |
| Auto-starts `completeWithdrawal` on init | PASS | Line 54: `_runCompleteWithdrawal()` called from `initState` |

### Processing State (lines 119-142)

| Criteria | Status | Notes |
|----------|--------|-------|
| Spinner (CircularProgressIndicator) | PASS | Lines 124-128 |
| "Validators are signing..." text | PASS | Line 132 — matches plan |
| Close button hidden during processing | PASS | Line 83: `if (_state != _DialogState.processing)` guards close button |
| Non-dismissible during processing | PASS | `barrierDismissible: false` on `showDialog` |

### Success State (lines 144-177)

| Criteria | Status | Notes |
|----------|--------|-------|
| Shows VFX transaction hash | PASS | Lines 158-161: conditional on `vfxTransactionHash != null` |
| Shows BTC transaction hash | PASS | Lines 162-165: conditional on `btcTransactionHash != null` |
| Copy buttons on hashes | PASS | `_buildHashRow` (lines 227-256): `Clipboard.setData` + toast |
| Hashes are selectable text | PASS | Line 239: `SelectableText` — allows manual selection too |
| "Done" button | PASS | Lines 169-173: pops dialog with `_result` |

### Failure State (lines 179-225)

| Criteria | Status | Notes |
|----------|--------|-------|
| Shows error message | PASS | Lines 191-193: `_result?.message` with fallback |
| "Retry" button | PASS | Lines 216-220: calls `_runCompleteWithdrawal` |
| "Dismiss" button | PASS | Lines 202-206: pops with `_result` (preserves requestHash for later) |
| No retry limit | PASS | Retry just calls `_runCompleteWithdrawal` again — unlimited |

### Retry Mechanism (lines 57-71)

| Criteria | Status | Notes |
|----------|--------|-------|
| Resets to processing state | PASS | Line 58: `setState(() => _state = _DialogState.processing)` |
| Calls `completeWithdrawal` with widget's `requestHash` | PASS | Lines 60-63 |
| Checks `mounted` before `setState` | PASS | Line 65 — prevents state update if dialog was dismissed |
| Updates result and state on completion | PASS | Lines 67-70 |

### Cancel Withdrawal (lines 180, 258-279)

| Criteria | Status | Notes |
|----------|--------|-------|
| Only shown when owner AND btcTransactionHash exists | PASS | Line 180: `widget.ownerAddress != null && _result?.btcTransactionHash != null` |
| Calls `VbtcV2Service().cancelWithdrawal()` | PASS | Lines 263-269 |
| Passes correct params (scUid, ownerAddress, requestHash, btcTxHash, failureProof) | PASS | All 5 params present |
| Double-checks preconditions before calling | PASS | Line 259: guard clause |
| On success: toast + pop with null | PASS | Lines 274-275 |
| On failure: returns to failure state | PASS | Line 277 |
| Checks `mounted` before state update | PASS | Line 271 |

---

## Scope Check

- Single new file — correct per plan
- Uses existing project components: `AppButton`, `AppColorVariant`, `rootNavigatorKey`, `Toast`
- Follows `MpcCeremonyProgressModal` pattern for dialog structure
- No Riverpod dependency (doesn't need one — state is local to dialog)

## Edge Cases and Safety

- **`mounted` checks** on both async operations (`_runCompleteWithdrawal` line 65, `_cancelWithdrawal` line 271) — prevents setState on disposed widget
- **Close button hidden during processing** — prevents user from closing mid-FROST-signing
- **`barrierDismissible: false`** — dialog can only be closed via buttons
- **Cancel button guarded by `ownerAddress != null` AND `btcTransactionHash != null`** — matches plan requirement that cancel is only available when FROST succeeded but BTC TX stalled
- **Dismiss always pops with `_result`** — preserves `requestHash` in the result so caller can use it for future retry
- **Cancel pops with `null`** — signals that the withdrawal was cancelled, not failed

## Issues Found

None.

## Summary

Phase 3 implementation is correct, complete, and matches the plan. The dialog follows the `MpcCeremonyProgressModal` pattern with a static `show()` method and `AlertDialog`. All three states (processing, success, failure) are implemented with the correct UI elements. The retry mechanism calls `completeWithdrawal` with the stored `requestHash` with no retry limit. The cancel option is correctly gated on owner status and BTC transaction hash existence. Proper `mounted` checks protect against state updates on disposed widgets.
