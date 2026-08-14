# Non-Owned vBTC V2 Contracts
<!-- Added: 2026-08-14 -->

## When to Use

Any desktop feature that reads a vBTC V2 contract the local wallet holds a balance on but did **not** mint — i.e. vBTC received via transfer. This is a whole class of bug, not a single defect: the CLI's local LiteDB records are keyed to what the node minted, so anything derived from them is empty or absent for received tokens, while chain state has the data all along.

## Structure

Three CLI record types, only the third of which exists for a received contract:

| Source | Exists for received contract? | Consequence |
|---|---|---|
| `VBTCContractV2` (local) | Yes — balance/deposit data is fine | — |
| `SmartContractMain` (local mint record) | **No** | `Name`/`Description` come back `""` |
| State trei `ContractData` (chain) | Yes | Decompiles to the real metadata |

The fix in every case is to stop trusting the local mint record and go to chain state:

```dart
// Discovery: GetContractList/{address} is owner-scoped — fetch unfiltered
// and filter client-side on (owner || spendable balance > 0).
final tokens = await VbtcV2Service().getContractList(address: address);

// Metadata: local Name is "" for non-minted contracts; decompile from
// the state trei instead.
final nft = await NftService().getNftData(scUid);  // GET /scapi/SCV1/GetSmartContractData/{scUID}
```

## Example

- `lib/features/btc/services/vbtc_v2_service.dart` — `getContractList()` fetches the unfiltered list, filters to `rbxAddress == address || myBalance > 0`, and backfills empty names via `NftService().getNftData()`.
- `lib/features/btc/screens/tokenized_btc_detail_screen.dart` — guards `nftDetailProvider` with `token.version != 2` so a missing NFT record doesn't hang the screen.

## Gotchas

- **`GetContractList/{address}` is owner-scoped** (`VBTCContractV2.GetContractsByOwner`). Passing an address silently hides received tokens. `GetAllVBTCBalances/{address}` uses the wider semantics (owner **or** ledger balance) — useful for cross-checking, but it carries no name fields at all.
- **Never block a screen on `nftDetailProvider` for a V2 token.** It calls `GetSingleSmartContract`, which starts from `SmartContractMain` and returns `"null"` forever for a received contract. The screen sits on a loader with no error. Fall back to the contract's `OwnerAddress` for `scOwner`.
- **`GetSmartContractData/{scUID}` has no owner gate** — it decompiles chain state and works for any contract the node has state for. `AddNFTDataFromNetwork` also decompiles but rejects non-owners, so it is not a substitute.
- Balances are per-holder: `GetVBTCBalance/{address}/{scUID}` → `AvailableBalance`. The contract-level `Balance` is the deposit address total and means nothing for a non-owner.
