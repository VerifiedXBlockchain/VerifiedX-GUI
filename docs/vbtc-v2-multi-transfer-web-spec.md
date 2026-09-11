# vBTC V2 Multi-Contract Transfer: Web Wallet Spec

Status: draft for review, revision 2. Date: 2026-09-08. Scope: testnet first; mainnet waits on the network upgrade that sets `Globals.V2TransferMultiHeight`.

Revision 2 drops the CLI raw endpoint and the Spyglass prepare/send proxies from revision 1. The wallet builds the transaction itself through the existing raw path. Only the Spyglass indexer change remains as a dependency.

Sources: Core CLI `testnet` branch at `fd1a0f35` ("vbtc multi transfer", 2026-09-01), Spyglass `testnet` branch at `af7f311`, GUI `testnet` branch.

## 1. Goal

Let a web wallet user send one vBTC amount to one recipient, drawn automatically from every V2 token contract they hold a balance on, in a single signed transaction. Same UX as the desktop GUI's rebuilt "Bulk vBTC Transfer" screen: total amount plus recipient, no token picking, allocations shown after the broadcast.

## 2. Where things stand

- Core CLI: consensus for `TransferVBTCMultiV2()` is complete and active on testnet from height 1. Nothing is needed from the CLI for the web path.
- Desktop GUI: done. The screen calls the keyed endpoint `POST /vbtcapi/VBTC/TransferVBTCMulti` and is gated to testnet.
- Spyglass: done on `testnet` (2026-09-08): the indexer handles `TransferVBTCMultiV2()` per input, transfers carry `is_multi`, and the token list exposes `available_balances` net of open withdrawal requests inside the CLI's 360-block expiry window.
- Web wallet: built per section 4 (GUI `testnet`, 2026-09-08). Same screen as desktop; the wallet allocates client-side and sends through the raw path. Awaiting a testnet run.

## 3. Design

The transaction is ordinary raw data. The wallet builds the Data payload locally, and the existing raw path does the rest: `RawTransaction.generate` (`lib/features/web/utils/raw_transaction.dart:31`) fetches the timestamp and nonce, builds the transaction, gets the fee, gets the hash from the node through Spyglass `/raw/hash` (which proxies `txapi/TXV1/GetTxHash`, so the node's own preimage rules apply), signs locally with secp256k1, checks the signature, then verifies and broadcasts through `/raw/verify` and `/raw/send`. This is exactly how the V1 bulk transfer worked on web before it was removed in `eeeb5723`, and how token transfers and NFT actions work today.

The wallet also chooses the inputs. It already has per-address balances for every token it holds from Spyglass's token list (`BtcWebVbtcToken.addresses`, read through `balanceForAddress`), so it runs the same greedy allocation the CLI uses and the two wallets produce the same inputs for the same balances. Consensus checks every input's balance at verify time, so a stale ledger or a pending withdrawal produces a clear rejection from the node rather than a bad transaction.

If one token covers the whole amount, the wallet uses the existing single-transfer flow (`WebTokenActionsManager.transferVbtcV2`) instead of the multi shape. That matches the CLI's own fallback and keeps the one-input case working before activation.

A CLI-side raw endpoint with server-side allocation was considered and is recorded in section 8.

## 4. Web wallet (GUI repo)

### 4.1 Allocation

Input: the sender's V2 tokens with a positive balance for the sender address, and the requested total.

1. Take each token's balance for the sender from `balanceForAddress(senderAddress)`, or from `available_balances` once section 5.2 exists, rounded to 8 decimals, keeping only positive values.
2. Sort by balance descending, ties broken by `sc_identifier` with ordinal string comparison.
3. Walk the list, taking `min(remaining, balance)` rounded to 8 decimals from each until the total is covered, skipping anything under 0.00000001.
4. Fail with the combined-balance message if the total is not covered; fail with the cap message if more than 25 inputs would be needed.
5. Use decimal-safe arithmetic (the `decimal` package or integer satoshis) so the input amounts sum exactly to the total. Consensus rejects a sum that differs from `TotalAmount` at all.

Amount entry validation is the same as desktop: positive, at most 8 decimals, not above the combined available balance. Recipient validation is `formValidatorVbtcRecipient`, which already rejects Vault and privacy addresses and does not accept `.vfx` names, so no address resolution is needed. Reject a Vault sender before allocating.

### 4.2 Data payload and transaction

```json
{
  "Function": "TransferVBTCMultiV2()",
  "FromAddress": "VFXsender...",
  "ToAddress": "VFXrecipient...",
  "TotalAmount": 0.5,
  "Inputs": [
    { "SCUID": "abc:1234", "Amount": 0.3 },
    { "SCUID": "def:5678", "Amount": 0.2 }
  ]
}
```

Exactly those five keys. Send it through `_verifyConfirmAndSendTx` (`web_token_actions_manager.dart:38`) with `txType: TxType.vbtcV2Transfer` (26) and `toAddress` equal to the Data `ToAddress`; the helper builds the transaction with `Amount` 0 and no `UnlockTime`. The deleted V1 method at `eeeb5723^:lib/features/token/providers/web_token_actions_manager.dart:551` is the skeleton: keep its structure, drop the per-input signatures and `SignatureInput`, and swap the function name, type and fields.

### 4.3 Code changes

- `WebTokenActionsManager.transferVbtcMulti(toAddress, totalAmount)`: allocate, fall back to `transferVbtcV2` for a single input, otherwise build the payload above and send it. On success insert a pending `WebTransaction` of type 26 with amount 0, as `transferVbtcV2` does at line 486, and return the allocations for display.
- A small pure `allocateVbtcInputs(balances, total)` function with unit tests covering ordering, ties, rounding, exact sums, the shortfall and the 25 cap.
- `BulkVbtcTransferScreen`: remove the `!kIsWeb` gate on the entry button, compute the available total on web from `btcWebVbtcTokenListProvider`, only allow the primary keypair as sender, and reuse the allocations dialog.
- Keep the `Env.isTestNet` gate until mainnet activation.

### 4.4 Errors the wallet will see

All come back from `/raw/verify` as `Transaction was not verified. Error: {reason}`, so surface the reason. The ones this flow can hit: `Insufficient vBTC balance for transfer input {SCUID}. Available: {x}, Requested: {y}` when Spyglass's ledger is ahead of a pending withdrawal or behind a mempool outflow; `Multi-contract vBTC transfer exceeds the maximum of 25 inputs.`; `TotalAmount must equal the sum of input amounts for multi-contract vBTC transfer.` if rounding drifts; and `ContractUID cannot be null for vBTC V2 transfer.` if the multi shape reaches a node that has not activated it. Do not call `/raw/send` without a successful verify; send discards the reason.

## 5. Spyglass

Owner: Spyglass (`vfx-explorer`). No new endpoints.

### 5.1 Indexer: `process_transaction`, `rbx/tasks.py:1106` (required)

Add a branch for `func == "TransferVBTCMultiV2()"` next to the existing `TransferVBTCV2()` branch. For each entry in `parsed["Inputs"]`, `get_or_create` a `VbtcV2TokenTransfer` with `token` looked up by `SCUID`, `transaction=tx`, and defaults `from_address = parsed["FromAddress"]`, `to_address = parsed["ToAddress"]`, `amount = Decimal(input["Amount"])`, `created_at = tx.date_crafted`. A missing token logs and `continue`s to the next input rather than returning, matching the V1 `TransferCoinMulti()` loop at `rbx/tasks.py:1075`. Consensus requires distinct contracts per transaction, so the `(token, transaction)` unique constraint (`uniq_vbtcv2transfer_token_tx`) holds.

Optional: an `is_multi` boolean on `VbtcV2TokenTransfer` with a migration and a serializer field at `api/btc/serializers.py:66`, mirroring V1's flag, so the transfers feed can label them.

### 5.2 Available balance on the token list (recommended)

`VbtcV2TokenSerializer` exposes gross per-address balances in `addresses`; open withdrawal requests are not netted. Add `available_balances`, the same map minus the sum of that address's ACTIVE `VbtcV2WithdrawalRequest` amounts (the `settlement_amount_for` pattern at `rbx/models.py:1246`). The wallet allocates from it when present, which removes the most likely verify-time rejection.

### 5.3 Tests

An indexer test that turns one multi transaction into N transfer rows and skips an unknown SCUID without aborting the others, plus `AddressesTests` coverage (`rbx/tests.py:114`) showing balances after a multi transfer for sender and recipients.

## 6. Consensus rules the transaction must satisfy

Verified against `TransactionValidatorService.cs:2427` onward and `Transaction.cs:44`. `/raw/verify` runs all of these, so the wallet needs them to build a valid payload and to read error messages.

| Rule | Detail |
| --- | --- |
| Data keys | Exactly `Function`, `FromAddress`, `ToAddress`, `TotalAmount`, `Inputs`. A top-level `ContractUID` is rejected after activation. |
| Function | `TransferVBTCMultiV2()`. The older `TransferVBTCMulti()` name is rejected as deprecated. |
| Addresses | Data `FromAddress`/`ToAddress` must equal the transaction's. Use the base58 address in both; never a `.vfx` name. |
| Sender | Not a reserve (xRBX) address. |
| Recipient | Not shielded. Reserve recipients are allowed by consensus; the GUI blocks them by policy. Self-send is allowed. |
| Inputs | 1 to 25, distinct SCUIDs, each `Amount > 0` with at most 8 decimals, sum equal to `TotalAmount`. |
| Balances | Per input, the sender's transparent ledger balance on that contract must cover the amount. Shielded balances never count. |
| Transaction | Type 26, `Amount` 0.0, no `UnlockTime`, fee at least 0.000003 VFX and sized to the JSON, sequential nonce. |
| Hash | Computed by the node via `/raw/hash`. The preimage renders `TransactionType` as the enum name `VBTC_V2_TRANSFER`, which only matters to a client that hashes itself; the wallet never does. |
| Signature | One ECDSA secp256k1 signature over the UTF-8 hash string, verified against the transaction's `FromAddress`. |
| Activation | Multi shape accepted only when block height reaches `Globals.V2TransferMultiHeight`: 1 on testnet, unset on mainnet. |

## 7. Sequence

1. Wallet allocates inputs from its Spyglass balances; if one input covers it, the existing single-transfer flow runs instead.
2. Wallet builds the Data payload and calls `_verifyConfirmAndSendTx` with type 26.
3. Raw path: `/raw/timestamp`, `/raw/nonce`, fee, `/raw/hash`; the node returns the hash.
4. Wallet signs the hash locally and validates the signature.
5. `/raw/verify` runs consensus checks; on failure the wallet shows the node's reason and stops.
6. `/raw/send` broadcasts; the wallet records a pending type-26 transaction and shows the allocations.
7. The transaction is mined; Spyglass's indexer writes one `VbtcV2TokenTransfer` row per input; balances update for sender and recipient.

## 8. Alternative considered: CLI raw endpoint with server-side allocation

Revision 1 proposed `GetRawTransferVBTCMultiData` on the CLI, taking candidate contracts from Spyglass, allocating from the state trei and mempool, storing the unsigned transaction and returning the hash, with two Spyglass proxies in front. Dropped because the transaction needs nothing from the node that the raw path does not already provide: the `GetRaw*Data` pattern exists for operations that compile Trillium or run MPC, not for plain JSON payloads. The only thing server-side allocation buys is visibility into the sender's own mempool outflows, which matters for back-to-back sends and is caught at verify time anyway. Revisit only if that rejection turns out to be common.

## 9. Open questions

1. When does mainnet get `V2TransferMultiHeight`? Both wallets stay testnet-gated until then.
2. Ship `available_balances` (5.2) with the indexer change, or later? It is cheap and removes the most likely verify-time rejection.
3. For the one-input case, is routing through the existing `transferVbtcV2` flow acceptable, or should the wallet always use the raw path for consistency? The former is simpler and works pre-activation.
