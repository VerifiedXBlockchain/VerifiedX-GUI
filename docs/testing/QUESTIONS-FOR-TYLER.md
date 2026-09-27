# Questions for Tyler

**Answered 2026-09-27 through Waypoint** (`questions-for-tyler.review.digest.md` holds the answers verbatim). All changes are on `fix/release-bugs`. Notable: VFX amounts are capped at 8 decimal places, not 16, because the Core CLI uses 8 everywhere it fixes a precision (`GlobalsPrivacy.cs:30`, `FeeCalcService.cs:25`); tokens, token deep links, desktop video playback, the minted-list filter and Validator Pool were left as they are by decision.

These are the product decisions the test suite could not settle from the code. Everything else raised while writing the cases is either a bug (see [BUGS-TO-FIX.md](BUGS-TO-FIX.md)) or something the first test run will answer (see [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md)). A one-word answer is enough for most; each answer goes back into the named case's expected result.

## Money and sending

1. **Should the send form subtract or reserve the fee so a full-balance send is caught client-side?** (TC-SEND-018) Both platforms compare the amount against the balance only, so sending the whole balance passes the client and is then refused by the node for the missing fee.

2. **What is VFX's maximum precision, and should the form reject amounts with more decimals than that?** (TC-SEND-019) The amount field accepts any number of decimals; the node decides what happens to extra precision.

3. **Should sending to your own address be blocked, warned about, or allowed silently as today?** (TC-SEND-021) No check exists; a self-send goes through and only costs the fee.

4. **Should the web wallet block sends from a non-activated Vault the same way desktop does?** (TC-VAULT-011) Desktop blocks sends from a non-activated Vault with 'You must activate your Vault Account before proceeding.'; the web form has no such guard and leaves it to the node.

5. **Should the send form validate BTC address format (network-aware) before calling the CLI or Spyglass?** (TC-SEND-011) The BTC address field only checks non-empty. On macOS a bad address surfaces through the CLI's CalculateFee message (the exact text is a runtime check); on web it ends in a generic error toast.

## Accounts and passwords

6. **Should all accounts in a web wallet be forced to share one password (reuse the existing one on Add Account), or are per-account passwords intended?** (TC-AUTH-031) Adding an account overwrites the wallet-wide password hash and the stored primary keys with the new account's password, while each account's keys in the multi-account store stay encrypted with their own password. With different passwords, unlock accepts only the newest password and opens the newest account, switching back needs the old account's password, and reveal-key prompts check the newest password whichever account is active.

7. **Should the GUI let the user switch to an imported view-only wallet (so VIEW ONLY is reachable), or should Import Viewing Key be hidden for this release?** (TC-PRV-020) Import Viewing Key succeeds, but the dashboard only follows the stored zfx_ address, so the imported view-only wallet and its VIEW ONLY badge cannot be reached.

## Tokens, domains and NFTs

8. **Should the desktop Receive screen show the domain (with a copy button) like the web does?** (TC-ADNR-011) The web Receive screen shows the domain with a copy button; the desktop only passes the domain to the request-link buttons and never displays it.

9. **Should a Token Icon URL alone be enough to create a token, or is an uploaded image always required?** (TC-TOKEN-009) The create form requires an uploaded icon image even when a Token Icon URL is typed.

10. **Should a pasted token detail URL open the token on web, and if so on which path?** (TC-TOKEN-013) The only route is token/detail/:scId under the fungible-token tab (the older fungible/detail routes are commented out), and deep-link behaviour is not defined.

11. **Is the delay acceptable, or should the web show a pending state after pausing, as the desktop does?** (TC-TOKEN-021) After Pause TXs on web the button keeps reading 'Pause TXs' until the next 10-second refresh after the block, so a user may press it again.

12. **Should desktop disable Transfer on vault-held token rows the way it disables Burn?** (TC-TOKEN-034) Desktop disables Burn for vault-held tokens but still shows Transfer; the web hides all actions because the node refuses a sender that is not the signer. Whether the desktop CLI can sign a vault token transfer is untested.

13. **Is the per-row Evolve button the intended way to devolve (then delete the unused helpers), or should there be a dedicated Devolve button?** (TC-SC-041) NftMangementModal has evolve() and devolve() helpers (with 'Devolve?' confirm and 'Devolve transaction sent successfully!' toast) that nothing calls. Evolving and devolving both go through the per-row Evolve button (setEvolve to a specific stage).

14. **Should the web creator also confirm before discarding unsaved input?** (TC-SC-004) macOS asks 'Are you sure you want to close the smart contract creator?' before discarding input; web does not.

15. **Should web reject the same file extensions before uploading?** (TC-SC-008) macOS rejects blocked extensions for the primary asset; web FileSelector has no extension check and uploads to Spyglass directly.

16. **Is in-app video playback expected on macOS, or is Open Asset enough?** (TC-SC-034) The desktop NFT detail shows a video asset's file type and an Open Asset button; only web has a player.

17. **Should the web sender see plain (non-evolving) NFTs they minted and transferred, or is the evolving-only filter intended?** (TC-SC-046) On web, MintedNftListProvider keeps only NFTs with canEvolve, so a transferred plain NFT never shows in the sender's minted list. Whether the macOS CLI list includes it after transfer is a runtime check.

18. **Should web validate image URLs at import the way macOS does?** (TC-SC-058) macOS downloads each image at import and skips unreachable URLs; web keeps the URL as the asset location without checking it, so a dead URL is only discovered at or after mint.

## Network tools

19. **Should the Peer Info strip and node cards come back (re-enable the loaders), or be removed from Validator Pool?** (TC-NET-026) loadMasterNodes() and loadPeerInfo() are commented out in SessionProvider.mainLoop, and nothing else loads nodeListProvider or nodeInfoProvider, so the Peer Info strip and per-node cards on Validator Pool are always empty.

## Unreachable screens

20. **For each of these (feature modals, templates, drafts, My Smart Contracts, Adjudicator, Datanode, Payment Link History, standalone faucet, keygen panel, config screen/π, image sequencer): keep for a later release, wire it in now, or delete?** (TC-DASH-036, TC-SC-011, TC-SC-059, TC-SC-060, TC-SC-061, TC-NET-001, TC-MISC-023, TC-MISC-036, TC-MISC-037, TC-MISC-041, TC-MISC-042) Each of these exists in code but has no entry point in 7.0.2 (verified): the Soul-Bound, Ticketing, Fractionalization, Tokenization and Pair feature modals (commented out of Feature.allTypes); the templates chooser (TemplateChooserScreen, landing button commented out); smart contract drafts (Save as Draft, Delete and My Drafts commented out, but DELETE_DRAFT_ON_MINT still deletes drafts on compile); My Smart Contracts (compiled list, landing button commented out); the Adjudicator (Start only shows a spinner, Stop has an empty handler) and Datanode ('Activating soon.') screens, hidden by VALIDATOR_NAV_ENABLED = false; the Butterfly Payment Link History view; the standalone FaucetScreen (both entry points commented out); the web keygen panel (only rendered by HomeScreen, which neither router uses); the configuration screen and its π easter egg (only pushed from the unused Footer widget); and lib/features/image_sequencer plus the assets/images/connector frames (ConnectorVisual commented out in both balance rows).
