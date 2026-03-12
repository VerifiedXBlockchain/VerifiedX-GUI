# Phase 8 (Plan Phase 2): VbtcV2Service — Verification Report

**Plan:** vBTC V2 Transfer & Withdrawal (majestic-noodling-cloud)
**Phase:** 2 — VbtcV2Service: Transfer, Withdrawal, and Cancel Methods
**Reviewer:** reviewer agent
**Date:** 2026-03-12
**Verdict:** PASS

---

## Checklist

### Method: `transferVbtc` (lines 97-132)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature matches plan | PASS | `{scUid, fromAddress, toAddress, amount}` — all required |
| Endpoint `POST /TransferVBTC` | PASS | Uses `postJson("/TransferVBTC", ...)` |
| Returns `String?` (transaction hash) | PASS | Returns `data['TransactionHash']` on success, `null` on failure |
| Error handling with `Toast.error` | PASS | Shows toast on API failure (line 124) and exception (line 129) |
| Follows existing service pattern | PASS | Uses `postJson`, `cleanPath: false`, `inspect: true` — consistent with `createContract` above |

### Method: `transferOwnership` (lines 135-158)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature matches plan | PASS | `{scUid, toAddress}` — all required |
| Endpoint `GET /TransferOwnership/{scUID}/{toAddress}` | PASS | Uses `getJson("/TransferOwnership/$scUid/$toAddress")` with path params |
| Returns `bool` | PASS | `true` on success, `false` on failure |
| Error handling with `Toast.error` | PASS | Shows toast on API failure (line 150) and exception (line 155) |

### Method: `requestWithdrawal` (lines 162-208)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature matches plan | PASS | `{scUid, requestorAddress, btcAddress, amount, feeRate}` — all required |
| Endpoint `POST /RequestWithdrawal` | PASS | Uses `postJson("/RequestWithdrawal", ...)` |
| Returns `WithdrawalResult` | PASS | Returns result with `requestHash` on success |
| Contains `requestHash` on success | PASS | Maps `data['RequestHash']` to `requestHash` (line 191) |
| Error returns `WithdrawalResult` (not null) | PASS | Returns `WithdrawalResult(success: false, ...)` on failure (lines 196-199, 203-206) |
| No `Toast.error` in this method | PASS | Correct — errors bubble up to `withdraw()` helper for parsing |

### Method: `completeWithdrawal` (lines 212-257)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature matches plan | PASS | `{scUid, withdrawalRequestHash}` — all required |
| Endpoint `POST /CompleteWithdrawal` | PASS | Uses `postJson("/CompleteWithdrawal", ...)` |
| Returns `WithdrawalResult` | PASS | Contains both tx hashes on success |
| Contains both hashes on success | PASS | Maps `VFXTransactionHash` and `BTCTransactionHash` (lines 237-238) |
| Always includes `requestHash` | PASS | Passes through `withdrawalRequestHash` in success (line 236), failure (line 246), and exception (line 254) paths |
| Timeout extended for FROST signing | PASS | `timeout: 120000` (2 minutes) — appropriate for FROST ceremony |

### Method: `cancelWithdrawal` (lines 261-298)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature matches plan | PASS | `{scUid, ownerAddress, withdrawalRequestHash, btcTxHash, failureProof}` — all required |
| Endpoint `POST /CancelWithdrawal` | PASS | Uses `postJson("/CancelWithdrawal", ...)` |
| Returns `bool` | PASS | `true` on success, `false` on failure |
| Error handling with `Toast.error` | PASS | Lines 290, 295 |

### Combined helper: `withdraw` (lines 303-355)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature matches plan | PASS | `{scUid, requestorAddress, btcAddress, amount, feeRate}` |
| Step 1: calls `requestWithdrawal` | PASS | Lines 311-317 |
| Step 2: parses existing `requestHash` on "active withdrawal" error | PASS | Uses `_activeWithdrawalPattern` regex (line 324) |
| Step 3: calls `completeWithdrawal` with `requestHash` | PASS | Lines 341-344 |
| Step 4: returns combined result with `requestHash` always present | PASS | Lines 347-354 — `requestHash` included even on failure |
| Null `requestHash` guard | PASS | Lines 333-337 — returns error if no hash from either path |

### Regex: `_activeWithdrawalPattern` (line 8)

| Criteria | Status | Notes |
|----------|--------|-------|
| Pattern matches plan's error format | PASS | `RegExp(r'Request Hash:\s*(0x[a-fA-F0-9]+)')` matches `"...Request Hash: 0x..."` |
| Captures hex hash in group(1) | PASS | `(0x[a-fA-F0-9]+)` captures the full hash including `0x` prefix |

---

## Scope Check

- Only `lib/features/btc/services/vbtc_v2_service.dart` was modified
- All 5 new methods + 1 combined helper added as specified
- Pre-existing methods (`initiateCeremony`, `getCeremonyStatus`, `createContract`) untouched
- Follows existing service pattern: `BaseService` with `postJson`/`getJson`, `cleanPath: false`, `Toast.error` on failure

## Edge Cases and Safety

- **requestWithdrawal does not show Toast.error directly** — correct, because errors need to be parsed by the `withdraw()` helper first. The helper shows the toast if parsing fails (line 328).
- **completeWithdrawal preserves requestHash in all paths** (success, failure, exception) — enables retry from the dialog.
- **withdraw() null-guard on requestHash** (line 333) — prevents proceeding to `completeWithdrawal` with a null hash.
- **120s timeout on completeWithdrawal** — reasonable for FROST signing ceremony.

## Issues Found

None.

## Summary

Phase 2 implementation is correct, complete, and matches the plan exactly. All 5 methods plus the combined `withdraw()` helper are implemented with the correct endpoints, HTTP methods, parameters, return types, and error handling. The active withdrawal detection regex correctly parses the error message format. The `requestHash` is preserved through all code paths to enable retry. The extended timeout on `completeWithdrawal` is a good addition for the FROST signing step.
