# Spyglass: vBTC V2 Multi-Contract Transfer Support

Date: 2026-09-08. Repo: `vfx-explorer`, branch `testnet` (written against `af7f311`). Core CLI reference: `testnet` branch, commit `fd1a0f35` ("vbtc multi transfer").

## Background

The Core CLI now supports a vBTC V2 transfer that debits the sender on several token contracts in one transaction. It is live on testnet from height 1 and not yet activated on mainnet. Desktop wallets can already broadcast these on testnet, and the web wallet will build them through the existing `/raw/*` endpoints. No new API endpoints are needed from Spyglass.

The problem: Spyglass's V2 indexer only recognizes the single-contract shape, so after any multi transfer the vBTC ledger is wrong for the sender and every recipient contract. That is the one required change. Two smaller additions are listed after it.

## The on-chain shape

TransactionType 26 (`VBTC_V2_TRANSFER`), `Amount` 0, no `UnlockTime`. The `Data` field is JSON with exactly these five keys:

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

Consensus guarantees, so the indexer can rely on them: 1 to 25 inputs, distinct `SCUID`s, every `Amount` positive with at most 8 decimals, the amounts sum to `TotalAmount`, and `FromAddress`/`ToAddress` in `Data` equal the transaction's own `FromAddress`/`ToAddress`. There is never a top-level `ContractUID` in this shape. The node applies it as one ledger debit/credit pair per input, all from the transaction's sender to the transaction's recipient. Contract ownership never changes.

When a sender's total fits in one contract the CLI emits the existing single shape (`TransferVBTCV2()` with `ContractUID`) instead, which Spyglass already indexes. Nothing changes there.

## 1. Indexer: handle `TransferVBTCMultiV2()` (required)

Where: `process_transaction` in `rbx/tasks.py`, the `VBTC_V2_TRANSFER` branch at line 1106. It currently checks `func == "TransferVBTCV2()"` and writes one `VbtcV2TokenTransfer`. Add a sibling branch:

```python
elif func == "TransferVBTCMultiV2()":
    from_address = parsed["FromAddress"]
    to_address = parsed["ToAddress"]

    for entry in parsed["Inputs"]:
        sc_identifier = entry["SCUID"]
        amount = Decimal(str(entry["Amount"]))

        try:
            token = VbtcV2Token.objects.get(sc_identifier=sc_identifier)
        except VbtcV2Token.DoesNotExist:
            logging.error(f"VbtcV2Token with sc id of {sc_identifier} not found (multi transfer {tx.hash}).")
            continue

        VbtcV2TokenTransfer.objects.get_or_create(
            token=token,
            transaction=tx,
            defaults={
                "from_address": from_address,
                "to_address": to_address,
                "amount": amount,
                "created_at": tx.date_crafted,
            },
        )
```

Notes:

- Use `continue`, not `return`, when a token is missing. The existing single branch returns, which would drop the remaining inputs. The V1 `TransferCoinMulti()` loop at `rbx/tasks.py:1075` already does it this way.
- `get_or_create` keyed on `(token, transaction)` is safe because inputs are distinct contracts; the unique constraint `uniq_vbtcv2transfer_token_tx` (`rbx/models.py:1301`) holds and a re-run is idempotent.
- The existing `parsed` handling (string-encoded Data, list-wrapped Data) applies unchanged.
- `process_transaction` is also called from the mint-recovery sweep at `rbx/tasks.py:412`. No extra wiring needed.
- Grep the rest of the type-26 handling (serializers, transaction detail views) for anything that reads `ContractUID` or `Amount` from `Data` unconditionally; the multi shape has neither at the top level.

Result: `VbtcV2Token.ledger_entries` and the `addresses` map pick the rows up with no further change, since they only walk `VbtcV2TokenTransfer`.

## 2. `is_multi` flag on transfers (optional)

If the transfers feed at `/api/btc/vbtc-v2/transfers/{sc_identifier}/` should label these, add `is_multi = BooleanField(default=False)` to `VbtcV2TokenTransfer` with a migration, set it in the new branch, and expose it in the serializer at `api/btc/serializers.py:66`. This mirrors the V1 `is_multi` field on `VbtcTokenAmountTransfer` (`rbx/models.py:1144`, migration `0059`).

## 3. `available_balances` on the token list (recommended)

`VbtcV2TokenSerializer` (`api/btc/serializers.py:76`) exposes gross per-address balances in `addresses`. Open withdrawal requests are not netted; only COMPLETED ones debit the ledger. The web wallet will pick the input contracts for a multi transfer from these numbers, and consensus rejects any input that exceeds the sender's real balance, so a balance that includes an in-flight withdrawal produces a failed send.

Add `available_balances`: the same map as `addresses`, minus, per address, the sum of that address's `VbtcV2WithdrawalRequest` amounts in `ACTIVE_STATUSES` (`rbx/models.py:1332`). The `settlement_amount_for` helper at `rbx/models.py:1246` shows the existing pattern for subtracting open requests. Floor at zero. Keep `addresses` as is.

## 4. Tests

Follow the existing style (`APIRequestFactory` with `force_authenticate` for API tests; `AddressesTests` at `rbx/tests.py:114` for ledger behavior).

- One multi transaction with three inputs creates three `VbtcV2TokenTransfer` rows with the right token, addresses and amounts.
- An input whose `SCUID` is unknown is skipped and the other inputs are still written.
- Processing the same transaction twice creates no duplicate rows.
- After a multi transfer, `addresses` shows the sender reduced on each input contract and the recipient credited on each.
- `available_balances` subtracts ACTIVE withdrawal requests and ignores COMPLETED and CANCELLED ones.

## Acceptance

On testnet, after a wallet broadcasts a multi transfer and it is mined: `GET /api/btc/vbtc-v2/{sender}/` and `GET /api/btc/vbtc-v2/{recipient}/` reflect the per-contract debits and credits, the transfers feed for each input contract shows the row, and single-contract transfers continue to index exactly as before.
