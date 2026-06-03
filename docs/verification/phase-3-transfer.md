# Phase 3 Verification: Transfer

**Verdict: PASS**

---

## Task 1: Add `transferVbtcV2()` to WebTokenActionsManager

**File:** `lib/features/token/providers/web_token_actions_manager.dart` (lines 313-332)

| Requirement | Status | Notes |
|---|---|---|
| Data payload: `{ "Function": "TransferVBTCV2()", "ContractUID": ..., "FromAddress": ..., "ToAddress": ..., "Amount": ... }` | Done | Lines 319-325 — all fields present with correct keys |
| TX type: 26 (`TxType.vbtcV2Transfer`) | Done | Line 330 — `TxType.vbtcV2Transfer` used; confirmed as `static const int vbtcV2Transfer = 26` in `app_constants.dart:86` |
| Uses `_verifyConfirmAndSendTx()` with `toAddress` set to recipient | Done | Lines 327-331 |
| Data payload is a Map (not a List like V1's `TransferCoin()`) | Done | V1 uses `[{...}]` (List), V2 uses `{...}` (Map) — correct per plan |

---

## Task 2: Version-gate in web action buttons

**File:** `lib/features/btc_web/components/web_btc_tokenized_action_buttons.dart` (lines 341-351)

| Requirement | Status | Notes |
|---|---|---|
| Check `token.version >= 2` in transfer handler | Done | Line 341 |
| V2: call `transferVbtcV2()` | Done | Lines 342-347 |
| V1: call existing `transferVbtcAmount()` | Done | Lines 349-350 |

The version gate is cleanly placed after the modal returns transfer details, routing to the correct method based on token version.

---

## Summary

Both tasks complete. The V2 transfer method has the correct data payload structure (Map, not List), correct function name, correct TX type (26), and the action buttons properly version-gate between V1 and V2 transfer paths. No issues found.
