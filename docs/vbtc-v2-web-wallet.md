# vBTC V2 — Web Wallet Implementation Plan

> Status: **Exploration / Planning**
> Last updated: 2026-05-25

## Overview

vBTC V2 is fully working on desktop (talks to local CLI). The goal is to bring it to the web wallet, which currently only supports V1. The web wallet talks to the Spyglass API, which in turn talks to a headless CLI for data syncing and tx broadcasting.

## Architecture Decision

**Approach: Proxy through Spyglass → headless CLI**

The headless CLI already has all MPC ceremony and FROST signing logic. Rather than reimplementing cryptography in JS or a new backend, the Spyglass API will proxy the relevant CLI endpoints to web users.

- Self-custodial: Yes. MPC and FROST are threshold protocols — no single party holds the full key.
- The server holds a key share but cannot move funds without the user's participation.
- Tradeoff: server becomes an infrastructure dependency for create/withdraw operations.

### Open question for Aaron/Jay
> Does the headless CLI support running MPC ceremonies and FROST signing on behalf of a remote user's address? Or does it assume it owns the keys locally? If the latter, CLI-side work is needed to accept externally-provided key shares.

---

## Current State

### Desktop (fully working)
- **Service**: `lib/features/btc/services/vbtc_v2_service.dart`
- Talks to local CLI at `/vbtcapi/vbtc/*`
- All operations: create (MPC), transfer, withdraw (FROST), cancel

### Web V1 (working)
- **Service**: `lib/features/token/providers/web_token_actions_manager.dart`
- Builds raw transactions in Dart, signs with secp256k1, sends via `RawService`
- Operations: transfer, withdraw, transfer ownership
- No version awareness — assumes V1

### Spyglass API (V1 only)
- `GET /btc/vbtc/{address}/` — list user's V1 tokens
- `GET /btc/vbtc/detail/{scIdentifier}/` — token details
- `GET /btc/vbtc-compile-data/{vfxAddress}/` — V1 compile data
- No V2 endpoints exist

---

## Operations Breakdown

### Tier 1 — May work already (test first)

| Operation | How V1 web does it | V2 compatibility | Action needed |
|-----------|-------------------|-----------------|---------------|
| **List tokens** | `GET /btc/vbtc/{address}/` | Unknown — does Spyglass index V2 contracts? | Check if V2 tokens already appear |
| **Transfer vBTC** | Raw TX with `TransferCoin()` function, type 20 | Likely same SC function | Test with a V2 contract |

### Tier 2 — Needs new Spyglass endpoints (plumbing)

| Operation | Desktop CLI endpoint | Spyglass endpoint needed |
|-----------|---------------------|------------------------|
| **List V2 tokens** | `GET /vbtcapi/vbtc/GetContractList` | `GET /btc/vbtc-v2/{address}/` |
| **Token detail** | (same endpoint, filtered) | `GET /btc/vbtc-v2/detail/{scId}/` |
| **Cancel withdrawal** | `POST /vbtcapi/vbtc/CancelWithdrawal` | `POST /btc/vbtc-v2/withdraw/cancel/` |

### Tier 3 — Needs Spyglass-to-CLI proxy (crypto operations)

| Operation | What happens | Complexity |
|-----------|-------------|------------|
| **Create contract** | MPC ceremony (distributed key gen) → contract TX | High |
| **Withdraw** | Request withdrawal → FROST signing ceremony → BTC TX | High |

These are the hard ones. Details below.

---

## Tier 3 Deep Dive

### MPC Ceremony (contract creation)

**Desktop flow:**
1. `POST /InitiateMPCCeremony/{ownerAddress}` → returns `ceremonyId`
2. Poll `GET /GetCeremonyStatus/{ceremonyId}` until complete
3. `POST /CreateVBTCContract` with `ceremonyId`, name, description, etc.

**Web flow (proposed):**
1. Web user submits create request to Spyglass
2. Spyglass calls headless CLI's `/InitiateMPCCeremony` with user's address
3. Spyglass returns `ceremonyId` to web
4. Web polls Spyglass for ceremony status (Spyglass proxies to CLI)
5. Once complete, Spyglass calls CLI's `/CreateVBTCContract`
6. Returns contract details to web

**Spyglass endpoints needed:**
- `POST /btc/vbtc-v2/ceremony/initiate/` — body: `{ ownerAddress }`
- `GET /btc/vbtc-v2/ceremony/{ceremonyId}/` — returns status + progress
- `POST /btc/vbtc-v2/create/` — body: `{ ownerAddress, name, description, ticker, ceremonyId }`

### FROST Signing (withdrawals)

**Desktop flow:**
1. `POST /RequestWithdrawal` → returns `requestHash`
2. Wait for block confirmation (~1 block)
3. `POST /CompleteWithdrawal` with `requestHash` → 120s timeout for FROST signing → returns BTC tx hash

**Web flow (proposed):**
1. Web sends withdrawal request to Spyglass
2. Spyglass calls CLI's `/RequestWithdrawal`
3. Returns `requestHash` to web
4. Web polls for block confirmation
5. Web sends complete request to Spyglass
6. Spyglass calls CLI's `/CompleteWithdrawal` (long timeout)
7. Returns BTC tx hash to web

**Spyglass endpoints needed:**
- `POST /btc/vbtc-v2/withdraw/request/` — body: `{ scUid, requestorAddress, btcAddress, amount, feeRate }`
- `POST /btc/vbtc-v2/withdraw/complete/` — body: `{ scUid, requestHash }` (needs long timeout, 120s+)

---

## Flutter (GUI) Changes Required

### New/modified files

| File | Change |
|------|--------|
| `lib/features/btc_web/models/btc_web_vbtc_token.dart` | Add `version` field, V2 withdrawal state fields |
| `lib/features/btc_web/components/web_btc_tokenized_action_buttons.dart` | Version-aware UI (same pattern as desktop `token.version >= 2`) |
| `lib/features/token/providers/web_token_actions_manager.dart` | Add V2 transfer/withdraw methods |
| `lib/core/services/explorer_service.dart` | Add V2 Spyglass endpoint calls |
| `lib/features/btc_web/providers/btc_web_vbtc_token_list_provider.dart` | Support V2 token listing |

### UI components to add
- MPC ceremony progress dialog (similar to desktop's flow)
- V2 withdrawal processing dialog (similar to `withdrawal_processing_dialog.dart`)
- Version badge on token list tiles

---

## Implementation Order

### Phase 1 — Discovery (no code changes)
- [ ] Check if Spyglass already indexes V2 contracts at `/btc/vbtc/{address}/`
- [ ] Test if `TransferCoin()` raw TX works for V2 contracts
- [ ] Ask Aaron: can the headless CLI run MPC/FROST for a remote user's address?

### Phase 2 — Read path (list + detail)
- [ ] Add V2 token listing endpoint to Spyglass (or confirm existing one works)
- [ ] Update `BtcWebVbtcToken` model with version + V2 fields
- [ ] Update web token list provider to handle V2

### Phase 3 — Transfer
- [ ] If Phase 1 confirms `TransferCoin()` works for V2 → done
- [ ] If not, add V2-specific transfer endpoint to Spyglass

### Phase 4 — Contract creation (MPC)
- [ ] Add Spyglass ceremony proxy endpoints
- [ ] CLI-side work if needed (remote user support)
- [ ] Web ceremony UI (initiate + poll + create)

### Phase 5 — Withdrawal (FROST)
- [ ] Add Spyglass withdrawal proxy endpoints (with long timeout support)
- [ ] CLI-side work if needed
- [ ] Web withdrawal UI (request + poll + complete)
- [ ] Cancel withdrawal support

---

## Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-05-21 | Proxy via Spyglass → headless CLI | Reuses existing crypto implementations, stays self-custodial |
| 2026-05-21 | Full V2 support on web (including creation) | Web is the most used wallet — can't be desktop-only |

## Open Questions

- [ ] Does the headless CLI support MPC/FROST for addresses it doesn't own locally?
- [ ] Does Spyglass already index V2 contracts?
- [ ] Is the `TransferCoin()` smart contract function the same for V1 and V2?
- [ ] What timeout limits does Spyglass have? FROST needs 120s+.
- [x] ~~Should we support V2 contract creation on web?~~ Yes — web is the most used wallet, full V2 support required.
