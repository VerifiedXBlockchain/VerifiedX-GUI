# 04 · BTC and vBTC

This area covers Bitcoin accounts and vBTC (tokenized Bitcoin, V2 contracts) on both targets: importing, creating and listing BTC accounts, balances and UTXOs, BTC sends with the fee-rate presets and picker, replace-by-fee and rebroadcast, BTC transaction history, vBTC contract creation through the MPC (FROST DKG) ceremony, funding the deposit address, the vBTC token list and detail screens, single-token transfers, the multi-contract ("Bulk vBTC Transfer") send, withdrawals back to Bitcoin through FROST signing including resume and cancellation, tokens received from another holder, and the media check used by the web ownership transfer. Desktop code lives in `lib/features/btc` and talks to the local Core CLI (`/btcapi/BTCV2`, `/vbtcapi/vbtc`); web code lives in `lib/features/btc_web`, `lib/features/btc/screens/web_*` and `WebTokenActionsManager`, and talks to Spyglass (ceremony and withdrawal proxies, `/raw/*` for plain transfers). Bridging vBTC to Base is covered in `12-payments-faucet-keygen.md`; BTC domains are covered in `07-domains.md`.

## Area preconditions

- Environment set up as in `README.md`: web automation build at `http://localhost:42069/?automation=1`, macOS Flutter Driver build with its isolated data folder and a synced testnet chain.
- Web session: logged in with `TEST_VFX_A_PRIVKEY` (VFX Private Key tile), with the BTC account added in TC-BTC-002. macOS: `TEST_VFX_A_PRIVKEY` imported and selected as the current wallet, and the BTC account imported in TC-BTC-001. Cases that act as the second party say so and use `TEST_VFX_B_PRIVKEY`.
- Balances: account A holds at least 5 testnet VFX (every vBTC action pays a VFX fee and the web actions refuse below 0.001 VFX); the `TEST_BTC_ADDRESS` account holds at least 0.0005 testnet BTC. Suggested amounts in this file are deliberately small (0.00002 BTC sends, 0.0001 BTC funding, 0.00002 vBTC transfers) so one funded BTC account covers a full pass.
- Two funded V2 contracts owned by the lane's account A are needed for the multi-transfer path. Each lane creates both in its Bitcoin kickoff (see "Lane schedule" in `README.md`): the macOS lane runs TC-BTC-022 twice and funds both with TC-BTC-026, the web lane runs TC-BTC-023 twice and funds both with TC-BTC-027. Contract names use the run id, the lane and a number, for example `qa-20261001a-m1` and `qa-20261001a-m2`.
- Scheduling. The contract creation, the deposits and the BTC sends in this file are started at the very beginning of a lane and checked later; the transfer cases run once the deposits have confirmed; the withdrawals are started after the transfers, and their payouts are checked at the end of the lane. The order of cases in this file is not the order they run in.
- Chain timing. VFX blocks land about every 12 seconds; allow up to 2 minutes for a VFX transaction to confirm. Bitcoin testnet4 blocks are irregular; allow up to 60 minutes for a BTC confirmation even at the app's floored testnet fee rates (5 to 10 sat/vB). The CLI rescans vBTC deposit addresses about every 5 minutes after a BTC confirmation. Cases marked **Needs BTC confirmations** should be started early in a run and checked later, so their waits overlap.
- Debug builds and pending BTC transactions: `BtcTransactionListTile` forces every transaction to show as confirmed when `kDebugMode && Env.isTestNet`, which is true for both `make run_web_automation` and `make run_macos_driver`. On those builds the BTC Pending badge, Replace By Fee and Rebroadcast TX never appear on desktop. Cases that need them say so and run on a testnet profile or release build instead.
- Dialog buttons without keys are tapped by text on macOS (`tap-text Yes`). Where the same text is also on screen (for example `Send` in the side nav) and `drive.dart` reports "Too many elements", record the step as blocked with that note: it is an automation gap, not a product failure.
- Bulk vBTC transfer: `BULK_VBTC_TRANSFER_ENABLED` is now `true` on every network (the comment in `app_constants.dart` says the multi-contract transfer went live on mainnet at block 7,281,000 on 2026-09-11). Earlier notes describe it as testnet-only; this suite still only sends on testnet.

## BTC accounts

### TC-BTC-001 · Import a BTC account from its private key (macOS)
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Chain synced. Account A selected. `TEST_BTC_ADDRESS` not yet imported in this data folder.

**Steps**
1. On the dashboard BTC card, tap `New Address`: `tap-text "New\nAddress"` on the BTC card (the VFX card has the same label, so if it reports "Too many elements", open the side-nav account selector, switch the list to BTC and tap `Add Account` instead).
2. In the `Add BTC Account` dialog tap `Import`: `tap-text Import`.
3. In `Import BTC Private Key`, tap the `Private Key` field and `type` the value of `TEST_BTC_WIF`, then `tap-text Import`.
4. Hover the `BTC Online` item in the status bar (or `get-text text:"BTC Online"`) to read the next sync time, and wait until that time, up to 15 minutes, for the balance to load.

**Expected**
- The dialog shows the body `Paste in your BTC private key to import your account.`
- A toast reads `Private Key Imported! Please wait until <time> for the balance to sync.` (or `Private Key Imported!` when the node has no sync info yet).
- After the next sync, the dashboard BTC card shows a non-zero `<n> BTC` heading and `1 Account` (or the new count), and the account appears in the account list with `[<balance> BTC]`.

**Cleanup:** none (the account is reused by later cases).

### TC-BTC-002 · Add a BTC account from a WIF key (web)
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Logged in as account A on web with no BTC account attached to the session.

**Steps**
1. Open the account selector in the top bar (the menu listing the VFX, Vault and BTC entries) and choose `Add BTC Account`.
2. In the sheet `Add BTC Account (Segwit)`, choose `Import WIF Private Key` (`fltA11y.tap("Import WIF Private Key")` if it reads as text).
3. In `Import BTC WIF Private Key`, type the value of `TEST_BTC_WIF` into `textbox "WIF Private Key"` and click `button "Import"`.
4. Select the BTC entry in the account selector and wait up to 90 seconds for the balance to load.

**Expected**
- A toast reads `BTC Account Imported`.
- The account selector now lists `TEST_BTC_ADDRESS` in BTC orange instead of `Add BTC Account`.
- With BTC selected, the wallet details show `<balance> BTC`; its tooltip lists `Balance`, `Sent` and `Received`.

**Cleanup:** none.

### TC-BTC-003 · Import validation (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As TC-BTC-001 / TC-BTC-002, with no BTC account attached on web (log out and back in as A first).

**Steps**
1. Web: open `Add BTC Account` > `Import WIF Private Key` and click `button "Import"` with the field empty. macOS: not applicable (the desktop dialog has no validator); continue at step 2.
2. Enter a malformed key such as `notakey123` and submit. Web: `button "Import"`. macOS: the `Import BTC Private Key` dialog, `tap-text Import`.

**Expected**
- Step 1 (web): the field shows `WIF Private Key is required.` and the dialog stays open.
- Step 2: an error toast reads `A problem occurred.` and no account is added.

**Cleanup:** re-add the real account (TC-BTC-002) on web.

### TC-BTC-004 · Create a new BTC account (macOS)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Chain synced. Wallet password set if encryption is enabled.

**Steps**
1. Open `Add BTC Account` as in TC-BTC-001 step 1 and `tap-text Create`.
2. In the `BTC Account Created` dialog, `tap-label "Copy private key"`.
3. `tap-text Done`.

**Expected**
- The dialog reads `Here are your BTC account details. Please ensure to back up your private key in a safe place.` with an `Address` field (a `tb1` address) and a `Private Key` field.
- The copy button shows `Private Key copied to clipboard`.
- The account count on the BTC card increases by one. Record this address as the run's second BTC address; TC-BTC-010 and TC-BTC-011 send to it.

**Cleanup:** none. Never paste the private key into results.

### TC-BTC-005 · Generate a BTC keypair (web)
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in on web as account B (`TEST_VFX_B_PRIVKEY`) with no BTC account attached.

**Steps**
1. Open the account selector and choose `Add BTC Account`.
2. Choose `Generate Keypair` (subtitle `Generate a random BTC keypair.`).
3. Close the keys dialog that follows.

**Expected**
- A keys dialog shows the new BTC address, its private key, WIF and mnemonic.
- The account selector lists the new BTC address in place of `Add BTC Account`.

**Cleanup:** log out of account B.

### TC-BTC-006 · BTC account list, selection and copy (macOS)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** At least one BTC account in the wallet (TC-BTC-001).

**Steps**
1. On the BTC card tap `View Addresses` (`tap-text "View\nAddresses"`); the `My Accounts` screen opens on the BTC list.
2. Tap a BTC account row that is not selected.
3. Tap its copy icon: `tap-label "Copy address"` (use the one in the BTC row; if several match, record the automation gap).
4. Tap `Reveal Private Key` on the account imported in TC-BTC-001.

**Expected**
- Each row shows the label, `[<balance> BTC]` and the address; the selected row has a checked box.
- Tapping a row selects it; the send form and receive screen then use that address.
- Copy shows `Address copied to clipboard`.
- For an imported account, reveal shows the toast `The node only shares a Bitcoin private key when the account is created. Use the backup you saved at that time.` For an account created in TC-BTC-004, it shows the key in a `Private Key` dialog with a `Copy private key` button.

**Cleanup:** none.

### TC-BTC-007 · BTC connection status and balance card (macOS)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Chain synced, BTC account imported.

**Steps**
1. Read the status bar BTC item: `get-text text:"BTC Online"` (or `BTC Loading` / `BTC Offline`).
2. Read the dashboard BTC card heading.
3. On the BTC card tap the view-all-transactions control, or open Transactions (`tap-key nav:transactions`) and choose `BTC` in the segmented control.

**Expected**
- The status item reads `BTC Online` once ElectrumX is connected; its tooltip shows `Last Sync:` and `Next Sync:` times.
- The BTC card heading is `<sum of BTC account balances> BTC` and matches the account list.
- The Transactions screen title reads `BTC Transactions` with tabs `Transactions` and `Inputs`.

**Cleanup:** none.

### TC-BTC-008 · UTXO list (macOS)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** BTC account with at least one received transaction.

**Steps**
1. Open Transactions, choose `BTC`, then `tap-text Inputs`.

**Expected**
- Each tile shows `Address: <address>` and `TX ID: <hash>` / `Amount:<amount>`, with a `Used` or `Unused` badge.
- Unused UTXOs add up to the account balance shown on the card (allowing for unconfirmed spends).
- With no BTC accounts, the tab reads `No UTXOs`.

**Cleanup:** none.

### TC-BTC-009 · BTC receive address (both platforms)
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** BTC account selected.

**Steps**
1. Open Receive. Web: `button "Receive"` in the side nav with the BTC account selected. macOS: `tap-key nav:receive`, then switch the currency to BTC.

**Expected**
- The title reads `Receive BTC`; macOS shows `Your Selected BTC Address` with the selected account's address; web shows the session BTC address.

**Cleanup:** none.

## BTC send

### TC-BTC-010 · Send BTC with a fee preset (macOS)
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes · **Needs BTC confirmations**

**Preconditions:** `TEST_BTC_ADDRESS` selected as the BTC account with at least 0.0001 BTC. The second BTC address from TC-BTC-004 recorded.

**Steps**
1. `tap-key nav:send`. Tap the sender address at the top of the form and choose the BTC account (`TEST_BTC_ADDRESS`) from the menu.
2. `tap-key send:address`, `type` the second BTC address.
3. `tap-key send:amount`, `type 0.00002`.
4. Tap the `Fee Rate:` preset menu (it shows `Economy` by default) and choose `Hour` (`tap-text Hour`).
5. `tap-key send:submit`.
6. In `Please Confirm` check the body, then `tap-text Send` (see the area note on text collisions).
7. Wait up to 60 minutes for the transaction to show a `Confirmed` badge in BTC Transactions (on the debug driver build it shows as confirmed at once; verify on mempool.space via the tile's `Open in BTC Explorer`).

**Expected**
- The fee line under the preset reads `Fee Rate: <n> SATS /byte [<btc> BTC /byte]` and `Fee Estimate: ~<n*140> SATS [~<btc> BTC]`, and changes when the preset changes. Presets offered: `Minimum`, `Economy`, `Hour`, `Half Hour`, `Fastest`, `Custom`. On testnet the Hour value is at least 5.
- The confirm body reads `Sending:` / `0.00002 BTC` / `To:` / `<address>` / `From:` / `TEST_BTC_ADDRESS` / `Fee:` / `<fee> BTC`.
- After sending: toast `0.00002 BTC has been sent to <address>.` and a `Transaction Broadcasted` dialog with a `Transaction Hash` field, a `Copy transaction hash` button and `Open in BTC Explorer`.
- The transaction appears in BTC Transactions; once confirmed, the second account's balance rises by 0.00002 BTC after its next sync.

**Cleanup:** none.

### TC-BTC-011 · Send BTC with the fee-rate picker (web)
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes · **Needs BTC confirmations**

**Preconditions:** Web session with the BTC account from TC-BTC-002 holding at least 0.0001 BTC. The second BTC address from TC-BTC-004 recorded.

**Steps**
1. Select the BTC account in the top-bar account selector, then click `button "Send"` in the side nav. The title reads `Send BTC`.
2. Type the second BTC address into the recipient field and `0.00002` into the amount field.
3. Click `button "Send"` in the form.
4. In the `Fee Rate` dialog confirm that `Economy` is ticked, tick `Half Hour`, then click `button "Continue"`.
5. In `Please Confirm` click `button "Send"`.
6. Wait up to 60 minutes and check the BTC tab of Transactions.

**Expected**
- The picker lists `Minimum`, `Economy`, `Hour`, `Half Hour`, `Fastest` each with `<n> SATS | <btc> BTC`, plus `Custom`.
- The confirm body reads `Sending:` / `0.00002 BTC` / `To:` / `<address>` / `From:` / `<web BTC address>` / `FeeRate:` / `<Half Hour value> SATS`, and the fee rate equals the Half Hour row (not the Fastest row).
- Toast `0.00002 BTC has been sent to <address>.`, then the `Transaction Broadcasted` dialog.
- The transaction is listed under Transactions > `BTC` as `Pending`, then `Confirmed` within 60 minutes; the balance refreshes about 2 seconds after sending and again once confirmed.

**Cleanup:** none.

### TC-BTC-012 · Custom fee rate (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** BTC account selected on the Send screen.

**Steps**
1. macOS: in the send form choose `Custom` in the `Fee Rate:` menu; a field with hint `Fee rate in satoshis` appears. Leave it empty or type `0`, fill a valid address and amount, `tap-key send:submit`. Web: submit the form to open the picker, tick `Custom`, type `0`.
2. macOS: `type 12` into the custom field. Web: replace the value with `12`.
3. Cancel before sending. macOS: `tap-text Cancel` in `Please Confirm`. Web: `button "Cancel"` in the picker.

**Expected**
- macOS step 1: the field shows `Invalid Fee Rate. Must be atleast 1 satoshi.` and the form does not submit.
- macOS step 2: the helper line reads `Fee Rate: 12 SATS /byte [0.000000120 BTC /byte]` / `Fee Estimate: 1680 SATS [~0.000016800 BTC]`.
- Web step 2: the label under the field reads `12 SATS /byte | 0.000000120 BTC /byte`.
- **Open question:** on web, Continue with `Custom` and a 0 or empty value returns 0 without running the field validator. Confirm whether a 0 sat/vB send is expected to be rejected by the backend, and with what message.

**Cleanup:** none.

### TC-BTC-013 · BTC send validation (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** BTC account selected on the Send screen.

**Steps**
1. Leave the recipient empty and submit.
2. Enter a valid recipient and amount `0.000001` and submit.
3. Enter an amount larger than the BTC balance and submit.

**Expected**
- Step 1: the recipient field shows `BTC Address required`.
- Step 2: `The minimum transaction amount is 1e-05 BTC` (macOS shows it on the amount field; web shows it on the field when balance data is loaded).
- Step 3: `Not enough balance in BTC account` on the amount field (macOS includes the fee in the check). On web, if the field check passes, the submit toast reads `Not enough balance`.
- **Open question:** the minimum is printed from the Dart double `0.00001`, which renders as `1e-05`. Confirm whether that wording is acceptable or should read `0.00001`.

**Cleanup:** none.

### TC-BTC-014 · Replace by fee, including the high-fee confirmation (macOS)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** yes · **Needs BTC confirmations**

**Preconditions:** A testnet profile or release macOS build (not the debug driver build, see Area preconditions). A BTC send from this node broadcast less than 20 minutes ago and still unconfirmed, ideally sent at the `Minimum` preset so it stays in the mempool.

**Steps**
1. Open Transactions > `BTC` > `Transactions`. On the pending tile, click `Replace By Fee`.
2. In `Fee Rate`, type `abc` (the field only accepts digits), then a rate lower than the original, and submit.
3. Repeat with a rate a few sat/vB above the original and submit.
4. For a small send, repeat with a very high rate (for example `500`) so the total fee exceeds 10% of the amount.
5. In `High Fee`, click `Cancel`; repeat and click `Replace anyway`.

**Expected**
- The pending tile shows a `Pending` badge, `Replace By Fee` and `Rebroadcast TX`; its date reads `Date: Pending`.
- The prompt body reads `Input your desired fee rate (SATS /byte) for this transaction.` with the field `Fee Rate (SATS /byte)`.
- A rate that is not higher is refused with the node's message in an error toast.
- A valid replacement shows `Replaced by fee (<rate> SATS /byte) TX sent. Hash: <hash>` and a log entry with the hash.
- Step 4 opens `High Fee` with `<node reason> Replace the transaction anyway?`; `Cancel` sends nothing, `Replace anyway` sends the replacement.
- The original tile turns into a replaced entry and the replacement confirms within 60 minutes.

**Cleanup:** none.

### TC-BTC-015 · Rebroadcast a pending BTC transaction (macOS)
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** As TC-BTC-014 (profile or release build, a pending BTC transaction younger than 20 minutes).

**Steps**
1. On the pending tile click `Rebroadcast TX`.
2. In `Rebroadcast TX` (`Are you sure you want to rebroadcast this transaction?`) click `Yes`.

**Expected**
- Toast `Rebroadcasted TX. (<hash>)` and a matching log entry.
- Neither button is shown on a confirmed transaction or one older than 20 minutes.

**Cleanup:** none.

## BTC transaction history

### TC-BTC-016 · BTC transaction list and detail (macOS)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** BTC account with at least one send and one receive.

**Steps**
1. Open Transactions > `BTC` > `Transactions`.
2. On a tile, `tap-label "Copy transaction hash"`.
3. `tap-label "Show details"` on the same tile, then `tap-label "Hide details"`.
4. `tap-label "Open in BTC Explorer"`.

**Expected**
- Tiles show `Hash: <hash>`, `Amount: <n> BTC`, `Type: <type>`, `To:`, `From:`, `Date:` and a `Confirmed` badge whose tooltip is `Block <height>`.
- Copy shows `Hash copied to clipboard`.
- Details show `Fee Rate` / `<n> SATS`, `Fee` / `<n> BTC`, `Signature` with a `Copy signature` button, and `UTXOs:` with the UTXO tiles.
- The explorer link opens `https://mempool.space/testnet4/tx/<hash>` on testnet (`https://mempool.space/tx/<hash>` on mainnet).

**Cleanup:** none.

### TC-BTC-017 · BTC transaction list (web)
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Web session with a BTC account that has history.

**Steps**
1. Click `button "Transactions"` in the side nav, then the `BTC` tab.
2. On a tile, click the show-details control (`Show details`) and read the inputs and outputs.
3. Click the `TX ID:` link.

**Expected**
- Each tile shows `<amount> BTC` (or `vBTC` with the vBTC icon when it touches a vBTC deposit address), `TX ID: <txid>`, and cards for `Status` (`Confirmed` or `Pending`), `Fee` (`<n> SATS | <n> BTC`), `Block Time` and `Block Height`.
- Details list `Inputs:` and `Outputs:` with an address, a copy button (`Copy address`) and the value in BTC.
- The link opens the transaction on mempool.space (testnet4 path on testnet).
- With no history the tab reads `No Transactions found for <address>.`

**Cleanup:** none.

### TC-BTC-018 · History with an OP_RETURN output (web)
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** A BTC address whose history includes a transaction with an OP_RETURN output.

**Steps**
1. Open Transactions > `BTC` with that address as the session BTC account.
2. Expand the transaction that carries the OP_RETURN output.
3. Click the copy button next to the OP_RETURN output.

**Expected**
- The whole list renders; the OP_RETURN transaction does not empty or break it (`BtcWebVout.scriptpubkeyAddress` is nullable for this case).
- The OP_RETURN output row shows its script type (`op_return`) in place of an address, with value `0.0 BTC`.
- Copying that row does nothing and shows no error.
- **Open question:** which testnet address with an OP_RETURN transaction should the run use? `TEST_BTC_ADDRESS` only has one if a flow in this suite produced one. Confirm whether a vBTC V2 withdrawal or funding transaction carries OP_RETURN, or name a fixed address to import read-only.
- **Open question:** the desktop list comes from the CLI (`GetBitcoinTXList`); confirm whether desktop needs the same check.

**Cleanup:** none.

## vBTC tokenization

### TC-BTC-019 · vBTC Tokens screen entry points (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Logged in as account A.

**Steps**
1. Open vBTC Tokens. Web: `button "vBTC Tokens"` in the side nav. macOS: `tap-key nav:vbtc_tokens`.
2. Click `What is vBTC?`, read the dialog, close it.

**Expected**
- Header `Tokenized Bitcoin (vBTC)` with `1 vBTC = 1 BTC`, the buttons `Bulk vBTC Transfer` and `Create Verified BTC Token`, and `Use Wizard` only while the token list is empty.
- The info dialog is titled `vBTC` and starts `This wallet provides a specific smart contract that enables tokenizing actual Bitcoin!` and ends `Welcome to true on-chain utility for your BTC!`
- With no tokens, macOS shows `No Tokenized Bitcoin found in account.`; web shows an empty list.

**Cleanup:** none.

### TC-BTC-020 · Create requires a funded VFX account (macOS)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** A wallet in which no non-Vault VFX account holds more than 0.001 VFX (for example a fresh data folder with only a new, empty VFX account), chain synced.

**Steps**
1. Open vBTC Tokens and tap `Create Verified BTC Token`.
2. In `VFX Address with Balance Required`, tap `No`.
3. Tap `Create Verified BTC Token` again and tap `Yes`.

**Expected**
- The dialog body reads `A VFX address with a balance is required to proceed. Would you like to set this up now?`
- `No` closes it with nothing else happening.
- `Yes` opens the `vBTC Onboard` wizard at `Step 1/6: Create VFX Account`.
- With the chain not synced, the button shows the not-synced guard toast instead.

**Cleanup:** leave the wizard with the back button (`tap-label Back`) and `Yes` in `Exit vBTC Onboarding?`.

### TC-BTC-021 · Create validation (web)
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Web session whose VFX account holds less than 0.001 VFX (log in as a fresh keypair, or as account B if it is empty).

**Steps**
1. Open vBTC Tokens, click `button "Create Verified BTC Token"`.
2. On `Tokenize BTC (vBTC)`, click `button "Create vBTC Token"`.

**Expected**
- Toast `A VFX account with a balance is required.`; no ceremony dialog opens.

**Cleanup:** log back in as account A.

### TC-BTC-022 · Create a vBTC contract through the MPC ceremony (macOS)
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Account A selected with at least 1 VFX, chain synced. No other ceremony running for account A.

**Steps**
1. Open vBTC Tokens and tap `Create Verified BTC Token`; `Tokenize BTC (vBTC)` opens.
2. Fill `Token Name (Optional)` with `qa-<runid>-mac`, `Token Description (Optional)` with `release test`, and leave `Token Ticker (Optional)` empty (hint `vBTC`).
3. Tap `Mint & Deploy`. In `Create vBTC Token?` check the body; when the wallet has several funded accounts, make sure the `VFX Address:` under `Change Account:` is account A (pick it from that menu if not). Then tap `Mint & Deploy` in the dialog.
4. Watch the `MPC Ceremony in Progress` dialog; close it with `tap-label Close`, then reopen it with `View Progress` on the form.
5. Wait up to 5 minutes for `Ceremony Completed`, then up to 2 minutes for `Contract Created`.
6. Tap `Done`.

**Expected**
- The confirm body reads `This will start an MPC ceremony to create your vBTC token.`, `A network fee of ~0.000028 VFX is required.`, the VFX account line and `Continue?`.
- The progress dialog shows the steps `Initiated`, `Validating`, `Round 1`, `Round 2`, `Round 3`, `Completed`, a progress bar with `<n>% complete`, `Validators: <n> (threshold: <n>)` and `You can dismiss this dialog. The ceremony will continue in the background.` There is no cancel control.
- Closing and reopening does not interrupt the ceremony.
- On completion: toast `MPC ceremony completed successfully.`, the dialog shows `Deposit Address:` with a `tb1p` Taproot address, then `Creating vBTC contract on-chain...`, then `vBTC contract created successfully!` with `Transaction Hash:` and a toast `vBTC contract created. Hash: <hash>`.
- `Done` closes the form; within 2 minutes the token `qa-<runid>-mac` appears in the vBTC list with `0.0 vBTC`.

**Cleanup:** none (funded in TC-BTC-026).

### TC-BTC-023 · Create a vBTC contract through the MPC ceremony (web)
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Logged in as account A with at least 1 VFX.

**Steps**
1. Open vBTC Tokens and click `button "Create Verified BTC Token"`.
2. Type `qa-<runid>-web` into `textbox "Token Name (Optional)"`, leave the other fields empty.
3. Click `button "Create vBTC Token"`.
4. Watch the ceremony dialog; wait up to 5 minutes for the ceremony and up to 2 minutes for creation.
5. Click `button "Done"`.

**Expected**
- The dialog cannot be dismissed by clicking outside it and shows no close button while running.
- It moves through `Starting MPC Ceremony` (`Initiating MPC ceremony...`, `This starts the distributed key generation process.`), `MPC Ceremony in Progress` (`<n>% complete`, `Validators are generating threshold signing keys. This typically takes 30-90 seconds.`), `Creating Contract` (`Creating vBTC contract on-chain...`, `This will be confirmed once indexed by the explorer.`) to `Token Created`.
- `Token Created` shows `vBTC token created successfully!`, `Transaction Hash:` with a `Copy transaction hash` button (toast `Copied to clipboard`), `Smart Contract ID:` and `The token will appear in your list once indexed (typically a few seconds).`
- Within 2 minutes the token appears in the web vBTC list as `qa-<runid>-web (Owner)` with `0.0 vBTC`.

**Cleanup:** none (funded in TC-BTC-027).

### TC-BTC-024 · Ceremony failure and retry (both platforms)
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** A way to make the ceremony fail, for example starting a second ceremony for account A while TC-BTC-022's ceremony is still running, or running while the validator set is below quorum.

**Steps**
1. Start a ceremony as in TC-BTC-022 or TC-BTC-023 while the failing condition holds.
2. On the failure view click `Retry` (web also offers `Dismiss`).

**Expected**
- macOS: the dialog title becomes `Ceremony Failed` with the node's message (for a second ceremony: `You already have an active MPC ceremony in progress. Complete or cancel it before starting a new one.`, shown as a toast `Failed to initiate ceremony.` if the node gives no message); other failure texts are `Ceremony failed. Please try again.`, `Ceremony timed out. Please try again.` (after 5 minutes) and `Lost connection while monitoring ceremony. Please try again.`
- Web: the dialog title becomes `Error` with the server message or `Failed to initiate MPC ceremony.` / `MPC ceremony failed.`, and `Dismiss` / `Retry` buttons plus a close button.
- `Retry` resets the state; no contract is created by the failed attempt.
- **Open question:** confirm a reliable way to force a ceremony failure on testnet for this case.

**Cleanup:** none.

### TC-BTC-025 · Tokenization wizard (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes · **Needs BTC confirmations**

**Preconditions:** Account A with at least 1 VFX and the BTC account with balance, so the wizard skips the funding steps. The vBTC list is empty for the session, otherwise `Use Wizard` is hidden (run this case in a fresh data folder on macOS, or with an account that owns no vBTC on web). **Open question:** confirm which account to use for a wizard run when account A already owns contracts.

**Steps**
1. Open vBTC Tokens and click `Use Wizard`.
2. macOS: at `Step 1/6: Create VFX Account`, pick account A under `Or use one of your existing VFX Accounts:`. At the BTC step pick the BTC account under `Or use one of your existing BTC Accounts:`. Web: the wizard starts at the VFX or BTC step according to the session balances.
3. At `Tokenized vBTC` (`Time to tokenize a vBTC token. The following fields are all optional!`), name the token `qa-<runid>-wiz` and create it as in TC-BTC-022 (macOS) or TC-BTC-023 (web).
4. At `Transfer BTC to vBTC Token`, type `0.00005` into `Amount to Send (BTC)`, leave the fee preset at `Economy`, click `Initiate Transfer`.
5. Wait up to 60 minutes, with the wizard open, for the final screen.
6. Click `View Token`.

**Expected**
- The step header reads `Step <n>/6: <step name>` with the step description; while waiting it shows `MPC ceremony and contract creation in progress.` (macOS) or `Waiting for vBTC Tokenization to compile.` (web), then `Waiting for BTC to vBTC transaction to reflect on-chain.`
- Toasts in order: `Token Deployed!`, the send result, `Transfer Complete!`.
- The final screen reads `Done!` and `Your vBTC token is ready and funded.`; `View Token` opens the detail screen with `My Balance` 0.00005 vBTC.
- The back button asks `Exit vBTC Onboarding?` / `Are you sure you want to cancel setting up your account with Tokenized Bitcoin?`

**Cleanup:** none.

### TC-BTC-026 · Fund a vBTC contract from a BTC account (macOS)
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes · **Needs BTC confirmations**

**Preconditions:** TC-BTC-022 done. The BTC account holds at least 0.0002 BTC.

**Steps**
1. Open the `qa-<runid>-mac` token detail from the vBTC list.
2. Tap `Fund`. The `Fund Token` sheet lists `Buy BTC (On-Ramp)`, each BTC account with its balance, and `Manual Send`.
3. Tap the `TEST_BTC_ADDRESS` row. In `BTC Amount` type `0.0001`, submit.
4. In the `Fee Rate` picker keep `Economy` and `tap-text Continue`.
5. In `Confirm Transaction` tap `Send`.
6. Wait up to 60 minutes for the BTC confirmation plus the next deposit scan (about 5 minutes).

**Expected**
- The confirm body reads `Sending 0.000100000 BTC from <BTC address> to <deposit address>.` followed by `Fee:` and the fee in BTC.
- Toast `0.0001 BTC has been sent to <deposit address>.` and the `Transaction Broadcasted` dialog.
- The token's `BTC Transactions` section lists the funding transaction.
- After confirmation and scan, `My Balance` and `Token Total Balance` read `0.0001 vBTC` (with a USD value when the BTC price is loaded), and the list tile shows `0.0001 vBTC`.

**Cleanup:** none.

### TC-BTC-027 · Fund a vBTC contract from the web BTC account (web)
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes · **Needs BTC confirmations**

**Preconditions:** TC-BTC-023 done. The web BTC account holds at least 0.0002 BTC.

**Steps**
1. Open the `qa-<runid>-web` token detail from the vBTC list.
2. Click `button "Fund"`. In `Fund vBTC Token`, click the BTC address row.
3. In `Amount (Balance: <n> BTC)` type `0.0001` into `textbox "Deposit amount"`, click `button "Submit"`.
4. In the `Fee Rate` picker keep `Economy`, click `button "Continue"`.
5. In `Please Confirm` click `button "Send"`.
6. Wait up to 60 minutes for the BTC confirmation and indexing.

**Expected**
- The confirm body reads `Sending:` / `0.0001 BTC` / `To:` / `<deposit address> (Token Deposit Address)` / `From:` / `<BTC address>` / `FeeRate:` / `<n> SATS`.
- Toast `0.0001 BTC has been sent to <deposit address>.` and the `Transaction Broadcasted` dialog.
- After confirmation, the detail screen's `My Balance` reads `0.0001 vBTC` (the screen refreshes every 10 seconds) and the funding transaction is listed under `Transactions:` with the vBTC icon.

**Cleanup:** none.

### TC-BTC-028 · Fund validation (web)
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** An owned token detail screen open on web.

**Steps**
1. Open `Fund` > BTC row. Enter `0` and submit.
2. Enter an amount equal to or above the BTC balance and submit.
3. With a BTC account whose balance is 0 (for example the TC-BTC-005 keypair), click the BTC row.

**Expected**
- Step 1: `Amount must be greater than 0.0 BTC`.
- Step 2: `Not enough BTC to cover this transaction + fee`.
- Step 3: `This BTC account doesn't have a balance`.
- On macOS the equivalent checks read `Amount must be greater than 0.0 BTC` and `Insufficient Balance to cover tx and fee. This account only has <n> BTC.`

**Cleanup:** none.

### TC-BTC-029 · Copy the deposit address and manual send (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** An owned V2 token detail screen open.

**Steps**
1. Click `Copy Deposit Address`.
2. Click `Fund`, then `Manual Send`.
3. macOS only: in `Fund via Manual Send`, `tap-label "Copy Address"`, then `tap-text Close`.

**Expected**
- Step 1: toast `BTC Address copied to clipboard`; the clipboard holds the token's deposit address.
- Web step 2: toast `Deposit address copied to clipboard`.
- macOS step 2: the dialog reads `Send BTC from any exchange or external wallet to the deposit address below.`, shows `Deposit Address` with the address, and `Once the BTC transaction is confirmed on-chain, your vBTC balance will update automatically.`; the copy button shows `Address copied to clipboard`.

**Cleanup:** none.

## vBTC token list and detail

### TC-BTC-030 · Token list (both platforms)
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Account A owns at least one V2 contract with a balance.

**Steps**
1. Open vBTC Tokens.
2. Click a token row.

**Expected**
- macOS: each row shows the token name, the contract's owner address (Vault addresses in purple) and `<balance> vBTC`, where the balance is the current wallet's spendable balance; a contract listed under several addresses shows `My Total Balance:` with one sub-row per address and a `Details` button.
- Web: each row shows the token image (or the vBTC placeholder), `<name> (Owner)` for owned contracts, `<balance> vBTC` and the address.
- Clicking opens the detail screen for that contract and address.

**Cleanup:** none.

### TC-BTC-031 · Owned token detail (both platforms)
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** A funded V2 contract owned by account A.

**Steps**
1. Open the token's detail screen.
2. Click the copy button next to `Smart Contract ID` (`Copy`).

**Expected**
- macOS rows: `Name`, `Description`, `Owner`, `BTC Deposit Address`, `Smart Contract ID`, `My Balance`, `Token Total Balance`; the image loads; a `BTC Transactions` section lists deposit-address transactions or `No BTC Transactions`.
- Web rows: `Name`, `Owner`, `My Balance`, `Description`, `Smart Contract ID`, `SmartContract Owner Address`, `BTC Deposit Address`, `Token Total Balance`, `FROST Group Key`, `Signing Threshold`; `Status` / `Pending Withdrawal` only while a withdrawal is open.
- Action buttons for the owner: `Copy Deposit Address`, `Fund`, `Withdraw`, `Transfer` (macOS: sheet with transfer and ownership options; web: separate `Transfer Ownership`), `Bridge to Base` (macOS), `Prove Ownership`, `Borrow/Lend`.
- Copy shows `Smart Contract ID copied to clipboard`.
- `Borrow/Lend` shows `Action Not Available Yet.`

**Cleanup:** none.

## vBTC transfer

### TC-BTC-032 · Transfer vBTC to another VFX address (macOS)
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Account A selected, holding at least 0.00005 vBTC on `qa-<runid>-mac` (TC-BTC-026 confirmed) and at least 0.001 VFX.

**Steps**
1. Open the token detail and `tap-key vbtc:transfer`.
2. In the `Transfer` sheet, `tap-text "Transfer vBTC"` (subtitle `Transfer a specific portion of the vBTC within the token to another VFX address.`).
3. `tap-key vbtc:address`, `type` the value of `TEST_VFX_B_ADDRESS`.
4. `tap-key vbtc:amount`, `type 0.00002`.
5. `tap-key vbtc:submit`.
6. In `Transfer BTC` tap `Yes`.
7. Wait up to 2 minutes for the VFX transaction to confirm.

**Expected**
- The sheet shows `Transfer vBTC`, `Your Balance: <n> vBTC` (with USD when priced), the fields `To VFX Address` and `Amount of vBTC to Send`.
- The confirm body reads `Are you sure you want to transfer 0.00002 vBTC to <address>?`
- Toast `vBTC V2 Transfer TX Broadcasted. Hash: <hash>` and a log entry.
- After confirmation, `My Balance` drops by 0.00002 and the transfer is listed in the VFX transactions.

**Cleanup:** none (account B's balance is used in TC-BTC-044 to TC-BTC-046).

### TC-BTC-033 · Transfer vBTC to another VFX address (web)
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Logged in as account A, holding at least 0.00005 vBTC on `qa-<runid>-web` (TC-BTC-027 confirmed) and at least 0.001 VFX.

**Steps**
1. Open the token detail and click `button "Transfer"`.
2. Type the value of `TEST_VFX_B_ADDRESS` into `textbox "To VFX Address"` and `0.00002` into `textbox "Amount of BTC to Send"`.
3. Click `button "Transfer"` in the sheet.
4. In `Confirm Transfer` click `button "Transfer"`.
5. Wait up to 2 minutes for confirmation.

**Expected**
- The sheet shows the fields `To VFX Address` and `Amount of BTC to Send`, and the note `This is a Multi-signature transaction so a higher fee rate is recommended.` (P2 finding: that note does not apply to a vBTC transfer, which has no BTC fee).
- The confirm body reads `Transfer 0.00002 vBTC to <address>?`
- Toast `vBTC transfer broadcasted successfully` and a pending type-26 transaction in the VFX transaction list.
- After confirmation, `My Balance` drops by 0.00002 on the detail screen.

**Cleanup:** none.

### TC-BTC-034 · Transfer validation (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** A token detail screen with a vBTC balance; the transfer sheet open (TC-BTC-032 steps 1–2 or TC-BTC-033 step 1).

**Steps**
1. Submit with the address empty.
2. Enter an address starting with `xRBX` (a Vault address, 34 characters), amount `0.00001`, submit.
3. Enter an address starting with `zfx_`, submit.
4. Enter `abc123`, submit.
5. Enter `TEST_VFX_B_ADDRESS` and amount `0`, submit.
6. Amount `0.000000001` (9 decimals), submit.
7. Amount larger than `My Balance`, submit.
8. Web only, with the VFX balance below 0.001 VFX (for example as a freshly generated keypair holding received vBTC): click `Transfer`.

**Expected**
- Step 1: `Address required`.
- Step 2: `vBTC can only be sent to a standard VFX address (not a Vault account).`
- Step 3: `vBTC can only be sent to a standard VFX address (not a privacy address).`
- Step 4: `Invalid Address.`
- Step 5: `Invalid Amount`.
- Step 6: `Amount can have at most 8 decimal places` (macOS also shows it under the amount field while typing).
- Step 7: `Not enough balance`; on web, when pending sends reduce the spendable amount, `Not enough balance once pending sends are counted. Available: <n> vBTC`.
- Step 8: `A balance on your VFX account is required to broadcast this transaction`.
- No transaction is broadcast in any step.

**Cleanup:** none.

### TC-BTC-035 · Transfer contract ownership (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** A funded V2 contract owned by account A that the run can give away (for example the wizard token from TC-BTC-025). Beacons reachable. Account B logged in on the other platform to observe.

**Steps**
1. macOS: `tap-key vbtc:transfer`, `tap-text "Transfer Token Ownership"`, enter `TEST_VFX_B_ADDRESS` in `To VFX Address`, submit, then `Yes` in `Transfer Ownership`. Web: click `button "Transfer Ownership"`, type the address into `textbox "Recipient VFX Address"`, click `button "Submit"`, then `button "Transfer"`.
2. Wait up to 5 minutes (the transfer runs in the background after the beacon upload).
3. As account B, open vBTC Tokens.

**Expected**
- macOS confirm body: `Are you sure you want to transfer ownership of this vBTC token to <address>?`; toast `Ownership transfer initiated.`
- Web confirm title `Transfer Ownership` with the body starting `Transfer ownership of this vBTC token to <address>?`; the raw transaction confirmation and success follow.
- Account B lists the contract as owner (web shows `(Owner)`), and account A no longer shows the owner-only buttons.
- With a zero-balance contract: macOS `vBTC tokens with zero balance can not be transferred.`, web `vBTC tokens with no balance can not be transferred`.
- Ownership transfer is recorded as still untested on testnet; treat a failure as a finding, not a blocker for other cases.

**Cleanup:** optionally transfer the contract back from account B.

### TC-BTC-036 · Media detection on web ownership transfer (web)
**Platforms:** Web · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** A default-asset V2 contract (created without media, as every contract in this suite is) owned by the web session, and a way to make the beacon upload fail. **Open question:** how to make the beacon upload fail on testnet in a controlled way.

**Steps**
1. With the beacon upload failing, run the web ownership transfer from TC-BTC-035 on the default-asset contract.
2. Repeat on a contract that has a real media file.

**Expected**
- Step 1: the transfer continues (the wallet uses the `NA` locator because the contract's primary asset is size 0 and named `vbtc_v2_token` or `defaultvBTC*`) and reaches the raw transaction confirmation.
- Step 2: toast `Beacon upload failed. This token has a media file that must be transferred with it, so the transfer cannot continue until a beacon is reachable.` and nothing is sent.

**Cleanup:** none.

## Bulk (multi-contract) vBTC transfer

### TC-BTC-037 · Bulk transfer across two contracts (macOS)
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Account A selected (not a Vault account), holding confirmed vBTC on both `qa-<runid>-mac` and `qa-<runid>-web`, and at least 0.001 VFX. Note both balances before starting.

**Steps**
1. Open vBTC Tokens and tap `Bulk vBTC Transfer`.
2. Read the available total, then `tap-key vbtc:bulk_amount` and `type` an amount larger than the biggest single-token balance but not above the total (for example the larger balance plus 0.00001).
3. `tap-key vbtc:bulk_address`, `type` the value of `TEST_VFX_B_ADDRESS`.
4. `tap-key vbtc:bulk_submit`.
5. In `Confirm Bulk Tx` tap `Send`.
6. Close the result dialog; wait up to 2 minutes for confirmation.

**Expected**
- The screen `Bulk vBTC Transfer` shows `Send vBTC from all of your tokens in one transaction. The amount is drawn from your tokens automatically, largest balance first.`, `Available across your vBTC tokens:` with the combined balance, `Amount to Send` with a `(MAX: <n> vBTC)` button, and `Transfer To VFX Address`. There is no token picker.
- The confirm body reads `Would you like to send a total of <amount> vBTC to <address>`.
- Toast `<amount> vBTC has been sent to <address>.` and a log entry `vBTC V2 Transfer TX Broadcasted. Hash: <hash>`.
- The `vBTC Sent` dialog lists `Drawn from:` with one line per contract, the larger balance first and taken in full, the remainder from the other.
- After confirmation both token balances drop by their allocated amounts and account B's balances rise accordingly.

**Cleanup:** none.

### TC-BTC-038 · Bulk transfer across two contracts (web)
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Logged in as account A, holding confirmed vBTC on two V2 contracts (`available_balances` from Spyglass, net of open withdrawals), and at least 0.001 VFX.

**Steps**
1. Open vBTC Tokens and click `button "Bulk vBTC Transfer"`.
2. Type an amount larger than the biggest single balance into `textbox "Amount to Send"` and `TEST_VFX_B_ADDRESS` into `textbox "Transfer To VFX Address"`.
3. Click `button "Send"`, then `button "Send"` in `Confirm Bulk Tx`.
4. Confirm the raw transaction when the wallet asks, then close the `vBTC Sent` dialog.
5. Wait up to 2 minutes for confirmation and Spyglass indexing.

**Expected**
- The same screen and texts as TC-BTC-037.
- The `vBTC Sent` dialog lists both contracts under `Drawn from:`, largest balance first, and the inputs sum exactly to the amount.
- A pending type-26 transaction with amount 0 is added to the VFX list; after indexing, both contract balances drop by their allocations.

**Cleanup:** none.

### TC-BTC-039 · Bulk transfer that fits one contract (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** As TC-BTC-037 / TC-BTC-038.

**Steps**
1. Open `Bulk vBTC Transfer`, enter an amount smaller than the largest single balance (for example `0.00001`) and `TEST_VFX_B_ADDRESS`, send and confirm.

**Expected**
- `Drawn from:` lists one contract (the one with the largest balance).
- Web falls back to the single-token path, so the `Confirm Transfer` / `Transfer <amount> vBTC to <address>?` confirmation appears and the toast is `vBTC transfer broadcasted successfully`.
- The balance of that contract drops by the amount after confirmation.

**Cleanup:** none.

### TC-BTC-040 · Bulk transfer validation (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** `Bulk vBTC Transfer` screen open with a spendable balance.

**Steps**
1. Submit with both fields empty.
2. Amount `0`; then `1.2.3` (the field only accepts digits and dots); then `0.000000001`; then the available total plus `0.00001`. Submit after each.
3. Tap `(MAX: <n> vBTC)`.
4. Recipient: a Vault (`xRBX`) address; then a `zfx_` address; then `abc123`. Submit after each, with a valid amount.

**Expected**
- Step 1: `Amount required` and `Address required`.
- Step 2: `Invalid Amount`, `Invalid Amount`, `Amount can have at most 8 decimal places`, `Maximum amount is <available> vBTC`.
- Step 3: the amount field is filled with the available total.
- Step 4: `vBTC can only be sent to a standard VFX address (not a Vault account).`, `vBTC can only be sent to a standard VFX address (not a privacy address).`, `Invalid Address.`
- No confirmation dialog appears for any invalid input.

**Cleanup:** none.

### TC-BTC-041 · Bulk transfer guards (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Varies per step.

**Steps**
1. With a session that holds no vBTC (for example account B on a fresh data folder before any transfer), open vBTC Tokens and click `Bulk vBTC Transfer`.
2. macOS: select a Vault account as the current wallet, open `Bulk vBTC Transfer` with a spendable token visible, fill valid values and send.
3. macOS: select a VFX account holding less than 0.001 VFX (with vBTC), fill valid values and send.
4. Web: with the web VFX balance below 0.001 VFX, fill valid values and send.

**Expected**
- Step 1: toast `No vBTC tokens with a balance`; the screen does not open.
- Step 2: `Vault accounts can't send multi-token vBTC transfers. Send from a single token instead.`
- Step 3: `Selected VFX account doesn't have enough balance`.
- Step 4: `A balance on your VFX account is required to broadcast this transaction`.
- When more than 25 contracts would be needed (web allocator): `This amount would need more than 25 tokens in one transaction. Send a smaller amount.`; when the web allocator cannot cover the amount: `Insufficient combined vBTC balance. Available: <n> vBTC, requested: <n> vBTC.` These two are covered by unit tests; record them only if the data allows.

**Cleanup:** none.

## vBTC withdrawal to BTC

### TC-BTC-042 · Withdraw vBTC to a BTC address (macOS)
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes · **Needs BTC confirmations**

**Preconditions:** Account A selected, holding at least 0.00003 vBTC on `qa-<runid>-mac`, no open withdrawal on that contract, at least 0.001 VFX. FROST validators online.

**Steps**
1. Open the token detail and `tap-key vbtc:withdraw`.
2. In `Withdraw BTC`, `tap-key vbtc:address` and `type` the value of `TEST_BTC_TREASURY_ADDRESS` (the treasury, see README); `tap-key vbtc:amount` and `type 0.00002`.
3. Open the `Fee Rate:` menu and choose `Half Hour`.
4. `tap-key vbtc:submit`, then `Yes` in `Withdraw BTC`.
5. Watch the processing dialog: wait up to 5 minutes for the request to confirm, then up to 3 minutes for signing (plus up to 2 minutes of verification if the request times out).
6. `tap-text Done`. Wait up to 60 minutes for the BTC transaction to confirm.

**Expected**
- The sheet shows `To BTC Address`, `Amount of vBTC to Withdraw`, the fee preset menu (no `Custom` entry) and `Fee Estimate: ~<n> SATS | ~<n> BTC    (<n> SATS /byte | <n> BTC /byte)`.
- The confirm body reads `Are you sure you want to withdraw 0.00002 BTC to <address>?`
- The dialog moves from `Waiting for Confirmation` (`Waiting for the withdrawal request to be confirmed in a block...`, `This typically takes 10-20 seconds. The FROST signing will begin automatically once confirmed.`) to `Processing Withdrawal` (`Validators are signing the Bitcoin transaction...`, `This may take a minute. Please do not close the application.`) to `Withdrawal Complete` (`Withdrawal completed successfully!`, `VFX Transaction:` and `BTC Transaction:` hashes with copy and explorer links).
- A log entry `vBTC Withdrawal completed successfully.` with the BTC hash; `My Balance` drops by 0.00002 after the list refreshes; the BTC transaction confirms on mempool.space within 60 minutes and `TEST_BTC_TREASURY_ADDRESS` receives the amount less the network fee.

**Cleanup:** none.

### TC-BTC-043 · Withdraw vBTC to a BTC address (web)
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes · **Needs BTC confirmations**

**Preconditions:** Logged in as account A, holding at least 0.00003 vBTC on `qa-<runid>-web`, no open withdrawal of its own on that contract, at least 0.001 VFX.

**Steps**
1. Open the token detail and click `button "Withdraw"`.
2. In `Amount` (`How much BTC do you want to withdraw?`), type `0.00002` into `textbox "Withdrawal Amount"`, click `button "Submit"`.
3. In `BTC Address`, type the value of `TEST_BTC_TREASURY_ADDRESS` (the treasury, see README) into `textbox "Receiving BTC Address"`, click `button "Submit"`.
4. In the `Fee Rate` picker keep `Economy`, click `button "Continue"`.
5. In `Confirm Withdrawal Request` click `button "Yes"`.
6. Keep the tab visible. Wait up to 5 minutes for block confirmation and up to 10 minutes for FROST signing and completion.
7. Click `button "Done"`, then wait up to 60 minutes for the BTC confirmation.

**Expected**
- The confirm body reads `Withdraw 0.00002 BTC to <address>` / `Fee rate: <n> sats/byte` / `Proceed?`
- The dialog cannot be dismissed while running and moves through `Broadcasting Request` (`Broadcasting withdrawal request...`), `Waiting for Confirmation` (`Waiting for block confirmation...`), `FROST Signing` (`FROST signing in progress...`, `Validators are signing the Bitcoin transaction. This may take a minute or two. Please do not close this window.`), `Recording Completion` (`Recording completion on the VFX chain...`) to `Withdrawal Complete` with `Withdrawal completed successfully!` and `BTC Transaction:` with copy and `Open in BTC Explorer`.
- The detail screen shows a `Withdrawal History:` row `0.00002 vBTC → <address>` with a green check once its status is `completed`, and `My Balance` drops by 0.00002.

**Cleanup:** none.

### TC-BTC-044 · Withdraw from a received (non-owned) contract (both platforms)
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes · **Needs BTC confirmations**

**Preconditions:** Account B holds vBTC received in TC-BTC-032 / TC-BTC-033 / TC-BTC-037 on a contract owned by A (confirmed), and at least 0.001 VFX. macOS: a data folder in which only `TEST_VFX_B_PRIVKEY` is imported (move the automation folder aside and start clean, or run these cases before importing A), because with A's key on the same node the app treats the contract as owned. Web: logged in as account B. No open withdrawal on the contract.

**Steps**
1. Open vBTC Tokens as account B and open the received contract.
2. Withdraw `0.00001` to `TEST_BTC_TREASURY_ADDRESS` as in TC-BTC-042 (macOS) or TC-BTC-043 (web).

**Expected**
- The withdrawal runs to `Withdrawal Complete` for the holder, not the owner: the requestor is account B.
- Account B's `My Balance` on that contract drops by 0.00001; the owner's balance is unaffected apart from the shared deposit total.

**Cleanup:** none.

### TC-BTC-045 · Received contract: list, detail and actions (both platforms)
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Account B holds vBTC on a V2 contract owned by account A (TC-BTC-032 or TC-BTC-033 confirmed). macOS: a data folder with only `TEST_VFX_B_PRIVKEY` imported, as in TC-BTC-044.

**Steps**
1. As account B, open vBTC Tokens.
2. Open the received contract's detail screen.

**Expected**
- The contract is listed even though B did not mint it, with its real on-chain name (not blank) and B's balance.
- macOS detail: the screen does not sit on a loader (the V2 path skips the NFT lookup); `Owner` shows account A (the contract owner), `My Balance` shows B's spendable balance, `Token Total Balance` shows the contract's deposit total, and the name is the on-chain name (falling back to `vBTC` only if the chain lookup fails).
- Web detail: no `(Owner)` suffix, no `BTC Deposit Address` or `Token Total Balance` rows, `SmartContract Owner Address` shows account A.
- Buttons: `Copy Deposit Address`, `Withdraw`, `Transfer` (macOS sheet offers only `Transfer vBTC`), `Borrow/Lend`. `Fund`, `Transfer Ownership`, `Bridge to Base` and `Prove Ownership` are absent.

**Cleanup:** none.

### TC-BTC-046 · Forward received vBTC (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** As TC-BTC-045, with at least 0.00001 vBTC left.

**Steps**
1. As account B, transfer `0.00001` vBTC on the received contract to `TEST_VFX_A_ADDRESS` as in TC-BTC-032 (macOS) or TC-BTC-033 (web).
2. Wait up to 2 minutes.

**Expected**
- The transfer is sent from account B and succeeds with the same texts as TC-BTC-032 / TC-BTC-033; B's balance drops and A's balance on that contract rises.
- **Open question (suspected defect, macOS):** `TokenizedBtcActionButtons` calls `VbtcV2Service().transferVbtc(fromAddress: token.rbxAddress, ...)`, and for V2 contracts `rbxAddress` is the contract's `OwnerAddress`. On a B-only node this should fail with the CLI's `Account not found`; on a node that also holds A's key it would move A's vBTC instead of B's. The withdrawal path was already changed to use the current wallet; confirm whether transfer should do the same.

**Cleanup:** none.

### TC-BTC-047 · Withdrawal validation (both platforms)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** A token detail screen with a vBTC balance and no open withdrawal.

**Steps**
1. macOS: open `Withdraw BTC` and submit with an empty address; then a VFX address; then a mainnet `bc1` address; each with a valid amount. Web: in the `BTC Address` prompt try the same values.
2. Amount `0`; amount with 9 decimals; amount above the balance.
3. macOS: select a Vault account holding vBTC and click `Withdraw`.

**Expected**
- Empty address: `BTC address required.`
- VFX address or mainnet address on testnet: `Invalid BTC address. A testnet address is required.`
- Amount `0`: `Invalid Amount`. Nine decimals: `Amount can have at most 8 decimal places` (web shows it in the prompt). Above balance: macOS `Not enough balance`, web `Insufficient balance. Available: <n> vBTC`.
- Vault: `Vault Accounts can not withdrawl. Please transfer vBTC to a standard VFX address`.
- No withdrawal request is broadcast in any step.

**Cleanup:** none.

### TC-BTC-048 · Second withdrawal while one is open (web)
**Platforms:** Web · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** A withdrawal on the contract is open for another holder (for example account B's request from TC-BTC-044 web, stopped at `Waiting for Confirmation` or `FROST Signing` by closing the tab), less than 90 minutes old. Logged in as account A in another profile.

**Steps**
1. As account A, start a new withdrawal on the same contract (TC-BTC-043 steps 1–5).

**Expected**
- The withdrawal dialog closes and an info dialog `Withdrawal In Progress` appears with `This token already has a withdrawal underway, so another can't start yet.` and the explanation that holders share one deposit address, ending `If it has stalled, the token frees itself automatically about an hour after the request was made.`, with a `Got It` button.
- No red error with the raw node wording is shown, and A's balance is unchanged.

**Cleanup:** let B's withdrawal finish (TC-BTC-049) or expire.

### TC-BTC-049 · Resume a withdrawal after reload (web)
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes · **Needs BTC confirmations**

**Preconditions:** Logged in as account A with a vBTC balance, at least 0.001 VFX.

**Steps**
1. Start a withdrawal of `0.00001` as in TC-BTC-043. As soon as the dialog shows `Waiting for Confirmation` or `FROST Signing`, reload the page with `?automation=1` and log back in as A.
2. Open the token detail. In `Withdrawal History:` find the row `0.00001 vBTC → <address>`.
3. Click the row (subtitle `Pending — tap to resume`).
4. Alternatively, click `button "Withdraw"` on the same token.
5. Wait up to 10 minutes for the dialog to finish.

**Expected**
- The row shows `Pending — tap to resume` and a cancel icon with tooltip `Cancel withdrawal`.
- Clicking the row, or `Withdraw` while this request is open, reopens the withdrawal dialog at `FROST Signing` (or `Recording Completion` when the Bitcoin was already broadcast) without asking for a new amount or address.
- The dialog reaches `Withdrawal Complete`; the row turns `Status: completed` with a green check.
- If the reload happened after the Bitcoin broadcast but before settlement, the row reads `BTC sent — tap to finish settling on VFX` with a warning icon, and resuming only submits the completion (no second Bitcoin transaction).

**Cleanup:** none.

### TC-BTC-050 · Completion pending and retry (web)
**Platforms:** Web · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** A withdrawal whose Bitcoin transaction was broadcast but whose VFX completion failed (for example the network dropped during `Recording Completion`). **Open question:** confirm a reproducible way to make only the completion step fail.

**Steps**
1. Observe the dialog after the completion failure.
2. Click `button "Later"`, reopen the row from `Withdrawal History:`, then click `button "Retry Completion"`.

**Expected**
- The dialog title is `Action Required` with `Your Bitcoin was sent, but the withdrawal has not been settled on the VFX chain yet.` and `Retry below to finish. This only submits the completion transaction — your Bitcoin will not be sent again. You can also come back to this from the token's withdrawal history.`, the `BTC Transaction:` hash, `Later` and `Retry Completion`.
- `Retry Completion` settles the withdrawal and shows `Withdrawal Complete`; no second Bitcoin transaction appears on mempool.space.
- When signing fails instead, the failure view shows `FROST signing failed or timed out. The withdrawal may still complete — check back shortly.` with `Dismiss` and `Retry Signing`; `Retry Signing` is absent when the Bitcoin broadcast returned no txid or the explorer reports the request already signed.

**Cleanup:** none.

### TC-BTC-051 · Cancel an open withdrawal request (web)
**Platforms:** Web · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Account A has its own withdrawal request in `requested` state (step 1 of TC-BTC-049, reloaded before signing began).

**Steps**
1. On the token detail, in `Withdrawal History:`, click the cancel icon (`Cancel withdrawal`).
2. In `Cancel Withdrawal?` (`Are you sure you want to cancel this withdrawal request?`) confirm with `button "Yes"`.
3. Wait up to 2 minutes.

**Expected**
- The cancellation is signed and sent; on failure the toast reads `Failed to prepare cancellation` or `Cancellation failed: <error>`.
- The row no longer offers resume or cancel, and after validator voting the reserved amount is spendable again.
- The cancel icon is never shown on another holder's row or on a row whose Bitcoin was already sent (`BTC sent — tap to finish settling on VFX`).
- **Open question:** cancellation needs a 75% validator vote; confirm how long the run should wait and which status the row shows while votes are pending.

**Cleanup:** none.

### TC-BTC-052 · Pending withdrawal found and cancel from the failure view (macOS)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** A contract with an open withdrawal (for example start TC-BTC-042 and quit the app during `Processing Withdrawal` with `osascript -e 'tell application id "io.reserveblock.wallet" to quit'`, then relaunch).

**Steps**
1. Open the token detail and `tap-key vbtc:withdraw`.
2. In `Pending Withdrawal Found` tap `Complete`.
3. If the dialog ends in `Withdrawal Failed` with a BTC transaction hash known, tap `Cancel Withdrawal`.

**Expected**
- The prompt body reads `This token has a pending withdrawal of <amount> vBTC to <destination>.`, `It may have been requested by another holder of this token. Only the account that requested it can complete it.` and `Would you like to try to complete it?`, with `Complete` and `Dismiss`.
- `Complete` opens the processing dialog directly at `Processing Withdrawal` and runs to `Withdrawal Complete`, or to `Withdrawal Failed` with the node message and `Dismiss` / `Retry` (plus `Cancel Withdrawal` when a BTC hash exists).
- `Cancel Withdrawal` shows `Cancellation request submitted. Awaiting validator votes.` and closes the dialog.
- If signing outlasts the 3-minute request, the dialog shows `Checking Withdrawal Status` with `The request timed out. Checking whether the withdrawal completed anyway...` and `Signing can outlast the request. Please wait rather than retrying — retrying can broadcast a second Bitcoin transaction.`, then success or failure within 2 minutes.
- Starting a new request while one is open returns the node's `You already have an active withdrawal request...` message and offers `Pending Withdrawal Found` / `You have a pending withdrawal for this contract. Would you like to complete it?`

**Cleanup:** none.
