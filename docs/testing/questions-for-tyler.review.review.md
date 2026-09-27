---
waypoint: 1
title: "VFX GUI: product decisions from the release test suite"
project: vfx-gui
waypoint_status: completed
reviewed_at: 2026-09-27T03:10:00.694Z
---

# Product decisions from the release test suite

The release test suite was written by reading the GUI and web wallet code. These 20 behaviours could not be settled from the code alone. Each answer goes back into the named test case's expected result, and some become small code changes. A box is pre-checked where there is a clear recommendation; change it freely.

## Sending money

<!-- wp:question id="q1" type="choice" select="single" -->
**Q1 — Full-balance send (TC-SEND-018):** Both platforms only compare the amount against the balance, so sending your entire VFX balance passes the form and is then refused by the node because nothing is left for the fee. What should the form do?
- [ ] Block it in the form with a message that the fee does not fit
- [x] Automatically lower the amount to balance minus fee
- [ ] Leave as is (node refuses it)
<!-- wp:answer status="answered" -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q2" type="text" -->
**Q2 — VFX decimal places (TC-SEND-019):** The send amount field accepts any number of decimals and the node decides what happens to the extra precision. How many decimal places does VFX support, and should the form reject amounts with more?
<!-- wp:answer status="answered" -->
I think 16? But not sure. Check the core CLI code
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q3" type="choice" select="single" -->
**Q3 — Sending to your own address (TC-SEND-021):** Today a send to your own address goes through silently and only costs the fee. What should happen?
- [ ] Block it
- [x] Warn and let the user confirm
- [ ] Allow silently, as today
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q4" type="choice" select="single" -->
**Q4 — Sends from a vault that is not activated (TC-VAULT-011):** The desktop blocks them with "You must activate your Vault Account before proceeding." The web wallet has no such check and leaves it to the node. Should web match the desktop?
- [x] Yes, add the same check on web
- [ ] No, leave web as is
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q5" type="choice" select="single" -->
**Q5 — BTC address check (TC-SEND-011):** The BTC send form only checks that the address field is not empty. A bad address fails later with a CLI message on desktop and a generic error toast on web. Should the form check the address format for the current network before sending?
- [x] Yes, validate the format (mainnet vs testnet aware)
- [ ] No, leave it to the CLI and Spyglass
<!-- wp:answer status="answered" -->
Yes but there are multiple types of btc addresses so we need to account for that 
<!-- /wp:answer -->
<!-- /wp:question -->

## Accounts

<!-- wp:question id="q6" type="choice" select="single" -->
**Q6 — Web wallet passwords (TC-AUTH-031):** Adding a second web account with a different password overwrites the wallet's password. Afterwards unlock accepts only the newest password, switching back needs the old account's password, and reveal-key prompts check the newest one. What is intended?
- [ ] One password per web wallet: Add Account reuses the existing password
- [x] One password per account: fix unlock and reveal to use the active account's password
<!-- wp:answer status="answered" -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q7" type="choice" select="single" -->
**Q7 — Imported view-only wallets (TC-PRV-020):** On desktop privacy, Import Viewing Key succeeds, but the dashboard only follows the wallet's own shielded address, so the imported view-only wallet and its VIEW ONLY badge can never be reached. What should happen?
- [ ] Let the user switch to an imported view-only wallet
- [x] Hide Import Viewing Key for this release
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->

## Tokens, domains and NFTs

<!-- wp:question id="q8" type="choice" select="single" -->
**Q8 — Domain on the desktop Receive screen (TC-ADNR-011):** The web Receive screen shows your domain with a copy button. The desktop only uses it inside request links and never shows it. Should the desktop show it too?
- [x] Yes, match web
- [ ] No
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q9" type="choice" select="single" -->
**Q9 — Token icon (TC-TOKEN-009):** Creating a fungible token requires uploading an icon image even when a Token Icon URL is typed. Should the URL alone be enough?
- [ ] Yes, either an upload or a URL
- [x] No, an uploaded image is always required (then remove or relabel the URL field)
<!-- wp:answer status="answered" -->
Remove url field
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q10" type="choice" select="single" -->
**Q10 — Token links on web (TC-TOKEN-013):** Should pasting a token's detail URL into the browser open that token directly? The only working route today is `#dashboard/fungible-token/token/detail/<scId>`, and its behaviour on a fresh load is undefined.
- [ ] Yes, support deep links to token detail
- [x] Not needed for now
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q11" type="choice" select="single" -->
**Q11 — Pausing a token on web (TC-TOKEN-021):** After Pause TXs, the web button still reads "Pause TXs" until the next refresh after the block, so a user may press it again. The desktop shows a pending state. Should web show one too?
- [x] Yes, show a pending state
- [ ] No, the delay is acceptable
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q12" type="choice" select="single" -->
**Q12 — Tokens held by a vault (TC-TOKEN-034):** The desktop disables Burn for vault-held tokens but still offers Transfer. The web hides all actions because the node refuses a sender that is not the signer. Should the desktop also disable Transfer?
- [x] Yes, disable Transfer for vault-held tokens
- [ ] No, vault token transfers should work on desktop
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q13" type="choice" select="single" -->
**Q13 — Devolving an NFT (TC-SC-041):** The NFT manage sheet has unused devolve helpers. Today both evolving and devolving go through the per-row Evolve button, which jumps to a chosen stage. What is intended?
- [x] The per-row Evolve button is enough; delete the unused helpers
- [ ] Add a dedicated Devolve button
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q14" type="choice" select="single" -->
**Q14 — Closing the web contract creator (TC-SC-004):** The desktop asks "Are you sure you want to close the smart contract creator?" before discarding unsaved input. The web creator closes without asking. Should web ask too?
- [x] Yes
- [ ] No
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q15" type="choice" select="single" -->
**Q15 — Blocked file types on web (TC-SC-008):** The desktop refuses certain file extensions as an NFT's primary asset. The web uploads any file straight to Spyglass. Should web refuse the same extensions?
- [x] Yes
- [ ] No
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q16" type="choice" select="single" -->
**Q16 — Video NFTs on desktop (TC-SC-034):** The desktop NFT detail shows a video's file type and an Open Asset button, while only web has an in-app player. Is that acceptable?
- [x] Yes, Open Asset is enough on desktop
- [ ] No, add in-app playback on desktop
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q17" type="choice" select="single" -->
**Q17 — Web minted list (TC-SC-046):** The web "Manage Minted" list only shows NFTs that can evolve, so a plain NFT a creator minted and transferred never appears there. Intended?
- [x] Yes, keep the evolving-only filter
- [ ] No, show every NFT the account minted
<!-- wp:answer status="answered" -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q18" type="choice" select="single" -->
**Q18 — Bulk import image URLs on web (TC-SC-058):** The desktop downloads each image at bulk import and skips unreachable URLs. The web keeps the URL without checking it, so a dead link is only discovered at or after mint. Should web check URLs at import?
- [x] Yes
- [ ] No
<!-- wp:answer status="answered" -->
<!-- /wp:answer -->
<!-- /wp:question -->

## Network tools and unreachable screens

<!-- wp:question id="q19" type="choice" select="single" -->
**Q19 — Validator Pool (TC-NET-026):** The loaders for the Peer Info strip and the per-node cards are commented out, so both are always empty. The Validator screens are also hidden behind a flag in this release.
- [ ] Bring the loaders back
- [ ] Remove the empty Peer Info strip and node cards
- [x] Leave as is until the validator screens ship
<!-- wp:answer status="answered" -->
<!-- /wp:answer -->
<!-- /wp:question -->

<!-- wp:question id="q20" type="choice" select="multi" -->
**Q20 — Unreachable code to delete now:** Each of these exists in the code but has no way in from the 7.0.2 UI. Check the ones to delete now; anything left unchecked is kept for a later release.
- [ ] Hidden smart contract features: Soul-Bound, Ticketing, Fractionalization, Tokenization, Pair
- [ ] Smart contract templates chooser
- [ ] Smart contract drafts (still deleted on compile even though they can't be created)
- [ ] My Smart Contracts list
- [ ] Adjudicator screen (Start only spins, Stop does nothing)
- [ ] Datanode screen
- [ ] Butterfly payment link history
- [x] Standalone faucet screen (the faucet is reached through Get VFX)
- [x] Web key generator panel (its import shows the email as a mnemonic)
- [ ] CLI configuration screen and its π easter egg (only linked from an unused footer)
- [x] Connector image-sequence animation and its image frames
<!-- wp:answer -->
<!-- /wp:answer -->
<!-- /wp:question -->
