# BTC and vBTC pass

A BTC and vBTC pass runs only the Bitcoin-related cases of the release suite (`README.md`), on both wallets, against the VerifiedX signet and a watched-vault testnet. It exists because the 20261021a smoke pass could not run its Bitcoin stage: Bitcoin testnet4 stalled, and its minimum-difficulty blocks never credited a watched deposit (VerifiedX-Issues#333). Everything in `SMOKE.md` applies unless this file says otherwise: agent-owned accounts that fund themselves, the deployed web wallet and the real desktop folder as targets, one tracker issue per defect on the `E2E Testing` board, the blocking protocol, the results files.

The first pass of this kind is `20261023a`: GUI `testnet` at `c58eedac` (9.0.0, deployed at `https://wallet-testnet.verifiedx.io`) on the reset VFX testnet (genesis 2026-10-22; Core `testnet` `2cd65002`, the signet build) and the VerifiedX signet.

## The network (read first)

- **Bitcoin is the VerifiedX signet** (BIP 325), run by the node farm, which holds the only signing key. Blocks come every 10 minutes at mainnet rules (no minimum-difficulty blocks, no reorgs); every header counts toward burial. Fees quote at 1 sat/vB; the wallets keep their testnet fee floors. Addresses and keys are testnet-format (`tb1…`), so every stored key still works.
- **Explorer and API:** `https://signet.verifiedx.io/tx/<txid>`, `/address/<addr>`, `/block/<hash>`; Esplora API `https://signet.verifiedx.io/api` (`/tx/<txid>/status`, `/address/<addr>`, `/blocks/tip/height`, `/v1/fees/recommended`). The wallets, Spyglass and the Core CLI all read this chain and nothing else. Where an area file says "mempool.space" for a testnet check, read the signet explorer.
- **Confirmations:** a block every 10 minutes from the farm's miner, or on demand through the farm's mining API (see "Timing"). A watched vault credits a deposit at depth 3; a watched withdrawal's pin and payout need the same.
- **No in-app faucet.** `Get BTC` → `Testnet Faucet` shows a dialog saying to ask the VerifiedX team. The lanes fund themselves through the Spyglass faucet's automation token ("Accounts and funding").
- **The VFX testnet was reset to genesis on 2026-10-22.** Its 9.0 rule set activates at block 400: Bitcoin attestation observe at 300, record at 400, active at 401; validator bonds at 399. Every vault created from block 401 on is a watched vault; there are no legacy vaults on this chain, so the legacy FROST withdrawal cases (TC-BTC-042, 043, 048 to 052) are `skipped` for good and the watched cases (TC-BTC-053 to 059) are the withdrawal suite. **Nothing vBTC starts before the chain is past block 401.** Spyglass testnet follows the reset chain (it showed block 231 at 04:13Z on 2026-10-23).
- **Builds.** Web: the deployed `https://wallet-testnet.verifiedx.io/?automation=1` is 9.0.0 with the signet endpoints (GUI PR #53) and this week's BTC fixes (PRs #51 and #52). Desktop: `make run_macos_driver_real` on the real `~/rbxtest`, recreated fresh on 2026-10-22 for the reset chain, with the CLI in `VFXWallet.app` rebuilt the same night; the boot log must show a 9.0.0 CLI and a chain height in the hundreds, not the old 1.18 million. For the Replace-By-Fee and Rebroadcast cases the desktop lane switches to `make run_macos_driver_real_profile`, a profile build in which BTC pending badges and those actions behave as in a release (the debug build shows every BTC transaction as confirmed).

## Accounts and funding

- **Keys are reused.** The lanes' env files (`~/.config/vfx-release-tests/agent/accounts.<lane>.env`) still hold A, B, the BTC key and the password. The chain is new, so every balance is zero and every object has to be made again. Web: the wallet's storage still holds the accounts; verify with TC-AUTH-039 that the BTC key matches the env file. macOS: the folder is fresh, so import A and B (TC-AUTH-046) and the BTC key (TC-AUTH-049), then create one fresh account C (TC-AUTH-045) that owns no vault, for the wizard and the received-contract cases; on web, add C with TC-AUTH-031. Record C in the env file as `TEST_VFX_C_PRIVKEY` / `TEST_VFX_C_ADDRESS`.
- **Funding** after S1: the lane pays itself through the faucet token, as in `SMOKE.md` "Funding" (one `POST /api/faucet/request/` per address, `btc_address` / `btc_amount` on account A's call). Per lane:

| Asset | To | Amount | Why |
|---|---|---|---|
| signet BTC | the lane's `TEST_BTC_ADDRESS` | 0.002 | two vault deposits of 0.0001, the BTC send cases, RBF, cross-platform sends, fees |
| VFX | account A | 50 | vault creations, two BTC domains at 5 VFX each, transfers, withdrawal fees |
| VFX | account B | 10 | the second party's transfers and fees |
| VFX | account C | 5 | the wizard's vault and one transfer |

One Bitcoin faucet payment per lane; the lane mines one block for it once it shows on the signet explorer. Only when the token is missing, refused or past its daily cap (1,000 VFX, 0.1 BTC per 24 hours) does the lane write this table as one combined `## Funding request` block at the top of its results file and put it on Tyler's `/bench`, then carry on with S2.

- **Payout address.** Wherever a case pays a withdrawal to `TEST_BTC_TREASURY_ADDRESS`, use the lane's own `TEST_BTC_ADDRESS` instead: there is no treasury in this pass and the BTC cycles back to the lane. Nothing is returned at close-out; the lanes keep their signet BTC for the next pass.

## Timing

- Vault deposits and withdrawals wait for blocks. With mining on demand a wait is minutes, not half an hour, but still: create both vaults and fund them as soon as the chain is past 401 and the funding has confirmed, add every Bitcoin transaction to the `Pending BTC` table, mine what it needs, and run the next cases while the VFX node catches up.
- **Mining on demand (farm API, 2026-10-23).** The regular miner keeps its 10-minute cadence, and the lanes mine the blocks a step needs themselves: `POST https://fleet.verifiedx.io/api/signet/mine/` with `Authorization: Bearer $SIGNET_API_TOKEN` and a JSON body `{"blocks": N}` (1 to 10, default 1) answers 202 with a request id; `GET https://fleet.verifiedx.io/api/signet/mine/<id>/` with the same header until `status` is `done` (about 2 to 3 seconds a block; `start_height`, `end_height`, `block_hashes`) or `failed` (`error` says why). 401 is a wrong or missing token, 400 a bad block count, 503 the endpoint switched off; requests run one at a time, so a second call waits. The token is in `~/.config/vfx-release-tests/signet.env` as `SIGNET_API_TOKEN` (mode 600): read it into the shell (`set -a; . ~/.config/vfx-release-tests/signet.env; set +a`) and never write it into results, issues, commits or chat. Rules: broadcast first and wait until the transaction shows at `https://signet.verifiedx.io/tx/<txid>` (a block only takes what has reached the signer's mempool), then mine what the step needs in one call, not a trickle: 4 blocks for a watched-vault deposit or a withdrawal pin and payout (depth 3 counts after the transaction's own block, so 3 left the credit waiting on the regular miner in the 20261023a fix round), 1 for a plain BTC send; after `done`, check `https://signet.verifiedx.io/api/blocks/tip/height` and give the VFX node a minute to read the new headers before expecting the wallet to react. Never loop it: every extra block raises the signet's difficulty at the next adjustment (height 4,032); dozens of blocks per pass are fine, thousands are not.
- Do not replace-by-fee anything except in the RBF cases themselves, and never a transaction another case is waiting on.

## Stages

Both lanes, in this order; within a stage, `P0` first, then `P1`, then `P2` (this pass runs every Bitcoin case, not only Tier A).

| Stage | What | Web | macOS |
|---|---|---|---|
| S0 boot | Desktop boot on the fresh folder: CLI version, chain height, signet attestation status (`GET http://localhost:17292/vbtcapi/VBTC/GetBitcoinAttestationStatus` with the api token: `BitcoinTipHeight` should track `https://signet.verifiedx.io/api/blocks/tip/height`) | – | TC-AUTH-001, 002; 008 at the very end |
| S1 accounts | Reuse the keys, add account C, verify the BTC key, fund the lane through the faucet token | TC-AUTH-039, 031, 033 | TC-AUTH-046 ×2, 049, 045, 050 |
| S2 BTC | Everything Bitcoin that needs no vault: BTC accounts, cards, sends and fee presets, validation, history, UTXOs, Receive BTC, prefilled BTC send, BTC domains; the regressions from 20261021a (#327 web pays the picked rate, #328 web balance counts unconfirmed, #330 desktop balance follows a new deposit) | 19 cases | 20 cases |
| S3 vBTC setup | After block 401 and confirmed funding: two vaults per lane (TC-BTC-022 / 023 twice), the wizard on account C (TC-BTC-025, regression #331), funding (TC-BTC-026 / 027), validation and copy cases; deposits into the `Pending BTC` table. When the first deposit credits (depth 3), comment on VerifiedX-Issues#333 with the block heights and times: that is its verification | 8 cases | 7 cases |
| S4 vBTC use | Token list and detail, transfers, transfer validation, ownership transfer, bulk transfers and their guards, received contracts and forwarding (#329: web history marks the deposits as vBTC) | 11 cases | 11 cases |
| S5 withdrawals | Watched-vault withdrawals: web status step, raise fee, release, resume, cancel while Waiting, second-account guard; desktop TC-BTC-059 (the behaviour still unobserved); withdraw from a received contract; validation. Payouts go to the lane's own BTC address. Legacy cases recorded `skipped` | 8 cases | 3 cases |
| S6 pending states | Desktop on the profile build (`make run_macos_driver_real_profile`, after quitting the debug app): Replace By Fee with the high-fee confirmation, Rebroadcast, the Pending badge; a 10-minute block gives one window per send. Web: the deployed build is a release build, so its pending states ran in S2 | – | 2 cases |
| S7 cross-platform | BTC and vBTC between the lanes: sends, transfers, forwarding, bulk, withdraw a received contract on the other platform. Run by whichever lane finishes first with the other lane's app still open; reads both env files | 7 cases | 6 cases |
| Close-out | `Pending BTC` drained (every row confirmed on the signet explorer), results files finished and committed, the debug driver app restarted if the profile build is still up | | |

## Case lists

Generated from the area files on 2026-10-23: every case in `04-btc-vbtc.md` plus the Bitcoin cases of `02`, `03`, `07` and `13`, every priority, exclusions applied. A case listing both platforms appears in both lanes.

Excluded: TC-BTC-042, 043, 048, 049, 050, 051, 052 (legacy FROST path: no legacy vault exists on this chain); TC-BTC-005 (web always derives a BTC key, so `Generate Keypair` is unreachable; noted on 20261021a); TC-BTC-036 (web media check on ownership transfer, needs an NFT asset, out of this pass's scope); TC-MISC-026 (on-ramp iframe); everything not Bitcoin-related.

### Web lane: 56 cases
#### S1 accounts

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-AUTH-031 | P0 | no | Add a second account with its own password |
| TC-AUTH-033 | P0 | no | Switch between accounts |
| TC-AUTH-039 | P1 | no | Reveal the BTC keys |

#### S2 BTC

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-ADNR-020 | P0 | yes | Create a BTC domain |
| TC-ADNR-022 | P0 | yes | Transfer a BTC domain |
| TC-BTC-002 | P0 | no | Add a BTC account from a WIF key (web) |
| TC-BTC-011 | P0 | yes | Send BTC with the fee-rate picker (web) |
| TC-SEND-010 | P0 | yes | Send BTC from the web wallet |
| TC-ADNR-017 | P1 | no | BTC domain section and cost note |
| TC-ADNR-019 | P1 | no | Web: faucet prompt when VFX is too low for a BTC domain |
| TC-ADNR-021 | P1 | no | BTC domain shown on the Addresses panel and Receive |
| TC-ADNR-023 | P1 | yes | Delete a BTC domain |
| TC-BTC-003 | P1 | no | Import validation (both platforms) |
| TC-BTC-012 | P1 | no | Custom fee rate (both platforms) |
| TC-BTC-013 | P1 | no | BTC send validation (both platforms) |
| TC-BTC-017 | P1 | no | BTC transaction list (web) |
| TC-BTC-018 | P1 | no | History with an OP_RETURN output (web) |
| TC-DASH-003 | P1 | no | BTC balance card |
| TC-SEND-011 | P1 | no | BTC send validation |
| TC-SEND-025 | P1 | no | Receive BTC shows and copies the BTC address |
| TC-BTC-009 | P2 | no | BTC receive address (both platforms) |
| TC-SEND-013 | P2 | no | Prefilled BTC send from the URL |

#### S3 vBTC setup

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-BTC-023 | P0 | yes | Create a vBTC contract through the MPC ceremony (web) |
| TC-BTC-027 | P0 | yes | Fund a vBTC contract from the web BTC account (web) |
| TC-BTC-019 | P1 | no | vBTC Tokens screen entry points (both platforms) |
| TC-BTC-021 | P1 | no | Create validation (web) |
| TC-BTC-025 | P1 | yes | Tokenization wizard (both platforms) |
| TC-BTC-028 | P1 | no | Fund validation (web) |
| TC-BTC-029 | P1 | no | Copy the deposit address and manual send (both platforms) |
| TC-BTC-024 | P2 | no | Ceremony failure and retry (both platforms) |

#### S4 vBTC use

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-BTC-030 | P0 | no | Token list (both platforms) |
| TC-BTC-031 | P0 | no | Owned token detail (both platforms) |
| TC-BTC-033 | P0 | yes | Transfer vBTC to another VFX address (web) |
| TC-BTC-038 | P0 | yes | Bulk transfer across two contracts (web) |
| TC-BTC-045 | P0 | no | Received contract: list, detail and actions (both platforms) |
| TC-BTC-034 | P1 | no | Transfer validation (both platforms) |
| TC-BTC-035 | P1 | yes | Transfer contract ownership (both platforms) |
| TC-BTC-039 | P1 | yes | Bulk transfer that fits one contract (both platforms) |
| TC-BTC-040 | P1 | no | Bulk transfer validation (both platforms) |
| TC-BTC-041 | P1 | no | Bulk transfer guards (both platforms) |
| TC-BTC-046 | P1 | yes | Forward received vBTC (both platforms) |

#### S5 withdrawals

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-BTC-044 | P0 | yes | Withdraw from a received (non-owned) contract (both platforms) |
| TC-BTC-053 | P0 | yes | Withdraw from a watched vault: status step, no FROST (web) |
| TC-BTC-047 | P1 | no | Withdrawal validation (both platforms) |
| TC-BTC-054 | P1 | yes | Raise the fee of a pinned watched withdrawal (web) |
| TC-BTC-055 | P1 | yes | Release a pinned watched withdrawal (web) |
| TC-BTC-056 | P1 | no | Close and resume the watched-withdrawal dialog (web) |
| TC-BTC-057 | P1 | yes | Cancel a watched withdrawal while it is Waiting (web) |
| TC-BTC-058 | P2 | no | Watched withdrawal actions from a second account (web) |

#### S7 cross-platform

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-XP-006 | P0 | yes | Transfer vBTC from web to macOS |
| TC-XP-007 | P0 | yes | Transfer vBTC from macOS to web |
| TC-XP-008 | P0 | yes | Forward received vBTC back to its owner |
| TC-XP-004 | P1 | yes | Send BTC from web to macOS |
| TC-XP-005 | P1 | yes | Send BTC from macOS to web |
| TC-XP-009 | P1 | yes | Bulk vBTC transfer across platforms |
| TC-XP-010 | P1 | yes | Withdraw received vBTC to Bitcoin on the other platform |

### macOS lane: 56 cases
#### S0 boot

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-AUTH-001 | P0 | no | Cold boot shows the boot screen and starts the Core CLI |
| TC-AUTH-008 | P0 | no | Quitting the app stops the Core CLI |
| TC-AUTH-002 | P1 | no | Boot log lines in the Activity Log |

#### S1 accounts

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-AUTH-045 | P0 | no | Create a new VFX account |
| TC-AUTH-046 | P0 | no | Import a VFX private key |
| TC-AUTH-050 | P0 | no | Switch the selected account |
| TC-AUTH-049 | P1 | no | Import a BTC private key |

#### S2 BTC

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-ADNR-020 | P0 | yes | Create a BTC domain |
| TC-ADNR-022 | P0 | yes | Transfer a BTC domain |
| TC-BTC-001 | P0 | no | Import a BTC account from its private key (macOS) |
| TC-BTC-010 | P0 | yes | Send BTC with a fee preset (macOS) |
| TC-SEND-009 | P0 | yes | Send BTC with a fee-rate preset (macOS) |
| TC-ADNR-017 | P1 | no | BTC domain section and cost note |
| TC-ADNR-018 | P1 | no | macOS: BTC domain form validation |
| TC-ADNR-023 | P1 | yes | Delete a BTC domain |
| TC-BTC-003 | P1 | no | Import validation (both platforms) |
| TC-BTC-004 | P1 | no | Create a new BTC account (macOS) |
| TC-BTC-006 | P1 | no | BTC account list, selection and copy (macOS) |
| TC-BTC-007 | P1 | no | BTC connection status and balance card (macOS) |
| TC-BTC-008 | P1 | no | UTXO list (macOS) |
| TC-BTC-012 | P1 | no | Custom fee rate (both platforms) |
| TC-BTC-013 | P1 | no | BTC send validation (both platforms) |
| TC-BTC-016 | P1 | no | BTC transaction list and detail (macOS) |
| TC-DASH-014 | P1 | no | Desktop BTC card actions |
| TC-SEND-011 | P1 | no | BTC send validation |
| TC-SEND-025 | P1 | no | Receive BTC shows and copies the BTC address |
| TC-BTC-009 | P2 | no | BTC receive address (both platforms) |

#### S3 vBTC setup

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-BTC-022 | P0 | yes | Create a vBTC contract through the MPC ceremony (macOS) |
| TC-BTC-026 | P0 | yes | Fund a vBTC contract from a BTC account (macOS) |
| TC-BTC-019 | P1 | no | vBTC Tokens screen entry points (both platforms) |
| TC-BTC-020 | P1 | no | Create requires a funded VFX account (macOS) |
| TC-BTC-025 | P1 | yes | Tokenization wizard (both platforms) |
| TC-BTC-029 | P1 | no | Copy the deposit address and manual send (both platforms) |
| TC-BTC-024 | P2 | no | Ceremony failure and retry (both platforms) |

#### S4 vBTC use

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-BTC-030 | P0 | no | Token list (both platforms) |
| TC-BTC-031 | P0 | no | Owned token detail (both platforms) |
| TC-BTC-032 | P0 | yes | Transfer vBTC to another VFX address (macOS) |
| TC-BTC-037 | P0 | yes | Bulk transfer across two contracts (macOS) |
| TC-BTC-045 | P0 | no | Received contract: list, detail and actions (both platforms) |
| TC-BTC-034 | P1 | no | Transfer validation (both platforms) |
| TC-BTC-035 | P1 | yes | Transfer contract ownership (both platforms) |
| TC-BTC-039 | P1 | yes | Bulk transfer that fits one contract (both platforms) |
| TC-BTC-040 | P1 | no | Bulk transfer validation (both platforms) |
| TC-BTC-041 | P1 | no | Bulk transfer guards (both platforms) |
| TC-BTC-046 | P1 | yes | Forward received vBTC (both platforms) |

#### S5 withdrawals

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-BTC-044 | P0 | yes | Withdraw from a received (non-owned) contract (both platforms) |
| TC-BTC-059 | P0 | yes | Withdraw from a watched vault on desktop (macOS) |
| TC-BTC-047 | P1 | no | Withdrawal validation (both platforms) |

#### S6 pending states

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-BTC-014 | P1 | yes | Replace by fee, including the high-fee confirmation (macOS) |
| TC-BTC-015 | P2 | no | Rebroadcast a pending BTC transaction (macOS) |

#### S7 cross-platform

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-XP-006 | P0 | yes | Transfer vBTC from web to macOS |
| TC-XP-007 | P0 | yes | Transfer vBTC from macOS to web |
| TC-XP-008 | P0 | yes | Forward received vBTC back to its owner |
| TC-XP-004 | P1 | yes | Send BTC from web to macOS |
| TC-XP-005 | P1 | yes | Send BTC from macOS to web |
| TC-XP-009 | P1 | yes | Bulk vBTC transfer across platforms |

## Filing and results

As `SMOKE.md` "Filing issues" and "Results and commits": one issue per defect in `VerifiedXBlockchain/VerifiedX-Issues`, label `source:e2e-smoke` plus the component, on the `E2E Testing` board (org project 4; Priority, Platform, Area `04 btc-vbtc` for almost everything here). Search the tracker first; this week's BTC issues (#327 to #331, #333, #338) are open or In Progress, so a recurrence is a comment on them, not a new issue. Results in `docs/testing/runs/20261023a-web.md`, `-macos.md` and `-cross.md`, stage sections as above, committed on `testnet` after each stage, only the lane's own file, no push.

## Starting a lane session

Each lane is its own session in `~/prj/vfx/vfx-gui` (branch `testnet`). Tyler starts them once the chain is past block 401; each lane funds itself after S1; before the macOS lane starts backs up the Bitcoin key he asked to be reminded of.

**Web lane**

```
You are running the web lane of BTC and vBTC pass 20261023a for the VFX web wallet, in this checkout (vfx-gui, branch testnet). Read docs/testing/SMOKE-BTC.md first (the network section is new: the VerifiedX signet replaced Bitcoin testnet4 and the VFX testnet was reset), then docs/testing/SMOKE.md, docs/testing/README.md and docs/automation.md, then 04-btc-vbtc.md and the other area files as you reach their cases. Target: the deployed https://wallet-testnet.verifiedx.io/?automation=1 (9.0.0) in the built-in browser pane with tool/automation/flt_semantics.js and fltA11y.enable(); check the landing screen says 9.0.0 and that a BTC explorer link opens signet.verifiedx.io. Accounts: reuse the keys in ~/.config/vfx-release-tests/agent/accounts.web.env (the wallet still holds them; verify the BTC key with TC-AUTH-039), add account C and record it in that file; secrets never leave the file. Stages S1 → S2 → S3 → S4 → S5 (→ S7 with the macOS lane) in the order of the web lane table; nothing vBTC before the chain is past block 401 (Spyglass block height). After S1 fund your addresses through the faucet token (token in ~/.config/vfx-release-tests/faucet.env, never written anywhere; SMOKE.md "Funding"), mine one block for the BTC, and run S2; only if the token fails, write one Funding request block and put it on my /bench. Every Bitcoin check reads https://signet.verifiedx.io (API /api), never mempool.space; withdrawals pay to your own BTC address, not a treasury; no replace-by-fee outside the RBF cases. Blocks are mined on demand through the farm API in SMOKE-BTC.md "Timing" (token in ~/.config/vfx-release-tests/signet.env, read into the shell and never written into results, issues or chat): broadcast, wait until the transaction shows on the signet explorer, mine what the step needs in one call (4 for a deposit or withdrawal, 1 for a send), then give the node a minute. When the first vault deposit credits, comment on VerifiedX-Issues#333 with the heights and times. Results in docs/testing/runs/20261023a-web.md, committed on testnet after each stage (only that file, no push, no other git operations; the macOS lane shares this checkout). One issue per defect on the E2E Testing board (org project 4, label source:e2e-smoke, Area 04 btc-vbtc); #327 to #331 and #333 are open, so a recurrence is a comment there. A blocking failure (SMOKE.md) pauses the lane and asks me. Begin with the pre-flight and tell me the build and the chain height before S1.
```

**macOS lane**

```
You are running the macOS lane of BTC and vBTC pass 20261023a for the VFX desktop wallet, in this checkout (vfx-gui, branch testnet). Read docs/testing/SMOKE-BTC.md first (the network section is new: the VerifiedX signet replaced Bitcoin testnet4 and the VFX testnet was reset), then docs/testing/SMOKE.md, docs/testing/README.md and docs/automation.md, then 04-btc-vbtc.md and the other area files as you reach their cases. This lane drives my real ~/rbxtest (fresh for the reset chain) with `make run_macos_driver_real` (no VerifiedXCore may be running first; if one is, ask me to quit my wallet). At boot record the CLI version (9.0.0.x), the chain height (hundreds, not 1.18 million; stop and ask me if it is the old chain) and the signet attestation status. Accounts: reuse the keys in ~/.config/vfx-release-tests/agent/accounts.macos.env by import (A, B, the BTC key), create account C and record it in that file; only ever act on your own addresses; secrets never leave the file. Stages S0 → S1 → S2 → S3 → S4 → S5 → S6 → (S7 with the web lane) in the order of the macOS lane table; nothing vBTC before the chain is past block 401. After S1 fund your addresses through the faucet token (token in ~/.config/vfx-release-tests/faucet.env, never written anywhere; SMOKE.md "Funding"), mine one block for the BTC, and run S2; only if the token fails, write one Funding request block and put it on my /bench. S6 runs on `make run_macos_driver_real_profile` after quitting the debug app; restart the debug app afterwards. Every Bitcoin check reads https://signet.verifiedx.io (API /api), never mempool.space; withdrawals pay to your own BTC address, not a treasury; no replace-by-fee outside the RBF cases. Blocks are mined on demand through the farm API in SMOKE-BTC.md "Timing" (token in ~/.config/vfx-release-tests/signet.env, read into the shell and never written into results, issues or chat): broadcast, wait until the transaction shows on the signet explorer, mine what the step needs in one call (4 for a deposit or withdrawal, 1 for a send), then give the node a minute. TC-BTC-059 is the case we most need observed: screenshot every state of the desktop withdrawal dialog on a watched vault and record it verbatim. When the first vault deposit credits, comment on VerifiedX-Issues#333 with the heights and times. Results in docs/testing/runs/20261023a-macos.md, committed on testnet after each stage (only that file, no push, no other git operations; the web lane shares this checkout). One issue per defect on the E2E Testing board (org project 4, label source:e2e-smoke, Area 04 btc-vbtc); #327 to #331, #333 and #338 are open, so a recurrence is a comment there. A blocking failure (SMOKE.md) pauses the lane and asks me. Begin with S0 and tell me the CLI version, the chain height and the attestation tip before S1.
```
