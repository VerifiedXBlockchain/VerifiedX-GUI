# Phase 1 Verification: Model + Service Layer

**Verdict: PASS**

---

## Task 1: Update `BtcWebVbtcToken` model

**File:** `lib/features/btc_web/models/btc_web_vbtc_token.dart`

| Requirement | Status |
|---|---|
| `@Default(1) int version` | Done (line 25) |
| `@JsonKey(name: 'is_pending_withdrawal') @Default(false) bool isPendingWithdrawal` | Done (line 26) |
| `@JsonKey(name: 'frost_group_public_key') String? frostGroupPublicKey` | Done (line 27) |
| `@JsonKey(name: 'required_threshold') int? requiredThreshold` | Done (line 28) |
| `@JsonKey(name: 'withdrawal_requests') List<Map<String, dynamic>>? withdrawalRequests` | Done (line 29) |
| Keep all existing V1 fields | Done — all original fields remain |
| Make `publicKeyProofs` optional (`String?`) | Done (line 21) |

---

## Task 2: Create `WebVbtcWithdrawal` model

**File:** `lib/features/btc_web/models/web_vbtc_withdrawal.dart`

| Field | Status |
|---|---|
| `requestorAddress` | Done |
| `btcAddress` | Done |
| `amount` (String) | Done |
| `feeRate` (String) | Done |
| `btcTransactionHash` (nullable) | Done |
| `status` | Done |
| `requestTransactionHash` | Done |
| `completionTransactionHash` (nullable) | Done |
| `createdAt` (DateTime) | Done |
| `completedAt` (nullable DateTime) | Done |
| Uses freezed + json_serializable | Done |

---

## Task 3: V2 methods in ExplorerService

**File:** `lib/core/services/explorer_service.dart` (lines 622-746)

| Method | Endpoint | Status | Notes |
|---|---|---|---|
| `getWebVbtcV2Tokens(address)` | `GET /btc/vbtc-v2/{address}/` | Done | Sets `version: 2` explicitly, sets `address` on each result |
| `getWebVbtcV2TokenDetail(scIdentifier)` | `GET /btc/vbtc-v2/detail/{scIdentifier}/` | Done | No address param (correct per plan). Handles missing `address` field gracefully |
| `initiateV2Ceremony(ownerAddress)` | `POST /btc/vbtc-v2/ceremony/initiate/` | Done | Body matches API spec |
| `getV2CeremonyStatus(ceremonyId)` | `GET /btc/vbtc-v2/ceremony/{ceremonyId}/` | Done | |
| `createV2Contract(...)` | `POST /btc/vbtc-v2/create/` | Done | All params present: ownerAddress, name, description, ticker, ceremonyId |
| `completeV2Withdrawal(scIdentifier, requestHash)` | `POST /btc/vbtc-v2/withdraw/complete/` | Done | 180s timeout correctly set |
| `cancelV2Withdrawal(...)` | `POST /btc/vbtc-v2/withdraw/cancel/` | Done | All params: scIdentifier, ownerAddress, requestHash, btcTxHash, failureProof |

---

## Task 4: Regenerate freezed/json files

- `btc_web_vbtc_token.freezed.dart` — exists, contains all V2 fields
- `btc_web_vbtc_token.g.dart` — exists
- `web_vbtc_withdrawal.freezed.dart` — exists, contains all fields
- `web_vbtc_withdrawal.g.dart` — exists

---

## Cross-reference with API spec

All endpoints, request bodies, and response handling match the API integration doc at `/Users/tyler/prj/vfx/vfx-explorer/docs/vbtc-v2-web-wallet-integration.md`.

---

## Summary

All 4 tasks complete. Models are correct, service methods match API spec endpoints and parameters, generated code is up to date. No issues found.
