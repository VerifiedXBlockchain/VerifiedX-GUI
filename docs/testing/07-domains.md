# 07 · Domains (ADNR)

This area covers VFX domains (`.vfx`, an alias for a VFX address) and BTC domains (`.btc`, an alias for a BTC address that a VFX account controls) on the web wallet and the macOS desktop GUI: the Domains screen, creating a domain with its cost, balance and name checks, the pending states shown until the chain confirms, transferring and deleting a domain, where a confirmed domain is shown (account labels, the web Addresses panel, the Receive screen, request links), and sending VFX to a domain from the Send form. On the web every domain operation is built and signed in the browser and shown in a "Valid Transaction" confirmation before it is sent; on the desktop the Core CLI builds and broadcasts it with no extra confirmation. Code: `lib/features/adnr`, `lib/features/btc/components/btc_adnr_card.dart`, `lib/features/btc/providers/btc_adnr_*_form_provider.dart`, `lib/features/btc_web/components/web_btc_adnr_content.dart`.

## Area preconditions

- Testnet build, set up as in the README Environment section. macOS: chain synced before any case that signs (the desktop buttons refuse with a sync toast otherwise). If the desktop wallet is encrypted, enter `TEST_ENCRYPTION_PASSWORD` whenever a password prompt appears; the steps below do not repeat this.
- Balances: account A (`TEST_VFX_A_ADDRESS`) holds at least 40 VFX per platform, and account B (`TEST_VFX_B_ADDRESS`) holds at least 15 VFX per platform. Every domain create, transfer and delete costs 5.0 VFX plus the fee; the code refuses below 5.001 VFX. Top B up from A with a normal send (`03-send-receive-transactions.md`) if needed.
- BTC account: the BTC account (`TEST_BTC_ADDRESS`, key `TEST_BTC_WIF`) is loaded on both platforms as in `04-btc-vbtc.md`. For BTC domain transfer a second BTC address that the tester controls is needed: create a new BTC account in the macOS wallet (see `04-btc-vbtc.md`) and note its address as `<BTC_ADDR_2>` in the run notes. It is not a secret.
- Names: domain names only accept letters and numbers, so the run id is used with its non-alphanumeric characters removed, written `<RUN_ALNUM>` (run id `qa-20261001a` gives `qa20261001a`). Each platform uses its own suffix so both can run with one run id: VFX domains `<RUN_ALNUM>w1` (web) and `<RUN_ALNUM>m1` (macOS), called `<D1>` below; BTC domains `<RUN_ALNUM>wb1` / `<RUN_ALNUM>mb1` (`<B1>`) and `<RUN_ALNUM>wb2` / `<RUN_ALNUM>mb2` (`<B2>`).
- Chain waits: a domain transaction normally confirms within 1 to 2 minutes on testnet. Cases wait up to 3 minutes; the web screen refreshes from Spyglass on its own polling loop, the desktop from the CLI wallet list.
- macOS hooks: every VFX account card on the desktop Domains screen reuses the same keys (`adnr:create`, `adnr:transfer`, `adnr:delete`), and the BTC card's buttons have no keys. `drive.dart` fails with "Too many elements" when two cards show the same button, so keep only the accounts a case needs in the automation wallet at that point (the cases say which), and switch the segmented control to `VFX` or `BTC` before tapping card buttons.
- Web hooks: open the Domains screen with `button "Domains"` in the side nav (or `fltA11y.tap("Domains")`). Toasts are snackbars read as `text` nodes.

## Domains screen

### TC-ADNR-001 · Domains screen layout and cost notes
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Logged in as account A. Account A has no VFX domain (on mainnet: any account; skip the "no domain" checks if it has one).

**Steps**
1. Open Domains. Web: click `button "Domains"` in the side nav. macOS: `tap-key nav:domains`.
2. Web: read the page with the segmented control on `All`, then click `button "VFX"` and `button "BTC"` in turn. macOS: read the screen on `All` (`tap-text All`), then `tap-text VFX`, then `tap-text BTC`, taking a screenshot on each.

**Expected**
- Web: the app bar reads `Domains`; the segmented control shows `All`, `VFX` and `BTC` (no `Vault`). Under `VFX Domain` the card reads "Create a VFX Domain as an alias to your account's address for receiving funds." and "VFX domains cost 5.0 VFX plus the transaction fee." with a `Create Domain` button. On `BTC` the `BTC Domain` section appears only when the session has a BTC account.
- macOS: on `All` the app bar reads `Domains` with "Create a domain as an alias to your address for receiving funds." and "Domains cost 5.0 VFX plus the transaction fee."; on `VFX` it reads `VFX Domains` with "Create a VFX domain as an alias to your address for receiving funds." and "VFX domains cost 5.0 VFX plus the transaction fee."; on `BTC` it reads `BTC Domains` with "Create a BTC domain as an alias to your BTC address for receiving funds." and "BTC domains cost 5.0 VFX plus the transaction fee.".
- macOS: each non-vault VFX account has a card with its address, a `link_off` icon, the subtitle `No Domain` and a `Create Domain` button; vault accounts are not listed.

**Cleanup:** none.

## Create a VFX domain: validation

### TC-ADNR-002 · Create dialog opens and requires a name
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as account A with at least 6 VFX and no VFX domain. macOS: A is the only account in the wallet without a domain; segmented control on `VFX`.

**Steps**
1. Open Domains as in TC-ADNR-001.
2. Click Create Domain. Web: `button "Create Domain"` under `VFX Domain`. macOS: `tap-key adnr:create`.
3. Leave the name empty and submit. Web: `button "Create"`. macOS: `tap-key adnr:create_submit`.
4. Close the dialog. Web: `button "Cancel"`. macOS: `tap-text Cancel`.

**Expected**
- The dialog is titled `New VFX Domain` and shows "VFX Domains cost 5.0 VFX." and "Your domain must only contain letters and numbers and will automatically be appended with ".vfx" upon verification", a `Domain Name` field with the suffix `.vfx`, and `Cancel` and `Create` buttons.
- Submitting empty shows the field error "Domain Name is required." and nothing is sent.
- Cancel closes the dialog with no toast.

**Cleanup:** none.

### TC-ADNR-003 · Name field drops characters other than letters and numbers
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As TC-ADNR-002.

**Steps**
1. Open the create dialog as in TC-ADNR-002.
2. Type `qa-test.vfx_1 X` into the name field. Web: `await fltA11y.type("Domain Name", "qa-test.vfx_1 X")`. macOS: `tap-key adnr:domain_name`, then `type "qa-test.vfx_1 X"`.
3. Read the field value. Web: `fltA11y.list()` value of `Domain Name`. macOS: `get-text key:adnr:domain_name`.
4. Cancel the dialog.

**Expected**
- The field holds `qatestvfx1X`: hyphens, dots, underscores and spaces are dropped as they are typed, so the "A DNR may only contain letters and numbers." error cannot appear.

**Cleanup:** none.

### TC-ADNR-004 · Name longer than 65 characters is refused
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As TC-ADNR-002.

**Steps**
1. Open the create dialog as in TC-ADNR-002.
2. Type a 66-character name: `a` repeated 66 times. Submit (web `button "Create"`, macOS `tap-key adnr:create_submit`).
3. Clear the field and type a 65-character name (`a` repeated 65 times). Web only: submit and, when the `Valid Transaction` confirmation appears, click `button "Cancel"`. macOS: do not submit (the desktop sends immediately); cancel the dialog instead.

**Expected**
- 66 characters: a red toast "Maximum characters for domain is 65" and the dialog stays open; nothing is sent.
- 65 characters (web): the length check passes and the flow continues to the availability check and the `Valid Transaction` confirmation; cancelling there closes the dialog and nothing is sent.

**Cleanup:** none.

## Create a VFX domain

### TC-ADNR-005 · Web: cancelling at the confirmation sends nothing
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** As TC-ADNR-002, web.

**Steps**
1. Open the create dialog, type `<D1>` into `textbox "Domain Name"`, click `button "Create"`.
2. When `Valid Transaction` appears, click `button "Cancel"`.

**Expected**
- The confirmation reads "The VFX Domain transaction is valid.", "Are you sure you want to proceed?", then `Domain: <D1>.vfx`, `Amount: 5.0 VFX`, `Fee: <fee> VFX` and `Total: <5.0 + fee> VFX`, with `Cancel` and `Send`.
- Cancel closes both the confirmation and the create dialog; no toast; the card still shows `Create Domain` and no pending badge; A's balance is unchanged.

**Cleanup:** none.

### TC-ADNR-006 · Create a VFX domain on account A
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** As TC-ADNR-002. Note A's VFX balance.

**Steps**
1. Open Domains and the create dialog as in TC-ADNR-002.
2. Enter `<D1>`. Web: `await fltA11y.type("Domain Name", "<D1>")`. macOS: `tap-key adnr:domain_name`, `type <D1>`.
3. Submit. Web: click `button "Create"`, check the `Valid Transaction` body, click `button "Send"`. macOS: `tap-key adnr:create_submit`.
4. Navigate to Dashboard and back to Domains.
5. Wait up to 3 minutes for the domain to confirm. Web: re-read the page every 20 s until the `VFX Domain` card shows the domain name. macOS: `wait-for-text Transfer --timeout 180`.

**Expected**
- Web: after Send, a green toast "VFX Domain Transaction has been broadcasted. See log for hash."; the dialog closes; the `VFX Domain` section shows the green badge `VFX Domain Pending` in place of the create card, and it survives step 4.
- macOS: a green toast "VFX Domain Transaction has been broadcasted. See log for hash."; the dialog closes; A's card shows the yellow badge `Creation Pending` in place of `Create Domain`, and it survives step 4. The log panel has "ADNR create transaction broadcasted. Tx Hash: <hash>".
- After confirmation: web shows a card with the domain (`<D1>.vfx`) as its heading, A's address below it, and `Transfer` and `Delete` buttons; macOS shows A's card with a `link` icon, a badge `@<domain>` and `Transfer` and `Delete` buttons.
- A transaction notification titled "Domain Name Created" with "VFX Domain created for <D1>.vfx" appears once the transaction is seen.
- A's balance drops by 5.0 VFX plus the fee.

**Cleanup:** none; later cases transfer and delete this domain.

### TC-ADNR-007 · Web: create refused when the balance is too low
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** A web session on a newly created wallet with 0 VFX (create it as in `01-launch-auth.md`; its keys are throwaway and are not recorded).

**Steps**
1. Open Domains and click `button "Create Domain"` under `VFX Domain`.

**Expected**
- A red toast "Not enough VFX in this account to create a VFX domain. 5.0 VFX required (plus TX fee)." and no dialog opens.

**Cleanup:** log back in as account A.

### TC-ADNR-008 · macOS: fund-account prompt when the account is too low
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** TC-ADNR-006 confirmed, so A has a domain. Create a new VFX account C in the desktop wallet (see `01-launch-auth.md`); it holds 0 VFX and is the only card with a `Create Domain` button. A holds more than 6 VFX.

**Steps**
1. Open Domains (`tap-key nav:domains`), `tap-text VFX`.
2. `tap-key adnr:create` on C's card.
3. In the `Fund Account` dialog, `tap-text Send`.
4. In `Please Confirm`, `tap-text Send`.
5. Wait up to 3 minutes for C's balance to show 6.0 VFX (wallet selector or dashboard).

**Expected**
- Step 2 does not open the create dialog. `Fund Account` reads "You don't have the required funds to buy the domain in this account.", "Please send funds to <C address>", and "You have an account with a sufficient balance." / "Would you like to send 6 VFX from:" with A's address and "[Balance: <A balance> VFX]?", with `Cancel` and `Send`. (If no other account holds more than 6 VFX, the dialog instead shows "Please send funds to <C address>" and a `Copy Address` button whose tap shows "Address copied to clipboard.")
- `Please Confirm` reads "Sending:" 6.0 VFX, "To:" C's address, "From:" A's address.
- After sending, an info dialog `Funds Sent` reads "6.0 VFX has been sent to <C address>." and "Please wait for transaction to reflect and then you can get your domain."; the log panel has the send entry with its hash. C's balance reaches 6.0 VFX.

**Cleanup:** keep C for TC-ADNR-009.

### TC-ADNR-009 · Creating a domain name that is already taken fails
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no (web checks before signing; on macOS a regression here would broadcast a failing transaction, testnet only)

**Preconditions:** TC-ADNR-006 confirmed. Web: logged in as account B (at least 6 VFX, no domain). macOS: account C from TC-ADNR-008 funded with 6 VFX and the only card with `Create Domain`.

**Steps**
1. Open Domains, open the create dialog (web `button "Create Domain"`; macOS `tap-text VFX`, `tap-key adnr:create`).
2. Enter `<D1>` (the name confirmed in TC-ADNR-006) and submit.

**Expected**
- Web: a red toast "This VFX Domain already exists"; the dialog stays open; no `Valid Transaction` confirmation; B's balance unchanged.
- macOS: a red toast with the CLI's error message; the dialog stays open; no `Creation Pending` badge; C's balance is unchanged.

**Open question:** the macOS message comes from the CLI (`/txapi/TXV1/CreateAdnr`) and the GUI shows `result.message` verbatim; the exact text is not in this repo. Record what it says on the first run and pin it here.

**Cleanup:** cancel the dialog. Web: log back in as account A.

## Domain display

### TC-ADNR-010 · Domain shown on account labels and the web Addresses panel
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Logged in as account A with `<D1>` confirmed (mainnet: any account that owns a domain).

**Steps**
1. Web: open Dashboard (`button "Dashboard"`), open the `Addresses` dropdown in the top bar (`fltA11y.tap("Addresses")`) and read it. macOS: open Dashboard (`tap-key nav:dashboard`) and read the wallet selector label; open the selector list.

**Expected**
- Web: the VFX row reads `<balance> VFX | @<domain>`.
- macOS: for an account without a friendly name the label reads `@<domain> | <first 5>.....<last 5>` of A's address, in the header and in the selector list.

**Cleanup:** close the dropdown or selector.

### TC-ADNR-011 · Receive screen shows the domain and request links use it
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** As TC-ADNR-010.

**Steps**
1. Open Receive. Web: `button "Receive"` in the side nav. macOS: `tap-key nav:receive`.
2. Web only: click `button "Copy domain"`.
3. Click the `Copy Link` button (label "Copy" / "Link" on two lines, link icon; web `fltA11y.tap("Copy\nLink")` or click it by its text, macOS `tap-text "Copy\nLink"`). In `Request Funds`, enter `1` in `Amount to request` (web `await fltA11y.type("Amount to request", "1")`; macOS tap the field, `type 1`), confirm with `Generate Link`.

**Expected**
- Web: below the address card a second card shows the domain in the account colour with the subtitle `Your Domain`; `Copy domain` shows the toast "'<domain>' Copied to clipboard".
- macOS: the Receive card shows only the address (no domain row, no copy-domain control).
- Both: a green toast "Request funds link copied to clipboard", and the clipboard holds `https://wallet-testnet.verifiedx.io/#dashboard/send/vfx/<domain>/1.0`, using the domain instead of the address.

**Open question:** the desktop Receive screen never shows the domain even though it passes it to the request-link buttons; confirm that is intended.

**Cleanup:** none.

## Send to a domain

### TC-ADNR-012 · Send VFX to a VFX domain
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** `<D1>` confirmed on A. Sender is account B with at least 2 VFX (web: log in as B; macOS: import B into the wallet as in `01-launch-auth.md` and select it in the wallet selector). Note A's balance.

**Steps**
1. Open Send. Web: `button "Send"`. macOS: `tap-key nav:send`.
2. Enter the domain as the recipient: `<D1>.vfx`. Web: `await fltA11y.type("Recipient's Account Address", "<D1>.vfx")`. macOS: `tap-key send:address`, `type <D1>.vfx`.
3. Enter amount `1`. Web: the amount textbox. macOS: `tap-key send:amount`, `type 1`.
4. Submit. Web: `button "Send"`, then `Send` in `Please Confirm`, then `Send` in `Valid Transaction`. macOS: `tap-key send:submit`, then `tap-text Send` in `Please Confirm`.
5. Wait up to 3 minutes for the transaction to confirm.

**Expected**
- The recipient field accepts `<D1>.vfx` with no validation error.
- `Please Confirm` shows "Sending:" 1 VFX, "To:" `<D1>.vfx`, "From:" B's address. Web `Valid Transaction` reads "This transaction is valid and is ready to send." with `To: <D1>.vfx` and `Amount: 1.0 VFX` plus the fee lines.
- After confirmation A's balance is 1 VFX higher and the transaction's recipient resolves to A's address in the transaction detail.

**Cleanup:** none.

### TC-ADNR-013 · Send to a domain that does not exist
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no (expected to be refused before broadcast)

**Preconditions:** As TC-ADNR-012.

**Steps**
1. Open Send, enter `<RUN_ALNUM>nodomain.vfx` as recipient and `1` as amount, submit and confirm `Please Confirm`.

**Expected**
- The field validator accepts it (it only checks for `.vfx`), then the send is refused with an error toast and nothing is broadcast; B's balance is unchanged.

**Open question:** the refusal text comes from Spyglass (web raw path) or the CLI (desktop); neither is in this repo. Record the text on the first run.

**Cleanup:** none.

## Transfer a VFX domain

### TC-ADNR-014 · Transfer dialog validates the address
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as account A with `<D1>` confirmed and at least 6 VFX. macOS: A is the only account with a domain; segmented control on `VFX`.

**Steps**
1. Open Domains and click Transfer. Web: `button "Transfer"`. macOS: `tap-key adnr:transfer`.
2. Submit empty. Web: `button "Submit"`. macOS: `tap-key adnr:transfer_submit`.
3. Type `notanaddress` (web `await fltA11y.type("Address", "notanaddress")`; macOS `tap-key adnr:transfer_address`, `type notanaddress`) and submit.
4. Cancel (`button "Cancel"` / `tap-text Cancel`).

**Expected**
- The prompt is titled `Transfer VFX Domain` with "There is a cost of 5.0 VFX to transfer a VFX Domain." and an `Address` field, with `Cancel` and `Submit`.
- Empty: "Address required". Invalid: "Invalid Address.". Nothing is sent.

**Cleanup:** none.

### TC-ADNR-015 · Transfer a VFX domain from A to B
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** As TC-ADNR-014. B has no domain.

**Steps**
1. Open Domains, click Transfer as in TC-ADNR-014.
2. Enter `TEST_VFX_B_ADDRESS` in the address field and submit.
3. Web: read the `Valid Transaction` dialog and click `button "Send"`.
4. Wait up to 3 minutes for the transfer to confirm.

**Expected**
- Web: `Valid Transaction` reads "The VFX Domain transaction is valid." with the domain, amount, fee and total; after Send, a green toast "VFX Domain Transaction has been broadcasted. See log for hash." and the section shows the badge `VFX Domain Transfer Pending`.
- macOS: a green toast "VFX domain transfer transaction has been broadcasted. Check logs for tx hash", the log panel has "VFX domain transfer transaction broadcasted. Tx Hash: <hash>", and A's card shows the badge `Transfer Pending`.
- After confirmation A no longer has a domain (web: the create card is back; macOS: A's card shows `No Domain` and `Create Domain`), and B has `<D1>` (check by logging in as B on web, or B's card on macOS if B is in the wallet). A notification titled "Domain Name Transferred" with "VFX Domain transfer for <D1>" appears.
- A's balance drops by 5.0 VFX plus the fee.

**Open question:** the web confirmation body is hardcoded (`web_adnr_screen.dart`) and shows `Amount: 5.0 VFX` from `ADNR_COST` and `Fee: <fee> RBX`, and appends `.vfx` to the stored domain, which may already end in `.vfx`. Confirm the expected wording; this case records what is shown.

**Cleanup:** none; TC-ADNR-016 deletes the domain from B.

## Delete a VFX domain

### TC-ADNR-016 · Delete a VFX domain (cancel, then confirm)
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** TC-ADNR-015 confirmed: B owns `<D1>` and holds at least 6 VFX. Web: logged in as B. macOS: B is in the wallet and is the only account with a domain.

**Steps**
1. Open Domains. Web: under `VFX Domain` click `button "Delete"`. macOS: `tap-text VFX`, `tap-key adnr:delete`.
2. In `Delete VFX Domain?`, click `Cancel`.
3. Click Delete again and confirm with `Delete`.
4. Web: in `Valid Transaction`, click `button "Send"`.
5. Wait up to 3 minutes for the delete to confirm.

**Expected**
- The confirmation is titled `Delete VFX Domain?` and reads "Are you sure you want to delete this VFX Domain?", "There is a cost of 5.0 RBX to delete an RBX Domain." and "Once deleted, this ADNR will no longer be able to receive any transactions.", with a red `Delete` button.
- Cancel closes it with nothing sent.
- Web: after Send, a green toast "VFX Domain Transaction has been broadcasted. See log for hash." and the badge `VFX Domain Delete Pending`.
- macOS: a green toast "VFX domain delete transaction has been broadcasted. Check logs for tx hash", the log entry "VFX domain delete transaction broadcasted. Tx Hash: <hash>", and B's card shows the red badge `Delete Pending`.
- After confirmation B's card or section is back to the no-domain state with `Create Domain`, and a notification "Domain Name Deleted" with "VFX Domain deleted for <D1>" appears. B's balance drops by 5.0 VFX plus the fee.

**Open question:** the cost line says "RBX" and "an RBX Domain" (`r3gAdnrDeleteWithCost`, `svcAdnrDeleteWithCost`); confirm whether the copy should say VFX. On macOS a failed delete shows no error toast (`vfx_adnr_component.dart` only handles success); note it if seen.

**Cleanup:** web: log back in as account A.

## BTC domains

### TC-ADNR-017 · BTC domain section and cost note
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Logged in as account A with the BTC account loaded. The BTC account has no domain (mainnet: skip the no-domain checks if it has one).

**Steps**
1. Open Domains. Web: click `button "BTC"`. macOS: `tap-text BTC`.

**Expected**
- Web: a `BTC Domain` heading and a card reading "Create a BTC Domain as an alias to your account's address for receiving funds." and "BTC domains cost 5.0 VFX plus the transaction fee." with a `Create Domain` button.
- macOS: the `BTC Domains` app bar, the heading and cost note from TC-ADNR-001, and a card for `TEST_BTC_ADDRESS` with `No Domain` and an orange `Create Domain` button.
- Web with no BTC account in the session: no `BTC Domain` section at all.

**Cleanup:** none.

### TC-ADNR-018 · macOS: BTC domain form validation
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As TC-ADNR-017, macOS. Account A holds at least 6 VFX.

**Steps**
1. On the `BTC` tab tap the card's button: `tap-text "Create Domain"`.
2. Tap `Create BTC Domain` with the name empty.
3. Enter `qa-bad` and tap `Create BTC Domain`.
4. Enter a 66-character name (`a` repeated 66 times) and tap `Create BTC Domain`.
5. Close with `Cancel`.

**Expected**
- The sheet reads "Create Domain for <TEST_BTC_ADDRESS>", "Your domain must only contain letters and numbers and will automatically be appended with ".btc" upon verification", a `Domain Name` field with suffix `.btc`, "Select VFX Address", "This wallet will control transfer/delete ownership over this new domain.", and `Selected Address:` preset to the first account holding at least 5.001 VFX.
- Empty: "Domain Name Required". `qa-bad`: "Invalid domain. Must only contain letters and/or numbers.". 66 characters: "Domain must be less than 66 characters.". Nothing is sent.

**Open question:** the too-long message reads "less than 66 charcters" (typo, and the limit is 65 allowed); confirm the intended copy.

**Cleanup:** none.

### TC-ADNR-019 · Web: faucet prompt when VFX is too low for a BTC domain
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** A web session whose VFX balance is below 5.001 VFX and that has a BTC account with no domain (a newly created web wallet, as in `01-launch-auth.md`). The faucet itself is covered in `12-payments-faucet-keygen.md`; this case does not submit it.

**Steps**
1. Open Domains, click `button "BTC"`, click `button "Create Domain"` under `BTC Domain`.
2. In `New BTC Domain`, note the action button, then click `button "Continue"`.
3. In `5.0 VFX Required`, click `button "No Thanks"`.
4. Repeat steps 1 and 2, then click `button "Continue"` in `5.0 VFX Required`.
5. In `VFX Faucet`, click `button "Close"` without submitting.

**Expected**
- The dialog is `New BTC Domain` with "BTC Domains cost 5.0 VFX." and the `.btc` suffix; its action button reads `Continue` instead of `Create`.
- `5.0 VFX Required` explains the 5.0 VFX cost, the community allocation and the SMS phone check, ending "Would you like to proceed?", with `No Thanks` and `Continue`.
- `No Thanks`: a red toast "Not enough VFX in your account to create a BTC domain. 5.0 VFX required (plus TX fee)." and the dialog closes.
- `Continue`: the `VFX Faucet` dialog opens with the faucet form; after `Close`, a green toast "Please wait for your balance to arrive before continuing.".

**Open question:** in `create_adnr_dialog.dart` the `No Thanks` branch pops the dialog but does not return, so the `VFX Faucet` dialog still opens after the toast. If that happens this case fails on the third bullet; confirm whether that is a bug. "Woud" is a typo in `adnrFaucetRequiredBody`.

**Cleanup:** log back in as account A with the BTC account.

### TC-ADNR-020 · Create a BTC domain
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** As TC-ADNR-017, on testnet. Account A holds at least 6 VFX.

**Steps**
1. Open Domains on the `BTC` tab and click `Create Domain` (web `button "Create Domain"` under `BTC Domain`; macOS `tap-text "Create Domain"`).
2. Web: type `<B1>` into `textbox "Domain Name"`, click `button "Create"`, read `Valid Transaction`, click `button "Send"`. macOS: type `<B1>` into `Domain Name`, check `Selected Address:` shows A's address (change it from the dropdown if not), `tap-text "Create BTC Domain"`.
3. Wait up to 3 minutes for the domain to confirm.

**Expected**
- Web: `Valid Transaction` reads "The BTC Domain transaction is valid." with `Domain: <B1>.btc`, `Amount: 5.0 VFX`, the fee and total. After Send, a green toast "BTC Domain Transaction has been broadcasted. See log for hash." and the badge `BTC Domain Pending`.
- macOS: a green toast "Transaction Broadcasted!", the sheet closes, the BTC card shows the badge `Creation Pending`, and the log has "BTC Domain Create TX Sent: <hash>".
- After confirmation: web shows a card with the domain as heading, the BTC address and `Transfer` / `Delete`; macOS shows the orange badge `@<domain>` and "Controlled by: <A address>" with `Transfer` and `Delete`. A notification "BTC Domain Name Created" with "BTC Domain created for <B1>.btc" appears. A's VFX balance drops by 5.0 plus the fee.

**Cleanup:** none.

### TC-ADNR-021 · BTC domain shown on the Addresses panel and Receive
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** `<B1>` confirmed (mainnet: a BTC account with a domain).

**Steps**
1. Open the `Addresses` dropdown in the top bar and read the BTC row.
2. Open Receive, select the BTC account, read the page and click `button "Copy domain"`.

**Expected**
- The BTC row reads `<balance> BTC | @<domain>`.
- Receive shows the domain card with `Your Domain`; `Copy domain` shows "'<domain>' Copied to clipboard"; request links use `/send/btc/<domain>/`.

**Cleanup:** none.

### TC-ADNR-022 · Transfer a BTC domain
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** `<B1>` confirmed. `<BTC_ADDR_2>` exists (see Area preconditions). Account A holds at least 6 VFX.

**Steps**
1. Open Domains on the `BTC` tab and click `Transfer` on the `<B1>` card.
2. Web: in `Transfer BTC Domain` ("There is a cost of 5.0 VFX to transfer a BTC Domain.") type `<BTC_ADDR_2>` into `textbox "BTC Address"`, `button "Submit"`; in `VFX Owner` ("What VFX address will manage this BTC domain?") type `TEST_VFX_A_ADDRESS` into `textbox "VFX Address,"`, `button "Submit"`; read `Valid Transaction`, `button "Send"`.
3. macOS: in the sheet ("Transfer Domain from <TEST_BTC_ADDRESS>") first tap `Transfer BTC Domain` with both fields empty, then fill `To BTC Address` with `<BTC_ADDR_2>` and `To VFX Address` with `TEST_VFX_A_ADDRESS` and tap `Transfer BTC Domain`.
4. Wait up to 3 minutes for the transfer to confirm.

**Expected**
- macOS empty submit: "To BTC address required." and "To VFX address required.".
- Web: a green toast "BTC Domain Transaction has been broadcasted. See log for hash." and the badge `BTC Domain Transfer Pending`. macOS: a green toast "Transaction Broadcasted!" and the badge `Transfer Pending`.
- After confirmation the `TEST_BTC_ADDRESS` card is back to the no-domain state and (macOS) the `<BTC_ADDR_2>` card shows `@<domain>`. A notification "BTC Domain Name Transferred" appears.

**Open question:** the web `Valid Transaction` body shows the domain as `<B1>.vfx` and the amount from `ADNR_COST` (`web_btc_adnr_content.dart`); confirm whether `.btc` is intended. On macOS `BtcService.transferAdnr` ignores the CLI response and the sheet always reports success, so a refused transfer still shows "Transaction Broadcasted!" and `Transfer Pending`; confirm on chain rather than trusting the toast.

**Cleanup:** macOS: delete the domain from the `<BTC_ADDR_2>` card with TC-ADNR-023's steps if it is not needed later.

### TC-ADNR-023 · Delete a BTC domain
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** The BTC account has no domain. Create `<B2>` with the steps of TC-ADNR-020 and wait for it to confirm. Account A holds at least 6 VFX.

**Steps**
1. On the `BTC` tab click `Delete` on the `<B2>` card (web `button "Delete"`; macOS `tap-text Delete`).
2. Cancel the first confirmation, then click Delete again and confirm with `Delete`.
3. Web: read `Valid Transaction` and click `button "Send"`.
4. Wait up to 3 minutes for the delete to confirm.

**Expected**
- The confirmation is `Delete BTC Domain?` and reads "Are you sure you want to delete this BTC Domain?", a cost line (web "There is a cost of 5.0 VFX to delete a BTC Domain."; macOS "There is a cost of 5.0 VFX to delete an RBX Domain.") and "Once deleted, this ADNR will no longer be able to receive any transactions.". Cancel sends nothing.
- Web: a green toast "BTC Domain Transaction has been broadcasted. See log for hash." and the badge `BTC Domain Delete Pending`. macOS: a green toast "TX broadcasted!" and the badge `Delete Pending`.
- After confirmation the card is back to `Create Domain`; a notification "BTC Domain Name Deleted" appears.

**Open question:** the web `Valid Transaction` for this delete uses the VFX wording ("The VFX Domain transaction is valid.", `r3eVfxDomainValidBody`). The macOS BTC delete has no balance, sync or password check and ignores the CLI response, so it always reports success. Confirm both are intended.

**Cleanup:** none.
