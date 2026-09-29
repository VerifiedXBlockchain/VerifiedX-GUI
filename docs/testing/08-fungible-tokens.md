# 08 · Fungible tokens

This area covers fungible tokens on the web wallet and the macOS desktop GUI: the Fungible Tokens list, the create form (name, ticker, description, fixed or mintable supply, decimal places, burnable and voting options, icon), the pre-mint of an initial issuance, the owner's management view (details, Mint Tokens, Pause/Resume TXs, Ban Address, List Bans, Prove Ownership, Change Ownership, Voting), holder actions (Transfer, Burn, Voting), token voting topics (create, vote yes, vote no, minimum balance, vote history), the All My Tokens screen, and how token balances are displayed. The desktop reaches the owner view by tapping a token row on the Fungible Tokens list and sends every action through the Core CLI with no extra confirmation; the web opens a token detail page (`token/detail/:scId` under the `fungible-token` tab) and signs every action in the browser after a "Valid Transaction" confirmation. Code: `lib/features/token`, plus `lib/features/home/screens/all_tokens_screen.dart` and `lib/features/voting/providers/pending_votes_provider.dart` (the only part of `lib/features/voting` that token topics use).

## Area preconditions

- Testnet build, set up as in the README Environment section. macOS: chain synced. If the desktop wallet is encrypted, enter `TEST_ENCRYPTION_PASSWORD` whenever a password prompt appears.
- Balances: account A (`TEST_VFX_A_ADDRESS`) holds at least 20 VFX per platform to pay token transaction fees; account B (`TEST_VFX_B_ADDRESS`) holds at least 2 VFX (its vote and any transfer need a fee). On the web every token action is refused with "A balance on your VFX account is required to broadcast this transaction" when the VFX balance is below 0.001.
- Names, per platform so both can share a run id (`<RUN_ID>`, and `<RUN_ALNUM>` for the run id with non-alphanumerics removed, uppercased by the ticker field): token T1 is named `QA Token <RUN_ID> W1` with ticker `<RUN_ALNUM>W1` on web and `QA Token <RUN_ID> M1` / `<RUN_ALNUM>M1` on macOS; token T2 is `QA Fixed <RUN_ID> W2` / `<RUN_ALNUM>W2` and `QA Fixed <RUN_ID> M2` / `<RUN_ALNUM>M2`. Tickers stay under the 20-character limit. Record each token's Smart Contract UID in the run notes as `<T1_SCID>` and `<T2_SCID>`.
- Token icon: the form requires an uploaded icon image. Use the repo file `assets/images/icon.png`. Web: when the browser file chooser opens, attach it with Claude in Chrome's file-upload tool. macOS: `Upload Token Icon` opens the native macOS open panel, which `tool/drive.dart` cannot drive; pick the file by hand (see the Open question in TC-TOKEN-009).
- Chain waits: token deploys take up to 5 minutes to appear (compile, mint, block); other token transactions up to 3 minutes. The desktop management screen reloads every 10 seconds and the web detail page every 10 seconds; topic detail pages every 20 seconds.
- Web hooks: open the list with `button "Fungible Tokens"` in the side nav (or `fltA11y.tap("Fungible Tokens")`). Rows are buttons whose text starts with `[<TICKER>]`. Prompt fields are `textbox "Amount"` or `textbox "Address"`; the web "Valid Transaction" confirmation reads "Transaction verified. There will be a fee of <fee> VFX. Would you like to proceed?" with `Cancel` and `Yes`, and a successful send shows the green toast "Transaction broadcasted!".
- macOS hooks: the side nav key is `nav:fungible_tokens`. Only Create (`token:create`), the name and ticker fields (`token:name`, `token:ticker`), Transfer (`token:transfer`) and Mint Tokens (`token:mint`) have keys; other buttons are tapped by text. Every token row repeats the same Transfer, Burn and Voting buttons, so `drive.dart` fails with "Too many elements" when more than one row is on screen; keep the rows the case needs (the cases say which accounts hold what) and prefer the management screen's `Token Accounts` rows, which list one token only.

## Fungible Tokens list

### TC-TOKEN-001 · Fungible Tokens screen, empty and populated
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Logged in as account A. For the empty-state check, an account holding no fungible tokens (on the first run A qualifies; otherwise use a newly created wallet as in `01-launch-auth.md`).

**Steps**
1. Open the list. Web: `button "Fungible Tokens"`. macOS: `tap-key nav:fungible_tokens`.
2. Read the screen with no tokens held, then again later in the run once A holds T1.

**Expected**
- The app bar reads `Fungible Tokens`.
- Empty, web: "No Fungible Tokens", "You have no fungible tokens with supply in any of your accounts." and a green `Create Token` button; no button in the app bar.
- Empty, macOS: "Fungible Tokens", the same body text and `Create Token`; no button in the app bar.
- Populated: a green `Create New Token` button in the app bar. Web rows show the icon, `[<TICKER>] <name>`, the holding address, and a badge `<balance> <TICKER>`. macOS groups rows under each holding address (with a copy icon), each row showing `[<TICKER>] <name>`, `Balance: <balance>` and `Transfer` (plus `Burn` when burnable and `Voting` when voting is enabled).

**Cleanup:** none.

### TC-TOKEN-002 · macOS: copy a holding address from the list
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** A holds T1 (after TC-TOKEN-009).

**Steps**
1. `tap-key nav:fungible_tokens`, then `tap-label "Copy address"` on A's group header.

**Expected**
- A green toast "Address copied to clipboard (<A address>)".

**Cleanup:** none.

## Create form

### TC-TOKEN-003 · Create form opens with its defaults
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Logged in as account A (a standard account, not a vault).

**Steps**
1. Open the list and click `Create Token` (empty state) or `Create New Token` (app bar). macOS: `tap-text "Create Token"` or `tap-text "Create New Token"`.
2. Read the form and take a screenshot. Do not submit.

**Expected**
- The screen is titled `Create Fungible Token`.
- macOS only: a `Token Owner: ` row with the wallet selector showing the current account's full address.
- Fields: `Token Name:` (hint `MyToken`, helper "The name of this new token."), `Token Ticker:` (hint `ABC`, helper "The ticker for this new token.", counter `0/20`), `Description (Optional):`.
- `Token Has Fixed Supply:` is unchecked and no `Total Supply:` field is shown (the token is mintable by default).
- `Decimal Places:` shows 8 with the decrease and increase arrows; `Is Burnable:` is checked; `Allow Voting:` is unchecked.
- `Upload Token Icon` with no icon URL field next to it; a red `Cancel` and a `Create` button.

**Cleanup:** click `Cancel`.

### TC-TOKEN-004 · Decimal places stay between 1 and 18
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Create form open.

**Steps**
1. Click the decrease arrow 8 times. Web: `button "Decrease decimal places"`. macOS: `tap-label "Decrease decimal places"`.
2. Click the increase arrow 18 times. Web: `button "Increase decimal places"`. macOS: `tap-label "Increase decimal places"`.

**Expected**
- The value goes 8 → 1 and stops; at 1 the decrease arrow is disabled.
- The value then climbs to 18 and stops; at 18 the increase arrow is disabled.

**Cleanup:** click `Cancel`.

### TC-TOKEN-005 · Fixed supply shows and validates the supply field
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Create form open, with an icon uploaded (see Area preconditions) so the form reaches field validation, and name `x` and ticker `X` filled in.

**Steps**
1. Tick `Token Has Fixed Supply:`. Web: click the checkbox beside it or `fltA11y.tap("Token Has Fixed Supply:")`. macOS: `tap-text "Token Has Fixed Supply:"`.
2. Clear `Total Supply:` and click `Create`.
3. Enter `1.5` and click `Create`.
4. Enter `2147483648` and click `Create`.
5. Enter `1.2.3` and click `Create`.
6. Untick `Token Has Fixed Supply:`.

**Expected**
- Ticking shows `Total Supply:` set to `0` with the helper "Use 0 for Infinite (allows minting)".
- Empty: "Supply Amount is required.". `1.5` and `2147483648`: "Supply must be a whole number from 0 to 2,147,483,647.". `1.2.3`: "Invalid Supply Amount.". No confirmation dialog opens.
- Letters cannot be typed into the field.
- Unticking hides the field again.

**Cleanup:** click `Cancel`.

### TC-TOKEN-006 · Icon, name and ticker are required
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Create form open, empty.

**Steps**
1. Click `Create` (web `button "Create"`; macOS `tap-key token:create`) with nothing filled in and no icon.
2. Upload the icon, then click `Create` again with name and ticker empty.
3. Type `qa-x y!` into the ticker (web `await fltA11y.type("Token Ticker:", "qa-x y!")`; macOS `tap-key token:ticker`, `type "qa-x y!"`) and read it back.
4. Type 25 letters into the ticker.

**Expected**
- Step 1: a red toast "Icon Image Required"; no field errors yet (the icon is checked first).
- Step 2: "Token Name is required." and "Token Ticker is required.".
- Step 3: the ticker reads `QAXY` (uppercased, non-alphanumerics dropped).
- Step 4: the ticker stops at 20 characters and the counter reads `20/20`.
- No confirmation dialog opens in any step.

**Cleanup:** click `Cancel`.

### TC-TOKEN-007 · Cancel clears the form
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Create form open.

**Steps**
1. Type a name and ticker, tick `Token Has Fixed Supply:`, change decimals to 4.
2. Click the red `Cancel` (macOS `tap-text Cancel`).
3. Open the create form again.

**Expected**
- Cancel returns to the Fungible Tokens list.
- The reopened form shows the defaults from TC-TOKEN-003 (empty fields, mintable, 8 decimals, burnable on, voting off, no icon).

**Cleanup:** click `Cancel`.

### TC-TOKEN-008 · macOS: vault accounts cannot create tokens
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** The desktop wallet has a vault account (`06-vault-accounts.md`) and it is selected as the current account.

**Steps**
1. Open `Create Token` / `Create New Token`.
2. Switch to account A in the wallet selector shown on the screen.

**Expected**
- Instead of the form: "Vault Accounts cannot mint smart contracts" and a wallet selector.
- After switching to A the create form appears.

**Cleanup:** none.

## Create a token

### TC-TOKEN-009 · Create a mintable, burnable token with voting and a pre-mint
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Logged in as account A (macOS: A selected as `Token Owner`). A holds at least 5 VFX.

**Steps**
1. Open the create form.
2. Name: T1's name. Web: `await fltA11y.type("Token Name:", "<T1 name>")`. macOS: `tap-key token:name`, `type "<T1 name>"`.
3. Ticker: T1's ticker. Web: `await fltA11y.type("Token Ticker:", "<T1 ticker>")`. macOS: `tap-key token:ticker`, `type <T1 ticker>`.
4. Description: `Release test token <RUN_ID>`.
5. Leave `Token Has Fixed Supply:` unticked, decimals 8, `Is Burnable:` ticked. Tick `Allow Voting:` (web: the checkbox after `Allow Voting:`; macOS: see Open question).
6. Click `Upload Token Icon` and attach `assets/images/icon.png`.
7. Click `Create` (macOS `tap-key token:create`).
8. In `Compile & Mint Token Smart Contract?` click `Continue` (macOS `tap-text Continue`), then in `Confirm Address` click `Compile & Mint` (macOS `tap-text "Compile & Mint"`).
9. Pre-mint prompt. Web: it appears right away as `Pre Mint Initial Issuance? (Optional)`; enter `1000` in `textbox "Supply"` and click `button "Submit"`. macOS: it appears after the contract compiles (loader first) as `Pre Mint Initial Issuance?`; tap the `Supply` field, `type 1000`, `tap-text Submit`.
10. Close the `Stand by` dialog.
11. Wait up to 5 minutes for the deploy, then up to 3 more minutes for the automatic pre-mint. Web: re-read the Fungible Tokens list every 20 s. macOS: `wait-for-text "[<T1 ticker>] <T1 name>" --timeout 480` on the Fungible Tokens list.

**Expected**
- The first confirmation reads "Are you sure you want to proceed?" / "Once compiled you will not be able to make any changes" / "and the smart contract/token will be deployed to the chain." with `Cancel` and `Continue`; `Confirm Address` reads "This will be minted by <A address>" (macOS shows the account label) with `Cancel` and `Compile & Mint`.
- The pre-mint prompt's cancel button reads `No Initial Issuance` and the field starts at `0`.
- `Stand by` reads "Token Smart Contract mint transaction has been broadcasted." and "The Fungible Token screen will reflect the change once the block is crafted and block height has synced with this transaction."; closing it returns to the list and the form is cleared.
- When the deploy confirms: a notification "Token Deployed" with the Smart Contract UID, then a green toast "Token Auto Mint initiated. (<T1_SCID>: 1000.0)" (web signs this mint without a confirmation), then a notification "Tokens Minted".
- The list shows T1 held by A with balance 1000 (web badge `1000.0 <T1 ticker>`; macOS `Balance: 1000.0`) and the row shows `Transfer`, `Burn` and `Voting` (macOS).
- The uploaded icon is required: the form has no icon URL field, and clicking `Create` before uploading an icon shows the red toast "Icon Image Required" and nothing is compiled. The web form also uploads the icon to Spyglass (`uploadAsset`) as well as embedding it.

**Open question:** the `Is Burnable:` and `Allow Voting:` checkboxes have no key or label and their text is not tappable, and the icon upload opens the native macOS open panel; `tool/drive.dart` can drive neither, so on macOS these are done by hand until keys (for example `token:voting`, `token:burnable`) and a test hook for the picker exist.

**Cleanup:** none; later cases use T1. Record `<T1_SCID>`.

## Token detail and management

### TC-TOKEN-010 · Owner view of a token
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** A owns and holds T1 (mainnet: any account that owns a token; read only).

**Steps**
1. Open the list and tap T1's row. Web: click the row whose text starts with `[<T1 ticker>]`. macOS: `tap-text "[<T1 ticker>] <T1 name>"`.
2. Read the page and take a screenshot.

**Expected**
- Web: the app bar shows the icon and `[<T1 ticker>] <T1 name>`. macOS: the app bar shows the icon and `[<T1 ticker>] <T1 name>`.
- Detail rows (value above its label): `Smart Contract UID` (`<T1_SCID>`, copyable), `Token Name`, `Lifetime Cap` = `Infinite`, `Mintable` = `YES`, `Owner` = A's address (copyable), `Token Ticker` (copyable), `Circulating Supply` = `1000.0`, `Burnable` = `YES`, `Voting` = `YES`; `Description:` with the description.
- Owner actions. Web: a `Manage Token` section with `Mint Tokens`, `Change Ownership`, `Pause TXs`, `Ban Address`, `Prove Ownership`, `Voting`, then `Token Balances` with A's row (`1000.0 <T1 ticker>`, `Voting`, `Transfer`, `Burn`). macOS: `Mint Tokens`, `Pause TXs`, `Prove Ownership`, `Voting`, `Change Ownership`, then `Ban Address`, then `Token Accounts` listing A's address with its balance and `Transfer` / `Burn` / `Voting`.

**Cleanup:** none.

### TC-TOKEN-011 · Copy a detail value
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On T1's detail or management screen.

**Steps**
1. Click the copy icon beside `Smart Contract UID` (web `fltA11y.tap("Copy")` on the first one; macOS `tap-label Copy` fails with several matches, so tap the first copy icon by hand or by screenshot coordinates).

**Expected**
- A green toast "Smart Contract UID copied to clipboard" and the clipboard holds `<T1_SCID>`.

**Cleanup:** none.

### TC-TOKEN-012 · Prove ownership
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On the owner view of T1 (mainnet: of a token the account owns).

**Steps**
1. Click `Prove Ownership` (web `button "Prove Ownership"`; macOS `tap-text "Prove Ownership"`).
2. Click `Copy Signature`.

**Expected**
- A dialog `Ownership Verification Signature` with a read-only field holding the signature string and a `Copy Signature` button.
- Copying shows "Signature Verification copied to clipboard.". No transaction is sent.

**Cleanup:** close the dialog.

### TC-TOKEN-013 · Web: open a token detail by URL
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** `<T1_SCID>` known; web session logged in as A.

**Steps**
1. Load `http://localhost:42069/?automation=1#/dashboard/fungible-token/token/detail/<T1_SCID>`.

**Expected**
- T1's detail page opens with the same content as TC-TOKEN-010.

**Open question:** the route is `token/detail/:scId` under the `fungible-token` tab (the older `fungible/detail/:scId` routes are commented out in `web_router.dart`), and the automation build rewrites the URL to `#./` after load. Confirm whether deep links to a token detail are meant to work, and on which path.

**Cleanup:** none.

## Mint

### TC-TOKEN-014 · Mint more of a mintable token
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** On the owner view of T1 (A owns it; macOS: only A holds T1 in this wallet).

**Steps**
1. Click `Mint Tokens`. Web: `button "Mint Tokens"`. macOS: `tap-key token:mint`.
2. In `Amount to Mint`, enter `250` in `Amount` and click `Submit`.
3. Web: click `Yes` in `Valid Transaction`.
4. Wait up to 3 minutes.

**Expected**
- macOS: a green toast "Token mint transaction broadcasted". Web: "Transaction broadcasted!".
- After confirmation `Circulating Supply` reads `1250.0`, A's balance reads 1250, and a notification "Tokens Minted" appears.

**Cleanup:** none.

### TC-TOKEN-015 · Mint amount validation
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** On the owner view of T1.

**Steps**
1. Open `Mint Tokens`, submit an empty amount.
2. Enter `1.2.3` and submit.
3. Try to type `abc`.
4. Cancel.

**Expected**
- Empty: "Amount is required.". `1.2.3`: "Invalid Amount.". Letters cannot be typed. Nothing is sent.

**Cleanup:** none.

## Transfer

### TC-TOKEN-016 · Transfer tokens from A to B
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** A holds 1250 T1. macOS: only A holds T1 in this wallet (B not imported yet, or imported with no T1).

**Steps**
1. Web: on T1's detail page, in `Token Balances` on A's row click `button "Transfer"`; in `Transfer to` type `TEST_VFX_B_ADDRESS` into `textbox "Address"` and click `Submit`; in `Amount to Transfer` type `100` into `textbox "Amount"` and click `Submit`; click `Yes` in `Valid Transaction`.
2. macOS: on the Fungible Tokens list (or T1's `Token Accounts` row) `tap-key token:transfer`; in `Amount to Transfer` type `100` and `tap-text Submit`; in `To Address` type `TEST_VFX_B_ADDRESS` and `tap-text Submit`.
3. Wait up to 3 minutes for the transfer to confirm.

**Expected**
- Web asks for the address first, then the amount; macOS asks for the amount first, then the address (the `To Address` field has an address-book icon).
- Web: a green toast "Transaction broadcasted!". macOS: "Token transfer transaction broadcasted".
- After confirmation A's T1 balance is 1150 and B's is 100 (check B by logging in as B on web, or B's group on macOS once B is imported). A notification "Token Transfer" appears. `Circulating Supply` is unchanged at 1250.

**Cleanup:** none.

### TC-TOKEN-017 · Transfer and burn amount and address validation
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** A holds 1150 T1.

**Steps**
1. Transfer with amount `999999` to `TEST_VFX_B_ADDRESS`.
2. Transfer with address `notanaddress`.
3. Web only: transfer to A's own address (`TEST_VFX_A_ADDRESS`).
4. Burn with amount `999999` (web: A's `Token Balances` row `Burn`; macOS: the row's `Burn`).

**Expected**
- Step 1: macOS "Not enough balance to perform this transaction" (after the amount prompt, before the address prompt); web "This address's (<A address>) <T1 ticker> balance is insufficient." (after both prompts). Nothing is sent.
- Step 2: the address prompt shows "Invalid Address." and stays open.
- Step 3: "Tokens cannot be transferred to the address that holds them." and nothing is sent.
- Step 4: macOS "Not enough balance to perform this transaction"; web the same insufficient-balance message as step 1.

**Open question:** macOS has no self-transfer check (`isTokenTransferToSelf` is only used on the web), so a desktop transfer to the holder's own address reaches the CLI and is refused there. Decide whether the desktop should share the web check; until then do not run a self-transfer on macOS.

**Cleanup:** cancel any open prompt.

### TC-TOKEN-018 · Web: pending sends count against the balance
**Platforms:** Web · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** A holds 1150 T1 on the web, no pending token transactions.

**Steps**
1. Transfer `1100` T1 to `TEST_VFX_B_ADDRESS` and confirm.
2. Before it confirms, start a second transfer of `100` to `TEST_VFX_B_ADDRESS`.
3. Wait up to 3 minutes, then return 1100 from B to A (log in as B and transfer back) so later cases keep their balances.

**Expected**
- Step 2 is refused with "Not enough balance once pending sends are counted. Available: 50 <T1 ticker>" and nothing is sent.

**Cleanup:** step 3 restores A to 1150 and B to 100.

### TC-TOKEN-019 · Holder (non-owner) view
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** B holds 100 T1 and does not own it. Web: logged in as B. macOS: B imported into the wallet (`01-launch-auth.md`).

**Steps**
1. Open the Fungible Tokens list and tap T1's row under B.

**Expected**
- Web: the detail page shows the same token rows as TC-TOKEN-010 but no `Manage Token` section; `Token Balances` lists B's row with `Voting`, `Transfer` and `Burn`.
- macOS: instead of the management screen a `Token Details` dialog opens with the same detail rows (owner is A).

**Cleanup:** web: log back in as A.

## Burn

### TC-TOKEN-020 · Burn tokens
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** A holds 1150 T1 and owns it.

**Steps**
1. Web: on T1's detail page, A's `Token Balances` row, click `button "Burn"`, enter `10` in `Amount to Burn`, `Submit`, then `Yes`. macOS: `tap-text Burn` on A's T1 row, enter `10` in `Amount to Burn`, `tap-text Submit`.
2. Wait up to 3 minutes.

**Expected**
- Web "Transaction broadcasted!"; macOS "Token burn transaction broadcasted".
- After confirmation A's balance is 1140 and `Circulating Supply` is `1240.0`; a notification "Token Burn" appears.

**Cleanup:** none.

## Pause and resume

### TC-TOKEN-021 · Pause a token, see transfers blocked, resume
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** On the owner view of T1 as A.

**Steps**
1. Click `Pause TXs`. Web: `button "Pause TXs"`. macOS: `tap-text "Pause TXs"`.
2. Confirm. Web: `Yes` in `Pause Transactions`, then `Yes` in `Valid Transaction`. macOS: `tap-text Pause` in `Pause Token Transactions`.
3. Click the button again while it reads `Pending Pause`. Web: `button "Pending Pause"`. macOS: `tap-text "Pending Pause"`.
4. Wait up to 3 minutes for the button to read `Resume TXs`.
5. Try to transfer 1 T1 to `TEST_VFX_B_ADDRESS` as in TC-TOKEN-016.
6. Click `Resume TXs` and confirm (web `Yes`, `Yes`; macOS `tap-text Resume`). Wait up to 3 minutes for `Pause TXs` to return.

**Expected**
- Confirmations: web `Pause Transactions` "Are you sure you want to pause all transactions with this token?" (`No` / `Yes`); macOS `Pause Token Transactions` "Are you sure you want to pause token transactions? This will prevent transfers and burning of this token until resumed." (`Cancel` / `Pause`).
- After step 2: web "Transaction broadcasted!"; macOS "Token pause transaction broadcasted". On both platforms the button turns into a spinner reading `Pending Pause`, and step 3 shows "Token state change is pending. Please wait" and sends nothing. The web keeps the pending state until a 10-second refresh reports the token paused.
- Once paused: the button reads `Resume TXs`; the web app bar and list read `[<T1 ticker>] <T1 name> (PAUSED)`; a notification "Token Pause" appears.
- Step 5: web refuses before the address prompt with "Transactions on this token are currently paused."; macOS shows the CLI's refusal as a red toast and nothing confirms.
- Resume: web `Resume Transactions` "Are you sure you want resume transactions with this token?"; macOS `Resume Token Transactions` "Are you sure you want to resume token transactions?" and the toast "Token resume transaction broadcasted"; on both platforms the button reads `Pending Resume` (a spinner) until the resume reaches the chain; afterwards the button reads `Pause TXs` and `(PAUSED)` is gone.

**Open question:** the macOS refusal text in step 5 comes from the CLI (`TransferToken`); record it on the first run.

**Cleanup:** make sure T1 is resumed before continuing.

## Voting topics

### TC-TOKEN-022 · No topics yet
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** T1 has no topics. Owner A on the owner view; B holds 100 T1.

**Steps**
1. Web as A: click `Voting` in `Manage Token` and read the sheet. macOS as A: `tap-text Voting` on the management screen action row, then `tap-text "View Topics"`.
2. Web as B: on B's `Token Balances` row click `Voting`. macOS: on B's T1 row in the list, `tap-text Voting`.

**Expected**
- Web owner: the sheet shows only `Create New Voting Topic` ("As the token owner, you can create topics for other holders to vote on.").
- macOS owner: the sheet offers `Create Token Topic` and `View Topics`; `View Topics` shows `No Topics` with "This token doesn't have any voting topics yet.".
- Holder: web shows "No Voting Topics"; macOS shows `No Topics` as above.

**Cleanup:** close the sheet or dialog.

### TC-TOKEN-023 · Topic form validation and discard
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Owner A on the owner view of T1.

**Steps**
1. Open the topic form. Web: `Voting` → `Create New Voting Topic`. macOS: `tap-text Voting` → `tap-text "Create Token Topic"`.
2. Click `Create Topic` with every field empty, then click `Create` in the confirmation.
3. Type 130 characters into `Topic Name`.
4. Click `Cancel`, answer `No`, then `Cancel` and `Yes`.

**Expected**
- The screen is `Create Token Topic` with `Topic Name` (counter `128 character limit` and `n/128`), `Voting Ends` defaulting to `30 Days` with `60 Days`, `90 Days`, `180 Days`, `Topic Description` (`1,600 character limit including provided links`, `n/1600`), and `Minimum Token Requirement` ("The minimum token balance required to vote.").
- Step 2: the confirmation `Create Topic` "Are you sure you want to create this token topic?" appears first; after `Create`, the fields show "Name is required.", "Description is required." and "Minimum Token Requirement is required." and nothing is sent.
- Step 3: the name stops at 128 characters.
- `Cancel` asks `Discard` "Are you sure you want to discard this new topic?"; `No` keeps the form, `Yes` clears it and goes back.

**Open question:** the confirmation dialog opens before the form is validated (`token_topic_form.dart`), so an empty form still asks "Are you sure you want to create this token topic?"; confirm whether validation should come first. On macOS the minimum field only accepts digits.

**Cleanup:** none.

### TC-TOKEN-024 · Create a token voting topic
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Owner A on the owner view of T1.

**Steps**
1. Open the topic form as in TC-TOKEN-023. On macOS this pushes `tokens/create-topic/<T1_SCID>/<A address>`; on web `token/detail/new-topic/<T1_SCID>/<A address>`.
2. `Topic Name`: `QA topic <RUN_ID>`. `Voting Ends`: `30 Days`. `Topic Description`: `Release test topic`. `Minimum Token Requirement`: `50`.
3. Click `Create Topic`, then `Create`. Web: then `Yes` in `Valid Transaction`.
4. Wait up to 3 minutes, then reopen the topic list (web `Voting`; macOS `Voting` → `View Topics`).

**Expected**
- Web: "Transaction broadcasted!" then "Token Topic Created", and the form closes. macOS: "Token Topic Created" and the form closes.
- After confirmation a notification "Token Topic Created" appears and the topic list shows `QA topic <RUN_ID>` with its description.

**Cleanup:** none.

### TC-TOKEN-025 · Owner votes Yes
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** The topic from TC-TOKEN-024 is confirmed. A holds 1140 T1.

**Steps**
1. Open the topic from the topic list (tap `QA topic <RUN_ID>`).
2. Read the page.
3. Click `Vote Yes`, then `Vote YES` in the confirmation. Web: then `Yes` in `Valid Transaction`.
4. Wait up to 3 minutes; the page polls every 20 s.

**Expected**
- The page shows the topic name as title and heading, `UID: <topic uid>`, `Topic Created` and `Voting Ends` dates, the description, `Smart Contract UID: <T1_SCID>`, macOS also `Block Height: <n>`, `Minimum Tokens to Vote: 50`, `Your Balance: 1140.0`, "No votes yet.", `Cast Your Vote` with `Vote Yes` and `Vote No`, and "Voting ends <date>.".
- The confirmation is `Confirm Vote [YES]` "Are you sure you want to vote YES on this token topic?" with `Cancel` / `Vote YES`.
- After sending: the toast "Vote casted"; the buttons are replaced by "Vote transaction pending." (macOS) or "You have voted." (web).
- After confirmation (macOS) "You voted YES on block <n>."; `Vote Counts` shows `Votes Yes` 1 and `Total Votes` 1, `Percentages` shows `Votes Yes` 100% and `Result` `In Progress`; a notification "Token Vote Cast" appears.

**Open question:** the web never loads the address's existing vote (only the desktop polls `GetVotesByAddress`), so after a reload the web shows the vote buttons again for an address that has voted. Confirm whether the web should show "You voted ..." as the desktop does.

**Cleanup:** none.

### TC-TOKEN-026 · Holder votes No
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** TC-TOKEN-025 done. B holds 100 T1 (at least the 50 minimum) and 2 VFX. Web: logged in as B. macOS: B imported.

**Steps**
1. Open the topic as B. Web: T1 detail, B's `Token Balances` row `Voting`, tap the topic. macOS: B's T1 row in the list, `tap-text Voting`, tap the topic.
2. Click `Vote No`, then `Vote NO` in `Confirm Vote [NO]` ("Are you sure you want to vote NO on this token topic?"). Web: then `Yes`.
3. Wait up to 3 minutes.

**Expected**
- `Your Balance: 100.0` before voting.
- "Vote casted", then the pending text as in TC-TOKEN-025; after confirmation `Votes Yes` 1, `Votes No` 1, `Total Votes` 2, 50% each.

**Cleanup:** web: log back in as A.

### TC-TOKEN-027 · Balance below the topic minimum cannot vote
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Owner A on the owner view of T1, holding 1140 T1.

**Steps**
1. Create a second topic as in TC-TOKEN-024 with name `QA min <RUN_ID>` and `Minimum Token Requirement` `100000`; wait up to 3 minutes for it to confirm.
2. Open `QA min <RUN_ID>` as A.

**Expected**
- In place of the vote buttons: "You need at least 100000 tokens to vote.".

**Cleanup:** none.

### TC-TOKEN-028 · Owner vote history
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** TC-TOKEN-026 confirmed; A on the first topic's page (opened from the owner's topic list).

**Steps**
1. Click `Vote History`.
2. Open `QA min <RUN_ID>` and look for `Vote History`.

**Expected**
- Step 1: a sheet lists the voting addresses (A and B), each with its vote time.
- Step 2: a topic with no votes shows "No votes yet." and no counts, so `Vote History` is not shown.

**Open question:** the desktop branch of `Vote History` (`token_topic_detail_screen.dart`) was not traced end to end; record what it lists on the first run. On the web, `Vote History` on a topic whose vote list is empty shows the toast "No Votes".

**Cleanup:** close the sheet.

## Ban an address

### TC-TOKEN-029 · Ban an address and list bans
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Owner A on the owner view of T1. Voting cases done (this bans B).

**Steps**
1. Click `Ban Address` (web `button "Ban Address"`; macOS `tap-text "Ban Address"`).
2. Submit `notanaddress`, then `TEST_VFX_B_ADDRESS`. Web: then `Yes` in `Valid Transaction`.
3. Wait up to 3 minutes, then click the bans button.

**Expected**
- The prompt is `Address to Ban` (web) or `Address To Ban` (macOS) with an `Address` field; `notanaddress` shows "Invalid Address.".
- Web "Transaction broadcasted!"; macOS "Token address ban transaction broadcasted".
- After confirmation a notification "Token Ban Address" appears; the owner view shows `List Bans (1)` (web) or `List Bans` (macOS), which opens `Banned Addresses` listing B's address.

**Cleanup:** none.

## Fixed-supply token and ownership

### TC-TOKEN-030 · Create a fixed-supply, non-burnable token without voting
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Logged in as account A with at least 5 VFX.

**Steps**
1. Open the create form. Enter T2's name and ticker.
2. Tick `Token Has Fixed Supply:` and set `Total Supply:` to `500`. Set decimals to 2. Untick `Is Burnable:`. Leave `Allow Voting:` unticked. Upload the icon.
3. Click `Create`, then `Continue` and `Compile & Mint`.
4. Wait up to 5 minutes for T2 to appear in the list.

**Expected**
- No pre-mint prompt appears on either platform (the token is not mintable and the supply is not 0).
- After confirmation A holds 500 T2. The owner view shows `Fixed Supply` 500, `Lifetime Cap` 500, `Mintable` `NO`, `Burnable` `NO`, `Voting` `NO`, `Circulating Supply` 500.
- No `Mint Tokens` button in the owner view and no `Burn` button on A's T2 row (macOS: if the row still shows `Burn` because the token's details were not cached yet, tapping it gives the red toast "This token is not burnable" and nothing is sent); macOS shows no `Voting` in the owner actions and on the row; web still shows `Voting` in `Manage Token`.

**Cleanup:** record `<T2_SCID>`.

### TC-TOKEN-031 · Change token ownership
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** A owns T2 (TC-TOKEN-030).

**Steps**
1. Open T2's owner view and click `Change Ownership`.
2. Web: in `New Owner's Address` type `TEST_VFX_B_ADDRESS`, `Submit`, then `Yes`. macOS: in `Transfer To Address` type `TEST_VFX_B_ADDRESS` into `To Address`, `tap-text Submit`.
3. Wait up to 3 minutes.

**Expected**
- macOS: "Token ownership change transaction broadcasted" and the management screen closes; tapping T2's row afterwards opens the `Token Details` dialog instead of the management screen.
- Web: "Transaction broadcasted!"; after confirmation the `Manage Token` section disappears for A.
- `Owner` reads B's address; a notification "Token Change Ownership" appears. A still holds its 500 T2.

**Cleanup:** none.

## All tokens and balances

### TC-TOKEN-032 · All My Tokens lists fungible tokens with balances
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Logged in as account A.

**Steps**
1. Open Dashboard and click the `Tokens` action.
2. Read the list, then tap T1's entry.
3. Go back to the list and click the back arrow (`button "Back"` / `tap-label Back`).

**Expected**
- The screen is headed `All My Tokens`. With nothing held it reads "You have no vBTC Tokens, Fungible Tokens, or Non-Fungible Tokens".
- Web: T1 reads `<T1 name>` with the subtitle `Fungible Token (1140.0 <T1 ticker>)`; tapping opens T1's detail page.
- macOS: T1 reads `<T1 name>` with the subtitle `Fungible Token`; tapping opens T1's management screen.
- Back returns to the dashboard.

**Open question:** the web list comes from token balances only, so a web owner of a mintable token with no issuance yet (no pre-mint) sees it nowhere (not on Fungible Tokens, not on All My Tokens) and cannot reach its detail page to mint. The desktop All My Tokens lists tokens from the smart contract list instead. Confirm how a web owner is meant to reach such a token.

**Cleanup:** none.

### TC-TOKEN-033 · Balances agree across screens
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** All earlier cases in this file confirmed. Expected holdings: A 1140 T1 and 500 T2; B 100 T1; T1 circulating supply 1240 (mainnet: compare whatever the account holds).

**Steps**
1. Read A's T1 and T2 balances on the Fungible Tokens list, on each token's detail or management screen (web `Token Balances`, macOS `Token Accounts`), and on All My Tokens.

**Expected**
- Every screen shows A holding 1140 T1 and 500 T2; T1's `Circulating Supply` reads 1240.0.
- Balances show as decimals (`1140.0`) on every screen; web list badges read `<balance> <TICKER>`.

**Cleanup:** none.

### TC-TOKEN-034 · Vault-held tokens cannot be moved
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** A vault account (`06-vault-accounts.md`) holds some T1: transfer 10 T1 to the vault address as in TC-TOKEN-016 (that transfer moves funds).

**Steps**
1. Web: open T1's detail page and read the vault address's `Token Balances` row.
2. macOS: on the Fungible Tokens list find the vault group (address in the vault colour) and tap `Transfer` on its T1 row, close the dialog, then tap `Burn`.

**Expected**
- Web: the vault row shows its balance and "Transfer, burn and voting are not available for tokens held in the Vault. Move them out of the Vault first." with no buttons.
- macOS: the `Transfer` and `Burn` buttons are greyed, and tapping either opens `Not Supported by Vault Account` with "Vault Account owned tokens can not perform this action."; no amount prompt opens and nothing is sent.

**Cleanup:** none.
