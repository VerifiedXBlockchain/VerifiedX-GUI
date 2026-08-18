# vBTC v2: Name/Description missing for non-minted contracts

## Summary

When a node holds vBTC balance on a contract it didn't mint (received via transfer), the vBTC endpoints return blank or missing `Name`/`Description`. The name IS on chain — the state trei's `ContractData` contains it, and `GetSmartContractData` already decompiles it without needing the local `SmartContractMain` record. The vBTC endpoints just don't use that path: they enrich from `SmartContractMain`, which only exists for the node's own mints (`Name = scMain?.Name ?? ""` in `VBTCController.GetContractList`).

## Current behavior per endpoint

| Endpoint | Name/Description |
|---|---|
| `GET /vbtcapi/VBTC/GetContractList` (and `/{address}`) | Present but `""` when the node didn't mint the contract |
| `GET /vbtcapi/VBTC/GetContractDetails/{scUID}` | Missing entirely (serializes raw `VBTCContractV2`, which has no name fields) |
| `GET /vbtcapi/VBTC/GetAllVBTCBalances/{address}` | Missing entirely |

## Endpoints we'd like enriched

- `http://localhost:17292/vbtcapi/VBTC/GetContractList`
- `http://localhost:17292/vbtcapi/VBTC/GetContractList/{address}`
- `http://localhost:17292/vbtcapi/VBTC/GetContractDetails/{scUID}`
- `http://localhost:17292/vbtcapi/VBTC/GetAllVBTCBalances/{address}`

## Suggested fix

When `SmartContractMain` is null, fall back to decompiling the state trei's `ContractData` — the same pattern `GetSmartContractData` already uses (`SmartContractMain.GenerateSmartContractInMemory(scStateTrei.ContractData)`), which has no owner gate and works for any contract the node has state for.

Reference endpoint that already returns the correct data: `http://localhost:17292/scapi/SCV1/GetSmartContractData/{scUID}`

## Repro (testnet)

Contract `50dac1cfd6594050846cdad0ab1e6698:1786500311` ("deadbeef", minted by web wallet / `xMjrfrzkrNC2g3KJidbwF21gB7R3m46B9w`) from a node that holds balance but didn't mint it: `GetContractList` returns `"Name":"","Description":""` while `GetSmartContractData` returns `"Name":"deadbeef"`.

## Priority

Low / not a blocker. The GUI already works around it by calling `GetSmartContractData` for empty-name contracts — fixing CLI-side just saves a round-trip per unknown contract and makes the vBTC API self-consistent for other consumers.
