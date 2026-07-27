# PrivacyV1Controller Integration Guide

## VFX & vBTC Privacy Layer

**Base URL:** `privacyapi/PrivacyV1`  
**Authentication:** Action filter controlled (see `ActionFilterController`)  
**Content-Type:** `application/json`

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Shielded Address Management](#shielded-address-management)
4. [VFX Privacy Operations](#vfx-privacy-operations)
5. [vBTC Privacy Operations](#vbtc-privacy-operations)
6. [Balance & Pool Queries](#balance--pool-queries)
7. [Scanning & Resync](#scanning--resync)
8. [Viewing Key Management](#viewing-key-management)
9. [System Status](#system-status)
10. [Error Handling](#error-handling)
11. [Integration Workflow Examples](#integration-workflow-examples)

---

## Overview

The Privacy Layer provides a UTXO-based shielded pool for both **VFX** (native coin) and **vBTC** (wrapped Bitcoin) assets. It uses Pedersen commitments, encrypted notes, nullifiers, and PLONK zero-knowledge proofs to enable:

- **Shield (T→Z):** Move transparent funds into the shielded pool
- **Unshield (Z→T):** Move shielded funds back to a transparent address
- **Private Transfer (Z→Z):** Transfer shielded funds to another shielded address
- **Consolidate:** Merge dust notes into fewer, larger notes

All shielded addresses use the `zfx_` prefix and are derived from HD wallet seeds.

### Key Concepts

| Concept | Description |
|---------|-------------|
| **zfx_ address** | Shielded address derived from HD wallet seed. Used for both VFX and vBTC. |
| **Commitment** | Pedersen commitment hiding amount + randomness. Stored as Base64. |
| **Nullifier** | Derived from viewing key + note hash + tree position. Prevents double-spend. |
| **Note** | Encrypted payload containing amount, randomness, asset type. Only decryptable by recipient. |
| **Tree Position** | Position of a commitment in the global Merkle tree for its asset type. |
| **Asset Key** | `"VFX"` for native VFX, `"VBTC:{contractUid}"` for vBTC contracts. |

### vBTC Dual-Input Model

vBTC privacy operations (unshield, transfer, consolidate) require **two types of inputs**:
1. **vBTC inputs** — shielded vBTC commitments for the value being transferred
2. **VFX fee input** — a single shielded VFX note to cover the fixed ZK fee (`Globals.PrivateTxFixedFee`)

This means users must have shielded VFX available to perform vBTC privacy operations.

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│              PrivacyV1Controller                 │
│  privacyapi/PrivacyV1/*                         │
├─────────────────────────────────────────────────┤
│                                                  │
│  VFX Endpoints          vBTC Endpoints           │
│  ─────────────          ──────────────           │
│  ShieldVFX              ShieldVBTC               │
│  UnshieldVFX            UnshieldVBTC             │
│  PrivateTransferVFX     PrivateTransferVBTC      │
│  ConsolidateShieldedVFX ConsolidateShieldedVBTC  │
│  GetShieldedBalance     GetShieldedVbtcBalance   │
│  GetShieldedPoolState   GetVbtcShieldedPoolState │
│  ScanShielded           ScanShieldedVBTC         │
│  ResyncShieldedWallet   ResyncShieldedVBTC       │
│                                                  │
│  Shared Endpoints                                │
│  ────────────────                                │
│  GetPlonkStatus                                  │
│  GenerateShieldedAddress                         │
│  ExportViewingKey                                │
│  ImportViewingKey                                │
│                                                  │
├─────────────────────────────────────────────────┤
│  VfxPrivateTransactionBuilder                    │
│  VbtcPrivateTransactionBuilder                   │
│  ShieldedWalletService                           │
│  ShieldedPoolService                             │
│  CommitmentSelectionService                      │
│  PrivacyApiHelper                                │
│  PLONKSetup / PlonkNative                        │
└─────────────────────────────────────────────────┘
```

---

## Response Format

All endpoints return JSON with a consistent envelope:

**Success:**
```json
{
  "Success": true,
  "Result": { ... }
}
```

**Error:**
```json
{
  "Success": false,
  "Message": "Error description"
}
```

---

## Shielded Address Management

### Create Shielded Address from Account (Recommended)

Derives a `zfx_` address from a transparent account's private key. No HD wallet required. The shielded wallet is persisted on the node.

**`POST /privacyapi/PrivacyV1/CreateShieldedAddressFromAccount`**

**Request Body:**
```json
{
  "TransparentAddress": "RBx..."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `TransparentAddress` | string | Yes | A transparent VFX address that exists in the local wallet. |

**Response:**
```json
{
  "Success": true,
  "Result": {
    "ZfxAddress": "zfx_abc123...",
    "TransparentSourceAddress": "RBx..."
  }
}
```

> **Note:** This derives the shielded address deterministically from the account's private key using `ShieldedHdDerivation.DeriveFromPrivateKey`. Calling it again with the same address returns the same `zfx_` address.

---

### Generate Shielded Address (HD Wallet)

Derives a `zfx_` address from an HD wallet seed. Only needed if using HD wallet-based derivation.

**`POST /privacyapi/PrivacyV1/GenerateShieldedAddress`**

**Request Body:**
```json
{
  "UseLocalHdWallet": true,
  "WalletSeedHex": null,
  "CoinType": 889,
  "AddressIndex": 0
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `UseLocalHdWallet` | bool | No | If `true`, uses the local HD wallet seed from the node's DB. |
| `WalletSeedHex` | string | No | Explicit hex-encoded seed (ignored if `UseLocalHdWallet` is true). |
| `CoinType` | uint | No | BIP-44 coin type. Default: `889`. |
| `AddressIndex` | uint | No | Address index in derivation path. Default: `0`. |

> **Note:** Either `UseLocalHdWallet: true` or `WalletSeedHex` must be provided. Requires an HD wallet on the node.

**Response:**
```json
{
  "Success": true,
  "Result": {
    "ZfxAddress": "zfx_abc123...",
    "DerivationPath": "m/44'/889'/0'/0/0",
    "CoinType": 889,
    "AddressIndex": 0
  }
}
```

---

## VFX Privacy Operations

### Shield VFX (T→Z)

Moves VFX from a transparent address into the shielded pool. Creates a Pedersen commitment and encrypted note for the recipient.

**`POST /privacyapi/PrivacyV1/ShieldVFX`**

**Request Body:**
```json
{
  "FromAddress": "RBx...",
  "ShieldAmount": 100.0,
  "TransparentFee": null,
  "RecipientZfxAddress": "zfx_abc123...",
  "Memo": "optional memo"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `FromAddress` | string | Yes | Transparent VFX address (must exist in local wallet). |
| `ShieldAmount` | decimal | Yes | Amount of VFX to shield. |
| `TransparentFee` | decimal | No | Override transparent TX fee. Auto-calculated if null. |
| `RecipientZfxAddress` | string | Yes | Target `zfx_` address to receive the shielded note. Can be self. |
| `Memo` | string | No | Optional plaintext memo encrypted inside the note. |

**Response:** Broadcast result from the network.

---

### Unshield VFX (Z→T)

Moves VFX from the shielded pool back to a transparent address. Spends shielded notes and produces a transparent output.

**`POST /privacyapi/PrivacyV1/UnshieldVFX`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_abc123...",
  "WalletPassword": null,
  "TransparentToAddress": "RBx...",
  "TransparentAmount": 50.0
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ZfxAddress` | string | Yes | Sender's `zfx_` address. |
| `WalletPassword` | string | No | Password to decrypt spending key (if wallet is encrypted). |
| `TransparentToAddress` | string | Yes | Destination transparent VFX address. |
| `TransparentAmount` | decimal | Yes | Amount to unshield. The fixed ZK fee is deducted from shielded inputs. |

**Note:** Input selection automatically picks VFX notes totaling `TransparentAmount + PrivateTxFixedFee`. Change is returned as a new shielded note to the sender.

---

### Private Transfer VFX (Z→Z)

Transfers shielded VFX from one `zfx_` address to another. Fully private — no transparent amounts visible on-chain.

**`POST /privacyapi/PrivacyV1/PrivateTransferVFX`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_sender...",
  "WalletPassword": null,
  "RecipientZfxAddress": "zfx_recipient...",
  "PaymentAmount": 25.0
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ZfxAddress` | string | Yes | Sender's `zfx_` address. |
| `WalletPassword` | string | No | Password to decrypt spending key. |
| `RecipientZfxAddress` | string | Yes | Recipient's `zfx_` address. |
| `PaymentAmount` | decimal | Yes | Amount to transfer. Fee deducted from inputs. |

---

### Consolidate Shielded VFX

Merges the two smallest unspent VFX notes into a single note (Z→Z to self). Useful for reducing dust. Call repeatedly to merge additional pairs.

**`POST /privacyapi/PrivacyV1/ConsolidateShieldedVFX`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_abc123...",
  "WalletPassword": null
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ZfxAddress` | string | Yes | Your `zfx_` address. |
| `WalletPassword` | string | No | Password to decrypt spending key. |

**Requirements:** At least 2 unspent VFX notes. Combined amount must exceed the fixed shielded fee.

---

## vBTC Privacy Operations

### Shield vBTC (T→Z)

Moves vBTC from a transparent address into the shielded pool. This is a transparent-to-shielded operation that burns vBTC on the transparent side.

**`POST /privacyapi/PrivacyV1/ShieldVBTC`**

**Request Body:**
```json
{
  "FromAddress": "RBx...",
  "VbtcContractUid": "abc123-def456...",
  "VbtcAmount": 0.5,
  "TransparentFee": null,
  "RecipientZfxAddress": "zfx_abc123...",
  "Memo": "optional memo"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `FromAddress` | string | Yes | Transparent VFX address holding the vBTC contract (must be in local wallet). |
| `VbtcContractUid` | string | Yes | The smart contract UID of the vBTC token. |
| `VbtcAmount` | decimal | Yes | Amount of vBTC to shield. Must be ≥ `Globals.MinShieldAmountVBTC`. |
| `TransparentFee` | decimal | No | Override transparent TX fee. Auto-calculated if null. |
| `RecipientZfxAddress` | string | Yes | Target `zfx_` address to receive the shielded vBTC note. |
| `Memo` | string | No | Optional memo encrypted inside the note. |

**Transaction Type:** `VBTC_V2_SHIELD`

---

### Unshield vBTC (Z→T)

Moves shielded vBTC back to a transparent address. **Requires both vBTC inputs AND a VFX fee input.**

**`POST /privacyapi/PrivacyV1/UnshieldVBTC`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_abc123...",
  "WalletPassword": null,
  "VbtcContractUid": "abc123-def456...",
  "TransparentToAddress": "RBx...",
  "TransparentVbtcAmount": 0.25
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ZfxAddress` | string | Yes | Sender's `zfx_` address. |
| `WalletPassword` | string | No | Password to decrypt spending key. |
| `VbtcContractUid` | string | Yes | The vBTC smart contract UID. |
| `TransparentToAddress` | string | Yes | Destination transparent address to receive vBTC. |
| `TransparentVbtcAmount` | decimal | Yes | Amount of vBTC to unshield. |

**Dual-Input Requirements:**
- vBTC inputs are auto-selected from shielded notes matching `VBTC:{contractUid}`
- A single VFX note with balance ≥ `PrivateTxFixedFee` is automatically selected for the fee
- vBTC change (if any) is returned as a new shielded vBTC note
- VFX fee change (if any) is returned as a new shielded VFX note

**Transaction Type:** `VBTC_V2_UNSHIELD`

---

### Private Transfer vBTC (Z→Z)

Transfers shielded vBTC between `zfx_` addresses. Fully private. **Requires dual inputs (vBTC + VFX fee).**

**`POST /privacyapi/PrivacyV1/PrivateTransferVBTC`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_sender...",
  "WalletPassword": null,
  "VbtcContractUid": "abc123-def456...",
  "RecipientZfxAddress": "zfx_recipient...",
  "PaymentAmount": 0.1
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ZfxAddress` | string | Yes | Sender's `zfx_` address. |
| `WalletPassword` | string | No | Password to decrypt spending key. |
| `VbtcContractUid` | string | Yes | The vBTC smart contract UID. |
| `RecipientZfxAddress` | string | Yes | Recipient's `zfx_` address. |
| `PaymentAmount` | decimal | Yes | Amount of vBTC to transfer. |

**Transaction Type:** `VBTC_V2_PRIVATE_TRANSFER`

---

### Consolidate Shielded vBTC

Merges the two smallest unspent vBTC notes (for a specific contract) into one. **Requires a VFX fee input.**

**`POST /privacyapi/PrivacyV1/ConsolidateShieldedVBTC`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_abc123...",
  "WalletPassword": null,
  "VbtcContractUid": "abc123-def456..."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ZfxAddress` | string | Yes | Your `zfx_` address. |
| `WalletPassword` | string | No | Password to decrypt spending key. |
| `VbtcContractUid` | string | Yes | The vBTC smart contract UID. |

**Requirements:**
- At least 2 unspent vBTC notes for the specified contract
- A VFX note with balance ≥ `PrivateTxFixedFee`

---

## Balance & Pool Queries

### Get Shielded Balance (VFX — all assets)

Returns all shielded balances for a `zfx_` address, grouped by asset type.

**`GET /privacyapi/PrivacyV1/GetShieldedBalance?zfxAddress={addr}&includeCommitments={bool}`**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `zfxAddress` | string | Yes | The `zfx_` address to query. |
| `includeCommitments` | bool | No | If `true`, includes sanitized note list (no randomness). Default: `false`. |

**Response:**
```json
{
  "Success": true,
  "Result": {
    "ShieldedBalances": {
      "VFX": 150.0,
      "VBTC:abc123-def456": 0.75
    },
    "UnspentCommitments": 5,
    "UnspentSum": 150.75,
    "LastScannedBlock": 1234567,
    "IsViewOnly": false
  }
}
```

With `includeCommitments=true`, adds:
```json
{
  "Commitments": [
    {
      "Commitment": "base64...",
      "AssetType": "VFX",
      "Amount": 50.0,
      "TreePosition": 42,
      "BlockHeight": 1234500,
      "IsSpent": false
    }
  ]
}
```

---

### Get Shielded vBTC Balance

Returns the shielded vBTC balance for a specific contract UID.

**`GET /privacyapi/PrivacyV1/GetShieldedVbtcBalance?zfxAddress={addr}&vbtcContractUid={uid}&includeCommitments={bool}`**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `zfxAddress` | string | Yes | The `zfx_` address. |
| `vbtcContractUid` | string | Yes | The vBTC contract UID. |
| `includeCommitments` | bool | No | Include individual note details. Default: `false`. |

**Response:**
```json
{
  "Success": true,
  "Result": {
    "VbtcContractUid": "abc123-def456...",
    "AssetKey": "VBTC:abc123-def456...",
    "ShieldedVbtcBalance": 0.75,
    "UnspentCommitments": 3,
    "LastScannedBlock": 1234567,
    "IsViewOnly": false
  }
}
```

---

### Get Shielded Pool State (VFX)

Returns the global pool state for an asset.

**`GET /privacyapi/PrivacyV1/GetShieldedPoolState?asset={assetKey}`**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `asset` | string | No | Asset key. Default: `"VFX"`. Can also use `"VBTC:{uid}"`. |

**Response:**
```json
{
  "Success": true,
  "Result": {
    "AssetType": "VFX",
    "CurrentMerkleRoot": "base64...",
    "TotalCommitments": 1500,
    "TotalShieldedSupply": 50000.0,
    "LastUpdateHeight": 1234567
  }
}
```

---

### Get vBTC Shielded Pool State

Returns the pool state for a specific vBTC contract.

**`GET /privacyapi/PrivacyV1/GetVbtcShieldedPoolState?vbtcContractUid={uid}`**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `vbtcContractUid` | string | Yes | The vBTC contract UID. |

**Response:**
```json
{
  "Success": true,
  "Result": {
    "VbtcContractUid": "abc123-def456...",
    "AssetType": "VBTC:abc123-def456...",
    "CurrentMerkleRoot": "base64...",
    "TotalCommitments": 250,
    "TotalShieldedSupply": 12.5,
    "LastUpdateHeight": 1234500
  }
}
```

---

## Scanning & Resync

### Scan Shielded (VFX — all assets)

Scans a block range for notes decryptable by the wallet's encryption key. Updates the local wallet row with new notes and marks spent notes.

**`POST /privacyapi/PrivacyV1/ScanShielded`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_abc123...",
  "WalletPassword": null,
  "FromHeight": 1234000,
  "ToHeight": 1234567
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ZfxAddress` | string | Yes | The `zfx_` address to scan for. |
| `WalletPassword` | string | No | If provided, uses full key material. Otherwise uses viewing key only. |
| `FromHeight` | long | Yes | Start block height (inclusive). |
| `ToHeight` | long | Yes | End block height (inclusive). |

**Response:**
```json
{
  "Success": true,
  "Result": {
    "NotesFound": 3,
    "NotesMarkedSpent": 1,
    "LastScannedBlock": 1234567,
    "BlocksScanned": 568,
    "TransactionsScanned": 1200,
    "FromHeight": 1234000,
    "ToHeight": 1234567
  }
}
```

> **Note:** This scan picks up notes of ALL asset types (VFX, vBTC, etc.) that are encrypted to the wallet's key.

---

### Scan Shielded vBTC

Scans a block range for vBTC notes only, scoped to a specific contract UID. Useful for targeted scanning of a single vBTC token.

**`POST /privacyapi/PrivacyV1/ScanShieldedVBTC`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_abc123...",
  "WalletPassword": null,
  "VbtcContractUid": "abc123-def456...",
  "FromHeight": 1234000,
  "ToHeight": 1234567
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ZfxAddress` | string | Yes | The `zfx_` address. |
| `WalletPassword` | string | No | Optional password for full key material. |
| `VbtcContractUid` | string | Yes | The vBTC contract UID to filter notes. |
| `FromHeight` | long | Yes | Start block height. |
| `ToHeight` | long | Yes | End block height. |

**Response:**
```json
{
  "Success": true,
  "Result": {
    "VbtcContractUid": "abc123-def456...",
    "AssetKey": "VBTC:abc123-def456...",
    "NotesFound": 2,
    "NotesMarkedSpent": 0,
    "LastScannedBlock": 1234567,
    "BlocksScanned": 568,
    "TransactionsScanned": 1200,
    "ShieldedVbtcBalance": 0.75,
    "FromHeight": 1234000,
    "ToHeight": 1234567
  }
}
```

---

### Resync Shielded Wallet (VFX — full)

Wipes all cached notes and balances, then rescans from scratch. Use to fix corrupted or inflated balances.

**`POST /privacyapi/PrivacyV1/ResyncShieldedWallet`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_abc123...",
  "FromHeight": 0,
  "ToHeight": 0
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ZfxAddress` | string | Yes | The `zfx_` address. |
| `FromHeight` | long | Yes | Start block. Use `0` for genesis. |
| `ToHeight` | long | Yes | End block. Use `0` for current chain height. |

---

### Resync Shielded vBTC

Wipes cached vBTC notes **only for the specified contract**, then rescans. Does NOT affect VFX notes or other vBTC contracts.

**`POST /privacyapi/PrivacyV1/ResyncShieldedVBTC`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_abc123...",
  "VbtcContractUid": "abc123-def456...",
  "FromHeight": 0,
  "ToHeight": 0
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ZfxAddress` | string | Yes | The `zfx_` address. |
| `VbtcContractUid` | string | Yes | The vBTC contract UID to resync. |
| `FromHeight` | long | Yes | Start block. Use `0` for genesis. |
| `ToHeight` | long | Yes | End block. Use `0` for current chain height. |

---

## Viewing Key Management

### Export Viewing Key

Exports the 32-byte viewing key (Base64) for watch-only import on another device.

**`POST /privacyapi/PrivacyV1/ExportViewingKey`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_abc123...",
  "WalletPassword": null
}
```

**Response:**
```json
{
  "Success": true,
  "Result": {
    "ViewingKeyBase64": "aGVsbG93b3JsZC4uLg=="
  }
}
```

---

### Import Viewing Key

Creates a view-only wallet row from a viewing key. Can scan for incoming notes but **cannot spend**.

**`POST /privacyapi/PrivacyV1/ImportViewingKey`**

**Request Body:**
```json
{
  "ZfxAddress": "zfx_abc123...",
  "ViewingKeyBase64": "aGVsbG93b3JsZC4uLg==",
  "TransparentSourceAddress": "RBx..."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ZfxAddress` | string | Yes | The `zfx_` address this key belongs to. |
| `ViewingKeyBase64` | string | Yes | 32-byte viewing key encoded as Base64. |
| `TransparentSourceAddress` | string | No | Optional transparent address association. |

---

## System Status

### Get PLONK Status

Returns the node's PLONK zero-knowledge proof capabilities.

**`GET /privacyapi/PrivacyV1/GetPlonkStatus`**

**Response:**
```json
{
  "Success": true,
  "Result": {
    "ProofVerificationImplemented": true,
    "ProofProvingImplemented": true,
    "EnforcePlonkProofsForZk": true,
    "ParamsBytesMirrored": 4194304,
    "ParamsPathEnvSet": true,
    "NativeCapabilities": 7,
    "CapVerifyV1": true,
    "CapParsePublicInputsV1": true,
    "CapProveV1": true
  }
}
```

| Field | Description |
|-------|-------------|
| `ProofVerificationImplemented` | Whether the node can verify PLONK proofs. |
| `ProofProvingImplemented` | Whether the node can generate PLONK proofs. |
| `EnforcePlonkProofsForZk` | Whether the network enforces proof verification for ZK transactions. |
| `CapVerifyV1` / `CapProveV1` | Native FFI capability flags. |

---

## Error Handling

### Common Error Patterns

| Error Message | Cause | Resolution |
|---------------|-------|------------|
| `"FromAddress not found in local wallet."` | The transparent address doesn't exist in this node's wallet. | Import or create the account first. |
| `"No shielded wallet row for this zfx address."` | No shielded wallet exists for this `zfx_` address. | Generate a shielded address first. |
| `"Cannot sign (wallet locked?)."` | Private key unavailable. | Unlock the wallet or provide password. |
| `"Input selection failed."` | Insufficient shielded balance. | Shield more funds or consolidate notes. |
| `"No VFX note with sufficient balance to cover the fixed ZK fee of X VFX."` | No single VFX note large enough for the fee. | Shield VFX first, or consolidate existing VFX notes. |
| `"Need at least two unspent notes to consolidate."` | Less than 2 notes available. | Cannot consolidate with fewer than 2 notes. |
| `"Signature failed."` | ECDSA signature creation failed. | Check account key integrity. |

### Rollback Safety

All spending operations (unshield, transfer, consolidate) implement **optimistic local spend marking** with rollback:

1. Notes are marked as spent locally **before** broadcast (prevents race conditions with auto-scanner)
2. If build or broadcast fails, notes are **automatically unmarked** (rolled back)
3. This ensures no notes are permanently "stuck" as spent if a transaction fails

---

## Integration Workflow Examples

### Example 1: Shield VFX and Send Privately

```
Step 1: Create shielded address from transparent account
  POST /CreateShieldedAddressFromAccount { "TransparentAddress": "RBxMyTransparent..." }
  → zfx_myaddr...

Step 2: Shield VFX from transparent wallet
  POST /ShieldVFX {
    "FromAddress": "RBxMyTransparent...",
    "ShieldAmount": 100,
    "RecipientZfxAddress": "zfx_myaddr..."
  }

Step 3: Scan to pick up the new note
  POST /ScanShielded {
    "ZfxAddress": "zfx_myaddr...",
    "FromHeight": <currentHeight - 10>,
    "ToHeight": <currentHeight>
  }

Step 4: Check balance
  GET /GetShieldedBalance?zfxAddress=zfx_myaddr...

Step 5: Send privately to another zfx_ address
  POST /PrivateTransferVFX {
    "ZfxAddress": "zfx_myaddr...",
    "RecipientZfxAddress": "zfx_recipient...",
    "PaymentAmount": 25.0
  }
```

### Example 2: Shield vBTC and Transfer Privately

```
Step 1: Create shielded address (if not already done)
  POST /CreateShieldedAddressFromAccount { "TransparentAddress": "RBxMyAddr..." }

Step 2: Ensure you have shielded VFX for fees
  POST /ShieldVFX {
    "FromAddress": "RBxMyAddr...",
    "ShieldAmount": 10,
    "RecipientZfxAddress": "zfx_myaddr..."
  }
  POST /ScanShielded { ... }

Step 3: Shield vBTC
  POST /ShieldVBTC {
    "FromAddress": "RBxMyAddr...",
    "VbtcContractUid": "abc123-def456...",
    "VbtcAmount": 0.5,
    "RecipientZfxAddress": "zfx_myaddr..."
  }

Step 4: Scan for the vBTC note
  POST /ScanShieldedVBTC {
    "ZfxAddress": "zfx_myaddr...",
    "VbtcContractUid": "abc123-def456...",
    "FromHeight": <currentHeight - 10>,
    "ToHeight": <currentHeight>
  }

Step 5: Transfer vBTC privately (requires VFX for fee)
  POST /PrivateTransferVBTC {
    "ZfxAddress": "zfx_myaddr...",
    "VbtcContractUid": "abc123-def456...",
    "RecipientZfxAddress": "zfx_recipient...",
    "PaymentAmount": 0.1
  }
```

### Example 3: Consolidate Dust Notes

```
# Check how many notes you have
GET /GetShieldedBalance?zfxAddress=zfx_myaddr...&includeCommitments=true

# Consolidate VFX (merges 2 smallest notes each call)
POST /ConsolidateShieldedVFX {
  "ZfxAddress": "zfx_myaddr..."
}

# Consolidate vBTC (requires VFX fee note)
POST /ConsolidateShieldedVBTC {
  "ZfxAddress": "zfx_myaddr...",
  "VbtcContractUid": "abc123-def456..."
}

# Scan to pick up consolidated notes
POST /ScanShielded { ... }
```

### Example 4: Watch-Only Wallet

```
# On the spending node: export viewing key
POST /ExportViewingKey { "ZfxAddress": "zfx_myaddr..." }
→ ViewingKeyBase64: "..."

# On the watching node: import viewing key
POST /ImportViewingKey {
  "ZfxAddress": "zfx_myaddr...",
  "ViewingKeyBase64": "..."
}

# Scan to discover notes (view-only — no password needed)
POST /ScanShielded {
  "ZfxAddress": "zfx_myaddr...",
  "FromHeight": 0,
  "ToHeight": <currentHeight>
}

# Check balance (view-only wallet can see balances but NOT spend)
GET /GetShieldedBalance?zfxAddress=zfx_myaddr...
```

---

## Complete Endpoint Reference

| # | Method | Endpoint | Asset | Description |
|---|--------|----------|-------|-------------|
| 1 | GET | `GetPlonkStatus` | — | PLONK ZK proof system status |
| 2 | POST | `CreateShieldedAddressFromAccount` | — | Derive `zfx_` address from transparent account (recommended) |
| 2b | POST | `GenerateShieldedAddress` | — | Derive `zfx_` address from HD seed (requires HD wallet) |
| 3 | POST | `ExportViewingKey` | — | Export viewing key (Base64) |
| 4 | POST | `ImportViewingKey` | — | Import view-only wallet |
| 5 | POST | `ShieldVFX` | VFX | Transparent → Shielded |
| 6 | POST | `UnshieldVFX` | VFX | Shielded → Transparent |
| 7 | POST | `PrivateTransferVFX` | VFX | Shielded → Shielded |
| 8 | POST | `ConsolidateShieldedVFX` | VFX | Merge dust notes |
| 9 | GET | `GetShieldedBalance` | All | All-asset shielded balance |
| 10 | GET | `GetShieldedPoolState` | Any | Pool state by asset key |
| 11 | POST | `ScanShielded` | All | Scan blocks for all notes |
| 12 | POST | `ResyncShieldedWallet` | All | Wipe & rescan all notes |
| 13 | POST | `ShieldVBTC` | vBTC | Transparent → Shielded |
| 14 | POST | `UnshieldVBTC` | vBTC | Shielded → Transparent (dual-input) |
| 15 | POST | `PrivateTransferVBTC` | vBTC | Shielded → Shielded (dual-input) |
| 16 | POST | `ConsolidateShieldedVBTC` | vBTC | Merge dust notes (dual-input) |
| 17 | GET | `GetShieldedVbtcBalance` | vBTC | Contract-scoped vBTC balance |
| 18 | GET | `GetVbtcShieldedPoolState` | vBTC | Contract-scoped pool state |
| 19 | POST | `ScanShieldedVBTC` | vBTC | Contract-scoped note scan |
| 20 | POST | `ResyncShieldedVBTC` | vBTC | Contract-scoped wipe & rescan |