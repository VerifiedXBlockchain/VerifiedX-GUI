# 20261023a CLI multi-withdrawal pass

vBTC multi-vault withdrawal (`RequestWithdrawalMulti`, `CompleteWithdrawalMulti`, raw `GetRawRequestWithdrawalMultiTxData`) tested end to end against the Core CLI's HTTP API on watched vaults, local and raw path. No UI. Run 2026-10-23, 17:42–18:05Z.

- **Build:** Core CLI `9.0.0.1757-beta` (the CLI bundled in `/Applications/VFXWallet.app`, started `enableapi gui apitoken=testnet testnet` on the macOS lane's `~/rbxtest`); source read at Core `origin/testnet` `2cd65002`. Spyglass testnet after PR #66.
- **Chain:** VFX testnet synced at 4120 (Spyglass tip 4117) at start, 4217 at the end. Signet tip 2183 at start, 2195 at the end (12 blocks mined on demand, farm requests 16, 17, 18). Attestation at start: `BitcoinTipHeight` 2170, `EventsThroughBitcoinHeight` 2167, `SignerEpoch` 5, 13 signers, 9 signatures, `OpenWithdrawals` 0; at the end 2195 / 2192, `OpenWithdrawals` 0.
- **Accounts:** macOS lane A `xD5hREu1…MqjP6`, B `xPmT8XiX…57NbK`, C `xTrYQw4e…YZrNqH`; payouts to the lane's `tb1qpy9ngm47…06t0gntw`. Keys stayed in `accounts.macos.env`; the raw case signed with B's key in a local Node process (JS SDK `KeypairService`) that read the file and printed only the signature and public key.
- **Calls:** every request and answer is in the session scratchpad (`run/calls.log`); trimmed below. Every call sent `apitoken: testnet`.

## Starting balances (node, `GetAllVBTCBalances`)

| Vault | UID | Vault coins | A | B |
|---|---|---|---|---|
| m1 | `ecc3aec4…:1792763038` | 7000 sats (one coin) | 0.000035 | 0.00003 |
| m2 | `b3c6ddf5…:1792763130` | 8000 | 0 | 0.00008 |
| web1 | `1c951c92…:1792760559` | 6000 | 0.00002 | – |
| wiz | `fe8d25c7…:1792761545` | 5000 | – | 0.00005 |

All four `Attested: true`. A total 0.000055, B total 0.00016, C none. VFX: A 35.99940901, B 9.99997852. BTC address 138,116 sats.

## Results

| Case | Result | Note |
|---|---|---|
| 1 Allocation across vaults (local) | pass | A, 0.000035 at 3 sat/vB (above the biggest available single-vault balance, 0.00002 after case 5's pending 0.000015 on m1, and below A's 0.00004 available) → one VFX request `2b391bf4…7840` (type 27, `VBTCWithdrawalRequestMultiV2()`, VFX 4129), allocations web1 0.00002 + m1 0.000015 (largest first, tie broken by UID). Answer `BitcoinTransactions: 2`, `AttestedContracts` both. The planner subtracted A's own pending case 5 request on m1. |
| 2 Payout per vault | pass | Both shares pinned in the request block, each to its own Bitcoin transaction from its own vault: web1 `54b8ef18…d60d` (1538 to the lane, 4000 change, fee 462) and m1 `bef4a8ec…e792` (1038, 5500 change, fee 462). Signers broadcast both about 2.5 min after the pin (17:47:47); confirmed in signet 2184; both shares closed paid at VFX 4146 (attested 2187/2184). Received 2576 = 3500 − 2 × 462. A web1 0.00002 → 0, m1 0.000035 → 0.000005 after cases 1 and 5. |
| 3 CompleteWithdrawalMulti on watched shares | pass with defect #360 | No VFX transaction and no FROST ceremony (local transactions after 4120: type 27 and type 44 only, no type 28). Before payout: `Success:false`, `"0/2 withdrawal share(s) paid; 2 being paid by the chain (nothing to do; ask again later)"`, `BeingPaid: true`, `BTCTxHash: null`; the txid only in `ErrorMessage` (`[AWAITING-BTC-CONFIRMATION] This withdrawal is paid by Bitcoin transaction 54b8ef18…`). After close: `Success:true`, `"All withdrawal shares completed"`, `AlreadyComplete: true`, `BTCTxHash` set, `VFXTxHash: null`. After case 4: `"1/2 withdrawal share(s) paid; 1 closed and refunded (no Bitcoin was or will be sent for them)"`, refunded share `Refunded: true`, `"This share was closed without being paid (Cancelled); its vBTC was returned to the requester. No Bitcoin was or will be sent for it."` Truthful per share. The route's summary still describes "one FROST ceremony, one Bitcoin transaction and one WITHDRAWAL_COMPLETE per contract". |
| 4 Per-share fee raise and release | pass | B, 0.00007 at 1 sat/vB → `0390ca74…6d13` (VFX 4179): m2 0.00005 pinned `c58c225f…2f03` (4846, fee 154), m1 0.00002 pinned `c7ea2d98…d45d` (1846 + 2000 change, fee 154). Refusals first: same rate `"The new fee rate must be above the 1 sat/vB the withdrawal's newest Bitcoin transaction pays."`, A as signer `"Only the requester can raise a withdrawal's Bitcoin fee."` Then `BumpWithdrawalFee` m2 → 3 (`aba32f60…d0af`) and `ReleaseWithdrawal` m1 at 2 (`f87f6078…a2f7`), both type 44 at VFX 4183. New pins: m2 `2407c724…67cf` (4538, fee 462), m1 release `866f3d59…d2b9` (3692 back to the vault, fee 308); the originals marked `Superseded` and never broadcast; only the new two reached the mempool (17:59:32). Mined 2192; closed at VFX 4202: m2 `Settled` by `2407c724…`, m1 `Released` (`"The vBTC was returned to its requester, less that transaction's fee."`). B m2 0.00005 → 0, m1 0.00001 → 0.00002692 (refund 1692 = 2000 − 308); lane received 4538. |
| 5 Fits one vault | pass | A, 0.000015 at 1 sat/vB → `f9a2c5e5…9bf8`, `Allocations` m1 only, sent as the single shape (`VBTCWithdrawalRequest()`), `IsMultiContract: false` in `GetWithdrawalRequestShares`. It waited (`State: Waiting`, `"the vault's free coins do not cover the amount (others are held by withdrawals not yet confirmed)"`, `ExpiresAtVfxHeight` 4490) because case 1's m1 share, mined in the same block, took m1's only coin; pinned as soon as that change confirmed (`9d0c052c…b620`, 1346 + 4000 change, fee 154), mined in 2188, closed at VFX 4176. The answer still says "multi-contract withdrawal request created successfully" (#360). |
| 6 Validation | pass with defect #359 | Without `SmartContractUID` (or with `null`) every body gets HTTP 400 `"The SmartContractUID field is required."` (#359); with `"SmartContractUID": ""`: above balance (0.0001) `"Insufficient combined vBTC balance. Available: 0.000055, Requested: 0.0001"`; 0 and −0.00001 `"Amount must be greater than zero"`; 0.000040001 `"Amount cannot have more than 8 decimal places."`; dust share (0.000039 → web1 0.000004 at 3 sat/vB) `"Withdrawal share from contract 1c951c92…: 0.000004 BTC cannot pay a Bitcoin withdrawal at 3 sat/vB. The smallest withdrawal transaction costs 462 sats in fees and the payout must be at least 330 sats, so the minimum at this fee rate is 0.00000792 BTC. Raise the amount or lower the fee rate. (The total was split across 2 contracts; each share pays its own Bitcoin fee.)"`; `tb1qnotarealaddress000` and a mainnet `bc1q…` address `"TX Verify Failed: The withdrawal's Bitcoin address is not an address on this network: …"`; `xRBXabc123notreal` `"Reserve accounts cannot request BTC withdrawals. Move the vBTC to a normal VFX address first."`; C (holds nothing) `"No spendable vBTC balance found for this address."`; FeeRate 0 `"Fee rate must be greater than zero"`; an address this node does not hold `"Account not found: xCkUC4…"`; FeeRate 2.5 HTTP 400 (Int32). Nothing was broadcast. |
| 7 Raw path (B) | pass with defect #361 | `GetRawRequestWithdrawalMultiTxData` with explicit Inputs wiz 0.00003 + m2 0.00003 at 2 sat/vB → `Hash 39ff6b9b…a22b`, `Fee 0.00001375`, `Nonce 2`, `IsMultiContract: true`, `BitcoinTransactions: 2`, `Data` and `HashPreimage` returned. Client checks before signing: sha256(sha256-hex(`HashPreimage`)) = `Hash`; the preimage starts with Timestamp + B and contains `Data` verbatim; `Data` names B, the lane address, the two Inputs and the total; key derives B. Signed `Hash` with B's key; submitted with `SendRawRequestWithdrawalTx` → `"Withdrawal request transaction broadcast successfully."` (a flipped signature first: `"Transaction verification failed: Signature Failed to verify."`; resubmit after success: `"No pending transaction found for hash 39ff6b9b…. Call GetRawRequestWithdrawalTxData first."`). Mined VFX 4155; pinned wiz `4d0a1c43…95cc`, m2 `6ab116da…e8d8` (2692 each, fee 308); broadcast 17:53:28–43, mined 2188, closed VFX 4176. B wiz 0.00005 → 0.00002, m2 0.00008 → 0.00005. Builder refusals: sum ≠ total, duplicate contract, input above balance, xRBX, 9 decimals, C holds nothing, all verbatim in calls.log; but a bad BTC address builds and fails only at submit (#361). Node plan without Inputs: m2 0.00008 + wiz 0.00004 for 0.00012 (built, not sent). TXV1 `VerifyRawTransaction` refused the builder's transaction both with `Data` as object and as string: `"This transactions hash is not equal to the original hash."` (see Questions); the vBTC submit route is the one the builder names. |
| 8 Spyglass | pass with defect #362 | `GET /api/btc/vbtc-v2/<address>/` after each case: one `withdrawal_requests` row per share for cases 1, 4, 5 and 7, each closed in the block the node closed it (`completed` with the paying txid, case 4's m2 row with the replacement `2407c724…`; the released m1 row `cancelled`, `closed_because: Released`, `refunded_amount: 1.692e-05`); per-address balances equal the node's for A and B after every case. While shares were pinned (VFX 4155–4176 and 4179–4202, through the bump and release) every multi row served `pin_state: null`, `pin_txid: null` (#362). Comment on #354: its fix holds for multi rows. |

## Transactions

| What | VFX hash | Height | Bitcoin txid | Signet block | Sats to lane / fee |
|---|---|---|---|---|---|
| Case 1 request (A, multi) | `2b391bf42e56a35f926008170b1fee1f404edd5b3810b43d7ea946776c0d7840` | 4129 | | | |
| Case 1 web1 payout | | closed 4146 | `54b8ef185d93caa700d3033b0142ab96feeb328c6d2b0baa1dd7afa3b5ded60d` | 2184 | 1538 / 462 |
| Case 1 m1 payout | | closed 4146 | `bef4a8eceb3a6180215be1d3937f7e6180433885765b2b750b06427af95fe792` | 2184 | 1038 / 462 |
| Case 5 request (A, single shape) | `f9a2c5e56354b8da0dff65a21addac032c1594f182b8e9e75eab530960889bf8` | 4129 | | | |
| Case 5 m1 payout | | closed 4176 | `9d0c052cbb681269674497fb3272fe230696b153396b0a8a95c9719c4642b620` | 2188 | 1346 / 154 |
| Case 7 request (B, raw multi) | `39ff6b9bae91afa57403af3607ba20736823ad6595f23880d0175c43f7cca22b` | 4155 | | | |
| Case 7 wiz payout | | closed 4176 | `4d0a1c4368f935105048df834434c8d36d16eadd7ceb234bf14466dbc86295cc` | 2188 | 2692 / 308 |
| Case 7 m2 payout | | closed 4176 | `6ab116dae9b2a7f5bf010f2ce191fcb226bacf1c6cde4fde2df3572dfab7e8d8` | 2188 | 2692 / 308 |
| Case 4 request (B, multi) | `0390ca745e78e7558546bd5fae4d485e6a4b24e3d74558e837b95dfb2d996d13` | 4179 | | | |
| Case 4 m2 first pin (superseded, never broadcast) | | | `c58c225fbe3f5a9e66f706342023652e64360c724fb86dfc8a7074aa74e02f03` | – | (4846 / 154) |
| Case 4 m1 first pin (superseded, never broadcast) | | | `c7ea2d9847999e4a763f997d3126b3824d0fcc2ea4f53b941b61f26b08fbd45d` | – | (1846 / 154) |
| Case 4 fee bump m2 → 3 sat/vB (type 44) | `aba32f60dc479d242609694ca3081ab2dc079852e2b347f0c129c70efb54d0af` | 4183 | `2407c72422e488e1e69e2a1b4913c6684d0b12487bb5ef6110f1f71be7cf67cf` | 2192 | 4538 / 462 |
| Case 4 release m1 at 2 sat/vB (type 44) | `f87f607866df94febc64f94ab52b696d1beaa85f4957442cf004234744d0a2f7` | 4183 | `866f3d59c6ddac2ceff6166865f1d0369be4090d0d15a51b99f176e62b8ed2b9` | 2192 | 0 (3692 back to m1's vault) / 308 |

**Totals.** The lane address went 138,116 → 151,960 sats (+13,844) = case 1 (3500 − 2 × 462) + case 5 (1500 − 154) + case 7 (6000 − 2 × 308) + case 4 m2 (5000 − 462). Every share paid once, by one transaction, for its amount less one miner fee at the pinned rate (fee = rate × 154 vB, the floor's size; the payouts are 142 vB). No share was paid twice; nothing is open (`OpenWithdrawals` 0 at VFX 4217).

## Ending balances (node)

| | m1 | m2 | web1 | wiz | VFX |
|---|---|---|---|---|---|
| A | 0.000005 | 0 | 0 | – | 35.99938406 (−0.00002495, two requests) |
| B | 0.00002692 | 0 | – | 0.00002 | 9.99993066 (−0.00004786, two requests, bump, release) |

Spyglass shows the same per-address figures.

## Questions

- **TXV1 raw routes and the vBTC builders.** `TXV1/VerifyRawTransaction` and `SendRawTransaction` re-serialize `Data` (`JToken.ToString(Formatting.None)`) and the amount before hashing, so the hash the vBTC builder returned and B signed (`39ff6b9b…`) never matches: `TXV1/GetTxHash` computes `d9772225…` with `Data` as a JSON object (small decimals such as 0.00003 come back in exponent form) and `c32e8a21…` with `Data` as a string. The builder's own message names `SendRawRequestWithdrawalTx`, which worked. Is it intended that vBTC raw transactions go only through the vBTC `SendRaw*` routes, and should Core's raw docs say so?
- **Available balance while a request is in the mempool.** Just after case 5 was sent, `GetAllVBTCBalances` for A still showed m1 `AvailableBalance` 0.000035 and `PendingWithdrawals` 0, while the allocation planner (correctly) subtracted the pending 0.000015. An exchange reading the balance between submit and mining sees more than it can withdraw. Intended?
- **Two requests on one vault in one block.** Case 5 (1 sat/vB) was sent before case 1 (3 sat/vB), both took m1 and were mined in VFX 4129; case 1's m1 share got the vault's only coin and case 5 waited for its change. Fine for funds; is the in-block order meant to decide which share pins first? An exchange batching withdrawals on a one-coin vault will see shares serialise through `Waiting`, each with an `ExpiresAtVfxHeight` (here 361 blocks).
- **Wording of a released share.** `GetWithdrawalRequestShares` and `CompleteWithdrawalMulti` call the released m1 share `Cancelled`; `GetWithdrawalPin` says `Released`, Spyglass `cancelled` / `Released`. Should the share views say Released?
- `GET /txapi/TXV1/GetLocalTxAfterBlock/4120` lists every transaction of this pass twice.

## Not covered

More than two shares, the 10-input cap, a Waiting share reaching its expiry, cancelling a Waiting share, a share that fails at signing, a reorg. `RequestWithdrawalMulti` from an address whose vaults this node does not hold (refused locally: `Account not found`; raw path covers that use).

## Handover

- **Safe for exchanges?** On these watched vaults, yes as far as funds go: one VFX request opened every share, each share was pinned and paid by its own vault's signers exactly once, payouts equal the share less one miner fee, a fee raise and a release on different shares of one request each closed their own way with the right refund, superseded transactions were never broadcast, and `CompleteWithdrawalMulti` never sent anything for a watched share. Integration caveats: send `"SmartContractUID": ""` (#359); follow shares with `GetWithdrawalRequestShares` / `GetWithdrawalPin`, not `CompleteWithdrawalMulti`'s `Success` / `BTCTxHash` (#360); ignore the raw builder's "complete EACH contract" line (#360); validate the BTC address before signing (#361); do not rely on Spyglass for the pin while a share is open (#362); expect shares on a one-coin vault to wait for each other.
- Issues filed: #359, #360, #361 (component:core), #362 (component:spyglass), all P2, Platform CLI, Area 00 core-cli. Comment on #354.
- The CLI was started at 17:42:48Z and stopped with `SendExit` at 18:04Z; port 17292 free, no `VerifiedXCore` running. `~/rbxtest` was used by this pass only while the macOS lane was idle.
