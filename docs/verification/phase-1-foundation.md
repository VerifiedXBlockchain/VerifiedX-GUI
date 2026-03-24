# Phase 1: Foundation (Service + Models) — Verification Report

**Phase Objective:** Pure data layer — service and models. No UI. Can be verified by importing and calling from a test.

**Reviewed:** 2026-03-24

---

## Plan Task Checklist

### Service: `lib/features/privacy/services/privacy_service.dart`

- [x] Extends `BaseService` with `apiBasePathOverride: "/privacyapi/PrivacyV1"`
- [x] `getPlonkStatus()` — GET `/GetPlonkStatus`
- [x] `generateShieldedAddress()` — POST `/GenerateShieldedAddress`
- [x] `shieldVfx(fromAddress, amount, recipientZfxAddress)` — POST `/ShieldVFX`
- [x] `unshieldVfx(zfxAddress, toAddress, amount)` — POST `/UnshieldVFX`
- [x] `privateTransferVfx(zfxAddress, recipientZfxAddress, amount)` — POST `/PrivateTransferVFX`
- [x] `consolidateVfx(zfxAddress)` — POST `/ConsolidateShieldedVFX`
- [x] `getShieldedBalance(zfxAddress, {includeCommitments})` — GET `/GetShieldedBalance`
- [x] `exportViewingKey(zfxAddress)` — POST `/ExportViewingKey`
- [x] `importViewingKey(zfxAddress, viewingKeyBase64, {transparentAddress})` — POST `/ImportViewingKey`
- [x] `scanShielded(zfxAddress, fromHeight, toHeight)` — POST `/ScanShielded`
- [x] `resyncShieldedWallet(zfxAddress, {fromHeight, toHeight})` — POST `/ResyncShieldedWallet`

### Model: `lib/features/privacy/models/plonk_status.dart`

- [x] Freezed model with correct fields: `proofProvingImplemented`, `proofVerificationImplemented`, `enforcePlonkProofsForZk`, `capVerifyV1`, `capProveV1`
- [x] `@JsonKey(name: "ProofProvingImplemented")` etc. — all PascalCase API field mappings correct
- [x] Includes `isPrivacyEnabled` convenience getter

### Model: `lib/features/privacy/models/shielded_address.dart`

- [x] Freezed model with correct fields: `zfxAddress`, `derivationPath`, `coinType`, `addressIndex`
- [x] `@JsonKey(name: "ZfxAddress")` etc. — all PascalCase API field mappings correct

### Model: `lib/features/privacy/models/shielded_balance.dart`

- [x] Freezed model with correct fields: `shieldedBalances` (Map<String, double>), `unspentCommitments`, `unspentSum`, `lastScannedBlock`, `isViewOnly`, `commitments` (optional list)
- [x] `@JsonKey(name: "ShieldedBalances")` etc. — all PascalCase API field mappings correct
- [x] `commitments` is nullable `List<ShieldedCommitment>?` — correct for optional `includeCommitments` param
- [x] Includes `vfxBalance` convenience getter

### Model: `lib/features/privacy/models/shielded_commitment.dart`

- [x] Freezed model with correct fields: `commitment`, `assetType`, `amount`, `treePosition`, `blockHeight`, `isSpent`
- [x] `@JsonKey(name: "Commitment")` etc. — all PascalCase API field mappings correct

### Code Generation

- [x] `.freezed.dart` files generated for all 4 models
- [x] `.g.dart` files generated for all 4 models
- [x] Generated JSON deserialization matches `@JsonKey` annotations (verified in `.g.dart` files)

---

## Findings

### API Field Mapping Verification (against `docs/prism/PRISM_INTEGRATION_GUIDE.md`)

All request parameter names in the service match the integration guide exactly:

| Endpoint | Field | Service Value | Guide Value | Match |
|----------|-------|---------------|-------------|-------|
| ShieldVFX | FromAddress | `"FromAddress"` | `FromAddress` | Yes |
| ShieldVFX | ShieldAmount | `"ShieldAmount"` | `ShieldAmount` | Yes |
| ShieldVFX | RecipientZfxAddress | `"RecipientZfxAddress"` | `RecipientZfxAddress` | Yes |
| UnshieldVFX | ZfxAddress | `"ZfxAddress"` | `ZfxAddress` | Yes |
| UnshieldVFX | TransparentToAddress | `"TransparentToAddress"` | `TransparentToAddress` | Yes |
| UnshieldVFX | TransparentAmount | `"TransparentAmount"` | `TransparentAmount` | Yes |
| PrivateTransferVFX | PaymentAmount | `"PaymentAmount"` | `PaymentAmount` | Yes |
| PrivateTransferVFX | RecipientZfxAddress | `"RecipientZfxAddress"` | `RecipientZfxAddress` | Yes |
| GenerateShieldedAddress | UseLocalHdWallet | `true` | `true` | Yes |
| ImportViewingKey | TransparentSourceAddress | `"TransparentSourceAddress"` | `TransparentSourceAddress` | Yes |

All response model PascalCase `@JsonKey` names match the API response JSON exactly (verified against guide response examples).

### Pattern Compliance

The service follows the same patterns as `BtcService`:
- Extends `BaseService` with `apiBasePathOverride`
- Uses `getJson()` for GET endpoints, `postJson()` for POST endpoints
- Handles `data['Success']` / `result['Success']` response envelope correctly
- Null-safe error handling with try/catch and print logging
- Returns null/false on error — consistent with codebase convention

The models follow existing freezed conventions:
- `const ClassName._()` private constructor
- `part` directives for `.freezed.dart` and `.g.dart`
- `@Default` for optional fields with sensible defaults
- `@JsonKey(name:)` for PascalCase API mappings
- `fromJson` factory constructor

### Notes

**Response envelope handling difference (not a blocker):** `getPlonkStatus()` and `getShieldedBalance()` access `result['Success']` directly (GET response pattern), while POST methods access `result['data']['Success']` (POST response pattern). This is correct — `BaseService.getJson()` returns the response data directly, while `BaseService.postJson()` wraps it in `{'data': data}`. The implementation handles both correctly.

**`getShieldedBalance` uses `cleanPath: false`:** This is correct because the endpoint uses query parameters (`?zfxAddress=...&includeCommitments=...`), and the trailing slash added by `cleanPath` would interfere with query string formatting.

---

## Verdict: PASS

All 12 service methods implemented with correct API mappings. All 4 models have correct freezed definitions with proper JsonKey annotations matching the integration guide. Code generation output is present and valid. Follows existing codebase patterns (BaseService, freezed, error handling).
