# Phase 5: Pending Withdrawal Recovery — Verification Report

**Plan:** vBTC V2 Transfer & Withdrawal (majestic-noodling-cloud)
**Phase:** 5 — Pending Withdrawal Recovery
**Reviewer:** reviewer agent
**Date:** 2026-03-12
**Verdict:** PASS

---

## Checklist

### Recovery Flow (lines 408-427)

| Criteria | Status | Notes |
|----------|--------|-------|
| Detects "already have active withdrawal" error | PASS | Line 411: regex `Request Hash:\s*(0x[a-fA-F0-9]+)` matches error message |
| Parses existing `requestHash` from error | PASS | Line 413: `requestHash = match.group(1)` |
| Shows recovery dialog | PASS | Lines 416-421: `ConfirmDialog.show()` |
| Dialog title: "Pending Withdrawal Found" | PASS | Line 417 |
| Dialog body matches plan text | PASS | Line 418: "You have a pending withdrawal for this contract. Would you like to complete it?" |
| "Complete" button label | PASS | Line 419: `confirmText: "Complete"` |
| "Dismiss" button label | PASS | Line 420: `cancelText: "Dismiss"` |

### "Complete" Path

| Criteria | Status | Notes |
|----------|--------|-------|
| Opens `WithdrawalProcessingDialog` with parsed `requestHash` | PASS | Falls through to line 435: `WithdrawalProcessingDialog.show(requestHash: requestHash)` |
| Skips `requestWithdrawal` (calls `completeWithdrawal` directly) | PASS | Dialog internally calls `completeWithdrawal` only — request step already happened |
| Passes `ownerAddress` for cancel gating | PASS | Line 438: `ownerAddress: isOwner ? token.rbxAddress : null` |
| Refreshes token list after dialog | PASS | Line 441: `tokenizedBitcoinListProvider.notifier.refresh()` |

### "Dismiss" Path

| Criteria | Status | Notes |
|----------|--------|-------|
| Closes dialog, takes no action | PASS | Line 423: `if (shouldComplete != true) return;` |
| No side effects on dismiss | PASS | Early return, no API calls or state changes |

### Soft-Lock Prevention

| Criteria | Status | Notes |
|----------|--------|-------|
| App closed mid-withdrawal -> reopen -> click Withdraw -> detects pending | PASS | `requestWithdrawal` returns error with hash, regex parses it, dialog offers completion |
| User can complete the pending withdrawal | PASS | "Complete" -> `WithdrawalProcessingDialog` -> `completeWithdrawal` |
| User can dismiss and try later | PASS | "Dismiss" -> no action, withdrawal stays in "Requested" state |

### ConfirmDialog API Compatibility

| Criteria | Status | Notes |
|----------|--------|-------|
| `ConfirmDialog.show()` accepts `confirmText` | PASS | Verified in `lib/core/dialogs.dart:181` |
| `ConfirmDialog.show()` accepts `cancelText` | PASS | Verified in `lib/core/dialogs.dart:180` |
| Returns `bool?` — `true` for confirm, `false`/`null` for cancel | PASS | Lines 163, 148 in dialogs.dart |

---

## Scope Check

- Only `tokenized_btc_action_buttons.dart` modified — correct per plan
- Phase 5 logic is cleanly integrated into the Phase 4 withdrawal V2 path (lines 412-427) rather than being a separate code block
- No new files created
- V1 paths untouched

## Integration with Phase 4

The Phase 5 recovery logic is embedded within the Phase 4 active-withdrawal detection block (lines 412-427). When the regex matches:
- Phase 4 behavior: parse `requestHash`, proceed to `WithdrawalProcessingDialog`
- Phase 5 addition: insert a `ConfirmDialog` asking the user before proceeding

This is a clean integration — the recovery prompt is a single `ConfirmDialog.show()` call inserted between hash parsing and dialog display, with an early return on dismiss.

## Issues Found

None.

## Summary

Phase 5 implementation is correct, complete, and matches the plan. When a V2 withdrawal attempt detects an existing pending withdrawal via the "already have active withdrawal" error, the parsed `requestHash` triggers a confirmation dialog asking whether to complete the pending withdrawal. "Complete" proceeds to `WithdrawalProcessingDialog` (calling `completeWithdrawal` directly, skipping the request step). "Dismiss" returns with no action. This prevents the soft-lock scenario where a user cannot initiate new withdrawals after an interrupted attempt.
