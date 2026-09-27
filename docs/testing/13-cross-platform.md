# 13 · Cross-platform transfers

This area moves funds and assets between the web lane and the macOS lane, so each platform is tested as both sender and receiver of the other's transactions. It runs in phase 2 of a release pass, after both lanes have finished, with one agent that keeps the web lane's browser session and the macOS lane's driver app open at the same time. Each case names accounts with their lane, for example `web:A` for the web lane's account A and `macos:A` for the macOS lane's account A, and reads addresses and keys from that lane's account file as described in `README.md`. The steps reuse the flows already specified in the lane files and cite the case that describes each flow, so hooks and exact messages are not repeated here.

## Area preconditions

- Both lanes finished phase 1. The web lane's browser tab is logged in as `web:A` at `http://localhost:42069/?automation=1`, and the macOS lane's driver app is running with `macos:A` selected and the chain synced.
- Objects created in phase 1 still exist: each lane's funded vBTC contracts (TC-BTC-022 to TC-BTC-027), fungible token T1 (TC-TOKEN-009), a minted NFT per lane that was not transferred (mint a fresh `sc-basic-<run-id>-<p>-xp` as in TC-SC-009 if needed), and a VFX domain per lane that was not deleted (create `qa<run-id><lane>xp` as in TC-ADNR-006 if needed).
- Vault restore codes from both lanes are still in `$TMPDIR/vfx-run-<run id>/`.
- Balances: `web:A` and `macos:A` each hold at least 20 VFX; each lane's BTC account holds at least 0.0002 testnet BTC.
- Record every balance before a case and compare after it. Neither lane is running any other case now, so every change is caused by the case itself.

## VFX

### TC-XP-001 · Send VFX from web to macOS
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes · Phase: cross-platform

**Preconditions:** Balances of `web:A` (web dashboard) and `macos:A` (desktop dashboard) recorded.

**Steps**
1. On web, send 1 VFX to `macos:TEST_VFX_A_ADDRESS` as in TC-SEND-003.
2. On macOS, open Transactions (`tap-key nav:transactions`) and wait up to 2 minutes, re-reading every 20 seconds, for a received transaction of 1 VFX from `web:TEST_VFX_A_ADDRESS`.
3. On macOS, read the dashboard balance of `macos:A`. On web, read the transaction in the web transaction list.

**Expected**
- The desktop lists the incoming transaction with the web address as sender, the amount 1 and status Success.
- `macos:A` increased by exactly 1 VFX; `web:A` decreased by 1 VFX plus the fee shown in the web confirmation.
- The transaction hash is the same on both platforms.

**Cleanup:** none.

### TC-XP-002 · Send VFX from macOS to web
**Platforms:** macOS, Web · **Priority:** P0 · **Moves funds:** yes · Phase: cross-platform

**Preconditions:** Balances recorded as in TC-XP-001.

**Steps**
1. On macOS, send 1 VFX to `web:TEST_VFX_A_ADDRESS` as in TC-SEND-002 (`tap-key send:address`, `send:amount`, `send:submit`).
2. On web, open Transactions and wait up to 2 minutes, reloading the list every 20 seconds, for the received transaction.
3. Read both balances.

**Expected**
- The web wallet lists the incoming transaction from `macos:TEST_VFX_A_ADDRESS`, amount 1, status Success, and the web dashboard balance rises by exactly 1 VFX without a page reload beyond the list refresh.
- `macos:A` decreased by 1 VFX plus the fee; the hash matches on both sides.

**Cleanup:** none.

### TC-XP-003 · Same account seen from both platforms
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · Phase: cross-platform

**Preconditions:** TC-XP-001 and TC-XP-002 passed.

**Steps**
1. In a second browser profile, open the web wallet with `?automation=1` and log in with `macos:TEST_VFX_A_PRIVKEY` through `VFX Private Key` (TC-AUTH-016).
2. Compare its VFX balance, its latest 10 transactions (hash, amount, status) and its owned NFTs and tokens with what the desktop shows for `macos:A`.
3. Log out of the second profile.

**Expected**
- Balance, transactions, NFTs and tokens agree between Spyglass (web) and the Core CLI (desktop). A difference in pending transactions that resolves within 2 minutes is acceptable; any lasting difference is a failure.

**Cleanup:** Log out of the second profile and close it.

## Bitcoin

### TC-XP-004 · Send BTC from web to macOS
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes · Phase: cross-platform · Needs BTC confirmations

**Preconditions:** Both lanes' BTC accounts funded.

**Steps**
1. On web, send 0.00002 BTC to `macos:TEST_BTC_ADDRESS` as in TC-SEND-010, with the lowest fee preset.
2. On macOS, open the BTC account and wait up to 60 minutes, checking every 5 minutes, for the incoming transaction to confirm.

**Expected**
- The web history shows the send immediately; the desktop shows the incoming BTC after it confirms, with the same transaction id, and the desktop BTC balance rises by 0.00002.

**Cleanup:** none.

### TC-XP-005 · Send BTC from macOS to web
**Platforms:** macOS, Web · **Priority:** P1 · **Moves funds:** yes · Phase: cross-platform · Needs BTC confirmations

**Steps**
1. On macOS, send 0.00002 BTC to `web:TEST_BTC_ADDRESS` as in TC-SEND-009.
2. On web, wait up to 60 minutes, checking every 5 minutes, for the incoming transaction in the BTC history.

**Expected**
- The same transaction id appears on both sides; the web BTC balance rises by 0.00002 after confirmation.

**Cleanup:** none.

## vBTC

### TC-XP-006 · Transfer vBTC from web to macOS
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes · Phase: cross-platform

**Preconditions:** The web lane's funded V2 contract (created in TC-BTC-023) holds at least 0.0001 vBTC for `web:A`.

**Steps**
1. On web, transfer 0.00002 vBTC on that contract to `macos:TEST_VFX_A_ADDRESS` as in TC-BTC-033.
2. On macOS, open vBTC Tokens (`tap-key nav:vbtc_tokens`) and wait up to 3 minutes, refreshing every 30 seconds, for the contract to appear.
3. Open it and read the balance and the owner.

**Expected**
- The desktop lists the contract as received, not owned: the owner is `web:TEST_VFX_A_ADDRESS`, the balance is 0.00002, and owner-only actions are absent (see TC-BTC-045).
- The web contract's balance for `web:A` drops by 0.00002.

**Cleanup:** none.

### TC-XP-007 · Transfer vBTC from macOS to web
**Platforms:** macOS, Web · **Priority:** P0 · **Moves funds:** yes · Phase: cross-platform

**Preconditions:** The macOS lane's funded V2 contract (created in TC-BTC-022) holds at least 0.0001 vBTC for `macos:A`.

**Steps**
1. On macOS, transfer 0.00002 vBTC on that contract to `web:TEST_VFX_A_ADDRESS` as in TC-BTC-032.
2. On web, open vBTC Tokens and wait up to 3 minutes, refreshing every 30 seconds, for the contract.

**Expected**
- The web wallet lists the received contract with owner `macos:TEST_VFX_A_ADDRESS` and balance 0.00002, without owner-only actions.

**Cleanup:** none.

### TC-XP-008 · Forward received vBTC back to its owner
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes · Phase: cross-platform

**Preconditions:** TC-XP-006 and TC-XP-007 passed.

**Steps**
1. On macOS, on the contract received in TC-XP-006, transfer 0.00001 vBTC back to `web:TEST_VFX_A_ADDRESS`.
2. On web, on the contract received in TC-XP-007, transfer 0.00001 vBTC back to `macos:TEST_VFX_A_ADDRESS`.
3. Wait up to 3 minutes and read all four balances.

**Expected**
- Each forward succeeds and moves vBTC from the receiving account, not from the contract owner. On macOS this is the path of the suspected bug in TC-BTC-046 (desktop transfer sending from the owner address); if the desktop reports `Account not found` or the owner's balance drops instead of `macos:A`'s received balance, record a failure that references TC-BTC-046.
- Received balances drop by 0.00001 each; the owners' balances rise by 0.00001 each.

**Cleanup:** none.

### TC-XP-009 · Bulk vBTC transfer across platforms
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes · Phase: cross-platform

**Preconditions:** `web:A` holds vBTC on at least two V2 contracts (its own from TC-BTC-023 and one received in TC-XP-007).

**Steps**
1. On web, run a Bulk vBTC Transfer of an amount larger than any single contract balance to `macos:TEST_VFX_A_ADDRESS`, as in the bulk transfer cases in `04-btc-vbtc.md`.
2. On macOS, wait up to 3 minutes and read the received contracts.

**Expected**
- The allocation spans at least two contracts, largest balance first, and the desktop shows the received amounts per contract summing to the total sent.

**Cleanup:** none.

### TC-XP-010 · Withdraw received vBTC to Bitcoin on the other platform
**Platforms:** Web · **Priority:** P1 · **Moves funds:** yes · Phase: cross-platform · Needs BTC confirmations

**Preconditions:** `web:A` holds vBTC received from the macOS lane (TC-XP-007).

**Steps**
1. On web, withdraw the received vBTC to `web:TEST_BTC_ADDRESS` as in TC-BTC-044.
2. Wait for the FROST signing to finish and for the BTC transaction to confirm (up to 60 minutes).

**Expected**
- The withdrawal completes on a contract owned by the macOS lane, and the BTC arrives at the web lane's BTC address.

**Cleanup:** none.

## NFTs

### TC-XP-011 · Transfer an NFT from macOS to web, then fetch its assets
**Platforms:** macOS, Web · **Priority:** P0 · **Moves funds:** yes · Phase: cross-platform

**Preconditions:** A minted NFT owned by `macos:A`, not listed. The desktop app stays open for the whole case.

**Steps**
1. On macOS, transfer the NFT to `web:TEST_VFX_A_ADDRESS` as in TC-SC-043.
2. On web, open NFTs and wait up to 3 minutes, pressing `Refresh` every 30 seconds, for the NFT.
3. Open it. If it shows `NFT assets have not been transferred to the VFX Web Wallet.`, run TC-SC-045 (`Transfer Now`).

**Expected**
- The NFT appears in `web:A`'s `My NFTs` with owner `web:TEST_VFX_A_ADDRESS` and minter `macos:TEST_VFX_A_ADDRESS`.
- After `Transfer Now`, the primary asset renders within 5 minutes.
- The desktop no longer lists the NFT under My NFTs.

**Cleanup:** none.

### TC-XP-012 · Transfer an NFT from web to macOS
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes · Phase: cross-platform

**Preconditions:** A minted NFT owned by `web:A`, not listed.

**Steps**
1. On web, transfer the NFT to `macos:TEST_VFX_A_ADDRESS` as in TC-SC-043.
2. On macOS, open NFTs (`tap-key nav:nfts`) and wait up to 3 minutes, refreshing every 30 seconds.
3. Open the NFT and check its media.

**Expected**
- The NFT appears on the desktop with owner `macos:TEST_VFX_A_ADDRESS`, and its media is fetched into the isolated assets folder so the primary asset renders (see TC-SC-032 for where assets land). If the media is missing, record the message shown and whether Sync Media recovers it.

**Cleanup:** none.

## Fungible tokens

### TC-XP-013 · Transfer tokens between platforms in both directions
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes · Phase: cross-platform

**Preconditions:** `web:A` owns token T1 from the web lane and `macos:A` owns token T1 from the macOS lane, each with a balance of at least 10.

**Steps**
1. On web, transfer 5 of the web lane's T1 to `macos:TEST_VFX_A_ADDRESS` as in TC-TOKEN-016.
2. On macOS, transfer 5 of the macOS lane's T1 to `web:TEST_VFX_A_ADDRESS`.
3. Wait up to 2 minutes and read the token lists on both platforms.

**Expected**
- Each platform lists the other lane's token as a holder (not owner) with balance 5, and the senders' balances drop by 5.
- The All My Tokens screen on each platform includes the received token.

**Cleanup:** none.

## Domains

### TC-XP-014 · Send VFX to the other platform's domain
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes · Phase: cross-platform

**Preconditions:** Each lane owns a confirmed VFX domain.

**Steps**
1. On web, send 1 VFX to the macOS lane's domain (`<name>.vfx`) as in TC-ADNR-012.
2. On macOS, send 1 VFX to the web lane's domain.
3. Wait up to 2 minutes and check both receiving balances.

**Expected**
- Each domain resolves to the other lane's account A and the 1 VFX arrives there. If a platform does not resolve domains when sending (see the open question in TC-SEND-023), record the refusal text.

**Cleanup:** none.

### TC-XP-015 · Transfer a domain from web to macOS
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes · Phase: cross-platform

**Preconditions:** `web:A` owns a confirmed VFX domain not used by TC-XP-014.

**Steps**
1. On web, transfer the domain to `macos:TEST_VFX_A_ADDRESS` as in TC-ADNR-015.
2. On macOS, open Domains (`tap-key nav:domains`) and wait up to 3 minutes for it.

**Expected**
- The desktop lists the domain under `macos:A` and shows it on the account label; the web no longer lists it.

**Cleanup:** none.

## Vault accounts

### TC-XP-016 · Restore each lane's vault on the other platform
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · Phase: cross-platform

**Preconditions:** Both lanes' restore codes are in `$TMPDIR/vfx-run-<run id>/`.

**Steps**
1. Run TC-VAULT-026 on web with the macOS lane's vault restore code.
2. Run TC-VAULT-027 on macOS with the web lane's vault restore code.
3. Delete `$TMPDIR/vfx-run-<run id>/`.

**Expected**
- As in TC-VAULT-026 and TC-VAULT-027: each platform shows the other lane's vault address and balance.
- The folder no longer exists after step 3.

**Cleanup:** Log out of any account signed in only for this case.
