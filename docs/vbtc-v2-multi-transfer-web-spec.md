# vBTC V2 Multi-Contract Transfer: Web Wallet Spec

Status: draft for review. Date: 2026-09-08. Scope: testnet first; mainnet waits on the network upgrade that sets `Globals.V2TransferMultiHeight`.

Sources: Core CLI `testnet` branch at `fd1a0f35` ("vbtc multi transfer", 2026-09-01), Spyglass `testnet` branch at `af7f311`, GUI `testnet` branch.

## 1. Goal

Let a web wallet user send one vBTC amount to one recipient, drawn automatically from every V2 token contract they hold a balance on, in a single signed transaction. Same UX as the desktop GUI's rebuilt "Bulk vBTC Transfer" screen: total amount plus recipient, no token picking, allocations shown after the broadcast.

## 2. Where things stand

- Core CLI: consensus for `TransferVBTCMultiV2()` is complete and active on testnet from height 1. The keyed endpoint `POST /vbtcapi/VBTC/TransferVBTCMulti` allocates, signs and broadcasts, but it needs the sender's private key on the node, so the web wallet cannot use it. There is no raw (externally signed) multi endpoint yet.
- Desktop GUI: done. The screen calls `TransferVBTCMulti` and is gated to testnet and desktop.
- Spyglass: nothing exists for multi. The V2 indexer only recognizes `TransferVBTCV2()`, so every multi transfer that lands on chain today leaves Spyglass's vBTC ledger wrong for both parties. That part is needed regardless of the web wallet work.
- Web wallet: waits on this spec.

## 3. Design

The web wallet signs locally and never hands keys to a node. Every V2 web operation today follows one pattern: Spyglass exposes a `prepare` endpoint that proxies a CLI `GetRaw*Data` call, the CLI builds the unsigned transaction, stores it in memory keyed by hash and returns the hash, the wallet signs the hash, and Spyglass's `send` endpoint proxies the CLI `SendRaw*Tx` call which verifies and broadcasts. Spyglass holds no logic, no hashing and no pending state on that path (`api/btc/views.py:282`, `_vbtc_v2_proxy`). The single vBTC transfer uses exactly this with `GetRawTransferVBTCData` and `SendRawTransferVBTCTx` (`VBTCController.cs:2270` and `:2372`).

Multi follows the same pattern with one new CLI endpoint and two thin Spyglass proxies. The allocator stays in the CLI because that is where the state trei and the mempool are; Spyglass's indexed ledger lags the chain, cannot see the sender's pending outflows, and does not net open withdrawal requests, so allocating there would produce transactions the node rejects at verify time.

One wrinkle: the CLI's existing allocator (`VBTCService.TransferVBTCMulti`, `VBTCService.cs:683-748`) enumerates candidate contracts from `VBTCContractV2.GetAllContracts()`, a wallet-local LiteDB table that the node prunes when no local wallet claims the contract. The Spyglass node holds no wallets, so that table is empty for a web user. The raw endpoint therefore accepts the candidate contract list from the caller. Spyglass already knows which contracts an address holds (the same scoping `VbtcV2ListView` uses) and passes them along. Per-contract availability is still computed by the CLI from the state trei, incomplete withdrawals and the local mempool, exactly as the keyed endpoint does.

An alternative with no CLI change is recorded in section 9.

## 4. Core CLI: `POST /vbtcapi/VBTC/GetRawTransferVBTCMultiData`

Owner: CLI. Lives beside `GetRawTransferVBTCData` in the Raw Transaction Endpoints region of `VBTCController.cs` and shares its `_pendingRawVbtcTxs` store.

Request:

```json
{
  "FromAddress": "VFXsender...",
  "ToAddress": "VFXrecipient...",
  "TotalAmount": 0.5,
  "CandidateContracts": ["abc:1234", "def:5678"]
}
```

`CandidateContracts` is optional. When omitted the endpoint enumerates `VBTCContractV2.GetAllContracts()` as the keyed endpoint does, so a locally hosted wallet can call it too. When supplied, only those SCUIDs are considered.

Preflight, in this order, each returning `{ "Success": false, "Message": "..." }` with the same strings the keyed endpoint and validator already use:

1. Payload present; `FromAddress` and `ToAddress` non-empty.
2. `FromAddress` is not a reserve (xRBX) address.
3. `TotalAmount > 0` and `TotalAmount == Math.Round(TotalAmount, 8)`.
4. `ToAddress` normalized with `ToAddressNormalize()` so `.vfx` names resolve before the hash is built. The resolved address goes into both the transaction and the Data payload, since consensus requires them to match.
5. `ToAddress` is not a shielded address.

Availability per candidate contract, reusing the keyed endpoint's calculation: `TryGetAvailableTransparentVbtcBalance(scUid, FromAddress)` minus `VBTCWithdrawalRequest.GetIncompleteWithdrawalAmount(FromAddress, scUid)` minus the sender's pending `VBTC_V2_TRANSFER` outflows on that contract in the local mempool (`GetVbtcV2TransferOutflows`), rounded to 8 decimals, kept only if positive. Extract this and the allocation loop into a shared helper so the keyed and raw endpoints cannot drift.

Allocation: greedy, largest available first, ties broken by ordinal SCUID, `Math.Round(Math.Min(remaining, available), 8)` per contract, skipping anything under 0.00000001. Shortfall returns `Insufficient combined vBTC balance. Available: {x}, Requested: {y}`. More than 25 inputs returns the existing cap message. If more than one input is needed and `Globals.LastBlock.Height + 1 < Globals.V2TransferMultiHeight`, return the existing "not active on this network yet" message.

Single-contract fallback: when one contract covers the total, build the plain `TransferVBTCV2()` shape with a top-level `ContractUID`, byte-for-byte what `GetRawTransferVBTCData` builds. This keeps the path working before activation and identical to today's single transfer. The response still reports one allocation.

Transaction build for the multi shape:

```json
{"Function":"TransferVBTCMultiV2()","FromAddress":"VFXsender...","ToAddress":"VFXrecipient...","TotalAmount":0.5,"Inputs":[{"SCUID":"abc:1234","Amount":0.3},{"SCUID":"def:5678","Amount":0.2}]}
```

Exactly those five Data keys. `Amount = 0.0M`, `Fee` from `FeeCalcService.CalculateTXFee`, `Nonce = AccountStateTrei.GetNextNonce(FromAddress)`, `TransactionType = VBTC_V2_TRANSFER`, `UnlockTime` null. `tx.Build()`, then `_pendingRawVbtcTxs[tx.Hash] = tx`.

Response:

```json
{
  "Success": true,
  "Hash": "…",
  "Timestamp": 1757350000,
  "FromAddress": "VFXsender...",
  "ToAddress": "VFXrecipient...",
  "Amount": 0.0,
  "Fee": 0.00002,
  "Nonce": 12,
  "TransactionType": "VBTC_V2_TRANSFER",
  "UnlockTime": null,
  "TotalAmount": 0.5,
  "InputCount": 2,
  "IsSingleContract": false,
  "Allocations": [
    { "SmartContractUID": "abc:1234", "Amount": 0.3 },
    { "SmartContractUID": "def:5678", "Amount": 0.2 }
  ],
  "Message": "Sign the Hash field with your private key (ECDSA secp256k1, UTF-8 encoded hash string) and submit via SendRawTransferVBTCTx."
}
```

Send: reuse `SendRawTransferVBTCTx` unchanged. It removes the pending transaction by hash, attaches the signature, runs `TransactionValidatorService.VerifyTX`, which enforces every multi rule in section 7, and broadcasts. No new send endpoint is needed on the CLI.

Tests: extend `VerifiedXCore.Tests/VBTCV2MultiTransferTests.cs` with candidate-list allocation, the single-contract fallback shape, the 25-input cap, xRBX rejection, and a round trip showing the built transaction verifies once signed.

## 5. Spyglass

Owner: Spyglass (`vfx-explorer`). Conventions: kebab-case URLs with trailing slashes under `/api/btc/vbtc-v2/`, snake_case request keys mapped to PascalCase for the CLI, responses via `_vbtc_v2_proxy` (lowercase `success` plus the CLI's PascalCase keys verbatim), 400 `{success, message}` for validation and 500 `{success, message, raw}` for a CLI refusal. Token auth and the default 300/min throttle apply as on the other V2 routes.

### 5.1 `POST /api/btc/vbtc-v2/transfer-multi/prepare/`

Request:

```json
{ "from_address": "VFXsender...", "to_address": "VFXrecipient...", "total_amount": 0.5 }
```

Behavior:

1. Validate with a real check, not `_require_fields` truthiness: all three fields present, `total_amount` parses as a Decimal, is greater than zero and has at most 8 decimal places. A zero amount must not come back as "total_amount required".
2. Derive `CandidateContracts`: every `VbtcV2Token` whose `addresses` map has `from_address` with a positive balance, using the same token scoping as `VbtcV2ListView` (`api/btc/views.py:201`). Order does not matter; the CLI sorts.
3. Forward `{ FromAddress, ToAddress, TotalAmount, CandidateContracts }` to CLI `vbtcapi/vbtc/GetRawTransferVBTCMultiData` through `_vbtc_v2_request`, and return it through `_vbtc_v2_proxy`.

Response on success is the CLI response with `success: true` in place of `Success`, so the wallet reads `Hash`, `TotalAmount`, `InputCount`, `IsSingleContract` and `Allocations` directly.

### 5.2 `POST /api/btc/vbtc-v2/transfer-multi/send/`

Request `{ "hash": "…", "signature": "…", "public_key": "…" }`, forwarded as `{ Hash, Signature, PublicKey }` to CLI `vbtcapi/vbtc/SendRawTransferVBTCTx`. Identical to `VbtcV2TransferSendView`; share the implementation rather than copying it. A dedicated route is kept so the two flows can diverge later without a wallet change.

### 5.3 Indexer: `process_transaction`, `rbx/tasks.py:1106`

Add a branch for `func == "TransferVBTCMultiV2()"` next to the existing `TransferVBTCV2()` branch. For each entry in `parsed["Inputs"]`, `get_or_create` a `VbtcV2TokenTransfer` with `token` looked up by `SCUID`, `transaction=tx`, and defaults `from_address = parsed["FromAddress"]`, `to_address = parsed["ToAddress"]`, `amount = Decimal(input["Amount"])`, `created_at = tx.date_crafted`. A missing token logs and `continue`s to the next input rather than returning, matching the V1 `TransferCoinMulti()` loop at `rbx/tasks.py:1075`. Consensus requires distinct contracts per transaction, so the `(token, transaction)` unique constraint (`uniq_vbtcv2transfer_token_tx`) holds.

This is required independently of the endpoints. Desktop wallets can already broadcast multi transfers on testnet, and until this lands the web wallet's balances and transfer feeds are wrong after any of them.

Optional: an `is_multi` boolean on `VbtcV2TokenTransfer` with a migration and a serializer field at `api/btc/serializers.py:66`, mirroring V1's flag, so the transfers feed can label them.

### 5.4 Available balance on the token list (recommended)

`VbtcV2TokenSerializer` today exposes gross per-address balances in `addresses`; open withdrawal requests are not netted. Add `available_balances`, the same map minus the sum of that address's ACTIVE `VbtcV2WithdrawalRequest` amounts (the `settlement_amount_for` pattern at `rbx/models.py:1246`). The wallet sums it for its "Available" figure. The CLI remains the authority and will reject an over-allocation with a clear message either way.

### 5.5 Tests

Mirror `WithdrawCompleteExecuteRequiredFieldsTests` (`rbx/tests.py:1035`): required-field 400s for both endpoints, `total_amount` of `0`, negative, non-numeric and 9 decimals each rejected with a message naming the problem, candidate-list derivation from the ledger, and an indexer test that turns one multi transaction into N transfer rows and skips an unknown SCUID without aborting the others.

## 6. Web wallet (GUI repo), after 4 and 5 ship

- `ExplorerService.prepareV2TransferMulti` and `sendV2TransferMulti` beside `prepareV2Transfer` (`lib/core/services/explorer_service.dart:785`).
- `WebTokenActionsManager.transferVbtcMulti(toAddress, totalAmount)` modeled on `transferVbtcV2` (`lib/features/token/providers/web_token_actions_manager.dart:438`): prepare, `_signAndSend`, insert a pending `WebTransaction` of type 26 with amount 0, then show the allocations dialog the desktop screen already has.
- `BulkVbtcTransferScreen`: remove the `!kIsWeb` gate on the entry button, compute the available total on web from `btcWebVbtcTokenListProvider` via `balanceForAddress` (or `available_balances` once 5.4 exists), and only allow the primary keypair as sender.
- Keep the `Env.isTestNet` gate until mainnet activation.

## 7. Consensus rules the transaction must satisfy

Verified against `TransactionValidatorService.cs:2427` onward and `Transaction.cs:44`. `SendRawTransferVBTCTx` runs all of these before broadcasting, so a wallet only needs them to understand error messages.

| Rule | Detail |
| --- | --- |
| Data keys | Exactly `Function`, `FromAddress`, `ToAddress`, `TotalAmount`, `Inputs`. A top-level `ContractUID` is rejected after activation. |
| Function | `TransferVBTCMultiV2()`. The older `TransferVBTCMulti()` name is rejected as deprecated. |
| Addresses | Data `FromAddress`/`ToAddress` must equal the transaction's. Resolve `.vfx` names before building. |
| Sender | Not a reserve (xRBX) address. |
| Recipient | Not shielded. Reserve recipients are allowed by consensus; the GUI blocks them by policy. Self-send is allowed. |
| Inputs | 1 to 25, distinct SCUIDs, each `Amount > 0` with at most 8 decimals, sum equal to `TotalAmount`. |
| Balances | Per input, the sender's transparent ledger balance on that contract must cover the amount. Shielded balances never count. |
| Transaction | Type 26, `Amount` 0.0, no `UnlockTime`, fee at least 0.000003 VFX and sized to the JSON, sequential nonce. |
| Hash preimage | `Timestamp + FromAddress + ToAddress + Amount + Fee + Nonce + TransactionType + Data`, double SHA-256, where `TransactionType` renders as the enum name `VBTC_V2_TRANSFER`, not `26`. Only matters to a client that hashes itself; this design never does. |
| Signature | One ECDSA secp256k1 signature over the UTF-8 hash string, verified against the transaction's `FromAddress`. |
| Activation | Multi shape accepted only when block height reaches `Globals.V2TransferMultiHeight`: 1 on testnet, unset on mainnet. |

## 8. Sequence

1. Wallet posts `from_address`, `to_address`, `total_amount` to Spyglass `transfer-multi/prepare/`.
2. Spyglass validates, derives candidate contracts from its ledger, calls CLI `GetRawTransferVBTCMultiData`.
3. CLI computes availability, allocates, builds and stores the unsigned transaction, returns `Hash` plus `Allocations`.
4. Wallet shows the allocations, signs `Hash` with the account key.
5. Wallet posts `hash`, `signature`, `public_key` to Spyglass `transfer-multi/send/`.
6. Spyglass calls CLI `SendRawTransferVBTCTx`; the CLI verifies and broadcasts; the wallet records a pending type-26 transaction.
7. The transaction is mined; Spyglass's indexer writes one `VbtcV2TokenTransfer` row per input; balances update for sender and recipient.

## 9. Alternative considered: Spyglass builds the raw transaction

Spyglass could allocate from its own ledger, fetch timestamp, nonce and fee from `txapi/TXV1`, assemble the Data payload, get the hash from `GetTxHash`, hold the unsigned transaction in Redis with a short TTL, and on send call `VerifyRawTransaction` then `SendRawTransaction`. No CLI change. Rejected for the first version because Spyglass cannot see the sender's mempool outflows or the node's live availability, so allocations would fail at verify under normal use, and because every consensus rule in section 7 would have to be re-implemented in Python and kept in step with the node. It remains the fallback if the CLI endpoint cannot land.

## 10. Open questions

1. Does the state trei offer any index from holder address to contracts? If so the CLI could enumerate candidates itself and `CandidateContracts` becomes purely optional.
2. Should the raw endpoint also accept an explicit `Inputs` list for callers that want to choose contracts (Butterfly, power users)? Not needed for the auto-allocate UX.
3. When does mainnet get `V2TransferMultiHeight`? Both wallets stay testnet-gated until then.
4. The `_pendingRawVbtcTxs` store has no expiry. Fine for now; worth a TTL if the raw endpoints see real traffic.
