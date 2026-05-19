# vBTC ↔ Base Bridge: Request to Add Burn Endpoints

## What the CLI already exposes (great!)

- `POST /api/vbtc/bridge/toBase` — initiate lock
- `GET /api/vbtc/bridge/preflight/{owner}/{scUID}` — balances, derived Base addr, ETH for gas
- `GET /api/vbtc/bridge/status/{lockId}` — full state machine
- `GET /api/vbtc/bridge/base-balance/{evmAddr}` — vBTC.b balance
- Mint orchestration server-side via `UserBridgeMintService` (Nethereum submits `mintWithProof`)
- Caster polling, FROST signing for BTC exit, consensus — all handled

## The gap

No CLI endpoint to call the burn step on Base for the two exit flows:

- `burnForVfxExit(amount, vfxDestinationAddress)` — Base → vBTC on VFX
- `burnForBTCExit(amount, btcDestination)` — Base → native BTC

Without these, the Flutter GUI would need to embed a web3/EVM signing stack — complexity I'd love to avoid given the CLI already has the private key, derives the Base address, uses Nethereum, and knows the contract ABI.

## Proposed endpoints

```
POST /api/vbtc/bridge/burnForVfxExit
  body:    { ownerAddress, amount, vfxDestinationAddress }
  returns: { success, baseTxHash, message }

POST /api/vbtc/bridge/burnForBTCExit
  body:    { ownerAddress, amount, btcDestination }
  returns: { success, baseTxHash, message }
```

Each would:

1. Derive the user's Base address from their VFX private key
2. Check vBTC.b balance and ETH gas balance, return useful errors if short
3. Submit the burn tx via Nethereum (same pattern as `mintWithProof`)
4. Return the Base tx hash so the GUI can poll for confirmation
5. Existing `BaseBridgeExitWatchService` picks it up automatically from there

## Questions

- Feasible from your side?
- Any architectural reason these were left client-side that I'm missing?
- Rough timeline if you're up for it?

If it's not on the table CLI-side, I'll scope an embedded EVM signer for the GUI — but the clean path is keeping all crypto out of Flutter.
