# Phase 2: VbtcV2Service — Verification Report

**Plan:** vBTC V2 Transfer & Withdrawal (majestic-noodling-cloud)
**Phase:** 2 — VbtcV2Service: Transfer, Withdrawal, and Cancel Methods
**Reviewer:** reviewer agent
**Date:** 2026-03-12
**Verdict:** PASS

---

## Checklist

### Imports and Structure (lines 1-8)

| Criteria | Status | Notes |
|----------|--------|-------|
| Imports `WithdrawalResult` model | PASS | Line 3: `import '../models/withdrawal_result.dart'` |
| Imports `BaseService` and `Toast` | PASS | Lines 1-2 |
| Extends `BaseService` with `/vbtcapi/vbtc` path | PASS | Line 6 — matches existing service setup |
| Active withdrawal regex defined | PASS | Line 8: `RegExp(r'Request Hash:\s*(0x[a-fA-F0-9]+)')` |

### Method: `transferVbtc` (lines 97-132)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature: `{scUid, fromAddress, toAddress, amount}` | PASS | All required, matches plan |
| Endpoint: `POST /TransferVBTC` | PASS | `postJson("/TransferVBTC", ...)` |
| Returns `String?` (transaction hash) | PASS | `data['TransactionHash']` on success, `null` on failure |
| Error handling: `Toast.error` on failure | PASS | Lines 124 (API error), 129 (exception) |
| Uses `response['data']` for POST response | PASS | Consistent with `postJson` return format `{'data': data}` |

### Method: `transferOwnership` (lines 135-158)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature: `{scUid, toAddress}` | PASS | All required, matches plan |
| Endpoint: `GET /TransferOwnership/{scUID}/{toAddress}` | PASS | `getJson("/TransferOwnership/$scUid/$toAddress")` — path params in URL |
| Returns `bool` | PASS | `true` on success, `false` on failure |
| Uses `result['Success']` directly (no `['data']` wrapper) | PASS | Correct for `getJson` which returns response data directly |
| Error handling: `Toast.error` on failure | PASS | Lines 150, 155 |

### Method: `requestWithdrawal` (lines 162-208)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature: `{scUid, requestorAddress, btcAddress, amount, feeRate}` | PASS | All required, matches plan |
| Endpoint: `POST /RequestWithdrawal` | PASS | `postJson("/RequestWithdrawal", ...)` |
| Returns `WithdrawalResult` (not nullable) | PASS | Always returns a result, never null |
| Success result contains `requestHash` | PASS | Line 191: `data['RequestHash']` |
| Failure result preserves error message | PASS | Lines 196-199: `data['Message']`, lines 203-206: `e.toString()` |
| Does NOT show `Toast.error` directly | PASS | Correct — errors need to be parsed by `withdraw()` helper first |

### Method: `completeWithdrawal` (lines 212-257)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature: `{scUid, withdrawalRequestHash}` | PASS | All required, matches plan |
| Endpoint: `POST /CompleteWithdrawal` | PASS | `postJson("/CompleteWithdrawal", ...)` |
| Returns `WithdrawalResult` with both tx hashes | PASS | Lines 237-238: `VFXTransactionHash`, `BTCTransactionHash` |
| `requestHash` preserved in ALL paths | PASS | Success (line 236), failure (line 246), exception (line 254) |
| Extended timeout for FROST signing | PASS | `timeout: 120000` (2 min) — appropriate for ceremony duration |

### Method: `cancelWithdrawal` (lines 261-298)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature: `{scUid, ownerAddress, withdrawalRequestHash, btcTxHash, failureProof}` | PASS | All required, matches plan exactly |
| Endpoint: `POST /CancelWithdrawal` | PASS | `postJson("/CancelWithdrawal", ...)` |
| Returns `bool` | PASS | `true` on success, `false` on failure |
| Error handling: `Toast.error` on failure | PASS | Lines 290, 295 |

### Combined helper: `withdraw` (lines 303-355)

| Criteria | Status | Notes |
|----------|--------|-------|
| Signature: `{scUid, requestorAddress, btcAddress, amount, feeRate}` | PASS | Matches plan |
| Step 1: calls `requestWithdrawal` | PASS | Lines 311-317 |
| Step 2: on "active withdrawal" error, parses existing `requestHash` | PASS | Lines 321-331 — regex match on error message |
| Step 3: calls `completeWithdrawal` with `requestHash` | PASS | Lines 341-344 |
| Step 4: returns combined result with `requestHash` always included | PASS | Lines 347-354 |
| Null guard on `requestHash` before completing | PASS | Lines 333-338 — returns error if no hash from either path |
| Shows `Toast.error` only when regex parsing also fails | PASS | Line 328 — toast only when error is not "active withdrawal" |

### Regex: `_activeWithdrawalPattern` (line 8)

| Criteria | Status | Notes |
|----------|--------|-------|
| Matches plan error format: `"...Request Hash: 0x..."` | PASS | `r'Request Hash:\s*(0x[a-fA-F0-9]+)'` |
| Captures full hash including `0x` prefix | PASS | Group 1 captures `0x` + hex chars |
| Case-insensitive hex `[a-fA-F0-9]` | PASS | Handles mixed-case hash values |

---

## Scope Check

- Only `lib/features/btc/services/vbtc_v2_service.dart` modified (new methods added to existing file)
- Pre-existing methods (`initiateCeremony`, `getCeremonyStatus`, `createContract`) untouched
- Follows existing service conventions: `BaseService`, `postJson`/`getJson`, `cleanPath: false`, `Toast.error`, `inspect: true`
- No unnecessary imports or dependencies added

## Edge Cases and Safety

- **`requestWithdrawal` avoids premature toast** — errors bubble to `withdraw()` for active-withdrawal parsing first
- **`completeWithdrawal` preserves `requestHash` in all 3 code paths** (success, API failure, exception) — critical for retry
- **`withdraw()` null guard** (line 333) — defensive check prevents calling `completeWithdrawal` with null hash
- **`getJson` vs `postJson` response handling** — `transferOwnership` correctly reads `result['Success']` directly (getJson returns data unwrapped), while POST methods correctly unwrap via `response['data']`
- **120s timeout on `completeWithdrawal`** — appropriate for FROST signing which can take significant time

## Issues Found

None.

## Summary

Phase 2 implementation is correct, complete, and matches the plan. All 5 methods plus the combined `withdraw()` helper are implemented with correct endpoints, HTTP methods, parameters, return types, and error handling. The active withdrawal detection regex correctly parses the error message format. The `requestHash` is preserved through all code paths for retry support. Response handling is consistent with `BaseService` conventions (unwrapped for GET, `['data']` wrapped for POST).
