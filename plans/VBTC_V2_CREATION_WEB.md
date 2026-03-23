# vBTC V2 Token Creation — Web Plan

## Scope

Implement vBTC V2 token creation in the web wallet. The web wallet has no local CLI — all operations go through the Spyglass/Explorer API proxy.

**Status:** High-level. Blocked on Spyglass proxy implementation for MPC ceremony endpoints.

**Prerequisite:** Desktop plan should be completed first. The ceremony progress modal and model layer can be shared.

---

## Architecture Overview

The web flow mirrors the desktop flow but routes through Spyglass instead of localhost:

```
Web Wallet → Spyglass/Explorer API (proxy) → Validator Node → MPC Ceremony
Web Wallet → CreateVBTCContractRaw (signed payload) → On-chain contract
```

---

## Phase 1: Spyglass Proxy Endpoints (Backend Work)

New endpoints needed on the Spyglass/Explorer service to proxy ceremony requests to a validator node:

| Proxy Endpoint | Proxied To | Purpose |
|----------------|-----------|---------|
| `POST /btc/vbtc-v2/initiate-ceremony/{address}` | `InitiateMPCCeremony` on a validator | Start DKG ceremony |
| `GET /btc/vbtc-v2/ceremony-status/{ceremonyId}` | `GetCeremonyStatus` on the validator | Poll ceremony progress |

This is similar to how the existing `vbtc-compile-data` endpoint works — Spyglass acts as a bridge.

**Owner:** Blockchain dev / Spyglass team

---

## Phase 2: Explorer Service Additions

**Modify:** `lib/core/services/explorer_service.dart`

Add new methods:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `initiateVbtcV2Ceremony(address)` | `POST /btc/vbtc-v2/initiate-ceremony/{address}` | Start ceremony via proxy |
| `getVbtcV2CeremonyStatus(ceremonyId)` | `GET /btc/vbtc-v2/ceremony-status/{id}` | Poll ceremony via proxy |

These return the same data structures as the CLI endpoints — the `MpcCeremony` model from the desktop plan can be reused.

---

## Phase 3: Update Web Submission Flow

**Modify:** `lib/features/btc/providers/tokenize_btc_form_provider.dart`

Update `submitWeb()` to use V2 ceremony flow:

1. Call `ExplorerService.initiateVbtcV2Ceremony()` instead of `ExplorerService.vbtcCompileData()`
2. Poll `getVbtcV2CeremonyStatus()` (reuse polling logic from desktop `MpcCeremonyProvider`)
3. On completion, use `CreateVBTCContractRaw` with signed payload via `RawService`
4. Show same ceremony progress modal as desktop

The existing `RawService.compileAndMintSmartContract()` pattern with signed payloads will be used for the final contract creation step.

---

## Phase 4: Shared UI Components

The ceremony progress modal (`mpc_ceremony_progress_modal.dart`) built in the desktop plan should work for both platforms — it just consumes the ceremony state from the provider.

If the provider needs platform-aware data sourcing, the `MpcCeremonyProvider` can accept a strategy/callback for the polling source (CLI vs Explorer API).

---

## Open Items

- [ ] Spyglass proxy endpoint design and implementation
- [ ] Signed payload format for `CreateVBTCContractRaw` — does web need `Timestamp`, `UniqueId`, `OwnerSignature`?
- [ ] How does the web wallet sign the contract creation request? (JS interop for VFX key signing)
- [ ] Multi-asset and custom image support in V2 (same blocker as desktop)

---

## File Summary

| File | Action | Phase |
|------|--------|-------|
| Spyglass service (external repo) | **New endpoints** | 1 |
| `lib/core/services/explorer_service.dart` | **Modify** | 2 |
| `lib/features/btc/providers/tokenize_btc_form_provider.dart` | **Modify** | 3 |
| `lib/features/btc/components/mpc_ceremony_progress_modal.dart` | **Shared** (from desktop plan) | 4 |
