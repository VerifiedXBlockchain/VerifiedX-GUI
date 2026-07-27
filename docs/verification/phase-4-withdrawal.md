# Phase 4 Verification: Withdrawal

**Verdict: PASS**

---

## Task 1: Add `requestV2Withdrawal()` to WebTokenActionsManager

**File:** `lib/features/token/providers/web_token_actions_manager.dart` (lines 337-402)

| Requirement | Status | Notes |
|---|---|---|
| Data payload: `{ "Function": "VBTCWithdrawalRequest()", "ContractUID", "RequestorAddress", "BTCAddress", "Amount", "FeeRate" }` | Done | Lines 350-357 — all fields correct |
| TX type: 27 (`TxType.vbtcV2WithdrawalRequest`) | Done | Line 365; confirmed as `static const int vbtcV2WithdrawalRequest = 27` in `app_constants.dart:87` |
| `to_address` = `from_address` = requestor's VFX address | Done | Line 363: `toAddress: requestorAddress` |
| Returns the tx hash (withdrawal_request_hash) | Done | Lines 395-397: extracts and returns `tx['Hash']` |
| Shows confirmation dialog with fee | Done | Lines 377-382 |

---

## Task 2: Add `completeV2Withdrawal()` to WebTokenActionsManager

**File:** `lib/features/token/providers/web_token_actions_manager.dart` (lines 405-414)

| Requirement | Status | Notes |
|---|---|---|
| Calls `ExplorerService().completeV2Withdrawal(scIdentifier, requestHash)` | Done | Line 410 |
| Returns result map on success, null on failure | Done | Error returns null |

---

## Task 3: Add `cancelV2Withdrawal()` to WebTokenActionsManager

**File:** `lib/features/token/providers/web_token_actions_manager.dart` (lines 417-436)

| Requirement | Status | Notes |
|---|---|---|
| Calls `ExplorerService().cancelV2Withdrawal(...)` | Done | Lines 425-431 |
| All params: scIdentifier, ownerAddress, requestHash, btcTxHash, failureProof | Done | |
| Returns boolean success | Done | Line 432: checks `result['success'] == true` |

---

## Task 4: Create web V2 withdrawal processing dialog

**File:** `lib/features/btc_web/components/web_v2_withdrawal_dialog.dart` (383 lines)

| Requirement | Status | Notes |
|---|---|---|
| Step 1: "Broadcasting withdrawal request..." | Done | `_DialogStep.broadcasting`, `_buildBroadcastingSection()` |
| Step 2: "Waiting for block confirmation..." — polls withdrawals | Done | `_DialogStep.waitingForBlock`, polls `getWebVbtcV2TokenDetail` every 5s, checks `withdrawal_requests` for matching hash |
| Step 3: "FROST signing in progress..." during completeV2Withdrawal | Done | `_DialogStep.frostSigning`, `_runFrostSigning()` calls `completeV2Withdrawal` |
| Step 4: Success with BTC tx hash + mempool.space link | Done | `_buildSuccessSection()` shows both hashes with copy buttons and external link to mempool.space |
| Error handling at each step | Done | Failure state with `_errorMessage`, different error paths for broadcast fail, timeout, and FROST failure |
| Timeout handling with "check back" messaging | Done | Max 60 polls (5min) for block confirmation; FROST timeout message: "signing may still complete" |
| Support for resuming pending withdrawal (existingRequestHash) | Done | Lines 81-84: if `existingRequestHash` provided, skips broadcast step and goes directly to FROST signing |
| Retry button on failure | Done | Lines 337-344: "Retry Signing" button when `_requestHash` exists |

---

## Task 5: Wire into web action buttons

**File:** `lib/features/btc_web/components/web_btc_tokenized_action_buttons.dart` (lines 256-305)

| Requirement | Status | Notes |
|---|---|---|
| Version-gate: V2 uses new dialog, V1 uses existing flow | Done | Line 256: `if (token.version >= 2)` |
| Pending withdrawal detection: offer to complete | Done | Lines 258-276: checks `isPendingWithdrawal` and finds matching pending request, passes `existingRequestHash` to dialog |
| New withdrawal: prompts for amount, address, fee rate, opens dialog | Done | Lines 280-305: collects inputs then opens `WebV2WithdrawalDialog.show()` |

---

## Summary

All 5 tasks complete. The withdrawal flow covers the full lifecycle: request TX (Type 27) with correct payload, block confirmation polling, FROST signing with long-running call, success display with mempool links, error handling with retry, and pending withdrawal resumption. The dialog is well-structured with clear step progression. No issues found.
