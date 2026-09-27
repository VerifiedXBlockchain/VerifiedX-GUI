# 02 · Dashboard, navigation and settings

This file covers what a logged-in user sees around every screen: the dashboard on each platform (VFX, Vault and BTC balance cards, their latest-transaction cards and actions, the coin price cards and charts, the All My Tokens screen), the side navigation with its per-platform items, collapse and expand and the web mobile drawer, the desktop status and sync indicators, the Operations status panel, Activity Log and diagnostic buttons, the CLI configuration screen, the language selector, the version display and the desktop update prompts. Nothing here signs a transaction except TC-DASH-005, which sends a small amount to watch a balance refresh.

## Area preconditions

- **Web.** The testnet automation build is open at `http://localhost:42069/?automation=1` with `fltA11y` injected, logged in as account A (`TEST_VFX_A_PRIVKEY`, see TC-AUTH-016), on the Home tab. The browser window is at least 1260 px wide unless a case resizes it; below 581 px the web wallet switches to its mobile layout.
- **macOS.** The driver build is running with account A imported and selected, the chain synced (the sync dot tooltip reads `Synced`), and the wallet unlocked if it is encrypted.
- **Hover.** Several panels open on mouse hover only (web `Addresses` tab, both platforms' block tab, balance cards off the Home tab). On web, hover with Claude in Chrome's mouse move. `drive.dart` cannot hover; the desktop cases use taps or screenshots instead and say so.
- **Multi-line labels.** Dashboard action buttons have two-line labels such as `Send` / `Coin`. On web `fltA11y.tap("Send")` matches by "contains"; on macOS pass the exact text with the line break, for example `tap-text $'Send\nCoin'`.
- **Duplicate labels on macOS.** `drive.dart` fails with `Too many elements` when a text or tooltip appears more than once, and some controls have no key: `View Chart`, `View All Txs` and `New Address` (one per card), `Add Account` on an empty account panel (header and empty state), the `Restart` confirm (title and button share the text), `Import` in the bulk importer while its confirm dialog is open, and per-row tooltips such as `Reveal Private Key`, `Hide Account` and the Activity Log `Copy`. Where a step hits one of these, reduce the screen to a single match if the case says how, otherwise do that tap by hand and note `manual tap` in the result.
- **Mainnet smoke.** Cases tagged `Mainnet smoke` run on the production web wallet (logged in with `TEST_VFX_A_PRIVKEY`, whose mainnet balance may be zero) and on a normal desktop build, and only observe. Skip any step that opens a payment or on-ramp flow beyond its first chooser.

## Web dashboard

### TC-DASH-001 · Web dashboard loads with balances
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Logged in as account A, Home tab.

**Steps**
1. Web: `read_page`, screenshot `TC-DASH-001`.
2. Compare the VFX figure with account A's balance on the Spyglass explorer (testnet explorer for testnet).

**Expected**
- On testnet a green bar reads `VFX TESTNET` across the top.
- Top-left shows the cube and the wordmark `Verified` `X` with `Switchblade` under it.
- Two balance cards are expanded at the top: VFX with `<n> VFX` (account balance plus Vault balance) and BTC with `<n> BTC` in 8 decimals. Each shows `Latest TX:` and `View All Txs`.
- Two price cards (VFX and BTC) show a `$<price>` with 4 decimals and a 1h/24h change, each with `View Chart` and `Get VFX` / `Get BTC`.
- The action row shows `Send Coin`, `Receive Coin`, `TXs`, `Tokens`, `Tutorials`, `Get Help`, `Open Explorer`, `Verify Owner` and `Sign Out`.
- The VFX figure matches the explorer within the 30-second refresh window (testnet: at least 200 VFX).

**Cleanup:** none.

### TC-DASH-002 · VFX balance card: latest transaction and actions
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Logged in as account A, which has at least one confirmed VFX transaction.

**Steps**
1. Screenshot the VFX card.
2. Click its `Copy Address` action (`fltA11y.tap("Copy")` on the VFX card); read the clipboard.
3. Click `Vault Address`; read the clipboard.
4. Click `Get VFX`; screenshot the sheet; close it without choosing.
5. Click the latest-transaction card.
6. Go back to Home and click `View All Txs` on the VFX card.

**Expected**
- The latest-transaction card shows either `<amount> VFX` (green for incoming, red for outgoing) or the transaction type, then `From: <address>`, `To: <address>` (Vault addresses in the Vault colour) and `Success` or `Pending`. Without transactions the card area reads `No Transactions`.
- Copy Address shows `Address copied to clipboard` and the clipboard holds `TEST_VFX_A_ADDRESS`; Vault Address copies account A's `xRBX…` Vault address.
- Get VFX opens the `Choose Payment Gateway` sheet (on testnet it includes `Testnet Faucet`); closing it has no side effects. Without an address it shows `No address selected` instead.
- A confirmed latest transaction opens the Transactions tab with that transaction's detail; a pending one does nothing.
- View All Txs opens the Transactions tab with VFX selected.

**Cleanup:** Clear the clipboard.

### TC-DASH-003 · BTC balance card
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as account A (its derived BTC account) or an account made from `TEST_BTC_WIF` for a non-zero balance.

**Steps**
1. Screenshot the BTC card.
2. Click `Copy Address` on the BTC card; read the clipboard.
3. Click `Get BTC`, screenshot, close. Click `Off Ramp BTC`, screenshot, close.
4. Click `View All Txs` on the BTC card.

**Expected**
- The heading is `<n> BTC` with 8 decimals. A latest BTC transaction card shows `<amount> BTC`, `From: …` / `To: …` and `Confirmed` or `Pending`; otherwise `No Transactions`.
- Copy Address copies the account's BTC address with the toast `Address copied to clipboard`.
- Get BTC opens `Choose Payment Gateway`; Off Ramp BTC opens its first off-ramp dialog (or a toast when the BTC balance is too low); both close cleanly. Payment flows themselves are in `12-payments-faucet-keygen.md`.
- View All Txs opens Transactions with BTC selected.

**Cleanup:** none.

### TC-DASH-004 · The VFX total includes the Vault balance
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Account A has a non-zero Vault balance (see `06-vault-accounts.md`); otherwise record `skipped`.

**Steps**
1. Hover the `Addresses` tab; note the VFX row balance and the Vault row balance.
2. Compare with the VFX card heading.

**Expected**
- The card heading equals the VFX balance plus the Vault balance.

**Cleanup:** none.

### TC-DASH-005 · Balances refresh without a reload
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Web logged in as account B (`TEST_VFX_B_PRIVKEY`) on Home. macOS with account A selected and at least 2 VFX.

**Steps**
1. Note account B's VFX figure on web.
2. On macOS send 1 VFX from account A to `TEST_VFX_B_ADDRESS` (any send path from `03-send-receive-transactions.md`).
3. Without touching the web page, take a web screenshot every 15 seconds for up to 3 minutes.
4. On macOS take a screenshot of the VFX card every 15 seconds for up to 3 minutes.

**Expected**
- Web: within 3 minutes of the transaction confirming, the VFX card rises by 1 and its latest-transaction card shows the incoming `1 VFX` from account A, without a reload.
- macOS: the VFX card total falls by 1 plus the fee and the latest-transaction card shows `-1 VFX` (red), first `Pending`, then `Success`.

**Cleanup:** none (the funds stay in the test accounts).

### TC-DASH-006 · Addresses panel
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Logged in as account A, window at least 1260 px wide.

**Steps**
1. Hover the `Addresses` tab at the bottom-left until the panel slides up; screenshot.
2. Click the copy icon next to the VFX address (`fltA11y.tap("Copy address")`); read the clipboard.
3. Open the VFX row's three-dot menu and choose `Copy Address`.
4. Move the mouse away.

**Expected**
- The panel lists a `VFX` row (address, `<n> VFX` or `<n> VFX | @<domain>`), a `Vault` row (`<n> VFX`, or `Recovered & Deactivated` for a deactivated Vault) and a `BTC` row (`<n> BTC` or with `| @<domain>`), then `Backup` and `Sign Out`.
- Both copy paths show `Address copied to clipboard.` and copy `TEST_VFX_A_ADDRESS`.
- The panel slides back down when the mouse leaves, unless a row menu is open.

**Cleanup:** Clear the clipboard.

### TC-DASH-007 · Block height tab
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Logged in.

**Steps**
1. Screenshot the bottom-right corner; note `Block <height>`.
2. Hover the tab until the latest-block card slides up; screenshot.
3. Wait 2 minutes and screenshot the tab again.

**Expected**
- The tab reads `Block <height>` with the current chain height (compare with the explorer).
- The card shows the latest block's details (for example `Hash`, `Validated By`, `# of Txs`, `Total Amount`, `Total Reward`, `Size`, `Craft Time`).
- The height increases over the 2 minutes.

**Cleanup:** none.

### TC-DASH-008 · Price cards and price charts
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Home tab.

**Steps**
1. Click `View Chart` on the VFX price card; screenshot; close the full-screen chart.
2. Click `View Chart` on the BTC price card; screenshot; close it.

**Expected**
- The VFX chart opens full screen titled `VFX Price History` with a USDT axis and a price line over recent days; the BTC one is titled `BTC Price History`.
- If the price service fails, the card shows `Error Loading Data` instead of a price; record that as a fail with the time.

**Cleanup:** none.

### TC-DASH-009 · All My Tokens
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Account A. For the list branch, account A holds at least one fungible token, vBTC token or NFT (created in areas 04, 08, 09); otherwise only the empty branch is checked.

**Steps**
1. Click the `Tokens` action. Web: `fltA11y.tap("Tokens")`. macOS: `tap-text Tokens`.
2. Screenshot.
3. Tap one fungible token row, screenshot, go back; repeat for a vBTC row and an NFT row if present.
4. Tap the back button (web `fltA11y.tap("Back")`, macOS `tap-label Back`).

**Expected**
- macOS shows `Loading...` briefly, then both platforms open `All My Tokens`; the balance cards collapse.
- Rows read `<name>` with `Fungible Token (<balance> <ticker>)`, `vBTC Token (<balance> vBTC)`, `Fungible Token` or `Non-Fungible Token`; with none the screen says `You have no vBTC Tokens, Fungible Tokens, or Non-Fungible Tokens`.
- A fungible row opens its token detail, a vBTC row its vBTC detail, an NFT row its NFT detail.
- Back returns to the dashboard with the cards expanded again.
- macOS with no account selected: the Tokens action shows `No account selected` instead.

**Cleanup:** none.

### TC-DASH-010 · Tutorials, Get Help and Open Explorer
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Home tab.

**Steps**
1. Click `Tutorials`; note the opened URL; close it.
2. Web only: click `Get Help`; screenshot; open each entry and close the new tab.
3. Click `Open Explorer`; screenshot; choose `VFX Explorer`, close; reopen and choose `BTC Explorer`, close.

**Expected**
- Tutorials opens `https://docs.verifiedx.io/docs/tutorials/video-tutorials/` in the browser.
- Get Help opens a sheet `Get Help` with `Join Discord` (`https://discord.gg/7cd5ebDQCj`), `Visit Website` (`https://verifiedx.io`) and `Read Docs` (`https://docs.verifiedx.io`). There is no Get Help action on macOS.
- Open Explorer opens a sheet `Open Explorer`; `VFX Explorer` opens the network's Spyglass explorer and `BTC Explorer` opens `https://mempool.space/testnet4/` on testnet (`https://mempool.space/` on mainnet).

**Cleanup:** Close the opened browser tabs.

### TC-DASH-011 · Verify Owner rejects a bad signature
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Home tab. The positive ownership check is covered in `09-smart-contracts-nfts.md`.

**Steps**
1. Click `Verify Owner`; screenshot.
2. Submit with the field empty; screenshot.
3. Type `abc<>def` and submit; screenshot.

**Expected**
- The prompt is `Validate Ownership` with `Paste in the signature provided by the owner to validate its ownership.` and label `Signature`.
- Empty: `Signature is required.`
- A value without four `<>`-separated parts: red toast `Invalid ownership verification signature`.

**Cleanup:** none.

## Desktop dashboard

### TC-DASH-012 · Desktop dashboard loads with balances
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Accounts A and B imported, account A selected, chain synced.

**Steps**
1. macOS: `tap-key nav:dashboard`, `wait-for-text $'Send\nCoin'`, `screenshot TC-DASH-012.png`.
2. Open the account panel (`tap-label "Selected VFX Address"`) and add up the listed VFX balances.

**Expected**
- The VFX card heading is `<total> VFX`, the sum of every listed VFX and Vault account; under it `<n> Addresses` (or `<n> Address`), plus `<n> Vault Address(es)` when Vault accounts exist.
- The BTC card heading is `<n> BTC` with `<n> Account(s)`.
- Both cards are expanded with `Latest TX:` and `View All Txs`, and the price cards show `View Chart` with `Get VFX` / `Get BTC`.
- The action row shows `Send Coin`, `Receive Coin`, `TXs`, `Tokens`, `Tutorials`, `Verify Owner`, `Open Explorer`.
- The heading equals the sum from step 2.

**Cleanup:** none.

### TC-DASH-013 · Desktop VFX card actions
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Dashboard with account A.

**Steps**
1. `tap-text $'View\nAddress'`; screenshot; go back (`tap-label Back`).
2. Tap `New Address` on the VFX card (manual tap, the label repeats on the BTC card); screenshot; close the dialog by tapping outside it.
3. `tap-text $'Get\nVFX'`; screenshot; close the sheet.
4. Tap `View All Txs` on the VFX card (manual tap).

**Expected**
- View Address opens a full-screen `My Accounts` screen with the account panel in VFX mode.
- New Address opens `Add VFX Account` (`Create` / `Import`).
- Get VFX opens `Choose Payment Gateway` (with `Testnet Faucet` on testnet); closing it changes nothing.
- View All Txs opens the Transactions tab with VFX selected (`VFX Transactions`).

**Cleanup:** none.

### TC-DASH-014 · Desktop BTC card actions
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Dashboard.

**Steps**
1. `tap-text $'View\nAddresses'`; screenshot; go back.
2. Tap `New Address` on the BTC card (manual tap); screenshot; close.
3. `tap-text $'Get\nBTC'`; screenshot; close.
4. Tap `View All Txs` on the BTC card (manual tap).

**Expected**
- View Addresses opens `My Accounts` in BTC mode (`No BTC Accounts` when there are none).
- New Address opens `Add BTC Account` (`Create a new BTC account` / `Import an existing BTC private key`).
- View All Txs opens Transactions with BTC selected (`BTC Transactions`).

**Cleanup:** none.

### TC-DASH-015 · Desktop latest transaction cards
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Account A has VFX transactions; BTC account optional.

**Steps**
1. Screenshot both cards on the dashboard.
2. Tap the VFX latest-transaction card.

**Expected**
- The VFX card shows `<amount> VFX` (green incoming, red outgoing), `From: <address>` / `To: <address>` and `Success` or `Pending`.
- The BTC card shows `<amount> BTC` the same way, or `No Transactions`.
- Tapping the card opens the Transactions tab.

**Cleanup:** none.

### TC-DASH-016 · Desktop price charts
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Dashboard.

**Steps**
1. Tap `View Chart` on the VFX price card (manual tap, see Area preconditions); screenshot; close.
2. Repeat for the BTC card.

**Expected**
- Full-screen charts titled `VFX Price History` and `BTC Price History` open and close.
- A failed price load shows `Error Loading Data` on the card.

**Cleanup:** none.

### TC-DASH-017 · Balance cards expand on Home and collapse elsewhere
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Logged in, Home tab.

**Steps**
1. Screenshot Home.
2. Open Send (web `button "Send"`, macOS `tap-key nav:send`); screenshot.
3. Web only: hover the VFX card; screenshot.
4. Return to Dashboard.

**Expected**
- On Home the cards are expanded with the latest transaction and actions.
- On other tabs only the headings show; on web hovering a card expands it until the mouse leaves.
- Back on Home they expand again.

**Cleanup:** none.

### TC-DASH-018 · Chain rebuild banner and placeholder
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** The CLI reports `IsResyncing` (for example right after TC-AUTH-003's hard kill triggers a state rebuild). Otherwise record `skipped`.

**Steps**
1. Screenshot the dashboard and one other tab while the rebuild runs.

**Expected**
- A gold banner below the top bar reads `Rebuilding chain state` and `VFXCore is re-verifying its copy of the ledger. Balances show as zero until it finishes, which can take several minutes. Keep the wallet open.`
- The VFX card heading reads `Rebuilding…` instead of a number; the sync indicator tooltip reads `Resyncing...`.
- Both disappear and the real balance returns when the rebuild ends.

**Cleanup:** none.

**Open question:** there is no reliable way to make the CLI rebuild its state on demand; confirm a trigger or keep the case opportunistic.

## Side navigation

### TC-DASH-019 · Web side nav items
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Logged in, window at least 1260 px wide, nav expanded.

**Steps**
1. `read_page`; list the buttons in the side nav; screenshot.

**Expected**
- Above the list sits `Select Account`.
- The list is, in order: `Dashboard`, `Vault Account`, `Domains`, `Send`, `Receive`, `Launch BFLY`, `Transactions`, `vBTC Tokens`, `Fungible Tokens`, `Smart Contracts`, `NFTs`, `P2P Auctions`, `Sign Out`.
- `Privacy`, `Validator`, `Operations` and `Crypto.com` are not shown on web.
- `Dashboard` is highlighted as active.

**Cleanup:** none.

### TC-DASH-020 · Desktop side nav items
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Dashboard, nav expanded.

**Steps**
1. Screenshot the side nav.
2. For each label run `wait-for-text <label> --timeout 5`: `Dashboard`, `Vault Accounts`, `Domains`, `Send`, `Receive`, `Launch BFLY`, `Transactions`, `vBTC Tokens`, `Privacy`, `Fungible Tokens`, `Smart Contracts`, `NFTs`, `P2P Auctions`, `Operations`.
3. Run `tap-key nav:sign_out --timeout 5`, `tap-key nav:validator --timeout 5` and `tap-key nav:crypto_com --timeout 5`.

**Expected**
- The labels are, in order: `Dashboard`, `Vault Accounts`, `Domains`, `Send`, `Receive`, `Launch BFLY`, `Transactions`, `vBTC Tokens` (in BTC orange), `Privacy` (with a `NEW` badge), `Fungible Tokens`, `Smart Contracts`, `NFTs`, `P2P Auctions`, `Operations`.
- Every label in step 2 is found; the keys in step 3 are not found (each command exits 1).

**Cleanup:** none.

### TC-DASH-021 · Every web nav item opens its section
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. For each item click its button, wait for the screen, note the URL (its hash ends with the path given below) and the heading, and screenshot: `Vault Account`, `Domains`, `Send`, `Receive`, `Transactions`, `vBTC Tokens`, `Fungible Tokens`, `Smart Contracts`, `NFTs`, then `Dashboard`. P2P Auctions is out of scope for this suite.

**Expected**
- Each click highlights that item and opens its section: Vault Account `dashboard/vault-accounts` (`Your Vault Account`), Domains `dashboard/adnrs` (`Domains`), Send `dashboard/send` (`Send VFX`), Receive `dashboard/receive` (`Receive VFX`), Transactions `dashboard/transactions` (`Transactions`), vBTC Tokens `dashboard/vbtc` (`Tokenized Bitcoin (vBTC)`), Fungible Tokens `dashboard/fungible-token` (`Fungible Tokens`), Smart Contracts `dashboard/smart-contract` (`Create Smart Contract`), NFTs `dashboard/nfts` (`NFTs`), Dashboard `dashboard/home`.
- No section shows an error or a blank page.

**Cleanup:** none.

**Open question:** the headings are taken from each screen's app bar title in code; some web screens hide their app bar in the desktop layout. If a heading is missing but the URL and content are right, record a pass with a note.

### TC-DASH-022 · Every desktop nav item opens its section
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Account A selected.

**Steps**
1. For each key run `tap-key <key>`, then `wait-for-text "<heading>"` and a screenshot: `nav:vault_accounts` → `Vault Accounts`, `nav:domains` → `VFX Domains` or `Domains`, `nav:send` → `Send VFX`, `nav:receive` → `Receive VFX`, `nav:transactions` → `VFX Transactions` or `All Transactions`, `nav:vbtc_tokens` → `Tokenized Bitcoin (vBTC)`, `nav:privacy` → `PRISM Privacy`, `nav:fungible_tokens` → `Fungible Tokens`, `nav:smart_contracts` → `Smart Contracts`, `nav:nfts` → `NFTs`, `nav:operations` → `Operations`.
2. `tap-key nav:dashboard`, `wait-for-text $'Send\nCoin'`.

**Expected**
- Each item opens its section with that heading and is highlighted; Dashboard returns to the price cards.

**Cleanup:** none.

### TC-DASH-023 · Tapping the active item returns to its root
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Home tab.

**Steps**
1. Open `All My Tokens` via the `Tokens` action.
2. Tap `Dashboard` in the side nav (web `button "Dashboard"`, macOS `tap-key nav:dashboard`).
3. macOS only: open Fungible Tokens, open a token's detail or `Create`, then `tap-key nav:fungible_tokens` again.

**Expected**
- Dashboard pops back to the dashboard root with the price cards.
- macOS: tapping the active Fungible Tokens (and Operations) item pops back to that section's list.

**Cleanup:** none.

### TC-DASH-024 · Desktop sections that need an account
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** A data folder with no VFX account (see TC-AUTH-043), or all accounts hidden.

**Steps**
1. `tap-key nav:smart_contracts`; screenshot.
2. `tap-key nav:nfts`; screenshot.

**Expected**
- Both show the red toast `An account is required to access this section.` and the active section does not change.

**Cleanup:** Restore hidden accounts if any were hidden.

### TC-DASH-025 · Launch BFLY dialog
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Logged in.

**Steps**
1. Tap `Launch BFLY` (web `button "Launch BFLY"`, macOS `tap-key nav:butterfly`); screenshot.
2. Close the dialog without choosing an option.

**Expected**
- A dialog titled `Launch Butterfly` describes Butterfly (`Butterfly makes sending payments simple…` ending `Auto-login with this account?`) and offers `Just Take Me There` and `Login with this Account`.
- Closing it leaves the current section unchanged. (The login flow itself is out of scope here.)

**Cleanup:** none.

### TC-DASH-026 · Collapse and expand the side nav
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Nav expanded.

**Steps**
1. Tap the expander under the nav. Web: `fltA11y.tap("Collapse navigation")`. macOS: `tap-key nav:expander`. Screenshot.
2. Web: hover a collapsed item; screenshot the tooltip.
3. Tap `Send` in the collapsed nav (web by position from `fltA11y.list()`, macOS `tap-key nav:send`).
4. Tap the expander again (web label `Expand navigation`, macOS `nav:expander`).

**Expected**
- Collapsed, the nav shrinks to icons only, the `Verified` `X` / `Switchblade` wordmark fades out, and on web `Select Account` turns into a wallet icon.
- A collapsed item shows its title as a tooltip on hover and still navigates.
- The expander's accessible label switches between `Collapse navigation` and `Expand navigation`; expanding restores the labels and wordmark.

**Cleanup:** Leave the nav expanded.

### TC-DASH-027 · Web mobile layout and drawer
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. Resize the browser window to 400 × 800 (Claude in Chrome `resize_window`); screenshot.
2. Tap the VFX balance row (`fltA11y.tap("VFX")` on the row showing `<n> VFX`); screenshot; tap outside it.
3. Tap `button "Open menu"`; screenshot the drawer.
4. Tap `Send` in the drawer; screenshot.
5. Open the drawer again, tap `Dashboard`.
6. Resize back to at least 1260 px wide.

**Expected**
- The mobile Home shows an app bar titled `Dashboard` with a menu button (tooltip `Open menu`), the cube and wordmark, two rows `<n> VFX` and `<n> BTC`, `Coin Prices` with compact VFX and BTC price rows, and the action row without `Sign Out`.
- Tapping the VFX row slides the full VFX card in from the top; tapping outside hides it.
- The drawer shows the `Verified` `X` wordmark and the same items as TC-DASH-019, including `Sign Out`.
- Choosing an item closes the drawer and opens the section.
- Back at full width the side nav layout returns.

**Cleanup:** Window at full width.

## Status bar and sync (desktop)

### TC-DASH-028 · Block tab and status indicators
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** CLI started and synced.

**Steps**
1. Screenshot the bottom-right corner.
2. `tap-label "VFX Online"`, `tap-label "BTC Online"`, `tap-label Synced` (each exits 0 when that indicator is present).
3. Compare the height in the tab with Operations → `Status` → `Block Height`.

**Expected**
- The tab reads `Block <height>` followed by three indicators: CLI status (green, tooltip `VFX Online`), BTC/Electrum status (green, `BTC Online`) and sync (green dot, `Synced`).
- Other states: CLI `VFX CLI Loading` (amber), `VFX CLI Offline` or `CLI Inactive` (red); BTC `BTC Loading`, `BTC Offline`, `BTC Inactive`; sync shows an animated bar with `Syncing...` (gold), `Resyncing...` or `Loading...` (red).
- The tab height matches the Status panel.
- (Hovering the tab by hand slides up the latest-block card; `drive.dart` cannot hover.)

**Cleanup:** none.

### TC-DASH-029 · Sync indicator on a syncing chain
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Fresh data folder, booted, snapshot declined.

**Steps**
1. `tap-label "Syncing..."` right after boot; screenshot.
2. Every 5 minutes screenshot the tab and run `tap-label Synced` until it succeeds (up to the time the testnet sync takes).

**Expected**
- While behind the tip the indicator is a gold animated bar with tooltip `Syncing...` and the block number climbs.
- When caught up it becomes a green dot with tooltip `Synced`.

**Cleanup:** none.

### TC-DASH-030 · Operations status panel
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** CLI started.

**Steps**
1. `tap-key nav:operations`, `wait-for-text Status`, screenshot.

**Expected**
- The `Status` card lists `Blockchain Version`, `CLI Version` (same as the boot log), `Block Height`, `Peers (In / Out)` as `<n> / 10`, `Wallet Started` as `MM/dd - HH:mm` of this launch, and `Network Metrics` with a `View Metrics` link.
- Under it are Discord (tooltip `Join Discord`) and GitHub (tooltip `GitHub`) buttons, a `Docs` link, and the version text (TC-DASH-040).

**Cleanup:** none.

### TC-DASH-031 · Network metrics dialog
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Operations open, `Network Metrics` visible.

**Steps**
1. `tap-text "View Metrics"`; screenshot; `tap-text Close`.

**Expected**
- A dialog `Network Metrics` lists block difference average, last block received time, last block delay, time since last block, blocks averaged and `Active Validators: <n>`, then `Close`.

**Cleanup:** none.

## Log panel and folders (desktop)

### TC-DASH-032 · Activity Log and Print Addresses
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Accounts A and B, a BTC account optional.

**Steps**
1. Operations → `General` → `tap-text "Print Addresses"`; screenshot the `Activity Log`.
2. Tap the copy button on account A's line (manual tap: the `Copy` label repeats on every line); read the clipboard.

**Expected**
- The log appends `Wallet Addresses:` then one line per VFX account `<address> (<balance> VFX)` (Vault accounts as `<address> (Available: <n> VFX)`) and per BTC account `<address> (<balance> BTC)`, scrolling to the newest line.
- Copy shows `<address> copied to clipboard` and copies that address.
- Log lines stay in English whatever the app language.

**Cleanup:** Clear the clipboard.

### TC-DASH-033 · Open Log
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** CLI started (automation build).

**Steps**
1. Operations → `Diagnose` → `tap-text "Open Log"`.
2. In a shell, check the front application and the opened file (for example `osascript -e 'tell application "System Events" to get name of first process whose frontmost is true'`).

**Expected**
- The CLI log `rbxlog.txt` from `DatabasesTestNet` opens in the default text app; on an automation build it is the one under `~/Library/Application Support/vfx-gui-automation/rbxtest/`.

**Cleanup:** Close the text app.

**Open question:** confirm Open Log follows the automation data folder (it builds its path through `DataHome.fromDocuments`), so it never opens the real `~/rbxtest` log.

### TC-DASH-034 · Open DB Folder
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** CLI started.

**Steps**
1. Operations → `General` (or `Diagnose`) → `tap-text "Open DB Folder"`.
2. Check the frontmost Finder window's path.

**Expected**
- Finder opens the CLI database folder (`DatabasesTestNet` under the automation folder on an automation build).

**Cleanup:** Close the Finder window.

### TC-DASH-035 · Show Debug Data and Mempool
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no · Mainnet smoke

**Preconditions:** CLI started.

**Steps**
1. Operations → `Diagnose` → `tap-text "Show Debug Data"`; screenshot; `tap-text Copy`; close with the back arrow (`tap-label Back`).
2. `tap-text Mempool`; screenshot; close the sheet.

**Expected**
- A dialog `Debug Data` shows the CLI's debug text; Copy shows `Debug data copied to clipboard`.
- The `Mempool` sheet shows the pending transactions or `Mempool is empty.`

**Cleanup:** Clear the clipboard.

## Settings, language, version and updates

### TC-DASH-036 · CLI Configuration screen
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Dashboard.

**Steps**
1. Look for an entry point to the CLI configuration on Dashboard, Operations (all sections) and the account panel.
2. If one exists, open it and screenshot.

**Expected**
- A screen titled `CLI Configuration` opens with `Open Config`, `View Docs`, an advanced-settings warning and `Save`; saving shows the restart-required toast.

**Cleanup:** none.

**Open question:** in the current code the only link to this screen is in the `Footer` widget, which no screen uses, so the configuration screen appears unreachable. Confirm whether it should be reachable (and from where) or retired; until then record this case as `blocked`.

### TC-DASH-037 · Switch the desktop language to Spanish and back
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Language set to `System default` or `English`.

**Steps**
1. Operations → `General` → `tap-text Language`; screenshot.
2. `tap-text Español`; screenshot Operations and the side nav.
3. `tap-key nav:dashboard`; screenshot.
4. Operations → `General` → `tap-text Idioma` → `tap-text English`.

**Expected**
- The dialog `Language` offers `System default`, `English` and `Español` (current choice marked) and `Close`.
- After choosing Español, without a restart: nav items read `Panel`, `Enviar`, `Recibir`, `Transacciones`, `Operaciones`; Operations shows `Registro de actividad`, `Estado` and the section `Diagnóstico`; the dashboard shows `Ver gráfico`, `Última TX:` and `Ver todas las Txs`. The expanded nav widens so no Spanish label is cut off.
- Existing Activity Log lines stay in English.
- Choosing English restores the English strings.

**Cleanup:** Language back to English.

### TC-DASH-038 · Switch the web language to Spanish and back
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Logged in.

**Steps**
1. Open `Select Account`; screenshot the `Language` row.
2. Click `Language`; screenshot the sheet; click `Español`.
3. `read_page` the nav and Home; screenshot.
4. Open `Seleccionar cuenta` → `Idioma` → `English`.

**Expected**
- The menu row reads `Language` with `Auto`, `EN` or `ES` on the right.
- The sheet `Language` lists `System default`, `English`, `Español` with a check on the current choice.
- In Spanish: `Seleccionar cuenta`, nav `Panel`, `Enviar`, `Recibir`, `Transacciones`, `Cerrar sesión`, and `Ver gráfico` on the price cards; the menu row shows `Idioma` / `ES` and `Bloquear billetera`.
- English restores the English strings.

**Cleanup:** Language back to English.

### TC-DASH-039 · The language choice persists
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Language set to Español (TC-DASH-037 step 2 or TC-DASH-038 step 2).

**Steps**
1. Web: reload with `?automation=1`; screenshot the auth screen; unlock; screenshot Home.
2. macOS: quit and restart the app; screenshot the boot screen and the dashboard.
3. Choose `System default`, then reload or restart again.

**Expected**
- Web: the auth screen shows `Iniciar sesión / Crear cuenta` or the Spanish unlock texts, and Home stays in Spanish.
- macOS: the dashboard and nav stay in Spanish after the restart.
- `System default` follows the OS or browser language after the next load (English on an English system).

**Cleanup:** Language back to English.

### TC-DASH-040 · Version display
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Build version recorded for the run.

**Steps**
1. Web: sign out or open a fresh profile and read the landing screen subtitle.
2. macOS: read the boot screen line (TC-AUTH-001) and Operations' version text under `Status`.

**Expected**
- Web: `Web Wallet Testnet <version>` (mainnet `Web Wallet Mainnet <version>`).
- macOS boot: `VFX Wallet [TESTNET] Version Testnet <version> (Switchblade)`.
- macOS Operations: `VFX Wallet [TESTNET]` on one line and `Version Testnet <version> (Switchblade)` on the next.
- `<version>` equals the build under test on every surface.

**Cleanup:** none.

### TC-DASH-041 · GUI update prompt
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** The Spyglass applications endpoint (`/applications/` on the network's data API) reports a GUI version higher than the build under test. Otherwise record `skipped` and note the reported version.

**Steps**
1. Start the app and wait up to 3 minutes after the dashboard for `GUI Update Available`; screenshot.
2. `tap-text No`.
3. Restart, wait for the prompt, `tap-text Update`; screenshot the second dialog; `tap-text Cancel`.

**Expected**
- The first dialog is `GUI Update Available` / `A GUI update is available. Download now?` with `No` and `Update`. No closes it and the snapshot prompt is not shown in that launch.
- The second dialog is `GUI Update` / `The VFX GUI download will be launched in your browser. Once launched, the CLI will be shutdown and your wallet will be closed to ensure a safe update.` with `Cancel` and `Update`. Cancel keeps the app running.
- (Confirming would open the download, stop the CLI and close the window; do not confirm during a run.)

**Cleanup:** none.

### TC-DASH-042 · CLI update prompt
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** The CLI reports an available update and no GUI update is pending. Otherwise record `skipped`.

**Steps**
1. Start the app and wait up to 3 minutes after the dashboard for `CLI Update Available`; screenshot; `tap-text No`.
2. On a disposable run, restart, accept with `Update`, and when `CLI Updated` appears choose `Restart`.

**Expected**
- `CLI Update Available` / `A CLI update is available. Download and install now?` with `No` and `Update`; No closes it.
- After a successful update, `CLI Updated` / `A restart of the CLI is required. Restart Now?` with `No` and `Restart`; Restart runs the restart sequence from TC-AUTH-007 and the Status panel's `CLI Version` changes.

**Cleanup:** none.

**Open question:** there is no documented way to stage a pending CLI update on testnet; confirm how to exercise the accept path.
