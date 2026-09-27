# 12 · Base bridge, payments, faucet and key generation

This area covers the features that reach outside the VFX chain or that no other file owns: the vBTC to Base bridge (desktop only, which on testnet locks vBTC on the VFX testnet and mints vBTC.b on Base Sepolia, chain id 84532, with explorer links to `sepolia.basescan.org`), the Butterfly launcher and Butterfly payment links, the Get VFX / Get BTC on-ramp gateways (MoonPay, Banxa, Crypto.com, testnet faucets), the SMS-verified VFX faucet, the standalone web key generator (`lib/features/keygen`), and the leftovers under `lib/features` (the hidden π button, the connector animation, the raw transaction service and the web balance-expander provider). Several of these can only be partly automated: the provider iframes do not render under `?automation=1`, the faucet needs an SMS code only a person can read, and some screens have no entry point in 7.0.2. Each case says which of these applies.

## Area preconditions

- macOS cases run against the Flutter Driver build (`make run_macos_driver`), CLI running and testnet synced; web cases run at `http://localhost:42069/?automation=1` unless a case says to use the deployed testnet web wallet. See `docs/automation.md`.
- Bridge cases need, from `04-btc-vbtc.md`: a version 2 vBTC token owned by account A with a confirmed vBTC balance of at least 0.0002 vBTC (enough for two small bridges), and account A selected. The CLI must be built with the Base bridge configured for Base Sepolia.
- Bridge cases also need ETH on Base Sepolia at account A's derived Base gas address (shown in the bridge form), at least 0.0005 ETH (`BRIDGE_MIN_ETH_FOR_GAS`), and a destination Base Sepolia address that the team controls. Neither is in the README's test data yet; see the open questions in TC-MISC-002 and TC-MISC-009.
- Provider pages (MoonPay, Banxa, Crypto.com, Butterfly web app) are third-party. Cases open them and check that the right page loads for the right network, and never enter card details or complete a purchase.
- Butterfly login builds a URL that carries account A's private key encrypted with a password. Never screenshot, log or paste that URL; take evidence of the Butterfly tab only after its address bar has changed or with the address bar out of frame.
- The faucet sends real testnet VFX after an SMS check. Its request step is automatable; the verification step needs Tyler (or whoever owns the faucet phone) to read the code, so those cases are marked **Needs a person for the SMS code**.
- The driver build (and `make run_web_automation`) runs in debug mode. There, `widgetGuardWalletIsSynced` lets unsynced wallets through with `Please wait until your wallet is synced with the network. In debug mode, you shall pass.`, and the new-password prompts are prefilled with the debug password from `DEBUG_ENCRYPTION_PASSWORD`; clear the field before typing. A release web build served from `build/web` has neither behaviour.


## Base bridge: entry and preflight

### TC-MISC-001 · Bridge to Base button on the vBTC token detail
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Account A owns a v2 vBTC token with a positive balance, and, if available, a second v2 token (or a v1 token) for the negative checks.

**Steps**
1. `tap-key nav:vbtc_tokens` and open the v2 token's detail with its `Details` button (as in `04-btc-vbtc.md`).
2. Screenshot the action buttons and hover target: `get-text label:"Bridge vBTC to Base (vBTC.b)"`.
3. Open a v1 token's detail, or a v2 token with a zero balance, and screenshot its buttons.

**Expected**
- On a v2 token owned by the selected account there is a `Bridge to Base` button with a swap icon and the tooltip `Bridge vBTC to Base (vBTC.b)`.
- Below the action buttons a `Bridge History` section is rendered for v2 tokens.
- On a v2 token with a zero balance the button is disabled and its tooltip reads `No vBTC available to bridge`.
- On v1 tokens and on tokens the account does not own there is no `Bridge to Base` button and no `Bridge History`.

**Cleanup:** none.

### TC-MISC-002 · Bridge dialog preflight loads
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** no

**Preconditions:** On the v2 token detail (TC-MISC-001).

**Steps**
1. `tap-text "Bridge to Base"` (the button; the dialog title has the same text only after it opens).
2. Screenshot while loading if the spinner is visible.
3. `wait-for-text "Amount to bridge" --timeout 30`.
4. Screenshot the whole form.

**Expected**
- The dialog is titled `Bridge to Base` with a close button (`bridge:close`, tooltip `Close`).
- While loading it shows a spinner with `Checking your accounts…` and a `Cancel` button.
- The form shows the one-way notice `Bridging is one-way from this app. Once vBTC.b is on Base, use your DeFi provider or another Base (EVM) wallet to manage, transfer, or exit.`, the `Amount to bridge` field (`bridge:amount`, suffix `vBTC`) with a `Max` button, `Available: <amount> vBTC`, the `Base (EVM) Address` field (`bridge:destination`, hint `0x…`) with `Paste the destination address from your DeFi provider or Base wallet.`, the gas section, `Show details`, `Cancel` and `Review Bridge`.
- The gas section is titled `Gas (paid on Base)` with a `Refresh` link, `Your gas address` (a 0x address with a `Copy address` icon), and `Current balance` as `<n.nnnnnn> ETH` or `—`.

**Cleanup:** Leave the dialog open for TC-MISC-003.

**Open question:** The bridge needs a Base Sepolia destination address and ETH on account A's derived gas address. Proposed new variable `TEST_BASE_SEPOLIA_ADDRESS` (the destination, public) in `accounts.env`, and a note in the README on who keeps the derived gas address funded and from which Base Sepolia faucet.

### TC-MISC-003 · Bridge amount validation
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Bridge form open (TC-MISC-002). A valid destination typed so only amount errors show: `tap-key bridge:destination`, `type <TEST_BASE_SEPOLIA_ADDRESS>`.

**Steps**
1. Leave the amount empty and `tap-key bridge:review`.
2. `tap-key bridge:amount`, `type 0`, `tap-key bridge:review`.
3. `type 1000`, `tap-key bridge:review`.
4. `type 0.0001`, screenshot.
5. Try to enter letters: `type abc` and read the field back with `get-text key:bridge:amount`.

**Expected**
- No errors show before the first Review press.
- Empty: `Amount is required`. Zero: `Enter a positive amount`. More than available: `Exceeds available (<available> vBTC)`.
- Typing in the field clears its error immediately.
- The field only accepts digits and one decimal point, so the letters from step 5 are rejected and the previous value stays.

**Cleanup:** Leave the dialog open.

**Open question:** `drive.dart type` replaces the field through the text input channel; confirm the input formatter still rejects `abc` that way (if the driver bypasses formatters, check step 5 manually).

### TC-MISC-004 · Bridge destination validation
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Bridge form open, a valid amount typed (`0.0001`).

**Steps**
1. Clear the destination (`tap-key bridge:destination`, `type ""` or select-all and delete) and `tap-key bridge:review`.
2. `type 0x1234`, `tap-key bridge:review`.
3. Type `TEST_VFX_A_ADDRESS` (a VFX address), `tap-key bridge:review`.

**Expected**
- Empty: `Base address is required`.
- Too short and non-EVM: `Must be a valid 0x Base address (40 hex chars)` in both cases.
- The dialog stays on the form.

**Cleanup:** Leave the dialog open.

### TC-MISC-005 · Max fills the available amount
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Bridge form open.

**Steps**
1. `tap-key bridge:max`.
2. `get-text key:bridge:amount`.

**Expected**
- The amount equals the `Available: <amount> vBTC` value, formatted with up to 8 decimals and no trailing zeros (for example `0.0005`, not `0.00050000`).

**Cleanup:** Clear the amount.

### TC-MISC-006 · Gas section: copy, refresh and low-balance text
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Bridge form open.

**Steps**
1. `tap-label "Copy address"` (the first match is the gas address; if "Too many elements", check visually).
2. `tap-text Refresh`.
3. Screenshot the section.

**Expected**
- Copy shows the toast `Copied to clipboard`.
- Refresh re-runs the preflight without clearing the typed amount or destination; the form also refreshes by itself every 10 seconds.
- With 0 ETH the section is amber with a warning icon and reads `This address pays the gas fee for the mint transaction on Base. Send a small amount of Base ETH (≈ 0.001 ETH) to the address above before bridging. …`. With some ETH but less than 0.0005 it is amber and reads `Low balance — gas costs vary. Top up the address above if the mint fails.`. At or above 0.0005 ETH the border is neutral, the gas-station icon shows, and the low-balance text still reads `Low balance — gas costs vary. …` (the copy only switches on zero).

**Cleanup:** none.

**Open question:** The zero-ETH text says the address can be funded from any exchange "that supports withdrawing to Base mainnet", which is wrong on testnet (Base Sepolia). Should the copy become network-aware? Also, the low-balance sentence shows even when the balance is healthy; is that intended?

### TC-MISC-007 · Bridge network details
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Bridge form open.

**Steps**
1. `tap-text "Show details"`.
2. Screenshot the `Network info` box.
3. `tap-label "View on Basescan"` on the Contract row.
4. `tap-text "Hide details"`.

**Expected**
- The box lists `Network` (the CLI's network name, `Base` when none), `Contract` (0x address with copy and Basescan icons), `Your Base address` (with copy), `ETH for gas` and `vBTC.b balance` (`<amount> vBTC.b` or `—`).
- On testnet the Basescan icon opens `https://sepolia.basescan.org/address/<contract>`; on mainnet it would open `https://basescan.org/address/<contract>`.
- `Hide details` collapses the box.

**Cleanup:** none.

### TC-MISC-008 · Review screen and Back keeps the values
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Bridge form open with amount `0.0001` and `TEST_BASE_SEPOLIA_ADDRESS`.

**Steps**
1. `tap-key bridge:review`.
2. Screenshot.
3. `tap-key bridge:back`.
4. `get-text key:bridge:amount` and `get-text key:bridge:destination`.

**Expected**
- The confirmation reads `You're about to bridge`, then `0.0001 vBTC` / `from VFX`, an arrow, `0.0001 vBTC.b` / `to 0x1234…abcd on Base` (first 6 and last 4 characters of the destination) and the full destination in monospace.
- `This will:` lists `1. Lock your 0.0001 vBTC on VFX`, `2. Wait for validator signatures`, `3. Submit a mintWithProof transaction on Base (paid from your derived Base address)`, then `Estimated time: 2–5 minutes once submitted.` and the reminder `Reminder: this is one-way from this app. …`.
- Buttons are `Back` (`bridge:back`) and `Confirm & Bridge` (`bridge:confirm`).
- Back returns to the form with both values still filled.

**Cleanup:** Close the dialog with `tap-key bridge:close`.

## Base bridge: execution and history

### TC-MISC-009 · Bridge vBTC to Base Sepolia end to end
**Platforms:** macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** As TC-MISC-002, the gas address holding at least 0.0005 Base Sepolia ETH, and the token holding at least 0.0001 vBTC available. This locks real testnet vBTC and mints vBTC.b on Base Sepolia (chain id 84532).

**Steps**
1. Open the bridge dialog, `type 0.0001` into `bridge:amount`, the destination into `bridge:destination`, `tap-key bridge:review`.
2. `tap-key bridge:confirm`. If the wallet is encrypted, enter `TEST_ENCRYPTION_PASSWORD` when prompted.
3. `wait-for-text "VFX lock submitted" --timeout 60` and screenshot the stepper.
4. Poll with a screenshot every minute. Wait up to 15 minutes for `wait-for-text "Bridged to Base" --timeout 900`; if the `Taking longer than expected. …` warning appears after 5 minutes, keep waiting until the 15-minute limit.
5. Screenshot the result, then `tap-label "Copy address"`.
6. `tap-text "View on Basescan"` (the outlined button).
7. `tap-key bridge:done`.

**Expected**
- While submitting, `Confirm & Bridge` shows a spinner, `Back` is disabled, and the close button's tooltip changes to `Bridging…` and is disabled.
- The progress view shows `<amount> vBTC → <short destination>`, `Lock ID: <id>`, and a stepper: `VFX lock submitted` (with `Tx: <short hash>` and copy / open icons), `Confirmed on VFX` (`Block height: <n>`), `Collecting validator signatures…` then `Validator signatures collected` (`<collected> / <required> signatures collected`), `Submitting mint on Base` (`Tx: <short hash>`), `Minted on Base`. Under it: `Safe to close this dialog — your bridge will continue in the background. Track progress in Bridge History.`
- The result shows `Bridged to Base`, `You now have 0.0001 vBTC.b on Base`, `at <destination>` with copy and Basescan icons, a `What's next?` box (`Earn yield via Base DeFi`, `Transfer to another Base address`, `Exit back to vBTC on VFX or directly to BTC …`), and the buttons `View on Basescan` and `Done`.
- Copy shows `Copied to clipboard`. View on Basescan opens `https://sepolia.basescan.org/tx/<base tx hash>` (or `/address/<destination>` if the record has no Base hash), where the mint shows as successful.
- After Done, the token's available vBTC is 0.0001 lower and `Bridge History` lists the bridge as `Minted`.

**Cleanup:** none. The vBTC.b stays at the destination on Base Sepolia.

**Open question:** Which Base Sepolia address receives the minted vBTC.b (`TEST_BASE_SEPOLIA_ADDRESS` proposed above), and should a later case exit it back to vBTC, or is exit out of scope for the GUI?

### TC-MISC-010 · Close the dialog mid-bridge and follow it in history
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** As TC-MISC-009, with another 0.0001 vBTC available.

**Steps**
1. Start a 0.0001 bridge as in TC-MISC-009 steps 1 and 2.
2. As soon as `VFX lock submitted` shows, `tap-key bridge:close`.
3. Screenshot the `Bridge History` section.
4. Wait up to 15 minutes, tapping the history `Refresh` icon (`tap-label Refresh`) every 2 minutes, until the row's badge reads `Minted`.

**Expected**
- Closing is allowed once the lock is submitted and the bridge keeps going.
- The new row is at the top: `0.0001 vBTC → 0x1234…abcd`, a relative time such as `just now` or `3m ago`, and an amber in-flight badge (`Locking`, then `Awaiting signatures`, then `Minting`).
- Within 15 minutes the badge turns green and reads `Minted`. The list refreshes by itself every 30 seconds while a row is in flight.

**Cleanup:** none.

### TC-MISC-011 · Bridge history detail
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** At least one bridge in `Bridge History` (TC-MISC-009).

**Steps**
1. Tap the row (`tap-text "0.0001 vBTC → <short destination>"`).
2. Screenshot the `Bridge details` dialog.
3. `tap-label "Copy transaction hash"` (first match, the VFX lock hash).
4. `tap-text Close`.

**Expected**
- The dialog is titled `Bridge details` and shows the same header and stepper as the live progress view, read-only, with no `Safe to close` note and no result screen.
- Copy shows `Copied to clipboard`.
- The VFX lock row's open icon opens `https://spyglass-testnet.verifiedx.io/transaction/<hash>`; the Base mint row's opens `https://sepolia.basescan.org/tx/<hash>`.
- Close returns to the token detail.

**Cleanup:** none.

**Open question:** Both open icons in the stepper are labelled `View on Basescan`, including the one that opens the VFX explorer. Should the VFX row use a VFX-explorer label (which would also let `tap-label` target each one)?

### TC-MISC-012 · Bridge history empty state
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** A v2 vBTC token owned by account A that has never been bridged.

**Steps**
1. Open that token's detail and screenshot `Bridge History`.

**Expected**
- While loading: `Loading bridge history…`.
- Then: `No bridge operations yet.`
- If the bridge service is down and nothing is cached, an error box with a `Try again` button replaces the list.

**Cleanup:** none.

### TC-MISC-013 · Retry a failed mint from history
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** A bridge record in `Failed` state whose VFX lock is confirmed on chain. This cannot be produced on demand; run it only when such a record exists (for example after a mint failed for lack of gas).

**Steps**
1. Fund the gas address if the failure was gas.
2. On the failed row `tap-text Retry`; enter the password if prompted.
3. Wait up to 15 minutes with the history refresh as in TC-MISC-010.

**Expected**
- The failed row has a red `Failed` badge and an outlined `Retry` button; rows without a confirmed lock have no Retry.
- After Retry the button shows a spinner, then the toast `Retry submitted. Watching for status updates.` and the row goes back to an in-flight badge, ending `Minted`.
- If the retry call fails the toast reads `Retry failed. See history detail for status.`

**Cleanup:** none.

**Open question:** Is there a reliable way to produce a failed-but-locked record on testnet (for example bridging with an empty gas address)? If so, the case can move to P1 with that setup.

### TC-MISC-014 · Bridge blocked while the wallet is locked
**Platforms:** macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Wallet encrypted with `TEST_ENCRYPTION_PASSWORD` (from `01-launch-auth.md`) and locked (`Lock Wallet` under Operations > Account Security).

**Steps**
1. Open the v2 token detail and `tap-text "Bridge to Base"`.
2. Wait up to 30 seconds and screenshot.
3. `tap-text Close`.

**Expected**
- The dialog shows `Bridge unavailable — your Base address couldn't be derived. This usually means the wallet is locked. Unlock your wallet and try again.` with a single `Close` button.
- After unlocking, the same dialog shows the normal form.

**Cleanup:** Unlock the wallet if later cases need it unlocked.

**Open question:** Confirm the CLI reports "no derived address" for a locked encrypted wallet; if it instead fails the whole preflight, the expected message is the generic `Couldn't load bridge info.` (or the CLI's own message) with `Cancel` and `Retry`.

### TC-MISC-015 · Bridge blocked states from preflight
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Opportunistic; each part needs a specific backend state.

**Steps**
1. Part A (bridge service unreachable, for example with networking off): open the bridge dialog.
2. Part B (a v2 token whose BTC deposit is still unconfirmed, right after funding it in `04-btc-vbtc.md`): open the bridge dialog.
3. Part C (CLI without Base configuration): open the bridge dialog.

**Expected**
- Part A: `Couldn't reach the bridge service. Check your connection and try again.` with `Cancel` and `Retry`.
- Part B: `Nothing available to bridge yet.` followed by the explanation about Bitcoin confirmations and in-flight reservations, with `Close` and `Try again`; if the CLI returned an error reading the balance, instead `Couldn't read your vBTC balance: <error>`.
- Part C: `Bridging is currently unavailable. The CLI is not configured to talk to Base.` with `Close` only.

**Cleanup:** Restore networking after Part A.

### TC-MISC-016 · Bridge is not offered on the web wallet
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Web logged in as an account that owns a v2 vBTC token.

**Steps**
1. Open vBTC Tokens (`button "vBTC Tokens"` in the side nav) and open the v2 token's detail.
2. `read_page` and search for `Bridge`.

**Expected**
- No `Bridge to Base` button and no `Bridge History` section exist on web; the bridge is desktop only in 7.0.2.

**Cleanup:** none.

## Butterfly

### TC-MISC-017 · Launch BFLY options dialog
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Logged in (web) or an account selected (macOS).

**Steps**
1. Open the dialog. Web: click `button "Launch BFLY"` in the side nav. macOS: `tap-key nav:butterfly`.
2. Screenshot.
3. Close it. Web: click the close button (`button "Close"`). macOS: `tap-label Close`.

**Expected**
- The dialog is titled `Launch Butterfly` and reads `Butterfly makes sending payments simple. Save, Spend, and Pay Anyone, Anywhere, Anytime. Instantly. No Borders, No Restrictions, No Limits, and No Accounts Needed… Be Free!` then `Auto-login with this account?` (the shorter text on a mobile-width window ends at `Instantly.` before the question).
- Buttons: `Just Take Me There` and `Login with this Account`.
- Close dismisses it with nothing opened.

**Cleanup:** none.

### TC-MISC-018 · Just Take Me There opens Butterfly
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** As TC-MISC-017.

**Steps**
1. Open the dialog and click `Just Take Me There` (web: `button "Just Take Me There"`; macOS: `tap-text "Just Take Me There"`).
2. Check the new tab / browser window.

**Expected**
- Testnet builds open `https://testnet.befree.io`; mainnet builds open `https://befree.io`. The URL carries no credentials.
- The wallet stays on the page it was on.

**Cleanup:** Close the Butterfly tab.

### TC-MISC-019 · Login with this Account: password prompts
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Account A logged in / selected. On macOS, if the wallet is encrypted, `TEST_ENCRYPTION_PASSWORD` is needed first to read the private key.

**Steps**
1. Open the dialog and click `Login with this Account`.
2. macOS encrypted wallet only: enter `TEST_ENCRYPTION_PASSWORD` in the account-password prompt.
3. In `Create Butterfly Password`, clear the field (debug builds prefill it), submit it empty (`Submit`), then type `abc` and submit.
4. Type `TEST_ENCRYPTION_PASSWORD` and submit.
5. In `Confirm Password`, type `abc` and submit, then `Cancel`.

**Expected**
- The first prompt is titled `Create Butterfly Password`, labelled `New Password`, with the text `Create a password to securely transfer your credentials to Butterfly. You will need to enter this same password on the Butterfly website.`
- Empty: `Password required.` Weak: `Password not strong enough.`
- A mismatched confirmation shows `Passwords do not match` on the field.
- Cancelling the confirmation shows the toast `Password confirmation failed` and nothing opens.

**Cleanup:** none.

### TC-MISC-020 · Login with this Account opens Butterfly logged in
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** As TC-MISC-019. Read the security note in Area preconditions before taking any evidence.

**Steps**
1. Repeat TC-MISC-019 steps 1, 2 and 4, then enter the same password in `Confirm Password` and submit.
2. In `Login to Butterfly`, `Cancel` first, then repeat step 1 and click `Open Butterfly`.
3. On the Butterfly page, enter the same password when it asks, and confirm it shows account A.

**Expected**
- The confirm dialog is titled `Login to Butterfly` with `You are about to open Butterfly and log in with:`, account A's address, `Continue?`, and buttons `Cancel` / `Open Butterfly`. Cancel opens nothing.
- Open Butterfly opens `https://testnet.befree.io/…` in a new tab or the default browser; after the password, Butterfly shows account A's address.
- If URL generation fails the toast reads `Failed to generate login URL: <error>`.

**Cleanup:** Log out of Butterfly and close its tab.

**Open question:** Should Butterfly use its own password variable instead of reusing `TEST_ENCRYPTION_PASSWORD`? And which Butterfly testnet account state is expected after login (empty wallet is fine)?

### TC-MISC-021 · Create Payment Link entry point on Send
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Account A selected, chain synced (macOS).

**Steps**
1. Open Send. Web: `button "Send"` in the side nav. macOS: `tap-key nav:send`.
2. Screenshot below the send form.
3. Switch the send form to BTC (as in `03-send-receive-transactions.md`) and screenshot again.
4. Switch back to VFX and click `Create Payment Link` (web: `button "Create Payment Link"`; macOS: `tap-text "Create Payment Link"`).

**Expected**
- With VFX selected, the Butterfly logo lockup and an outlined `Create Payment Link` button show under the send form; with BTC selected they are hidden.
- The button opens a `Payment Link` screen with the intro `Use Butterfly to create a payment link, claimable by anyone you send the link to.`, an `Amount (VFX)` field (hint `Enter amount`, `Available: <balance> VFX`), a `Message (Optional)` field (hint `What's this payment for?`), an icon selector and a `Create Payment Link` button.
- On macOS in a release build with the chain still syncing, the button shows `Please wait until your wallet is synced with the network` instead (the debug driver build shows the debug variant and continues).

**Cleanup:** none.

### TC-MISC-022 · Payment link amount validation
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** On the `Payment Link` screen (TC-MISC-021).

**Steps**
1. Submit with the amount empty.
2. Amount `abc` (if the field accepts it), then `0`.
3. Amount larger than account A's balance.
4. Amount `0.00001`.

**Expected**
- Empty: `Amount is required`. Non-numeric or zero: `Please enter a valid amount`. Over balance: `Insufficient balance`. Below the minimum: `Minimum amount is 0.0001 VFX`.
- No confirmation dialog opens while any error shows.

**Cleanup:** none.

### TC-MISC-023 · Create a Butterfly payment link
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** On the `Payment Link` screen with account A holding at least 2 VFX. This sends real testnet VFX to Butterfly's escrow.

**Steps**
1. Amount `1`, message `qa-<run id>`, pick any icon, click `Create Payment Link`.
2. In `Confirm Details`, click `Cancel`; repeat step 1.
3. Click `Create Link`. Web: enter `TEST_ENCRYPTION_PASSWORD` if the unlock prompt appears.
4. Wait up to 5 minutes for the title `Payment Link Ready`, screenshotting every minute.
5. Click `Copy Link`, then `Done`.

**Expected**
- `Confirm Details` lists `Amount` (`1.00000000 VFX`), `Estimated Fee`, `Total`, `Message` (`qa-<run id>`) and `From` (account A's address shortened to 8 + `...` + 8 characters), with `Cancel` and `Create Link`. Cancel sends nothing.
- After Create Link the title changes to `Sending VFX` (`Sending VFX...`), then `Waiting for Confirmation` (`Waiting for deposit confirmation...` / `This may take up to 20 seconds.`), then `Payment Link Ready` with `Payment link created successfully!`, the short link URL, `Copy Link` and `Share Link`.
- Copy Link shows `Link copied to clipboard!`.
- Account A's balance drops by 1 VFX plus the fee, and the send appears in Transactions within 2 minutes.
- If confirmation takes over 5 minutes the dialog switches to `Error` with `Timeout waiting for deposit confirmation. The link was created but may need manual verification.` and `Close` / `Try Again`.

**Cleanup:** Claim the link from a second browser profile into account B, or record the link in the run notes so the 1 VFX can be recovered later.

**Open question:** Does the Butterfly API (`api.befree.io`, called with `is_testnet: true`) honour testnet links end to end, including claiming? And the history view (`Payment Link History`, `No payment links yet`) is commented out of the form; is it meant to ship?

## On-ramp gateways

### TC-MISC-024 · Get VFX on testnet offers only the testnet faucet
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Testnet build, account A logged in / selected.

**Steps**
1. Click the dashboard's `Get VFX` button. Web: `button "Get VFX"` on the home screen. macOS: `tap-text "Get VFX"` on the Dashboard.
2. Screenshot the `Choose Payment Gateway` sheet.
3. Click `Testnet Faucet`.

**Expected**
- The sheet `Choose Payment Gateway` lists only `Testnet Faucet` (MoonPay, Banxa and Crypto.com are off for VFX, and Stripe is off).
- `Testnet Faucet` has no terms dialog and opens `https://testnet.rbx.network/faucet` in a new tab / the default browser.

**Cleanup:** Close the opened tab.

**Open question:** `https://testnet.rbx.network/faucet` is the old RBX domain; does it still resolve to a working VFX testnet faucet? If not, should this gateway open the in-app SMS faucet (TC-MISC-031) instead?

### TC-MISC-025 · Get VFX on mainnet reports no gateway
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no · **Tags:** Mainnet smoke

**Preconditions:** Mainnet build (production web wallet or a normal desktop build), logged in read-only.

**Steps**
1. Click `Get VFX` on the dashboard (or `Get VFX` in the top balance card, whose label wraps as `Get` / `VFX`).

**Expected**
- No sheet opens; the toast reads `Payment not available in this environment`, because every VFX on-ramp is disabled on mainnet and the testnet faucet only exists on testnet.

**Cleanup:** none.

### TC-MISC-026 · Get BTC gateway sheet and terms dialog
**Platforms:** Web, macOS · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Testnet build, a BTC account selected (web: logged in with a BTC key or with a BTC keypair present).

**Steps**
1. Click `Get BTC` on the dashboard.
2. Screenshot the sheet.
3. Click `Moonpay`.
4. In `Disclaimer`, click `Confirm` without ticking the box.
5. Click `Cancel`.
6. Open the sheet again, click `Banxa`, tick `I have read and agree to the disclaimer.` and screenshot, then `Cancel`.

**Expected**
- The sheet lists `Moonpay`, `Banxa` and `Testnet Faucet`.
- The `Disclaimer` dialog shows the gateway's text: `I understand that I will now be purchasing VFX or BTC native coin directly through MoonPay (` + link `www.moonpay.com` + `), which is a third-party services platform. …` with `Terms of Use` and `Privacy Policy` links and a support link, plus the checkbox `I have read and agree to the disclaimer.` and buttons `Cancel` / `Confirm`.
- Confirm without the box ticked shows the toast `You must agree to the terms before proceeding.` and keeps the dialog open.
- Cancel closes it and nothing opens.

**Cleanup:** none.

### TC-MISC-027 · Get BTC testnet faucet
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** As TC-MISC-026.

**Steps**
1. Click `Get BTC`, then `Testnet Faucet`.

**Expected**
- No terms dialog; `https://mempool.space/testnet4/faucet` opens in a new tab / the default browser.

**Cleanup:** Close the tab.

### TC-MISC-028 · MoonPay sandbox purchase page opens (read-only)
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** As TC-MISC-026. Web runs against the deployed testnet web wallet, not `?automation=1`, unless the MoonPay overlay turns out to render in automation mode.

**Steps**
1. `Get BTC` > `Moonpay`, tick the disclaimer, `Confirm`.
2. Screenshot the MoonPay page or overlay.
3. Close it without entering any details.

**Expected**
- macOS opens a MoonPay URL in the default browser, signed by the onramp service (or unsigned as a fallback), in the sandbox environment, with the BTC address prefilled.
- Web opens the MoonPay widget in sandbox mode with the BTC address prefilled.
- Closing it returns to the wallet with no toast.

**Cleanup:** none.

**Open question:** The web MoonPay widget is started through a JS SDK (`moonPayBuy`) rather than an `HtmlElementView`; does it render under `?automation=1`? If so this case can run on the local automation build.

### TC-MISC-029 · Banxa sandbox purchase page opens (read-only)
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** As TC-MISC-026. The web part embeds an iframe, which does not render under `?automation=1`, so it runs on the deployed testnet web wallet, read-only.

**Steps**
1. `Get BTC` > `Banxa`, tick the disclaimer, `Confirm`.
2. Screenshot.
3. Web: click `Close` under the iframe. macOS: close the browser tab.

**Expected**
- macOS opens `https://rbx.banxa-sandbox.com/?coinType=BTC&fiatType=USD&coinAmount=…&blockchain=BTC&walletAddress=<BTC address>` in the default browser.
- Web opens a dialog with the Banxa sandbox iframe, the gateway disclaimer under it and a `Close` button. On the automation build the dialog opens but the iframe area is blank, which is expected.

**Cleanup:** none.

### TC-MISC-030 · Crypto.com on-ramp stays hidden
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Preconditions:** Logged in as account A.

**Steps**
1. Check the side nav and both Get VFX / Get BTC sheets for Crypto.com.

**Expected**
- No `Crypto.com` side-nav entry (`nav:crypto_com` does not exist) and no `Crypto.com` gateway, because `CRYPTO_DOT_COM_ENABLED` is false.

**Cleanup:** none.

## Faucet

### TC-MISC-031 · Faucet offer when creating a BTC domain without enough VFX
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** Web session with a BTC keypair and a VFX balance below 5.001 VFX.

**Steps**
1. Open Domains (`button "Domains"`), go to the BTC domain section and click `button "Create Domain"`.
2. In the create dialog, click `Continue` (shown instead of the normal submit when the balance is too low).
3. In `5.0 VFX Required`, click `No Thanks`.
4. Repeat steps 1 and 2 and click `Continue` in `5.0 VFX Required`.

**Expected**
- `5.0 VFX Required` reads `There is a 5.0 VFX cost (plus TX fee) to create a BTC domain.`, then the faucet explanation, then `Woud you like to proceed?` (spelling as shipped), with `No Thanks` and `Continue`.
- `No Thanks` shows the toast `Not enough VFX in your account to create a BTC domain. 5.0 VFX required (plus TX fee).` and closes the create dialog.
- `Continue` opens an info dialog `VFX Faucet` containing the faucet form (TC-MISC-032); closing it shows `Please wait for your balance to arrive before continuing.`

**Cleanup:** Close the dialogs.

**Open question:** We need a web account with under 5.001 VFX. Proposed variable `TEST_WEB_EMPTY_EMAIL` / `TEST_WEB_EMPTY_PASSWORD` (a login that is never funded except by this faucet), or should the case log in with a fresh key generated in `01-launch-auth.md`? Also, after `No Thanks` the code pops the dialog but does not return, so it still goes on to open the `VFX Faucet` dialog; is that a bug to fix, or should the case expect it?

### TC-MISC-032 · Faucet form and phone validation
**Platforms:** Web · **Priority:** P1 · **Moves funds:** no

**Preconditions:** `VFX Faucet` dialog open (TC-MISC-031).

**Steps**
1. Screenshot the form.
2. Click `Request VFX` (`faucet:request`) with the phone empty.
3. Type an invalid number (`123`) into `Phone Number` (`faucet:phone`) and click `Request VFX`.
4. Click `Cancel`.

**Expected**
- The form shows `VFX Address: <address>` in the accent colour, `Amount: 6.0 VFX`, a `Phone Number` field with a country selector, and `Cancel` / `Request VFX`.
- Empty phone: the field shows `Required phone number`. Invalid phone: `Invalid phone number`.
- Cancel closes the dialog.

**Cleanup:** none.

**Open question:** The phone field's messages come from the `phone_form_field` package, whose localization delegate is not registered in `app.dart`. Confirm on a run that the English defaults above appear rather than an error or a key name.

### TC-MISC-033 · Request VFX from the faucet and verify by SMS
**Platforms:** Web · **Priority:** P1 · **Moves funds:** yes

**Preconditions:** As TC-MISC-031. **Needs a person for the SMS code.** The faucet phone number has not been used on the faucet within its rate-limit window.

**Steps**
1. Choose the phone's country, type the faucet phone number into `faucet:phone`, click `Request VFX`.
2. `wait-for` the `Verification Code` field (`faucet:verification_code`), up to 30 seconds.
3. Submit with the code empty, then with `abc`.
4. Ask the phone owner for the SMS code, type it, click `Verify` (`faucet:verify`).
5. Close the `VFX Faucet` dialog and wait up to 2 minutes for the balance to increase.

**Expected**
- After the request the form switches to a single `Verification Code` field and a `Verify` button.
- Empty: `Verification Code is required.` Non-numeric: `Invalid Verification Code.`
- A correct code shows the toast `Success! Funds are on their way. TX Hash: <hash>` and the dialog closes.
- Within 2 minutes the VFX balance rises by 6.0 and the incoming transaction is listed.
- A wrong code shows the faucet service's error message as a toast and keeps the form open.

**Cleanup:** none.

**Open question:** Which phone number is the faucet test number, who reads its SMS during a run, and what is the faucet's rate limit (per phone and per address)? Proposed variable `TEST_FAUCET_PHONE` (secret, in `accounts.env`).

### TC-MISC-034 · Faucet rate limit
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Preconditions:** TC-MISC-033 just succeeded with the same phone.

**Steps**
1. Open the faucet again as in TC-MISC-031 and request with the same phone number.

**Expected**
- The request is refused: a toast shows the faucet service's rate-limit message and the form stays on the phone step (no `Verification Code` field).

**Cleanup:** none.

**Open question:** What exact message does the faucet return for a rate-limited phone? The client shows the service's `message` field verbatim, so the case needs it to assert the text.

### TC-MISC-035 · vBTC onboarding Use Faucet step
**Platforms:** Web · **Priority:** P2 · **Moves funds:** yes

**Preconditions:** Web session with no vBTC tokens (the `Use Wizard` button only shows then) and a VFX account with no balance. **Needs a person for the SMS code.**

**Steps**
1. vBTC Tokens > `Use Wizard`, advance to the `Get VFX` step.
2. Click `Use Faucet`, submit the phone prompt empty, then with `123`, then with the faucet number.
3. Enter the SMS code in `Enter verification code sent to <phone>` and submit.

**Expected**
- The step offers `Use Faucet`, `Transfer Manually` and a Get VFX button.
- The phone prompt `Phone Number` (field `Your Phone Number`) rejects empty with `Phone Number required.` and `123` with `Invalid Phone Number.`
- A valid code shows `Success! Funds are on their way. TX Hash: <hash>` and the wizard moves to waiting for the VFX transfer; the account receives 1.0 VFX within 2 minutes.

**Cleanup:** Leave the wizard; `04-btc-vbtc.md` continues from here if it owns the rest of the wizard.

**Open question:** Does `04-btc-vbtc.md` already cover the wizard's faucet step? If so this case should be dropped to avoid spending faucet quota twice.

### TC-MISC-036 · Standalone faucet screen is not reachable
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** `FaucetScreen` (with the editable `faucet:amount` field and `Max Amount: <n> VFX`) is not routed; its two entry points in `web_home_screen.dart` and `common_actions.dart` are commented out. Record `skipped` with "no entry point".

**Preconditions:** none.

**Steps**
1. Search the dashboard, side nav and Operations for a `VFX Faucet` entry.

**Expected**
- None exists. Once wired, the screen should show `The community has allocated some VFX to lower the barrier to entry …`, `Max Amount: <n> VFX`, and an `Amount` field (`faucet:amount`, default `5.0`) that rejects empty with `Amount is required.` and text with `Invalid Amount.`; without a VFX account it shows `Please choose a VFX account to continue`.

**Cleanup:** none.

**Open question:** Should the standalone faucet screen be wired back in (for example as the testnet VFX gateway in TC-MISC-024) or deleted?

## Key generation (web keygen panel)

The key generator in `lib/features/keygen/components/keygen_cta.dart` is web only and is rendered only by `HomeScreen` (`lib/features/home/screens/home_screen.dart`), which is not in either router. In 7.0.2 it therefore has no entry point. Web login key generation, private-key import and mnemonic recovery are covered in `01-launch-auth.md` through `lib/features/auth`, which reuses `KeygenService`. The cases below are written against the panel so they can run if it is routed again; until then record them `skipped` with "no entry point".

### TC-MISC-037 · Generate a keypair
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Availability:** No entry point (see section note).

**Preconditions:** The keygen panel visible under the `Keys` heading.

**Steps**
1. Click `Generate Keypair` (`keygen:generate`).
2. In `Email Address`, submit empty (`keygen:email_submit`), then `not-an-email`, then `qa-<run id>@example.com`.
3. Screenshot the `Key Generated` dialog with the private key field masked in the screenshot, or skip the screenshot.
4. Click `Done` (`keygen:done`).

**Expected**
- The email prompt (`keygen:email`) rejects empty with `Email required.` and a malformed address with `Invalid email.`
- `Key Generated` shows `Here is your account details. Please ensure to back up your private key in a safe place.`, a 12-word `Recovery Mnemonic`, a testnet `Address` and a `Private Key`, each read-only with a copy button.
- Done closes the dialog.

**Cleanup:** Discard the generated key; it is never funded.

**Open question:** Should this panel be deleted, since the email it asks for is not used to derive or store anything (generate ignores it; import passes it as an unused mnemonic argument)?

### TC-MISC-038 · Keygen copy buttons
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Availability:** No entry point (see section note).

**Preconditions:** `Key Generated` dialog open (TC-MISC-037).

**Steps**
1. Click `keygen:copy_mnemonic` (tooltip `Copy mnemonic`).
2. Click `keygen:copy_address` (tooltip `Copy address`).
3. Click `keygen:copy_private_key` (tooltip `Copy private key`).

**Expected**
- Toasts, in order: `Mnemonic copied to clipboard`, `Public key copied to clipboard` (the address button's toast says public key), `Private key copied to clipboard`.

**Cleanup:** Clear the clipboard.

### TC-MISC-039 · Import a private key in the keygen panel
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Availability:** No entry point (see section note).

**Preconditions:** Keygen panel visible.

**Steps**
1. Click `Import Private Key` (`keygen:import`) and give a valid email.
2. In `Import Wallet`, submit empty (`keygen:private_key_submit`).
3. Type `TEST_VFX_B_PRIVKEY` into `keygen:private_key` and submit.

**Expected**
- Empty: `Private Key is required.`
- The `Key Generated` dialog shows `TEST_VFX_B_ADDRESS` as the address.
- As written, `handleImport` passes the email as the keypair's mnemonic, so the dialog also shows a `Recovery Mnemonic` row containing the email address. Record this as a failure against the expected behaviour (no mnemonic row for an imported key).

**Cleanup:** Close the dialog and clear the clipboard.

### TC-MISC-040 · Recover from a mnemonic in the keygen panel
**Platforms:** Web · **Priority:** P2 · **Moves funds:** no

**Availability:** No entry point (see section note).

**Preconditions:** Keygen panel visible.

**Steps**
1. Click `Recover Account` (`keygen:recover`) and give a valid email.
2. In `Input Recovery Mnemonic`, submit empty (`keygen:mnemonic_submit`).
3. Type an invalid phrase (twelve copies of `abandon`) and submit.
4. Type `TEST_MNEMONIC` into `keygen:mnemonic` and submit.

**Expected**
- Empty: `Recovery Mnemonic is required.`
- An invalid phrase shows the generic toast `A problem occurred.`
- `TEST_MNEMONIC` shows `Key Generated` with the mnemonic and the address at index 0, matching the first HD address the web login derives from the same phrase in `01-launch-auth.md`.

**Cleanup:** Close the dialog.

## Other leftovers

### TC-MISC-041 · Hidden π button on the configuration screen
**Platforms:** macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** The button only becomes visible while the Option key is held, which `drive.dart` cannot do; run it by hand. It lives on the configuration screen (`/config`) and in the unused `Footer` widget.

**Preconditions:** The configuration screen open (as reached in `02-dashboard-navigation-settings.md`).

**Steps**
1. Hold the Option key and look at the bottom-left corner.
2. Click the `π` that appears.

**Expected**
- `π` fades in while Option is held and fades out on release; it cannot be clicked while hidden.
- Clicking it opens `<CLI API base URL>/snake` in the default browser.

**Cleanup:** Close the browser tab.

**Open question:** Is this easter egg meant to ship, and how is the configuration screen reached in 7.0.2? The only `push(ConfigContainerScreenRoute())` in the code is in `Footer`, which is not used anywhere.

### TC-MISC-042 · Connector animation assets
**Platforms:** Web, macOS · **Priority:** P2 · **Moves funds:** no

**Availability:** `ConnectorVisual`, the only user of `lib/features/image_sequencer`, is commented out in both balance rows. Record `skipped` with "not rendered".

**Preconditions:** none.

**Steps**
1. On the dashboard, look for an animated connector between the balance cards.

**Expected**
- No connector animation is shown in 7.0.2.

**Cleanup:** none.

**Open question:** Should `lib/features/image_sequencer` and the `assets/images/connector` frames be removed, since nothing renders them?
