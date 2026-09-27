# 05 · Privacy (PRISM)

This area covers the PRISM privacy layer on the desktop GUI: the PLONK proof-system status gate, activating a shielded (`zfx_`) wallet, the privacy password and its unlock and auto-lock, the dashboard (shielded address, shielded balance, note count, last scanned block, commitments list), the four VFX actions (shield, unshield, private transfer, consolidate), the settings menu (export and import viewing key, resync, reset), and the vBTC variants of every action. Privacy is desktop-only: the side-nav entry is built only when `!kIsWeb` and the route exists only in `AppRouter`. Every call goes to the local Core CLI under `/privacyapi/PrivacyV1` (`GetPlonkStatus`, `CreateShieldedAddressFromAccount`, `ShieldVFX`, `UnshieldVFX`, `PrivateTransferVFX`, `ConsolidateShieldedVFX`, `GetShieldedBalance`, `ExportViewingKey`, `ImportViewingKey`, `ResyncShieldedWallet`, and the `...VBTC` equivalents). The vBTC variants are compiled in but hidden while `VBTC_PRIVACY_ENABLED` is `false` (shielded vBTC is disabled in the CLI); their cases are kept so they can run the day the flag flips, and are recorded as skipped until then.

## Area preconditions

- macOS Flutter Driver build as in `README.md`, chain synced, account A (`TEST_VFX_A_PRIVKEY`) imported and selected as the current wallet with at least 5 testnet VFX.
- The CLI has finished loading the PLONK parameters (see TC-PRV-001). A clean automation data folder downloads about 250 MB on first launch, so run TC-PRV-001 first and allow for it.
- Privacy password: the suite uses the value of `TEST_ENCRYPTION_PASSWORD` as the privacy wallet password. It is typed only into the local app.
- The app keeps one shielded address per GUI (local storage key `PRISM_ZFX_ADDRESS`), created from the wallet selected at activation. A private transfer needs a second `zfx_` address; TC-PRV-004 records account B's, and TC-PRV-005 switches back to account A.
- VFX blocks land about every 12 seconds. A privacy transaction also needs a proof, and the dashboard polls the shielded balance every 30 seconds, so allow up to 3 minutes for a shielded balance to reflect a confirmed transaction. The dashboard adjusts the shown balance at once after a send and ignores a lower interim value for 90 seconds.
- Every privacy transaction costs a fixed `0.000003 VFX` fee. Shielding pays the normal transparent network fee instead; unshield, private transfer and consolidate take the fee from the shielded VFX balance.
- Dialog buttons without keys are tapped by text (`tap-text Yes`). Where `drive.dart` reports "Too many elements" because the same text is elsewhere on screen, record the step as blocked with that note.

## Status and activation

### TC-PRV-001 · PLONK parameters and the privacy status gate
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** A clean automation data folder (delete `~/Library/Application Support/vfx-gui-automation` first), so the CLI has to download the PLONK parameters. Allow up to 30 minutes on a normal connection.

**Steps**
1. Launch the driver build and wait for the boot screen to finish.
2. Open Privacy: `tap-key nav:privacy` (the nav item reads `Privacy` with a new badge).
3. Read the screen: `get-text text:"Privacy Layer Starting Up"`, or `get-text text:"Checking privacy layer status..."` if the first status call has not returned.
4. Wait for the screen to change, checking every minute, up to 30 minutes. The GUI re-polls `GetPlonkStatus` every 15 seconds while privacy is not enabled.

**Expected**
- The app bar reads `PRISM Privacy`.
- Before the first status reply: a spinner with `Checking privacy layer status...`.
- While the parameters load (`ProofProvingImplemented` or `ProofVerificationImplemented` still false): a shield icon, `Privacy Layer Starting Up`, `The PLONK proof system is initializing. This may take a moment` / `while cryptographic parameters are loaded.` and a small spinner. The rest of the app stays usable.
- Once both flags are true, the screen switches by itself (no restart) to the activation card, or to the dashboard if a shielded address is already stored.
- The PLONK files appear under the isolated folder's `rbxtest` tree, not under `~/rbxtest`.
- **Open question:** the GUI never downloads the parameters itself; it only reads `GetPlonkStatus`. Confirm the CLI's expected download size and duration on testnet, and whether a failed download is reported anywhere other than the permanent `Privacy Layer Starting Up` screen.

**Cleanup:** none.

### TC-PRV-002 · Privacy is not offered on the web wallet
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Logged in on web as account A.

**Steps**
1. Read the side nav with `read_page`.
2. Try the desktop path directly: load `http://localhost:42069/?automation=1#/privacy`.

**Expected**
- There is no `Privacy` item in the side nav.
- The direct path does not open any `PRISM Privacy` screen (the web router has no privacy route).

**Cleanup:** none.

### TC-PRV-003 · Activate the privacy wallet
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** TC-PRV-001 passed. Account A selected. No shielded address stored (a fresh data folder, or after TC-PRV-022).

**Steps**
1. `tap-key nav:privacy`. Read the activation card.
2. `tap-text "Activate Privacy Wallet"`.
3. In `Create Privacy Password`, tap the `Password` field and `type` the value of `TEST_ENCRYPTION_PASSWORD`; `tap-text Submit`.
4. In `Confirm Password`, `type` a different value; `tap-text Submit`.
5. Correct it: `type` the value of `TEST_ENCRYPTION_PASSWORD`; `tap-text Submit`.
6. Wait up to 2 minutes for the dashboard.

**Expected**
- The card reads `PRISM Privacy Layer` and `Activate your privacy wallet to shield VFX using zero-knowledge proofs. Shielded funds are hidden from the public ledger and can be transferred privately.`
- The first prompt body reads `Create a password to secure your shielded wallet's spending key. You'll need this password to unshield, transfer, or consolidate funds.`; submitting it empty shows `Password is required.`
- Step 4 shows `Passwords do not match` under the field and keeps the prompt open.
- While working the button reads `Activating...`. Then a toast `Privacy wallet activated: zfx_...` and the dashboard: `Shielded Address` with the `zfx_` address, `Shielded Balance` `0.0 VFX`, `0 notes`, `Block <n>`, the four action buttons, and no unlock banner (the password is held for this session).
- Record the `zfx_` address as account A's shielded address for this run.

**Cleanup:** none.

### TC-PRV-004 · Record a second shielded address (account B)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-PRV-003 passed. `TEST_VFX_B_PRIVKEY` imported in the same data folder.

**Steps**
1. On the dashboard open `Privacy settings` (`tap-label "Privacy settings"`), choose `Reset Privacy Wallet`, confirm with `tap-text Reset`.
2. Select account B as the current wallet.
3. Activate as in TC-PRV-003 steps 2–6.
4. `tap-label "Copy address"` on the address card and record the `zfx_` address as account B's shielded address.

**Expected**
- The reset confirm reads `This will clear your local privacy wallet state and return to the activation screen. Your shielded funds on the network are not affected — you can re-activate with the same account to recover them.` / `Continue?`; after it, toast `Privacy wallet reset` and the activation card.
- Activation for B succeeds and shows a different `zfx_` address.
- Copy shows `Address copied to clipboard`.

**Cleanup:** continue with TC-PRV-005.

### TC-PRV-005 · Re-activate account A and recover its shielded state
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** TC-PRV-004 done. Account A previously activated (TC-PRV-003), ideally with a shielded balance from an earlier run.

**Steps**
1. Reset the privacy wallet as in TC-PRV-004 step 1.
2. Select account A as the current wallet.
3. Activate with `TEST_ENCRYPTION_PASSWORD` as in TC-PRV-003.
4. Wait up to 3 minutes for the balance to load.

**Expected**
- The dashboard shows the same `zfx_` address recorded in TC-PRV-003.
- Any shielded balance and notes A had before are shown again.
- **Open question:** `ShieldedAddressNotifier.load` avoids calling the create endpoint on restart because it "would overwrite scanned data on the node". Confirm that re-activating the same account after a reset is safe for already-scanned notes, and whether a rescan is expected.

**Cleanup:** none.

### TC-PRV-006 · Unlock after restart, and the auto-lock
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Privacy wallet activated for account A.

**Steps**
1. Quit the app (`osascript -e 'tell application id "io.reserveblock.wallet" to quit'`) and relaunch the driver build; wait for sync.
2. `tap-key nav:privacy`.
3. `tap-key privacy:unshield`.
4. In `Unlock Privacy Wallet`, `tap-text Cancel`.
5. `tap-text Unlock` on the banner, `type` the value of `TEST_ENCRYPTION_PASSWORD`, `tap-text Submit`.
6. Leave the app idle for 11 minutes, then read the dashboard.

**Expected**
- After relaunch the dashboard loads directly (the `zfx_` address is remembered) with the orange banner `Enter your privacy password to unlock spending operations.` and an `Unlock` button.
- Step 3 opens `Unlock Privacy Wallet` (`Enter your privacy wallet password to enable spending.`) before any spending dialog; `Cancel` leaves it locked and opens nothing.
- Step 5 shows `Privacy wallet unlocked` and the banner disappears.
- After 10 minutes without a privacy operation the wallet locks again and the banner returns.
- `Shield` does not require unlocking (it spends transparent VFX).

**Cleanup:** unlock again for the following cases.

## Dashboard

### TC-PRV-007 · Dashboard content and address copy
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Privacy wallet activated, with at least one shielded note (after TC-PRV-008). On mainnet, only a wallet already activated by its owner; do not activate or send.

**Steps**
1. `tap-key nav:privacy`.
2. `tap-label "Copy address"` on the shielded address card.
3. Read `get-text text:"Shielded Balance"` and the figures next to it.

**Expected**
- Address card: shield icon, `Shielded Address`, the `zfx_` address in monospace, a copy button and a settings button (`Privacy settings`).
- Copy shows `Address copied to clipboard`.
- Balance card: `Shielded Balance` with `<amount> VFX`, and on the right `<n> note` / `<n> notes` and `Block <height>` (the last scanned block, which advances within a minute on a synced node).
- A `VIEW ONLY` badge appears only for a view-only wallet (TC-PRV-020).
- The `Shielded vBTC` section is absent while `VBTC_PRIVACY_ENABLED` is false, even when the wallet holds V2 vBTC tokens.

**Cleanup:** none.

## VFX actions

### TC-PRV-008 · Shield VFX
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Privacy wallet activated for account A. Account A holds at least 2 transparent VFX. Note the transparent balance and shielded balance.

**Steps**
1. `tap-key nav:privacy`, then `tap-key privacy:shield`.
2. `tap-key privacy:shield_amount`, `type 1`.
3. `tap-key privacy:shield_submit`.
4. Wait up to 3 minutes for the shielded balance and note count to update.
5. Repeat steps 1–4 with `0.5`, so later cases have two notes.

**Expected**
- The dialog `Shield VFX` reads `Move VFX from your transparent wallet into the shielded pool.`, `From: <account A address>`, the field `Amount (VFX)` with hint `Min: 0.001`, and `Transparent network fee will be auto-calculated.`
- While submitting, the Shield button turns into a spinner and the fields are disabled.
- Toast `Shield transaction broadcast successfully`; the dialog closes; the shielded balance rises by the amount at once.
- Within 3 minutes the shielded balance, note count and commitments list reflect the confirmed note; account A's transparent balance drops by the amount plus the network fee; the transaction appears in the VFX transaction list.

**Cleanup:** none.

### TC-PRV-009 · Shield validation
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Privacy wallet activated.

**Steps**
1. Open `Shield VFX` and submit with the amount empty.
2. `type 0.0005`, submit.
3. `type` an amount larger than account A's transparent balance, submit.
4. `tap-text Cancel`.

**Expected**
- Steps 1 and 2: toast `Minimum shield amount is 0.001 VFX`; the dialog stays open.
- Step 3: toast `Shield failed: <node message>`; the dialog stays open and the shielded balance is unchanged.
- `Cancel` closes the dialog without sending.

**Cleanup:** none.

### TC-PRV-010 · Unshield VFX to a transparent address
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Privacy wallet unlocked, shielded balance at least 0.3 VFX (TC-PRV-008 confirmed). Note account B's transparent balance.

**Steps**
1. `tap-key privacy:unshield`.
2. Tap the account picker in the address field: `tap-label "Select from my accounts"`, then tap account B's row in `Select Account`.
3. `tap-key privacy:unshield_amount`, `type 0.2`.
4. `tap-key privacy:unshield_submit`.
5. Wait up to 3 minutes.

**Expected**
- The dialog `Unshield VFX` reads `Move VFX from the shielded pool back to a transparent address.`, fields `To Address (transparent)` (hint `Enter VFX address`) and `Amount (VFX)`, and `0.000003 VFX fee deducted from shielded balance.`
- The picker lists each account with its domain or address and `<balance> VFX`; choosing one fills the address field.
- Toast `Unshield transaction broadcast successfully`; the dialog closes; the shielded balance drops by 0.200003 at once.
- Within 3 minutes account B's transparent balance rises by 0.2 and the shielded balance and notes settle (a change note may appear).

**Cleanup:** none.

### TC-PRV-011 · Unshield validation
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Privacy wallet unlocked with a shielded balance above the fee.

**Steps**
1. Open `Unshield VFX`, type `abc` as the address and `0.1` as the amount, submit.
2. Enter a valid address (the value of `TEST_VFX_B_ADDRESS`) and amount `0`, submit.
3. Enter an amount larger than the shielded balance, submit.

**Expected**
- Step 1: toast `Please enter a valid VFX address`.
- Step 2: toast `Please enter a valid amount`.
- Step 3: toast `Unshield failed: <node message>`; nothing is sent.

**Cleanup:** none.

### TC-PRV-012 · Private transfer to another shielded address
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Privacy wallet for account A unlocked, shielded balance at least 0.3 VFX. Account B's `zfx_` address recorded in TC-PRV-004.

**Steps**
1. `tap-key privacy:transfer`.
2. `tap-key privacy:transfer_recipient`, `type` account B's `zfx_` address.
3. `tap-key privacy:transfer_amount`, `type 0.1`.
4. `tap-key privacy:transfer_submit`.
5. Wait up to 3 minutes.
6. Optional check: reset, select account B, re-activate as in TC-PRV-005 and read B's shielded balance; then switch back to A.

**Expected**
- The dialog `Private Transfer` reads `Transfer shielded VFX to another zfx_ address. Fully private.`, fields `Recipient (zfx_ address)` (hint `zfx_...`) and `Amount (VFX)`, and `0.000003 VFX fee deducted from shielded balance.`
- Toast `Private transfer broadcast successfully`; the dialog closes; A's shielded balance drops by 0.100003 at once and settles within 3 minutes.
- No transparent balance changes on either account.
- Step 6: B's shielded balance includes the 0.1 VFX.

**Cleanup:** make sure account A is the active privacy wallet again.

### TC-PRV-013 · Private transfer validation
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Privacy wallet unlocked with a shielded balance above the fee.

**Steps**
1. Open `Private Transfer`, type account B's transparent address (`TEST_VFX_B_ADDRESS`) as the recipient and `0.1` as the amount, submit.
2. Type `zfx_short` as the recipient, submit.
3. Type account B's `zfx_` address and amount `0`, submit.

**Expected**
- Steps 1 and 2: toast `Recipient must be a valid zfx_ address`.
- Step 3: toast `Please enter a valid amount`.
- Nothing is sent.

**Cleanup:** none.

### TC-PRV-014 · Wrong privacy password locks the wallet
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Privacy wallet locked (relaunch or wait for the auto-lock), shielded balance above the fee.

**Steps**
1. `tap-text Unlock`, `type` a wrong password, `tap-text Submit`.
2. Open `Unshield VFX`, fill the value of `TEST_VFX_B_ADDRESS` and `0.01`, submit.

**Expected**
- Step 1 shows `Privacy wallet unlocked` (the password is not checked until it is used).
- Step 2: toast `Unshield failed: <node message about the password>`; the wallet locks again and the unlock banner returns; nothing is sent.
- **Open question:** the lock only happens when the node's message contains `password`, `unauthorized` or `authentication`. Confirm the CLI's wording for a wrong privacy password so this case can assert the exact toast.

**Cleanup:** unlock with the right password.

### TC-PRV-015 · Spending with no shielded VFX
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** A freshly activated privacy wallet with a shielded balance of 0 (for example account B after TC-PRV-004, before any transfer), unlocked.

**Steps**
1. `tap-key privacy:unshield`, fill the value of `TEST_VFX_A_ADDRESS` and `0.01`, `tap-key privacy:unshield_submit`.
2. In the dialog that appears, `tap-text Cancel`.
3. Repeat step 1 and tap `Shield VFX` in the dialog.

**Expected**
- A dialog `Shielded VFX Required` appears before any validation, reading `vBTC privacy operations require a small fee paid from your shielded VFX balance.` / `You currently have 0.0 shielded VFX.` / `Please shield at least 0.000003 VFX first.`
- `Cancel` closes it and nothing is sent.
- `Shield VFX` closes it and opens the `Shield VFX` dialog.
- The same guard runs before `Private Transfer`, and before `Consolidate Notes` when the wallet has at least 2 notes (with fewer, the Consolidate button is disabled first).
- P2 finding: the body says "vBTC privacy operations" although this is a VFX unshield; the text should cover VFX too.

**Cleanup:** none.

### TC-PRV-016 · Consolidate notes
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** Privacy wallet unlocked with at least 2 unspent notes (TC-PRV-008 twice) and shielded VFX above the fee.

**Steps**
1. Note the note count, then `tap-key privacy:consolidate`.
2. `tap-key privacy:consolidate_submit`.
3. Wait up to 3 minutes.

**Expected**
- The dialog `Consolidate Notes` reads `Merge your 2 smallest notes into a single note. This reduces dust and improves privacy.`, `Current notes: <n>` and `Fee: 0.000003 VFX (deducted from shielded balance)`.
- Toast `Consolidation broadcast successfully`; the dialog closes.
- Within 3 minutes the note count drops by one and the balance drops by the fee.

**Cleanup:** none.

### TC-PRV-017 · Consolidate needs two notes
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Privacy wallet unlocked with exactly one unspent note and shielded VFX above the fee.

**Steps**
1. `tap-key privacy:consolidate`.
2. `tap-key privacy:consolidate_submit`.

**Expected**
- The dialog shows `Current notes: 1` and, in red, `At least 2 unspent notes are required to consolidate.`
- The `Consolidate` button is greyed and tapping it does nothing.

**Cleanup:** `tap-text Cancel`.

### TC-PRV-018 · Commitments list
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Privacy wallet with at least one unspent note.

**Steps**
1. On the dashboard, tap the `Commitments (<n> notes)` tile to expand it.
2. Hover the info icon next to the title.
3. Tap `Block: <height>` on a row.

**Expected**
- The tile is collapsed by default and its title counts unspent notes (`1 note` / `<n> notes`).
- The tooltip starts `Notes represent individual shielded outputs that make up your` and mentions consolidation.
- Each row shows a green dot, `<amount> <asset>` (for example `1.0 VFX`) and `Tree pos: <n>  |  Block: <height>`; spent notes are not listed.
- The block link opens the explorer at `<explorer>/block/<height>`.
- With no commitments the tile is not shown.

**Cleanup:** none.

## Settings menu

### TC-PRV-019 · Export and copy the viewing key
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Privacy wallet activated.

**Steps**
1. `tap-label "Privacy settings"`, then `tap-text "Export Viewing Key"`.
2. `tap-label "Copy viewing key"`.
3. `tap-text Close`.

**Expected**
- The menu lists `Export Viewing Key`, `Import Viewing Key`, `Resync Wallet`, `Reset Privacy Wallet`, and no `Resync vBTC Wallet` while `VBTC_PRIVACY_ENABLED` is false.
- The dialog `Viewing Key` reads `Copy this key to import a view-only wallet on another device. This key can see balances but cannot spend.` and shows a Base64 key.
- Copy shows `Viewing key copied to clipboard`. Do not paste the key into results.
- On a node error the toast reads `Failed to export viewing key`.

**Cleanup:** none.

### TC-PRV-020 · Import a viewing key
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** A viewing key exported in TC-PRV-019 for account B's `zfx_` address (export it while B is the active privacy wallet), and the privacy wallet switched back to account A.

**Steps**
1. `tap-label "Privacy settings"`, `tap-text "Import Viewing Key"`.
2. Tap `Import` with both fields empty.
3. Type `abc` in `zfx_ Address`, tap `Import`.
4. Type account B's `zfx_` address, leave the key empty, tap `Import`.
5. Paste the exported key into `Viewing Key (Base64)`, tap `Import`.

**Expected**
- The dialog reads `Import a viewing key to create a view-only wallet. You can see balances but cannot spend.` with hints `zfx_...` and `Paste Base64 key here`.
- Steps 2 and 3: toast `Please enter a valid zfx_ address`.
- Step 4: toast `Please enter the viewing key`.
- Step 5: toast `Viewing key imported successfully` and the dialog closes; an invalid key gives `Failed to import viewing key`.
- **Open question:** the dashboard only follows the stored `zfx_` address, so an imported view-only wallet does not appear in the GUI. Confirm how the `VIEW ONLY` badge is meant to be reached and what the release test should assert after an import.

**Cleanup:** none.

### TC-PRV-021 · Resync the shielded wallet
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Privacy wallet activated, with a shielded balance.

**Steps**
1. `tap-label "Privacy settings"`, `tap-text "Resync Wallet"`.
2. In `Resync Shielded Wallet`, `tap-text Cancel`.
3. Repeat and `tap-text Resync`.
4. Wait up to 15 minutes for the result toast.

**Expected**
- The confirm reads `This will wipe all cached notes and balances, then rescan from the beginning. This may take a while.` / `Continue?`
- `Cancel` does nothing.
- `Resync` shows `Resync started...`, then `Resync complete` (or `Resync failed`).
- After completion the balance and notes match what they were before the resync.

**Cleanup:** none.

### TC-PRV-022 · Reset the privacy wallet
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Privacy wallet activated.

**Steps**
1. `tap-label "Privacy settings"`, `tap-text "Reset Privacy Wallet"`.
2. `tap-text Cancel`; repeat and `tap-text Reset`.

**Expected**
- The confirm text is as in TC-PRV-004; `Cancel` does nothing.
- `Reset` shows `Privacy wallet reset` and the activation card; balance polling stops.
- Re-activating the same account restores the address and funds (TC-PRV-005).

**Cleanup:** re-activate account A.

## vBTC variants (gated)

These cases run only on a build where `VBTC_PRIVACY_ENABLED` is `true` and the CLI has shielded vBTC enabled. On the release build, run TC-PRV-023 and record TC-PRV-024 to TC-PRV-029 as skipped with the note "VBTC_PRIVACY_ENABLED is false". They need account A to hold a V2 vBTC token with a transparent balance (see `04-btc-vbtc.md`) and a shielded VFX balance above the fee.

### TC-PRV-023 · vBTC privacy stays hidden while gated
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · **Mainnet smoke**

**Preconditions:** Release configuration (`VBTC_PRIVACY_ENABLED` false). Account A holds at least one V2 vBTC token.

**Steps**
1. Open Privacy and read the whole dashboard (scroll to the end).
2. Open `Privacy settings`.

**Expected**
- No `Shielded vBTC` heading and no vBTC balance cards or `privacy:*_vbtc` buttons.
- No `Resync vBTC Wallet` entry in the menu.

**Cleanup:** none.

### TC-PRV-024 · Shielded vBTC card
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Gated build as described above.

**Steps**
1. Open Privacy and read the `Shielded vBTC` section.

**Expected**
- One card per V2 token: the token name without the `V2` suffix, the smart contract id, `<amount> vBTC`, `<n> notes`, `Block <height>`, and the buttons `Shield`, `Unshield`, `Transfer`, `Consolidate` (keys `privacy:shield_vbtc`, `privacy:unshield_vbtc`, `privacy:transfer_vbtc`, `privacy:consolidate_vbtc`).

**Cleanup:** none.

### TC-PRV-025 · Shield vBTC
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** Gated build. Transparent vBTC balance at least 0.00003 on the token.

**Steps**
1. `tap-key privacy:shield_vbtc` on the token card.
2. Submit `0.000001` (below the minimum), then `tap-key privacy:shield_vbtc_amount`, `type 0.00002`, `tap-key privacy:shield_vbtc_submit`.
3. Wait up to 3 minutes.

**Expected**
- The dialog `Shield vBTC` reads `Move vBTC from your transparent wallet into the shielded pool.`, `Contract: <name>`, `From: <address>`, the field `Amount (vBTC)` with hint `Min: 0.00001`, and `Transparent network fee will be auto-calculated.`
- The low amount gives `Minimum shield amount is 0.00001 vBTC`.
- The valid amount gives `vBTC shield transaction broadcast successfully`, and the card's vBTC balance rises within 3 minutes. Failures read `vBTC shield failed: <error>`.

**Cleanup:** none.

### TC-PRV-026 · Unshield vBTC
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** Gated build. Shielded vBTC on the token (TC-PRV-025), wallet unlocked.

**Steps**
1. `tap-key privacy:unshield_vbtc`.
2. Submit with `abc` as the address; then with a valid address and `0`.
3. `tap-key privacy:unshield_vbtc_address`, choose account A with `Select from my accounts`; `tap-key privacy:unshield_vbtc_amount`, `type 0.00001`; `tap-key privacy:unshield_vbtc_submit`.

**Expected**
- The dialog `Unshield vBTC` reads `Move vBTC from the shielded pool back to a transparent address.`, `Contract: <name>`, and `A fee of 0.000003 VFX will be deducted from your shielded VFX balance.`
- Step 2: `Please enter a valid VFX address`, then `Please enter a valid amount`.
- Step 3: `vBTC unshield transaction broadcast successfully`; the transparent vBTC balance rises within 3 minutes. With too little shielded VFX: the `Shielded VFX Required` dialog or `Insufficient shielded VFX to cover the privacy transaction fee.`

**Cleanup:** none.

### TC-PRV-027 · Private transfer vBTC
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** Gated build. Shielded vBTC on the token, wallet unlocked, account B's `zfx_` address recorded.

**Steps**
1. `tap-key privacy:transfer_vbtc`.
2. `tap-key privacy:transfer_vbtc_recipient`, `type` account B's `zfx_` address; `tap-key privacy:transfer_vbtc_amount`, `type 0.00001`; `tap-key privacy:transfer_vbtc_submit`.

**Expected**
- The dialog `Private Transfer vBTC` reads `Transfer shielded vBTC to another zfx_ address. Fully private.`, `Contract: <name>` and the shielded VFX fee note.
- A transparent address as recipient gives `Recipient must be a valid zfx_ address`.
- Success toast `vBTC private transfer broadcast successfully`; failures read `vBTC private transfer failed: <error>`.

**Cleanup:** none.

### TC-PRV-028 · Consolidate vBTC notes
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** Gated build. At least 2 shielded vBTC notes on the token, wallet unlocked.

**Steps**
1. `tap-key privacy:consolidate_vbtc`.
2. `tap-key privacy:consolidate_vbtc_submit`.

**Expected**
- The dialog `Consolidate vBTC Notes` reads `Merge your 2 smallest vBTC notes into a single note. This reduces dust and improves privacy.`, `Contract: <name>`, `Current notes: <n>` and `Fee: 0.000003 VFX (deducted from shielded VFX balance)`; with fewer than 2 notes it shows `At least 2 unspent notes are required to consolidate.` and the button is disabled.
- Success toast `vBTC consolidation broadcast successfully`; failures read `vBTC consolidation failed: <error>`.

**Cleanup:** none.

### TC-PRV-029 · Resync vBTC wallet
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Gated build with at least one V2 token.

**Steps**
1. `tap-label "Privacy settings"`, `tap-text "Resync vBTC Wallet"`.
2. With more than one V2 token, pick one in `Select vBTC Contract` (`Choose which vBTC contract to resync.`).
3. Confirm with `tap-text Resync`.

**Expected**
- With one token, the picker is skipped. With no V2 tokens, toast `No vBTC tokens found`.
- The confirm reads `This will wipe cached notes and balances for "<name>" and rescan from the beginning. This may take a while.` / `Continue?`
- Toasts `vBTC resync started...`, then `vBTC resync complete` or `vBTC resync failed`.

**Cleanup:** none.
