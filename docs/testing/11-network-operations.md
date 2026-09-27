# 11 · Network operations

This area covers the desktop GUI's network-facing tools: the Operations screen (status panel, activity log, network metrics and the maintenance buttons grouped under General, Account Security, Tokens / NFTs and Diagnose), the Validator Pool search, beacons, the latest-block panel that doubles as the in-app block explorer, snapshot import, and the validator, network voting, MOTHER, adjudicator and datanode screens. Almost everything here is macOS only, because the web wallet has no Core CLI; the only web case is the latest-block panel. Several features ship dark in 7.0.2: `VALIDATOR_NAV_ENABLED` is `false` in `lib/core/app_constants.dart`, which removes the Validator side-nav entry and the Validator segment on Operations, and with them the only entry points to the Validator screen, the voting topics and MOTHER. The Adjudicator and Datanode screens have routes but no entry point at all. Those cases are written in full so they can run the day the flag flips, and each says how to record it until then.

## Area preconditions

- macOS cases run against the Flutter Driver build (`make run_macos_driver`) as described in `docs/automation.md`, with the Core CLI running and, unless a case says otherwise, the testnet chain synced (the status-bar sync indicator's tooltip reads `Synced`).
- Account A (`TEST_VFX_A_PRIVKEY`, `TEST_VFX_A_ADDRESS`) is imported and selected as the current VFX account (see `01-launch-auth.md`).
- The driver build runs in debug mode. `widgetGuardWalletIsSynced` lets debug builds through with the toast `Please wait until your wallet is synced with the network. In debug mode, you shall pass.` instead of blocking, so negative "not synced" checks only behave like production in a release build. Cases that depend on the guard say so.
- Validating needs 5,000 VFX (`ASSURED_AMOUNT_TO_VALIDATE`) on one account plus the validator ports open to the internet: 13338, 13339 and 17294 on testnet (3338, 3339 and 7294 on mainnet), from `Env.validatorPort`, `validatorSecondaryPort` and `validatorTertiaryPort`. The isolated automation environment has neither: account A is only guaranteed 200 VFX, and the test machine is behind NAT. Every case that needs an active validator is marked **Cannot run in the isolated automation environment** and names what it needs.
- Operations is reached with `tap-key nav:operations`. Its segmented control shows `General`, `Account Security`, `Tokens / NFTs` and `Diagnose` (plus `Validator` only when `VALIDATOR_NAV_ENABLED` is true); select a segment with `tap-text <label>`.
- Web cases use `http://localhost:42069/?automation=1`, logged in as account A.
- `lib/features/health` (port ping) is only called from the unreachable Adjudicator screen, `lib/features/inspector` is a debug-only no-op, and `lib/features/debug` only writes `Databases/debug-gui.txt` when the snapshot-info fetch fails. None of the three has user-visible UI, so they have no cases of their own.


## Feature gating

### TC-NET-001 · Hidden network features stay hidden
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** App running, any account selected.

**Steps**
1. Expand the side nav if it is collapsed (`tap-key nav:expander`) and take a screenshot of it.
2. Check that no Validator entry exists: `tap-key nav:validator` must fail with a "not found" error from `drive.dart` (exit code 1).
3. `tap-key nav:operations` and screenshot the segmented control.
4. `tap-text Validator` on the Operations screen.

**Expected**
- The side nav shows Dashboard, Vault Accounts, Domains, Send, Receive, Launch BFLY, Transactions, vBTC Tokens, Privacy, Fungible Tokens, Smart Contracts, NFTs, P2P Auctions and Operations, and no `Validator` entry.
- The segmented control shows exactly `General`, `Account Security`, `Tokens / NFTs`, `Diagnose`.
- Step 4 fails with "not found": no `Validator` segment exists, so `Validator Check`, `Validator Pool` (under Validator), `Proposals & Voting` and `MOTHER` are only reachable through the segments listed in later cases.
- There is no control anywhere that opens the Adjudicator (`/adjudicator`) or Datanode (`/datanode`) screens.

**Cleanup:** none.

**Open question:** When `VALIDATOR_NAV_ENABLED` is turned on for a release, should this case flip to asserting the entries are present, and should the Adjudicator and Datanode screens (the Adjudicator's `Start Adjudicating` button only shows a spinner for 750 ms and does nothing; `Stop Adjudicating` has an empty handler; Datanode only shows `Activating soon.`) be deleted instead of kept?

## Operations screen

### TC-NET-002 · Operations status panel shows live CLI status
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** CLI running and synced.

**Steps**
1. `tap-key nav:operations`.
2. `wait-for-text "Peers (In / Out)" --timeout 60` (the card only fills once the CLI has reported wallet info).
3. Screenshot the right-hand status card.
4. Take a second screenshot of the card at least 60 seconds later.

**Expected**
- The app bar title is `Operations`; the left column is headed `Activity Log` and the right column `Status`.
- The status card lists, each value above its small label: `Blockchain Version`, `CLI Version`, `Block Height`, `Peers (In / Out)` with a value of the form `<n> / 10`, `Wallet Started` with a `MM/dd - HH:mm` time, and `Network Metrics` with a `View Metrics` link.
- `Block Height` matches the `Block <height>` tab in the bottom-right latest-block panel and increases between the two screenshots when the chain is producing blocks.
- Under the Discord, GitHub and `Docs` links the version text reads `VFX Wallet [TESTNET]` then `Version Testnet <version> (Switchblade)`, where `<version>` is the build's `APP_V` (7.0.2 at the time of writing). On the mainnet smoke run it reads `VFX Wallet` then `Version Mainnet <version> (Switchblade)`.

**Cleanup:** none.

### TC-NET-003 · Network metrics dialog
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On Operations (TC-NET-002), `View Metrics` visible.

**Steps**
1. `tap-text "View Metrics"`.
2. `wait-for-text "Network Metrics" --timeout 15` (the dialog title; the label in the card has the same text, so confirm the dialog with a screenshot).
3. `tap-text Close`.

**Expected**
- An alert titled `Network Metrics` shows, in monospace: `Block Diff Avg: <value>`, `Block Last Received: <local date-time>`, `Block Last Delay: <value>`, `Time Since Last Block: <n>s`, `Blocks Averaged: <n>`, and `Active Validators: <n>` when the explorer returned a validator count.
- On a healthy testnet `Time Since Last Block` is under 60 seconds.
- `Close` dismisses the dialog.

**Cleanup:** none.

### TC-NET-004 · Operations segments show the expected tools
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On Operations, at least one VFX account in the wallet.

**Steps**
1. `tap-text General`, screenshot.
2. `tap-text "Account Security"`, screenshot.
3. `tap-text "Tokens / NFTs"`, screenshot.
4. `tap-text Diagnose`, screenshot.
5. `tap-text General` again.

**Expected**
- General: `Restart CLI`, `Print Addresses`, `Open DB Folder`, `Import Snapshot`, `Validator Pool`, `Language`.
- Account Security: `Encrypt Wallet` (or `Lock Wallet` / `Unlock Wallet` once encrypted), `Create HD Account`, `Backup`; `Restore HD Account` appears only when the wallet has no accounts.
- Tokens / NFTs: `Verify NFT Ownership`, `Import Media`, `Beacons`.
- Diagnose: `Restart CLI`, `Open DB Folder`, `Open Log`, `Show Debug Data`, `Validator Check`, `Mempool`.
- The selected segment is highlighted and only one segment's buttons show at a time. Buttons that need the CLI (`Restart CLI`, `Print Addresses`, `Import Snapshot`, `Show Debug Data`, `Validator Check`) are disabled while the CLI is not started.

**Cleanup:** none.

**Open question:** The Account Security buttons, `Language`, `Verify NFT Ownership` and `Import Media` are exercised by `01-launch-auth.md`, `02-dashboard-navigation-settings.md` and `09-smart-contracts-nfts.md`. Confirm those files own them so they are not tested twice.

### TC-NET-005 · Print Addresses writes every account to the activity log
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On Operations, General segment. Wallet holds account A, and a BTC account if `04-btc-vbtc.md` has run.

**Steps**
1. `tap-text "Print Addresses"`.
2. `wait-for-text "Wallet Addresses:" --timeout 10`.
3. Screenshot the Activity Log.
4. Tap the copy icon next to account A's line. It has the label `Copy`; if `tap-label Copy` reports "Too many elements", this step is checked visually only.

**Expected**
- The log gains a `Wallet Addresses:` line followed by one line per VFX account in the form `<address> (<balance> VFX)`, Vault accounts as `<address> (Available: <amount> VFX)` in purple with a help icon labelled `Vault Account Balance`, and one line per BTC account as `<address> (<balance> BTC)` in orange.
- The log scrolls to the newest entry.
- Tapping a copy icon shows the toast `<address> copied to clipboard`.

**Cleanup:** none.

**Open question:** The copy icons in log lines all carry the same label (`Copy`), so `drive.dart` cannot target one. Should `LogItem` get a per-line key such as `log:copy:<address>`?

### TC-NET-006 · Footer links open Discord, GitHub and the docs
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On Operations.

**Steps**
1. `tap-label "Join Discord"`.
2. `tap-label GitHub`.
3. `tap-text Docs`.

**Expected**
- The default browser opens `https://discord.gg/7cd5ebDQCj`, `https://github.com/VerifiedXBlockchain` and `https://docs.verifiedx.io` respectively (check the browser's front tab after each step; `drive.dart` cannot see outside the app).
- The app stays on Operations and logs no error.

**Cleanup:** Close the three browser tabs.

### TC-NET-007 · Restart CLI from Operations
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On Operations, General segment, CLI running.

**Steps**
1. `tap-text "Restart CLI"`.
2. In the confirm dialog, `tap-text Cancel`.
3. `tap-text "Restart CLI"` again, then `tap-text Restart`.
4. Wait up to 3 minutes for the CLI to come back: poll `get-text label:"VFX Online"` (the tooltip on the status dot) until it succeeds.

**Expected**
- The dialog is titled `Restart` with the body `Are you sure you want to restart the CLI?` and buttons `Cancel` and `Restart` (destructive, red).
- Cancel closes the dialog and nothing restarts.
- After Restart the CLI status dot goes through `VFX CLI Loading`, and within 3 minutes returns to `VFX Online`; the Activity Log shows the restart and the `Status` card values reappear.
- Account A is still selected and its balance is unchanged afterwards.

**Cleanup:** none.

### TC-NET-008 · Validator Check reports the validating state
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On Operations, CLI running, no account validating.

**Steps**
1. `tap-text Diagnose`.
2. `tap-text "Validator Check"`.
3. `wait-for-text "NO you are NOT Validating" --timeout 15`.
4. `tap-text Close`.

**Expected**
- An info dialog titled `Not Validating ❌` shows `NO you are NOT Validating` in red.
- When the node is validating (only in the setup of TC-NET-016) the dialog is titled `Validating ✅` with `YES you are Validating!` in green.
- If the CLI does not answer, the toast reads `A problem occurred checking your validating status. Please restart your wallet and try again.`

**Cleanup:** none.

### TC-NET-009 · Mempool viewer
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On Operations, Diagnose segment.

**Steps**
1. `tap-text Mempool`.
2. Screenshot the bottom sheet.
3. Close it with the sheet's close button, or `tap-label Close` if that does not match.

**Expected**
- A bottom sheet headed `Mempool` shows either `Mempool is empty.` or a read-only monospace field with the CLI's mempool dump.
- If a send from `03-send-receive-transactions.md` is pending, its hash appears in the dump.

**Cleanup:** none.

### TC-NET-010 · Show Debug Data and copy it
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** On Operations, Diagnose segment, CLI running.

**Steps**
1. `tap-text "Show Debug Data"`.
2. `wait-for-text "Debug Data" --timeout 15`.
3. `tap-text Copy`.
4. Close the dialog with its back arrow (`tap-label Back`) or `tap-text Close`.

**Expected**
- An info dialog titled `Debug Data` shows a green `Copy` button above a selectable monospace block of CLI debug output.
- `Copy` shows the toast `Debug data copied to clipboard`.
- The debug output does not contain any private key (search the screenshot for the start of `TEST_VFX_A_PRIVKEY`; never paste the key into results).

**Cleanup:** none.

### TC-NET-011 · Open Log and Open DB Folder
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** On Operations.

**Steps**
1. `tap-text Diagnose`, then `tap-text "Open Log"`.
2. `tap-text "Open DB Folder"`.

**Expected**
- Open Log opens `rbxlog.txt` from the testnet `DatabasesTestNet` folder in the default text viewer. In an automation build the path is under `~/Library/Application Support/vfx-gui-automation/rbxtest/`, never the real `~/rbxtest`.
- Open DB Folder opens a Finder window on the database folder, again inside the automation data home.
- The app shows no error toast.

**Cleanup:** Close the viewer and Finder windows.

**Open question:** `OpenLogButton` builds the macOS path from `DataHome.fromDocuments(...)`. Confirm on a real run that the automation build opens the isolated folder's log and not the production one, because a wrong path here would expose the real wallet's log.

## Snapshot import (remote info)

### TC-NET-012 · Import Snapshot when the local chain is ahead
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Chain synced past the published snapshot height (the normal state of a synced node).

**Steps**
1. `tap-key nav:operations`, `tap-text General`.
2. `tap-text "Import Snapshot"`.

**Expected**
- The toast reads `Your local blockheight is further along than the snapshot.`
- No dialog opens and the CLI keeps running.
- If the explorer is unreachable the toast reads `Problem fetching snapshot block height. Please try again.`; if the CLI does not report a height it reads `Problem fetching local block height. Please try again.`

**Cleanup:** none.

### TC-NET-013 · Import Snapshot prompt when the local chain is behind
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Fresh automation data folder (delete `~/Library/Application Support/vfx-gui-automation` before launch) so the local height is far below the snapshot. Account A imported so the backup warning appears.

**Steps**
1. Launch the driver build and wait for the CLI to answer (`VFX Online`), but do not wait for sync.
2. If the boot-time snapshot prompt from `01-launch-auth.md` appears, answer `No`.
3. `tap-key nav:operations`, `tap-text General`, `tap-text "Import Snapshot"`.
4. `wait-for-text "Import Snapshot?" --timeout 30`.
5. `tap-text No`.

**Expected**
- The dialog is titled `Import Snapshot?` with the body `You are only at <local> block height locally. The network has a snapshot at <snapshot> block height that will help you sync more quickly.` followed by `Would you like to import it now?`, and buttons `No` and `Import`.
- `No` closes it and nothing is downloaded.

**Cleanup:** none.

### TC-NET-014 · Import Snapshot end to end
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** As TC-NET-013, on a fresh automation data folder only. Never run this against a data folder you want to keep: the import wipes the database folder.

**Steps**
1. Open Import Snapshot as in TC-NET-013 steps 1 to 4 and `tap-text Import`.
2. In the warning dialog `tap-text "I'm Backed Up"`.
3. Wait up to 30 minutes for `wait-for-text "Database Snapshot Imported." --timeout 1800`, taking a screenshot every 5 minutes.
4. `tap-text Close`.
5. Wait up to 5 minutes for `VFX Online`.

**Expected**
- A `Warning` dialog first says `Be sure your private keys are backed up as this process will wipe your database folder.` and offers `Cancel` and `I'm Backed Up`.
- A non-dismissible dialog progresses through `Initializing...`, `Shutting down CLI...`, `Downloading...` with `Downloading: <file> (<n>/<total>)`, and ends on `All done!` with `Database Snapshot Imported.` and `Starting up CLI now...`.
- After Close the CLI restarts, the block height starts at or near the snapshot height, and account A is still in the wallet.
- On failure the dialog title is `Import Failed` with `Snapshot import failed.` and `Please restart and try again.`

**Cleanup:** none (the folder is disposable).

## Validator

### TC-NET-015 · Validator screen below the 5,000 VFX requirement
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Availability:** Not reachable while `VALIDATOR_NAV_ENABLED` is false (TC-NET-001). Record `skipped` with the note "validator nav disabled" until the flag ships on.

**Preconditions:** Account A selected with less than 5,000 VFX; no account validating.

**Steps**
1. `tap-key nav:validator`.
2. Screenshot.

**Expected**
- The app bar reads `Validator`.
- A card shows `Validating requires 5,000 VFX.` in the warning colour, `Please choose another account:`, an account selector without BTC accounts, and `Or transfer <shortfall> VFX to <account A address>.` where the shortfall is 5,000 minus A's balance rounded up.
- No `Start Validating` button is shown.

**Cleanup:** none.

### TC-NET-016 · Start validating
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** yes

**Availability:** Not reachable while `VALIDATOR_NAV_ENABLED` is false. **Cannot run in the isolated automation environment:** needs an account holding at least 5,000 testnet VFX and ports 13338, 13339 and 17294 forwarded to the test machine.

**Preconditions:** A testnet account with at least 5,000 VFX selected, chain synced, ports open, validator name `qa-<run id>` not taken.

**Steps**
1. `tap-key nav:validator`.
2. Check the instruction text, then `tap-key validator:start`.
3. If the wallet is encrypted, enter `TEST_ENCRYPTION_PASSWORD` in the password prompt.
4. In the `Name your validator` prompt, tap the field and `type qa-<run id>`, then `tap-text Submit`.
5. Wait up to 2 minutes for `wait-for-text "Validating..." --timeout 120`.

**Expected**
- Before starting, the card reads `You must have port 13338, 13339, and 17294 open to external networks with a balance of 5,000 VFX in order to validate.` above a green `Start Validating` button.
- After Submit a global loader shows, then the toast `qa-<run id> [<account label>] is now validating.`
- The screen switches to the active state: a rotating gear with `Validating...`, `Address: <label>`, the validator name in brackets, a `Stop Validating` button and `Blocks Validated (<n>)`.
- A green `Validating...` banner with a rotating gear appears in the app shell.

**Cleanup:** TC-NET-021 stops validating.

**Open question:** Does the CLI's `StartValidating` broadcast a signed registration transaction? The case is marked "Moves funds: yes" to keep it testnet-only until that is confirmed. We also need a funded validator account and a machine with open ports: can the README gain `TEST_VALIDATOR_PRIVKEY` / `TEST_VALIDATOR_ADDRESS` and a note on which host runs these cases?

### TC-NET-017 · Validator name is required
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Availability:** As TC-NET-016 (flag and 5,000 VFX account).

**Preconditions:** As TC-NET-016, up to the name prompt.

**Steps**
1. Reach the `Name your validator` prompt as in TC-NET-016 steps 1 to 3.
2. Leave the field empty and `tap-text Submit`.
3. `tap-text Cancel`.

**Expected**
- The field shows `Validator Name is required.` and the prompt stays open.
- Cancel closes the prompt without starting validation; the screen still shows `Start Validating`.

**Cleanup:** none.

### TC-NET-018 · Start validating blocked while not synced or already validating elsewhere
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** As TC-NET-016. The sync half only behaves like production in a release build (see Area preconditions).

**Preconditions:** Part A: a release build with the chain still syncing. Part B: a second account in the wallet while the first is validating.

**Steps**
1. Part A: `tap-key validator:start` while the sync indicator reads `Syncing...`.
2. Part B: select the non-validating account and open Validator.

**Expected**
- Part A: toast `Please wait until your wallet is synced with the network`, and nothing else happens. In the debug driver build the toast is `Please wait until your wallet is synced with the network. In debug mode, you shall pass.` and the flow continues.
- Part B: the screen shows a warning icon, `<label> can not validate.` and `You can only validate with one account.`

**Cleanup:** none.

### TC-NET-019 · Validator name already taken
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** As TC-NET-016.

**Preconditions:** As TC-NET-016, and the name of an existing testnet validator.

**Steps**
1. Start validating as in TC-NET-016 but submit the existing validator's name.

**Expected**
- The toast reads `Node name already taken.` and the screen stays on `Start Validating`.

**Cleanup:** none.

**Open question:** Which existing testnet validator name should this use? Proposed variable `TEST_EXISTING_VALIDATOR_NAME` (not secret; it could also live in the case).

### TC-NET-020 · Rename the validator
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** As TC-NET-016; needs an active validator.

**Preconditions:** TC-NET-016 passed and the validator name shows in brackets.

**Steps**
1. `tap-label "Rename Validator"`.
2. Leave the field empty and `tap-text Submit`.
3. Type `qa-<run id>b` and `tap-text Submit`.
4. In the `Restart CLI` dialog `tap-text Cancel`.
5. Repeat steps 1 and 3 with `qa-<run id>c`, and this time `tap-text Restart`.
6. Wait up to 3 minutes for `VFX Online`, then reopen Validator.

**Expected**
- The prompt is titled `Validator Name` with the field `New Validator Name`; an empty submit shows `Name is required.`
- A valid rename shows the toast `Validator name changed to qa-<run id>b.` and then the dialog `Restart CLI` with the body `In order for the name to be reflected,`, `a restart of the CLI is required.`, `Restart now?` and buttons `Cancel` / `Restart`.
- Restart shows the toast `Restarting CLI...`; after the CLI returns the bracketed name reads `[qa-<run id>c]`.

**Cleanup:** none.

### TC-NET-021 · Stop validating
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Availability:** As TC-NET-016; needs an active validator.

**Preconditions:** TC-NET-016 passed.

**Steps**
1. `tap-key validator:stop`.
2. `tap-text Cancel`.
3. `tap-key validator:stop`, then `tap-text Stop`.
4. Wait up to 1 minute for the start card: `wait-for-text "Start Validating" --timeout 60`.

**Expected**
- The confirm dialog is titled `Stop Validating` with `Are you sure you want to stop validating?` and a red `Stop` button; Cancel leaves the validator running.
- After Stop the toast reads `<label> has stopped validating.`, the shell banner disappears, and the screen returns to the start card.
- `Validator Check` (TC-NET-008) now reports `NO you are NOT Validating`.

**Cleanup:** none.

### TC-NET-022 · Not-validating state and Check Again
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** As TC-NET-016.

**Preconditions:** The account is flagged as validating by the CLI but `IsValidating` returns false (for example right after a CLI restart, before the validator reconnects).

**Steps**
1. Open Validator.
2. `tap-key validator:check_again` every 10 seconds, up to 2 minutes, until the active state appears.

**Expected**
- The screen shows `<label> is NOT Validating...` and a `Check Again` button.
- Once the CLI reports validating again the active card replaces it without leaving the screen.

**Cleanup:** none.

**Open question:** How can this state be produced on purpose? Without a reliable trigger the case is opportunistic: run it only if the state appears during TC-NET-016 to TC-NET-021.

### TC-NET-023 · Validated blocks list and block detail
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** As TC-NET-016; needs a validator that has crafted at least one block, which can take hours on testnet.

**Preconditions:** Active validator with at least one validated block.

**Steps**
1. Open Validator and scroll the `Blocks Validated (<n>)` strip.
2. Tap the first block card (`tap-text <height with thousands separators>`).
3. Screenshot, then close the dialog.

**Expected**
- With no blocks the strip reads `No Validated Blocks`.
- Each card shows the height with thousands separators and a `MM-dd-yyyy hh:mm a` time.
- Tapping a card opens a dialog titled `Block <height>` with the latest-block fields from TC-NET-043 for that block.

**Cleanup:** none.

## Validator Pool

### TC-NET-024 · Search the Validator Pool by exact name
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** CLI running, explorer reachable.

**Steps**
1. `tap-key nav:operations`, `tap-text General`, `tap-text "Validator Pool"`.
2. The search field is autofocused; `type <validator name>`.
3. `tap-label Search`.
4. Screenshot the result card.

**Expected**
- The app bar reads `Validator Pool` with a back button (`Back`) and the account selector.
- The field hint is `Search by validator name...` with the note `* Must be the name exactly` under it.
- One card appears with an `Active` (green) or `Inactive` (red) badge, the validator name, its address, `Connection Date: <date>` and `Blocks: <n>`.

**Cleanup:** none.

**Open question:** Which validator name should the search use on testnet and on mainnet? Proposed variables `TEST_EXISTING_VALIDATOR_NAME` and `MAINNET_VALIDATOR_NAME` (public values, not secrets).

### TC-NET-025 · Validator Pool search with no match, clear and back
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** On Validator Pool.

**Steps**
1. Tap the search field, `type qa-<run id>-none`, `tap-label Search`.
2. `tap-label Clear`.
3. `tap-label Back`.

**Expected**
- The toast reads ``No validator found with name `qa-<run id>-none`.`` and no card is shown.
- Clear empties the field and removes any result cards.
- Back returns to the Dashboard.

**Cleanup:** none.

### TC-NET-026 · Validator Pool lists the wallet's own validator addresses
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** On Validator Pool; the wallet has at least one address the CLI reports from `GetValidatorAddresses`.

**Steps**
1. Screenshot the lower half of the screen.

**Expected**
- A `Validator` heading lists each of the wallet's validator addresses with an `Active` or `Inactive` badge.
- With no validator addresses the heading is absent.

**Cleanup:** none.

**Open question:** `loadMasterNodes()` and `loadPeerInfo()` are commented out in `SessionProvider.mainLoop`, so the `Peer Info` strip (`IP:`, `Height:`, `Latency:`, `Last Checked:`) and the per-node cards (`Connected: <date>`, `Wallet Version: <v>`) can never appear. Is that intended, or should the case expect them?

## Beacons

### TC-NET-027 · Beacon list
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** CLI running.

**Steps**
1. `tap-key nav:operations`, `tap-text "Tokens / NFTs"`, `tap-text Beacons`.
2. Screenshot.

**Expected**
- The app bar reads `Beacons` with a `Back` button and two actions, `Add Remote Beacon` and `Create / Host Beacon`.
- With no beacons the body reads `No Beacons`. Otherwise each beacon is a card with a satellite icon (remote) or wifi icon (hosted by this wallet), the name plus `[Private]` when private, the IP label, a `Remote` badge or an `Active` / `Inactive` badge for the wallet's own beacon, and a `⋮` menu.
- The wallet's own beacon has a second line `Auto Delete Assets: Yes|No | Asset Cache: <n> Days|Infinite`.

**Cleanup:** none.

### TC-NET-028 · Add Remote Beacon validation
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On Beacons.

**Steps**
1. `tap-key beacon:add_remote`.
2. `tap-key beacon:add_submit` with all fields empty.
3. `tap-key beacon:add_name`, `type qa-<run id>!`; `tap-key beacon:add_ip`, `type 1.2.x`; screenshot the fields.
4. Tap `Cancel`.

**Expected**
- The sheet shows `Add Beacon`, the explanation starting `Add an existing beacon to foreign nodes to use that relay instead of default ones on the VFX network.`, and fields `Beacon Name`, `IP Address`, `Port (leave blank for default)`.
- An empty submit shows `Beacon Name is required.` and `IP Address is required.`
- The name field keeps only letters and digits (the `-` and `!` are dropped), the IP field keeps only digits and dots (the `x` is dropped), and the port field keeps only digits.
- Cancel clears the form and closes the sheet; reopening it shows empty fields.

**Cleanup:** none.

### TC-NET-029 · Add and remove a remote beacon
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On Beacons, the IP and port of a reachable testnet beacon.

**Steps**
1. `tap-key beacon:add_remote`.
2. `tap-key beacon:add_name`, `type qa<run id>`; `tap-key beacon:add_ip`, type the beacon IP; if it uses a non-default port, `tap-key beacon:add_port` and type it.
3. `tap-key beacon:add_submit`.
4. `wait-for-text "qa<run id> " --timeout 30` (the title includes a trailing space when not private), screenshot.
5. Open the card's `⋮` menu and `tap-text Remove`.
6. `tap-text Cancel`, then repeat step 5 and `tap-text Remove` in the dialog.

**Expected**
- After submit the sheet closes and the list shows `qa<run id>` with a `Remote` badge and the IP.
- The remove dialog is titled `Remove Beacon` with `Are you sure you want to remove this beacon?`, and buttons `Cancel` / `Remove` (destructive).
- Cancel keeps the beacon; Remove deletes it from the list without a CLI restart.
- If the CLI rejects the add, the overlay error shows the CLI's message, or `A problem occurred` when it gave none.

**Cleanup:** The beacon is removed in step 6.

**Open question:** Which remote beacon should this use? Proposed variables `TEST_REMOTE_BEACON_IP` and `TEST_REMOTE_BEACON_PORT` (public, not secret). The `⋮` menu has no key or tooltip, so `drive.dart` cannot open it by key; should `BeaconContextMenu` get a `Key('beacon:menu:<id>')` and a tooltip?

### TC-NET-030 · Create / Host Beacon validation
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On Beacons; the wallet does not host a beacon yet.

**Steps**
1. `tap-key beacon:create_host`.
2. Clear `beacon:create_name` if needed and `tap-key beacon:create_submit`.
3. Type letters into `beacon:create_port` and `beacon:create_retain_days`.
4. Tap `Cancel`.

**Expected**
- The sheet shows `Create Beacon`, the explanation starting `Create a beacon if you want to be the owner of the relay of assets.`, fields `Beacon Name`, `Port (leave blank for default)`, `Days to retain files (0 for unlimited)` (prefilled `0`), and checkboxes `Make Private` and `Auto Delete After Download`.
- An empty submit shows `Name is required.`
- Port and retain-days accept digits only.
- Cancel clears the form and closes the sheet.

**Cleanup:** none.

### TC-NET-031 · Create a hosted beacon, then remove it
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** On Beacons, no hosted beacon, account A selected with a few VFX. The beacon will show `Inactive` in the automation environment because the beacon port is not reachable from outside; that is expected.

**Steps**
1. `tap-key beacon:create_host`.
2. `tap-key beacon:create_name`, `type qa<run id>host`; leave port blank and retain days `0`; tick `Make Private` (`tap-text "Make Private"`).
3. `tap-key beacon:create_submit`.
4. In the `Beacon Created` dialog `tap-text Later`.
5. Screenshot the list.
6. `tap-key beacon:create_host` again.
7. Open the hosted beacon's `⋮` menu, `tap-text Remove`, and in the dialog `tap-text "Remove & Restart CLI"`.
8. Wait up to 3 minutes for `VFX Online`.

**Expected**
- After submit the dialog `Beacon Created` reads `A CLI restart is required for this to take effect.` and `Restart Now?` with `Later` and `Restart`.
- The list shows `qa<run id>host [Private]` with the wifi icon, an `Active` or `Inactive` badge, and `Auto Delete Assets: No | Asset Cache: Infinite`.
- Step 6 shows the toast `Only one beacon per wallet allowed.` and no sheet opens.
- Removing a hosted beacon uses the body `Are you sure you want to remove this beacon?` plus `A CLI restart is required.`, and after confirming the CLI restarts and the beacon is gone.

**Cleanup:** Step 7 removes the beacon.

**Open question:** `BeaconFormProvider.submit` calls `notifyTransactionSubmitted()` after `CreateBeacon`. Does creating a beacon broadcast a transaction? Marked "Moves funds: yes" until confirmed. Also, should a restart be run in step 4 (`Restart`) instead of `Later` to cover that branch, given it costs another 1 to 3 minutes?

## Network voting

### TC-NET-032 · Voting topics list, tabs, view toggle and search
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Availability:** Only reachable from the Validator segment's `Proposals & Voting` button, which is hidden while `VALIDATOR_NAV_ENABLED` is false. Record `skipped` until then.

**Preconditions:** CLI running and synced.

**Steps**
1. `tap-key nav:operations`, `tap-text Validator`, `tap-text "Proposals & Voting"`.
2. Tap each tab: `Active`, `Inactive`, `Voted`, `Not Voted`, `All`, `My Topics`.
3. `tap-label "Grid view"`, screenshot, then `tap-label "List view"`.
4. `tap-label Search`, type part of a known topic name, screenshot, close the sheet.

**Expected**
- The app bar reads `Validator Voting Topics` with `Back`, `Create Topic`, a search icon and the view toggle.
- Each tab shows its topics; list rows show an article icon, the name, a one-line description (or the nominated address for `Adj Vote In` topics) and a category badge. Grid cards show yes/no percentages.
- The search sheet (`Search...`) lists matching topics as you type and tapping one opens its detail.

**Cleanup:** none.

### TC-NET-033 · Create Topic is refused for a non-validator
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** As TC-NET-032.

**Preconditions:** Account A selected, not validating.

**Steps**
1. On the topics list, `tap-key voting:create_topic`.

**Expected**
- The toast reads `Your active account must be a validator to create a topic.` and no form opens.
- For a validator that already has an active topic the toast is `Only one active topic per address is allowed.`; with a balance under 1,002 VFX it is `Balance will not be sufficent to validate due to the cost of creating a topic (1 VFX + fee)` (spelling as shipped).

**Cleanup:** none.

### TC-NET-034 · Create Topic form validation and discard
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** As TC-NET-032, plus an active validator (TC-NET-016). **Cannot run in the isolated automation environment.**

**Preconditions:** Active validator with at least 5,010 VFX.

**Steps**
1. `tap-key voting:create_topic`.
2. Leave name and description empty, `tap-key voting:create_topic_submit`, confirm the cost dialog with `Create`.
3. Open the `Category` dropdown and choose `Adj Vote In`; screenshot; switch back to `General`.
4. Open the `Voting Ends` dropdown and check the options.
5. `tap-key voting:create_topic_cancel`, answer `No`, then cancel again and answer `Yes`.

**Expected**
- The screen is titled `Create Topic`; the name field `Topic Name` counts `<n>/128` with `128 character limit`, and the description `Topic Description` counts `<n>/1600` with `1,600 character limit including provided links`.
- Submit first shows `Create Topic` / `There is a cost of 10.0 VFX to create a topic.` with `Cancel` and `Create`; with empty fields the form then shows `Name is required.` and `Description is required.`
- Category offers General, Code Change, Add Developer, Remove Developer, Network Change, Adj Vote In, Adj Vote Out, Validator Change, Block Modify, Transaction Modify, Balance Correction, Hack or Exploit Correction, Other. Choosing `Adj Vote In` replaces the description with the adjudicator form (VFX address to nominate, IP address, machine provider, OS, machine type, CPU, cores, threads, RAM, HD size, bandwidth, technical background, reason, GitHub and additional links).
- Voting Ends offers `30 Days`, `60 Days`, `90 Days`, `180 Days`.
- Cancel asks `Discard` / `Are you sure you want to discard this new topic?`; `No` keeps the form, `Yes` clears it and returns to the list.

**Cleanup:** none.

### TC-NET-035 · Create a General topic
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** yes

**Availability:** As TC-NET-034. **Cannot run in the isolated automation environment.**

**Preconditions:** Active validator with at least 5,010 VFX.

**Steps**
1. `tap-key voting:create_topic`.
2. Category `General`, Voting Ends `30 Days`, name `qa-<run id> topic`, description `Release test topic <run id>`.
3. `tap-key voting:create_topic_submit`, enter `TEST_ENCRYPTION_PASSWORD` if prompted, then `tap-text Create`.
4. Wait up to 2 minutes for the topic to appear under `My Topics`.

**Expected**
- The toast reads `Topic created` and the screen returns to the list.
- Within 2 minutes the topic is listed under `My Topics` and `Active`, and the account balance drops by 10 VFX plus the fee.
- With less than 5,010 VFX the submit is refused with `Submitting a topic costs 10.0 VFX. Since you are validating, you need at least 5010.0 VFX.`

**Cleanup:** The topic expires on its own after 30 days; nothing to remove.

### TC-NET-036 · Topic detail
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Availability:** As TC-NET-032.

**Preconditions:** At least one topic in `All`.

**Steps**
1. Tap a topic row.
2. Screenshot the whole detail (scroll if needed).
3. `tap-text "Show History"` if there are votes, then close the sheet.

**Expected**
- The app bar shows the topic name; the body shows the name, a category badge, `UID: <uid>`, date cards `Topic Created` and `Voting Ends`, `Block Height: <n>`, `Topic Owner: <address>`, and the description (or the adjudicator details for `Adj Vote In`).
- The voting details show `No votes yet.` or `Vote Counts` (`Votes Yes`, `Votes No`, `Total Votes`), `Percentages`, and `Result` reading `In Progress` for active topics or `Pass` / `Fail` for ended ones.
- For a non-validator the vote area reads `You must be a validator to vote.`; for an ended topic `Voting Ended on <date>.`; with no account selected `Must have an account selected to vote.`
- Show History lists each vote's address, `Block <height>` and a Yes/No badge.

**Cleanup:** none.

### TC-NET-037 · Vote Yes on a topic
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** yes

**Availability:** As TC-NET-034. **Cannot run in the isolated automation environment.**

**Preconditions:** Active validator; an active topic it has not voted on.

**Steps**
1. Open the topic detail.
2. `tap-key voting:vote_yes`, `tap-text Cancel`.
3. `tap-key voting:vote_yes`, enter the password if prompted, `tap-text "Vote YES"`.
4. Wait up to 2 minutes, reopening the topic, until the pending message changes to the block message.

**Expected**
- Above the buttons: `Cast Your Vote`; under them `Voting ends <date>.`
- The dialog is `Confirm Vote [YES]` / `Are you sure you want to vote YES on this topic?` with `Cancel` and `Vote YES`; Cancel sends nothing.
- After confirming the toast reads `Vote Casted [YES]` and the vote area reads `Vote transaction pending.`, later `You voted Yes. Transaction is pending.`, and within 2 minutes `You voted Yes on block <height>`.
- The topic moves from `Not Voted` to `Voted`.

**Cleanup:** none.

### TC-NET-038 · Vote No on a topic
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** yes

**Availability:** As TC-NET-037.

**Preconditions:** Active validator; a different active topic it has not voted on.

**Steps**
1. Open the topic detail, `tap-key voting:vote_no`, enter the password if prompted, `tap-text "Vote NO"`.
2. Wait up to 2 minutes as in TC-NET-037.

**Expected**
- The dialog is `Confirm Vote [NO]` / `Are you sure you want to vote NO on this topic?`.
- The toast reads `Vote Casted [NO]`, followed by the pending and block messages with `No`.

**Cleanup:** none.

## MOTHER

### TC-NET-039 · MOTHER modal status
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** The `MOTHER` button only exists in the hidden Validator segment. Record `skipped` while `VALIDATOR_NAV_ENABLED` is false.

**Preconditions:** CLI running.

**Steps**
1. `tap-key nav:operations`, `tap-text Validator`, `tap-text MOTHER`.
2. If prompted, enter `TEST_ENCRYPTION_PASSWORD`.
3. Screenshot, then `tap-text "What is MOTHER?"`, read, close, and `tap-text Close`.

**Expected**
- The sheet shows `Monitor Of The Roster`, `MOTHER is a tool for monitoring the state of your remote validators.`, a `Close` button, a `Status` heading with `Is Host: NO` and `Is Remote: NO` on a fresh wallet.
- Options: `Set Wallet as Host`, `Set Wallet as Remote`, `What is MOTHER?`.
- The info dialog is titled `Monitor Of The Roster` and ends with `Note: you must have port '13338' open on the HOST machine.`

**Cleanup:** none.

### TC-NET-040 · Set wallet as MOTHER host
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** yes

**Availability:** As TC-NET-039. **Cannot run in the isolated automation environment** in any useful way: the host needs the validator port open for remotes to connect.

**Preconditions:** MOTHER sheet open, wallet not a host.

**Steps**
1. `tap-text "Set Wallet as Host"`.
2. Submit empty (`tap-text Create`).
3. `Host Name` = `qa<run id>`, `Create Password` = `TEST_ENCRYPTION_PASSWORD`, `tap-text Create`.
4. In `CLI Restart Required`, `tap-text Restart` and wait up to 3 minutes for `VFX Online`.
5. Reopen MOTHER, `tap-text "Launch MOTHER"`, then `tap-text "Open in Browser"`.

**Expected**
- The dialog `Set Wallet as Host` shows `You must have port '13338' open on the HOST machine.`; empty submit shows `Name Required` and `Password Required`.
- A valid submit shows the toast `Host Created` and the `CLI Restart Required` / `Would you like to restart now?` dialog.
- After restart the sheet shows `Is Host: YES`, `Children: <n>`, and the options `Launch MOTHER`, `Update Host Info`, `Stop Host`.
- `Launch MOTHER` opens `MOTHER Dashboard` listing child cards (`Balance`, `IP Address`, `Block Height`, `Is Validating?`, `Is Connected to Mother?`, `Open in Explorer`); `Open in Browser` opens `http://localhost:<api port>/mother`.

**Cleanup:** TC-NET-041.

**Open question:** Does the MOTHER host setup sign a transaction (the stop path calls `notifyTransactionSubmitted()`)? Marked "Moves funds: yes" until confirmed.

### TC-NET-041 · Stop MOTHER host
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** yes

**Availability:** As TC-NET-040.

**Preconditions:** Wallet is a MOTHER host.

**Steps**
1. Open MOTHER, `tap-text "Stop Host"`, `tap-text Cancel`.
2. `tap-text "Stop Host"`, `tap-text Stop`, then `tap-text Restart` and wait up to 3 minutes for `VFX Online`.

**Expected**
- The dialog is `Stop MOTHER Host?` / `Are you sure you want to stop running this wallet as a MOTHER host?`.
- After restart the sheet shows `Is Host: NO`.

**Cleanup:** none.

### TC-NET-042 · Set wallet as MOTHER remote, then stop
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** As TC-NET-039. **Cannot run in the isolated automation environment:** needs a reachable MOTHER host.

**Preconditions:** MOTHER sheet open; IP and password of a running host.

**Steps**
1. `tap-text "Set Wallet as Remote"`, submit empty with `tap-text Add`.
2. Fill `IP Address of HOST` and `Password set on HOST`, `tap-text Add`, then `Restart`.
3. After `VFX Online`, reopen MOTHER, `tap-text "Stop Remote"`, confirm with `Stop Remote & Restart CLI`.

**Expected**
- The dialog `Add Host` reads `Set the IP address and password set of your MOTHER HOST.`; empty submit shows `IP Address Required` and `Password Required`.
- After restart the sheet shows `Is Remote: YES` and `Stop Remote`.
- Stopping asks `Are you sure you want to remove this node as a REMOTE?` plus `A CLI restart will be required.`, removes the `MotherAddress` and `MotherPassword` lines from the CLI config, restarts the CLI and shows `REMOTE node has been removed from MOTHER`.

**Cleanup:** Step 3.

**Open question:** Which host should remote tests join? Proposed variables `TEST_MOTHER_HOST_IP` and `TEST_MOTHER_HOST_PASSWORD` (the password is a secret and belongs in `accounts.env`).

## Latest block panel (block explorer)

### TC-NET-043 · Latest block panel details
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Logged in (web) or CLI running (macOS), with at least one block received.

**Steps**
1. Find the `Block <height>` tab at the bottom right of the shell. Web: read it from `read_page` or `fltA11y.list()`. macOS: `get-text text:"Block <height>"` is not usable without the height, so screenshot the corner.
2. Expand the panel by hovering over the tab. Web: move the mouse over the tab with the Chrome extension's mouse-move action. macOS: `drive.dart` has no hover command, so read the panel's fields while collapsed with `get-text` (they are built off-screen): `get-text text:"Validated By"` must succeed.
3. Screenshot the expanded panel (web) and move the mouse away.

**Expected**
- The tab reads `Block <height>` and, on macOS, carries two status indicators whose tooltips read `VFX Online` and one of `BTC Online` / `BTC Loading` / `BTC Offline`, plus the sync bar (`Synced`, `Syncing...` or `Resyncing...`).
- Hovering slides up a panel with `Hash` (and a relative time such as `a minute ago`), `Craft Time` (`<n> seconds`), `Size`, `# of Txs`, `Total Amount` and `Total Reward` in VFX, `Validated By` with the validator address, and the links `VFX Explorer` and `BTC Explorer`.
- Moving the mouse away slides the panel back down.

**Cleanup:** none.

**Open question:** Can `drive.dart` gain a `hover <finder>` command so the macOS half can expand the panel instead of reading off-screen widgets?

### TC-NET-044 · Latest block transaction list
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Panel expanded (TC-NET-043) on a block with at least one transaction. Sending VFX in `03-send-receive-transactions.md` right before this case makes one likely on testnet.

**Steps**
1. Click `View Txs` (web: `fltA11y.tap("View Txs")`; macOS: not reachable without hover, see TC-NET-043).
2. Screenshot the bottom sheet and dismiss it.

**Expected**
- `View Txs` only appears when the block has transactions.
- The sheet lists each transaction as `<from> => <to>`, `Hash: <hash>`, and `<amount> VFX`.

**Cleanup:** none.

### TC-NET-045 · Explorer links from the latest block panel
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Panel expanded (web).

**Steps**
1. Click `VFX Explorer`.
2. Return and click `BTC Explorer`.

**Expected**
- On testnet `VFX Explorer` opens `https://spyglass-testnet.verifiedx.io` and `BTC Explorer` opens `https://mempool.space/testnet4/`.
- On mainnet they open `https://spyglass.verifiedx.io` and `https://mempool.space/`.
- Both open in a new tab or the default browser; the wallet stays where it was.

**Cleanup:** Close the opened tabs.
