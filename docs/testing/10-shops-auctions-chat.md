# 10 · Shops, auctions and chat (SHOP)

Two shop systems are live, and which one you get depends on the platform. On the **web wallet**, the P2P Auctions tab (`#/dashboard/p2p/...`, `lib/features/web_shop`) is the only shop system. These are web-hosted shops that live in the Spyglass API, and the code calls them "third-party" shops (`is_third_party`). On web you can create, edit, publish, import and delete a shop, manage collections, create, edit and delete listings, buy now, bid, share links, open auction details and bid history, and chat. On web the seller also signs the Sale Start transaction on the `#/dashboard/sign-tx/build-sale-start/:scId/:bidId/:ownerAddress` screen, and the buyer can finish a sale with "Complete Sale" on the web transaction list. On **macOS**, P2P Auctions opens the desktop landing. "Manage my Auction House" opens the decentralized shop (DST, `lib/features/dst`), which the local Core CLI hosts and publishes on chain: create and publish the shop, set it online or offline, and manage collections, listings and auction activity, plus seller chat. "Connect to Auction House" opens the same Spyglass "Auction Houses" list the web uses. From there, a desktop-hosted shop opens as a **remote shop** over the CLI's P2P connection (`lib/features/remote_shop`: connect by URL, browse, buy now, bid, auction details, bid history, shop chat). A web-hosted shop opens in the web shop screens inside the desktop app, where the buyer can browse, buy, bid and chat. Creating or editing web shops and listings is disabled on desktop because the buttons are gated to `Env.isWeb`. Chat (`lib/features/chat`) works across both platforms: web buyer and seller threads go through Spyglass, desktop-hosted shop threads go through the CLI, and a desktop seller's thread list also shows the web threads for their DST shop. Several routes are **not live**: the store routes `/s/:slug` and `store/collection/:slug` are commented out in `lib/core/web_router.dart`, the `Debug*` web-shop routes are commented out in `lib/core/app_router.dart`, and no navigation reaches `RemoteShopListScreen` (which holds the `remote_shop:connect` and `remote_shop:connect_empty` keys) or `BuyerChatThreadListScreen`. These are listed under "Not live / excluded" at the end and have no cases.

## Area preconditions

- **Run id.** Every object this file creates carries the run id. Web shop: name `qa-<run-id> web shop`, identifier `qa-<run-id>-web`. DST shop: name `qa-<run-id> dst shop`, identifier `qa-<run-id>-dst`. Collections: `qa-<run-id> collection` (web) and `qa-<run-id> dst collection` (DST). Chat messages start with `qa-<run-id>`.
- **Accounts.** Account A (`TEST_VFX_A_PRIVKEY`, `TEST_VFX_A_ADDRESS`) is the seller and needs at least 60 testnet VFX free for shop fees: 10 per publish, 1 per update, 1 per delete. Account B (`TEST_VFX_B_PRIVKEY`, `TEST_VFX_B_ADDRESS`) is the buyer and needs at least 20 testnet VFX. Top B up from A with `03-send-receive-transactions.md` or with the faucet case in `12-bridge-payments-faucet-keygen.md`.
- **NFTs.** Before this file runs, account A owns five unlisted testnet NFTs with **no royalty**, minted through `09-smart-contracts-nfts.md`. Web shop: `qa-<run-id>-web-buy`, `qa-<run-id>-web-auction` and `qa-<run-id>-web-buy2`. DST: `qa-<run-id>-dst-buy` and `qa-<run-id>-dst-auction`. With no royalty the seller receives the full sale price, so the balance checks below are exact apart from fees.
- **Running two parties.** Preferred for web + web: two Chrome profiles, each with Claude in Chrome connected (`list_connected_browsers`, then `switch_browser`), one signed in as A and one as B. Each tab is opened at `http://localhost:42069/?automation=1` and signed in with "VFX Private Key". Fallback: one tab, signing out and back in as the other account between steps, which works because the web session holds a single key. For web + macOS, run A on the macOS Flutter Driver build and B on web, or the other way round as each case says. Import both A and B into the macOS automation wallet (`01-launch-auth.md`) and switch the current account with the account selector in the app bar. One Mac runs only one Core CLI (port 17292), so a desktop-to-desktop P2P purchase needs a second Mac. Those cases say so.
- **Notification inbox.** When the web wallet asks for an address in "Subscribe for updates?", enter `TEST_WEB_EMAIL`. The seller's Sale Start link arrives at that inbox. Claude has no inbox access, so ask Tyler for the link, which carries the bid id, when a case reaches that step.
- **Chain.** macOS: the chain is synced. The buy and bid actions otherwise stop with "Please wait until your wallet is synced with the network". Web needs no sync.
- **Order.** Run the sections in file order. The web shop, collection and listings are reused by the buyer, sale and chat cases, and the delete cases at the end clean up.
- **Evidence and hooks.** Web hooks name what the page reader shows. When a tile or checkbox label reads as plain text, use `fltA11y.tap("<label>")`. macOS hooks are `tool/drive.dart` commands. For text fields without a key, tap the field's label text, then `type`.

## Entry points and browsing

### TC-SHOP-001 · P2P Auctions landing
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Logged in as account A (web), or account A selected (macOS).

**Steps**
1. Open P2P Auctions. Web: click `button "P2P Auctions"` in the side nav. macOS: `tap-key nav:p2p_auctions`.

**Expected**
- The app bar title reads "P2P Auctions".
- Two cards show: "Connect to Auction House" with "Connect to a remote auction house to trade NFTs.", and "Manage my Auction House". The second card's body reads "Manage your wallet's auction house and trade NFTs." on web and "Manage your account's auction house and trade NFTs." on macOS.
- macOS also shows the account selector in the app bar.

**Cleanup:** none.

### TC-SHOP-002 · Auction Houses list, search, clear and refresh
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** TC-SHOP-001 screen open.

**Steps**
1. Web: click `button "Connect to Auction House"` (or `fltA11y.tap("Connect to Auction House")`). macOS: `tap-text "Connect to Auction House"`.
2. Note the name of one shop in the list. In the search field ("Search for auction house..."), type part of that name. Web: click `textbox "Search for auction house..."` and type. macOS: `tap-text "Search for auction house..."`, then `type <text>`.
3. Replace the text with part of that shop's owner address, then with its identifier without `vfx://`.
4. Clear the search. Web: click `button "Clear"`. macOS: `tap-label Clear`.
5. Refresh the list. Web: click `button "Refresh"`. macOS: `tap-label Refresh`.

**Expected**
- The title reads "Auction Houses". Each row shows the shop name, its `vfx://` URL and the owner address. Published shops carry an "Online" or "Offline" badge.
- Searching by name, identifier or owner address shows only the matching rows. Clearing brings the full list back.
- macOS shows a "Connect to a Shop" button in the app bar. Web does not.
- The back arrow (tooltip "Back") returns to the landing.

**Cleanup:** clear the search.

### TC-SHOP-003 · Browse a public web-hosted shop, collection and listing
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** An online web-hosted shop that the current account does not own, with a live collection that holds at least one listing. On testnet, sign in as B and use A's shop once TC-SHOP-020 has passed. On mainnet, use any public shop.

**Steps**
1. On "Auction Houses", open the shop by clicking its row. Web: click the `button` whose text starts with the shop name. macOS: `tap-text <shop name>`.
2. Open a collection row under "Collections".
3. Switch the listing layout. Web: click `button "Grid view"`, then `button "List view"`. macOS: `tap-label "Grid view"`, then `tap-label "List view"`.
4. In list view, tap a listing row to expand it.
5. In the "Details" table, tap the copy icon next to "Identifier". Web: `fltA11y.tap("Copy")`. macOS: `tap-label Copy`. Take the first match; the row is keyed by position.

**Expected**
- The shop screen shows the shop name as its title, the description, a "Collections" heading, and "Chat" (when signed in), "Share Shop" and Refresh in the app bar. Owner-only buttons ("Delete Shop", "Edit Auction House", "Create Collection") are absent.
- The collection title reads "<shop name> > <collection name>", with "Chat", "Share Collection" and Refresh.
- An expanded listing shows `#<listing number>`, the NFT name, "Share Listing", the preview carousel, "NFT Features:" ("Baseline Asset" when the NFT has none), and a "Details" table with "Identifier", "Minted By", "Minter Address", "Owned by" and "Chain" ("VFX").
- A Buy Now listing shows a "Buy Now" card with "Price: <n> VFX" and a "Buy Now" button. An auction listing shows an "Auction" card with "Floor Price: <n> VFX" or "Highest Bid: <n> VFX", and the buttons "Bid Now", "Bid History" and "Details". An active listing shows a countdown prefixed "Auction Ends" (auction) or "Ends in" (Buy Now only).
- The copy tap shows the toast "Identifier copied to clipboard".
- No "Edit" or "Delete" button appears on the listing.

**Cleanup:** none.

### TC-SHOP-004 · Desktop refuses your own shop and offline shops
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Account A selected. A's web shop from TC-SHOP-009 is published. The list shows at least one shop with an "Offline" badge.

**Steps**
1. Open "Auction Houses" (TC-SHOP-002 step 1).
2. Tap A's shop, whose name ends with " [My Shop]": `tap-text "qa-<run-id> web shop"`.
3. Tap a shop with the "Offline" badge.

**Expected**
- Step 2 shows the toast "This is your own shop." and stays on the list.
- Step 3 shows the toast "Shop is offline." and stays on the list.

**Cleanup:** none.

## Web shops (seller A on web)

### TC-SHOP-005 · My Auction Houses list and setup entry points
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as A on web. P2P Auctions landing open.

**Steps**
1. Click `button "Manage my Auction House"` (or `fltA11y.tap("Manage my Auction House")`).
2. Click `button "Refresh"`.

**Expected**
- The title reads "My Auction Houses", with a search field ("Search for auction house..."), a search button (tooltip "Search") and Refresh.
- With no shop yet, the body reads "First, setup your auction house / gallery." and "Then you'll be able to create collections and add listings to them.", followed by "Setup Auction House", "or" and "Import Shop".
- The bottom bar always shows "Setup Auction House" and "Import Shop".

**Cleanup:** none.

### TC-SHOP-006 · Create web shop form validation
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SHOP-005 screen open.

**Steps**
1. Click `button "Setup Auction House"`.
2. With every field empty, click `button "Create"`.
3. Click `textbox "Shop Identifier"` and type `1abc`.
4. Type 70 letters into "Shop Identifier".

**Expected**
- The screen title reads "Create Auction House". The fields are "Shop Name", "Shop Description" and "Shop Identifier", and the identifier field shows the prefix `vfx://` and the hint "MyNewShop".
- Step 2 shows the field errors "Shop Name is required.", "Shop Description is required." and "Shop Identifier is required.", and the screen stays open.
- Step 3 leaves the identifier empty, because an identifier must start with a letter.
- Step 4 stops at 62 characters.

**Cleanup:** clear the fields and stay on the form for TC-SHOP-007.

### TC-SHOP-007 · Duplicate shop identifier is rejected
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** "Create Auction House" form open. The identifier of an existing shop from "Auction Houses", without `vfx://`, is known.

**Steps**
1. Type `qa-<run-id> dup` into "Shop Name" and `dup` into "Shop Description".
2. Type the existing identifier into "Shop Identifier".
3. Click `button "Create"`.

**Expected**
- The toast "Shop URL is not available." appears, the form stays open with its values, and no transaction is sent.

**Cleanup:** leave the form for TC-SHOP-008.

### TC-SHOP-008 · Discard shop creation
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** "Create Auction House" form open with some text entered.

**Steps**
1. Click `button "Discard Changes"`, then `button "Cancel"` in the dialog.
2. Click the close icon (`button "Close"`), then `button "Continue"`.

**Expected**
- Both actions open a dialog titled "Are you sure you want to close the shop creation screen?" with the body "All unsaved changes will be lost.".
- Cancel keeps the form and its values. Continue closes it and returns to "My Auction Houses".
- Reopening "Setup Auction House" shows an empty form.

**Cleanup:** none.

### TC-SHOP-009 · Create and publish a web shop
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Logged in as A on web with at least 20 VFX. No shop named `qa-<run-id> web shop` exists. Note A's balance.

**Steps**
1. On "My Auction Houses", click `button "Setup Auction House"`.
2. Type `qa-<run-id> web shop` into `textbox "Shop Name"`, `Release test shop <run-id>` into `textbox "Shop Description"`, and `qa-<run-id>-web` into `textbox "Shop Identifier"`.
3. Click `button "Create"`.
4. If "Subscribe for updates?" appears ("In order for the web wallet to provide notifications about bids/purchases for you to sign the transactions, an email address is required."), type `TEST_WEB_EMAIL` into `textbox "Email Address"` and click `button "Submit"`.
5. In the "Publish Shop?" dialog, click `button "Publish"`.
6. Open Transactions and wait up to 2 minutes for the shop transaction (to `DecShop_Base`, 10 VFX) to read Success.
7. Open "Auction Houses" and refresh every 30 seconds, for up to 5 minutes, until the shop appears.

**Expected**
- Step 4 shows the toast "Subscribed".
- The dialog in step 5 reads "There is a cost of 10.0 VFX to publish your shop to the network (plus the transaction fee).".
- After publishing, the toast "Shop Publish transaction broadcasted to the network" appears and the shop screen opens: title `qa-<run-id> web shop`, the description, "Collections", a "Published" badge, the empty hint "Now you can create collections and then add listings to them." with "Create Collection", and a bottom bar with "Delete Shop", "Edit Auction House" and "Create Collection".
- The transaction confirms within 2 minutes, and A's balance falls by 10 VFX plus the fee.
- On "Auction Houses" the shop reads `qa-<run-id> web shop [My Shop]` with an "Online" badge. On "My Auction Houses" it appears with the same badge.

**Open question:** the published payload (`WebShop.txPayload`) always sends `ThirdPartyBaseURL` `https://wallet.verifiedx.io` and `ThirdPartyAPIURL` `https://data.verifiedx.io/api` (`Env.shopBaseUrl`/`shopApiUrl`), even on testnet. Is that intended?

**Cleanup:** keep the shop. TC-SHOP-071 deletes it.

### TC-SHOP-010 · Open your own shop from My Auction Houses
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SHOP-009 passed.

**Steps**
1. Open "My Auction Houses" and click the row for `qa-<run-id> web shop`.

**Expected**
- The shop screen opens with the owner controls from TC-SHOP-009. Opening the row signs a web auth token for A in the background.
- If signing fails, the toast "Not Authorized" appears and the shop does not open. Record this as a failure.

**Cleanup:** none.

### TC-SHOP-011 · Edit a web shop and publish the update
**Platforms:** Web · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** On A's shop screen. Note A's balance.

**Steps**
1. Click `button "Edit Auction House"`.
2. Append ` edited` to "Shop Description".
3. Click `button "Save Changes"`, then `button "Cancel"` in the dialog.
4. Click `button "Save Changes"` again, then `button "Update"`.
5. On the shop screen, click `button "Refresh"`. Wait up to 2 minutes for the update transaction to read Success in Transactions.

**Expected**
- The title reads "Edit Auction House", and there is no "Shop Identifier" field.
- The dialog is titled "Update Shop?" and reads "There is a cost of 1.0 VFX to update your shop on the network (plus the transaction fee).".
- After Cancel, the form stays open and nothing is sent.
- After Update, the toast "Shop Update transaction broadcasted to the network" appears and the form closes. The shop description ends with "edited".
- A's balance falls by 1 VFX plus the fee once the transaction confirms.

**Cleanup:** none.

### TC-SHOP-012 · Share Shop link
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On any shop screen.

**Steps**
1. Click `button "Share Shop"`.
2. Read the clipboard (`javascript_tool`: `await navigator.clipboard.readText()`).
3. Open `http://localhost:42069/?automation=1#dashboard/p2p/shop/<id>` using the id from the copied link.

**Expected**
- The toast "Share url copied to clipboard" appears.
- On a testnet build, the clipboard holds `https://wallet-testnet.verifiedx.io//#dashboard/p2p/shop/<id>`. The double slash comes from `Env.appBaseUrl` ending in `/`. Log it as a P2 cosmetic issue if the link still opens.
- Step 3 opens the same shop.

**Cleanup:** none.

### TC-SHOP-013 · Import Shop rejects unknown and foreign shops
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Logged in as A on "My Auction Houses". The identifier of a shop owned by another address is known.

**Steps**
1. Click `button "Import Shop"`. Type `qa-<run-id>-missing` into the field and click `button "Submit"`.
2. Click `button "Import Shop"` again, enter the foreign shop's identifier, and click `button "Submit"`.
3. Click `button "Import Shop"`, then `button "Cancel"`.

**Expected**
- The prompt is titled "Shop URL" and reads "What is the shop URL you'd like to import?". The field shows the prefix `vfx://`.
- Step 1 shows the toast "Shop Not Found".
- Step 2 shows the toast "You are not the owner of this shop. Please login as <owner address>".
- Step 3 closes without a request, and no "Ready to Import" dialog ever appears.

**Cleanup:** none.

## Web collections

### TC-SHOP-014 · Collection form validation
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On A's shop screen.

**Steps**
1. Click `button "Create Collection"`.
2. Leave both fields empty and click `button "Create"`.
3. Type 70 characters into `textbox "Collection Name"`.
4. Paste 201 short words (for example `a ` repeated) into `textbox "Collection Description"` and click `button "Create"`.

**Expected**
- The title reads "Create New Collection". The fields are "Collection Name" and "Collection Description", with a "Publish Live" checkbox.
- Step 2 shows "The name is required" and "The description is required".
- Step 3 stops at 64 characters.
- Step 4 shows "The description exceeds the maximum word count".

**Cleanup:** stay on the form for TC-SHOP-015 and clear it.

### TC-SHOP-015 · Create a live collection
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** "Create New Collection" form open for A's shop.

**Steps**
1. Type `qa-<run-id> collection` into "Collection Name" and `Release test collection <run-id>` into "Collection Description".
2. Tick "Publish Live" with `fltA11y.tap("Publish Live")`.
3. Click `button "Create"`.
4. Go back to the shop (`button "Back"`).

**Expected**
- The toast "Collection Created" appears, and the collection screen opens titled `qa-<run-id> web shop > qa-<run-id> collection`.
- The owner bar shows "Delete Collection", "Edit Collection" and "Create Listing". There is no "Chat" button.
- Back on the shop, the collection row shows its name and description.

**Open question:** the web client does not filter on the collection's live flag. Does Spyglass hide a collection saved without "Publish Live" from buyers?

**Cleanup:** keep it. TC-SHOP-070 deletes it.

### TC-SHOP-016 · Edit a collection
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On the collection from TC-SHOP-015, as A.

**Steps**
1. Click `button "Edit Collection"`.
2. Append ` edited` to "Collection Description" and click `button "Save"`.

**Expected**
- The title reads "Edit Collection", with the current values filled in.
- The toast "Collection Updated!" appears and the form closes. After Refresh, the collection header text ends with "edited".

**Cleanup:** none.

### TC-SHOP-017 · Discard collection edits
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** On A's shop screen.

**Steps**
1. Click `button "Create Collection"`, type any name, then click `button "Discard Changes"` and `button "Cancel"`.
2. Click `button "Discard Changes"` and `button "Continue"`.
3. Open "Create Collection" again, click the close icon (`button "Close"`), then `button "Continue"`.

**Expected**
- "Discard Changes" asks "Are you sure you want to close the collection creation screen?" with "All unsaved changes will be lost.". Cancel keeps the form, and Continue closes it.
- The close icon asks "Are you sure you want to close the store creation screen?". The different wording is current behavior; log it as P2 copy.

**Cleanup:** none.

### TC-SHOP-018 · Share Collection link
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On any collection screen.

**Steps**
1. Click `button "Share Collection"` and read the clipboard.

**Expected**
- The toast "Share url copied to clipboard" appears. The clipboard ends with `#dashboard/p2p/shop/<shopId>/collection/<collectionId>`, and opening that path locally with `?automation=1` shows the same collection.

**Cleanup:** none.

## Web listings

### TC-SHOP-019 · Listing form validation
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As A, on the collection from TC-SHOP-015.

**Steps**
1. Click `button "Create Listing"`, then click `button "Save"` straight away.
2. Click `button "Select NFT"`, pick `qa-<run-id>-web-buy` in the "Select NFT" sheet, then click `button "Save"`.
3. Tick "Enable Buy Now?" (`fltA11y.tap("Enable Buy Now?")`), leave "Buy Now Price" empty, and click `button "Save"`.
4. Untick "Enable Buy Now?". Tick "Enable Auction?", leave "Floor Price" empty, and click `button "Save"`.
5. Type `5` into "Floor Price". Tick "Add Reserve Price", type `2` into "Reserve Price", and click `button "Save"`.
6. Type letters into "Floor Price".
7. Click the close icon (`button "Close"`), then `button "Continue"`.

**Expected**
- Step 1 shows the toast "The NFT must be set".
- After step 2 the form shows "NFT: qa-<run-id>-web-buy", and Save shows the toast "Enable at least one of the options (Gallery, Buy Now, or Auction)".
- Step 3 shows the field error "Buy Now is required.".
- Step 4 shows "Floor Price is required.". Ticking "Enable Auction?" reveals "Floor Price", "Add Reserve Price", "Start Date", "Start Time", "End Date" and "End Time". The date and time buttons have the tooltips "Pick a date" and "Pick a time".
- Step 5 shows the toast "The reserve price must be greater or equal to the floor price.".
- Step 6 enters nothing, because only digits and `.` are accepted.
- Step 7 asks "Are you sure you want to close the listing creation screen?" and closes without saving.

**Cleanup:** none.

### TC-SHOP-020 · Create a Buy Now listing
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** As A, on the collection from TC-SHOP-015. `qa-<run-id>-web-buy` is not listed.

**Steps**
1. Click `button "Create Listing"`, then `button "Select NFT"`, and pick `qa-<run-id>-web-buy`.
2. Tick "Enable Buy Now?" and type `2` into `textbox "Buy Now Price"`.
3. Click `button "Save"`.
4. On the collection, click `button "Refresh"` and expand the listing.

**Expected**
- The form closes back to the collection, and the listing appears with the NFT name.
- Expanded, it shows `#<n>`, the NFT name, "Share Listing", "Edit" and "Delete", a "Buy Now" card with "Price: 2.0 VFX", and a countdown prefixed "Ends in", which runs about 7 days.
- "Owned by" in "Details" shows A's address.

**Cleanup:** keep it for TC-SHOP-028.

### TC-SHOP-021 · An already-listed NFT cannot be listed twice
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** TC-SHOP-020 passed.

**Steps**
1. Click `button "Create Listing"`, then `button "Select NFT"`.
2. Pick `qa-<run-id>-web-buy`.

**Expected**
- In the sheet, the NFT's title ends with "(Listed)".
- Picking it shows the toast "This NFT is already listed. Please choose another", and the form still has no NFT.

**Cleanup:** close the form with Continue.

### TC-SHOP-022 · Create an auction listing with a reserve
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As A, on the collection from TC-SHOP-015.

**Steps**
1. Click `button "Create Listing"` and select `qa-<run-id>-web-auction`.
2. Tick "Enable Auction?", type `1` into "Floor Price", tick "Add Reserve Price" and type `2` into "Reserve Price".
3. Click "Pick a date" next to "End Date", choose tomorrow and confirm. Then click "Pick a time" next to "End Time", enter `00:30` and confirm.
4. Click `button "Save"`, then refresh the collection and expand the listing.

**Expected**
- The listing shows an "Auction" card with "Floor Price: 1.0 VFX" and the buttons "Bid Now", "Bid History" and "Details", plus a countdown prefixed "Auction Ends" that runs to tomorrow 00:30.
- Picking today as the end date instead shows "End date must be after the start date" as an overlay toast, because the date picker returns midnight.

**Open question:** the web form cannot end an auction on the day it was created, since the date picker returns midnight and an end date before the start is rejected. The auction settlement case therefore spans two days. Is that intended?

**Cleanup:** keep it for TC-SHOP-031 to TC-SHOP-034.

### TC-SHOP-023 · The owner cannot buy or bid on their own listing
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As A, on the collection with the listings from TC-SHOP-020 and TC-SHOP-022.

**Steps**
1. Click `button "Buy Now"` on the Buy Now listing.
2. Click `button "Bid Now"` on the auction listing.

**Expected**
- Both show the toast "You are the owner of this shop.", and no dialog opens.

**Cleanup:** none.

### TC-SHOP-024 · Edit a listing, and pricing locks once the auction starts
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As A, on the collection with both listings.

**Steps**
1. On the Buy Now listing, click `button "Edit"`.
2. Change "Buy Now Price" to `1` and click `button "Save"`. Refresh the collection.
3. On the auction listing, click `button "Edit"`, then tick or untick "Enable Auction?".
4. Close the form with Continue.

**Expected**
- The title reads "Edit Listing". The NFT is shown and the "Select NFT" button is disabled.
- After step 2, the listing shows "Price: 1.0 VFX".
- On the running auction, the form shows "Auction has started so the dates & times can't be updated." and "Auction has started so the pricing can't be updated.". The price fields are read-only, and step 3 shows the toast "The auction has already started.".

**Cleanup:** none.

### TC-SHOP-025 · Share Listing link
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Any expanded listing.

**Steps**
1. Click `button "Share Listing"` and read the clipboard.
2. Open `http://localhost:42069/?automation=1#dashboard/p2p/shop/<shopId>/collection/<collectionId>/listing/<listingId>` using the ids from the link.

**Expected**
- The toast "Share url copied to clipboard" appears. The clipboard ends with `#dashboard/p2p/shop/<shopId>/collection/<collectionId>/listing/<listingId>`.
- Step 2 opens the listing page titled "<shop> > <collection> > <NFT name>", with the same details. A missing id shows "Error".

**Cleanup:** none.

## Buying and bidding on web shops (buyer B)

### TC-SHOP-026 · Buyer sees the seller's shop and listings
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** A second party is signed in as B (see Area preconditions). TC-SHOP-020 and TC-SHOP-022 passed.

**Steps**
1. As B, open "Auction Houses", search `qa-<run-id>`, and open `qa-<run-id> web shop`.
2. Open `qa-<run-id> collection` and expand both listings.

**Expected**
- The row shows no " [My Shop]" suffix, and the badge reads "Online".
- The shop and collection screens show "Chat" and "Share", and have no owner buttons.
- The Buy Now listing shows "Price: 1.0 VFX" and the auction shows "Floor Price: 1.0 VFX". Neither shows "Edit" or "Delete".

**Cleanup:** none.

### TC-SHOP-027 · Buy Now with insufficient balance
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SHOP-026 passed. Note B's balance.

**Steps**
1. As A, edit the Buy Now listing and set "Buy Now Price" to B's balance plus 100. Save.
2. As B, refresh the collection and click `button "Buy Now"` on that listing.
3. As A, set the price back to `1` and save.

**Expected**
- Step 2 shows the toast "Not enough balance.", and no confirmation dialog or on-ramp dialog opens.
- After step 3, B sees "Price: 1.0 VFX" after a refresh.

**Cleanup:** the price is back at 1 VFX.

### TC-SHOP-028 · Buy Now end to end with sale completion
**Platforms:** Web · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** TC-SHOP-027 passed, and the listing is at 1 VFX. B has at least 5 VFX. Record A's balance, B's balance, and the "Owned by" value (A).

**Steps**
1. As B, click `button "Buy Now"` on the `qa-<run-id>-web-buy` listing.
2. In the "Buy Now" dialog, click `button "Buy Now"`.
3. Close the info dialog. Click `button "Bid History"`. If the listing no longer shows its buttons, reopen it with the share link from TC-SHOP-025.
4. Get the Sale Start link for this bid (see Area preconditions). As A, open it on the local build: keep the hash path `#/dashboard/sign-tx/build-sale-start/<scId>/<bidId>/<A address>`, with `http://localhost:42069/?automation=1` in front.
5. Click `button "Start Transaction"`.
6. Wait up to 2 minutes for the Sale Start transaction to read Success in A's Transactions, and for it to appear in B's Transactions.
7. Wait up to 5 more minutes for the sale to complete, refreshing B's NFTs and the listing every 30 seconds. If it has not completed, click `button "Complete Sale"` on the Sale Start transaction in B's Transactions. Then wait up to 2 minutes, and record which path completed the sale.

**Expected**
- Step 2's dialog reads "Are you sure you want to buy now for 1.0 VFX?".
- Step 2 then shows the toast "Buy Now TX broadcasted. Please wait for it to be accepted by the shop owner", and a dialog titled "Buy Now TX broadcasted.". Its body is "Please wait for the transaction to be finalized.", followed by "Because this auction house is hosted on the VFX Web Wallet, the seller will need to authorize the Sale Start transaction. You will see that in your transaction list once it's been sent.".
- Step 3 lists B's 1.0 VFX bid under "Current Bids" with B's address and a status badge ("Sent" or "Received", later "Purchased" with "[Buy Now]").
- Step 4 shows the "Send Sale Start TX" screen with "Please approve the Sale Start TX for your shop purchase.", "Smart Contract ID: <scId>", "Buyer: <B address>" and "Amount: 1.0".
- Step 5 shows the node's verification message, then the toast "TX Broadcasted". The card then reads "Transaction Sent.".
- When the sale completes, `qa-<run-id>-web-buy` is in B's NFTs and no longer in A's. "Owned by" shows B's address, and the listing reads "Sale has Completed" or has left the active list.
- A's balance rises by 1.0 VFX, less the Sale Start fee. B's balance falls by 1.0 VFX plus fees.

**Open question:** who broadcasts the buyer's pre-signed Sale Complete transaction that is sent with the bid: Spyglass on its own once Sale Start lands, or only B through "Complete Sale"? How does the seller get the Sale Start link (and the bid id) without reading the notification email? The screen is not reachable from any navigation.

**Cleanup:** none. The NFT now belongs to B.

### TC-SHOP-029 · Sale Start screen guards
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** The Sale Start link from TC-SHOP-028 is known.

**Steps**
1. As B, open the link.
2. Click `button "Sign In"`, choose "VFX Private Key", and submit `TEST_VFX_B_PRIVKEY`.
3. As A, open the same link with the bid id replaced by `999999999`.

**Expected**
- Step 1 shows "To authorize this transaction, you must sign in as", A's address, and "Sign In". The "Start Transaction" button does not appear.
- Step 2 shows the toast "Incorrect login details for <A address>.", and the screen still asks for A.
- Step 3 shows "Error: Bid not found.".

**Cleanup:** sign back in as the party each later case expects.

### TC-SHOP-030 · Complete Sale after the NFT has already moved
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** TC-SHOP-028 passed. As B.

**Steps**
1. In B's Transactions, find the Sale Start transaction for `qa-<run-id>-web-buy` and click `button "Complete Sale"`.

**Expected**
- The toast "You are already the owner of this NFT." appears, and nothing is sent.

**Cleanup:** none.

### TC-SHOP-031 · Bid History and Auction Details before any bid
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** As B, on the auction listing from TC-SHOP-022, with no bids yet.

**Steps**
1. Click `button "Bid History"`.
2. Click `button "Details"`, then close the dialog.

**Expected**
- Step 1 shows the toast "No bids.".
- Step 2 opens "Auction Details" with "Current Bid Price:" "1.0 VFX", "Increment Amount:" "<n> VFX", "Reserve Met:" "No" and "Active:" "Yes". Note the increment for TC-SHOP-032.

**Cleanup:** none.

### TC-SHOP-032 · Bid validation
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As B, on the auction listing. The increment `<inc>` from TC-SHOP-031 is known, and `<min>` = 1.0 + `<inc>`.

**Steps**
1. Click `button "Bid Now"`. Leave the field empty and click `button "Continue"`.
2. Type `abc` and click `button "Continue"`.
3. Type `1` and click `button "Continue"`.
4. Type `<min>` exactly and click `button "Continue"`.
5. Type `1000000` and click `button "Continue"`.
6. Open the prompt again and click `button "Cancel"`.

**Expected**
- The prompt is titled "Place Bid", with the field "Bid Amount (VFX)" and the footer "Must be greater than <min> VFX".
- Step 1 shows "Bid Amount is required.", and step 2 shows "Invalid Bid Amount.".
- Step 3 shows the toast "Your bid must be greater than the current highest bid (1.0 VFX)".
- Step 4 shows the toast "The minimum increment amount is <inc> VFX. A bid greater than <min> VFX is required.".
- Step 5 shows the toast "Not enough balance.".
- Cancel closes the prompt, and no bid appears in Bid History.

**Cleanup:** none.

### TC-SHOP-033 · Place a bid
**Platforms:** Web · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** As B, on the auction listing. Note B's balance.

**Steps**
1. Click `button "Bid Now"`, type `2.5` (above `<min>` and the 2 VFX reserve), and click `button "Continue"`.
2. In the confirmation, click `button "Place Bid"`.
3. If "Subscribe for updates?" appears, click `button "Cancel"`.
4. Wait up to 1 minute, refreshing the collection, then click `button "Bid History"` and `button "Details"`.

**Expected**
- The confirmation reads "Are you sure you want to place a bid of 2.5 VFX?".
- Step 3 shows the toast "You will not be notified. You can update this setting on the dashboard if you change your mind.". The toast "Bid Submitted" follows.
- The listing shows "Highest Bid: 2.5 VFX". "Current Bids" lists 2.5 VFX with B's address and a status badge.
- "Auction Details" shows "Current Bid Price:" "2.5 VFX", "Reserve Met:" "Yes" and "Active:" "Yes".
- B's balance does not change at this point. The bid only signs a message and a pre-signed Sale Complete transaction.

**Cleanup:** none.

### TC-SHOP-034 · Winning an auction and completing the sale
**Platforms:** Web · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** TC-SHOP-033 passed, and the auction end time (tomorrow 00:30) has passed. Record A's and B's balances.

**Steps**
1. As B, reopen the listing (share link) and confirm that the Bid Now button and the countdown are gone.
2. Get the Sale Start link for B's winning bid. As A, open it locally and click `button "Start Transaction"`.
3. Follow steps 6 and 7 of TC-SHOP-028.

**Expected**
- The Sale Start screen shows "Buyer: <B address>" and "Amount: 2.5".
- `qa-<run-id>-web-auction` moves to B within the waits of TC-SHOP-028. A's balance rises by 2.5 VFX less the Sale Start fee, and B's falls by 2.5 VFX plus fees.
- Bid History shows B's bid as "Accepted".

**Open question:** does Spyglass pick the winning bid and send the seller the Sale Start link automatically when the auction ends? The client has no seller screen for it.

**Cleanup:** none.

## Desktop buyer on a web-hosted shop

### TC-SHOP-035 · Desktop opens a web-hosted shop
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** B is imported into the macOS wallet and selected. A's web shop is online.

**Steps**
1. `tap-key nav:p2p_auctions`, then `tap-text "Connect to Auction House"`.
2. `tap-text "qa-<run-id> web shop"`.
3. Open `qa-<run-id> collection`.

**Expected**
- The shop opens directly in the web shop screens, with no connect dialog. It shows the shop name, description, "Collections", "Chat", "Share Shop" and Refresh (tooltip "Refresh").
- No owner buttons (`web_shop:delete_shop`, `web_shop:edit_shop`, `web_shop:create_collection`) exist, even when A is selected.
- The collection lists the remaining listings with `web_shop:buy_now` / `web_shop:bid_now` controls.

**Cleanup:** none.

### TC-SHOP-036 · Desktop Buy Now on a web-hosted listing
**Platforms:** macOS, Web · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** As A on web, create a Buy Now listing for `qa-<run-id>-web-buy2` at 1 VFX in `qa-<run-id> collection` (TC-SHOP-020 steps). On macOS, B is selected and the chain is synced. Record the balances.

**Steps**
1. macOS: open the collection (TC-SHOP-035), then `tap-key web_shop:buy_now` on the `qa-<run-id>-web-buy2` listing.
2. In the "Buy Now" dialog, `tap-text "Buy Now"` on the dialog button (use `tap-key` if the text matches twice).
3. `tap-key web_shop:bid_history`.
4. As A on web, sign the Sale Start as in TC-SHOP-028 steps 4 and 5.
5. Wait up to 2 minutes for Sale Start, then up to 5 minutes for the NFT to reach B's NFT list on macOS.

**Expected**
- The dialog reads "Are you sure you want to buy now for 1.0 VFX?". While the chain is still syncing, step 1 instead shows "Please wait until your wallet is synced with the network".
- After confirming, the listing refreshes and B's bid appears under "Current Bids".
- The NFT moves to B, A gains 1.0 VFX less the fee, and B loses 1.0 VFX plus fees.

**Open question:** on desktop, the web-shop buy sends the bid to Spyglass without a signature or pre-signed Sale Complete transaction. It then saves a local CLI bid with `bidStatus: success ? Rejected : Accepted`, which looks inverted. Is this path supported, and does the desktop CLI complete the sale on its own?

**Cleanup:** none.

## Desktop decentralized shop (seller A on macOS)

### TC-SHOP-037 · My Auction House empty state
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** A selected and A has no DST shop.

**Steps**
1. `tap-key nav:p2p_auctions`, then `tap-text "Manage my Auction House"`.

**Expected**
- The title reads "My Auction House", with a "Chat" button in the app bar.
- The body reads "First, setup your auction house / gallery." and "Then you'll be able to create collections and add listings to them.", followed by "Setup Auction House", "or" and "Import Shop".

**Cleanup:** none.

### TC-SHOP-038 · Import Shop validation (DST)
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** TC-SHOP-037 screen. The owner address of a shop from "Auction Houses" that is not in this wallet is known.

**Steps**
1. `tap-text "Import Shop"`, leave the field empty, and `tap-text Submit`.
2. `type abc` into "Your VFX Address" and `tap-text Submit`.
3. Enter the foreign owner address and `tap-text Submit`.

**Expected**
- The prompt is titled "Import Shop", with the field "Your VFX Address".
- Step 1 shows "Address required", and step 2 shows "Invalid Address.".
- Step 3 closes the prompt and shows the toast "This is not one of your addresses".

**Cleanup:** none.

### TC-SHOP-039 · Create DST shop form validation, and delete an unpublished shop
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SHOP-037 screen.

**Steps**
1. `tap-text "Setup Auction House"`, then `tap-text Create` with every field empty.
2. Fill "Shop Name" `qa-<run-id> tmp`, "Shop Description" `tmp`, and "Shop Identifier" `qa-<run-id>-tmp`, leave the owner unset, and `tap-text Create`.
3. `tap-text "Owner's Address"`, pick A in "Choose an address", and `tap-text Create`.
4. In "Publish Updates?", `tap-text No`.
5. On "My Auction House", `tap-text "Delete Shop"`, then `tap-text Delete`.

**Expected**
- The form is titled "Create Auction House" and opens with "Create your auction house / gallery and publish it to the network." and "Then you'll be able to create collections and add listings to them.". The owner tile reads "Owner's Address" with "Select an address from the list to be the shop owner.".
- Step 1 shows "Shop Name is required.", "Shop Description is required." and "Shop Identifier is required.". Step 2 shows the toast "Address Required.".
- Step 4 shows the toast "Local changes saved!". "My Auction House" then shows `qa-<run-id> tmp` and "URL: vfx://qa-<run-id>-tmp" with "Edit Details", "Publish Shop" and "Delete Shop", and no "Shop Online" button.
- The delete dialog reads "Are you sure you want to delete your unpublished shop?". Delete shows "Shop Deleted", and the empty state from TC-SHOP-037 returns. No transaction is sent.

**Cleanup:** none.

### TC-SHOP-040 · Create and publish a DST shop
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** A selected with at least 20 VFX, chain synced, no DST shop. Note A's balance.

**Steps**
1. `tap-text "Setup Auction House"`.
2. Fill "Shop Name" `qa-<run-id> dst shop`, "Shop Description" `Release test DST shop <run-id>`, and "Shop Identifier" `qa-<run-id>-dst`. Set "Owner's Address" to A.
3. `tap-text Create`, then `tap-text Yes` in "Publish Updates?".
4. In "CLI Restart Required", `tap-text Restart`. Wait up to 3 minutes for the CLI to come back (status bar connected and synced).
5. Open "Manage my Auction House" and wait up to 5 minutes for the publish button to change from "Pending" to "Published".

**Expected**
- "Publish Updates?" reads "Your local changes were saved successfully. Would you like to publish this to the network?".
- The toast "Publish Transaction Sent!" appears. The restart dialog reads "A CLI restart is required for this change to take effect. Would you like to restart now?", with "Later" and "Restart".
- "My Auction House" shows `qa-<run-id> dst shop`, "URL: vfx://qa-<run-id>-dst", and the buttons "Shop Online", "Edit Details", "Published" and "Delete Shop". The hint reads "Now you can create collections and then add listings to them.", with "Create New Collection".
- A's balance falls by 10 VFX plus the fee within 2 minutes. Within 5 minutes, "Auction Houses" on web (as B) lists the shop as "Online".

**Cleanup:** keep it. TC-SHOP-074 deletes it.

### TC-SHOP-041 · Copy the DST shop URL
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** TC-SHOP-040 passed.

**Steps**
1. `tap-label "Copy shop URL"`, then run `pbpaste`.

**Expected**
- The toast "Shop URL copied to clipboard" appears, and the clipboard holds `vfx://qa-<run-id>-dst`.

**Cleanup:** none.

### TC-SHOP-042 · Set the DST shop offline and back online
**Platforms:** macOS, Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SHOP-040 passed.

**Steps**
1. `tap-text "Shop Online"`, `tap-text Yes`, then `tap-text Restart` in "CLI Restart Required". Wait up to 3 minutes for the CLI.
2. As B on web, refresh "Auction Houses" every 30 seconds for up to 5 minutes.
3. On macOS, `tap-text "Shop Offline"`, `tap-text Yes`, `tap-text Restart`, and wait for the CLI.
4. Repeat step 2.

**Expected**
- Step 1 asks "Set Offline?" with "Are you sure you want to set this store offline?". Afterwards the button reads "Shop Offline", and on web the shop's badge reads "Offline". Opening the shop there shows "Shop is offline.".
- Step 3 asks "Set Online?" with "Are you sure you want to set this store online?". Afterwards the button reads "Shop Online", and on web the badge reads "Online".

**Open question:** does `toggleOnlineOffline` send an on-chain update (and fee), or does it only change the CLI's local state?

**Cleanup:** leave the shop online.

### TC-SHOP-043 · Edit the DST shop and publish the changes
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** TC-SHOP-040 passed. Note A's balance.

**Steps**
1. `tap-text "Edit Details"`, append ` edited` to "Shop Description", and `tap-text "Save Changes"`.
2. In "Publish Updates?", `tap-text No`.
3. On "My Auction House", `tap-text "Publish Changes"`. If a cost dialog opens, `tap-text "Publish Changes"` in it.
4. Wait up to 5 minutes for the button to read "Published".

**Expected**
- The form is titled "Edit Auction House". The owner tile cannot be tapped.
- "Publish Updates?" reads "Your local changes were saved successfully. Would you like to publish this to the network?". If the shop was published within the past 24 hours, it adds "1 VFX is required since you have already published within the past 24 hours.".
- Step 2 shows the toast "Local changes saved!", and the main screen shows "Publish Changes".
- A cost dialog, if shown, is titled "Publish Shop?" and reads "There is a cost of 1.0 VFX to publish your shop changes to the network (plus the transaction fee).".
- The toast "Publish Transaction Sent!" appears, the button reads "Pending", then "Published". Any charge is 1 VFX plus the fee.

**Cleanup:** none.

### TC-SHOP-044 · Create a DST collection
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** TC-SHOP-040 passed, and there are no collections yet.

**Steps**
1. `tap-text "Create New Collection"`, then `tap-text Create` with empty fields.
2. Fill "Collection Name" `qa-<run-id> dst collection` and "Collection Description" `Release test DST collection <run-id>`, and tick "Publish Live" (`tap-text "Publish Live"`).
3. `tap-text Create`.
4. Go back to "My Auction House".

**Expected**
- The form is titled "Create New Collection" and shows "You are creating a new collection in your auction house." and "After creating the new collection you will be able to create listings.". Under "Publish Live" it reads "When this is enabled, this collection will be visible to other users when they connect to your shop".
- Step 1 shows "The name is required" and "The description is required".
- Step 3 opens the collection screen, titled with the collection name, with "Now you can create listings for the NFTs you own." and "Create First Listing". The bar holds "Edit Collection", "Create Listing" and "Delete Collection".
- "My Auction House" lists the collection with a "Live" badge and its switch on.

**Cleanup:** keep it. TC-SHOP-073 deletes it.

### TC-SHOP-045 · Hide and show a DST collection
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SHOP-044 passed.

**Steps**
1. Turn the collection's switch off and `tap-text Hide`.
2. Turn it on and `tap-text "Make Live"`.

**Expected**
- Step 1 asks "Hide Collection?" with "Are you sure you want to hide this collection? It won't be visible to other users when they connect to your shop.". The badge then reads "Hidden".
- Step 2 asks "Make Collection Live?" with "Are you sure you want to make this collection live? This collection will be visible to other users when they connect to your shop.". The badge then reads "Live".

**Cleanup:** leave it live.

### TC-SHOP-046 · Edit a DST collection
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On the collection from TC-SHOP-044.

**Steps**
1. `tap-text "Edit Collection"`, append ` edited` to the description, and `tap-text Save`.

**Expected**
- The form is titled "Edit Collection". After saving, the collection screen shows the new description.

**Cleanup:** none.

### TC-SHOP-047 · DST listing form validation
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On the collection from TC-SHOP-044.

**Steps**
1. `tap-text "Create First Listing"`, then `tap-text Create`.
2. `tap-text "Choose NFT"`, pick `qa-<run-id>-dst-buy` in "Select NFT", and `tap-text Create`.
3. Tick "Enable Buy Now?", leave "Buy Now Price" empty, and `tap-text Create`. Then type `0` and `tap-text Create`.
4. Untick Buy Now. Tick "Enable Auction?", type `5` into "Floor Price", tick "Add Reserve Price", type `2` into "Reserve Price", and `tap-text Create`.
5. Set "Floor Price" to `0` and "Reserve Price" to `1`, and `tap-text Create`.
6. `tap-text "Discard Changes"`, then `tap-text Continue`.

**Expected**
- The screen is titled "Create Listing", with "NFT:" and a "Choose NFT" button.
- Step 1 shows the toast "The NFT must be set".
- Step 2 shows "NFT: qa-<run-id>-dst-buy" with "Replace NFT", and the toast "Enable at least one of the options (Gallery, Buy Now, or Auction)".
- Step 3 shows "Buy Now is required.", then the toast "Price must be greater than zero".
- Step 4 shows the toast "The reserve price must be greater or equal to the floor price.".
- Step 5 shows the toast "The floor price must be greater than zero.".
- Step 6 asks "Are you sure you want to discard the listing?" and closes.

**Cleanup:** none.

### TC-SHOP-048 · Create a DST Buy Now listing
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** On the collection from TC-SHOP-044.

**Steps**
1. `tap-text "Create First Listing"`, choose `qa-<run-id>-dst-buy`, tick "Enable Buy Now?", and type `1` into "Buy Now Price".
2. `tap-text Create`.

**Expected**
- The collection lists the NFT with the subtitle "Buy Now: 1.0 VFX" and the buttons "Delete", "Edit" and "Details".

**Cleanup:** keep it for TC-SHOP-052.

### TC-SHOP-049 · Create a DST auction listing
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On the collection from TC-SHOP-044.

**Steps**
1. `tap-text "Create Listing"`, choose `qa-<run-id>-dst-auction`, and tick "Enable Auction?". Type `1` into "Floor Price", tick "Add Reserve Price", and type `2` into "Reserve Price". Keep the default dates.
2. `tap-text Create`.

**Expected**
- The row subtitle reads "Floor: 1.0 VFX | Reserve: 2.0 VFX", with an extra "Activity" button.

**Cleanup:** TC-SHOP-053 deletes it.

### TC-SHOP-050 · DST listing detail and auction activity
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SHOP-048 and TC-SHOP-049 passed.

**Steps**
1. On the auction row, `tap-text Details`.
2. `tap-text "Auction Activity"`, then `tap-label Refresh`.

**Expected**
- The screen is titled "Listing for qa-<run-id>-dst-auction". Its table has "NFT", "Owner" (A's address), "Dates", "Options" (a check next to "Auction", a cross next to "Buy Now"), "Auction Floor Price" "1.0 VFX" and "Auction Reserve Price" "2.0 VFX". The bottom holds "Edit Listing" and "Delete Listing".
- The activity screen is titled "Auction Activity for qa-<run-id>-dst-auction" and shows "No Bids Yet.".

**Cleanup:** none.

### TC-SHOP-051 · Edit a DST listing
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SHOP-048 passed.

**Steps**
1. On the Buy Now row, `tap-text Edit`, change "Buy Now Price" to `1.5`, and `tap-text Update`.
2. Edit again, set the price back to `1`, and `tap-text Update`.

**Expected**
- The form is titled "Edit Listing", with "Delete Listing" and "Update" buttons.
- The row subtitle reads "Buy Now: 1.5 VFX" after step 1 and "Buy Now: 1.0 VFX" after step 2.

**Cleanup:** none.

### TC-SHOP-052 · Web buyer purchases from the DST shop
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** The DST shop is online, with the 1 VFX listing from TC-SHOP-048. A runs on macOS (CLI up), and B is on web. Record the balances.

**Steps**
1. As B on web, open "Auction Houses", open `qa-<run-id> dst shop`, then `qa-<run-id> dst collection`.
2. Expand the `qa-<run-id>-dst-buy` listing, click `button "Buy Now"`, then click `button "Buy Now"` in the dialog.
3. On macOS as A, open the collection and watch the row. Wait up to 5 minutes for the subtitle to read "Completed" or "Sale Complete TX Failed".
4. If it reads "Sale Complete TX Failed", `tap-text "Complete Sale"`, then wait up to 5 minutes more.

**Expected**
- On web, the DST shop, collection and listing load with the same data as on desktop.
- Step 2 shows "Buy Now TX broadcasted. Please wait for it to be accepted by the shop owner". The dialog body is "Please wait for the transaction to be finalized." only, without the web-hosted note.
- Step 4, if needed, shows the toast "Attempting to send sale complete TX.".
- The NFT moves to B, A gains 1.0 VFX less fees, and B loses 1.0 VFX plus fees. Afterwards, A's row reads "Completed" and has no "Edit" button.

**Open question:** does Spyglass relay a web buyer's bid to a desktop-hosted (CLI) shop, and who broadcasts Sale Complete in that case? If it does not, this case needs a second Mac running the buyer's CLI, using TC-SHOP-057 and TC-SHOP-058.

**Cleanup:** none.

### TC-SHOP-053 · Delete a DST listing
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** The auction listing from TC-SHOP-049 exists and has no bids.

**Steps**
1. On its row, `tap-text Delete`, then `tap-text Cancel`.
2. `tap-text Delete`, then `tap-text Delete` in the dialog.

**Expected**
- The dialog is titled "Delete Listing" and reads "Are you sure you want to delete this listing?". Cancel keeps the row.
- Confirming removes the row. `qa-<run-id>-dst-auction` is no longer marked "(Listed)" in "Choose NFT".

**Cleanup:** none.

## Desktop remote shops (buyer on macOS)

### TC-SHOP-054 · Connect to a Shop by URL validation
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On "Auction Houses".

**Steps**
1. `tap-text "Connect to a Shop"`. Clear the field and `tap-text Submit`.
2. Type `qa-<run-id>-missing` and `tap-text Submit`.

**Expected**
- The prompt is titled "Shop URL", prefilled with `vfx://`, with the label "Input Shop Name Only".
- Step 1 shows "Shop URL required".
- Step 2 closes the prompt and no shop opens.

**Open question:** an unknown URL gives no message, because `WebShopService.lookupShop` returns null silently. Should it show "Shop Not Found"?

**Cleanup:** none.

### TC-SHOP-055 · Connect to a desktop-hosted shop
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** An online desktop-hosted (CLI) shop that the selected account does not own, with a live collection. On testnet, that means another machine's DST shop, or A's DST shop opened while B is on a second Mac. If none exists, mark the case blocked.

**Steps**
1. On "Auction Houses", tap the shop, or use "Connect to a Shop" with its identifier.
2. If "Wallet Not Synced" appears, `tap-text Continue`.
3. In "Connect to Auction House?", `tap-text Connect`.

**Expected**
- An unsynced wallet gets "Since your wallet is not synced there may be some issues viewing the data in this shop. Continue anyway?".
- The connect dialog reads "Would you like to connect to <name> (<vfx url>)?". While it connects, the loader shows "Connecting to shop...", then "Connected to <url>. Fetching data...", then "Getting collections and listings...".
- The shop opens with its name as the title, the description, "Collections" with rows, or "No Active Collections", and Refresh and "Chat" in the app bar.
- An offline shop instead shows "Shop is offline." in the loader and the toast "Could not connect to shop because it's offline.".

**Cleanup:** none.

### TC-SHOP-056 · Browse a remote collection
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** TC-SHOP-055 passed.

**Steps**
1. Tap a collection row.
2. `tap-label "Grid view"`, then `tap-label "List view"`, and expand a listing.

**Expected**
- The app bar shows the collection name, the account selector, the balance "<n> VFX" (tooltip "My Balance"), Refresh and "Chat".
- A listing shows a "Details" table ("Identifier", "Owner Address", "Minted By", "Minter Address", "Chain"), plus a "Buy Now" section ("Price: <n> VFX") and/or an "Auction" section.
- A future listing shows "Auction Upcoming" and "Begins: <date> <time>", with an "Auction Starts" countdown. An ended auction shows "Auction Has Ended", plus "Purchased by: <address> for <n> VFX" when the reserve was met.
- A collection with no valid listings shows "No Active Listings".

**Cleanup:** none.

### TC-SHOP-057 · Remote bid validation and bid
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** TC-SHOP-056 passed, on an active auction listing. The chain is synced. The listing's increment `<inc>` and current price `<cur>` are known from "Details".

**Steps**
1. `tap-key remote_shop:bid_now`. Submit empty, then `abc`, then `<cur>`, then `<cur>+<inc>` exactly.
2. Enter `<cur>+<inc>+0.5` and `tap-text Continue`, then `tap-text "Place Bid"`.

**Expected**
- The prompt is titled "Place Bid", with the field "Bid Amount (VFX)" and the footer "Must be greater than <cur+inc> VFX".
- Step 1 shows, in order: "Bid Amount is required.", then "Invalid Bid Amount.", then the toast "Your bid must be greater than the current highest bid (<cur> VFX)", then the toast "The minimum increment amount is <inc> VFX. A bid grater than <cur+inc> VFX is required.". "grater" is a typo in the current string; log it as P2 copy.
- The confirmation reads "Are you sure you want to place a bid of <amount> VFX?". The toast "Bid sent. Please check the Bid History to see if it's been accepted or rejected." follows.
- A disconnected shop instead shows "This shop is currently offline.".

**Open question:** `BidListProvider.sendBid` checks the balance against the listing floor price, not the bid amount. Should a bid above the balance be blocked with "Not enough balance."?

**Cleanup:** none.

### TC-SHOP-058 · Remote Buy Now
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** TC-SHOP-056 passed, on an active Buy Now listing that a party we control is selling (a second Mac). Record the balances.

**Steps**
1. `tap-key remote_shop:buy_now`, then `tap-text "Buy Now"` in the dialog.
2. Wait up to 5 minutes for the NFT to appear in the buyer's NFT list, refreshing every 30 seconds.

**Expected**
- The dialog reads "Are you sure you want to buy now for <price> VFX?". The toast "Buy Now transaction sent successfully. Please wait for confirmation." follows. A failure shows "A problem occurred.".
- The NFT moves to the buyer, the seller gains the price, and the buyer loses the price plus fees.

**Cleanup:** none.

### TC-SHOP-059 · Remote Bid History and Auction Details
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** TC-SHOP-056 passed, on an auction listing.

**Steps**
1. `tap-key remote_shop:bid_history`.
2. If one of your own bids shows "Sent", `tap-text "Resend Bid"`.
3. `tap-key remote_shop:auction_details`.

**Expected**
- With no bids, step 1 shows "No bids.". Otherwise a sheet titled "Current Bids" lists each bid's amount in VFX, the address, the send time and a badge ("Sent", "Received", "Accepted", "Purchased" with "[Buy Now]", or "Rejected").
- Step 2 shows "Bid Resent!" and closes the sheet.
- "Auction Details" shows "Current Bid Price:", "Increment Amount:", "Reserve Met:" and "Active:". While disconnected, the warning "Warning: This shop is currently offline so the information may not be up to date." shows first.

**Cleanup:** none.

## Chat

### TC-SHOP-060 · Web buyer starts a chat with a web shop
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** B on web, on `qa-<run-id> web shop`.

**Steps**
1. Click `button "Chat"`.
2. Click `button "Send message"` with the field empty.
3. Click `textbox "Send message..."`, type `qa-<run-id> hello from B`, and click `button "Send message"`.

**Expected**
- The chat opens titled "Chatting with qa-<run-id> web shop". The message field shows the hint "Send message..." and takes at most 240 characters.
- Step 2 sends nothing.
- After step 3 the field clears, and the message appears with a time label, B as the sender, and a date divider.

**Cleanup:** none.

### TC-SHOP-061 · Web seller reads and replies
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SHOP-060 passed. A on web, on A's shop.

**Steps**
1. Click `button "Chat"`.
2. Open the row titled with B's address.
3. Type `qa-<run-id> reply from A` and send it.
4. In B's chat, wait up to 30 seconds without refreshing.

**Expected**
- A's list is titled "Chats". B's row shows B's address, with the last message as the subtitle (or "No messages yet").
- The thread is titled "Chat with <B address>" and shows B's message. A's reply appears after sending.
- B's chat shows the reply within 30 seconds (it polls every 5 seconds). Within 60 seconds B also gets a new-message notification titled with A's address.

**Cleanup:** none.

### TC-SHOP-062 · Chat refresh and buyer delete
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SHOP-061 passed. B in the chat.

**Steps**
1. Click `button "Refresh"`.
2. Click `button "Delete Chat Thread"`, then `button "Cancel"`.
3. Click `button "Delete Chat Thread"`, then `button "Delete"`.
4. On the shop, click `button "Chat"` again.

**Expected**
- Refresh keeps the messages.
- The dialog is titled "Delete Chat Thread" and reads "Are you sure you want to delete this chat thread?". Cancel keeps the thread.
- Delete closes the chat. Reopening it shows an empty thread, and A's "Chats" no longer lists the old thread after a refresh.

**Cleanup:** none.

### TC-SHOP-063 · Web seller deletes a thread
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** B has sent a new message to A's web shop (repeat TC-SHOP-060 step 3). A is in "Chat with <B address>".

**Steps**
1. Click `button "Delete Chat Thread"`, then `button "Delete"`.

**Expected**
- The dialog reads "Are you sure you want to delete this chat thread?". After Delete the screen closes, and the thread is gone from "Chats".

**Open question:** `WebSellerChatScreen` never sets the shop URL when `shopId` is not 0, which is always the case on web. The code therefore looks like it will show "No shop" and leave the loading overlay up. Confirm, and file a bug if so.

**Cleanup:** reload the page if the overlay stays.

### TC-SHOP-064 · Chat from a collection page
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** B on web, on `qa-<run-id> collection`.

**Steps**
1. Click `button "Chat"` in the collection app bar.

**Expected**
- The same thread as the shop's Chat opens, titled "Chatting with qa-<run-id> web shop".

**Cleanup:** none.

### TC-SHOP-065 · Desktop seller chat with a web buyer
**Platforms:** macOS, Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** The DST shop from TC-SHOP-040 is online. A on macOS, B on web.

**Steps**
1. As A on macOS, open "My Auction House" and `tap-text Chat`.
2. As B on web, open `qa-<run-id> dst shop`, click `button "Chat"`, and send `qa-<run-id> hi DST`.
3. On macOS, wait up to 30 seconds for B's row, then tap it.
4. `tap-key chat:message`, `type qa-<run-id> DST reply`, then `tap-key chat:send`.
5. On web, wait up to 30 seconds.

**Expected**
- Before step 2, the macOS list is titled "Chats" and shows "No Chats" if no threads exist.
- B's row appears with the message as its subtitle. The thread is titled "Chat with <B address>".
- The reply appears on macOS, and in B's web chat within 30 seconds.

**Cleanup:** none.

### TC-SHOP-066 · Desktop buyer chat with a remote shop
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SHOP-055 passed.

**Steps**
1. On the remote shop, `tap-text Chat`.
2. `tap-key chat:message`, `type qa-<run-id> remote hello`, then `tap-key chat:send`.
3. `tap-label "Delete Chat Thread"`, then `tap-text Delete`.

**Expected**
- The chat is titled "Chatting with <shop name>". The message appears after sending.
- The delete dialog reads "Are you sure you want to delete this chat thread locally?". Delete closes the screen.

**Cleanup:** none.

### TC-SHOP-067 · Desktop buyer chat with a web-hosted shop
**Platforms:** macOS, Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** B on macOS, on A's web shop (TC-SHOP-035).

**Steps**
1. `tap-text Chat`, then send `qa-<run-id> from desktop` with `chat:message` and `chat:send`.
2. As A on web, open the shop's "Chats" and refresh for up to 30 seconds.

**Expected**
- macOS opens "Chatting with qa-<run-id> web shop" and shows the message.
- A sees a thread from B's address containing the message.

**Cleanup:** none.

### TC-SHOP-068 · Chat message context menu
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Any chat with at least one message sent by the current account.

**Steps**
1. Right-click a message and choose "Copy Message".
2. Right-click it again and choose "Copy Address".
3. Right-click your own message and check that "Resend Message" is listed.

**Expected**
- Step 1 shows the toast "Message copied to clipboard.", and step 2 shows "Address copied to clipboard.".
- "Resend Message" appears only on your own messages.

**Cleanup:** none.

## Cleanup (seller A)

### TC-SHOP-069 · Delete a web listing
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As A, on `qa-<run-id> collection`, with an unsold listing. If none is left, create a Buy Now listing for any unlisted NFT of A.

**Steps**
1. Expand the listing and click `button "Delete"`, then `button "Cancel"`.
2. Click `button "Delete"`, then `button "Delete"` in the dialog, then `button "Refresh"`.

**Expected**
- The dialog is titled "Delete Listing" and reads "Are you sure you want to delete this listing?". Cancel keeps the listing.
- After Delete and refresh, the listing is gone.

**Cleanup:** none.

### TC-SHOP-070 · Delete a web collection
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As A, on `qa-<run-id> collection`.

**Steps**
1. Click `button "Delete Collection"`, then `button "Delete"`.

**Expected**
- The dialog is titled "Are you sure you want to delete this collection?" and reads "This is permanent".
- The collection screen closes, and the shop no longer lists the collection.

**Cleanup:** none.

### TC-SHOP-071 · Delete the published web shop
**Platforms:** Web · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** As A, on `qa-<run-id> web shop`. Note A's balance.

**Steps**
1. Click `button "Delete Shop"`, then `button "Cancel"`.
2. Click `button "Delete Shop"`, then `button "Delete"`.
3. Wait up to 2 minutes for the delete transaction to read Success. Then refresh "My Auction Houses" and "Auction Houses" every 30 seconds for up to 5 minutes.

**Expected**
- The dialog is titled "Delete shop?" and reads "Are you sure you want to delete this shop? There is a cost of 1.0 VFX to delete this from the network.". Cancel keeps the shop.
- Delete shows the toast "Shop Delete transaction broadcasted to the network" and closes the shop screen.
- A's balance falls by 1 VFX plus the fee. The shop disappears from both lists.

**Cleanup:** none.

### TC-SHOP-072 · Unpublished web shop: create without publishing, then delete
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Logged in as B on web. B has no shop.

**Steps**
1. On "My Auction Houses", click `button "Setup Auction House"`. Fill `qa-<run-id> b shop`, `tmp` and `qa-<run-id>-b`, then click `button "Create"`.
2. Cancel the email prompt if it appears. In "Publish Shop?", click `button "Cancel"`.
3. On the shop screen, check the header, then click `button "Delete Shop"` and `button "Delete"`.

**Expected**
- The shop screen shows a "Publish Shop" button instead of the "Published" badge. "My Auction Houses" lists the shop with an "Unpublished" badge.
- The delete dialog reads "Are you sure you want to delete this shop?", with no cost line. No transaction is sent, and the shop is removed.

**Open question:** can one address own more than one web shop? If it can, clicking "Publish Shop" on the unpublished shop needs its own case (10 VFX).

**Cleanup:** none.

### TC-SHOP-073 · Delete a DST collection
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** A on macOS, on `qa-<run-id> dst collection`.

**Steps**
1. `tap-text "Delete Collection"`, then `tap-text Delete` in the dialog.

**Expected**
- The dialog is titled "Delete Collection" and reads "Are you sure you want to delete this store?". Delete shows the toast "Collection deleted." and returns to "My Auction House" without the collection.

**Cleanup:** none.

### TC-SHOP-074 · Delete the published DST shop
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** A on macOS, on "My Auction House", with `qa-<run-id> dst shop` published. Note A's balance.

**Steps**
1. `tap-text "Delete Shop"`, then `tap-text Cancel`.
2. `tap-text "Delete Shop"`, then `tap-text Delete`.
3. Wait up to 2 minutes for the delete transaction to confirm.

**Expected**
- The dialog reads "Are you sure you want to delete this shop from the network? There is a cost of 1.0 VFX plus TX fee to perform this operation.". Cancel keeps the shop.
- Delete shows the toast "Delete TX broadcasted.", then "Shop Deleted". The empty state from TC-SHOP-037 returns.
- A's balance falls by 1 VFX plus the fee. Within 5 minutes the shop is gone from "Auction Houses".

**Cleanup:** none.

## Not live / excluded

- **Store routes.** `/s/:slug` (`StoreListingScreen`) and `store/collection/:slug` (`StoreCollectionScreen`) are commented out in `lib/core/web_router.dart`, so there are no cases.
- **Debug routes.** `DebugWebShopTabsRouter`, `DebugWebShopListScreenRoute`, `DebugMyWebShopListScreenRoute`, `DebugWebShopCreateScreenRoute`, `DebugWebListingCreateScreenRoute`, `DebugWebShopDetailScreenRoute`, `DebugWebCollectionDetailScreenRoute` and `DebugWebListingDetailScreenRoute` are commented out in `lib/core/app_router.dart` and cannot be reached, so they are excluded.
- **Unreachable desktop screens.** `RemoteShopListScreen` (keys `remote_shop:connect`, `remote_shop:connect_empty`) is only referenced by a commented-out route. `BuyerChatThreadListScreen` is routed at `remote-shop-container/shops/chat`, but only `RemoteShopListScreen` pushes it. Desktop buyers reach shop chat from each shop's "Chat" button instead (TC-SHOP-066, TC-SHOP-067).
- **Pay with card or crypto.** The "Insufficient Balance" → "Pay with Credit Card / Crypto" on-ramp path in buy and bid only runs when `ALLOW_BIDS_WITHOUT_BALANCE` is true. It is false, and the on-ramp iframe does not render under `?automation=1` anyway.
- **Unused seller hook.** `WebBidListProvider.waitForSaleStart` exists but its only caller is commented out.
