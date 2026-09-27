---
waypoint_digest: 1
title: "VFX GUI: product decisions from the release test suite"
project: "vfx-gui"
source: "docs/testing/questions-for-tyler.review.md"
status: "completed"
reviewed_at: "2026-09-27T03:10:00.726Z"
answered: 20
flagged: 0
skipped: 0
untouched: 0
total: 20
comments: 0
synthetic: 0
---

# Digest — VFX GUI: product decisions from the release test suite

## Questions

### q1 · choice (single) · answered
**Q:** **Q1 — Full-balance send (TC-SEND-018):** Both platforms only compare the amount against the balance, so sending your entire VFX balance passes the form and is then refused by the node because nothing is left for the fee. What should the form do?
**Selected:** Automatically lower the amount to balance minus fee

### q2 · text · answered
**Q:** **Q2 — VFX decimal places (TC-SEND-019):** The send amount field accepts any number of decimals and the node decides what happens to the extra precision. How many decimal places does VFX support, and should the form reject amounts with more?
**A:** I think 16? But not sure. Check the core CLI code

### q3 · choice (single) · answered
**Q:** **Q3 — Sending to your own address (TC-SEND-021):** Today a send to your own address goes through silently and only costs the fee. What should happen?
**Selected:** Warn and let the user confirm

### q4 · choice (single) · answered
**Q:** **Q4 — Sends from a vault that is not activated (TC-VAULT-011):** The desktop blocks them with "You must activate your Vault Account before proceeding." The web wallet has no such check and leaves it to the node. Should web match the desktop?
**Selected:** Yes, add the same check on web

### q5 · choice (single) · answered
**Q:** **Q5 — BTC address check (TC-SEND-011):** The BTC send form only checks that the address field is not empty. A bad address fails later with a CLI message on desktop and a generic error toast on web. Should the form check the address format for the current network before sending?
**Selected:** Yes, validate the format (mainnet vs testnet aware)
**Note:** Yes but there are multiple types of btc addresses so we need to account for that

### q6 · choice (single) · answered
**Q:** **Q6 — Web wallet passwords (TC-AUTH-031):** Adding a second web account with a different password overwrites the wallet's password. Afterwards unlock accepts only the newest password, switching back needs the old account's password, and reveal-key prompts check the newest one. What is intended?
**Selected:** One password per account: fix unlock and reveal to use the active account's password

### q7 · choice (single) · answered
**Q:** **Q7 — Imported view-only wallets (TC-PRV-020):** On desktop privacy, Import Viewing Key succeeds, but the dashboard only follows the wallet's own shielded address, so the imported view-only wallet and its VIEW ONLY badge can never be reached. What should happen?
**Selected:** Hide Import Viewing Key for this release

### q8 · choice (single) · answered
**Q:** **Q8 — Domain on the desktop Receive screen (TC-ADNR-011):** The web Receive screen shows your domain with a copy button. The desktop only uses it inside request links and never shows it. Should the desktop show it too?
**Selected:** Yes, match web

### q9 · choice (single) · answered
**Q:** **Q9 — Token icon (TC-TOKEN-009):** Creating a fungible token requires uploading an icon image even when a Token Icon URL is typed. Should the URL alone be enough?
**Selected:** No, an uploaded image is always required (then remove or relabel the URL field)
**Note:** Remove url field

### q10 · choice (single) · answered
**Q:** **Q10 — Token links on web (TC-TOKEN-013):** Should pasting a token's detail URL into the browser open that token directly? The only working route today is `#dashboard/fungible-token/token/detail/<scId>`, and its behaviour on a fresh load is undefined.
**Selected:** Not needed for now

### q11 · choice (single) · answered
**Q:** **Q11 — Pausing a token on web (TC-TOKEN-021):** After Pause TXs, the web button still reads "Pause TXs" until the next refresh after the block, so a user may press it again. The desktop shows a pending state. Should web show one too?
**Selected:** Yes, show a pending state

### q12 · choice (single) · answered
**Q:** **Q12 — Tokens held by a vault (TC-TOKEN-034):** The desktop disables Burn for vault-held tokens but still offers Transfer. The web hides all actions because the node refuses a sender that is not the signer. Should the desktop also disable Transfer?
**Selected:** Yes, disable Transfer for vault-held tokens

### q13 · choice (single) · answered
**Q:** **Q13 — Devolving an NFT (TC-SC-041):** The NFT manage sheet has unused devolve helpers. Today both evolving and devolving go through the per-row Evolve button, which jumps to a chosen stage. What is intended?
**Selected:** The per-row Evolve button is enough; delete the unused helpers

### q14 · choice (single) · answered
**Q:** **Q14 — Closing the web contract creator (TC-SC-004):** The desktop asks "Are you sure you want to close the smart contract creator?" before discarding unsaved input. The web creator closes without asking. Should web ask too?
**Selected:** Yes

### q15 · choice (single) · answered
**Q:** **Q15 — Blocked file types on web (TC-SC-008):** The desktop refuses certain file extensions as an NFT's primary asset. The web uploads any file straight to Spyglass. Should web refuse the same extensions?
**Selected:** Yes

### q16 · choice (single) · answered
**Q:** **Q16 — Video NFTs on desktop (TC-SC-034):** The desktop NFT detail shows a video's file type and an Open Asset button, while only web has an in-app player. Is that acceptable?
**Selected:** Yes, Open Asset is enough on desktop

### q17 · choice (single) · answered
**Q:** **Q17 — Web minted list (TC-SC-046):** The web "Manage Minted" list only shows NFTs that can evolve, so a plain NFT a creator minted and transferred never appears there. Intended?
**Selected:** Yes, keep the evolving-only filter

### q18 · choice (single) · answered
**Q:** **Q18 — Bulk import image URLs on web (TC-SC-058):** The desktop downloads each image at bulk import and skips unreachable URLs. The web keeps the URL without checking it, so a dead link is only discovered at or after mint. Should web check URLs at import?
**Selected:** Yes

### q19 · choice (single) · answered
**Q:** **Q19 — Validator Pool (TC-NET-026):** The loaders for the Peer Info strip and the per-node cards are commented out, so both are always empty. The Validator screens are also hidden behind a flag in this release.
**Selected:** Leave as is until the validator screens ship

### q20 · choice (multi) · answered
**Q:** **Q20 — Unreachable code to delete now:** Each of these exists in the code but has no way in from the 7.0.2 UI. Check the ones to delete now; anything left unchecked is kept for a later release.
**Selected:** Standalone faucet screen (the faucet is reached through Get VFX), Web key generator panel (its import shows the email as a mnemonic), Connector image-sequence animation and its image frames
