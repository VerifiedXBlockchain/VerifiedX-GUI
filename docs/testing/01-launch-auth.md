# 01 · Launch and authentication

This file covers everything between opening the app and holding a usable, unlocked account: the macOS boot screen and the Core CLI it launches, the snapshot prompt on a fresh data folder, first-run state, account creation and every import method on each platform, multiple accounts and switching, desktop wallet encryption with lock, unlock and password prompts, the web wallet's encrypted key storage with unlock, lock, idle lock, sign out and session resume, and key reveal, copy and backup. The two platforms work differently here: the desktop GUI keeps keys in the Core CLI and encryption is a CLI feature, while the web wallet derives and stores its own keys in the browser, always encrypted with a password the user sets at login.

## Area preconditions

- **Web.** The testnet automation build is open at `http://localhost:42069/?automation=1` with `fltA11y` injected (`tool/automation/flt_semantics.js`). A "fresh browser" means site data for `localhost:42069` is cleared: run `indexedDB.deleteDatabase('vfx'); localStorage.clear();` through the `javascript_tool` (or Chrome's Clear site data), then load `http://localhost:42069/?automation=1` again.
- **Web reloads.** Logout, Sign Out and Lock Wallet all do a full page load of `/`, which drops `?automation=1`. After any of them, and after every manual reload, open `http://localhost:42069/?automation=1` again before reading the page.
- **macOS.** No `VerifiedXCore` process is running (`pgrep -fl VerifiedXCore` is empty). The app is started with `make run_macos_driver` (output redirected to a file) and driven with `tool/drive.dart`. A "fresh data folder" means `~/Library/Application Support/vfx-gui-automation` was deleted before launch; the first boot in it downloads about 250 MB and syncs testnet.
- **Debug prefill.** In debug builds (`make run_web_automation`, `make run_macos_driver`) every "set password" and "enter password" prompt opens prefilled with a debug value. Always replace the field content: on web use `await fltA11y.type("<label>", value)`, which sets the whole value; on macOS `drive.dart type` replaces the focused field. A release build served from `build/web` has no prefill.
- **Duplicate labels on macOS.** `drive.dart` fails with `Too many elements` when a text or tooltip appears more than once, and some controls have no key: `View Chart`, `View All Txs` and `New Address` (one per card), `Add Account` on an empty account panel (header and empty state), the `Restart` confirm (title and button share the text), `Import` in the bulk importer while its confirm dialog is open, and per-row tooltips such as `Reveal Private Key`, `Hide Account` and the Activity Log `Copy`. Where a step hits one of these, reduce the screen to a single match if the case says how, otherwise do that tap by hand and note `manual tap` in the result.
- **Passwords.** Wherever a case sets or enters an encryption password it uses `TEST_ENCRYPTION_PASSWORD`, except the Email & Password login, whose account password is also its encryption password (`TEST_WEB_PASSWORD`).
- **Mainnet smoke.** Cases tagged `Mainnet smoke` run against the production web wallet or a normal desktop build and only observe. Never set a password or import a key on mainnet as part of this file.

## Desktop boot and Core CLI

### TC-AUTH-001 · Cold boot shows the boot screen and starts the Core CLI
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no · Mainnet smoke

**Preconditions:** No `VerifiedXCore` process. Any data folder state (fresh or existing).

**Steps**
1. Start the app (`make run_macos_driver`, output to a file) and read the Observatory URL from the output.
2. macOS: `wait-for-text VFX --timeout 60`, then `screenshot TC-AUTH-001-boot.png`.
3. macOS: `get-text "text:VFX Wallet [TESTNET] Version Testnet <version> (Switchblade)"` with `<version>` from the build record.
4. Wait up to 5 minutes for the dashboard: `wait-for-text $'Send\nCoin' --timeout 300`.
5. In a shell: `pgrep -fl VerifiedXCore` and `curl -s -o /dev/null -w '%{http_code}' http://localhost:17292/api/V1/CheckStatus/`.

**Expected**
- The boot screen shows the version line `VFX Wallet [TESTNET] Version Testnet <version> (Switchblade)` at the top (mainnet build: `VFX Wallet Version Mainnet <version> (Switchblade)`), the rotating cube, and `VFX booting` in the middle.
- Up to six recent log lines scroll under it, including `Starting VFXCore...` and `Launching CLI in the background.`, then repeated `CLI loading...`.
- The dashboard replaces the boot screen once the CLI answers; the window title is `VFX Switchblade`.
- A `VerifiedXCore` process exists and the status URL answers (testnet port 17292).

**Cleanup:** none (leave the app running for the next cases).

**Open question:** the boot screen builds its log list with `getRange(start, logs.length - 1)`, so the newest log line never appears there. Confirm whether that is intended.

### TC-AUTH-002 · Boot log lines in the Activity Log
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no · Mainnet smoke

**Preconditions:** TC-AUTH-001 done in this launch.

**Steps**
1. macOS: `tap-key nav:operations`.
2. macOS: `wait-for-text "Activity Log"`, then `screenshot TC-AUTH-002.png`.

**Expected**
- The Operations screen shows `Activity Log` with, in this order: `Welcome to VerifiedX Wallet version Testnet <version>`, `Starting VFXCore...`, `Automation: CLI data isolated under <…>/vfx-gui-automation` (automation builds only), `Launching CLI in the background.`, one or more `CLI loading...`, `VerifedX Wallet Started Successfully` (spelled as in the code), `Fetching Config...`, `Config Loaded...`, `CLI Version: <version>`.
- The `Status` panel on the right lists `CLI Version` with the same value as the log line.

**Cleanup:** none.

### TC-AUTH-003 · Startup sync panel after an improper shutdown
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Existing automation data folder with a synced chain.

**Steps**
1. With the app running, kill both processes hard: `pkill -9 -f VerifiedXCore; pkill -9 -f "VFX"` (or kill the `flutter run` process).
2. Start the app again and attach `drive.dart`.
3. macOS: `screenshot TC-AUTH-003.png` every 10 seconds while the boot screen is up (up to 5 minutes).

**Expected**
- If the CLI replays blocks, a panel appears under `VFX booting` with `SYNCING STATE TREIS DUE TO IMPROPER SHUTDOWN`, `Block: <n>`, `Progress: <p>`, a green progress bar and `Please do not close your wallet.`
- The dashboard loads once the CLI answers.

**Cleanup:** none.

**Open question:** the panel only shows when the CLI writes its startup progress file; confirm a hard kill reliably produces it.

### TC-AUTH-004 · "Import Snapshot?" prompt on a fresh data folder, declined
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Fresh data folder. No GUI update is published above this build (otherwise the GUI update prompt, TC-DASH-041, shows instead).

**Steps**
1. Boot as in TC-AUTH-001.
2. Wait up to 3 minutes after the dashboard appears: `wait-for-text "Import Snapshot?" --timeout 180`.
3. `screenshot TC-AUTH-004.png`, then `tap-text No`.
4. Wait 5 minutes on the dashboard.

**Expected**
- A dialog titled `Import Snapshot?` says `You are only at <local height> block height locally. The network has a snapshot at <snapshot height> block height that will help you sync more quickly.` followed by `Would you like to import it now?`, with buttons `No` and `Import`.
- After `No` the dialog closes and does not come back during this session.

**Cleanup:** none.

**Open question:** the prompt needs a testnet snapshot from `/api/snapshots/latest/?network=testnet` at least 5,000 blocks above the local height. Confirm testnet publishes one; if not, record the case as `blocked`.

### TC-AUTH-005 · Import a snapshot from the prompt
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Fresh data folder in which account A was imported (TC-AUTH-046) and the prompt was declined, then the app was restarted so the prompt appears again with an account present and the backup warning shows. Keys are backed up.

**Steps**
1. When `Import Snapshot?` appears, `tap-text Import`.
2. `wait-for-text Warning`, `screenshot TC-AUTH-005-warning.png`, then `tap-text "I'm Backed Up"`.
3. Take a screenshot every 30 seconds until the downloader dialog shows a completion message (up to 30 minutes), then `tap-text Close` if present.
4. Wait up to 5 minutes for the dashboard and the account list to load.

**Expected**
- The warning reads `Be sure your private keys are backed up as this process will wipe your database folder.` and offers `Cancel` and `I'm Backed Up`.
- A non-dismissable downloader shows progress (`Initializing...`, `Shutting down CLI...`, `Downloading: <file> (<n>/<total>)`, `Starting up CLI now...`) and ends with `Database Snapshot Imported.` or `All done!`.
- The CLI restarts, the local block height is at or above the snapshot height, and the imported accounts are still listed with their balances.
- On failure the dialog shows `An error occurred. Please restart and try again.` or `Import Failed` / `Snapshot import failed.`; record it as a fail.

**Cleanup:** none.

### TC-AUTH-006 · Manual Import Snapshot when the local chain is ahead
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Chain synced to the tip.

**Steps**
1. macOS: `tap-key nav:operations`, then `tap-text General`.
2. `tap-text "Import Snapshot"`.

**Expected**
- A toast says `Your local blockheight is further along than the snapshot.`
- If the node cannot report a height: `Problem fetching local block height. Please try again.`; if the snapshot service is unreachable: `Problem fetching snapshot block height. Please try again.`

**Cleanup:** none.

### TC-AUTH-007 · Restart CLI from Operations
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Dashboard loaded, CLI started.

**Steps**
1. macOS: `tap-key nav:operations`, `tap-text Diagnose`, `tap-text "Restart CLI"`.
2. `wait-for-text Restart`, `screenshot TC-AUTH-007-confirm.png`, `tap-text Cancel`.
3. Repeat step 1, then tap the red `Restart` button (the title shares the text, so this is a manual tap; see Area preconditions).
4. Wait up to 3 minutes, watching the Activity Log.

**Expected**
- The confirm dialog is titled `Restart` with `Are you sure you want to restart the CLI?` and buttons `Cancel` / `Restart`. Cancel changes nothing.
- After confirming, the log shows `Starting VFXCore...` and the start sequence from TC-AUTH-002 again; the accounts and balances reload.
- Exactly one `VerifiedXCore` process exists afterwards.

**Cleanup:** none.

### TC-AUTH-008 · Quitting the app stops the Core CLI
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no · Mainnet smoke

**Preconditions:** App running with its CLI.

**Steps**
1. In a shell: `osascript -e 'tell application id "io.reserveblock.wallet" to quit'`.
2. Wait up to 30 seconds, then `pgrep -fl VerifiedXCore` and `lsof -nP -iTCP:17292 -sTCP:LISTEN`.

**Expected**
- The app window closes and `flutter run` exits with "Lost connection to device."
- No `VerifiedXCore` process remains and port 17292 is free.

**Cleanup:** start the app again before the next macOS case.

## Web landing and login sheet

### TC-AUTH-009 · Web landing screen on a fresh browser
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no · Mainnet smoke

**Preconditions:** Fresh browser (site data cleared).

**Steps**
1. Web: open `http://localhost:42069/?automation=1`, run `fltA11y.status()` until `nodeCount > 0`.
2. Web: `read_page`, screenshot `TC-AUTH-009`.

**Expected**
- The page shows the animated cube, the wordmark `Verified` `X`, the subtitle `Web Wallet Testnet <version>` (mainnet: `Web Wallet Mainnet <version>`), `button "Login / Create Account"` and, on testnet, `TESTNET` in green.
- There is no `Enter Password`, `Logout` or `Resume Session` control.

**Cleanup:** none.

### TC-AUTH-010 · Login sheet lists every sign-in method
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no · Mainnet smoke

**Preconditions:** TC-AUTH-009 state.

**Steps**
1. Web: click `button "Login / Create Account"` (key `auth:login`).
2. `read_page`, screenshot `TC-AUTH-010`.
3. Web: `fltA11y.tap("Dismiss")` on the scrim above the sheet.

**Expected**
- A bottom sheet lists, in order: `Email & Password`, `Mnemonic (HD account)`, `VFX Private Key`, `Bitcoin Private Key / WIF Key`, and `VFX Extension` only when the VerifiedX browser extension is installed. Each row reads as a button (keys `auth:type_email_password`, `auth:type_mnemonic`, `auth:type_vfx_private_key`, `auth:type_btc_private_key`, `auth:type_extension`).
- Tapping the scrim closes the sheet and the landing screen is unchanged.

**Cleanup:** none.

## Web wallet creation and import

### TC-AUTH-011 · Create or log in with Email & Password
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Fresh browser.

**Steps**
1. Web: click `button "Login / Create Account"`, then `button "Email & Password"` (fallback `fltA11y.tap("Email & Password")`).
2. Screenshot the dialog. Type `TEST_WEB_EMAIL` into `textbox "Email Address"`, `TEST_WEB_PASSWORD` into `textbox "Password"` and into `textbox "Confirm Password"`.
3. Click `button "Login"`. Wait up to 30 seconds for `Welcome to the VerifiedX Web Wallet!`.
4. Screenshot, then click `button "Continue"`.
5. Record the VFX address shown in the dashboard (public data).

**Expected**
- The dialog is titled `Create Account` and explains `Your email and password is used to seed your private key which is processed in this browser and will never be transmitted across the internet.` It has `Cancel` and `Login`.
- No separate encryption password is asked; the account password becomes the encryption password.
- The welcome dialog shows three paragraphs starting `The network does NOT store your email/password or mnemonic.`, `This includes your VFX account, Vault account, and Bitcoin account.` and `We recommend backing up all private keys…`, with `Backup Keys` and `Continue`.
- The dashboard opens with the VFX and BTC balance cards. The same email and password give the same VFX address on every run (compare with the address recorded in earlier runs).

**Cleanup:** Sign out (TC-AUTH-026) unless the next case needs this session.

### TC-AUTH-012 · Email & Password validation messages
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Fresh browser, login sheet open on `Email & Password`.

**Steps**
1. Click `button "Login"` with all fields empty; screenshot.
2. Type `not-an-email` as email and `short12` (7 characters) as both passwords; click `Login`; screenshot.
3. Type a valid-looking email `qa+<run id>@example.com`, `password-one` as Password and `password-two` as Confirm Password; click `Login`; screenshot.
4. Click `Cancel`.

**Expected**
- Step 1: `Email required.` under the email field and `Password required.` under both password fields; the dialog stays open.
- Step 2: `Invalid email.` and `Password not strong enough.` (the rule is at least 8 characters).
- Step 3: a red toast `Passwords do not match`; the dialog stays open and nobody is logged in.
- Cancel closes the dialog; the landing screen is unchanged.

**Cleanup:** none.

### TC-AUTH-013 · Create a new mnemonic (HD) account
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Fresh browser.

**Steps**
1. Click `button "Login / Create Account"`, then `button "Mnemonic (HD account)"`.
2. In the next sheet click `button "Create New Mnemonic"`. A confirm dialog appears; screenshot, click `button "Yes"`.
3. Wait for `Set Encryption Password`. `await fltA11y.type("New Password", TEST_ENCRYPTION_PASSWORD)`, click `button "Submit"`.
4. In `Confirm Password`, `await fltA11y.type("Confirm Password", TEST_ENCRYPTION_PASSWORD)`, click `button "Submit"`.
5. Screenshot the key dialog. Click `button "Copy mnemonic"`, then `button "Done"`.
6. Screenshot the welcome dialog, click `button "Continue"`.

**Expected**
- The confirm dialog is titled `Mnemonic` with `Are you sure you want to create a Mnemonic account?`.
- `Loading...` covers the screen briefly while keys are derived.
- The set-password prompt reads `This password will encrypt your generated mnemonic keys.`
- A non-dismissable dialog titled `Key Generated` says `Here are your account details. Please ensure to back up your private key in a safe place.` and shows `Recovery Mnemonic` (12 words), `Address` and `Private Key`, each with a copy button. Copy mnemonic shows `Mnemonic copied to clipboard`.
- After `Done` and `Continue` the dashboard shows the new account with 0 VFX and 0 BTC.

**Cleanup:** Sign out.

### TC-AUTH-014 · Recover from a mnemonic
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Fresh browser.

**Steps**
1. Open the login sheet, click `button "Mnemonic (HD account)"`, then `button "Recover From Mnemonic"`.
2. In `Input Recovery Mnemonic`, type `TEST_MNEMONIC` into `textbox "Recovery Mnemonic"`, click `button "Submit"`.
3. Set and confirm `TEST_ENCRYPTION_PASSWORD` as in TC-AUTH-013.
4. Click `button "Continue"` on the welcome dialog. Record the VFX, Vault and BTC addresses from the `Addresses` tab (TC-DASH-012).
5. Sign out, reopen `?automation=1`, and repeat steps 1–4.

**Expected**
- The set-password prompt reads `This password will encrypt your recovered mnemonic keys.`
- The dashboard opens logged in. No key dialog is shown for a recovery.
- The second recovery yields exactly the same VFX, Vault and BTC addresses as the first.

**Cleanup:** Sign out.

### TC-AUTH-015 · Mnemonic recovery rejects empty and invalid phrases
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Fresh browser, `Input Recovery Mnemonic` open.

**Steps**
1. Click `button "Submit"` with the field empty; screenshot.
2. Type `apple banana cherry dog elephant frog grape house igloo jacket kite lemon` and click `Submit`; screenshot.

**Expected**
- Step 1: `Recovery Mnemonic is required.` under the field; the dialog stays open.
- Step 2: the dialog closes, a red toast `A problem occurred.` appears, no password prompt follows and the landing screen is unchanged.

**Cleanup:** none.

### TC-AUTH-016 · Import a VFX private key
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Fresh browser.

**Steps**
1. Open the login sheet and click `button "VFX Private Key"`.
2. In `Import Wallet`, `await fltA11y.type("VFX Private Key", TEST_VFX_A_PRIVKEY)`, click `button "Submit"`.
3. Set and confirm `TEST_ENCRYPTION_PASSWORD`.
4. If a `Choose accounts to restore` dialog appears, screenshot it and pick the row marked `Activity found` (else `Standard key form`).
5. Click `button "Continue"` on the welcome dialog. Wait up to 60 seconds for the VFX card balance.

**Expected**
- The set-password prompt reads `This password will encrypt your imported private key.`
- The chooser, when shown, explains `Earlier wallet versions wrote this key in more than one form…` and lists `Standard key form` / `Earlier key form` rows, each with `Vault: …`, `Bitcoin: …` and an activity note (`Activity found`, `No activity found` or `Could not check activity`).
- The dashboard's VFX address equals `TEST_VFX_A_ADDRESS` and the VFX card shows at least 200 VFX.

**Cleanup:** Keep this session for the web cases that need account A.

### TC-AUTH-017 · VFX private key validation
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Fresh browser, `Import Wallet` open from the login sheet.

**Steps**
1. Click `Submit` with the field empty; screenshot.
2. Type `xyz123` and click `Submit`; screenshot.
3. Type `0` and click `Submit`; screenshot.
4. Type `0x` followed by `TEST_VFX_A_PRIVKEY` with a leading and trailing space, click `Submit`, then cancel the password prompt.

**Expected**
- Step 1: `VFX Private Key is required.`
- Steps 2 and 3: `This is not a valid private key. Paste the hexadecimal key.`; the dialog stays open.
- Step 4 is accepted (the `0x` prefix and whitespace are stripped) and moves on to `Set Encryption Password`; cancelling there leaves the user on the landing screen, not logged in.

**Cleanup:** none.

### TC-AUTH-018 · Import a Bitcoin private key or WIF key
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Fresh browser.

**Steps**
1. Open the login sheet and click `button "Bitcoin Private Key / WIF Key"`.
2. Screenshot the `Warning` dialog, click `button "Okay"`.
3. In `Import BTC Private Key or WIF Key`, type `TEST_BTC_WIF` into `textbox "Enter your private key"`. Leave the address type on `Bech32 (Native SegWit - P2WPKH)` unless `TEST_BTC_ADDRESS` is of another type, then pick the matching one.
4. Click `button "Import"`. Set and confirm `TEST_ENCRYPTION_PASSWORD`, then `Continue`.
5. Open the `Addresses` tab and compare the BTC row.

**Expected**
- The warning reads `Although if you login with a BTC Private key, if this key was generated originally with a different login mechanism, your VFX/Vault account keypairs will not match…`.
- The address type list offers `P2PKH (Legacy)`, `P2SH (Nested SegWit)`, `Bech32 (Native SegWit - P2WPKH)`, `Bech32m (Taproot - P2TR)` and `I don't know`.
- The set-password prompt reads `This password will encrypt your imported BTC private key.`
- The dashboard's BTC address equals `TEST_BTC_ADDRESS` and the BTC card shows its balance within 90 seconds. A VFX and a Vault account derived from the key are listed as well.

**Cleanup:** Sign out.

### TC-AUTH-019 · Bitcoin key import rejects bad input
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Fresh browser.

**Steps**
1. Open the BTC import sheet (TC-AUTH-018 steps 1–2). Type `abc123`, click `Import`, then set and confirm `TEST_ENCRYPTION_PASSWORD`; screenshot.
2. Open the sheet again, type `TEST_BTC_WIF`, choose `I don't know`, type `xyz` into `textbox "Enter your BTC address"`, click `Import`; screenshot.
3. Repeat step 2 with `TEST_BTC_ADDRESS` in the address field.

**Expected**
- Step 1: the password prompts come first, then a red toast `Not a valid Private Key or WIF Key. Should be 64 or 52 characters`; nobody is logged in.
- Step 2: the sheet closes with a red toast `Invalid BTC Address`.
- Step 3: the address type is detected from the prefix and the import continues to the password prompt.

**Cleanup:** none.

**Open question:** the `I don't know` detection only recognises mainnet prefixes (`1`, `3`, `bc1q`, `bc1p`). A testnet address (`tb1…`, `m…`, `n…`, `2…`) will fail step 3 with `Invalid BTC Address`. Confirm whether that is acceptable on testnet.

### TC-AUTH-020 · Set Encryption Password validation
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Fresh browser; start a VFX private key import with `TEST_VFX_A_PRIVKEY` up to the `Set Encryption Password` prompt.

**Steps**
1. Clear the field and click `Submit`; screenshot.
2. Type `1234567` and click `Submit`; screenshot.
3. Type `TEST_ENCRYPTION_PASSWORD`, submit; in `Confirm Password` type `different-password` and submit; screenshot.
4. Click `Cancel` on `Confirm Password`; screenshot.
5. Start again and click `Cancel` on `Set Encryption Password`.
6. Start again, use `button "Show password"` on the first prompt, screenshot, then `button "Hide password"`.

**Expected**
- Step 1: `Password required.`; step 2: `Password not strong enough.`; both keep the dialog open.
- Step 3: `Passwords do not match` under the confirm field; the dialog stays open.
- Step 4: a red toast `Password confirmation failed`; the landing screen stays, nobody is logged in.
- Step 5: the prompt closes; still logged out.
- Step 6: the eye button shows the typed text and its tooltip toggles between `Show password` and `Hide password`.

**Cleanup:** none.

### TC-AUTH-021 · Log in with the VFX browser extension
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** The VerifiedX browser extension is installed in the automation Chrome profile, unlocked, and holds a testnet account. Otherwise mark the case `skipped`.

**Steps**
1. Open the login sheet and click `button "VFX Extension"`. Approve the request in the extension.
2. In `Enter Wallet Password` type a wrong password into `textbox "Wallet Password"`, click `Submit`; screenshot.
3. Repeat, reject the request in the extension; screenshot.
4. Lock the extension and repeat; screenshot.
5. Repeat with the correct extension password.

**Expected**
- The prompt body reads `Enter the password you used in the VFX Extension to decrypt your private key.`
- Wrong password: `Decryption failed. Check your password.`; rejected: `Request cancelled`; locked extension: `Please unlock your extension wallet first`; no answer: `Request timed out`.
- The correct password logs in with the extension's account, no extra password prompt is shown, and the web wallet's unlock password is the extension password.

**Cleanup:** Sign out.

**Open question:** the suite has no extension fixture or variable for its password; decide whether this case stays manual.

## Web unlock, lock and session

### TC-AUTH-022 · Unlock after a reload
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Logged in as account A (TC-AUTH-016).

**Steps**
1. Reload with `http://localhost:42069/?automation=1`.
2. `read_page`, screenshot `TC-AUTH-022-locked`.
3. Click `button "Enter Password"` (key `auth:enter_password`).
4. `await fltA11y.type("Password", TEST_ENCRYPTION_PASSWORD)` (field key `auth:password`), click `button "Submit"` (key `auth:password_submit`).

**Expected**
- The landing screen shows `Unlock wallet for:` and the address `TEST_VFX_A_ADDRESS`, a `Enter Password` button and an underlined `Logout`; `Login / Create Account` is not shown.
- The prompt is titled `Enter Password` with `Enter your password to decrypt your stored keys.`
- After submitting, the dashboard opens with account A's balance, without the welcome dialog.

**Cleanup:** none.

### TC-AUTH-023 · Wrong or empty password on unlock
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Locked auth screen as in TC-AUTH-022 step 2.

**Steps**
1. Click `Enter Password`, clear the field, click `Submit`; screenshot.
2. Type `wrong-password-123`, click `Submit`; screenshot.

**Expected**
- Step 1: `Password is required.`; the dialog stays open.
- Step 2: the dialog closes with a red toast `Incorrect password`; the screen still shows `Unlock wallet for:` and nothing is decrypted.

**Cleanup:** Unlock with the right password.

### TC-AUTH-024 · Return to the same page after unlocking
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. Click `button "Transactions"` in the side nav (the URL hash ends with `dashboard/transactions`).
2. Reload with `?automation=1`, then unlock with `TEST_ENCRYPTION_PASSWORD`.

**Expected**
- After unlocking, the Transactions screen opens, not the Home tab.

**Cleanup:** none.

### TC-AUTH-025 · Lock Wallet from the account menu
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. Click `Select Account` at the top of the side nav (`fltA11y.tap("Select Account")`); screenshot the menu.
2. Click `Lock Wallet`.
3. Open `http://localhost:42069/?automation=1` again and `read_page`.
4. Unlock with `TEST_ENCRYPTION_PASSWORD`.

**Expected**
- The menu lists the stored accounts, `Add Account`, `Manage Accounts`, `Language` (with `Auto`, `EN` or `ES`) and `Lock Wallet`.
- Lock Wallet loads `/`; the auth screen shows `Unlock wallet for:` with account A's address.
- Unlocking restores account A with the same balance.

**Cleanup:** none.

### TC-AUTH-026 · Idle timeout warning and auto-lock
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as account A, tab visible, mouse outside the page.

**Steps**
1. Leave the page untouched for 10 minutes; wait up to 11 minutes for `Session Timeout Warning` (screenshot to force frames).
2. Click `button "Stay Logged In"`.
3. Wait another 10 minutes for the warning, then do nothing for 20 seconds; screenshot.
4. Unlock with `TEST_ENCRYPTION_PASSWORD`, wait for the warning again and click `button "Lock Now"`.

**Expected**
- The dialog is titled `Session Timeout Warning` with `Your session will be locked due to inactivity. Do you want to stay logged in?` and `This dialog will auto-lock in 15 seconds.`, buttons `Lock Now` and `Stay Logged In`.
- Stay Logged In keeps the session and restarts the 10-minute timer.
- Without an answer the wallet locks after 15 seconds: the auth screen shows `Unlock wallet for:`. The page is not reloaded, so `?automation=1` still applies.
- Lock Now locks immediately the same way; after unlocking, the page that was open before the lock is shown again.

**Cleanup:** none.

### TC-AUTH-027 · Logout from the unlock screen
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Locked auth screen (TC-AUTH-022 step 2).

**Steps**
1. Click `button "Logout"` (key `auth:logout`).
2. Open `http://localhost:42069/?automation=1` and `read_page`.

**Expected**
- The landing screen shows `Login / Create Account` and no `Unlock wallet for:`; stored keys and all saved accounts are gone (logging in again needs a full import).

**Cleanup:** Log in again as account A (TC-AUTH-016) for later cases.

### TC-AUTH-028 · Resume Session link
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. In the address bar, open `http://localhost:42069/?automation=1#/` without reloading the session state (edit only the hash if possible).
2. `read_page`; if `button "Resume Session"` (key `auth:resume_session`) is shown, click it.

**Expected**
- When the auth screen is reached with keys in memory, it shows `Resume Session`, which opens the dashboard without a password or welcome dialog.

**Cleanup:** none.

**Open question:** the auth screen pushes an authenticated session straight to the dashboard when the path is `/`, so it is unclear which user path shows `Resume Session`. Confirm the intended trigger.

## Web sign out

### TC-AUTH-029 · Sign out from the side nav
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. Click `button "Sign Out"` in the side nav (key `nav:sign_out`); screenshot the dialog.
2. Click `button "Cancel"`.
3. Click `Sign Out` again and then `button "Logout"`.
4. Open `http://localhost:42069/?automation=1` and `read_page`.

**Expected**
- The dialog is titled `Sign Out` with `Are you sure you want to logout of the VFX Web Wallet?`, `Cancel` and a red `Logout`.
- Cancel keeps the session.
- Logout reloads `/`; the landing screen shows `Login / Create Account` with no unlock prompt, and every stored account is removed.

**Cleanup:** Log in again as account A.

### TC-AUTH-030 · Sign out from the dashboard and the Addresses tab
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as account A, window wider than 580 px.

**Steps**
1. On the Home tab click the `Sign Out` action in the action row (`fltA11y.tap("Sign")`); screenshot; click `Cancel`.
2. Hover the `Addresses` tab at the bottom-left (Claude in Chrome mouse move) until the panel opens; click its `Sign Out` button; screenshot; click `Cancel`.
3. Repeat step 2 and confirm with `Logout`.

**Expected**
- Both entry points open the same `Sign Out` dialog as TC-AUTH-029; Cancel keeps the session; Logout returns to the landing screen with no stored accounts.

**Cleanup:** Log in again as account A.

## Web multiple accounts

### TC-AUTH-031 · Add a second account
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Logged in as account A with encrypted storage (any login from this suite).

**Steps**
1. Click `Select Account`, then `Add Account`.
2. In the login sheet click `VFX Private Key`, import `TEST_VFX_B_PRIVKEY`, and set and confirm `TEST_ENCRYPTION_PASSWORD`.
3. Click `Select Account` again; screenshot the menu.

**Expected**
- The dashboard switches to account B (address `TEST_VFX_B_ADDRESS`).
- The menu lists `Account 1` and `Account 2`, each with a small edit (rename) button, and the checkbox is ticked on `Account 2`. With only one stored account the row reads `Default Account` and has no rename button.

**Cleanup:** none.

**Open question:** adding an account stores a new password hash for the wallet. If the second account is given a different password than the first, which one does the unlock screen accept afterwards, and can the first account still be switched to? The suite uses the same password for both until this is settled.

### TC-AUTH-032 · Add Account on a legacy unencrypted session
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** A browser holding keys saved by a wallet version before encryption (unencrypted `WEB_KEYPAIR` in storage). Otherwise mark `skipped`.

**Steps**
1. Click `Select Account`, then `Add Account`.

**Expected**
- An info dialog titled `Web Wallet Now Uses Encryption` explains that the user must sign out and log in again, with `Okay`; the login sheet does not open.

**Cleanup:** none.

**Open question:** the suite has no fixture for a legacy unencrypted session; confirm whether one should be built or the case dropped.

### TC-AUTH-033 · Switch between accounts
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** TC-AUTH-031 done; account B active.

**Steps**
1. Click `Select Account`, then `Account 1`.
2. In `Enter Account Password` type `wrong-password-123`, click `Submit`; screenshot.
3. Repeat step 1 and enter `TEST_ENCRYPTION_PASSWORD`.
4. Wait up to 30 seconds and compare the VFX card and the `Addresses` tab.

**Expected**
- The prompt has label `Account Password` and body `Enter the password for this account to decrypt its private keys.`
- Wrong password: red toast `Failed to decrypt account keys. Check your password.`; account B stays active.
- Right password: the dashboard shows account A (`TEST_VFX_A_ADDRESS`) and its balance; the checkbox moves to `Account 1`. Selecting the already active account does nothing.

**Cleanup:** none.

### TC-AUTH-034 · Rename an account
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Two stored accounts.

**Steps**
1. Open `Select Account` and tap the edit button next to `Account 2` (`fltA11y.tap("Rename Account")`).
2. Clear the field, click `Submit`; screenshot.
3. Type `qa-<run id>-B`, click `Submit`, and open `Select Account` again.

**Expected**
- The prompt is `Rename Account` with `What would you like to name this account?` and label `Account Name`.
- An empty name shows `Account Name is required.`
- The menu shows `qa-<run id>-B` instead of `Account 2`, also after a reload and unlock.

**Cleanup:** none.

### TC-AUTH-035 · Manage Accounts sheet
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Two stored accounts, account A active.

**Steps**
1. Open `Select Account` → `Manage Accounts`; screenshot.
2. On account B's card tap the copy button next to its VFX address (`fltA11y.tap("Copy address")`).
3. Tap `Set Active` on account B and enter `TEST_ENCRYPTION_PASSWORD`.

**Expected**
- The sheet is titled `Manage Accounts` and shows a card per account with its VFX, Vault and BTC addresses, each with copy and reveal buttons, plus `Backup Keys` and `Forget`; `Set Active` appears only on the inactive account; `Add Account` sits at the bottom.
- Copy shows `Address copied to clipboard` and the clipboard holds `TEST_VFX_B_ADDRESS`.
- Set Active switches to account B after the password.

**Cleanup:** none.

### TC-AUTH-036 · Forget an account
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Two stored accounts, account B active.

**Steps**
1. Open `Manage Accounts`, tap `Forget` on account A's card; screenshot; confirm `Forget`.
2. Tap `Forget` on the remaining account B; screenshot; confirm `Forget & Logout`.
3. Open `http://localhost:42069/?automation=1`.

**Expected**
- Step 1: dialog `Forget Account 1` with `Are you sure you want to remove this account from your wallet?`; after confirming only account B remains and stays active.
- Step 2: dialog `Forget Account 2` with `Are you sure you want to remove this account from your wallet? Since you have no other accounts, you will be logged out.` and a red `Forget & Logout`; confirming signs out.
- The landing screen shows `Login / Create Account`.

**Cleanup:** Log in again as account A.

## Web key reveal and backup

### TC-AUTH-037 · Reveal and copy the VFX private key
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Logged in as account A, window wider than 580 px.

**Steps**
1. Hover the `Addresses` tab at the bottom-left until the panel opens.
2. Open the three-dot menu on the `VFX` row; screenshot; click `Reveal Private Key`.
3. In `Reveal Private Key?` click `Reveal`.
4. In `Confirm Password` type `TEST_ENCRYPTION_PASSWORD` (field key `auth:password`), click `Submit`.
5. Screenshot, click `button "Copy private key"`, compare the clipboard with `TEST_VFX_A_PRIVKEY` (never paste it into results), then `button "Copy address"`, then `button "Done"`.

**Expected**
- The row menu has `Copy Address` and `Reveal Private Key`.
- The confirm dialog says `Are you sure you want to reveal your private key for this account?`.
- The password prompt says `Enter your password to reveal private keys.`
- The key dialog shows `Here are your account details. Please ensure to back up your private key in a safe place.`, `Address` and `Private Key` (plus `Recovery Mnemonic` for a mnemonic account). Copy private key shows `Private key copied to clipboard` and the value matches the imported key; Copy address shows `Public key copied to clipboard`.

**Cleanup:** Clear the clipboard.

**Open question:** the VFX reveal passes no reveal flag, so its title reads `Key Generated` instead of `Keys` (the BTC reveal shows `Keys`). Confirm which title is intended.

### TC-AUTH-038 · Reveal the Vault account keys and restore code
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. In the `Addresses` panel open the menu on the `Vault` row, `Reveal Private Key`, `Reveal`.
2. Enter `TEST_ENCRYPTION_PASSWORD`; screenshot.
3. Click `button "Copy restore code"`, then `button "Copy All"`, then `Done`.

**Expected**
- The password prompt says `Enter your password to reveal Vault account private keys.`
- The dialog `Vault Account Details` shows `Address`, `Private Key`, `Recovery Address`, `Recovery Private Key` and `Restore Code`, each with a copy button (`Copy address`, `Copy private key`, `Copy recovery address`, `Copy recovery private key`, `Copy restore code`).
- Toasts: `Restore Code copied to clipboard`, then `Vault Account Data copied to clipboard`.

**Cleanup:** Clear the clipboard.

### TC-AUTH-039 · Reveal the BTC keys
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. In the `Addresses` panel open the menu on the `BTC` row, `Reveal Private Key`, `Reveal`, enter `TEST_ENCRYPTION_PASSWORD`.
2. Screenshot, click `button "Copy WIF private key"`, then `Done`.

**Expected**
- The dialog is titled `Keys` with `Here are your BTC account details. Please ensure to back up your private key in a safe place.` and shows `Address`, `WIF Private Key` and `Private Key`.
- Copy WIF shows `WIF private key copied to clipboard`.

**Cleanup:** Clear the clipboard.

### TC-AUTH-040 · Reveal keys with a wrong password
**Platforms:** Web · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. Start a VFX reveal (TC-AUTH-037 steps 1–3) and enter `wrong-password-123`.

**Expected**
- A red toast `Incorrect password`; no key dialog opens.

**Cleanup:** none.

### TC-AUTH-041 · Reveal keys of an inactive account
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Two stored accounts, account A active.

**Steps**
1. Open `Manage Accounts`. Several nodes share the label `Reveal Private Key`, so use `fltA11y.list()` to find the one on the row of account B's VFX address and click its centre.
2. Enter `wrong-password-123`; screenshot.
3. Repeat and enter `TEST_ENCRYPTION_PASSWORD`; screenshot, `Done`.

**Expected**
- The prompt is `Enter Account Password` with `Enter the password for this account to decrypt and view its private keys.`
- Wrong password: `Failed to decrypt account keys. Check your password.`
- Right password: a key dialog for `TEST_VFX_B_ADDRESS`; account A stays active.

**Cleanup:** none.

### TC-AUTH-042 · Backup keys to a text file
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. In the `Addresses` panel click `Backup`; screenshot the sheet.
2. Tap `Backup Keys`, enter `TEST_ENCRYPTION_PASSWORD`.
3. Check the browser's downloads for the new text file and read its section headings only.
4. Repeat from the welcome dialog's `Backup Keys` button after a fresh login, and from `Manage Accounts` → `Backup Keys`.

**Expected**
- The sheet shows `Backup Keys` with `Export and save all your VFX Vault and BTC private keys & addresses to a text file.` (no `Backup Media` row on web).
- The password prompt says `Enter your password to backup your keys.`
- A text file downloads, the toast says `Keys backed up successfully.`, and the file has the sections `VFX Account:`, `VFX Vault Account:` and `BTC Account:`.

**Cleanup:** Delete the downloaded file.

## Desktop accounts

### TC-AUTH-043 · First run with no accounts
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Fresh data folder, booted to the dashboard, snapshot prompt answered `No`.

**Steps**
1. Screenshot the dashboard.
2. Tap the account tab at the bottom-left: `tap-text "Select Account"`; screenshot.
3. `tap-key nav:smart_contracts`; screenshot.

**Expected**
- The VFX balance card shows `0 Addresses`; the BTC card shows `0 Accounts`.
- The account panel opens with the `All` / `VFX` / `BTC` switch, `[Restore Hidden]`, `Add Account` and the empty text `No VFX Accounts` (or `No Accounts` / `No BTC Accounts` for the other modes).
- Smart Contracts shows a red toast `An account is required to access this section.` and stays on the Dashboard.

**Cleanup:** none.

**Open question:** with no accounts the VFX card heading stays `Loading...` because the total balance is only set when the account list is not empty. Confirm whether `0 VFX` is expected instead.

### TC-AUTH-044 · Restore an HD wallet from a recovery phrase
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Fresh data folder with no accounts (the button only shows then), wallet not encrypted.

**Steps**
1. `tap-key nav:operations`, `tap-text "Account Security"`; screenshot.
2. `tap-key hd:restore`.
3. `tap-key hd:restore_submit` with the field empty; screenshot.
4. `tap-key hd:restore_phrase`, `type <TEST_MNEMONIC>`, `tap-key hd:restore_submit`.
5. Add an account (TC-AUTH-045 steps 1–3) and record its address.

**Expected**
- `Restore HD Account` is visible only while the wallet has no accounts.
- The prompt is `Input Recover Phrase` with label `Recovery Phrase`; empty submit shows `Recovery Phrase is required.`
- A valid phrase shows `HD Account restored. Keys will now be generated deterministically based on phrase.`
- Accounts created afterwards are derived from the phrase: on a second fresh folder the same steps give the same first address.

**Cleanup:** none.

### TC-AUTH-045 · Create a new VFX account
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** CLI started, wallet unlocked or not encrypted.

**Steps**
1. Open the account panel (`tap-text "Select Account"` or `tap-label "Selected VFX Address"`), `tap-text "Add Account"` (manual tap when the panel is empty, since the empty state repeats the button).
2. If the `Add New Account` chooser appears (mode `All`), `tap-text VFX`.
3. In `Add VFX Account` `tap-text Create`.
4. Screenshot the result, `tap-label "Copy private key"`, then `tap-text Done`.

**Expected**
- The chooser lists `Create` (`Create a new VFX account`) and `Import` (`Import an existing VFX private key`).
- A dialog `Account Created` shows `Here are your wallet details. Please ensure to back up your private key in a safe place.` with `Address` and `Private Key`; copy shows `Private Key copied to clipboard`.
- The new account appears in the list, becomes the selected account (bottom-left tab shows its address), and the VFX card count goes up by one.

**Cleanup:** Clear the clipboard.

### TC-AUTH-046 · Import a VFX private key
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** CLI started and synced.

**Steps**
1. Open the account panel, `Add Account` → (`VFX`) → `tap-text Import`.
2. `type <TEST_VFX_A_PRIVKEY>`, `tap-text Submit`.
3. In `Rescan Blocks?` `tap-text Yes`.
4. Wait up to 5 minutes for the balance: screenshot every 30 seconds.

**Expected**
- The prompt is `Import Wallet` with label `Private Key` and a `Bulk Import` link in the title.
- The rescan question reads `Would you like to rescan the chain to include any transactions relevant to this key?` with `No` / `Yes`.
- Account A (`TEST_VFX_A_ADDRESS`) is added and selected; its balance, at least 200 VFX, shows in the list and on the VFX card.

**Cleanup:** none.

### TC-AUTH-047 · VFX private key import rejects bad input
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** `Import Wallet` prompt open.

**Steps**
1. `tap-text Submit` with the field empty; screenshot.
2. `type zzzz1234`, `tap-text Submit`, answer `No` to the rescan; screenshot.
3. Open the prompt again and `type abc-!def`; screenshot the field.

**Expected**
- Step 1: `Private Key is required.`
- Step 2: a red toast `No account found`; no account is added.
- Step 3: the field only keeps letters and digits (`abcdef`).

**Cleanup:** none.

### TC-AUTH-048 · Bulk import several keys
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Account B is not in the wallet yet (hide it first if needed).

**Steps**
1. Open `Import Wallet` and `tap-text "Bulk Import"`.
2. Tap the text area and `type` `TEST_VFX_B_PRIVKEY` and `TEST_VFX_A_PRIVKEY` on two lines.
3. `tap-text Import`; screenshot; confirm with the dialog's `Import` (manual tap, the sheet's button has the same text); `tap-text Yes` for the rescan.

**Expected**
- The sheet is `Bulk Account Importer` with `Paste in your private keys. Each key should be a separate line.`
- The confirm dialog `Confirm Import` says `Would you like to proceed with importing 2 keypairs?`; the rescan question says `…relevant to these keys?`.
- A toast `2 keypairs imported!`; account B appears; account A is not duplicated.

**Cleanup:** none.

### TC-AUTH-049 · Import a BTC private key
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** CLI started. Detailed BTC flows are in `04-btc-vbtc.md`.

**Steps**
1. Open the account panel, switch to `BTC` (`tap-text BTC`), `tap-text "Add Account"`, `tap-text Import`.
2. Tap the `Private Key` field, `type <TEST_BTC_WIF>`, `tap-text Import`.
3. Repeat with `not-a-key`.

**Expected**
- The dialog is `Import BTC Private Key` with `Paste in your BTC private key to import your account.`
- A valid key shows `Private Key Imported!` or `Private Key Imported! Please wait until <time> for the balance to sync.`, and `TEST_BTC_ADDRESS` is listed.
- An invalid key shows `A problem occurred.`

**Cleanup:** none.

### TC-AUTH-050 · Switch the selected account
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Accounts A and B in the wallet, A selected.

**Steps**
1. Open the account panel; `tap-key vfx_wallet_<TEST_VFX_B_ADDRESS>_false`.
2. Screenshot; open Send (`tap-key nav:send`) and check the sender shown.
3. Quit (TC-AUTH-008) and start the app again; screenshot the bottom-left tab.

**Expected**
- The ticked checkbox moves to account B; the bottom-left tab shows B's address and `[<balance> VFX]` with tooltip `Selected VFX Address`.
- Screens that act on the current account (Send, Receive) use account B.
- After the restart account B is still selected.

**Cleanup:** Select account A again.

### TC-AUTH-051 · Reveal a desktop VFX private key
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Only account A listed in VFX mode (hide others or use a folder with one account, so the tooltip is unique), wallet unlocked.

**Steps**
1. Open the account panel, `tap-label "Reveal Private Key"`.
2. Screenshot, `tap-label "Copy private key"`, compare the clipboard with `TEST_VFX_A_PRIVKEY`, `tap-text Close`.

**Expected**
- A dialog `Private Key` shows the key, which equals the imported key; copy shows `Private Key copied to clipboard`.
- If the node refuses, a red toast shows the node's message or `The node did not return a private key.` and no dialog opens.

**Cleanup:** Clear the clipboard.

### TC-AUTH-052 · Hide an account and restore it
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Accounts A and B listed.

**Steps**
1. Open the account panel, `tap-text "[Restore Hidden]"` with nothing hidden; screenshot; `tap-text Okay`.
2. On account B's row tap the trash button (`tap-label "Hide Account"`; the tooltip repeats on every row, so hide the other rows first or tap B's button by coordinates from a screenshot); screenshot; `tap-text Hide`.
3. `tap-text "[Restore Hidden]"`; screenshot; `tap-text "Restore Selected"` without ticking anything.
4. `tap-text "[Restore Hidden]"`, then `tap-text "Restore All"`.
5. Manual check (the checkboxes have no key): hide B, open `[Restore Hidden]`, tick B's address and use `Restore Selected`.

**Expected**
- Nothing hidden: `No Accounts to Restore` / `You have no hidden accounts.`
- The hide dialog is `Hide Account` / `Are you sure you want to hide this account?` with `Cancel` and a red `Hide`; B disappears from the list and from the address count.
- The restore dialog is `Select Account(s) to Restore` with a checkbox per hidden address, `Restore All`, `Cancel`, `Restore Selected`. Restore Selected with nothing ticked leaves B hidden; Restore All and Restore Selected with B ticked bring B back with its balance.

**Cleanup:** none.

### TC-AUTH-053 · Backup all keys to a file
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Accounts A and B, wallet unlocked.

**Steps**
1. `tap-key nav:operations`, `tap-text "Account Security"`, `tap-text Backup`; screenshot.
2. `tap-text "Backup Keys"`. If a `Notice` dialog appears, screenshot and close it.
3. In the macOS save panel accept the default name (for example `osascript -e 'tell application "System Events" to keystroke return'`).
4. Open the saved file and check its headings only.

**Expected**
- The sheet lists `Backup Keys` (`Export and save all your VFX and BTC private keys & addresses to a text file.`) and `Backup Media` (`Zip and export your NFT media assets.`).
- With vault accounts present, `Notice` says `Please note that Reserve/Protected Accounts will not be exported.`
- The save panel proposes `vfx-keys-backup-<y>-<m>-<d>.txt`; afterwards the toast says `Keys backed up successfully.`
- The file lists each VFX account's `Address:`, `Public Key:` and `Private Key:`, a `FOR BULK IMPORT:` block, and `BTC Accounts:` when BTC accounts exist.

**Cleanup:** Delete the saved file.

**Open question:** `drive.dart` cannot drive the native save panel; confirm the `osascript` keystroke is acceptable or mark the save step manual.

### TC-AUTH-054 · Create an HD account (recovery phrase)
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Wallet not encrypted.

**Steps**
1. Operations → `Account Security` → `tap-text "Create HD Account"`; screenshot.
2. `tap-text "12 Words"`; screenshot `Recovery Phrase Generated`.
3. `tap-text "Copy to Clipboard"`, then `tap-text Done`; screenshot; `tap-text Cancel`.
4. `tap-text Done`, then `tap-text "Agree and Close"`.

**Expected**
- The `HD Account` dialog explains the feature (`By creating an HD account you are creating a function to recover your private keys by use of recovery phrase.` …) and offers `12 Words`, `24 Words` and `Cancel`.
- The result dialog says `Copy your recovery phrase to a secure location.` and shows a 12-word `Recovery Phrase`; copy shows `Mnemonic copied to clipboard`.
- `Done` asks `Close Recovery Phrase?` / `Are you sure you have copied your recovery phrase to a secure location?`; Cancel keeps the phrase visible; `Agree and Close` closes it.

**Cleanup:** Clear the clipboard.

**Open question:** behaviour when the wallet already has an HD seed (after TC-AUTH-044) is not handled in the GUI; confirm whether the CLI replaces the seed or refuses.

## Desktop encryption, lock and unlock

### TC-AUTH-055 · Encrypt Wallet with no accounts
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Fresh data folder with no accounts.

**Steps**
1. Operations → `Account Security` → `tap-text "Encrypt Wallet"`.

**Expected**
- A red toast `No keys to encrypt.`; no prompt opens.

**Cleanup:** none.

### TC-AUTH-056 · Encrypt the wallet
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Accounts A and B imported, keys backed up. This is irreversible for the automation data folder; run it after the unencrypted desktop cases above (HD create needs an unencrypted wallet).

**Steps**
1. Operations → `Account Security` → `tap-text "Encrypt Wallet"`; screenshot.
2. `type <TEST_ENCRYPTION_PASSWORD>`, `tap-text Agree`.
3. In `Confirm Password` `type <TEST_ENCRYPTION_PASSWORD>`, `tap-text Submit`.
4. Screenshot the Account Security row.

**Expected**
- The first prompt is `Encrypt Wallet` with label `Create Password`, the warning `This function will encrypt ALL private keys in this wallet…` and buttons `Cancel` / `Agree`.
- The confirm prompt says `Please confirm your encryption password.`
- `Loading...` shows while the CLI encrypts, then `Your wallet is now encrypted.`; the button now reads `Lock Wallet`.
- `Create HD Account` now answers `You can not create an HD account with an encrypted wallet.`

**Cleanup:** Later areas run with an encrypted wallet and answer `Unlock Account` prompts with `TEST_ENCRYPTION_PASSWORD`.

**Open question:** confirm the release pass should encrypt the shared automation wallet, or whether encryption cases get their own data folder.

### TC-AUTH-057 · Encrypt Wallet password mismatch and cancel
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Unencrypted wallet with accounts (a second fresh folder if TC-AUTH-056 already ran).

**Steps**
1. `Encrypt Wallet`, `type pass-one-123`, `Agree`, then `type pass-two-123`, `Submit`; screenshot.
2. `Encrypt Wallet`, `type pass-one-123`, `Agree`, then `tap-text Cancel` on `Confirm Password`; screenshot the Account Security row.

**Expected**
- Step 1: red toast `Your passwords do not match. Please try again.`; the button still reads `Encrypt Wallet`.
- Step 2: the wallet stays unencrypted.

**Cleanup:** none.

**Open question:** the code only compares passwords when the confirm prompt returns a value, so cancelling it (step 2) goes on to encrypt with the first password. If step 2 encrypts the wallet, log it as a bug.

### TC-AUTH-058 · Lock the wallet
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Encrypted and unlocked wallet, not validating.

**Steps**
1. Operations → `Account Security` → `tap-text "Lock Wallet"`; screenshot.

**Expected**
- Toast `Your wallet is now locked.`; within 10 seconds the button reads `Unlock Wallet`.
- While validating, the button instead shows `You can not lock your wallet while validating.`

**Cleanup:** none.

### TC-AUTH-059 · Unlock with the Unlock Wallet button
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Encrypted and locked wallet.

**Steps**
1. `tap-text "Unlock Wallet"`, `type wrong-password-123`, `tap-text Submit`; screenshot.
2. `tap-text "Unlock Wallet"`, `tap-text Submit` with the field empty; screenshot.
3. Clear and `type <TEST_ENCRYPTION_PASSWORD>`, `tap-text Submit`.

**Expected**
- The prompt is `Unlock Wallet` with label `Password` and a `Show password` eye button.
- Wrong password: `Incorrect decryption password.`; the button still reads `Unlock Wallet`.
- Empty: `Password is required.`
- Right password: `Wallet has been unlocked for 10 minutes.` and the button reads `Lock Wallet`.

**Cleanup:** none.

### TC-AUTH-060 · Password prompt on a guarded action while locked
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** Encrypted and locked wallet, account A only row in VFX mode.

**Steps**
1. Open the account panel, `tap-label "Reveal Private Key"`.
2. `tap-key auth:password`, `type wrong-password-123`, `tap-key auth:password_submit`; screenshot.
3. Repeat step 1, `type <TEST_ENCRYPTION_PASSWORD>`, `tap-key auth:password_submit`.
4. Lock again and start `Add Account` → `Create`; cancel the prompt with `tap-text Cancel`.

**Expected**
- The prompt is `Unlock Account` with label `Password`.
- Wrong password: `Incorrect decryption password.`; no key is shown.
- Right password: `Account unlocked for 10 minutes.`, then the `Private Key` dialog.
- Cancelling the prompt aborts the guarded action silently.

**Cleanup:** none.

### TC-AUTH-061 · The wallet relocks after the unlock window
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Encrypted wallet, just unlocked.

**Steps**
1. Leave the app on Operations → `Account Security` for 11 minutes; screenshot.

**Expected**
- The button returns to `Unlock Wallet` (the GUI polls the CLI every 10 seconds), and guarded actions prompt again.

**Cleanup:** none.

**Open question:** the 10-minute window is enforced by the CLI; confirm the expected relock time.

### TC-AUTH-062 · Restart with an encrypted wallet
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Encrypted wallet.

**Steps**
1. Quit (TC-AUTH-008) and start the app again.
2. Wait up to 5 minutes for the dashboard; screenshot. Check the account list and Operations → `Account Security`.

**Expected**
- Boot completes to the dashboard, accounts and balances load, and the button reads `Unlock Wallet`; guarded actions prompt as in TC-AUTH-060.

**Cleanup:** none.

**Open question:** when the CLI reports that a startup password is required, the session stops before loading and sets a flag that no screen reads (the `UnlockWallet` screen with `Encryption Password Required to continue validating.` is never shown). Confirm what the user should see in that state.
