# 03 · Send, receive and transactions

This area covers moving VFX and BTC from the Send screen, the prefilled send route the web wallet exposes for payment links, every client-side validation on the send form, the Receive screen (address and domain copy, request links, QR codes), the transaction lists on both platforms, the desktop transaction filters, and the web transaction detail screen with its copy and explorer actions. Both platforms render the same `SendForm` (`lib/features/send/components/send_form.dart`), but the submit path differs: the desktop signs through the Core CLI (`/SendTransaction`, BTC through `BtcService`), while the web wallet builds, signs and verifies the transaction itself through Spyglass `/raw/*` (`RawTransaction.generate`) and therefore shows the node-computed fee before the final confirmation. BTC send lives in the same screen behind the currency switch, so its send cases are here; BTC accounts, tokenization and withdrawals stay in `04-btc-vbtc.md`. Sending from a Vault account and the timelock/callback rules are in `06-vault-accounts.md`. The "Create Payment Link" (Butterfly) button under the form belongs to `12-payments-faucet-keygen.md`.

## Area preconditions

- Web: the testnet automation build is open at `http://localhost:42069/?automation=1`, semantics are on (`fltA11y.status()` reports `visible: true`), and the session is logged in as account A by importing `TEST_VFX_A_PRIVKEY` (see `01-launch-auth.md`). BTC cases additionally have the BTC key `TEST_BTC_WIF` in the session.
- macOS: the Flutter Driver build is running (`make run_macos_driver`), account A is imported from `TEST_VFX_A_PRIVKEY`, the chain is synced (status bar no longer shows syncing), and account A is the selected wallet. BTC cases additionally have `TEST_BTC_WIF` imported as a BTC account. If the wallet is encrypted, the password prompt that appears before sending takes `TEST_ENCRYPTION_PASSWORD`.
- Account A holds at least 20 VFX available for this area. Account B's address is `TEST_VFX_B_ADDRESS`; B is logged in in a second browser profile or checked on the explorer when a case says to verify the receiver.
- Clipboard checks: on macOS read the clipboard with `pbpaste`; on web paste it into the send address field through the "here" link or read it with `navigator.clipboard.readText()` in the `javascript_tool` when the page has clipboard permission. Never write a copied private key or restore code into results.
- Known hook gaps (record as `blocked` with this note rather than failing the feature): the confirmation dialogs (`ConfirmDialog`) have no keys, so on macOS `tap-text Send` can match the side-nav item, the form's `send:submit` button and the dialog button at once ("Too many elements"). On web the side-nav `button "Send"` and the form's submit share a label; click the one inside the form or dialog by ref from `read_page`. Desktop copy/explorer icons on transaction tiles share one label per tile, so `tap-label` only works when exactly one tile is on screen.
- Mainnet smoke cases run only with a mainnet account provided for the smoke pass, and never press a Send, Submit or Generate control that signs.

## Send form

### TC-SEND-001 · Send screen shows the form, sender and balance
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Area preconditions.

**Steps**
1. Open Send. Web: click `button "Send"` in the side nav. macOS: `tap-key nav:send`.
2. Make sure VFX is selected. Web: click `button "VFX"` in the currency switch (segments `All`, `VFX`, `Vault`, `BTC`). macOS: `tap-text VFX` in the currency switch (segments `All`, `VFX`, `BTC`).
3. Type `1` into the amount field. Web: `textbox "Amount of VFX to send"`. macOS: `tap-key send:amount`, then `type 1`.

**Expected**
- The app bar reads `Send VFX`.
- The card shows `From:` with account A's address (macOS: a dropdown with an arrow; web: the wallet selector), `To:` with the hint `Recipient's Account Address`, and `Amount:` with the hint `Amount of VFX to send`.
- Under the address field the helper reads `Use cmd+v to paste or click here.` on macOS and `Use ctrl+v to paste or click here.` on web.
- The balance badge on the right reads `<balance> VFX`. When the account has a locked balance, three indicators `Available:`, `Locked:` and `Total:` replace the badge.
- After step 3, the amount field shows a helper `$<value> USD` when a VFX price is available (no helper when the price feed is empty).
- The form has `Clear` and `Send` buttons and no "max" control. The fee is not shown on the form on either platform (web shows it in the final confirmation, see TC-SEND-003).
- A `Create Payment Link` button appears under the form for VFX.

**Cleanup:** click `Clear`.

### TC-SEND-002 · Send VFX to a valid address (macOS)
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Account A selected with at least 2 VFX available. Chain synced.

**Steps**
1. `tap-key nav:send`, make sure VFX is selected.
2. `tap-key send:address`, then `type` the value of `TEST_VFX_B_ADDRESS`.
3. `tap-key send:amount`, then `type 1`.
4. `tap-key send:submit`. If the wallet is encrypted, enter `TEST_ENCRYPTION_PASSWORD` in the password prompt.
5. In the `Please Confirm` dialog, tap `Send` (see the hook gap note).
6. `tap-key nav:transactions`, select `VFX`, open the `Pending` tab, then the `Successful` tab; wait up to 2 minutes for the transaction to leave Pending.

**Expected**
- Step 5 dialog is titled `Please Confirm` and its body reads `Sending:` / `1 VFX` / `To:` / account B's address / `From:` / account A's label or address, with `Cancel` and `Send` buttons.
- After confirming, a green toast reads `1 VFX has been sent to <B address>. See dashboard for TX ID.` and the form is cleared.
- The log panel gains a success entry containing the transaction hash.
- The transaction appears with `Status: Pending` within about 10 seconds (the Transactions screen polls every 10 seconds), then with `Status: Success` within 2 minutes, `Amount: -1.0 VFX` in red and `Type: Tx`.
- Account A's balance drops by 1 VFX plus the fee; account B's balance rises by 1 VFX (check B's web session or `https://spyglass-testnet.verifiedx.io/` for B's address).

**Cleanup:** none.

### TC-SEND-003 · Send VFX to a valid address (web)
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Logged in as account A with at least 2 VFX available.

**Steps**
1. Click `button "Send"` in the side nav, then `button "VFX"`.
2. Click `textbox "Recipient's Account Address"` and type the value of `TEST_VFX_B_ADDRESS`.
3. Click `textbox "Amount of VFX to send"` and type `1`.
4. Click the form's `button "Send"`.
5. In `Please Confirm`, click the dialog's `button "Send"`.
6. Wait up to 30 seconds for the `Valid Transaction` dialog; read it, then click its `button "Send"`.
7. Open Transactions (`button "Transactions"` in the side nav), tab `VFX`; wait up to 2 minutes for the new card to lose its `Pending` badge.

**Expected**
- Step 5 dialog: title `Please Confirm`, body `Sending:` / `1 VFX` / `To:` / B's address / `From:` / A's address.
- Step 6 dialog: title `Valid Transaction`, body starts `This transaction is valid and is ready to send.` / `Are you sure you want to proceed?`, then `To: <B address>`, `Amount: 1 VFX`, `TX Fee: <fee> VFX` and `Total: <1 + fee> VFX`. The fee is greater than 0. (The web build prints whole numbers without `.0`.)
- After confirming, a loading overlay shows briefly, then a green toast reads `1 VFX sent to <B address>` and the form is cleared.
- The Transactions list shows a card `-1 VFX` (or `1 VFX`) in red with `To: <B address>` and a `Pending` badge; the card is not tappable while pending. Within 2 minutes the badge disappears and the card opens the detail screen.
- Account A's balance on the dashboard drops by 1 VFX plus the fee; B's balance rises by 1 VFX.

**Cleanup:** none.

### TC-SEND-004 · Cancelling at confirmation sends nothing
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As TC-SEND-002 / TC-SEND-003.

**Steps**
1. Fill the form with B's address and amount `1` as in TC-SEND-002 (macOS) or TC-SEND-003 (web), and submit.
2. In `Please Confirm`, press `Cancel`. Web: `button "Cancel"`. macOS: `tap-text Cancel`.
3. Web only: submit again, confirm `Please Confirm`, then press `Cancel` in `Valid Transaction`.

**Expected**
- Each Cancel closes the dialog, the form keeps its values, no toast appears, and no new transaction appears in the Pending tab (macOS) or with a `Pending` badge (web) within 30 seconds.
- Account A's balance is unchanged.

**Cleanup:** press `Clear`.

### TC-SEND-005 · Clear resets the form
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Send screen open.

**Steps**
1. Enter any address and amount `abc1` (letters are filtered, `1` remains). Submit with an empty address first to raise a validation message, then fill the address.
2. Press `Clear`. Web: `button "Clear"`. macOS: `tap-text Clear`.

**Expected**
- Letters typed into the amount field do not appear; only digits and `.` are accepted.
- After Clear both fields are empty, validation messages are gone, and the USD helper disappears.

**Cleanup:** none.

### TC-SEND-006 · Paste an address from the clipboard
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Send screen open, VFX selected. The clipboard holds ` <B address>` followed by a newline (macOS: `printf ' %s\n' "$TEST_VFX_B_ADDRESS" | pbcopy`; web: write it with `navigator.clipboard.writeText` in the `javascript_tool`).

**Steps**
1. Click the `here` link under the address field. Web: `fltA11y.tap("here")`. macOS: `tap-text here`.
2. Press `Clear`, then use the paste icon. Web: `button "Paste"`. macOS: `tap-label Paste`.
3. Empty the clipboard (macOS: `printf '' | pbcopy`) and press `here` again.

**Expected**
- Steps 1 and 2 fill the address field with B's address exactly, with the leading space and the newline removed (the paste keeps letters and digits only).
- Step 3 leaves the field empty or shows the red toast `Clipboard text is invalid`.
- On a narrow (mobile) layout the paste icon is hidden; only the `here` link remains.

**Cleanup:** press `Clear`.

### TC-SEND-007 · Choose one of my addresses (macOS)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** The desktop wallet holds at least two VFX accounts (A plus any second account or vault).

**Steps**
1. On Send with VFX selected, `tap-label "Choose an address"` (the folder icon next to Paste).
2. In the dialog, `tap-text Cancel`.
3. Open it again and `tap-text` the second account's address.

**Expected**
- The dialog is titled `Choose an address` and lists every VFX account address in the wallet as an underlined link (BTC addresses are listed too when the currency switch is on `All`).
- Cancel closes it without changing the field.
- Tapping an address closes the dialog and puts that address into `send:address`.
- The web form has no such button.

**Cleanup:** press `Clear`.

### TC-SEND-008 · Desktop blocks sending while the wallet is not synced
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Run right after a fresh-folder launch while the status bar still shows the chain syncing. Account A imported.

**Steps**
1. Fill `send:address` with B's address and `send:amount` with `1`, then `tap-key send:submit`.

**Expected**
- A red toast reads `Please wait until your wallet is synced with the network` and no confirmation dialog opens.

**Cleanup:** press `Clear`.

## BTC send

### TC-SEND-009 · Send BTC with a fee-rate preset (macOS)
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** The BTC account from `TEST_BTC_WIF` is imported and holds at least 0.0002 testnet BTC plus fees. A second BTC address to receive: use a fresh BTC account created with `New Account` on Receive (BTC), or any testnet4 address Tyler provides.

**Steps**
1. `tap-key nav:send`, then `tap-text BTC` in the currency switch.
2. `tap-key send:address`, `type <receiving BTC address>`.
3. `tap-key send:amount`, `type 0.0001`.
4. Tap the fee-rate dropdown next to `Fee Rate:` (it shows `Economy` by default) and pick `Hour`.
5. `tap-key send:submit`.
6. In `Please Confirm`, tap `Send`.
7. In the `Transaction Broadcasted` dialog, tap the copy icon (`tap-label "Copy transaction hash"`), then check the clipboard with `pbpaste`.
8. Tap `Open in BTC Explorer`, then close the dialog (`tap-text Close`).

**Expected**
- The app bar reads `Send BTC`, the balance badge reads `<balance> BTC`, the amount hint reads `Amount of BTC to send`.
- Under the fee rate the text reads `Fee Rate: <n> SATS /byte [<x> BTC /byte]` and `Fee Estimate: ~<n> SATS [~<x> BTC]`, and it changes when the preset changes. Presets offered: `Minimum`, `Economy`, `Hour`, `Half Hour`, `Fastest`, `Custom`.
- The confirmation body reads `Sending:` / `0.0001 BTC` / `To:` / receiver / `From:` / BTC account / `Fee:` / `<fee> BTC` with 8 decimals.
- After Send: a green toast `0.0001 BTC has been sent to <receiver>.`, the form clears, the log panel gains `BTC TX broadcasted with hash of <hash>`, and the dialog `Transaction Broadcasted` shows a read-only `Transaction Hash` field.
- The copy icon shows the toast `Transaction Hash copied to clipboard` and `pbpaste` returns the hash.
- `Open in BTC Explorer` opens `https://mempool.space/testnet4/tx/<hash>` in the default browser.
- Within 2 minutes the transaction is listed on the BTC transactions tab (`nav:transactions`, `BTC`, tab `Transactions`).

**Cleanup:** none.

### TC-SEND-010 · Send BTC from the web wallet
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Web session holds the BTC key from `TEST_BTC_WIF` with at least 0.0002 testnet BTC. A receiving testnet4 address as in TC-SEND-009.

**Steps**
1. Open Send and click `button "BTC"`.
2. Fill `textbox "Recipient's Account Address"` with the receiver and `textbox "Amount of BTC to send"` with `0.0001`.
3. Click the form's `button "Send"`.
4. In the `Fee Rate` dialog pick `Economy`, then click `button "Continue"`.
5. In `Please Confirm`, click `button "Send"`.
6. In `Transaction Broadcasted`, click `button "Copy transaction hash"`, then `button "Open in BTC Explorer"`, then close the dialog.

**Expected**
- No fee-rate row is shown on the web form; the fee rate is chosen in the `Fee Rate` dialog, which lists each preset with `<n> SATS | <x> BTC`.
- The confirmation body reads `Sending:` / `0.0001 BTC` / `To:` / receiver / `From:` / BTC address / `FeeRate:` / `<n> SATS`.
- After Send: green toast `0.0001 BTC has been sent to <receiver>.`, the `Transaction Broadcasted` dialog with the hash, and the form clears.
- Copy shows `Transaction Hash copied to clipboard`; the explorer button opens a new tab on `https://mempool.space/testnet4/tx/<hash>`.
- The BTC balance refreshes within about 2 seconds of the send and the transaction appears on the Transactions `BTC` tab within 2 minutes.

**Cleanup:** close the explorer tab.

### TC-SEND-011 · BTC send validation
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Send screen with BTC selected, BTC account loaded.

**Steps**
1. Submit with both fields empty.
2. Enter any address and amount `0.000001`, submit.
3. Enter amount `1000`, submit.
4. macOS only: set the fee rate preset to `Custom`, leave the custom fee field (hint `Fee rate in satoshis`) empty, enter a valid amount `0.0001`, submit.

**Expected**
- Step 1: `BTC Address required` under the address and `Amount required` under the amount.
- Step 2: `The minimum transaction amount is 0.00001 BTC`.
- Step 3: `Not enough balance in BTC account`.
- Step 4: `Invalid Fee Rate. Must be atleast 1 satoshi.` under the custom fee field.
- No confirmation dialog opens in any step.

**Open question:** the client does not validate the BTC address format (only non-empty). What should a malformed BTC address produce: a CLI/Spyglass error toast, or nothing? Record the observed text.

**Cleanup:** press `Clear`, set the preset back to `Economy`.

## Prefilled send (web)

### TC-SEND-012 · Prefilled VFX send from the URL
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Logged in as account A on web.

**Steps**
1. Load `http://localhost:42069/?automation=1#/dashboard/send/vfx/<B address>/2.5` (substitute `TEST_VFX_B_ADDRESS`). If the reload drops the session, log in again as A and load the URL again.
2. Read the form.

**Expected**
- The screen is `Send VFX` with the `To:` field holding B's address and the amount holding `2.5`.
- The currency switch is set to VFX (the route's `vfx` segment), even if BTC was selected before.
- Nothing is sent until `Send` is pressed; the normal flow of TC-SEND-003 applies from here.

**Open question:** the in-app request link (TC-SEND-029) is built as `.../#dashboard/send/...` without a leading slash; confirm both `#/dashboard/...` and `#dashboard/...` resolve.

**Cleanup:** press `Clear`.

### TC-SEND-013 · Prefilled BTC send from the URL
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Web session with the BTC key loaded.

**Steps**
1. Load `http://localhost:42069/?automation=1#/dashboard/send/btc/<a testnet4 address>/0.0001`.

**Expected**
- The app bar reads `Send BTC`, the currency switch shows BTC selected, and the fields hold the address and `0.0001`.

**Cleanup:** press `Clear`.

### TC-SEND-014 · Prefilled send with malformed parameters
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. Load `http://localhost:42069/?automation=1#/dashboard/send/vfx/xNOTREAL/1` and press `Send`.
2. Load `http://localhost:42069/?automation=1#/dashboard/send/vfx/<B address>/abc`.

**Expected**
- Step 1: the address field shows `xNOTREAL` and submitting shows `Invalid Address.` under it.
- Step 2: the app does not crash to a blank page; it either shows the send form with an empty or `NaN` amount, or redirects to the dashboard.

**Open question:** the `amount` path parameter is declared as `double`; what should a non-numeric value do? Record what the build does.

**Cleanup:** press `Clear`.

## Validation

### TC-SEND-015 · Required fields
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Send screen with VFX selected, form empty.

**Steps**
1. Press the form's `Send` (macOS: `tap-key send:submit`).

**Expected**
- Under the address: `Address or VFX domain required`.
- Under the amount: `Amount required`.
- No dialog opens and no toast appears.

**Cleanup:** none.

### TC-SEND-016 · Invalid recipient address
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Send screen with VFX selected, account A has at least 2 VFX.

**Steps**
1. Address `xabc`, amount `1`, submit.
2. Address: B's address with its first character replaced by `R` (a mainnet-shaped address on testnet), amount `1`, submit.
3. Address: 34 characters starting with `x` that are not a real address (for example `x` followed by 33 `A`), amount `1`, submit. Confirm `Please Confirm` if it appears on web.
4. Type `xab c!d` into the address field.

**Expected**
- Steps 1 and 2: `Invalid Address.` under the address field (the client requires 34 characters and, on testnet, a leading `x`; `xRBX` addresses are accepted), no dialog.
- Step 3, macOS: the form passes, the CLI `ValidateAddress` check fails and a red toast reads `Invalid Address`; no confirmation dialog.
- Step 3, web: the form passes and `Please Confirm` opens; after confirming, the node refuses the transaction and a red toast shows the node's refusal message, or `A problem occurred.` when there is none. No `Valid Transaction` dialog.
- Step 4: the field shows `xabcd`; spaces and symbols are filtered as you type (only letters, digits and `.` are accepted).

**Open question:** record the exact node refusal text for step 3 on web so the next pass can assert it.

**Cleanup:** press `Clear`.

### TC-SEND-017 · Invalid amounts: zero, negative, malformed
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Send screen, address field holds B's address.

**Steps**
1. Amount `0`, submit.
2. Amount `0.0`, submit.
3. Type `-5` into the amount, submit.
4. Amount `1.2.3`, submit.
5. Amount `.`, submit.

**Expected**
- Steps 1 and 2: `The amount has to be a positive value`.
- Step 3: the `-` is filtered as typed, the field holds `5`, and the form validates normally (no negative amount can be entered).
- Steps 4 and 5: `Not a valid amount`.
- No dialog opens in steps 1, 2, 4 and 5.

**Cleanup:** press `Clear`.

### TC-SEND-018 · Amount larger than the balance
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Send screen with account A selected; note A's balance.

**Steps**
1. Address: B's address. Amount: A's balance plus 1. Submit.
2. Amount: exactly A's balance. Submit, and stop at the first confirmation dialog (press `Cancel`).

**Expected**
- Step 1: `Not enough balance in account.` under the amount; no dialog.
- Step 2, macOS: `Please Confirm` opens (the client compares against the balance only, not balance plus fee).
- Step 2, web: `Please Confirm` opens; if it is confirmed, the node refuses the send because the fee is not covered and a red toast shows the refusal. Press `Cancel` instead.

**Open question:** should the client reserve the fee when the amount equals the full balance? Today neither platform does.

**Cleanup:** press `Clear`.

### TC-SEND-019 · Amounts with many decimals
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Account A has at least 2 VFX.

**Steps**
1. Send `0.12345678` VFX to B through the full flow (TC-SEND-002 on macOS, TC-SEND-003 on web).
2. Send `0.0000000000000000001` (19 decimals) to B; stop at the web `Valid Transaction` dialog or the macOS toast and record the result.

**Expected**
- Step 1 succeeds; the transaction lists `-0.12345678 VFX` and B receives exactly `0.12345678`.
- Step 2: the client has no decimal-places rule, so the form accepts it. The outcome comes from the node: a refusal toast, or a transaction whose amount is shown rounded. The amount shown in the confirmation must equal the amount that lands on chain.

**Open question:** what is VFX's maximum precision, and should the form reject extra decimals with a message? No client rule exists today.

**Cleanup:** none.

### TC-SEND-020 · Web counts pending sends against the balance
**Platforms:** Web · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Logged in as account A. Note A's balance `bal`.

**Steps**
1. Send `1` VFX to B through TC-SEND-003 and do not wait for it to confirm.
2. Immediately fill a second send to B of `bal - 0.5` VFX and submit.
3. Wait up to 2 minutes for the first send to lose its `Pending` badge, then submit the second send again.

**Expected**
- Step 2 shows `Not enough balance once pending sends are counted. Available: <available> VFX` under the amount, where `<available>` is `bal - 1 - fee`, and no dialog opens. The amount is below the confirmed balance, so without the pending check it would have passed.
- Step 3 shows `Not enough balance in account.`, because the confirmed balance is now `bal - 1 - fee`.

**Cleanup:** press `Clear`.

### TC-SEND-021 · Send to my own address
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** Account A with at least 2 VFX.

**Steps**
1. Send `1` VFX from A to A's own address (`TEST_VFX_A_ADDRESS`) through the full flow.
2. Wait up to 2 minutes and open the transaction list.

**Expected**
- The client does not block it: `Please Confirm` shows the same address as `To:` and `From:`.
- The transaction confirms; A's balance drops by the fee only. On macOS the tile shows the refresh (to-and-from-me) icon.

**Open question:** should sending to self be blocked or warned about? No check exists today.

**Cleanup:** none.

### TC-SEND-022 · Send to a Vault (xRBX) address
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Account A's web Vault address, read from the web `Vault Account` page (`Address:` row); it starts with `xRBX`. Account A has at least 3 VFX.

**Steps**
1. Send `1` VFX from A to that vault address through the full flow.
2. Wait up to 2 minutes, then check the vault's `Available Balance:` on the web `Vault Account` page.

**Expected**
- The address passes validation (`xRBX` addresses are always accepted) and the send completes normally with no timelock prompt, because the sender is a normal account.
- In the lists the vault address is drawn in the vault (purple) colour: macOS `To:` line, web card `To:` line and the colour bar on the web `All` tab.
- The vault's available balance rises by 1 VFX.

**Cleanup:** none (the funds are used by `06-vault-accounts.md`).

### TC-SEND-023 · Send to a VFX domain
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** A VFX domain registered to account B (created by `07-domains.md`, for example `qa-<run id>.vfx`); if 07 has not run yet, run this case after it or mark it `blocked`.

**Steps**
1. Type the domain (including `.vfx`) into the address field and `1` into the amount; submit and confirm through the full flow.
2. Copy the domain to the clipboard and use the `here` paste link instead of typing.

**Expected**
- Step 1: the form accepts the domain (any value containing `.vfx` skips the address check), the confirmation shows the domain as `To:`, and after confirmation B's address receives 1 VFX within 2 minutes.
- Step 2: the paste strips every non-alphanumeric character, so the field holds the domain without its dot (for example `qa20261001avfx`) and submitting shows `Invalid Address.`.

**Open question:** does the Core CLI `ValidateAddress` (macOS) and Spyglass raw path (web) resolve `.vfx` domains? If step 1 fails with `Invalid Address` or a node refusal, record it; domain sending may not be supported by this build. Is the paste stripping the dot intended?

**Cleanup:** none.

## Receive

### TC-SEND-024 · Receive VFX shows and copies the address
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Account A selected.

**Steps**
1. Open Receive. Web: `button "Receive"` in the side nav, then `button "VFX"`. macOS: `tap-key nav:receive`, VFX selected.
2. Copy the address. Web: click `button "Copy address"`. macOS: `tap-key receive:copy_address`.
3. Check the clipboard.
4. macOS only: tap the `Copy\nAddress` tile (`tap-text $'Copy\nAddress'`).

**Expected**
- The app bar reads `Receive VFX`.
- macOS: the card shows A's address with the subtitle `Your Selected VFX Address`, and a row of tiles `Copy Address`, `New Account`, `Import Key`, `Copy Link`, `QR Code`.
- Web: the card shows A's address with the subtitle `Your Address`, then `Copy Link` and `QR Code` tiles. The currency switch has no `All` segment.
- Copy shows the toast `Address copied to clipboard` (macOS) or `'<address>' Copied to clipboard` (web), and the clipboard holds exactly A's address.

**Cleanup:** none. (`New Account` and `Import Key` are covered in `01-launch-auth.md`.)

### TC-SEND-025 · Receive BTC shows and copies the BTC address
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** A BTC account loaded (desktop import or web session key).

**Steps**
1. On Receive, select BTC. Web: `button "BTC"`. macOS: `tap-text BTC`.
2. Copy. Web: `button "Copy address"`. macOS: `tap-key receive:copy_btc_address`.

**Expected**
- The app bar reads `Receive BTC`.
- macOS: subtitle `Your Selected BTC Address`, tiles `Copy Address`, `New Account`, `Import Key` (no link or QR tiles).
- Web: the BTC address is shown in the BTC (orange) colour with `Copy Link` and `QR Code` tiles.
- The clipboard holds the BTC address and the copy toast appears as in TC-SEND-024.

**Cleanup:** switch back to VFX.

### TC-SEND-026 · Copy the account's domain (web)
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Account A owns a VFX domain (from `07-domains.md`).

**Steps**
1. Open Receive with VFX selected.
2. Click `button "Copy domain"`.

**Expected**
- A second card shows the domain with the subtitle `Your Domain`.
- The toast reads `'<domain>' Copied to clipboard` and the clipboard holds the domain.
- For an account without a domain the card is absent.

**Cleanup:** none.

### TC-SEND-027 · Request funds link
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Receive screen with VFX selected for account A.

**Steps**
1. Tap `Copy Link`. Web: `fltA11y.tap("Copy")` or the `button` whose label starts with `Copy` and ends with `Link`. macOS: `tap-text $'Copy\nLink'`.
2. In the `Request Funds` prompt, press `Generate Link` with the field empty.
3. Type `1.2.3`, press `Generate Link`.
4. Type `5`, press `Generate Link`.
5. Read the clipboard, then open the link in the web build: replace `https://wallet-testnet.verifiedx.io/` with `http://localhost:42069/?automation=1` and load it.

**Expected**
- The prompt is titled `Request Funds` with the body `Generate a URL to send to another user.` and a field labelled `Amount to request`.
- Step 2: `Amount is required.`. Step 3: `Invalid Amount.`.
- Step 4: the prompt closes with the toast `Request funds link copied to clipboard`.
- The clipboard holds `https://wallet-testnet.verifiedx.io/#dashboard/send/vfx/<A address>/5.0` on macOS and `.../5` on web (the web build prints whole numbers without `.0`); the domain replaces the address when A owns one.
- Step 5 opens the prefilled Send screen as in TC-SEND-012 with A's address and the amount `5`.

**Cleanup:** press `Clear` on the Send screen.

### TC-SEND-028 · Request QR code
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Receive screen with VFX selected.

**Steps**
1. Tap `QR Code` (web: `fltA11y.tap("QR")`; macOS: `tap-text $'QR\nCode'`).
2. Enter `5` in `Amount to request` and press `Generate Link`.
3. Press `Save` (tooltip), then `Close`.

**Expected**
- A dialog shows a QR code (360 px) with a `Save` icon and a `Close` button. The QR encodes the same URL as TC-SEND-027 (decode the screenshot if a decoder is available).
- `Save` downloads or saves a PNG without an error toast; `Close` dismisses the dialog.

**Cleanup:** delete the saved QR file.

## Transaction list

### TC-SEND-029 · Desktop transactions screen modes and tabs
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Account A has at least one confirmed and, ideally, one failed or vault transaction.

**Steps**
1. `tap-key nav:transactions`.
2. Select `All`, then `VFX`, then `BTC` in the switch on the right of the app bar.
3. In VFX mode, open each tab: `All`, `Pending`, `Successful`, `Failed`, `Vaulted`.
4. In BTC mode, open `Transactions` and `Inputs`.

**Expected**
- The title reads `All Transactions`, `VFX Transactions` or `BTC Transactions` to match the switch.
- The filter icon (`tx:filter`, tooltip `Transaction Filters`) appears only in VFX mode.
- Each VFX tab lists only its status; an empty tab shows `No Transactions Found`.
- BTC mode shows the `Transactions` and `Inputs` tabs.
- The list refreshes on its own every 10 seconds while the screen is open.

**Cleanup:** leave the switch on VFX.

### TC-SEND-030 · Desktop transaction tile details and copy hash
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Exactly one tile on screen: right after TC-SEND-002, open the `Pending` tab, or narrow the list with filters (TC-SEND-033/034) until one tile remains.

**Steps**
1. Read the tile.
2. `tap-label "Copy transaction hash"` and check `pbpaste`.
3. `tap-label "Show details"`, read the expanded rows, then `tap-label "Hide details"`.

**Expected**
- The tile shows `Hash: <hash>`, `Amount: <n> VFX` (red when negative, green when positive), `Type: Tx`, `Status: <status>`, `To: <address>`, `From: <address>` (friendly names in brackets for own accounts) and `Date: <date>`.
- An outbox icon marks sends, an inbox icon receipts, a refresh icon self-sends.
- Copy shows `Hash copied to clipboard` and the clipboard holds the hash.
- Show details adds `Block Number`, `Fee`, `Nonce` and `Data` rows; Hide details removes them.

**Cleanup:** none.

### TC-SEND-031 · Desktop explorer link from a transaction
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Exactly one successful transaction tile on screen (filters or the `Successful` tab).

**Steps**
1. `tap-label "View on explorer"`.
2. Check the frontmost browser tab (Claude in Chrome `tabs_context_mcp`, if Chrome is the default browser).

**Expected**
- The browser opens `https://spyglass-testnet.verifiedx.io/transaction/<hash>` (mainnet: `https://spyglass.verifiedx.io/transaction/<hash>`) and the explorer shows the same transaction.
- Pending and failed tiles have no explorer icon.

**Cleanup:** close the tab.

### TC-SEND-032 · Web transactions screen
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Logged in as account A with VFX history; ideally a vault and a BTC key in the session.

**Steps**
1. Click `button "Transactions"` in the side nav.
2. Open the tabs `All`, `VFX`, `Vault`, `BTC`.
3. Scroll the `VFX` tab to the bottom.

**Expected**
- The app bar reads `Transactions` and there is no filter control on web.
- `All` interleaves VFX, vault and BTC entries, each with a coloured bar (blue VFX, purple vault, orange BTC).
- VFX cards show `<amount> VFX` (green received, red sent, secondary colour for moves between A and its vault) or the type label for non-transfer types, plus `From:`/`To:` and the date; settled vault receipts append `| Settlement Date: <date>`.
- A tab without history shows `No Transactions found for <address>.`
- Scrolling to the end loads the next page with a spinner.

**Cleanup:** none.

## Filters (desktop)

### TC-SEND-033 · Filter by transaction type
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Transactions screen in VFX mode with at least one `Tx` transaction.

**Steps**
1. `tap-key tx:filter`.
2. `tap-key tx:filter_type_0` (Tx).
3. `tap-key tx:filter_close`, read the `All` tab.
4. `tap-key tx:filter`, `tap-key tx:filter_type_0` to untick it, `tap-key tx:filter_type_38` (vBTC Bridge Unlock), close.

**Expected**
- The bottom sheet is titled `Transaction Filters` with `Clear Filters` and `Close`, a `Tx Type:` heading, the `All Addresses` dropdown and a grid of checkboxes for types 0 to 38 (`Tx`, `Node`, ..., `Vault`, ...).
- After ticking Tx the heading reads `Tx Type (1):` and the filter icon shows a red badge `1`.
- Step 3: only `Type: Tx` tiles are listed on every tab.
- Step 4: with a type that has no transactions the list reads `No Transactions Found` / `[with current filters]`.

**Cleanup:** TC-SEND-035.

### TC-SEND-034 · Filter by address
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** The wallet holds account A and at least one other account (for example a vault) with transactions.

**Steps**
1. `tap-key tx:filter`, `tap-key tx:filter_address`.
2. `tap-text` account A's address, close the sheet, read the list.
3. Open the sheet again, `tap-key tx:filter_address`, `tap-text "All Addresses"`.

**Expected**
- The dropdown lists `All Addresses` and every account in the wallet (vault addresses in purple), with a ticked box on the current choice.
- After step 2 the dropdown shows A's address, the badge counts one more filter, and only transactions where A is sender or receiver are listed.
- Step 3 restores `All Addresses` and lowers the badge by one.
- The web transactions screen has no address filter.

**Cleanup:** TC-SEND-035.

### TC-SEND-035 · Clear and close filters
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** At least one type filter and one address filter active.

**Steps**
1. Switch the tabs `All`, `Pending`, `Successful` and note that the filters still apply.
2. Switch the app bar to `All`, read the combined list, switch back to `VFX`.
3. `tap-key tx:filter`, `tap-key tx:filter_clear`, `tap-key tx:filter_close`.

**Expected**
- Filters apply to every VFX tab.
- In `All` mode the filter icon is hidden and the combined list is not filtered.
- After Clear Filters the heading reads `Tx Type:`, the dropdown reads `All Addresses`, all boxes are unticked, the badge disappears, and the full list returns.

**Cleanup:** none.

## Transaction detail (web)

### TC-SEND-036 · Open the transaction detail screen
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Account A has a confirmed VFX send (for example from TC-SEND-003).

**Steps**
1. On Transactions, tab `VFX`, click the confirmed card (it carries button semantics once it is no longer pending).
2. Read the screen, then go back with the app bar back arrow.

**Expected**
- The app bar reads `Transaction Detail` with a `View on explorer` icon.
- Cards, top to bottom: the hash (`Tx Hash`), the date (`Date`, format `MM-dd-yyyy hh:mm a`), `Block Height`, `Tx Type` (`Tx`), the recipient (`To`), the sender (`From`) with `[ME]` after A's address, `Amount` as `<n> VFX` and `Fee` as `<n> VFX`.
- The values match the explorer for the same hash.
- Back returns to the list on the same tab.

**Cleanup:** none.

### TC-SEND-037 · Copy hash and addresses from the detail screen
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Detail screen open (TC-SEND-036).

**Steps**
1. Click `button "Copy transaction hash"` and check the clipboard.
2. Click the first `button "Copy address"` (To) and the second (From), checking the clipboard after each.

**Expected**
- Each copy shows the toast `'<value>' Copied to clipboard` and the clipboard holds exactly the hash, the To address and the From address.

**Cleanup:** none.

### TC-SEND-038 · Explorer link from the detail screen
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Detail screen open.

**Steps**
1. Click `button "View on explorer"` in the app bar.

**Expected**
- A new tab opens on the Spyglass testnet explorer's transaction page for the hash and shows the same transaction.

**Open question:** the URL is built as `<base>/transaction/<hash>` where the base already ends in `/`, so it contains `//transaction/`. Confirm the explorer still resolves it.

**Cleanup:** close the tab.

### TC-SEND-039 · Detail screen by URL and for an unknown hash
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Logged in as account A; a known confirmed hash.

**Steps**
1. Load `http://localhost:42069/?automation=1#/dashboard/transactions/detail/<known hash>`.
2. Load the same URL with a made-up hash of the same length.

**Expected**
- Step 1 renders the detail screen of TC-SEND-036 directly.
- Step 2 shows a spinner and then the text `Error` (no transaction) or `An error occurred`, and no crash.

**Open question:** the detail provider is not `.autoDispose` and is not invalidated from the session loop, unlike the convention for web detail screens, so a detail opened while pending data was stale may keep the old values until reload. Check whether reopening a recently confirmed transaction shows its final block height.

**Cleanup:** none.
