# 09 · Smart contracts and NFTs

This area covers the smart contract creator (name, creator, description, primary asset, and the three features the chooser offers today: Royalty, Evolving and Multi Asset), properties including colors, compile and mint, the NFT Collection Wizard with its JSON and CSV import, the NFT list and detail screens, transfer, evolve and devolve, burn, the NFT management modal, and desktop asset handling in the Core CLI assets folder, on both the web wallet and the macOS desktop GUI. The code lives in `lib/features/{smart_contracts,sc_property,nft,asset}`; desktop routes are in `lib/core/app_router.dart`, web routes in `lib/core/web_router.dart`. Several things the release checklist names have no reachable UI in this build: the templates chooser, drafts (save, reopen, delete) and the My Smart Contracts list are registered routes whose only entry points are commented out, and Soul-Bound, Ticketing, Fractionalization, Tokenization and Pair exist as models and modals but are not offered by the feature chooser. A single-contract "quantity to mint" prompt is also commented out (the creator always mints one); quantity exists only per instance in the Collection Wizard. Those items get reachability cases with open questions rather than invented steps. Selling an NFT (the `Sell` button on desktop) belongs to the P2P auction and shop flows and is not tested here.

## Area preconditions

- **Accounts.** Web: logged in with `TEST_VFX_A_PRIVKEY` through `VFX Private Key` (see `01-launch-auth.md`). macOS: account A imported from `TEST_VFX_A_PRIVKEY`, chain synced, and account A selected as the current account. Account A holds at least 30 testnet VFX (each compile and mint, transfer, evolve and burn costs a fee). Account B's address is `TEST_VFX_B_ADDRESS`; the receipt cases log in to the web wallet with `TEST_VFX_B_PRIVKEY`.
- **One account, two clients.** Web and macOS both sign as account A. Never run fund-moving steps on both platforms at the same time; finish a case on one platform (including its chain wait) before starting it on the other.
- **Names.** `<run-id>` is the run id from the README (for example `qa-20261001a`). `<p>` is `web` or `mac` for the platform the case runs on, so every on-chain object is unique per run and per platform. Objects created in this area: `sc-basic-<run-id>-<p>` (TC-SC-009, transferred to B in TC-SC-043), `sc-full-<run-id>-<p>` (TC-SC-022, evolved in TC-SC-040 and 041, burned in TC-SC-047), `sc-time-<run-id>-<p>` (TC-SC-023), `sc-video-<run-id>-web` (TC-SC-034) and the collection `sc-bulk-<run-id>-<p>-1`, `-2` (TC-SC-054).
- **Test files.** Before the run, put these files in the run's scratch folder. They are generated per run and committed nowhere: `sc-a.png`, `sc-b.png` and `sc-c.png` (three visibly different small PNGs, each under 200 KB), `sc-clip.mp4` (a short H.264 clip under 2 MB), `sc-bad.vbx` (a copy of `sc-a.png` renamed to an extension on the blocked list in `MALWARE_FILE_EXTENSIONS`), `sc-bulk.json`, `sc-bulk.csv`, `sc-bad-headers.csv` and `sc-bad.json` (contents given in the bulk cases). For web cases the scratch folder must be one the Claude in Chrome session can upload from, because the `file_upload` tool rejects other paths.
- **Picking a file on web ("web file pick").** Flutter's file picker (file_picker 4.6.1) creates a hidden `<input type="file">` inside `flt-file-picker-inputs#__file_picker_web-file-input` when a picker button is pressed. Click the picker button named in the step, then use `find` to locate the newest file input inside `#__file_picker_web-file-input` and call the `file_upload` tool with that ref and the absolute path of the named file in the scratch folder. The creator uploads the file to Spyglass right away; wait up to 30 seconds for the loading overlay to clear and the file name to appear.
- **Picking a file on macOS ("macOS file pick").** The picker is the native macOS open panel, which `tool/drive.dart` cannot reach. After the step that opens it, drive the panel with System Events: `osascript -e 'tell application "System Events" to keystroke "g" using {command down, shift down}'`, then `osascript -e 'tell application "System Events" to keystroke "<absolute path>"'`, then `osascript -e 'tell application "System Events" to key code 36'` twice (go to the path, then open it). Then `wait-for-text <file name> --timeout 10`.
- **Dialog buttons.** `ConfirmDialog`, `InfoDialog` and `PromptModal` buttons carry no keys. On macOS tap them with `tap-text <label>`; on web click `button "<label>"`. Text fields are reached on macOS with `tap-text "<field label>"` followed by `type <text>`, and on web with `textbox "<field label>"` or `await fltA11y.type("<field label>", "<text>")`.
- **Chain waits.** A mint, transfer, evolve or burn shows on chain within 3 minutes on testnet. Where a case waits, press `Refresh` in the NFT list (tooltip `Refresh`; web `button "Refresh"`, macOS `tap-label Refresh`) every 30 seconds rather than sleeping.
- **Build mode.** `make run_macos_driver` is a debug build, so the landing screen's "wallet synced" guard is skipped (`kDebugMode`); the compile step still refuses an unsynced wallet with `Please wait until your wallet is synced with the network`.
- **Open question:** does the web file input survive the native chooser that `uploadInput.click()` opens under Claude in Chrome, so that `file_upload` can fill it, or does the chooser need dismissing first? If `file_upload` cannot reach it, every web case with a file pick is blocked until an automation hook exists.
- **Open question:** the macOS file pick needs Accessibility permission for the process running `osascript`. Is that granted on the release machine, or should the driver flavor get a test-only file picker override instead?
- **Open question:** several controls share a label on the same screen (the two `Copy address` buttons on NFT detail, the `Add Royalty` dialog title and its button in the wizard, the per-row `Edit`, `Remove` and `Delete` buttons). On macOS `tap-text` and `tap-label` fail with "Too many elements" there. Those steps are marked; should the controls get `<feature>:<detail>` keys?

## Landing and creator entry

### TC-SC-001 · Smart contract landing screen
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Logged in as account A.

**Steps**
1. Open Smart Contracts. Web: click `button "Smart Contracts"` in the side nav. macOS: `tap-key nav:smart_contracts`.
2. Read the screen.

**Expected**
- Web: the app bar reads `Create Smart Contract`. macOS: the app bar reads `Smart Contracts`.
- Three large buttons are shown: `Create a Smart Contract & Mint` (body `Start with a baseline smart contract and add customized features`), `Mint NFT Collection` (body `Mint multiple Smart Contracts into a collection`) and `Launch IDE` (body `Open the online IDE to write your own Trillium code for your smart contract`).
- There is no templates, drafts or My Smart Contracts entry (see TC-SC-059 to 061).

**Cleanup:** none.

### TC-SC-002 · Launch IDE opens Trillium
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On the Smart Contracts landing screen (TC-SC-001).

**Steps**
1. Web: `fltA11y.click("Launch IDE")`. macOS: `tap-text "Launch IDE"`.

**Expected**
- `https://trillium.rbx.network/` opens in a new browser tab (web) or the default browser (macOS). On a mobile-width web layout a confirm dialog `Launch IDE on mobile?` with `The IDE is optimized for larger screens. Would you like to proceed?` appears first.

**Cleanup:** Close the Trillium tab.

### TC-SC-003 · Creator refuses a BTC or vault account (macOS)
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** A BTC account exists (`04-btc-vbtc.md`) and a vault account exists (`06-vault-accounts.md`) in the desktop wallet.

**Steps**
1. Select the BTC account as the current account, open Smart Contracts (`tap-key nav:smart_contracts`) and `tap-text "Create a Smart Contract & Mint"`.
2. Select the vault account as the current account and `tap-text "Create a Smart Contract & Mint"` again.
3. Select account A again.

**Expected**
- Step 1 shows the error toast `Please choose a VFX account to begin creating a smart contract.` and the creator does not open.
- Step 2 shows the error toast `Vault Accounts cannot mint smart contracts` and the creator does not open.

**Cleanup:** Account A selected.

### TC-SC-004 · Close the creator with the confirm dialog
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** On the Smart Contracts landing screen.

**Steps**
1. Open the creator. Web: `fltA11y.click("Create a Smart Contract & Mint")`. macOS: `tap-text "Create a Smart Contract & Mint"`.
2. Type `close-test` into `Smart Contract Name`.
3. macOS: `tap-label Close` (the close icon in the app bar). Web: use the browser back button or the side nav, since the web create screen has no close button.
4. macOS: in the dialog, `tap-text Cancel`, then `tap-label Close` again and `tap-text Continue`.

**Expected**
- macOS: the dialog reads `Are you sure you want to close the smart contract creator?` with `All unsaved changes will be lost.`. `Cancel` keeps the creator open with `close-test` still in the name field; `Continue` returns to the landing screen, and reopening the creator shows an empty name field.
- Web: leaving the screen needs no confirmation.
- **Open question:** should the web creator also confirm before discarding unsaved input?

**Cleanup:** none.

### TC-SC-005 · Minter address switcher (macOS)
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Creator open (TC-SC-004 step 1). The desktop wallet holds at least one other non-vault VFX account besides A.

**Steps**
1. `tap-text "Minter Address:"` to open the account menu.
2. Read the menu, then pick account A.

**Expected**
- The menu lists every non-vault account as `<address> (<balance> VFX)`; vault accounts are not listed; the current account is highlighted.
- After picking A, the app bar shows `Minter Address:` followed by account A's address.

**Cleanup:** Account A selected.

## Creator fields and validation

### TC-SC-006 · Compile with an empty form lists every missing field
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Creator open with an empty form, logged in as account A.

**Steps**
1. Press Compile & Mint. Web: click `button "Compile & Mint"`. macOS: `tap-key sc:compile_mint`.
2. Close the dialog. Web: `button "Okay"`. macOS: `tap-text Okay`.
3. Fill only `Smart Contract Name` with `v-<run-id>` and press Compile & Mint again.

**Expected**
- Step 1 opens `Invalid Smart Contract` with the four lines `- Asset is required`, `- Name is required`, `- Minter name is required` and `- Description is required`, and an `Okay` button. Nothing is compiled.
- Step 3 lists only `- Asset is required`, `- Minter name is required` and `- Description is required`.

**Cleanup:** Close the dialog.

### TC-SC-007 · Primary asset choose, replace, reveal and remove
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Creator open.

**Steps**
1. In the `Asset` group press `Choose File` (web `button "Choose File"`, macOS `tap-text "Choose File"`) and pick `sc-a.png` (web file pick / macOS file pick).
2. macOS only: `tap-text Reveal`.
3. Press `Replace` and pick `sc-b.png`.
4. Press `Remove` (web `button "Remove"`, macOS `tap-text Remove`).

**Expected**
- After step 1 the group shows a thumbnail, the file name `sc-a.png` and `Type:` followed by the file type, plus `Replace` and `Remove` (and on macOS `Reveal`). On web the upload to Spyglass completes before the file name appears.
- macOS step 2 opens `sc-a.png` from its local path in the default viewer.
- Step 3 shows `sc-b.png` in place of `sc-a.png`.
- Step 4 returns the group to the `Asset` title with a `Choose File` button.

**Cleanup:** none.

### TC-SC-008 · Blocked file extension is rejected (macOS)
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Creator open.

**Steps**
1. `tap-text "Choose File"` and pick `sc-bad.vbx` (macOS file pick).
2. `tap-text Close` on the dialog.

**Expected**
- A dialog `Unsupported File` reads `This file extension (.vbx) is not permitted.` and the asset stays empty.
- Web has no extension check in `FileSelector`. **Open question:** should the web creator reject the same extensions before uploading to Spyglass?

**Cleanup:** none.

## Create and mint

### TC-SC-009 · Create and mint a basic NFT
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Logged in as account A with at least 5 VFX. macOS: chain synced, account A selected. Nothing else running that signs as A.

**Steps**
1. Open Smart Contracts (web `button "Smart Contracts"`, macOS `tap-key nav:smart_contracts`) and the creator (web `fltA11y.click("Create a Smart Contract & Mint")`, macOS `tap-text "Create a Smart Contract & Mint"`).
2. Type `sc-basic-<run-id>-<p>` into `Smart Contract Name`, `QA Runner` into `Minter/Creator Name` and `Basic release test NFT <run-id>` into `Description`.
3. Press `Choose File` and pick `sc-a.png` (web file pick / macOS file pick).
4. Press Compile & Mint. Web: click `button "Compile & Mint"`. macOS: `tap-key sc:compile_mint`.
5. macOS only: the `Backup URL (Optional)` prompt opens (`Paste in a public URL to a hosted zipfile containing the assets.`, field `URL (Optional)`). `tap-text Cancel`; the flow continues without a backup URL.
6. In `Compile & Mint Smart Contract?` press `Continue`.
7. In `Confirm Address` press `Compile & Mint`.
8. Wait up to 60 seconds for the compile animation to finish.
9. Close the `Stand by` dialog with `Close`.
10. Open NFTs (web `button "NFTs"`, macOS `tap-key nav:nfts`) and wait up to 3 minutes, pressing `Refresh` every 30 seconds, for a card titled `sc-basic-<run-id>-<p>`.

**Expected**
- Step 6 dialog body starts `Are you sure you want to proceed?` and says the contract cannot be changed once compiled.
- Step 7 dialog reads `This will be minted by` followed by account A's name or address.
- Step 8 shows `Compiling & Minting…`, then `Compiled!`.
- Web: the toast `Smart Contract minted successfully.` appears. macOS: the toast `Mint transaction sent successfully. Please wait until the the smart contract is minted on-chain.` appears.
- The `Stand by` dialog explains that the mint was broadcast; after `Close` the app returns to the Smart Contracts landing screen.
- The NFT card appears in `My NFTs` within 3 minutes with the name and its smart contract id.
- A mint transaction for account A appears in the transaction list.

**Cleanup:** none (the NFT is used by TC-SC-010 and TC-SC-043).

### TC-SC-010 · View the minted NFT
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** TC-SC-009 passed on this platform.

**Steps**
1. In NFTs, tab `My NFTs`, open the card. Web: `fltA11y.tap("sc-basic-<run-id>-<p>")`. macOS: `tap-text sc-basic-<run-id>-<p>`.
2. Wait up to 3 minutes for the status badge to read `Minted`.

**Expected**
- The app bar title and the large heading read `sc-basic-<run-id>-<p>`; the badge reads `Minting...` and then `Minted`.
- The smart contract id chip (tooltip `Smart Contract ID`) shows the id seen on the card.
- `Minted By: QA Runner` and the description `Basic release test NFT <run-id>` are shown.
- The `Owner` and `Minter Address` cards both show account A's address.
- The primary asset renders the `sc-a.png` image, with `File Type` and `File Size` rows. Web: a `Download Asset` button. macOS: `Open Folder` and `Open Asset` buttons.
- The QR code card has `Save` and `Open` icon buttons.
- `Features:` shows `No features`.
- Action buttons: `Prove Ownership`, `Transfer`, `Sell`, `Burn`; macOS also `Sync Media`. `Manage` is absent because the NFT has no manual evolve feature.

**Cleanup:** Go back to the NFT list.

## Features

### TC-SC-011 · Feature chooser offers Royalty, Evolving and Multi Asset, once each
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Creator open with no features.

**Steps**
1. Under `Features`, press `Add Feature` (web `button "Add Feature"`, macOS `tap-text "Add Feature"`).
2. Read the sheet, then close it with `Close`.
3. Add a Royalty of `5` to `TEST_VFX_B_ADDRESS` (TC-SC-013 step 1 to 3).
4. Press `Add Another Feature`, then `Royalty` (web `fltA11y.tap("Royalty")`, macOS `tap-text Royalty`).

**Expected**
- The sheet is titled `Add a Feature` and lists exactly three options: `Royalty` (`Include a royalty that is enforced on-chain upon any trade`), `Evolving` (`Allow the smart contract to evolve based on time or network variables`) and `Multi Asset` (`Allow multiple assets to be compiled into the smart contract`).
- Soul-Bound, Ticketing, Fractionalization and Tokenization are not offered.
- After one royalty exists, the button reads `Add Another Feature`, and choosing `Royalty` again shows `Can't add Royalty` with `You already have a royalty feature in this smart contract.`.
- The same guard applies to `Evolving` (`Can't add Evolve`) and `Multi Asset` (`Can't add Multi Asset`) once one exists.
- **Open question:** Soul-Bound, Ticketing, Fractionalization, Tokenization and Pair have modals in `lib/features/smart_contracts/features/` but are commented out of `Feature.allTypes()`. Are they intentionally dark for this release, and should their modals be removed?

**Cleanup:** Remove the royalty (TC-SC-021) or close the creator.

### TC-SC-012 · Royalty validation
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Creator open, no royalty yet.

**Steps**
1. `Add Feature` → `Royalty`. The sheet `Royalty` has `Percentage` (suffix `%`) and `Address`.
2. Press `Save` with both fields empty.
3. Type `0` into `Percentage` and `RxNOTAREALADDRESS` into `Address`; press `Save`.
4. Replace the percentage with `150`; press `Save`.
5. Type `abc` into `Percentage`.
6. Press `Cancel`.

**Expected**
- Step 2: `Required` under `Percentage` and `Address required` under `Address`; the sheet stays open.
- Step 3: `Must be more than 0%` and `Invalid Address.`.
- Step 4: `Can not be more than 100%`.
- Step 5: the field accepts only digits and `.`, so no letters appear.
- Step 6 closes the sheet and no Royalty card is added.

**Cleanup:** none.

### TC-SC-013 · Add, edit and remove a royalty
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Creator open, no royalty yet.

**Steps**
1. `Add Feature` → `Royalty`; type `5` into `Percentage`.
2. Fill `Address`. Web: press `Use My Address` (fills account A), then replace it with `TEST_VFX_B_ADDRESS`. macOS: `tap-label "Choose an address"`, check the `Choose an address` dialog, `tap-text Cancel`, then type `TEST_VFX_B_ADDRESS`.
3. Press `Save`.
4. On the new Royalty card press `Edit`, change the percentage to `7.5`, press `Save`.
5. Press `Remove` on the card and confirm with `Delete` in `Delete?`.

**Expected**
- Step 2: web `Use My Address` fills account A's address; macOS `Choose an address` lists every account in the wallet as full labels.
- Step 3: a `Royalty` card appears with subtitle `Percent 5.0% [<account B address>]`.
- Step 4: the edit sheet opens with `5.0` and B's address; after saving, the subtitle reads `Percent 7.5% [<account B address>]` and there is still one card.
- Step 5: the confirm reads `Are you sure you want to delete this?`; after `Delete` the card is gone and the button reads `Add Feature`.

**Cleanup:** none.

### TC-SC-014 · Multi Asset: add and remove additional assets
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Creator open.

**Steps**
1. `Add Feature` → `Multi Asset`. The sheet is titled `Assets` and shows one `Choose a File` row.
2. Press `Choose File` and pick `sc-b.png`; then press the new row's `Choose File` and pick `sc-c.png`.
3. Press `Remove` on the `sc-b.png` row.
4. Press `Save`.
5. Press `Edit` on the `Multi Asset` card, check the list, and press `Cancel`.

**Expected**
- After step 2 the sheet lists `sc-b.png` and `sc-c.png` plus an empty `Choose a File` row; existing rows show `Remove` but no `Replace`.
- After step 3 only `sc-c.png` remains.
- After step 4 a `Multi Asset` card reads `1 asset`.
- The edit sheet in step 5 lists `sc-c.png`.

**Cleanup:** none.

### TC-SC-015 · Multi Asset saved with no files
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Creator open with no Multi Asset feature.

**Steps**
1. `Add Feature` → `Multi Asset`, then press `Save` without choosing a file.

**Expected**
- The sheet closes and no `Multi Asset` card is added; the app shows no error.
- **Open question:** `MultiAssetFormProvider.complete()` calls `removeMultiAsset` for an id that is not in the list, which runs `removeAt(-1)`; this may throw a RangeError in the log. Record what the log shows.

**Cleanup:** none.

### TC-SC-016 · Properties: text, number and color, edit and remove
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Creator open with no properties.

**Steps**
1. In `Properties` (shows `No Properties`) press `Add Property`. The sheet has a `Property Type:` dropdown (default `Text`), `Property Name` and `Property Value`.
2. Type `Edition` / `First`; press `Save`.
3. `Add Property`; open `Property Type:` and choose `Number`; type `Level` / `12a.5`; press `Save`.
4. `Add Property`; choose `Color`; type `Background` into `Property Name`. Press the palette button (web `button "Pick a color"`, macOS `tap-label "Pick a color"`), pick any color and press `Choose`. Press `Save`.
5. On the `Edition` row press `Edit`, change the value to `Second`, press `Save`.
6. On the `Level` row press `Remove`.

**Expected**
- Step 2: a row with title `First` and subtitle `Edition` and a text icon.
- Step 3: the value field accepts only digits and `.`, so it holds `12.5`; the row shows a number icon.
- Step 4: choosing `Color` prefills `#ff0000`; after `Choose` the value is a `#` followed by six hex digits; the row shows a palette icon.
- Step 5: the row now reads `Second`.
- Step 6: two rows remain, `Second` and the color.

**Cleanup:** none.

### TC-SC-017 · Property validation
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Creator open.

**Steps**
1. `Add Property`; press `Save` with both fields empty.
2. Choose `Color`, type `Tint` as name, replace the value with `ff0000` and press `Save`.
3. Replace the value with `#ff00`; press `Save`.
4. Press `Cancel`.

**Expected**
- Step 1: `Name is required.` under the name and `Value is required` under the value; the sheet stays open.
- Steps 2 and 3: `Invalid hex color`.
- Step 4 closes the sheet without adding a row.

**Cleanup:** none.

### TC-SC-018 · Manual evolving stages: add, validate, delete
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Creator open, no evolve feature.

**Steps**
1. `Add Feature` → `Evolving`. Check the header row: `Evolve`, `Evolving Mode:` (`Issuer/Minter Controlled`) and `Evolution Type:` (`Manual Only`), and one block `Evolve Stage 1`.
2. Press `Save and Close` with the stage empty.
3. Type `Stage One` into `Evolve Stage Name` and `First evolution` into `Evolve Stage Description`; press `Save and Close`.
4. Press `Choose File` in the stage (title `Evolve Stage Asset`) and pick `sc-b.png`. Press `Create New Phase`.
5. In `Evolve Stage 2` press the delete icon (web `button "Delete Stage"`, macOS `tap-label "Delete Stage"`) and confirm `Delete`.
6. Press `Save and Close`.

**Expected**
- Step 2: `Name is required.` and `Description is required.` under the fields; the sheet stays open.
- Step 3: an overlay toast `Asset is required` appears and the sheet stays open.
- Step 4 adds an `Evolve Stage 2` block; `Delete Stage`, `Create New Phase` and `Save and Close` move to the last block.
- Step 5 asks `Are you sure you want to delete this stage?` and removes `Evolve Stage 2`.
- Step 6 closes the sheet; an `Evolving` card reads `2 phases` (the base plus one stage).
- The evolving mode options are exactly `Issuer/Minter Controlled` and `Automated/Application Controlled`; while `Issuer/Minter Controlled` is selected the only type is `Manual Only`.

**Cleanup:** none.

### TC-SC-019 · Date/time evolving stage
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Creator open, no evolve feature.

**Steps**
1. `Add Feature` → `Evolving`. Open `Evolving Mode:` and choose `Automated/Application Controlled`.
2. Open `Evolution Type:` and read the options; keep `Date/Time`.
3. Press the calendar button (tooltip `Pick a date`) and pick today; press `OK`. Press the clock button (tooltip `Pick a time`), enter `12:00 AM` and press `OK`.
4. Press `Pick a date` again, pick tomorrow's date and press `OK`; press `Pick a time`, keep `12:00 AM`, press `OK`.
5. Fill `Evolve Stage Name` (`Tomorrow`), `Evolve Stage Description` (`Evolves tomorrow`) and the stage asset (`sc-b.png`); press `Save and Close`.

**Expected**
- Step 1 switches the type to `Date/Time`; the stage shows `Evolution Date` and `Evolution Time (<time zone>)` fields.
- Step 2 offers exactly `Date/Time` and `Block Height`.
- Step 3: dates before today cannot be picked; the time `12:00 AM` today shows the overlay toast `Time must be in the future.` and the time field stays empty.
- Step 4 fills the date as tomorrow in `M/D/YYYY` and the time as `00:00:00`.
- Step 5 saves; the `Evolving` card reads `2 phases`.
- Pressing `Save and Close` with the date or time empty shows `Required for Date/Time evolution.`.

**Cleanup:** none, or keep for TC-SC-023.

### TC-SC-020 · Block height evolving stage validation
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Creator open, no evolve feature. The current block height is known (status bar on macOS, explorer on web).

**Steps**
1. `Add Feature` → `Evolving`; set `Automated/Application Controlled`, then `Evolution Type:` → `Block Height`.
2. Clear `Block Height Value`, fill name, description and asset, press `Save and Close`.
3. Type the current block height; press `Save and Close`.
4. Type the current block height plus 1000; press `Save and Close`.

**Expected**
- Step 2: `Required for Block Height evolution.`.
- Step 3: `Block height must be greater than <current height>.`.
- Step 4 saves and closes; the card reads `2 phases`. The field accepts digits only.

**Cleanup:** Remove the feature or close the creator.

### TC-SC-021 · Remove a feature
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Creator open with a Royalty card and an Evolving card.

**Steps**
1. On the `Evolving` card press `Remove` (macOS: ambiguous with the other card's `Remove`, see area open question), then `Cancel`.
2. Press `Remove` again and confirm `Delete`.

**Expected**
- `Delete?` / `Are you sure you want to delete this?` appears both times; `Cancel` keeps the card.
- After `Delete` only the Royalty card remains, and `Add Another Feature` can add `Evolving` again.

**Cleanup:** none.

### TC-SC-022 · Create and mint a full-featured NFT
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Logged in as account A with at least 5 VFX. macOS synced.

**Steps**
1. Open the creator. Name `sc-full-<run-id>-<p>`, creator `QA Runner`, description `Full-feature release test <run-id>`, primary asset `sc-a.png`.
2. Add properties `Edition` = `First` (Text), `Level` = `12` (Number) and `Background` = `#00ff00` (Color, typed).
3. Add a Royalty of `5` to `TEST_VFX_B_ADDRESS`.
4. Add a Multi Asset with `sc-c.png`.
5. Add an Evolving feature in `Issuer/Minter Controlled` / `Manual Only` mode: `Evolve Stage 1` named `Stage One`, description `First evolution`, asset `sc-b.png`, one property `Mood` = `Happy`; press `Create New Phase`; `Evolve Stage 2` named `Stage Two`, description `Second evolution`, asset `sc-c.png`; press `Save and Close`.
6. Press Compile & Mint (web `button "Compile & Mint"`, macOS `tap-key sc:compile_mint`).
7. macOS only: in `Backup URL (Optional)` type `https://example.com/sc-<run-id>.zip` into `URL (Optional)` and press `Continue`.
8. `Continue`, then `Compile & Mint`; wait up to 60 seconds for `Compiled!`; close `Stand by`.
9. In NFTs wait up to 3 minutes for `sc-full-<run-id>-<p>` and open it; wait for `Minted`.

**Expected**
- Before compiling, the features list shows `Royalty` (`Percent 5.0% [...]`), `Multi Asset` (`1 asset`) and `Evolving` (`3 phases`).
- The mint succeeds with the same toasts and dialogs as TC-SC-009.
- The NFT detail is checked in TC-SC-031.

**Cleanup:** none (used through TC-SC-047).

### TC-SC-023 · Create and mint a date/time evolving NFT
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Logged in as account A with at least 5 VFX.

**Steps**
1. Open the creator. Name `sc-time-<run-id>-<p>`, creator `QA Runner`, description `Time evolve test <run-id>`, asset `sc-a.png`.
2. Add an Evolving feature as in TC-SC-019 with one stage `Tomorrow` evolving tomorrow at `12:00 AM`.
3. Compile and mint (macOS: `Cancel` on the backup URL prompt). Wait up to 3 minutes for the card and open it.
4. Press `Reveal Evolve Stages` on the `Evolving` feature row.

**Expected**
- No `Evolve stage(s) in the past` warning appears, because the stage is in the future.
- The detail shows no `Manage` button, since stages with a date are not manually manageable.
- The reveal sheet shows row `0.` `Name: Base` and row `1.` `Name: Tomorrow` whose text starts `Evolve Date:` with tomorrow's date, `12:00 AM` and the local time zone, followed by `Evolves tomorrow`; no row has an `Evolve` button.
- **Open question:** should a follow-up run check the next day that the stage became current automatically?

**Cleanup:** none.

## NFT list

### TC-SC-024 · Grid and list view toggle
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Logged in with an account that owns at least one NFT.

**Steps**
1. Open NFTs (web `button "NFTs"`, macOS `tap-key nav:nfts`).
2. Press `List view` (web `button "List view"`, macOS `tap-label "List view"`).
3. Press `Grid view`.

**Expected**
- The screen is titled `NFTs` with tabs `My NFTs` and `Manage Minted NFTs`; the default is the grid (three columns on desktop width), each card showing the name, the id and the image.
- List view shows one row per NFT with a 32 px thumbnail, the name, the id as subtitle and a chevron.
- Grid view restores the cards. The choice applies to both tabs.

**Cleanup:** Leave grid view.

### TC-SC-025 · Search and clear
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On testnet: TC-SC-009 and TC-SC-022 passed on this platform. On mainnet: an account with at least two NFTs.

**Steps**
1. In `My NFTs`, type `sc-full-<run-id>` into the `Search...` field (on mainnet, a distinctive part of one NFT's name).
2. Press the search button (web `button "Search"`, macOS `tap-label Search`).
3. Press `Clear` (web `button "Clear"`, macOS `tap-label Clear`).

**Expected**
- Before step 2 the `Search` and `Clear` buttons are enabled only once text is present.
- After step 2 only matching NFTs are listed; `sc-basic-<run-id>-<p>` is not.
- After step 3 the field is empty and the full list returns.
- Searching for text that matches nothing shows `No NFTs found.`.

**Cleanup:** none.

### TC-SC-026 · Pagination and refresh
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On the NFT list.

**Steps**
1. Read the state of `Prev Page` and `Next Page`.
2. Press `Next Page` if enabled, then `Prev Page`.
3. Press `Refresh` (web `button "Refresh"`, macOS `tap-label Refresh`).

**Expected**
- On page 1 `Prev Page` is disabled. On macOS `Next Page` is enabled only when more NFTs exist; on web it is always enabled.
- Moving forward and back returns to the same page 1 list.
- `Refresh` reloads the current page without leaving it.

**Cleanup:** none.

### TC-SC-027 · Manage Minted NFTs tab and management modal
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SC-022 passed on this platform.

**Steps**
1. In NFTs open the `Manage Minted NFTs` tab.
2. Open `sc-full-<run-id>-<p>` (web `fltA11y.tap("sc-full-<run-id>-<p>")`, macOS `tap-text sc-full-<run-id>-<p>`).
3. Press `View NFT`, then go back.
4. Open the card again and press `Close`.

**Expected**
- The tab lists NFTs account A minted: on web only those with an evolving feature (`listMintedNfts` filtered by `canEvolve`), on macOS whatever the CLI's minted list returns. With none it shows `No minted NFTs with management capabilities.`.
- Tapping a card opens the management sheet instead of the detail: buttons `Close` and `View NFT`, heading `Managing sc-full-<run-id>-<p>`, badge `Owned by Me`, `Current Stage: Base`, the section `Manage Evolution`, and rows `0.` (`Name: Base`), `1.` (`Name: Stage One`) and `2.` (`Name: Stage Two`), each with an `Evolve` button; the button on the current row (`0.`, outlined in green) is disabled.
- Row `1.` shows `1 Property`; tapping it opens a sheet with `Mood` / `Happy` and a `Close` button.
- `View NFT` opens the NFT detail; `Close` dismisses the sheet.

**Cleanup:** none.

### TC-SC-028 · Import an NFT by identifier (macOS)
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** On the NFT list. The id of an NFT owned by account A is known (for example `sc-full-<run-id>-web` from the web run).

**Steps**
1. `tap-text "Import NFT"`. The prompt `Smart Contract Identifier` reads `Paste in the smart contract's unique identifier.` with field `Identifier`.
2. `tap-text Submit` with the field empty.
3. Type the id and `tap-text Submit`.

**Expected**
- Step 2: `Identifier is required.` and the prompt stays open.
- Step 3: the toast `Smart Contract imported from network` appears and the NFT is listed in `My NFTs` after a refresh.
- `Import NFT` is not shown on web.

**Cleanup:** none.

## NFT detail

### TC-SC-029 · Copy smart contract id and addresses
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** An owned NFT's detail screen is open (testnet: `sc-basic-<run-id>-<p>`).

**Steps**
1. Press the copy icon in the id chip. Web: `button "Copy smart contract ID"`. macOS: `tap-label "Copy smart contract ID"`.
2. Press the copy icon on the `Owner` card (tooltip `Copy address`; macOS: two controls share this tooltip, see area open question).

**Expected**
- Step 1: the toast `Smart Contract Identifier copied to clipboard`; the clipboard holds the id shown in the chip (check with `pbpaste` on macOS).
- Step 2: the toast `<owner address> copied to clipboard`.

**Cleanup:** none.

### TC-SC-030 · QR code save and open
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** An NFT detail screen is open.

**Steps**
1. Press the QR `Save` icon (web `button "Save"`, macOS `tap-label Save`).
2. Press the QR `Open` icon (web `button "Open"`, macOS `tap-label Open`).

**Expected**
- Web: the browser downloads `qr.png`, a 2048 px QR image. macOS: a PNG named with a timestamp is written to the temporary folder and opens in the default viewer.
- `Open` opens `https://spyglass-testnet.verifiedx.io/nfts/<id>` (mainnet: `https://spyglass.verifiedx.io/nfts/<id>`) in the browser, and the page shows the same NFT.

**Cleanup:** Close the opened tab or viewer.

### TC-SC-031 · Full NFT detail: features, properties, additional assets, stages
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SC-022 passed on this platform; its detail screen is open and reads `Minted`.

**Steps**
1. Read the `Properties:` section.
2. Read `Additional Assets:` and open the `sc-c.png` thumbnail; close the dialog with `Close`.
3. Read `Features:`; press `Reveal Evolve Stages` on the `Evolving` row and read the sheet.

**Expected**
- `Properties:` shows cards `First` / `Edition`, `12` / `Level` and `#00ff00` / `Background` with a green palette icon. On macOS a card with an `Open` link and subtitle `Media Backup URL` also appears; its tooltip is `https://example.com/sc-<run-id>.zip`.
- **Open question:** on macOS, does the Media Backup URL block under the QR code (`Media Backup URL:`, the URL and `Copy URL`) appear for this NFT? It depends on the mint transaction's `BackupURL`; record what shows.
- `Additional Assets:` shows `sc-c.png`. Web: the dialog shows the image, `File Type`, `File Size` and `Download Asset`. macOS: the thumbnail's label is `View asset`, and the dialog shows the image with `Open Folder` and `Open Asset`.
- `Features:` lists `Royalty` (subtitle with `5` and account B's address), `Multi Asset` (`1 asset`) and `Evolving` (a phase count) with a `Reveal Evolve Stages` button. **Open question:** the detail builds the phase count from the compiler's feature data; confirm whether it reads `3 phases` like the creator did.
- The reveal sheet shows rows `0.` Base, `1.` Stage One, `2.` Stage Two with their descriptions; `Stage One` shows `1 Property`.

**Cleanup:** Close the sheet.

### TC-SC-032 · Desktop asset files, thumbnails and assets folder (macOS)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SC-022 passed on macOS; its detail is open.

**Steps**
1. Under the primary asset `tap-text "Open Asset"`.
2. `tap-text "Open Folder"`.
3. From a shell, run `find "$HOME/Library/Application Support/vfx-gui-automation/rbxtest" -path "*Assets*" -name "sc-*.png"`.
4. Open `Manage` (`tap-text Manage`) and, on row `1.`, `tap-text "Open File"`.

**Expected**
- Step 1 opens `sc-a.png` in the default viewer.
- Step 2 opens the NFT's asset folder in Finder.
- Step 3 lists `sc-a.png`, `sc-b.png` and `sc-c.png` under the isolated `AssetsTestNet` folder; nothing is written to the real `~/rbxtest`.
- Step 4 opens `sc-b.png`.
- In the NFT grid the card shows the `sc-a.png` image (loaded by `PollingImagePreview` from the local path).

**Cleanup:** Close the viewer and Finder windows.

### TC-SC-033 · Missing media: associate or call from beacon (macOS)
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** An NFT owned by account A whose media is not on this machine. **Open question:** how to produce one reliably on testnet (for example the web-minted `sc-basic-<run-id>-web` viewed on macOS, or temporarily renaming the file found in TC-SC-032)?

**Steps**
1. Open the NFT detail.
2. Read the primary asset card; `tap-text "Call Media"`.
3. In the sheet, read the two options; `tap-text "Associate Local File"` and pick `sc-a.png` (macOS file pick).

**Expected**
- The asset card reads `Media asset file not found on your machine (<file name>).` and `Please check any other account with the same address for the media.` with a `Call Media` button.
- The sheet offers `Call Media from Beacon` and `Associate Local File` and a `Close` button.
- After associating, the image renders and `Open Folder` and `Open Asset` appear.
- Choosing `Call Media from Beacon` instead shows `Call to beacon process has started.` and the toast `Call to beacon process has started. Please be patient while ALL assets associated with the NFT are called and downloaded.`.

**Cleanup:** none.

### TC-SC-034 · Media play and pause for a video NFT (web)
**Platforms:** Web · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** Logged in on web as account A with at least 2 VFX.

**Steps**
1. Create and mint `sc-video-<run-id>-web` as in TC-SC-009, with `sc-clip.mp4` as the primary asset.
2. Wait up to 3 minutes for the card and open the detail.
3. Press `button "Play"`; wait 3 seconds; press `button "Pause"`.

**Expected**
- The detail shows a video player (up to 300 px tall) with a `Play` button.
- After `Play` the video advances and the button's label changes to `Pause`; after `Pause` it stops and the label is `Play` again.
- The desktop detail has no video player; a video primary asset shows its file type and the `Open Asset` button. **Open question:** is in-app video playback expected on macOS?

**Cleanup:** none.

### TC-SC-035 · Download asset (web)
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** An owned NFT's detail is open on web.

**Steps**
1. Press `button "Download Asset"` under the primary asset.

**Expected**
- The browser downloads the asset file or opens it in a new tab, and the file matches the image shown.

**Cleanup:** none.

### TC-SC-036 · Prove ownership
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** `sc-full-<run-id>-<p>` detail is open.

**Steps**
1. Press `Prove Ownership` (web `button "Prove Ownership"`, macOS `tap-text "Prove Ownership"`).
2. Press `Copy Signature`; then `Close`.

**Expected**
- A dialog `Ownership Verification Signature` reads `Send this ownership validation signature to prove you are the owner.` above a read-only field. On web the value has the form `<address><>...<><signature><><smart contract id>`; on macOS it is the CLI's proof string.
- `Copy Signature` shows the toast `Signature Verification copied to clipboard.`.

**Cleanup:** none.

### TC-SC-037 · View code
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** `sc-full-<run-id>-<p>` detail is open.

**Steps**
1. Press `View Code` if present.

**Expected**
- A sheet shows the contract's Trillium code.
- **Open question:** `View Code` only appears when `nft.code` is set; record on which platforms the minted NFT carries code.

**Cleanup:** Close the sheet.

### TC-SC-038 · Sync media (macOS)
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** `sc-full-<run-id>-mac` detail is open.

**Steps**
1. `tap-text "Sync Media"`.
2. On web (as account A), open the same NFT's detail.

**Expected**
- The desktop shows no error; afterwards the web detail shows the primary and additional assets rather than `NFT assets have not been transferred to the VFX Web Wallet.`.
- **Open question:** `Sync Media` gives no success or failure feedback; should it show a toast?

**Cleanup:** none.

## Evolve and devolve

### TC-SC-040 · Evolve to stage 1
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** TC-SC-022 passed on this platform; `sc-full-<run-id>-<p>` is at `Current Stage: Base` and owned by A (A is also the minter).

**Steps**
1. Open the NFT detail and press `Manage` (web `button "Manage"`, macOS `tap-text Manage`).
2. On row `1.` press `Evolve` (macOS: several `Evolve` buttons share the label, see area open question), and in `Evolve?` (`Are you sure you want to evolve to stage 1?`) press `Evolve`.
3. Close the info dialog with `Close`.
4. Wait up to 3 minutes, reopening `Manage` every 30 seconds, for the current stage to change.

**Expected**
- The toast `Evolve transaction sent successfully!` and the dialog `Evolve transaction sent successfully` (`This screen will reflect the change once the block is crafted and block height has synced with this transaction.`) appear, and the sheet closes.
- Within 3 minutes `Manage` shows `Current Stage: Stage One`, row `1.` is outlined in green and its `Evolve` button is disabled.
- The detail title, image and description switch to `Stage One`, `sc-b.png` and `First evolution`; `Properties:` shows `Mood` / `Happy`.
- The NFT card in `My NFTs` shows the name `Stage One` and the `sc-b.png` image.

**Cleanup:** none (TC-SC-041 devolves it).

### TC-SC-041 · Devolve back to base
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** TC-SC-040 passed on this platform.

**Steps**
1. Open `Manage` on the NFT detail.
2. On row `0.` (Base) press `Evolve` and confirm `Evolve` in `Are you sure you want to evolve to stage 0?`.
3. Close the info dialog and wait up to 3 minutes for the stage to change.

**Expected**
- The same toast and dialog as TC-SC-040.
- `Current Stage: Base` within 3 minutes; the title is `sc-full-<run-id>-<p>` and the image `sc-a.png` again.
- **Open question:** the modal also has `evolve()`/`devolve()` helpers with `Devolve?` / `Are you sure you want to devolve this NFT one stage?` and the toast `Devolve transaction sent successfully!`, but no button calls them. Is devolving through the per-row `Evolve` button the intended UI?

**Cleanup:** none.

## Transfer

### TC-SC-042 · Transfer prompt rejects bad addresses
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** `sc-basic-<run-id>-<p>` detail is open and reads `Minted`.

**Steps**
1. Press Transfer. Web: `button "Transfer"`. macOS: `tap-key nft:transfer`.
2. Press `Continue` with the `VFX Address` field empty.
3. Type `RxNOTAREALADDRESS` and press `Continue`.
4. Type `bad-addr!`.
5. Press `Cancel`.

**Expected**
- The prompt is titled `Transfer NFT` with field `VFX Address`.
- Step 2: `Address or VFX domain required`.
- Step 3: `Invalid Address.`.
- Step 4: only letters, digits and `.` are accepted, so the field reads `badaddr`.
- Step 5 closes the prompt; nothing is sent.

**Cleanup:** none.

### TC-SC-043 · Transfer an NFT to account B
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** `sc-basic-<run-id>-<p>` owned by account A, `Minted`, not listed in an auction house. Account A holds at least 1 VFX. macOS: the media files are on this machine (TC-SC-010 shows the image).

**Steps**
1. Open the NFT detail and press Transfer (web `button "Transfer"`, macOS `tap-key nft:transfer`).
2. Type `TEST_VFX_B_ADDRESS` into `VFX Address` and press `Continue`.
3. macOS only: the prompt `Backup URL (Optional)` (`Paste in a public URL to a hosted zipfile containing the assets.`, field `URL (Optional)`) opens; leave it empty and `tap-text Transfer`.
4. macOS only: in `Confirm Transfer` read the body and `tap-text Send`; then close `Transfer in Progress` with `Okay`.
5. Open NFTs and wait up to 3 minutes, pressing `Refresh` every 30 seconds, for the NFT to leave `My NFTs`.

**Expected**
- Web: after step 2 the toast `NFT Transfer sent successfully to <account B address>!` appears and the detail closes.
- macOS: the confirm body reads `Please confirm you want to send the NFT to "<account B address>".` followed by the warning that a wrong address cannot be recovered. After `Send`, the dialog `Transfer in Progress` asks to keep the wallet open and mentions `sclog.txt`, and the detail closes.
- Right after sending, the card in `My NFTs` shows the overlay `Transferring...` and cannot be opened.
- Within 3 minutes the NFT is no longer in account A's `My NFTs`, and a transfer transaction appears in A's transaction list.

**Cleanup:** none (TC-SC-044 checks receipt).

### TC-SC-044 · Account B receives the transferred NFTs (web)
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** TC-SC-043 passed in the web lane. The macOS lane's NFT reaching the web wallet is covered by `13-cross-platform.md`.

**Steps**
1. On web, log out and log in with `TEST_VFX_B_PRIVKEY` through `VFX Private Key`.
2. Open NFTs and wait up to 3 minutes, pressing `Refresh` every 30 seconds, for `sc-basic-<run-id>-web`.
3. Open it and read `Owner`.

**Expected**
- The NFT is listed in account B's `My NFTs`.
- `Owner` shows account B's address and `Minter Address` shows account A's.
- The primary asset renders, because the NFT was minted on web.

**Cleanup:** Keep B logged in for TC-SC-045, then log out and log back in as account A.

### TC-SC-045 · Transfer Now fetches assets into the web wallet
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no · Phase: cross-platform

**Preconditions:** Logged in on web as account B; an owned NFT's detail shows `NFT assets have not been transferred to the VFX Web Wallet.` (expected for an NFT minted on macOS and sent to the web lane's account B, as in TC-XP-009).

**Steps**
1. Click the `Transfer Now` button (key `nft:transfer_now`; `button "Transfer Now"`).
2. Wait up to 5 minutes, reopening the detail every 30 seconds, for the asset to render.

**Expected**
- The toast `Transfer request has been broadcasted. Your assets should be available soon.` appears.
- Within 5 minutes the primary asset renders with `Download Asset`.
- On failure the toast names the step, for example `Signature not valid` or the assets request error; record the text.
- **Open question:** does the beacon delivery need the macOS wallet that minted the NFT to be running? If yes, keep the desktop app open during this case.

**Cleanup:** Log out and log back in as account A.

### TC-SC-046 · Sender sees the transferred badge
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-SC-043 passed on this platform; logged in as account A.

**Steps**
1. Open NFTs, tab `Manage Minted NFTs`.
2. Open `sc-basic-<run-id>-<p>`.

**Expected**
- The card shows the red badge `Transferred`.
- Web lists only minted NFTs with an evolving feature, so `sc-basic-<run-id>-web` is not expected there; on web this case passes if the NFT is absent and no error shows. **Open question:** should the sender be able to see transferred plain NFTs on web at all, and does the macOS CLI's minted list include `sc-basic-<run-id>-mac` after the transfer?
- If listed, the management sheet shows the badge `Transferred` instead of `Owned by Me`.

**Cleanup:** none.

## Burn

### TC-SC-047 · Burn an NFT
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** `sc-full-<run-id>-<p>` owned by account A, `Minted`, not listed, owner not a vault account. TC-SC-031 to 041 are done.

**Steps**
1. Open the NFT detail and press `Burn` (web `button "Burn"`, macOS `tap-text Burn`).
2. In `Burn NFT?` press `Cancel`.
3. Press `Burn` again and confirm with `Burn`.
4. Wait up to 3 minutes, pressing `Refresh` every 30 seconds.

**Expected**
- The dialog reads `Burn NFT?` / `Are you sure you want to burn sc-full-<run-id>-<p>`; `Cancel` leaves the NFT unchanged.
- After confirming, the toast `Burn transaction sent successfully!` appears and the detail closes.
- macOS: the card immediately shows the overlay `Burned` and cannot be opened; in list view the name ends with `(Burned)`.
- Within 3 minutes the NFT is gone from `My NFTs`, and a burn transaction appears in A's transaction list.
- A vault-owned NFT shows `Vault Accounts cannot burn NFTs`, and a listed NFT shows `This NFT is listed in your auction house. Please remove the listing before burning.`; both are covered only if such NFTs exist from other areas.

**Cleanup:** none.

## NFT Collection Wizard (bulk create)

### TC-SC-048 · Bulk create landing
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On the Smart Contracts landing screen.

**Steps**
1. Web: `fltA11y.click("Mint NFT Collection")` (route `smart-contract/bulk`). macOS: `tap-text "Mint NFT Collection"`.
2. Read the screen.
3. Press `Download Example JSON`, then `Download Example CSV`.

**Expected**
- The screen is titled `Mint NFT Collection` and has two cards: `Collection Wizard` with `Launch Wizard`, and `Upload JSON / CSV` with the explanatory text, `JSON` (`Download Example JSON`, `Upload JSON`) and `CSV` (`Download Example CSV`, `Upload CSV`). macOS shows the wallet selector in the app bar.
- Each download button opens the example file from `firebasestorage.googleapis.com` in the browser.
- **Open question:** do the example files' image URLs still resolve? They are the natural source for TC-SC-055 and 056.

**Cleanup:** Close the browser tabs.

### TC-SC-049 · Wizard instance validation
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On the bulk create screen.

**Steps**
1. Press `Launch Wizard`. The screen `NFT Collection Wizard` shows `Create First Instance`.
2. Press `Create First Instance`. The `Create Instance` screen opens.
3. Press `Save & Close` without filling anything.

**Expected**
- `Invalid Smart Contract` lists `- Name is required`, `- Minter name is required`, `- Description is required` and `- Primary Asset is required`, with `Okay`.
- The instance card shows placeholders `Name`, `Quantity: 1`, `Primary Asset` with `Choose File`, `Creator Name`, `Description`, and sections `Royalty`, `Additional Assets`, `Evolve` and `Properties`.

**Cleanup:** Press `Okay`, then `Delete` → `Delete` in `Delete Instance?` (`Are you sure you want to delete this instance?`).

### TC-SC-050 · Wizard quantity limits
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** A wizard instance is open on `Create Instance`.

**Steps**
1. Press the quantity edit button (tooltip `Quantity to Mint`; web `button "Quantity to Mint"`, macOS `tap-label "Quantity to Mint"`). In the prompt, clear `Quantity` and type `0`; press `Submit`.
2. Open it again, type `150`, press `Submit`.
3. Open it again, type `2`, press `Submit`.

**Expected**
- The field accepts digits only.
- Step 1: the toast `Min quantity is 1.` and the card reads `Quantity: 1`.
- Step 2: the toast `Max quantity is 100.` and the card reads `Quantity: 100`.
- Step 3: `Quantity: 2`.
- An empty submit shows `Quantity is required.`.

**Cleanup:** none.

### TC-SC-051 · Wizard instance with royalty, additional asset, evolve phase and property
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** A new wizard instance is open on `Create Instance`.

**Steps**
1. Press `Add Name` and enter `sc-bulk-<run-id>-<p>-1`; `Add Creator Name` → `QA Runner`; `Add Description` → `Bulk test <run-id>`.
2. Under `Primary Asset` press `Choose File` and pick `sc-a.png`.
3. Press `Add Royalty` (tooltip). In the dialog keep `Royalty Type:` `Percent`, type `5` into `Amount` and `TEST_VFX_B_ADDRESS` into `Address`, then press the `Add Royalty` button (macOS: the dialog title has the same text, see area open question).
4. Press `Add additional asset` and pick `sc-c.png`.
5. Press `Add evolving phase`; in `Evolve Type` choose `Manual Only`; in `Evolving phase` fill `Evolve Stage Name` (`Bulk Stage`), `Evolve Stage Asset` (`sc-b.png`) and `Evolve Stage Description` (`Bulk evolution`), then press `Add evolving phase`.
6. Press `Add property`; in `Property Type` choose `Color`; in `Color Property` set `Property Name` to `Background` and pick a color with `Pick a color` → `Choose`; press `Add property`.
7. Press `Save & Close`.

**Expected**
- The card shows the name, `Creator: QA Runner`, the description, a preview of `sc-a.png` with an `Open asset` button and a `Delete primary asset` button.
- The royalty reads `5.0% to <account B address>`; the additional asset lists `sc-c.png` with a `Remove asset` button; the evolve header reads `Evolve (Manual Only)` with `Phase #1: Bulk Stage`; the property list shows `Background` with the chosen hex value.
- After `Save & Close` the wizard list shows `sc-bulk-<run-id>-<p>-1 (x1)` with a subtitle containing `5.0% Royalty to`, `1 Additional Asset`, `1 Evolve Phase` and `1 Property`.
- Royalty validation matches TC-SC-012 (`Required`, `Must be more than 0%`, `Can not be more than 100%`, `Address required`, `Invalid Address.`).

**Cleanup:** none (used by TC-SC-052 and 054).

### TC-SC-052 · Wizard duplicate, edit, delete and clear
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** TC-SC-051 done; the wizard list shows one instance.

**Steps**
1. Press `Duplicate` on the instance. On the new `Create Instance` screen change the name to `sc-bulk-<run-id>-<p>-2`, set the quantity to `2` and press `Save & Close`.
2. Press `Edit` on the second row, check the title `Edit Instance`, and press `Save & Close`.
3. Press `Create New Instance`, then `Delete` → `Delete` on the empty instance.
4. Press `Clear` at the bottom and then `Cancel` in `Clear NFT Collection Wizard?`.

**Expected**
- After step 1 the list shows `-1 (x1)` and `-2 (x2)`, the second with the same royalty, asset, phase and property.
- Step 3 leaves the list with the same two rows.
- Step 4 asks `Are you sure you want to remove everything?`; `Cancel` keeps both rows. Confirming `Clear` would empty the list and close the wizard; that path is exercised in the cleanup of TC-SC-055 and 056.

**Cleanup:** none (used by TC-SC-054).

### TC-SC-053 · Close the wizard with the confirm dialog
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** The wizard is open with at least one instance.

**Steps**
1. Press the back button (web `button "Back"`, macOS `tap-label Back`) and press `Cancel`.

**Expected**
- The dialog reads `Are you sure you want to close the NFT collection Wizard?` with `All unsaved changes will be lost.`; `Cancel` keeps the wizard and its rows. `Continue` would clear the wizard and return to the bulk screen.

**Cleanup:** none.

### TC-SC-054 · Compile and mint a collection
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** TC-SC-052 done: the wizard lists `sc-bulk-<run-id>-<p>-1 (x1)` and `sc-bulk-<run-id>-<p>-2 (x2)`. Account A holds at least 10 VFX.

**Steps**
1. Press `Compile & Mint` at the bottom of the wizard.
2. In `Compile & Mint Smart Contract?` check the body and press `Continue`; in `Confirm Address` press `Compile & Mint`.
3. Wait up to 5 minutes for the progress dialog `Compiling & Minting` to read `Complete`, then press `Close`.
4. Open NFTs and wait up to 3 minutes, pressing `Refresh` every 30 seconds, for the new NFTs.

**Expected**
- The first dialog reads `Are you sure you want to proceed minting 3 Smart Contract(s)?`; the second `This will be minted by` followed by account A.
- The progress label counts `Minting 1/3...` to `Minting 3/3...`, then `Complete`, with the bar full.
- `My NFTs` then holds one `sc-bulk-<run-id>-<p>-1` and two `sc-bulk-<run-id>-<p>-2`, each with the `sc-a.png` image, royalty, multi asset, evolving and property features.
- Web: closing the progress dialog returns to the bulk create screen.

**Cleanup:** none.

### TC-SC-055 · Import a collection from CSV
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On the bulk create screen. `sc-bulk.csv` in the scratch folder has the header row `Name,Description,Primary Asset URL,Creator Name,Royalty Amount,Royalty Address,Additional Asset URLs,Quantity,Edition` and two rows: `csv-<run-id>-1` and `csv-<run-id>-2`, each with a description, a public HTTPS PNG URL, creator `QA Runner`, royalty `5%` to `TEST_VFX_B_ADDRESS`, no additional assets, quantity `1`, and `Edition` values `First` and `Second`. **Open question:** which stable public PNG URL should the file use? Proposal: add a non-secret `TEST_IMAGE_URL` to the README's test data.

**Steps**
1. Press `Upload CSV` and pick `sc-bulk.csv` (web file pick / macOS file pick).
2. Wait up to 60 seconds (macOS shows the `Importing` log window; web shows the loading overlay).

**Expected**
- macOS: the `Importing` log lists `Creating csv-<run-id>-1...` and `Downloading <url>...` for each row.
- The wizard opens with `csv-<run-id>-1 (x1)` and `csv-<run-id>-2 (x1)`, each subtitle containing `5.0% Royalty to <account B address>` and `1 Property`; the edit screen shows `Edition` with its value.

**Cleanup:** Press `Clear` → `Clear` (do not mint).

### TC-SC-056 · Import a collection from JSON
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On the bulk create screen. `sc-bulk.json` is an array of two objects with keys `name` (`json-<run-id>-1`, `json-<run-id>-2`), `description`, `image` (the same public PNG URL as TC-SC-055), `creator_name` (`QA Runner`), `quantity` (`1` and `2`), `royalty` (`{"amount": "5%", "address": "<TEST_VFX_B_ADDRESS>"}`) and `attributes` (`[{"trait_type": "Background", "value": "#00ff00"}, {"trait_type": "Level", "value": "7"}]`).

**Steps**
1. Press `Upload JSON` and pick `sc-bulk.json`.
2. Wait up to 60 seconds.
3. Open the first row with `Edit`.

**Expected**
- The wizard opens with `json-<run-id>-1 (x1)` and `json-<run-id>-2 (x2)`, subtitles containing `5.0% Royalty to` and `2 Properties`.
- The edit screen shows `Background` detected as a color property (`#00ff00`) and `Level` as a number (`7`).

**Cleanup:** `Save & Close`, then `Clear` → `Clear` (do not mint).

### TC-SC-057 · Bulk import rejects bad files
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** On the bulk create screen. `sc-bad-headers.csv` has the header `Title,Text,Image` and one row. `sc-bad.json` contains `{not json`.

**Steps**
1. Press `Upload CSV` and pick `sc-bad-headers.csv`.
2. Press `Upload JSON` and pick `sc-bad.json`.

**Expected**
- Step 1: the toast `The CSV headers are not in the correct format, please check the example file`; the wizard does not open.
- Step 2: the toast `Invalid JSON`; the wizard does not open.

**Cleanup:** none.

### TC-SC-058 · Unreachable image URL is skipped (macOS)
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** On the bulk create screen. A copy of `sc-bulk.csv` whose first row's `Primary Asset URL` is `https://example.invalid/missing-<run-id>.png`.

**Steps**
1. `tap-text "Upload CSV"` and pick the file.

**Expected**
- The toast `Problem downloading https://example.invalid/missing-<run-id>.png. Skipping.` appears and the log reads the same.
- The wizard opens with only the second row.
- Web does not download the URL at import time (it keeps the URL as the asset location), so this case is desktop only. **Open question:** should web validate the URL before minting?

**Cleanup:** `Clear` → `Clear`.

## Templates, drafts and My Smart Contracts

### TC-SC-059 · Templates chooser is not reachable
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. Look for a templates entry on the Smart Contracts landing screen, in the creator and in the side nav.

**Expected**
- No entry opens `TemplateChooserScreen`: the landing button `Templated Smart Contract` is commented out in `smart_contracts_screen.dart`, and the web router has no templates route.
- **Open question:** is the templates chooser (route `smart-contract-templates`, templates in `lib/features/nft/data/templates.dart`) meant to ship? If yes, it needs an entry point and full cases; if not, the screen and route should be removed.

**Cleanup:** none.

### TC-SC-060 · Drafts cannot be saved, reopened or deleted
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Creator open.

**Steps**
1. Look for `Save as Draft`, `Delete` and a `My Drafts` entry in the creator's app bar and bottom bar.

**Expected**
- The bottom bar has only `Compile & Mint`; `Save as Draft` (`buildSaveButton`), the draft `Delete` button and the `My Drafts` app bar action are commented out, so drafts cannot be saved (`Draft saved!`), reopened or deleted (`Delete Draft` / `Draft Delete`).
- **Open question:** should drafts ship on desktop? `SmartContractDraftsScreen` and `draftsSmartContractProvider` still exist, and `DELETE_DRAFT_ON_MINT` still deletes drafts on compile.

**Cleanup:** none.

### TC-SC-061 · My Smart Contracts list is not reachable
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. Look for a `My Smart Contracts` entry on the landing screen and in the side nav.

**Expected**
- No entry exists; the landing button is commented out. `MySmartContractsScreen` (tabs `Compiled` and `Drafts`, a `Refresh` action, empty states `No Smart Contracts Found` and `No Smart Contracts Drafts Found`) is registered only on the desktop router at `my-smart-contracts`.
- **Open question:** should the compiled list and its refresh ship, or should the screen be removed?

**Cleanup:** none.
