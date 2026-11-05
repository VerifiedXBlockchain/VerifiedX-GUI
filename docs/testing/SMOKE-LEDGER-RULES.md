# Ledger rules batch pass (Core #72)

Core PR #72 turns on 23 ledger and consensus rules that shipped inactive in 9.0, all at one height, `LedgerRulesBatchHeight`: **testnet block 7,400**, mainnet block 7,575,250 (about 25 hours after 2026-10-24 04:00 UTC). This pass proves on testnet, before mainnet reaches its height, that (1) everyday wallet actions still work once the rules are live, (2) the flows the rules touch build what Core now requires, and (3) the network keeps producing under the new VRF seed. Everything in `SMOKE.md` applies unless this file says otherwise: agent-owned accounts, Tyler funds, the deployed web wallet and the real desktop folder, one tracker issue per defect on the `E2E Testing` board, the blocking protocol, the results files.

Run id `20261024a`. Results in `docs/testing/runs/20261024a-web.md`, `-macos.md` and `-api.md`.

## The network and builds (read first)

- **Core:** `testnet` at `359bd067` (#72 merged as `daec4c0a`), version **9.0.1**. Every testnet validator and caster must run it before 7,400. A node on 9.0.0 sticks at 7,399 (it rejects the new VRF proofs); enough casters on 9.0.0 stall the chain at 7,400.
- **GUI:** `testnet` at `b7092306` or later (PR #58: BTC name signing active from 7,400 on testnet, web `.vfx` names lowercased). Desktop: `make release_macos_testnet` (bundles Core `origin/testnet`). Web: `https://wallet-testnet.verifiedx.io` redeployed from GUI `testnet` `a64a6b96` (b7092306 plus cache-bust `main.dart.js?version=9.0.1`) at 00:38 ET on 2026-10-24. Check before S1 that the page loads `main.dart.js?version=9.0.1` (a BTC domain's Accept Transfer button shows once the chain is past 7,399; on the old build it never does).
- **Funding:** both lanes' account A were topped up by 50 VFX at 00:38 ET (web A ~78, macOS A ~86). More VFX comes from the testnet faucet API, no need to ask: `POST https://data-testnet.verifiedx.io/api/faucet/request/` with header `X-Faucet-Token: $FAUCET_AUTOMATION_TOKEN` and JSON `{"address": "x…", "amount": "10"}` (token in `~/.config/vfx-release-tests/faucet.env`, mode 600: read it into the shell with `set -a; . ~/.config/vfx-release-tests/faucet.env; set +a` and never write it into results, issues or chat). Record each request's hash in the results file.
- **Bitcoin:** the VerifiedX signet, as in `SMOKE-BTC.md` "The network" and "Timing" (mining on demand through the farm API; the token never leaves `~/.config/vfx-release-tests/signet.env`).
- **What changed for a wallet user from 7,400:**
  - BTC name create: the BTC address's own key signs `<unix seconds>:<VFX owner>:<name>.btc` (at most 30 minutes old). Transfer: the **receiving** BTC key signs the same form with the receiver as owner (at most 24 hours old), carried as the acceptance code.
  - `.vfx` names: lowercase letters, digits and `-`, 1 to 65, no suffix.
  - Token mint: refused on a paused token, with more decimals than the token's, or past the supply. Two mints sent together land in separate blocks.
  - Token ownership change: the new owner in the data must be the transaction's recipient. Shop create: owned by its sender.
  - NFT Update/Transfer/Burn/Evolve/Devolve carry their data in array form; Evolve/Devolve only on an Evolving contract; one move (Transfer or Burn) per contract per block.
  - Vote topics: `TopicAdd()` only; the chain sets owner, tally, date and validator count; one open topic per owner.
  - Fees below 1 VFX; a fractional amount must hash with its value; recipients carry this network's byte; a shield spends nothing.
  - Node-side only: VRF seed from the epoch anchor, replay guard by time, 3,000 transactions per block, reserve recovery, signer age.

## Gate

Nothing in S1 or later starts until **both**:
1. Spyglass testnet (`https://data-testnet.verifiedx.io/api/blocks/?limit=1`) shows a height **≥ 7,401** and blocks still arriving (two readings a minute apart).
2. The lane's node reports 9.0.1 (`GET http://localhost:17292/api/V1/GetCLIVersion` → `9.0.1.x-beta`; desktop lane only) and the **fee probe** in L0-3 is refused.

If the chain stops at 7,399 or 7,400 for more than five minutes, that is a blocking failure: stop and tell Tyler (likely a validator or caster still on 9.0.0).

## Stages

| Stage | What | Web | macOS | API (agent, desktop node) |
|---|---|---|---|---|
| L0 pre-flight | Builds, versions, gate | build check, landing version | GetCLIVersion, boot log | L0-1 to L0-4 |
| L1 everyday | Must still work after 7,400 | TC-SEND-003, 023; TC-TOKEN-016; TC-SC-043, 047 | TC-SEND-002, 023; TC-TOKEN-016; TC-SC-043, 047 | – |
| L2 names | The flows the name rules touch | LR-ADNR-1, 2; LR-BTCN-1 to 4 | LR-ADNR-1; LR-BTCN-1 to 4 | LR-API-ADNR |
| L3 tokens, NFTs, topics | Mint, owner change, evolve, topics | TC-TOKEN-014, 015, 021, 031 | TC-TOKEN-014, 015, 021, 031, 024; TC-SC-040, 041; LR-TOPIC-1 | LR-API-TOKEN, LR-API-NFT |
| L4 privacy | Shield, unshield, private transfer | – (no privacy feature on web) | TC-PRV-008, 010, 012 | – |
| L5 raw refusals | Rules a wallet can't break on purpose | – | – | LR-API-1 to 7 |
| L6 network | VRF producers, block cap, rejections | – | – | LR-NET-1 to 4 |

Cross-wallet: LR-BTCN-3 and 4 need both lanes (one sends, the other accepts). Run them together after each lane's LR-BTCN-1.

## L0 pre-flight (API lane)

All calls to the desktop node, `http://localhost:17292`, with the api token from the node config. To see why Core refuses a transaction, use `txapi/TXV1/VerifyRawTransaction` (it returns `…Error: <reason>`); `SendRawTransaction` only says "Transaction was not verified." Raw transactions: `GetTimestamp`, `GetAddressNonce`, `GetRawTxFee`, `GetTxHash`, then `api/V1/CreateSignature/{msg}/{addr}`.

- **L0-1** `GET api/V1/GetCLIVersion` → `9.0.1.x-beta`.
- **L0-2** Tip and producers: `valapi/Validator/GetActiveValidators` (port 17294) and the last 20 blocks' `Validator`. Record the set at block 7,300 (the VRF epoch anchor for 7,400 to 16,039).
- **L0-3 fee probe (the rule switch):** build a plain VFX TX from account A to B with `Fee: 1.0` and call `VerifyRawTransaction` once the tip is ≥ 7,399. Expect "A transaction's fee must be below 1 VFX (ambiguous hash)." A node without #72 accepts it. Do not send it.
- **L0-4** Note the time and height in the results file; every later case records the block it landed in, and must be ≥ 7,400.

## L2 names

### LR-ADNR-1 · Create a `.vfx` name with capitals (both)
Web: Domains → create, type `LrMixed<N>` (capitals and digits; `-` is filtered by the input). Expect the confirmation to show and the name to register as `lrmixed<N>.vfx` (lowercase) and confirm in a block ≥ 7,400. macOS: same; Core's API lowercases it. Fail: refusal "A name is lowercase letters, digits and '-'…", or a name stored with capitals.

### LR-ADNR-2 · Web: `.vfx` name of exactly 65 characters (web)
Type 65 lowercase letters and digits; expect it to register. 66 is refused before sending (TC-ADNR-004).

### LR-BTCN-1 · Create a BTC domain after 7,400 (both)
TC-ADNR-020 on each lane's own `TEST_BTC_ADDRESS`. Expect it to confirm. On web, the signed message the wallet builds must be `<ts>:<A address>:<name>.btc` (the automation log or the request payload shows it). Fail: "Improper Message Format. Message must be <timestamp>:<VFX address>:<name>." (old build) or "The BTC signature is not from the key of the BTC address."

### LR-BTCN-2 · BTC domain create with a stale signature is refused (web, optional)
Only if the automation layer can hold the signed request: wait 31 minutes between signing and sending. Expect a refusal naming the signature's age. Skip otherwise and say so.

### LR-BTCN-3 · Transfer a BTC domain between wallets with the acceptance code (cross)
Receiver lane: on its BTC address card, `Accept Transfer` (macOS card; web BTC domain panel) for the sender's VFX address and the domain name; copy the acceptance code. Sender lane: TC-ADNR-022 to the receiver's BTC address, pasting the code. Expect the transfer to confirm and the domain to show on the receiver. Then repeat with the lanes swapped. Fail: "The receiving BTC address must sign the transfer.", or the Accept button / code field missing past 7,399.

### LR-BTCN-4 · Transfer without the receiver's code is refused (cross)
Sender: TC-ADNR-022 to the other lane's BTC address with no code, or with a code made for a different name. Expect a refusal before or at send ("…names a different VFX address/name." or the wallet asking for the code). Nothing mined.

### LR-API-ADNR · Raw name grammar (API)
Raw `AdnrCreate` with `Bad_Name`, then with `x.vfx`. `VerifyRawTransaction` → "A name is lowercase letters, digits and '-', 1 to 65 characters, with no suffix." Then `abc-<N>` → verifies; send it and confirm it mines.

## L3 tokens, NFTs, topics

- **Mint** (TC-TOKEN-014, 015): a normal mint confirms. Mint with more decimals than the token has: the wallet refuses before sending, and if it does not, Core refuses "A mint has at most N decimal places, the token's." File it if the wallet lets it through.
- **Paused** (TC-TOKEN-021): while paused, a mint is refused ("Contract is paused. NO TXs may go through.").
- **Ownership change** (TC-TOKEN-031): confirms; the new owner shows on both wallets.
- **Evolve and devolve** (TC-SC-040, 041, macOS; web where offered): confirm on an Evolving NFT.
- **Topic** (TC-TOKEN-024, and LR-TOPIC-1 on macOS: a validator vote topic from the Validator/Voting screen if the lane's account is a validator; skip otherwise): the new topic shows 0 votes, the creator as owner. A second topic while one is open from the same owner is refused ("Only one active topic per address is allowed.").
- **LR-API-TOKEN** (API): two mints of one token sent back to back land in two different blocks.
- **LR-API-NFT** (API): `scapi/SCV1/Evolve/{id}/{to}` on a plain (non-evolving) NFT → "Only a contract with the Evolving feature can be evolved or devolved." Two `Transfer()` calls on one NFT sent back to back: they land in different blocks and the second fails on ownership.

## L5 raw refusals (API lane)

Each one: build, `VerifyRawTransaction`, record the exact text. Never send a transaction that verifies when the case expects a refusal; file it instead.

- **LR-API-1 fee:** as L0-3.
- **LR-API-2 fractional amount:** hash and sign with `Amount: 0`, then verify with `Amount: 0.5` → "This transactions hash is not equal to the original hash."
- **LR-API-3 contract payload:** raw `NFT_TX` `Transfer()` with Data as a single object (not an array) → "Transfer() carries its call as an array whose first element is the call."
- **LR-API-4 data owner:** `TokenContractOwnerChange()` whose new owner in Data differs from the transaction's ToAddress → "A token contract's new owner in the data is the transaction's recipient." Shop create whose owner is not the sender → "A new shop is owned by the address that sends its creation."
- **LR-API-5 vBTC envelope:** `TransferVBTCV2()` sent as a contract call with a key repeated in Data → "This vBTC transaction's Data names a key twice."; with a To that differs from ToAddress → "To address in data must match transaction ToAddress." Use a vault the lane owns from the BTC pass.
- **LR-API-6 recipient network:** a TX to a mainnet `R…` address → refused ("The recipient is an address of another network…"). Regression only: admission refused it before too.
- **LR-API-7 replay:** resubmit a mined transaction's exact raw form → refused (already in the guard).

## L6 network (API lane)

- **LR-NET-1 VRF producers:** every block from 7,400 on is produced by a validator that was active at block 7,300 with `RegistrationBlockHeight` below 7,300. A validator registered after 7,300 produces nothing until 16,040; that is expected, not a defect. `valapi/Validator/GetRoundAudit/7400` and `GetConsensusState` are readable.
- **LR-NET-2 liveness:** blocks keep coming with committee certificates for 30 minutes after 7,400; average block time stays near 12 s.
- **LR-NET-3 block cap:** no block carries more than 3,000 transactions; nothing to provoke.
- **LR-NET-4 rejections:** `valapi/Validator/GetRejectionLog` shows no `ValidateBlock()-7-4. Proof Invalid.` and no `transactionCap` rejections after 7,400. Any such line means a node on the old build: record which and tell Tyler.

## Filing and results

As `SMOKE-BTC.md` "Filing and results". Area `07 domains` for LR-ADNR/LR-BTCN, `08 tokens` and `09 nfts` for L3, `11 network` for L0/L5/L6. Each case records the block height it landed in (must be ≥ 7,400). Expected-refusal cases quote Core's text exactly. Results committed on `testnet` after each stage, only the lane's own file, no push.

## Starting the lanes

Tyler starts them once the gate holds. Each lane is its own session in `~/prj/vfx/vfx-gui` (branch `testnet`).

**Web lane**

```
You are running the web lane of ledger rules pass 20261024a (Core #72, rules live on testnet from block 7,400). Read docs/testing/SMOKE-LEDGER-RULES.md first, then SMOKE.md, SMOKE-BTC.md ("The network", "Timing") and the area files as you reach their cases. Target: https://wallet-testnet.verifiedx.io/?automation=1 in the built-in browser pane; confirm it is the build from GUI testnet b7092306 or later before S1. Accounts: reuse ~/.config/vfx-release-tests/agent/accounts.web.env (secrets never leave the file). Check the gate (Spyglass testnet height ≥ 7,401 and moving). Stages L1 → L2 → L3 → L4; LR-BTCN-3 and 4 together with the macOS lane. Results in docs/testing/runs/20261024a-web.md, committed on testnet after each stage (only that file, no push). One issue per defect on the E2E Testing board (label source:e2e-smoke). A blocking failure pauses the lane and asks me. Begin by telling me the build, the chain height and the gate.
```

**macOS lane**

```
You are running the macOS lane of ledger rules pass 20261024a (Core #72, rules live on testnet from block 7,400). Read docs/testing/SMOKE-LEDGER-RULES.md first, then SMOKE.md, SMOKE-BTC.md ("The network", "Timing") and the area files as you reach their cases. Target: a desktop build from GUI testnet b7092306 or later with the Core 9.0.1 CLI (make release_macos_testnet, or the run target the BTC pass used) on the real ~/rbxtest; GET http://localhost:17292/api/V1/GetCLIVersion must say 9.0.1. Accounts: reuse ~/.config/vfx-release-tests/agent/accounts.macos.env. Check the gate. Stages L1 → L2 → L3 → L4; LR-BTCN-3 and 4 together with the web lane. Results in docs/testing/runs/20261024a-macos.md, committed on testnet after each stage (only that file, no push). One issue per defect on the E2E Testing board. A blocking failure pauses the lane and asks me. Begin by telling me the build, the CLI version, the chain height and the gate.
```

**API lane**

```
You are running the API lane of ledger rules pass 20261024a (Core #72, rules live on testnet from block 7,400). Read docs/testing/SMOKE-LEDGER-RULES.md. You talk only to the desktop node's API on http://localhost:17292 (valapi on 17294) with the api token from its config; never print the token. Stages L0 (with the fee probe as the gate), then L5, LR-API-ADNR, LR-API-TOKEN, LR-API-NFT, then L6 over the first 30 minutes after 7,400. Build raw transactions with GetTimestamp, GetAddressNonce, GetRawTxFee, GetTxHash and api/V1/CreateSignature, and use VerifyRawTransaction to read refusals; never send a transaction that verifies when a refusal is expected. Accounts: ~/.config/vfx-release-tests/agent/accounts.macos.env (A and B). Results in docs/testing/runs/20261024a-api.md, committed on testnet after each stage (only that file, no push). If the chain stops at 7,399 or 7,400 for more than five minutes, stop and tell me. Begin with L0 and tell me the version, the tip and the producer set at 7,300.
```
