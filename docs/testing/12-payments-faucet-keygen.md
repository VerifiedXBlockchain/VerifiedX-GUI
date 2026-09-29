# 12 · Payments, faucet and key generation

This area covers the features that reach outside the VFX chain or that no other file owns: the Butterfly launcher and Butterfly payment links, the Get VFX / Get BTC on-ramp gateways (MoonPay, Banxa, Crypto.com, testnet faucets), the SMS-verified VFX faucet, and the leftovers under `lib/features` (the hidden π button, the raw transaction service and the web balance-expander provider). Web key generation, import and recovery are covered in `01-launch-auth.md`. Several of these can only be partly automated: the provider iframes do not render under `?automation=1`, the faucet needs an SMS code only a person can read, and some screens have no entry point in 7.0.2. Each case says which of these applies. The vBTC to Base bridge is out of scope for this suite.

## Area preconditions

- macOS cases run against the Flutter Driver build (`make run_macos_driver`), CLI running and testnet synced; web cases run at `http://localhost:42069/?automation=1` unless a case says to use the deployed testnet web wallet. See `docs/automation.md`.
- Provider pages (MoonPay, Banxa, Crypto.com, Butterfly web app) are third-party. Cases open them and check that the right page loads for the right network, and never enter card details or complete a purchase.
- Butterfly login builds a URL that carries account A's private key encrypted with a password. Never screenshot, log or paste that URL; take evidence of the Butterfly tab only after its address bar has changed or with the address bar out of frame.
- The faucet sends real testnet VFX after an SMS check. Its request step is automatable; the verification step needs Tyler (or whoever owns the faucet phone) to read the code, so those cases are marked **Needs a person for the SMS code**.
- The driver build (and `make run_web_automation`) runs in debug mode. There, `widgetGuardWalletIsSynced` lets unsynced wallets through with `Please wait until your wallet is synced with the network. In debug mode, you shall pass.`, and the new-password prompts are prefilled with the debug password from `DEBUG_ENCRYPTION_PASSWORD`; clear the field before typing. A release web build served from `build/web` has neither behaviour.


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
- `5.0 VFX Required` reads `There is a 5.0 VFX cost (plus TX fee) to create a BTC domain.`, then the faucet explanation, then `Would you like to proceed?`, with `No Thanks` and `Continue`.
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
- Empty phone: the field shows `required phone number` (the package's English default, lowercase). Invalid phone: `Invalid phone number`.
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
