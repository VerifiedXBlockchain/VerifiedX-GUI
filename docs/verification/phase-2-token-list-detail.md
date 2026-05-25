# Phase 2 Verification: Token List + Detail

**Verdict: PASS**

---

## Task 1: Update `btcWebVbtcTokenListProvider`

**File:** `lib/features/btc_web/providers/btc_web_vbtc_token_list_provider.dart`

| Requirement | Status | Notes |
|---|---|---|
| Fetch from both V1 and V2 endpoints | Done | Lines 19-20 (V1), lines 28-29 (V2) |
| V2 tokens have `version: 2` set explicitly | Done | Set in `ExplorerService.getWebVbtcV2Tokens()` (line 630 of explorer_service.dart) — safety measure present |
| Merge both lists into single list | Done | Results accumulated in `results` list |
| Sort by createdAt descending | Done | Line 37: `results.sort((a, b) => b.createdAt.compareTo(a.createdAt))` |

Also handles RA address for both V1 and V2 (lines 22-25, 31-34), which is consistent with the existing V1 pattern.

---

## Task 2: Update `btcWebVbtcTokenDetailProvider`

**File:** `lib/features/btc_web/providers/btc_web_vbtc_token_detail_provider.dart`

| Requirement | Status | Notes |
|---|---|---|
| For V2 tokens, call `getWebVbtcV2TokenDetail` | Done | Line 18-19: `if (version >= 2)` gates the V2 endpoint |
| Determine version from token list state | Done | Lines 14-16: reads token list and finds matching token's version |
| Key format includes scIdentifier | Done | Key format: `"{scIdentifier}_{address}"` (line 10-11) |
| Falls back to V1 for version < 2 | Done | Line 22: calls `getWebVbtcTokenDetail(scId, address)` |

The approach uses the loaded token list to determine version rather than adding version to the key — this is a valid strategy since the list is always loaded before detail navigation.

---

## Task 3: Update detail screen

**File:** `lib/features/btc_web/screens/web_tokenized_btc_detail_screen.dart`

| Requirement | Status | Notes |
|---|---|---|
| Show V2-specific info: FROST group key | Done | Lines 405-411: conditionally shows FROST group key with copy |
| Show V2-specific info: threshold | Done | Lines 412-415: shows signing threshold |
| Show V2-specific info: pending withdrawal status | Done | Lines 416-420: shows "Pending Withdrawal" status |
| Display withdrawal history | Done | Lines 207-241: renders withdrawal history list with amount, BTC address, and status icons |
| Version badge/indicator | Done | Lines 400-403: shows "V{version}" in detail rows |

All V2 info is gated behind `token.version >= 2` checks.

---

## Task 4: Update list tile

**File:** `lib/features/btc_web/components/web_tokenized_btc_list_tile.dart`

| Requirement | Status | Notes |
|---|---|---|
| Show version badge on V2 tokens | Done | Lines 60-77: orange "V2" badge pill shown next to token name when `version >= 2` |

Badge uses `btcOrange` theme color with black text, compact styling — consistent with project UI patterns.

---

## Summary

All 4 tasks complete. The token list provider correctly fetches and merges V1+V2, the detail provider version-gates API calls, the detail screen shows all V2-specific fields plus withdrawal history, and the list tile displays a version badge. No issues found.
