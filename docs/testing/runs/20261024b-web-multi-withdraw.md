# Multi-vault withdrawal pass 20261024b: web lane

Cases: TC-BTC-060 to 067 (`04-btc-vbtc.md`, "Multi-vault withdrawals", commit `debd781a` on `docs/vbtc-multi-withdrawal-smoke`). Target: `https://rbx-web-wallet-testnet.web.app/?automation=1` in Claude's built-in browser pane, page source `main.dart.js?version=9.0.1d`, landing `Web Wallet Testnet 9.0.1` (GUI PRs #66 to #69), driven through `tool/automation/flt_semantics.js` (light DOM). Spyglass testnet `https://data-testnet.verifiedx.io/api` with `vbtc-v2/withdraw/multi/prepare/` (PR #71). Bitcoin: VerifiedX signet. Accounts: `~/.config/vfx-release-tests/agent/accounts.web.env` (A `xVWNbcBXTtiiL7ZHCqxRP1q12tcgUTQA4m`, B `xXVdgxHRzmr5WnSsi3c2v9wEjsFdk7jnkf`, BTC `tb1qg8d0w2gsu8qdwrfvxjge3wrvum4efj8lhq45a2`). Run by a Claude web-lane session on 2026-10-24, 14:08 to 14:52 UTC. Screenshots: session tool-results folder (not committed).

## Summary

| Case | Result | Note |
|---|---|---|
| TC-BTC-060 | pass | Two vaults (web1 + w2), 0.00011 at 2 sat/vB; both parts `Sent`; one history row `(2 vaults)` |
| TC-BTC-061 | pass | Three vaults (w4, w1, w5), 0.00017; `for 3 parts`; three txids; `Withdrawal Sent`; row `(3 vaults)` |
| TC-BTC-062 | pass | Floor toasts verbatim at 3 and 1 sat/vB; 1000 sats at 3 refused, 1008 reaches `Confirm Withdrawal`; amount and address field errors |
| TC-BTC-063 | skipped | Needs 11 funded vaults; A has 7 (rule covered by unit tests) |
| TC-BTC-064 | pass | Raise Part 1 (`At least 2` / `At most 5000` / 3), release Part 2 at 2; `Withdrawal Partly Sent`; only the new txs reached signet |
| TC-BTC-065 | pass | Waiting part alone offers `Cancel Withdrawal`; body verbatim; type 29; `Closed, its vBTC was returned to you`; other part paid |
| TC-BTC-066 | pass | After reload and unlock: one row per request with `(N vaults)`, `Withdrawal Status` reopens the same parts, txids and final titles |
| TC-BTC-067 | pass | `More Than This Vault Holds` offer, `Withdraw from Several Vaults` prefills 0.0001; above all vaults gives the old refusal |
| Extra: part under 546-sat floor | pass | Refused before signing (TC-BTC-062) |
| Extra: spendable after a request | pass | Available card 0.000495 → 0.000385 right after the 060 request; web1 `Transfer` 0.00001 refused `Not enough balance`; after a single 0.00001 request on w2 the card read 0.00012702 (w2 counted at 5000, not 6000) |
| Extra: mobile width | pass | At 375×812 the vBTC list shows `Withdraw vBTC` (see Questions for `Bulk vBTC Transfer`) |

No defects filed. Deviations from the cases are listed under each row and in Questions. End balances: A 71.94686826 VFX (from 71.94821746), BTC address 0.0019692 (from 0.00198108), B unchanged 15.04983165 VFX. A's vBTC left: w2 0.00005, web1 0.0000051, m1 0.000005.

## Setup

The browser profile on this origin had no wallet data (the earlier passes ran on `wallet-testnet.verifiedx.io`), so A was restored with TC-AUTH-014 (mnemonic, own password from the env file) and B added with TC-AUTH-031 (private key, B's password). Dashboard after restore: A 71.94821746 VFX, 0.00198108 BTC, BTC address tb1qg8d0…45a2 (matches the env file).

Five watched vaults, not three: every multi-vault request drains its largest vault, so 060, 061, 064 and 065 together need five full drains on top of A's existing `qa-20261023a-web1` (0.00009). With three vaults the lane would have run out before 065. No faucet top-up was needed.

| Vault | Contract | Deposit address | Deposit tx (fee) |
|---|---|---|---|
| qa-20261024b-w1 | 2d809e84e6e24fb39468a778eee32788:1792851308 | tb1ppkehvrfvvrpamk4pc5jujhpafepktseu794kpt9neqn9wmkj97vsgxw7p2 | 10ca57afbf83b5b7f3e11f3a20014216458a6cdf01cc29a403cde39bbc27b5d4 (824, 5 inputs) |
| qa-20261024b-w2 | 172dfbb98fd64275b674433b38d3612d:1792851330 | tb1pcf8exrerpqytz3rswtgt9jsuqdcdw7xmhsm0f9vkmvelqjgjug4qlsf2zz | d018bd80ac8a76a9ea8f7ce78859a2f457ea099f45a7d8dc7c4a12225d26543d (280) |
| qa-20261024b-w3 | dca9629badd4441f9769565135e9a836:1792851341 | tb1pr8mlyk7dahvwgcj4ttmdsf0v5psq9sr6759cjm6yrzl2p45djhgsfjpnxq | 7b37a04e93d4a93568bfc96e69b5995224d22e286cd66ca58acd752e0c2f1f17 (280) |
| qa-20261024b-w4 | 24dec8f0d4a04232a41c4bc91811525c:1792851355 | tb1pyyejvdh0hcgg673hvkp53m3ewz9af4qqs6myt05ay3yxvw98avxq8hasg5 | def393a8b82dd19a912089a61a86a73f6bcd7b54485d19f090dd7ded121c7cc7 (280) |
| qa-20261024b-w5 | bec7a6c390af40eea4a44583c80bca00:1792851370 | tb1px960ynm05lkc0t0flrqjxh65glsu9zhf9s0p8t5ysnsva326p8rqrm0the | 7d0cb53ce6b01e2467bd226eecf71d876455adc77c448079d924c1d1fff9fa1b (280) |

Created by TC-BTC-023 (`MPC Ceremony in Progress` 0% → 30% → `Creating Contract` → `Token Created`, about 12 s each; mints in VFX blocks 10,082 to 10,086, about 0.00025 VFX each). Each funded with 0.00008 BTC by TC-BTC-027 at `Minimum` (2 sat/vB): `Please Confirm` `Sending: 0.00008 BTC / To: <deposit> (Token Deposit Address) / From: tb1qg8d0…45a2 / FeeRate: 2 SATS`, `Transaction Broadcasted`. All five in signet block 2,357 (lane mined 4 blocks, 14:20:45Z), credited 0.00008 vBTC each on Spyglass at 14:21:54Z (VFX ~10,110). Starting holdings: web1 0.00009, w1 to w5 0.00008, m1 0.000005 (received from macOS on 20261023a). Allocation tie order (by contract id): w2, w4, w1, w5, w3.

## Cases

| Case | Result | Evidence |
|---|---|---|
| TC-BTC-062 | pass | Before any withdrawal. Card `Available to withdraw in one request:` `0.000495 vBTC` (sum of all 7); `(MAX: 0.000495 vBTC)` fills 0.000495. 0.000094 + Custom 3: toast `Part 2 would be 0.000004 BTC, below the Bitcoin fee floor at 3 sat/vB (each part needs at least 0.00001008 BTC). Lower the fee rate or the amount.`; at Custom 1: `… at 1 sat/vB (each part needs at least 0.000007 BTC) …`; 0.0001 at 3: `Part 2 would be 0.00001 BTC, below … at least 0.00001008 BTC …`. 0.00010008 at 3 reaches `Confirm Withdrawal` (`Part 1 · qa-20261023a-web1: 0.00009 vBTC`, `Part 2 · qa-20261024b-w2: 0.00001008 vBTC`, `at least 462 sats … at least 924 sats … for 2 parts`), cancelled. Field errors: 0.0005 `Maximum amount is 0.000495 vBTC`; 0.000010001 `Amount can have at most 8 decimal places`; `abc123` `Invalid BTC address.`; a mainnet bc1q address `This is a mainnet BTC address. A testnet address is required.` No dialog, nothing signed, VFX balance unchanged, no history row |
| TC-BTC-067 | pass | w1 detail (`My Balance: 0.00008 vBTC`) > `Withdraw` > 0.0001 > Submit: `More Than This Vault Holds` / `This vault holds 0.00008 vBTC. Withdraw 0.0001 vBTC from several of your vaults in one request instead?` / `Cancel` `Withdraw from Several Vaults`. The button opens `Withdraw vBTC` with `0.0001` in the amount. Back on w1, 0.0006 (above 0.000495): toast `Insufficient balance. Available: 0.00008 vBTC`, no offer |
| TC-BTC-060 | pass | 0.00011 (web1 0.00009 + 0.00002), `Minimum` = 2 sat/vB on this wallet (not 1, see Questions). `Confirm Withdrawal`: `To: tb1qg8d0w2gsu8qdwrfvxjge3wrvum4efj8lhq45a2`, `Fee rate: 2 sat/vB`, `Part 1 · qa-20261023a-web1: 0.00009 vBTC`, `Part 2 · qa-20261024b-w2: 0.00002 vBTC`, `Bitcoin fee per part: at least 308 sats (0.00000308 BTC), taken out of that part`, `Total Bitcoin fees: at least 616 sats (0.00000616 BTC) for 2 parts`, `Arrives at the address: at most 0.00010384 BTC`, `Each part settles on its own, so one part may be paid before another.` Request a3e71b6f458d67c2e09d267e39efa24605ee88c2704b2ab6244ed4efa7a7eca8 (type 27, `VBTCWithdrawalRequestMultiV2()`, VFX 10,131, 14:25:32Z). First screenshot (~30 s later) already `Withdrawal in Progress`, both parts `Bitcoin transaction fixed, waiting for Bitcoin to confirm it`, `Current fee rate: 2 sat/vB`, `Release` / `Raise Fee` each. Part 1 d272c175e1bc013703b8efb70d2f492b55c3300eabc3140adc669fb11a3d2941 (web1 in, 8,066 to the lane + 546 change, fee 424), Part 2 abbaa79a79a09fe507662dc96179bbcf8953a49334c90943db8e41bd72eba366 (w2 in, 1,692 to the lane + 6,000 change, fee 308). Both reached signet ~3 min after the pin; Part 2 confirmed in 2,363 by the regular miner, Part 1 in 2,365 (lane mined 4, 14:29:10Z). Completion 24089e7d… / 466ae084… on Spyglass. Dialog `Withdrawal Sent`, both `Sent`. No FROST step. VFX tab: one row `vBTC Withdrawal Request (2 vaults) (0.00011 vBTC)` with `Withdrawal Status`, no completion row. Balances: w2 0.00008 → 0.00006; web1 0.00009 → 0.0000051 (see Questions: 510 sats kept as A's vBTC to leave 546 sats of change) |
| TC-BTC-061 | pass | Precondition met with three own vaults, not a contract received from B (deviation). 0.00017 at 2 sat/vB: `Part 1 · qa-20261024b-w4: 0.00008`, `Part 2 · qa-20261024b-w1: 0.00008`, `Part 3 · qa-20261024b-w5: 0.00001`, `at least 924 sats (0.00000924 BTC) for 3 parts`, `at most 0.00016076 BTC`. Request de0e1a2e1e8815716a8d893330fa4becca0fd1a6288ba1a8edab6a81af14e7e4 (VFX 10,160). Dialog `Waiting for the Request to Be Mined`, each part `The request is not in a block yet` → `Withdrawal in Progress`, three pins 3cd74deda55b84e1c6fc2742babc363e6a5b04b19cc88157b8313144e92a30ef (w4, 7,692), 445bcb1f04467fa6ec058d1b43262420c225f621ddac9e3ae17eec6b3ed67809 (w1, 7,692), d417b9daf48ca05556fda61d8e77f89ff189588611f9e251962802f6893d64f7 (w5, 692 + 7,000 change), fee 308 each, all confirmed in 2,369 (lane mined 4, 14:34:46Z) → `Withdrawal Sent`, three `Sent`. Row `vBTC Withdrawal Request (3 vaults) (0.00017 vBTC)` |
| TC-BTC-064 | pass | 0.00009 at Custom 1: `Part 1 · qa-20261024b-w3: 0.00008`, `Part 2 · qa-20261024b-w5: 0.00001`, `Fee rate: 1 sat/vB`, `at least 154 sats (0.00000154 BTC)`, `at least 308 sats (0.00000308 BTC) for 2 parts`, `at most 0.00008692 BTC`. Request bec3f505c610d41d1192efb8b1e7539eb1ac64467e3dc33c3f7fd70f4f77ab81 (VFX 10,186); pins 202580dd…abd6f6 and 59745515…aa506 at 1 sat/vB. Part 1 `Raise Fee` → `Raise the Fee of Part 1` / `New fee rate (sat/vB)`: 1 → `At least 2 sat/vB`, 5001 → `At most 5000 sat/vB`, 3 → `Valid Transaction` `fee of 0.0000102 VFX` → Yes → `Transaction broadcasted!`; type 44 `VBTCWithdrawalFeeBump()` 8aa6970e77493574d8b2da7b7ea2dd1ea91ad37801c4255dc1df1cd03b585806 (VFX 10,193). Part 1 then showed `Sent. The actions come back once the chain shows the change…` with Part 2's buttons live. Part 2 `Release` → `Release Part 2` (`Its Bitcoin goes back to the vault and this part's vBTC is refunded to you, less the release's Bitcoin fee. The other parts are not affected.`) 2 → Yes; type 44 `VBTCWithdrawalRelease()` e65232a325126735dcf167840fe7a829a255eaf1689ad16ab596c67ba54c8a32 (VFX 10,195); Part 2 greyed with the same `Sent…` note, then `Being released: its vBTC comes back, less the release's fee`. Part 1 new pin ef8b1dbf6bc4b5bc90eec81d482db7fca259e8abffb3e36afefa4c76bd27f78c, `Current fee rate: 3 sat/vB` (7,538 to the lane, fee 462); release tx 7842fb9515e955d6abb4c914d4e8e719fd25d9fa5b84834f636e60c8dcf7b99f (w5 7,000 → 6,692 back to the vault, fee 308). The two original pins never reached signet. Lane mined 4 (2,377 to 2,380, 14:42:39Z). Dialog `Withdrawal Partly Sent`: Part 1 `Sent`, Part 2 `Closed, its vBTC was returned to you`. Spyglass: request 36 `cancelled`, `closed_because` Released, refunded 0.00000692; w5 A 0.00006692 (0.00007 less the 308-sat release fee). VFX tab rows `vBTC Withdrawal Fee Raise` and `vBTC Withdrawal Release` |
| TC-BTC-065 | pass | w2 (one coin, 6,000) own `Withdraw` 0.00001 at Custom 1: `Confirm Withdrawal Request` / `Withdraw 0.00001 BTC to tb1qg8d0…45a2 / Fee rate: 1 sats/byte` → Yes; request 4a99d95f6749b2d01946af8712cbc32ee67e40b8282d8661e3fa3e6ba756f86a (VFX 10,221), pin 14c3ddf6e1d4358c9a3efc596280a1aff506043550eb3f0f4246b11259e25d38. Then `Withdraw vBTC` (card 0.00012702) 0.00007692 at 1: `Part 1 · qa-20261024b-w5: 0.00006692`, `Part 2 · qa-20261024b-w2: 0.00001`; request 044e41504db301a080126d9fc4a946a224a017495bbbfc2e3b71c27544995c22 (VFX 10,224). Part 1 pinned e24a6093…aa008 with `Release` / `Raise Fee`; Part 2 `Waiting for its Bitcoin transaction` with only `Cancel Withdrawal`. Cancel → `Cancel Withdrawal?` / `Its Bitcoin transaction is not fixed yet, so it can still be cancelled. When the cancel is mined the withdrawal is closed and your vBTC is returned; no vote is held.` → Yes → `Transaction broadcasted!`; type 29 `VBTCWithdrawalCancel()` d1a1e266916214522f063d5412aa4e6ca7232143489a19591d3c245fefc6f7ff (VFX 10,229). Within 30 s Part 2 read `Closed, its vBTC was returned to you`; Spyglass request 42 `cancelled` (Cancelled), w2 A back to 0.00005 (6,000 less the single 1,000). Part 1 paid: e24a6093… (6,538 to the lane, fee 154) and the single 14c3ddf6… (846 + 5,000 change) in 2,385 (lane mined 4, 14:48:04Z). Dialog `Withdrawal Partly Sent` |
| TC-BTC-066 | pass | Reload `?automation=1`, `Unlock wallet for:` A, A's password. VFX tab: `vBTC Withdrawal Cancel`, `vBTC Withdrawal Request (2 vaults) (0.00007692 vBTC)`, `vBTC Withdrawal Request` (single, no amount, no `Withdrawal Status`), `vBTC Withdrawal Release`, `vBTC Withdrawal Fee Raise`, `… (2 vaults) (0.00009 vBTC)`, `… (3 vaults) (0.00017 vBTC)`, `… (2 vaults) (0.00011 vBTC)`; shares never appear as separate rows. Each `Withdrawal Status` reopened with the same vaults, amounts, txids and states: 065 and 064 `Withdrawal Partly Sent` (064 shows the raised pin ef8b1dbf…), 061 and 060 `Withdrawal Sent` |
| TC-BTC-063 | skipped | Needs 11 watched vaults with a balance; A has 7 |

## Pending BTC

| Tx | What | Status |
|---|---|---|
| 10ca57af…, d018bd80…, 7b37a04e…, def393a8…, 7d0cb53c… | deposits w1 to w5 | confirmed 2,357 |
| d272c175…, abbaa79a… | 060 parts | confirmed 2,365 / 2,363 |
| 3cd74ded…, 445bcb1f…, d417b9da… | 061 parts | confirmed 2,369 |
| ef8b1dbf…, 7842fb95… | 064 raised pin, release | confirmed (lane mined 2,377 to 2,380) |
| e24a6093…, 14c3ddf6… | 065 Part 1, single on w2 | confirmed 2,385 |

Signet tip 2,388 at 14:52Z; nothing of this lane is left in the mempool.

## Failures

None.

## Questions

- Payout short of `total less one fee per part` on a shared vault (060 Part 1). web1 held 9,036 sats (A 9,000, B 36). Core's pin paid 8,066 to the lane and left 546 sats of change, so A's 9,000 share delivered 8,066 + 424 fee and Spyglass still shows A holding 0.0000051 vBTC on web1. Nothing is lost (A keeps the 510 as vBTC), and the dialog's `Arrives at the address: at most …` stays true, but the vault's `My Balance` doesn't drop by the whole part as the case expects. Should the confirmation say so when a vault holds another holder's dust?
- The cases say `Minimum` is 1 sat/vB on the signet; this wallet's picker shows `Minimum 2 SATS` (testnet floor). 060 and 061 ran at 2 (308 sats a part); 064 and 065 used `Custom` 1, which the multi flow accepts. The 1-sat/vB wording in TC-BTC-060's expected text matched exactly at Custom 1.
- Wording against the case text: `Arrives at the address: at most …` (case: `about`), `Maximum amount is …` (case: `Max amount is …`). The case text should probably follow the app.
- Single-vault history rows read `vBTC Withdrawal Request` with no amount (as on 20261023a); TC-BTC-066 writes `vBTC Withdrawal Request (…)`.
- Reopening `Withdrawal Status` from history flashes `Waiting for the Request to Be Mined` / `The request is not in a block yet` for about a second before the chain state loads.
- At 375 px wide the vBTC list header shows `Withdraw vBTC` but not `Bulk vBTC Transfer`, and long token names run under the row chevron. Intended at mobile width?
- In 061 at mobile width, Part 3 (w5) showed no `Release` / `Raise Fee` while Parts 1 and 2 did, about the time all three confirmed in 2,369; at desktop width a minute earlier all three had them. Probably a per-part refresh racing the confirmation; not reproduced.
- Deposit toasts queue: five `0.00008 BTC has been sent to …` snackbars from back-to-back funding kept showing one after another for minutes, each naming its own deposit address.

## Objects created

Vaults qa-20261024b-w1 to w5 (table above), all owned by A. VFX transactions: mints 714627624b… (w1), db7e25005c… (w2), 559a2ebde8… (w3), 71fe0b27bf… (w4), 62ced85263… (w5); multi requests a3e71b6f…, de0e1a2e…, bec3f505…, 044e4150…; single request 4a99d95f…; fee raise 8aa6970e…; release e65232a3…; cancel d1a1e266….

## Handover

- A ends with 71.94686826 VFX; BTC address 0.0019692; vBTC w2 0.00005, web1 0.0000051, m1 0.000005; w1, w3, w4, w5 empty. B untouched.
- This origin (`rbx-web-wallet-testnet.web.app`) now holds A (mnemonic restore) and B (key import) in the pane's storage.
- The session scratchpad is shared with the macOS lane; its `mine.sh`, `tx.sh` and `wr.sh` were overwritten mid-run, so this lane moved its helpers to `scratchpad/web-lane/`.
