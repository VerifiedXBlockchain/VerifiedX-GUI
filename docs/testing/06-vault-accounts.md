# 06 · Vault accounts

This area covers Vault (reserve, `xRBX`) accounts on both platforms: creating one, funding and activating it, sending from it under a timelock, calling a send back, recovering the whole account to its recovery address, restoring it from a restore code, revealing its keys, and the manage, assets and balance-help screens. The rules the cases assert come from the code. A Vault has its own address starting `xRBX` and a paired recovery key; the desktop creates it through the Core CLI (`/rsapi/RSV1/NewReserveAddress`, protected by a Vault password), while the web wallet derives one Vault per login key automatically, so web has no "setup" step. A Vault must hold at least 5 VFX before it can be activated, and activation burns 4 VFX plus the fee (`Register()` on `Reserve_Base`); until it is activated the desktop shows `Not Activated`, disables sending and refuses to copy its receive address. Every send from a Vault asks for a timelock in hours with a 24-hour minimum (lower values are raised to 24): the transaction stays in `Vault` status and the recipient's funds stay locked until the settlement time, and until then the sender can call it back to the Vault. The web wallet also keeps at least 0.5 VFX in a Vault. Recovery is destructive: it calls back every unsettled transaction and asset and moves the available balance to the recovery address, after which the Vault is deactivated for good. Code: `lib/features/reserve/`, `lib/features/send/providers/send_form_provider.dart`, `lib/features/web/components/web_*_ra_button.dart`, `lib/features/web/components/web_callback_button.dart`, `lib/features/reserve/components/callback_button.dart`.

## Area preconditions

- macOS: the Flutter Driver build is running, account A (`TEST_VFX_A_PRIVKEY`) is imported and selected, the chain is synced, and A holds at least 40 VFX and is not validating (the funding shortcut only offers non-vault accounts holding more than 6 VFX, or more than 1006 while validating). Open the area with `tap-key nav:vault_accounts`.
- Web: the automation build is open at `http://localhost:42069/?automation=1`. Open the area with `button "Vault Account"` in the side nav.
- Web lifecycle cases use a fresh web account created for this run (the "run web account"), because a web Vault is tied to its login key: it can be activated only once, and after a recovery it stays deactivated forever. Create it through the create-wallet flow in `01-launch-auth.md`, send it 20 VFX from account A, and keep its mnemonic or key only in the browser session. Account A's own web Vault is used only by read-only cases.
- Vault password: use `TEST_ENCRYPTION_PASSWORD` wherever a case asks for the Vault password, on both platforms (the web wallet only asks when its storage is encrypted).
- Restore codes are secrets. When a case says to keep one, save it to `$TMPDIR/vfx-run-<run id>/` with mode 600, outside the repo, read it back with `cat` only to type it into the app, and delete the folder in the area cleanup (TC-VAULT-032). Never paste a restore code or private key into results, screenshots' names or chat.
- Run the cases in file order: they chain (the desktop Vault created in TC-VAULT-003 is "Vault D", the second desktop Vault from TC-VAULT-006 is "Vault E", the run web account's Vault is "Vault W"). Record each Vault's address (addresses are not secret) in the run notes.
- Chain waits: funding, activation, sends, callbacks and recoveries each confirm within 2 minutes on testnet; the desktop lists refresh every 10 seconds on the Transactions screen, the web status on the session loop. Timelocks are at least 24 hours, so settlement is checked in a later pass (TC-VAULT-021).
- Known hook gaps (record as `blocked` with this note rather than failing the feature): the Manage card can render two widgets keyed `reserve:activate:<address>` (the status badge's `Activate Now` and the `Activate\nAccount` tile), so `tap-key` fails with "Too many elements" there; use the overview screen's key. The desktop activation dialog's confirm button reads `Activate Now`, the same text as the button behind it, and `ConfirmDialog` buttons have no keys. With more than one Vault listed, `tap-label "Vault Account Balance"` and `tap-label "Copy address"` match several widgets.

## Overview and information

### TC-VAULT-001 · Desktop Vault Accounts screen and info dialog
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Area preconditions. For the empty state, a wallet with no Vaults (fresh automation folder).

**Steps**
1. `tap-key nav:vault_accounts`.
2. `tap-text "What are Vault Accounts?"`, read the dialog, `tap-text Close`.

**Expected**
- The app bar reads `Vault Accounts` with a `What are Vault Accounts?` link on the right.
- With no Vaults: a `Setup New Account` button (`reserve:setup_new_account`), the heading `Existing Accounts`, the text `No Vault Accounts` and a `Restore Vault Account` button (`reserve:restore`). With Vaults: a `Manage Vault Accounts` button (`reserve:manage_vault_accounts`) next to `Setup New Account`, one card per Vault, and `Restore Vault Account` at the bottom.
- The dialog explains Vault Accounts: it starts `Vault Accounts [xRBX] is a Cold Storage and On-Chain Escrow Feature to keep your VFX Funds and your Digital Assets Safe.`, mentions recovery and call-back `within 24 hours of occurrence or within a user pre-set defined time`, and ends `Note: Activating this feature requires a 5 VFX deposit, 4 of which will be burned upon activation.`

**Cleanup:** none.

### TC-VAULT-002 · Web Vault Account screen
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Logged in as account A on web.

**Steps**
1. Click `button "Vault Account"` in the side nav.
2. Click the copy icon next to the address (`button "Copy address"`) and check the clipboard.
3. Click `button "What are Vault Accounts?"`, read, and close.

**Expected**
- The app bar reads `Your Vault Account`.
- The card shows `Address:` with an address starting `xRBX` in purple, `Available Balance:` with `<n> VFX`, and `Status:` with one of: `Activated` (badge), `Awaiting Funds` with a `Fund Account` button (balance below 5 VFX), `Activate Now` (5 VFX or more, not activated) or `Pending Activation`.
- When the Vault is not activated, a `Warning` heading above the card reads `Your vault account is not activated yet. To protect funds and assets securely, please activate first.`
- The buttons `Send Funds`, `Manage Assets`, `Receive Assets` and `Recover` sit under the card, and `Restore Vault Account` sits below it.
- Copy shows `Address copied to clipboard` and the clipboard holds the Vault address.
- The info dialog shows the same text as TC-VAULT-001.
- Logging out and back in with the same key shows the same Vault address (it is derived from the login key).

**Cleanup:** none.

## Create a Vault (desktop)

### TC-VAULT-003 · Setup New Account password validation
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Vault Accounts screen open.

**Steps**
1. `tap-key reserve:setup_new_account`.
2. In `Setup Vault Account`, `tap-text Submit` with the field empty.
3. `type` the Vault password, `tap-text Submit`.
4. In `Confirm Password`, `type` a different value, `tap-text Submit`.
5. Repeat steps 1 and 3, then press `Cancel` in `Confirm Password`.

**Expected**
- The first prompt is titled `Setup Vault Account` with the body `Create a password to continue. You must remember this password as it will be required for any transaction with this Vault Account.`, a field labelled `Password` (obscured, with a `Show password` eye) and `Cancel`/`Submit`.
- Step 2: `Password is required.` under the field.
- The second prompt is titled `Confirm Password` with the body `Please confirm your password.`
- Step 4: red toast `Passwords do not match.` and no Vault is created.
- Step 5: red toast `You must confirm your password.` and no Vault is created.

**Cleanup:** none.

### TC-VAULT-004 · Create a Vault and back up its keys (Vault D)
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Vault Accounts screen open.

**Steps**
1. `tap-key reserve:setup_new_account`, enter the Vault password twice (`type`, `tap-text Submit`, `type`, `tap-text Submit`).
2. In `Vault Account Created`, `tap-label "Copy restore code"` and save `pbpaste` to `$TMPDIR/vfx-run-<run id>/vault-d.restore` (mode 600).
3. `tap-text "Copy All"`, then `tap-label "Copy address"` and record the address as Vault D.
4. `tap-text Close`, then in `Backed up?` `tap-text Cancel`; `tap-text Close` again and `tap-text "I'm Backed Up"`.
5. In the `Fund Account` dialog that follows, `tap-text Cancel`.

**Expected**
- The dialog `Vault Account Created` shows the red line `🚨 Make sure to backup your RESTORE CODE somewhere safe. 🚨`, a read-only `Restore Code` field, `Copy All` and `Save as File` buttons, the note `You will need the Restore Code and Password to Recover any transaction. It is highly advised to copy all and store safely as you would for any private key.`, then read-only `Address` (starts `xRBX`), `Private Key`, `Recovery Address` and `Recovery Private Key`, each with a copy icon.
- Copy toasts: `Restore Code copied to clipboard`, `Vault Account Data copied to clipboard`, `Address copied to clipboard`.
- `Backed up?` reads `Please confirm you have backed up your RESTORE CODE as well as your PASSWORD.`; Cancel keeps the details dialog open (it cannot be dismissed by tapping outside), `I'm Backed Up` closes it.
- The Vault appears on the Vault Accounts screen with its address in purple, `Available: 0.0 VFX`, and an `Awaiting Funds` button (`reserve:awaiting_funds:<Vault D>`).
- The Send screen's `From:` dropdown now lists Vault D in purple.

**Cleanup:** keep the restore-code file until TC-VAULT-032.

## Fund and activate (desktop)

### TC-VAULT-005 · Fund Vault D from account A and auto-activate
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Vault D awaiting funds (TC-VAULT-004). Account A holds more than 6 VFX.

**Steps**
1. `tap-key reserve:awaiting_funds:<Vault D>`.
2. In `Fund Account`, `tap-text Send`; in `Please Confirm`, `tap-text Send` (see the hook gap note in `03-send-receive-transactions.md`).
3. In `Funds Sent`, `tap-text Close`.
4. In `Auto Activate?`, `tap-text Yes`; in the `Password` prompt `type` the Vault password and `tap-text Submit`.
5. Wait up to 2 minutes for the funding transaction to confirm, then up to 2 more minutes for the activation.

**Expected**
- `Fund Account` reads `You must now fund your Vault Account with a minimum of 5 VFX. 4 VFX will be burned upon activation.`, `Please send funds to <Vault D>`, and `You have an account with a sufficient balance.` / `Would you like to send 5 VFX from:` / A's address / `[Balance: <n> VFX]?`.
- `Please Confirm` reads `Sending:` / `5.0 VFX` / `To:` / Vault D / `From:` / A's address.
- `Funds Sent` reads `5.0 VFX has been sent to <Vault D>.` / `Please wait for transaction to reflect and then activate your Vault Account.`
- `Auto Activate?` reads `Would you like to automatically activate this account once the funds are received?`; after the password the toast reads `Auto activate queued.` and the status shows `Activation Pending`.
- When the 5 VFX arrive, the toast `Vault Account Auto Activation process initiated` appears, and within 2 more minutes the card shows the `Activated` badge and a `Recover` button (`reserve:recover:<Vault D>`).
- Vault D's available balance ends below 1 VFX (5 minus 4 burned minus fees); account A's balance fell by 5 VFX plus the fee.

**Cleanup:** none.

### TC-VAULT-006 · Fund a second Vault manually (Vault E)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Account A holds more than 6 VFX.

**Steps**
1. Create Vault E as in TC-VAULT-004 steps 1 to 4 (no need to keep its restore code), record its address.
2. In `Fund Account`, `tap-text Send`, confirm `Please Confirm`, close `Funds Sent`.
3. In `Auto Activate?`, `tap-text No`.
4. Wait up to 2 minutes and watch Vault E's card.

**Expected**
- Before funds land, the card shows `Awaiting Funds`.
- Once the 5 VFX confirm (limit 2 minutes), the card shows `Available: 5.0 VFX` and an `Activate Now` button keyed `reserve:activate:<Vault E>`; no activation happens by itself.

**Cleanup:** none.

### TC-VAULT-007 · A Vault that is not activated cannot send or share its address
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Vault E funded and not activated (TC-VAULT-006).

**Steps**
1. `tap-key reserve:manage_vault_accounts`, then `tap-key reserve:send_funds:<Vault E>`.
2. Fill `send:address` with B's address and `send:amount` with `1`, then `tap-key send:submit`.
3. Go back to Manage Vault Accounts, `tap-key reserve:receive_assets:<Vault E>`.
4. `tap-key receive:copy_address`.

**Expected**
- The Send screen shows Vault E in the `From:` dropdown in purple with a red `Not Activated` badge, and the `Send` button does nothing (it is disabled).
- The Receive screen shows the red `Not Activated` badge, the subtitle `Your Selected VFX Vault Account Address`, and copying shows the red toast `This Vault Account has not been activated yet.`; the clipboard is unchanged. The `Copy\nAddress` tile behaves the same way.

**Cleanup:** select account A again (Send `From:` dropdown).

### TC-VAULT-008 · Activation with a wrong password
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Vault E funded and not activated.

**Steps**
1. On the Vault Accounts overview, `tap-key reserve:activate:<Vault E>`.
2. In `Activate on Network?`, tap the dialog's `Activate Now` (see the hook gap note).
3. In `Password`, `type` a wrong password and `tap-text Submit`.

**Expected**
- `Activate on Network?` reads `There is a cost of 4 VFX (which is burned) plus TX fee to activate this Vault Account on the network.  Continue?`.
- After the wrong password an `Error` dialog shows the Core CLI's message, and the card still shows `Activate Now` (not `Activation Pending`). No transaction appears.

**Open question:** record the CLI's exact wrong-password message so the next pass can assert it.

**Cleanup:** close the error dialog.

### TC-VAULT-009 · Activate a funded Vault manually
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Vault E funded and not activated.

**Steps**
1. `tap-key reserve:activate:<Vault E>`, confirm `Activate Now`, `type` the Vault password, `tap-text Submit`.
2. Close the `Success` dialog. Wait up to 2 minutes.

**Expected**
- A `Success` dialog reads `Vault Account activation transaction sent.` / `Please wait for it to reflect as "Activated".`
- The card shows `Activation Pending`, then within 2 minutes the `Activated` badge and a `Recover` button.
- Vault E's balance ends below 1 VFX (4 VFX burned plus the fee).

**Cleanup:** none.

## Fund and activate (web)

### TC-VAULT-010 · Fund the web Vault (Vault W)
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Logged in as the run web account, which holds at least 15 VFX; its Vault shows `Awaiting Funds`. Record the Vault address as Vault W.

**Steps**
1. On `Your Vault Account`, click `button "Fund Account"`.
2. In `Fund Your Vault Account`, click `button "Send"`.
3. In `Automatically Activate?`, click `button "No"`.
4. Wait up to 2 minutes and watch `Available Balance:` and `Status:`.

**Expected**
- `Fund Your Vault Account` reads `Would you like to send 5 VFX from <run account address>?`; `Automatically Activate?` reads `Would you like to activate the account automatically once the funding is complete?`.
- A green toast reads `5 VFX sent to <Vault W>` and the `Fund Account` button becomes disabled.
- Within 2 minutes `Available Balance:` shows `5 VFX` and the status changes to an `Activate Now` button.

**Open question:** the `Automatically Activate?` question is asked even when the first dialog was cancelled; is that intended? With auto-activate on, does the web wallet see the incoming Vault transaction and activate (it listens on the transaction signal)? This pass answers No so the next case can test the manual path; try Yes on the next run.

**Cleanup:** none.

### TC-VAULT-011 · Sending from a web Vault that is not activated
**Platforms:** Web · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** Vault W funded with 5 VFX and not activated.

**Steps**
1. Click `button "Send Funds"` (`reserve:send_funds`).
2. Fill B's address and amount `1`, click the form's `button "Send"`, confirm `Please Confirm`, accept the `Timelock Duration` default `24`, and stop at the `Valid Transaction` dialog or the error toast; press `Cancel` if `Valid Transaction` appears.

**Expected**
- The Send screen opens with the `Vault` segment selected and Vault W as sender.
- The web form has no `Not Activated` guard, so the outcome is decided by the node: either a red toast with the node's refusal, or a `Valid Transaction` dialog (cancelled here).

**Open question:** should the web wallet block sends from a Vault that is not activated, as the desktop does (`You must activate your Vault Account before proceeding.`)? Record what the node answers.

**Cleanup:** press `Clear`.

### TC-VAULT-012 · Activate the web Vault
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Vault W holds 5 VFX, not activated.

**Steps**
1. On `Your Vault Account`, click `button "Activate Now"`.
2. In `Activate Vault Account?`, click `button "Cancel"`; then click `Activate Now` again and click `button "Activate"`.
3. Wait up to 2 minutes.

**Expected**
- The dialog reads `There is a cost of 4 VFX to activate your Vault Account which is burned.` / `Continue?`. Cancel sends nothing.
- After Activate, a loading overlay shows, then the toast `Activation transaction broadcasted` and a `Pending Activation` badge.
- Within 2 minutes the status shows the `Activated` badge and the `Warning` banner is gone. The available balance is below 1 VFX.

**Cleanup:** send 10 VFX from the run web account's VFX address to Vault W (normal send, `03-send-receive-transactions.md` TC-SEND-003) and wait for it to confirm, for the send cases below.

## Balance help

### TC-VAULT-013 · Vault balance help
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** At least one Vault with a balance (macOS: only one Vault card on screen, or use the bottom sheet of TC-VAULT-022).

**Steps**
1. Web: on `Your Vault Account`, click `button "Vault Account Balance"` (the help icon after the balance). macOS: `tap-label "Vault Account Balance"` on the overview card.
2. Close the dialog (`button "Close"` / `tap-text Close`).

**Expected**
- Web: a dialog titled `Vault Account Balance` with the lines `Available: <a> VFX`, `Locked: <l> VFX`, `Total: <t> VFX`.
- macOS: a dialog titled `Vault Account Balance` with three indicators `Available:`, `Locked:` and `Total:`, each `<n> VFX`.
- The values add up (`Total` = `Available` + `Locked`) and `Available` matches the card.

**Cleanup:** none.

## Send from a Vault, timelock and callback

### TC-VAULT-014 · Send from a desktop Vault with a timelock
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Vault D activated. Send 10 VFX from account A to Vault D first (TC-SEND-002 with Vault D as recipient) and wait up to 2 minutes for it to confirm.

**Steps**
1. `tap-key reserve:manage_vault_accounts`, `tap-key reserve:send_funds:<Vault D>`.
2. `tap-key send:address`, `type` B's address; `tap-key send:amount`, `type 2`; `tap-key send:submit`.
3. In `Please Confirm`, tap `Send`.
4. In `Vault Account Password`, `type` the Vault password, `tap-text Submit`.
5. In `Timelock Duration`, the field `Hours (24 Minimum)` holds `24`; `type 25`, `tap-text Submit`.
6. `tap-key nav:transactions`, VFX, tab `Vaulted`; wait up to 2 minutes.

**Expected**
- The Send screen shows Vault D as `From:` in purple with no `Not Activated` badge.
- After step 5 a green toast reads `2 VFX has been sent to <B address>. See dashboard for TX ID.`, the log panel gains `Success! TX ID: <hash>`, and the form clears.
- Within 2 minutes the transaction is listed on `Vaulted` with `Status: Vault`, `Amount: -2.0 VFX`, a `Settlement Date:` about 25 hours from now, and a `Callback` button.
- On B's side (B's web session, Send form with VFX selected) the balance shows `Locked:` increased by 2 VFX and `Available:` unchanged.

**Cleanup:** none (TC-VAULT-016 calls it back).

### TC-VAULT-015 · Wrong Vault password on send
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Vault D activated with at least 3 VFX available.

**Steps**
1. As TC-VAULT-014 steps 1 to 3 with amount `1`.
2. In `Vault Account Password`, `type` a wrong password, `tap-text Submit`; accept the timelock default.

**Expected**
- A red toast shows the CLI's refusal message, the form keeps its values, the `Send` button stops spinning, and no new transaction appears on `Vaulted` or `Pending` within 30 seconds.
- Pressing `Cancel` in the password prompt instead ends the flow silently with nothing sent.

**Open question:** record the CLI's exact wrong-password message.

**Cleanup:** press `Clear`.

### TC-VAULT-016 · Call back a desktop Vault send
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** The TC-VAULT-014 transaction is in `Vault` status and before its settlement date.

**Steps**
1. On Transactions, VFX, tab `Vaulted` (filter by Vault D's address if more than one Vault transaction is listed), `tap-text Callback`.
2. In `Callback Transaction`, `type` the Vault password, `tap-text Submit`.
3. Wait up to 2 minutes.

**Expected**
- The prompt reads `Callbacks can be used to return the funds/assets to the same account for escrow purposes. Input your password to callback this transaction.`
- A green toast reads `Callback TX sent with hash of <hash>` and the `Callback` button becomes disabled.
- Within 2 minutes the original transaction shows `Status: Called Back`, a new `Type: Vault` transaction appears with an `Original TX` button that opens the original tile in a sheet, Vault D's available balance rises back by 2 VFX less fees, and B's `Locked:` balance drops by 2 VFX.

**Cleanup:** none.

### TC-VAULT-017 · Timelock below 24 hours is raised to 24
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** macOS: Vault D with at least 2 VFX available. Web: Vault W activated with at least 3 VFX available.

**Steps**
1. Send `1` VFX from the Vault to B (macOS as TC-VAULT-014; web as TC-VAULT-018), and in `Timelock Duration` replace `24` with `1`.
2. Wait up to 2 minutes and read the transaction.

**Expected**
- The field accepts digits only.
- The transaction is sent and its settlement date is about 24 hours from now, not 1 hour: macOS tile `Settlement Date: <date>`, web card `<date> | Settlement Date: <date>`.
- B's `Locked:` balance rises by 1 VFX.

**Cleanup:** leave this transaction locked; TC-VAULT-020 and TC-VAULT-021 use it.

### TC-VAULT-018 · Send from the web Vault with a timelock
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Vault W activated with at least 3 VFX available (after the top-up in TC-VAULT-012).

**Steps**
1. On `Your Vault Account`, click `button "Send Funds"`.
2. Fill `textbox "Recipient's Account Address"` with B's address and `textbox "Amount of VFX to send"` with `2`; click the form's `button "Send"`.
3. In `Please Confirm`, click `button "Send"`.
4. In `Timelock Duration` (field `Hours (24 Minimum)`, default `24`), type `25` and click `button "Submit"`.
5. In `Valid Transaction`, click `button "Send"`.
6. Open Transactions, tab `Vault`; wait up to 2 minutes.

**Expected**
- The Send screen opens with the `Vault` segment selected, Vault W as sender and its balance in the Vault colour.
- `Please Confirm` shows Vault W as `From:`; `Valid Transaction` shows `Amount: 2 VFX` and the fee.
- The toast reads `2 VFX sent to <B address>`.
- The card on the `Vault` tab shows `2 VFX` (red), `To: <B address>` and `<date> | Settlement Date: <about 25 hours from now>`, plus a `Callback` button once it is no longer pending.

**Cleanup:** none (TC-VAULT-019 calls it back).

### TC-VAULT-019 · Call back a web Vault send
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** The TC-VAULT-018 transaction is confirmed and before its settlement date.

**Steps**
1. On Transactions, tab `Vault`, click the card's `button "Callback"`.
2. In `Callback Transaction`, click `button "Cancel"`; then click `Callback` again and click the dialog's `button "Callback"`.
3. Wait up to 2 minutes.

**Expected**
- The dialog reads `Are you sure you want to callback this transaction?`; Cancel sends nothing.
- After confirming, the toast reads `Callback TX broadcasted`.
- Within 2 minutes the original card shows `CALLED BACK` instead of the button, a callback card appears reading `<text> [2 VFX from <address>]` with an `Original TX` button that opens the original transaction's detail, and Vault W's available balance rises back by 2 VFX less fees.

**Cleanup:** none.

### TC-VAULT-020 · Web Vault must keep 0.5 VFX, and locked funds cannot be spent
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Vault W activated with available balance `v`. B holds locked funds from TC-VAULT-017.

**Steps**
1. As the run web account, open Send with the `Vault` segment, fill B's address and amount `v - 0.25`, submit.
2. Change the amount to `v + 1`, submit.
3. As account B (second session), open Send with VFX selected and read the balance; enter A's address and an amount larger than `Available:` but smaller than `Total:`, submit.

**Expected**
- Step 1: `A Vault must keep 0.5 VFX. Available to send: <v - 0.5> VFX` under the amount; no dialog.
- Step 2: `Not enough balance in account.`
- Step 3: the form shows `Available:`, `Locked:` and `Total:` indicators, and submitting shows `Not enough balance in account.` (locked funds do not count as spendable).

**Cleanup:** press `Clear` in both sessions.

### TC-VAULT-021 · Settlement after the timelock
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Run this in a later pass, no earlier than the settlement date of the TC-VAULT-017 transaction(s). Limit: the settlement date plus 1 hour.

**Steps**
1. Find the TC-VAULT-017 transaction on the sender's list (macOS `Vaulted`/`Successful` tabs; web `Vault` tab) and on B's list.
2. Read B's balance indicators.

**Expected**
- The transaction no longer offers `Callback` and no longer shows a settlement date; on macOS it has left `Status: Vault`.
- B's `Locked:` balance has dropped by the settled amount and `Available:` has risen by it.

**Cleanup:** none.

## Manage and assets

### TC-VAULT-022 · Manage Vault Accounts screen
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** At least one activated Vault.

**Steps**
1. `tap-key reserve:manage_vault_accounts`.
2. Read one card; tap its copy icon (`tap-label "Copy address"` when one card is shown) and check `pbpaste`.
3. Go back to the overview and `tap-text` an activated Vault's address to open its bottom sheet.

**Expected**
- The app bar reads `Manage Vault Accounts`, with `Setup New Account` and `Restore Vault Account` on top, or `No Vault Accounts` when there are none.
- Each card shows `Address:` (purple) with a copy icon, `Available Balance:` `<n> VFX` with the balance help icon, `Status:` with the same badge as the overview, and the actions `Send Funds`, `Manage Assets`, `Receive Assets`, plus `Recover` for an activated Vault and `Activate\nAccount` when the balance is at least 5 VFX and no activation is pending.
- Copy shows `Address copied to clipboard`.
- Tapping an activated Vault on the overview opens the same card in a bottom sheet; a Vault that is not activated does not react.

**Open question:** the `Activate\nAccount` tile is also shown on a Vault that is already activated once it holds 5 VFX or more; is that intended, and what does activating twice return?

**Cleanup:** none.

### TC-VAULT-023 · Manage Assets on a Vault without assets
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** A Vault that holds no NFTs, fungible tokens or vBTC (Vault E on macOS, Vault W on web).

**Steps**
1. Open Manage Assets. Web: `button "Manage Assets"` (`reserve:manage_assets`). macOS: `tap-key reserve:manage_assets:<Vault E>`.
2. Pick `NFTs`; reopen and pick `Fungible Tokens`; reopen and pick `Bitcoin (vBTC)`.

**Expected**
- A bottom sheet lists `NFTs`, `Fungible Tokens` and `Bitcoin (vBTC)` as tappable tiles.
- macOS: `NFTs` and `Fungible Tokens` show the toast `This account has no assets/NFTS.`; `Bitcoin (vBTC)` shows `This account has no vBTC Tokens`.
- Web: red toasts `Your Vault Account has no NFTS.`, `Your Vault Account has no Fungible Tokens.` and `Your Vault Account has no vBTC Tokens.`

**Cleanup:** none.

### TC-VAULT-024 · Manage Assets lists a Vault's NFT
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** An NFT owned by a Vault (transferred there in `09-smart-contracts-nfts.md`); if none exists yet, mark this case `blocked` and rerun after 09.

**Steps**
1. Open Manage Assets for that Vault and pick `NFTs`.
2. macOS: tap `View Details` on the NFT. Web: click the NFT tile.

**Expected**
- macOS: a sheet headed `Manage Assets` lists the NFT with `Transfer` and `View Details` buttons; `View Details` opens the NFT detail screen.
- Web: a sheet lists the NFT with its name and description; clicking it opens the NFT detail screen.
- Transferring an NFT out of a Vault (`Transfer`) is covered in `09-smart-contracts-nfts.md`.

**Cleanup:** none.

### TC-VAULT-025 · Send Funds and Receive Assets shortcuts
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** An activated Vault (Vault D on macOS, Vault W on web).

**Steps**
1. macOS: `tap-key reserve:receive_assets:<Vault D>`, then `tap-key receive:copy_address`. Web: click `button "Receive Assets"` (`reserve:receive_assets`), then `button "Copy address"`.
2. Return to the Vault screen and use `Send Funds` (macOS `reserve:send_funds:<Vault D>`, web `reserve:send_funds`).

**Expected**
- Receive opens with the Vault selected: macOS subtitle `Your Selected VFX Vault Account Address`, web the `Vault` segment with the address in purple. Copy puts the Vault address on the clipboard with the usual copy toast.
- Send opens with the Vault as sender (macOS `From:` dropdown in purple; web `Vault` segment).

**Cleanup:** select account A again on macOS; select `VFX` on web.

## Restore

### TC-VAULT-026 · Restore a Vault from its restore code (web)
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as account A on web. Vault D's restore code saved in TC-VAULT-004.

**Steps**
1. On `Your Vault Account`, click `button "Restore Vault Account"`.
2. In the confirmation, click `button "No"`; open it again and click `button "Yes"`.
3. In `Restore Code`, type the saved code (read it with `cat`), click `button "Submit"`.
4. Log out and log back in as account A.

**Expected**
- The confirmation is titled `Restore Vault Account` and reads `Importing an existing Vault Account will replace the current one tied to your login. To revert you can logout and login again.` / `Continue?`; No does nothing.
- The prompt reads `Paste in your RESTORE CODE to import your existing Vault Account.`
- After Submit, the toast `Vault Account restored` appears and the screen shows Vault D's address, its balance and `Activated`.
- After logging in again, A's own derived Vault address is back.

**Open question:** is the desktop CLI restore code format the same as the web one (base64 of `private//recovery private`)? If step 3 fails, record it and retry with Vault W's restore code in TC-VAULT-027 instead.

**Cleanup:** step 4.

### TC-VAULT-027 · Restore a Vault from its restore code (desktop)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Vault W's restore code, copied from the web `Vault Account Details` dialog (reveal from the dashboard account menu, `02-dashboard-navigation-settings.md`, or TC-VAULT-030) and saved as in the area preconditions. Vault W is not in the desktop wallet yet.

**Steps**
1. On Vault Accounts, `tap-key reserve:restore`.
2. In `Restore Code` (body `Paste in your RESTORE CODE to import your existing Vault Account.`), `type` the code, `tap-text Submit`.
3. In `Password`, `type` the Vault password, `tap-text Submit`.
4. Close the details dialog as in TC-VAULT-004 step 4.

**Expected**
- A `Vault Account Created` details dialog shows Vault W's address, its recovery address and the restore code.
- Vault W appears in the list with its balance after the CLI rescans (limit 2 minutes) and the `Activated` badge.

**Open question:** which password does a restored web Vault take on the desktop: any new password, or must it match something? The CLI decides; record the behaviour.

**Cleanup:** none.

### TC-VAULT-028 · Restore with an invalid restore code
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Vault screen open.

**Steps**
1. Start `Restore Vault Account` (web: confirm `Yes` first) and submit `not-a-restore-code`; on macOS also submit a password.

**Expected**
- macOS: a red toast with the CLI's message, or `A problem occurred`; no Vault is added.
- Web: the Vault shown does not change and no `Vault Account restored` toast appears.

**Open question:** on web an undecodable code throws inside the button handler and nothing is shown to the user; should it show an error toast? Record what appears (check the console with `read_console_messages`).

**Cleanup:** none.

## Recover and reveal keys (destructive, run last)

### TC-VAULT-029 · Recover the web Vault
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Logged in as the run web account. Vault W activated, holding at least 1 VFX available, and with one unsettled Vault send outstanding (send 1 VFX to B as in TC-VAULT-018 and do not call it back). This permanently deactivates Vault W.

**Steps**
1. On `Your Vault Account`, click `button "Recover"`.
2. In `Recover Funds & NFTs`, read the recovery address, then click `button "Proceed"`.
3. Wait up to 2 minutes, then check the recovery address on `https://spyglass-testnet.verifiedx.io/`.
4. Reload the page (with `?automation=1`), log in as the run web account again, and open `Your Vault Account`.

**Expected**
- The dialog reads `This is a destructive function that will callback all pending transactions and assets and move everything to this recovery address:` followed by the recovery address, with `Cancel` and a red `Proceed`.
- After Proceed, a loading overlay shows, then the toast `Recovery transaction broadcasted.`; the `Recover` button becomes disabled and `Status:` shows `Recovery In Progress`, the explanation text, and a `Reveal Keys` button (`reserve:reveal_keys`).
- Within 2 minutes the recovery address holds Vault W's former available balance plus the outstanding 1 VFX send (called back), less fees, and B's locked 1 VFX is gone.
- After step 4 the screen shows `Warning` and `This vault account has been recovered and therefore deactivated.` / `Please create a new web wallet account if you'd like to use this feature.`

**Cleanup:** none.

### TC-VAULT-030 · Reveal Vault keys
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Immediately after TC-VAULT-029 step 2, while `Recovery In Progress` is shown (the button only exists in that state; the dashboard account menu reveals the same dialog at any time).

**Steps**
1. Click `button "Reveal Keys"`.
2. If the session storage is encrypted, enter `TEST_ENCRYPTION_PASSWORD` in the password prompt.
3. Click each copy icon (`Copy address`, `Copy private key`, `Copy recovery address`, `Copy recovery private key`, `Copy restore code`), then `button "Done"`.

**Expected**
- With encrypted storage the prompt reads `Enter your password to reveal Vault account private keys.`; a wrong password does not open the dialog.
- The dialog `Vault Account Details` reads `Here are your Vault Account details. Please ensure to back up your private key in a safe place.` and shows read-only `Address`, `Private Key`, `Recovery Address`, `Recovery Private Key` and `Restore Code`, then `Copy All` and `Done`.
- The recovery address matches the one shown in TC-VAULT-029's dialog.
- Toasts: `Public key copied to clipboard` (address), `Private key copied to clipboard`, `Recovery Address copied to clipboard`, `Recovery Private Key copied to clipboard`, `Restore Code copied to clipboard`. The dialog cannot be dismissed by clicking outside; `Done` closes it.

**Open question:** the address copy shows `Public key copied to clipboard`; should it say the address was copied?

**Cleanup:** clear the clipboard.

### TC-VAULT-031 · Recover with a wrong restore code (desktop)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Vault D activated.

**Steps**
1. On the overview, `tap-key reserve:recover:<Vault D>`.
2. In `Recover Funds & NFTs`, `tap-text Proceed`; in `Backup Media`, `tap-text No`.
3. In `Restore Code`, `type not-a-restore-code`, `tap-text Submit`; in `Password`, `type` the Vault password, `tap-text Submit`.

**Expected**
- `Recover Funds & NFTs` reads `This is a destructive function that will callback all pending transactions and assets and move everything to this recovery account:` followed by Vault D's recovery address.
- `Backup Media` reads `NFT Media will not be transferred in this process. Would you like to export a backup now now so you can import into your new environment?` with `No` and `Backup`.
- The `Restore Code` prompt body reads `Paste in your RESTORE CODE to import the recovery account for this Vault Account.`
- After the wrong code, a red toast shows the CLI's refusal, Vault D stays listed and `Activated`, and no recovery dialog opens.

**Open question:** record the CLI's exact refusal text.

**Cleanup:** none.

### TC-VAULT-032 · Recover a desktop Vault
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Vault D activated with at least 1 VFX available and one unsettled Vault send outstanding (send 1 VFX to B as in TC-VAULT-014 and do not call it back). Vault D's restore code saved in TC-VAULT-004. This permanently deactivates Vault D and closes the app.

**Steps**
1. `tap-key reserve:recover:<Vault D>`, `tap-text Proceed`, then `tap-text No` in `Backup Media`.
2. In `Restore Code`, `type` the saved code; in `Password`, `type` the Vault password; submit both.
3. Read the `Recovery process has started` dialog, then `tap-text "Close Wallet"`.
4. Wait up to 2 minutes and check Vault D's recovery address on `https://spyglass-testnet.verifiedx.io/`.
5. Relaunch the driver build (`make run_macos_driver`) and open Vault Accounts.
6. Delete `$TMPDIR/vfx-run-<run id>/`.

**Expected**
- Vault D disappears from the list before the dialog opens, and if it was the selected wallet another account becomes selected.
- The dialog `Recovery process has started` reads `Your Reserve (Protected) Account is being recovered to your recovery address.`, `Transaction Hash: <hash>`, and the advice to import the recovery private key on a new machine, with `Export NFT Media` and `Close Wallet` buttons. It cannot be dismissed by tapping outside.
- `Close Wallet` stops the Core CLI and closes the app (`pgrep -fl VerifiedXCore` is empty afterwards).
- Within 2 minutes the recovery address holds Vault D's former available balance plus the outstanding 1 VFX send (called back), less fees.
- After relaunch Vault D is not listed.

**Cleanup:** step 6.
