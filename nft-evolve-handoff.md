# Hand-off: Evolving NFTs (Raw / Web Wallet Path)

Guidance for integrating NFT **evolution** outside the GUI. Covers (A) minting an evolve-capable NFT and (B) the original minter manually triggering evolve / devolve / jump-to-specific-state. This documents the **raw path** — exactly what the web wallet does against the Spyglass raw API. No client code; just the data structures, payloads, transaction types, function strings, endpoints, and flow.

---

## Concepts up front

- **Evolution = a smart-contract feature** with an ordered list of **phases** (states). Each phase can carry its own asset (media), description, and properties.
- **Base phase is EvolutionState 0** — it is the NFT's primary/minted asset and is *synthesized*, not part of the evolve feature payload. The phases you submit in the feature start at **EvolutionState 1**.
- **Three evolve types:** `time` (Date/Time), `blockHeight` (Block Height), `manualOnly` (Manual Only). The type is **not** an explicit field — it's inferred from which trigger key (`EvolveDate` / `EvolveBlockHeight`) is populated per phase.
- **Manual control is the minter's:** evolve/devolve/jump-to-state are raw transactions signed by the **minter** and addressed to the NFT's **current owner**. Minter-only enforcement is on-chain/server-side.
- **API host (raw):** `${explorerApiBaseUrl}/raw`
  - mainnet `https://data.verifiedx.io/api/raw`
  - testnet `https://data-testnet.verifiedx.io/api/raw`
  - devnet `https://data-devnet.verifiedx.io/api/raw`
- **Conventions:** every raw endpoint path ends with a trailing `/`. Request bodies for tx ops are `{ "transaction": <txObject> }`. Responses are wrapped as `{ "data": <payload> }`.

---

## PART A — Minting an evolve-capable NFT

### A1. The evolve feature entry

Evolution is one entry in the mint payload's top-level `Features` array. Its `FeatureName` is **`0`** (the evolve compiler enum). Unlike most features (whose `FeatureFeatures` is an object), **evolution's `FeatureFeatures` is a LIST of phase objects**:

```json
{
  "FeatureName": 0,
  "FeatureFeatures": [
    { ...phase EvolutionState 1... },
    { ...phase EvolutionState 2... }
  ]
}
```

The feature is only included if there is at least one phase.

### A2. Phase object shape

Each phase in `FeatureFeatures`:

```json
{
  "Name": "Bloomed",
  "Description": "The flower has bloomed",
  "IsDynamic": true,
  "EvolutionState": 1,
  "IsCurrentState": false,
  "SmartContractAsset": {
    "AssetId": "550e8400-e29b-41d4-a716-446655440000",
    "Name": "phase1.png",
    "AssetAuthorName": "ArtistName",
    "Location": "/path/or/url",
    "Extension": "png",
    "FileSize": 102400
  },
  "EvolveDate": "2026-07-01T00:00:00.000Z",
  "EvolveBlockHeight": null,
  "Properties": { "Stage": "Bloomed" }
}
```

Field-by-field:

| Key | Type | Notes |
|---|---|---|
| `Name` | string | phase label |
| `Description` | string | |
| `IsDynamic` | bool | `true` if any phase has a date or block-height trigger; manual-only ⇒ `false` |
| `EvolutionState` | int | **1-based** (list index + 1; Base = 0 is implicit) |
| `IsCurrentState` | bool | always `false` at mint time |
| `SmartContractAsset` | object \| null | per-phase media; same shape as the primary asset. `null` for media-less phases |
| `EvolveDate` | string \| null | **UTC ISO-8601** timestamp; set only for `time` type |
| `EvolveBlockHeight` | int \| null | set only for `blockHeight` type |
| `Properties` | object \| null | flat `{name: value}` map; omitted if the phase has none. `:` and `<|>` stripped from keys and values |

`SmartContractAsset` keys: `AssetId` (required), `Name`, `AssetAuthorName` (set to the minter name), `Location`, `Extension`, `FileSize` (required). Raw bytes/local paths are never serialized.

### A3. Encoding the evolve type (no explicit field)

| Type | `EvolveDate` | `EvolveBlockHeight` | `IsDynamic` |
|---|---|---|---|
| `time` | UTC ISO-8601 | `null` | `true` |
| `blockHeight` | `null` | int | `true` |
| `manualOnly` | `null` | `null` | `false` |

- `time`: sort phases ascending by date before assigning `EvolutionState`.
- `blockHeight`: sort phases ascending by block height before assigning `EvolutionState`.
- `manualOnly`: no triggers — the NFT only changes state when the minter sends an evolve/devolve tx (Part B).

### A4. Where the feature sits in the full mint payload

The evolve feature is one element of `Features` in the standard compiler payload (same envelope used for royalties/properties):

```json
{
  "Name": "Evolving Flower",
  "MinterName": "ArtistName",
  "Description": "An NFT that blooms over time",
  "SmartContractAsset": { "...primary/base asset...": "..." },
  "IsPublic": false,
  "SmartContractUID": "00000000-0000-0000-0000-000000000000",
  "Features": [
    { "FeatureName": 0, "FeatureFeatures": [ { "...phase 1..." }, { "...phase 2..." } ] }
  ],
  "MinterAddress": "RBx...minterAddress",
  "IsMinter": true,
  "SCVersion": 1
}
```

`Properties` (top-level) is included only if the contract itself has properties. `SCVersion: 1` is added at submit time.

### A5. Mint submission flow (raw)

1. `POST /raw/smart-contract-data/` with the payload above (`SCVersion: 1` included). Response `data` = the compiled SC data blob.
2. Build a raw transaction: `TransactionType = 2` (**nftMint**), `Amount = 0`, `ToAddress = FromAddress = minter address`, `Data = <compiled blob from step 1>`.
3. Sign and submit via the standard tx flow (timestamp → nonce → fee → hash → sign → validate → verify → send). Same flow as §B4 below, just with the mint Data and tx type 2.

---

## PART B — Manually triggering evolve / devolve / jump-to-state

This is the minter-controlled state change. **Key design point:** the client does **not** build the evolve `Data` blob or pick the SC function name. It asks the raw API to build the `Data` from a single integer `stage`, then signs and sends it.

### B1. The three SC function calls

The `Data` blob's `Function` is one of these, chosen **server-side** based on the requested `stage` vs the NFT's current state:

- `Evolve()` — step up one state.
- `Devolve()` — step down one state.
- `ChangeEvolveStateSpecific()` — jump directly to a given state index.

You never send these strings — you send a target `stage` integer and the API emits the right one.

### B2. Transaction type

All three operations use **`TransactionType = 3` (nftTx)**. (For reference: burn = 4, transfer = 3 with `Function: "Transfer()"`.)

### B3. Building the evolve Data blob

```
POST /raw/nft-evolve-data/{scId}/{toAddress}/{stage}/
```

- Path segments only; **empty body**.
- `scId` — the smart-contract UID.
- `toAddress` — the NFT's **current owner** address.
- `stage` — target evolution-state index (int). See B5 for how to compute it.
- Response `data` is a JSON object → **use it verbatim as the transaction's `Data` field.** Treat it as opaque; its `Function` will be `Evolve()` / `Devolve()` / `ChangeEvolveStateSpecific()` depending on `stage` vs current state.

> Sibling endpoints follow the same "API builds the Data" pattern, if useful for cross-checking your integration:
> - Transfer: `POST /raw/nft-transfer-data/{scId}/{toAddress}/{locator}/` → `Function: "Transfer()"`
> - Burn: `POST /raw/nft-burn-data/{scId}/{toAddress}/`

### B4. Full raw-tx flow (evolve/devolve/specific)

The transaction envelope is built client-side; everything else comes from the API. Envelope fields:

```json
{
  "Hash": "",
  "ToAddress": "RBx...currentOwner",
  "FromAddress": "RBx...minter",
  "TransactionType": 3,
  "Amount": 0.0,
  "Nonce": <int>,
  "Fee": <number>,
  "Timestamp": <int>,
  "Signature": "",
  "Height": 0,
  "Data": <object from /raw/nft-evolve-data>,
  "UnlockTime": null
}
```

Sequence of raw-API calls:

1. `POST /raw/timestamp/` → `data` (int) → `Timestamp`.
2. `POST /raw/nonce/{minterAddress}/` → `data` (int) → `Nonce`.
3. `POST /raw/nft-evolve-data/{scId}/{currentOwner}/{stage}/` → `data` → `Data`.
4. Build the envelope (tx type 3, amount 0, to = current owner, from = minter). `POST /raw/fee/` with `{ "transaction": <tx> }` → `data.Fee` → set `Fee`.
5. `POST /raw/hash/` with `{ "transaction": <tx> }` → `data.Hash` → set `Hash`.
6. **Sign the hash locally** (minter's key): secp256k1 over SHA256 of the hash string, DER-encode, base64; final signature = `"<base64DER>.<base58(publicKey)>"`.
7. `POST /raw/validate-signature/{hash}/{minterAddress}/{signature}/` → expect `data == true`.
8. Set `Signature` (and `Hash`) on the tx. `POST /raw/verify/` with `{ "transaction": <tx> }` → require `data.Result != "Fail"`.
9. `POST /raw/send/` with `{ "transaction": <tx> }` → success when `data.Result == "Success"`.

(`/verify` vs `/send` are the same body; `/verify` is a dry run, `/send` executes.)

### B5. Choosing `stage` — evolve vs devolve vs specific

The operation is decided entirely by the `stage` integer relative to the NFT's current state. Remember **Base = EvolutionState 0**, and the visible/feature phases are 1-based.

Let `currentIndex` = index of the phase currently flagged `IsCurrentState == true` within the full phase list (Base included, so Base = index 0).

- **Evolve (step up):** `stage = currentIndex + 2`
- **Devolve (step down):** `stage = currentIndex`
- **Jump to specific state:** `stage = <chosen phase index>` (produces `ChangeEvolveStateSpecific()`)

The `+2` / `+0` come from the Base offset: feature `EvolutionState` values are 1-based while `currentIndex` is 0-based with Base occupying index 0. In all cases `toAddress` = the NFT's **current owner**.

### B6. Owner / minter constraint

- `FromAddress` = signing minter's address; `ToAddress` = current owner.
- Only the minter can change evolution state — enforced on-chain/server-side. In the GUI the controls are also gated to the minter, but that gating is cosmetic; the chain is the source of truth.

---

## Parsing minted NFTs back (chain → your app)

When reading an existing NFT's evolve feature (`FeatureName == 0`), each phase object exposes:
`Name`, `Description`, `EvolutionState` (int), `IsCurrentState` (bool), `EvolveDate` (epoch seconds on-chain, ISO string in the mint payload), `EvolveBlockHeight` (int?), `SmartContractAsset` (`{AssetId, Name, AssetAuthorName, Location, Extension, FileSize}`), `Properties` (flat `{name: value}`), `IsDynamic`. Parsers should tolerate both PascalCase and camelCase variants of these keys.

---

## One caveat for the Python port

The evolve `Data` blob is produced by the Spyglass `/raw/nft-evolve-data/` endpoint, **not** assembled client-side, so its exact internal field list isn't defined here. The reliable approach (and what the web wallet does) is: call that endpoint with `{scId, currentOwner, stage}` and pass the returned object straight through as the tx `Data`. If your Python backend instead builds the Core SC function call directly (as the Core CLI does for other tx types), mirror the `Evolve()` / `Devolve()` / `ChangeEvolveStateSpecific()` selection logic by `stage` vs current state yourself.

---

## Quick reference

| Operation | Endpoint to build Data | TxType | Function (server-chosen) |
|---|---|---|---|
| Mint evolve NFT | `POST /raw/smart-contract-data/` | 2 (nftMint) | — |
| Evolve (step up) | `POST /raw/nft-evolve-data/{scId}/{owner}/{stage=cur+2}/` | 3 (nftTx) | `Evolve()` |
| Devolve (step down) | `POST /raw/nft-evolve-data/{scId}/{owner}/{stage=cur}/` | 3 (nftTx) | `Devolve()` |
| Jump to state | `POST /raw/nft-evolve-data/{scId}/{owner}/{stage=N}/` | 3 (nftTx) | `ChangeEvolveStateSpecific()` |

Submit-tx flow for all: `timestamp → nonce → buildData → fee → hash → sign → validate-signature → verify → send`.
