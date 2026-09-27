# Open questions (full index)

Every question raised while the cases were written, in case order. They have been triaged: confirmed bugs are listed in [BUGS-TO-FIX.md](BUGS-TO-FIX.md), product decisions in [QUESTIONS-FOR-TYLER.md](QUESTIONS-FOR-TYLER.md). The rest are facts only a real run can establish (exact CLI or Spyglass messages, timings, whether a service does something) or test-setup needs; the first release pass answers those and edits each case.

## [01 · Launch and authentication](01-launch-auth.md)

- **TC-AUTH-001:** the boot screen builds its log list with `getRange(start, logs.length - 1)`, so the newest log line never appears there. Confirm whether that is intended.
- **TC-AUTH-003:** the panel only shows when the CLI writes its startup progress file; confirm a hard kill reliably produces it.
- **TC-AUTH-004:** the prompt needs a testnet snapshot from `/api/snapshots/latest/?network=testnet` at least 5,000 blocks above the local height. Confirm testnet publishes one; if not, record the case as `blocked`.
- **TC-AUTH-019:** the `I don't know` detection only recognises mainnet prefixes (`1`, `3`, `bc1q`, `bc1p`). A testnet address (`tb1…`, `m…`, `n…`, `2…`) will fail step 3 with `Invalid BTC Address`. Confirm whether that is acceptable on testnet.
- **TC-AUTH-021:** the suite has no extension fixture or variable for its password; decide whether this case stays manual.
- **TC-AUTH-028:** the auth screen pushes an authenticated session straight to the dashboard when the path is `/`, so it is unclear which user path shows `Resume Session`. Confirm the intended trigger.
- **TC-AUTH-032:** the suite has no fixture for a legacy unencrypted session; confirm whether one should be built or the case dropped.
- **TC-AUTH-037:** the VFX reveal passes no reveal flag, so its title reads `Key Generated` instead of `Keys` (the BTC reveal shows `Keys`). Confirm which title is intended.
- **TC-AUTH-043:** with no accounts the VFX card heading stays `Loading...` because the total balance is only set when the account list is not empty. Confirm whether `0 VFX` is expected instead.
- **TC-AUTH-053:** `drive.dart` cannot drive the native save panel; confirm the `osascript` keystroke is acceptable or mark the save step manual.
- **TC-AUTH-054:** behaviour when the wallet already has an HD seed (after TC-AUTH-044) is not handled in the GUI; confirm whether the CLI replaces the seed or refuses.
- **TC-AUTH-056:** confirm the release pass should encrypt the shared automation wallet, or whether encryption cases get their own data folder.
- **TC-AUTH-057:** the code only compares passwords when the confirm prompt returns a value, so cancelling it (step 2) goes on to encrypt with the first password. If step 2 encrypts the wallet, log it as a bug.
- **TC-AUTH-061:** the 10-minute window is enforced by the CLI; confirm the expected relock time.
- **TC-AUTH-062:** when the CLI reports that a startup password is required, the session stops before loading and sets a flag that no screen reads (the `UnlockWallet` screen with `Encryption Password Required to continue validating.` is never shown). Confirm what the user should see in that state.

## [02 · Dashboard, navigation and settings](02-dashboard-navigation-settings.md)

- **TC-DASH-018:** there is no reliable way to make the CLI rebuild its state on demand; confirm a trigger or keep the case opportunistic.
- **TC-DASH-021:** the headings are taken from each screen's app bar title in code; some web screens hide their app bar in the desktop layout. If a heading is missing but the URL and content are right, record a pass with a note.
- **TC-DASH-033:** confirm Open Log follows the automation data folder (it builds its path through `DataHome.fromDocuments`), so it never opens the real `~/rbxtest` log.
- **TC-DASH-036:** in the current code the only link to this screen is in the `Footer` widget, which no screen uses, so the configuration screen appears unreachable. Confirm whether it should be reachable (and from where) or retired; until then record this case as `blocked`.
- **TC-DASH-042:** there is no documented way to stage a pending CLI update on testnet; confirm how to exercise the accept path.

## [03 · Send, receive and transactions](03-send-receive-transactions.md)

- **TC-SEND-011:** the client does not validate the BTC address format (only non-empty). What should a malformed BTC address produce: a CLI/Spyglass error toast, or nothing? Record the observed text.
- **TC-SEND-014:** the `amount` path parameter is declared as `double`; what should a non-numeric value do? Record what the build does.
- **TC-SEND-016:** record the exact node refusal text for step 3 on web so the next pass can assert it.
- **TC-SEND-018:** should the client reserve the fee when the amount equals the full balance? Today neither platform does.
- **TC-SEND-019:** what is VFX's maximum precision, and should the form reject extra decimals with a message? No client rule exists today.
- **TC-SEND-021:** should sending to self be blocked or warned about? No check exists today.
- **TC-SEND-023:** does the Core CLI `ValidateAddress` (macOS) and Spyglass raw path (web) resolve `.vfx` domains? If step 1 fails with `Invalid Address` or a node refusal, record it; domain sending may not be supported by this build. Is the paste stripping the dot intended?
- **TC-SEND-038:** the URL is built as `<base>/transaction/<hash>` where the base already ends in `/`, so it contains `//transaction/`. Confirm the explorer still resolves it.
- **TC-SEND-039:** the detail provider is not `.autoDispose` and is not invalidated from the session loop, unlike the convention for web detail screens, so a detail opened while pending data was stale may keep the old values until reload. Check whether reopening a recently confirmed transaction shows its final block height.

## [04 · BTC and vBTC](04-btc-vbtc.md)

- **TC-BTC-012:** on web, Continue with `Custom` and a 0 or empty value returns 0 without running the field validator. Confirm whether a 0 sat/vB send is expected to be rejected by the backend, and with what message.
- **TC-BTC-018:** which testnet address with an OP_RETURN transaction should the run use? `TEST_BTC_ADDRESS` only has one if a flow in this suite produced one. Confirm whether a vBTC V2 withdrawal or funding transaction carries OP_RETURN, or name a fixed address to import read-only.
- **TC-BTC-018:** the desktop list comes from the CLI (`GetBitcoinTXList`); confirm whether desktop needs the same check.
- **TC-BTC-024:** confirm a reliable way to force a ceremony failure on testnet for this case.
- **TC-BTC-025:** **Preconditions:** Account A with at least 1 VFX and the BTC account with balance, so the wizard skips the funding steps. The vBTC list is empty for the session, otherwise `Use Wizard` is hidden (run this case in a fresh data folder on macOS, or with an account that owns no vBTC on web). **Open question:** confirm which account to use for a wizard run when account A already owns contracts.
- **TC-BTC-036:** **Preconditions:** A default-asset V2 contract (created without media, as every contract in this suite is) owned by the web session, and a way to make the beacon upload fail. **Open question:** how to make the beacon upload fail on testnet in a controlled way.
- **TC-BTC-046:** (suspected defect, macOS):** `TokenizedBtcActionButtons` calls `VbtcV2Service().transferVbtc(fromAddress: token.rbxAddress, ...)`, and for V2 contracts `rbxAddress` is the contract's `OwnerAddress`. On a B-only node this should fail with the CLI's `Account not found`; on a node that also holds A's key it would move A's vBTC instead of B's. The withdrawal path was already changed to use the current wallet; confirm whether transfer should do the same.
- **TC-BTC-050:** **Preconditions:** A withdrawal whose Bitcoin transaction was broadcast but whose VFX completion failed (for example the network dropped during `Recording Completion`). **Open question:** confirm a reproducible way to make only the completion step fail.
- **TC-BTC-051:** cancellation needs a 75% validator vote; confirm how long the run should wait and which status the row shows while votes are pending.

## [05 · Privacy (PRISM)](05-privacy.md)

- **TC-PRV-001:** the GUI never downloads the parameters itself; it only reads `GetPlonkStatus`. Confirm the CLI's expected download size and duration on testnet, and whether a failed download is reported anywhere other than the permanent `Privacy Layer Starting Up` screen.
- **TC-PRV-005:** `ShieldedAddressNotifier.load` avoids calling the create endpoint on restart because it "would overwrite scanned data on the node". Confirm that re-activating the same account after a reset is safe for already-scanned notes, and whether a rescan is expected.
- **TC-PRV-014:** the lock only happens when the node's message contains `password`, `unauthorized` or `authentication`. Confirm the CLI's wording for a wrong privacy password so this case can assert the exact toast.

## [06 · Vault accounts](06-vault-accounts.md)

- **TC-VAULT-008:** record the CLI's exact wrong-password message so the next pass can assert it.
- **TC-VAULT-010:** the `Automatically Activate?` question is asked even when the first dialog was cancelled; is that intended? With auto-activate on, does the web wallet see the incoming Vault transaction and activate (it listens on the transaction signal)? This pass answers No so the next case can test the manual path; try Yes on the next run.
- **TC-VAULT-011:** should the web wallet block sends from a Vault that is not activated, as the desktop does (`You must activate your Vault Account before proceeding.`)? Record what the node answers.
- **TC-VAULT-015:** record the CLI's exact wrong-password message.
- **TC-VAULT-022:** the `Activate\nAccount` tile is also shown on a Vault that is already activated once it holds 5 VFX or more; is that intended, and what does activating twice return?
- **TC-VAULT-026:** is the desktop CLI restore code format the same as the web one (base64 of `private//recovery private`)? If step 3 fails, record it and retry with Vault W's restore code in TC-VAULT-027 instead.
- **TC-VAULT-027:** which password does a restored web Vault take on the desktop: any new password, or must it match something? The CLI decides; record the behaviour.
- **TC-VAULT-028:** on web an undecodable code throws inside the button handler and nothing is shown to the user; should it show an error toast? Record what appears (check the console with `read_console_messages`).
- **TC-VAULT-030:** the address copy shows `Public key copied to clipboard`; should it say the address was copied?
- **TC-VAULT-031:** record the CLI's exact refusal text.

## [07 · Domains (ADNR)](07-domains.md)

- **TC-ADNR-009:** the macOS message comes from the CLI (`/txapi/TXV1/CreateAdnr`) and the GUI shows `result.message` verbatim; the exact text is not in this repo. Record what it says on the first run and pin it here.
- **TC-ADNR-011:** the desktop Receive screen never shows the domain even though it passes it to the request-link buttons; confirm that is intended.
- **TC-ADNR-013:** the refusal text comes from Spyglass (web raw path) or the CLI (desktop); neither is in this repo. Record the text on the first run.
- **TC-ADNR-015:** the web confirmation body is hardcoded (`web_adnr_screen.dart`) and shows `Amount: 5.0 VFX` from `ADNR_COST` and `Fee: <fee> RBX`, and appends `.vfx` to the stored domain, which may already end in `.vfx`. Confirm the expected wording; this case records what is shown.
- **TC-ADNR-016:** the cost line says "RBX" and "an RBX Domain" (`r3gAdnrDeleteWithCost`, `svcAdnrDeleteWithCost`); confirm whether the copy should say VFX. On macOS a failed delete shows no error toast (`vfx_adnr_component.dart` only handles success); note it if seen.
- **TC-ADNR-018:** the too-long message reads "less than 66 charcters" (typo, and the limit is 65 allowed); confirm the intended copy.
- **TC-ADNR-019:** in `create_adnr_dialog.dart` the `No Thanks` branch pops the dialog but does not return, so the `VFX Faucet` dialog still opens after the toast. If that happens this case fails on the third bullet; confirm whether that is a bug. "Woud" is a typo in `adnrFaucetRequiredBody`.
- **TC-ADNR-022:** the web `Valid Transaction` body shows the domain as `<B1>.vfx` and the amount from `ADNR_COST` (`web_btc_adnr_content.dart`); confirm whether `.btc` is intended. On macOS `BtcService.transferAdnr` ignores the CLI response and the sheet always reports success, so a refused transfer still shows "Transaction Broadcasted!" and `Transfer Pending`; confirm on chain rather than trusting the toast.
- **TC-ADNR-023:** the web `Valid Transaction` for this delete uses the VFX wording ("The VFX Domain transaction is valid.", `r3eVfxDomainValidBody`). The macOS BTC delete has no balance, sync or password check and ignores the CLI response, so it always reports success. Confirm both are intended.

## [08 · Fungible tokens](08-fungible-tokens.md)

- **TC-TOKEN-009:** 5. Leave `Token Has Fixed Supply:` unticked, decimals 8, `Is Burnable:` ticked. Tick `Allow Voting:` (web: the checkbox after `Allow Voting:`; macOS: see Open question).
- **TC-TOKEN-009:** the `Is Burnable:` and `Allow Voting:` checkboxes have no key or label and their text is not tappable, and the icon upload opens the native macOS open panel; `tool/drive.dart` can drive neither, so on macOS these are done by hand until keys (for example `token:voting`, `token:burnable`) and a test hook for the picker exist. The web form sends the icon to Spyglass (`uploadAsset`) as well as embedding it; confirm the `Token Icon URL:` field alone is not meant to satisfy the icon requirement (today it does not).
- **TC-TOKEN-013:** the route is `token/detail/:scId` under the `fungible-token` tab (the older `fungible/detail/:scId` routes are commented out in `web_router.dart`), and the automation build rewrites the URL to `#./` after load. Confirm whether deep links to a token detail are meant to work, and on which path.
- **TC-TOKEN-017:** macOS has no self-transfer check (`isTokenTransferToSelf` is only used on the web), so a desktop transfer to the holder's own address reaches the CLI and is refused there. Decide whether the desktop should share the web check; until then do not run a self-transfer on macOS.
- **TC-TOKEN-021:** the macOS refusal text in step 5 comes from the CLI (`TransferToken`); record it on the first run. The web has no pending state for pause, so the button keeps reading `Pause TXs` until the next 10-second refresh after the block; confirm that is acceptable.
- **TC-TOKEN-023:** the confirmation dialog opens before the form is validated (`token_topic_form.dart`), so an empty form still asks "Are you sure you want to create this token topic?"; confirm whether validation should come first. On macOS the minimum field only accepts digits.
- **TC-TOKEN-025:** the web never loads the address's existing vote (only the desktop polls `GetVotesByAddress`), so after a reload the web shows the vote buttons again for an address that has voted. Confirm whether the web should show "You voted ..." as the desktop does.
- **TC-TOKEN-028:** the desktop branch of `Vote History` (`token_topic_detail_screen.dart`) was not traced end to end; record what it lists on the first run. On the web, `Vote History` on a topic whose vote list is empty shows the toast "No Votes".
- **TC-TOKEN-032:** the web list comes from token balances only, so a web owner of a mintable token with no issuance yet (no pre-mint) sees it nowhere (not on Fungible Tokens, not on All My Tokens) and cannot reach its detail page to mint. The desktop All My Tokens lists tokens from the smart contract list instead. Confirm how a web owner is meant to reach such a token.
- **TC-TOKEN-034:** the desktop vault row still offers `Transfer` and the node refuses a transfer whose sender is not the signer (see the comment in `web_token_balance_list_title.dart`); confirm what the desktop should do for vault-held token transfers.

## [09 · Smart contracts and NFTs](09-smart-contracts-nfts.md)

- **TC-SC-011:** Soul-Bound, Ticketing, Fractionalization, Tokenization and Pair have modals in `lib/features/smart_contracts/features/` but are commented out of `Feature.allTypes()`. Are they intentionally dark for this release, and should their modals be removed?
- **TC-SC-023:** should a follow-up run check the next day that the stage became current automatically?
- **TC-SC-031:** on macOS, does the Media Backup URL block under the QR code (`Media Backup URL:`, the URL and `Copy URL`) appear for this NFT? It depends on the mint transaction's `BackupURL`; record what shows.
- **TC-SC-031:** - `Features:` lists `Royalty` (subtitle with `5` and account B's address), `Multi Asset` (`1 asset`) and `Evolving` (a phase count) with a `Reveal Evolve Stages` button. **Open question:** the detail builds the phase count from the compiler's feature data; confirm whether it reads `3 phases` like the creator did.
- **TC-SC-033:** **Preconditions:** An NFT owned by account A whose media is not on this machine. **Open question:** how to produce one reliably on testnet (for example the web-minted `sc-basic-<run-id>-web` viewed on macOS, or temporarily renaming the file found in TC-SC-032)?
- **TC-SC-034:** - The desktop detail has no video player; a video primary asset shows its file type and the `Open Asset` button. **Open question:** is in-app video playback expected on macOS?
- **TC-SC-037:** `View Code` only appears when `nft.code` is set; record on which platforms the minted NFT carries code.
- **TC-SC-038:** `Sync Media` gives no success or failure feedback; should it show a toast?
- **TC-SC-045:** does the beacon delivery need the macOS wallet that minted the NFT to be running? If yes, keep the desktop app open during this case.
- **TC-SC-046:** - Web lists only minted NFTs with an evolving feature, so `sc-basic-<run-id>-web` is not expected there; on web this case passes if the NFT is absent and no error shows. **Open question:** should the sender be able to see transferred plain NFTs on web at all, and does the macOS CLI's minted list include `sc-basic-<run-id>-mac` after the transfer?
- **TC-SC-048:** do the example files' image URLs still resolve? They are the natural source for TC-SC-055 and 056.
- **TC-SC-055:** **Preconditions:** On the bulk create screen. `sc-bulk.csv` in the scratch folder has the header row `Name,Description,Primary Asset URL,Creator Name,Royalty Amount,Royalty Address,Additional Asset URLs,Quantity,Edition` and two rows: `csv-<run-id>-1` and `csv-<run-id>-2`, each with a description, a public HTTPS PNG URL, creator `QA Runner`, royalty `5%` to `TEST_VFX_B_ADDRESS`, no additional assets, quantity `1`, and `Edition` values `First` and `Second`. **Open question:** which stable public PNG URL should the file use? Proposal: add a non-secret `TEST_IMAGE_URL` to the README's test data.
- **TC-SC-059:** is the templates chooser (route `smart-contract-templates`, templates in `lib/features/nft/data/templates.dart`) meant to ship? If yes, it needs an entry point and full cases; if not, the screen and route should be removed.
- **TC-SC-060:** should drafts ship on desktop? `SmartContractDraftsScreen` and `draftsSmartContractProvider` still exist, and `DELETE_DRAFT_ON_MINT` still deletes drafts on compile.
- **TC-SC-061:** should the compiled list and its refresh ship, or should the screen be removed?

## [11 · Network operations](11-network-operations.md)

- **TC-NET-001:** When `VALIDATOR_NAV_ENABLED` is turned on for a release, should this case flip to asserting the entries are present, and should the Adjudicator and Datanode screens (the Adjudicator's `Start Adjudicating` button only shows a spinner for 750 ms and does nothing; `Stop Adjudicating` has an empty handler; Datanode only shows `Activating soon.`) be deleted instead of kept?
- **TC-NET-004:** The Account Security buttons, `Language`, `Verify NFT Ownership` and `Import Media` are exercised by `01-launch-auth.md`, `02-dashboard-navigation-settings.md` and `09-smart-contracts-nfts.md`. Confirm those files own them so they are not tested twice.
- **TC-NET-005:** The copy icons in log lines all carry the same label (`Copy`), so `drive.dart` cannot target one. Should `LogItem` get a per-line key such as `log:copy:<address>`?
- **TC-NET-011:** `OpenLogButton` builds the macOS path from `DataHome.fromDocuments(...)`. Confirm on a real run that the automation build opens the isolated folder's log and not the production one, because a wrong path here would expose the real wallet's log.
- **TC-NET-016:** Does the CLI's `StartValidating` broadcast a signed registration transaction? The case is marked "Moves funds: yes" to keep it testnet-only until that is confirmed. We also need a funded validator account and a machine with open ports: can the README gain `TEST_VALIDATOR_PRIVKEY` / `TEST_VALIDATOR_ADDRESS` and a note on which host runs these cases?
- **TC-NET-019:** Which existing testnet validator name should this use? Proposed variable `TEST_EXISTING_VALIDATOR_NAME` (not secret; it could also live in the case).
- **TC-NET-022:** How can this state be produced on purpose? Without a reliable trigger the case is opportunistic: run it only if the state appears during TC-NET-016 to TC-NET-021.
- **TC-NET-024:** Which validator name should the search use on testnet and on mainnet? Proposed variables `TEST_EXISTING_VALIDATOR_NAME` and `MAINNET_VALIDATOR_NAME` (public values, not secrets).
- **TC-NET-026:** `loadMasterNodes()` and `loadPeerInfo()` are commented out in `SessionProvider.mainLoop`, so the `Peer Info` strip (`IP:`, `Height:`, `Latency:`, `Last Checked:`) and the per-node cards (`Connected: <date>`, `Wallet Version: <v>`) can never appear. Is that intended, or should the case expect them?
- **TC-NET-029:** Which remote beacon should this use? Proposed variables `TEST_REMOTE_BEACON_IP` and `TEST_REMOTE_BEACON_PORT` (public, not secret). The `⋮` menu has no key or tooltip, so `drive.dart` cannot open it by key; should `BeaconContextMenu` get a `Key('beacon:menu:<id>')` and a tooltip?
- **TC-NET-031:** `BeaconFormProvider.submit` calls `notifyTransactionSubmitted()` after `CreateBeacon`. Does creating a beacon broadcast a transaction? Marked "Moves funds: yes" until confirmed. Also, should a restart be run in step 4 (`Restart`) instead of `Later` to cover that branch, given it costs another 1 to 3 minutes?
- **TC-NET-043:** Can `drive.dart` gain a `hover <finder>` command so the macOS half can expand the panel instead of reading off-screen widgets?

## [12 · Payments, faucet and key generation](12-payments-faucet-keygen.md)

- **TC-MISC-020:** Should Butterfly use its own password variable instead of reusing `TEST_ENCRYPTION_PASSWORD`? And which Butterfly testnet account state is expected after login (empty wallet is fine)?
- **TC-MISC-023:** Does the Butterfly API (`api.befree.io`, called with `is_testnet: true`) honour testnet links end to end, including claiming? And the history view (`Payment Link History`, `No payment links yet`) is commented out of the form; is it meant to ship?
- **TC-MISC-024:** `https://testnet.rbx.network/faucet` is the old RBX domain; does it still resolve to a working VFX testnet faucet? If not, should this gateway open the in-app SMS faucet (TC-MISC-031) instead?
- **TC-MISC-028:** The web MoonPay widget is started through a JS SDK (`moonPayBuy`) rather than an `HtmlElementView`; does it render under `?automation=1`? If so this case can run on the local automation build.
- **TC-MISC-031:** We need a web account with under 5.001 VFX. Proposed variable `TEST_WEB_EMPTY_EMAIL` / `TEST_WEB_EMPTY_PASSWORD` (a login that is never funded except by this faucet), or should the case log in with a fresh key generated in `01-launch-auth.md`? Also, after `No Thanks` the code pops the dialog but does not return, so it still goes on to open the `VFX Faucet` dialog; is that a bug to fix, or should the case expect it?
- **TC-MISC-032:** The phone field's messages come from the `phone_form_field` package, whose localization delegate is not registered in `app.dart`. Confirm on a run that the English defaults above appear rather than an error or a key name.
- **TC-MISC-033:** Which phone number is the faucet test number, who reads its SMS during a run, and what is the faucet's rate limit (per phone and per address)? Proposed variable `TEST_FAUCET_PHONE` (secret, in `accounts.env`).
- **TC-MISC-034:** What exact message does the faucet return for a rate-limited phone? The client shows the service's `message` field verbatim, so the case needs it to assert the text.
- **TC-MISC-035:** Does `04-btc-vbtc.md` already cover the wizard's faucet step? If so this case should be dropped to avoid spending faucet quota twice.
- **TC-MISC-041:** Is this easter egg meant to ship, and how is the configuration screen reached in 7.0.2? The only `push(ConfigContainerScreenRoute())` in the code is in `Footer`, which is not used anywhere.
