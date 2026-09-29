# Bugs to fix

These are defects the release test suite found while its cases were being written from the code. Each one was then checked against the code by a second pass and is confirmed at the file and line given. All 35 are fixed on branch `fix/release-bugs` (merged into `testnet` on 2026-09-27), in one commit per area plus a review follow-up. Bug 28 is resolved by deleting the keygen panel it lived in (a product decision). The fixes still need the human test pass on the next build; the cases named next to each bug describe what to check.

| Severity | Count | Meaning |
|---|---|---|
| High | 3 | Can lose funds or data, or blocks a core flow |
| Medium | 15 | Wrong behaviour or misleading UI |
| Low | 17 | Small inconsistency, wording or typo |

## High

### 1. Cancelling Confirm Password still encrypts the wallet

- [x] **Found by:** TC-AUTH-057
- **What happens:** The Encrypt Wallet button only compares the two passwords when the confirm prompt returns a value; if the user cancels it, the code falls through and encrypts with the unconfirmed first password. Encryption is irreversible, so a typo in the first entry can lock the user out of their keys.
- **Where:** `lib/features/home/components/home_buttons/encrypt_wallet_button.dart:121`
- **Fix:** Return early when the confirm prompt returns null or empty, and only call encryptWallet when both entries match.

### 2. Startup-password-required state leaves the desktop app stuck with no prompt

- [x] **Found by:** TC-AUTH-062
- **What happens:** When the CLI's /CheckPasswordNeeded returns true, authenticate() sets startupPasswordRequiredProvider and returns false, so finishSetup (main loop, balances, BTC loop) never runs; nothing reads that provider and the UnlockWallet widget is never mounted anywhere, so the user sees a dashboard that never loads and has no way to enter the password. How often the CLI reports this is a runtime question, but the dead end is certain.
- **Where:** `lib/core/providers/session_provider.dart:251 (authenticate at :498; UnlockWallet in lib/features/encrypt/components/unlock_wallet.dart is unused)`
- **Fix:** Show the UnlockWallet prompt (or a blocking dialog) when startupPasswordRequiredProvider is true and call finishSetup after a successful unlock.

### 3. Desktop vBTC V2 transfer sends from the contract owner, not the current wallet

- [x] **Found by:** TC-BTC-046
- **What happens:** The desktop Transfer action passes token.rbxAddress as the sender, and for V2 contracts that field is the contract's OwnerAddress. A holder who is not the owner either gets 'Account not found' from the CLI, or, on a node that also holds the owner's key, moves the owner's vBTC instead of their own. The password guard for vault owners checks the same wrong address.
- **Where:** `lib/features/btc/components/tokenized_btc_action_buttons.dart:759 (also :749; rbxAddress set from OwnerAddress at lib/features/btc/services/vbtc_v2_service.dart:120)`
- **Fix:** Use ref.read(sessionProvider).currentWallet.address as fromAddress (and for the vault password guard), as the withdrawal path at line 420 already does.

## Medium

### 4. macOS VFX domain delete fails silently

- [x] **Found by:** TC-ADNR-016
- **What happens:** When DeleteAdnr returns a failure, the desktop does nothing: no toast, no log, no pending badge. The user cannot tell the delete was refused. Transfer on the same card does show result.message.
- **Where:** `lib/features/adnr/components/vfx_adnr_component.dart:198-212`
- **Fix:** Add an else branch that shows Toast.error(result.message), as the transfer branch at line 163 does.

### 5. 'No Thanks' on the BTC domain faucet prompt still opens the faucet

- [x] **Found by:** TC-ADNR-019, TC-MISC-031
- **What happens:** When the user declines the '5.0 VFX Required' prompt, the code shows the error toast and closes the dialog but does not return, so the VFX Faucet dialog opens anyway, followed by the 'wait for your balance' toast.
- **Where:** `lib/features/adnr/components/create_adnr_dialog.dart:101-113`
- **Fix:** Add return after Navigator.of(context).pop() in the confirmed != true branch.

### 6. macOS BTC domain transfer and delete always report success

- [x] **Found by:** TC-ADNR-022, TC-ADNR-023
- **What happens:** BtcService.transferAdnr and deleteAdnr call the CLI and return null without reading the response (the check is commented out), and the callers ignore the return value. A refused transfer or delete still shows 'Transaction Broadcasted!', adds a pending badge and fires the submitted notification. The BTC delete also has no balance, sync or password check.
- **Where:** `lib/features/btc/services/btc_service.dart:303-304, lib/features/btc/services/btc_service.dart:317-318, lib/features/btc/providers/btc_adnr_transfer_form_provider.dart:74-86, lib/features/btc/components/btc_adnr_card.dart:165-167`
- **Fix:** Parse Success/Hash/Message as createAdnr does, return the hash or show Toast.error(Message), and only mark pending and toast success when a hash came back; add the same balance and sync guards the VFX delete uses.

### 7. Web BTC domain confirmations show VFX wording and a '.vfx' domain

- [x] **Found by:** TC-ADNR-022, TC-ADNR-023
- **What happens:** The web BTC domain transfer confirmation shows the domain as '<name>.vfx' instead of '.btc', and the BTC delete confirmation uses the VFX string ('The VFX Domain transaction is valid.'). The user confirms a payment against the wrong domain name.
- **Where:** `lib/features/btc_web/components/web_btc_adnr_content.dart:221, lib/features/btc_web/components/web_btc_adnr_content.dart:308`
- **Fix:** Use '$adnr.btc' at line 221 and r3eBtcDomainValidBody at line 308 (with ADNR_TRANSFER_COST / ADNR_DELETE_COST for the amount).

### 8. Custom BTC fee rate of 0 skips validation and is sent

- [x] **Found by:** TC-BTC-012
- **What happens:** In the shared fee-rate picker (used by web BTC send and the vBTC flows), Continue with Custom returns customFee directly. The field's 'at least 1 satoshi' validator never runs, and customFee starts at 0 and keeps its last parsed value when the field is cleared, so a 0 sat/vB transaction can be built and broadcast. The backend's reaction (refusal text or a stuck tx) still needs recording on the first run.
- **Where:** `lib/features/btc/utils.dart:75, lib/features/btc/utils.dart:166-168`
- **Fix:** Wrap the custom field in a Form with a key and only pop when it validates (customFee >= 1), otherwise keep the dialog open.

### 9. Open Log fails when the data path contains a space

- [x] **Found by:** TC-DASH-033
- **What happens:** Open Log does follow the automation data folder (DataHome.fromDocuments), so the original concern is answered, but it runs an unquoted 'open <path>' through process_run's Shell, which splits on spaces. The automation path ('Library/Application Support/...') and any Windows user folder with a space in the name break the command, and throwOnError:false hides the failure, so nothing opens and no error is shown.
- **Where:** `lib/features/home/components/home_buttons/open_log_button.dart:33`
- **Fix:** Open the file with openFile(File(path)) as Open DB Folder does, or quote the path in the command.

### 10. Desktop compile/mint exception is swallowed with no message

- [x] **Found by:** TC-SC-009, TC-SC-022
- **What happens:** If compile or mint throws on macOS, the catch closes the compile animation and prints the exception to the console, but shows no toast, so the user gets no explanation of why minting stopped.
- **Where:** `lib/features/smart_contracts/components/sc_creator/smart_contract_creator_main.dart:241-247`
- **Fix:** Show Toast.error with the compile/mint failure message in the catch block, as the other failure branches do.

### 11. Saving an empty Multi Asset sheet crashes and leaves the sheet open

- [x] **Found by:** TC-SC-015
- **What happens:** complete() calls removeMultiAsset for a Multi Asset that was never added, so indexWhere returns -1 and removeAt(-1) throws a RangeError. The throw skips clear() and the Navigator.pop() after it, so Save appears to do nothing and the sheet stays open. The case currently expects the sheet to close.
- **Where:** `lib/features/smart_contracts/providers/create_smart_contract_provider.dart:261-262 (called from lib/features/smart_contracts/features/multi_asset/multi_asset_provider.dart:34, lib/features/smart_contracts/features/multi_asset/multi_asset_modal.dart:55-56)`
- **Fix:** In removeMultiAsset, return early when indexWhere returns -1, or in complete() skip the remove when the Multi Asset is not already in the list.

### 12. Sync Media gives no feedback and saves 'ERROR' as a media URL on failure

- [x] **Found by:** TC-SC-038
- **What happens:** The desktop Sync Media button uploads each asset and calls associateMedia, but shows nothing on success or failure. A failed upload stores the literal string 'ERROR' as that file's URL and still associates it, and a missing local file throws with no message.
- **Where:** `lib/features/nft/screens/nft_detail_screen.dart:881-896`
- **Fix:** Wrap the handler in try/catch with a loading state, skip or abort on a null upload URL instead of writing 'ERROR', and show a success or error toast based on associateMedia's result.

### 13. Download Example JSON and CSV links return 404

- [x] **Found by:** TC-SC-048
- **What happens:** Both buttons on the Mint NFT Collection screen open Firebase Storage URLs that currently return HTTP 404 'Not Found', so users cannot get the example files. The same files are already bundled in assets/docs.
- **Where:** `lib/features/smart_contracts/screens/bulk_create_screen.dart:211, lib/features/smart_contracts/screens/bulk_create_screen.dart:280`
- **Fix:** Re-upload the files and update the URLs, or serve the bundled assets/docs/nft-metadata-example.{json,csv} instead.

### 14. Prefilled send link with a non-numeric amount crashes the route

- [x] **Found by:** TC-SEND-014
- **What happens:** The amount path parameter is typed double, and auto_route's getDouble throws a FlutterError when the segment is not a number, so a link like #/dashboard/send/vfx/<addr>/abc renders an error page instead of the send form.
- **Where:** `lib/features/send/screens/web_prefilled_send_screen.dart:18 (parsed at lib/core/web_router.gr.dart:276)`
- **Fix:** Declare the amount path param as String and parse it with double.tryParse, leaving the field empty when it is not a number.

### 15. Web transaction detail never refreshes (stale pending status)

- [x] **Found by:** TC-SEND-039
- **What happens:** webTransactionDetailProvider is a plain FutureProvider.family, not .autoDispose, and is not invalidated from the web session loop, so it fetches once and serves that value for the rest of the session. A transaction opened while pending keeps showing pending even after re-entering the screen. This breaks the documented convention in context/conventions.md.
- **Where:** `lib/features/transactions/providers/web_transaction_detail_provider.dart:6`
- **Fix:** Make the provider .autoDispose and invalidate it from WebSessionProvider.loop(), as the convention requires.

### 16. Web forgets the user's token vote after a reload

- [x] **Found by:** TC-TOKEN-025
- **What happens:** On web, the topic poll returns before loading the address's votes, and 'You have voted' comes only from an in-memory pending list. After a reload the vote buttons come back for an address that already voted, inviting a second vote the node will refuse.
- **Where:** `lib/features/token/screens/token_topic_detail_screen.dart:96-105, lib/features/token/screens/token_topic_detail_screen.dart:219`
- **Fix:** On web, load the address's votes for the topic from Spyglass and set currentVote, as the desktop does via GetVotesByAddress.

### 17. Activate Account shown on an already-activated Vault

- [x] **Found by:** TC-VAULT-022
- **What happens:** The Manage Vault Accounts card shows the Activate Account tile whenever the balance is at least 5 VFX and no activation is pending, without checking isNetworkProtected, and the activate() handler does not check it either. An activated Vault with 5+ VFX invites a second activation, which burns VFX if the CLI accepts it (what the CLI returns is a runtime check).
- **Where:** `lib/features/reserve/screens/manage_reserve_accounts_screen.dart:111`
- **Fix:** Add !ra.isNetworkProtected to showActivateButton and guard activate() in reserve_account_provider.dart:360 the same way.

### 18. Web Vault restore with a bad code fails silently

- [x] **Found by:** TC-VAULT-028
- **What happens:** The web Restore Vault Account handler calls base64.decode and split('//')[1] with no try/catch, so an invalid or truncated restore code throws inside the button handler and the user sees nothing at all.
- **Where:** `lib/features/web/components/web_restore_ra_button.dart:53`
- **Fix:** Wrap decoding and key import in try/catch and show a red toast such as 'Invalid restore code'.

## Low

### 19. Web domain transfer and delete confirmations say 'Fee: ... RBX'

- [x] **Found by:** TC-ADNR-015
- **What happens:** Both web VFX-domain confirmations are hardcoded English strings (not localized) that label the fee in RBX while the total is in VFX. The amount line uses ADNR_COST rather than the transfer or delete cost; the values are equal today (5.0) so the number is right, but it will drift if the costs change.
- **Where:** `lib/features/adnr/screens/web_adnr_screen.dart:278, lib/features/adnr/screens/web_adnr_screen.dart:355`
- **Fix:** Use the localized r3eVfxDomainValidBody with ADNR_TRANSFER_COST / ADNR_DELETE_COST and VFX for the fee.

### 20. Domain delete cost text says 'RBX' and 'RBX Domain'

- [x] **Found by:** TC-ADNR-016, TC-ADNR-023
- **What happens:** The delete confirmations read 'There is a cost of 5.0 RBX to delete an RBX Domain.' on web and macOS VFX domains, and '...VFX to delete an RBX Domain.' on the macOS BTC domain card. RBX is the old brand name.
- **Where:** `lib/l10n/app_en.arb:5583 (r3gAdnrDeleteWithCost), lib/l10n/app_en.arb:7095 (svcAdnrDeleteWithCost), lib/l10n/app_en.arb:7583 (tkbDeleteDomainWithCost)`
- **Fix:** Change the copy to 'There is a cost of {cost} VFX to delete a VFX Domain' (BTC Domain for the BTC card) in all locales.

### 21. Typos in user-facing strings

- [x] **Found by:** TC-ADNR-018, TC-ADNR-019, TC-MISC-031, TC-NET-033, TC-SC-009, TC-SC-060, TC-SEND-011
- **What happens:** Shipped strings: 'atleast' (custom fee error), 'charcters' (BTC domain too long), 'Woud' (domain faucet prompt), 'the the' (macOS mint toast), 'sufficent' (network voting). In strings nobody can reach today: 'maxium', 'wan't', 'Draft Delete'. The 'Woud' entry has an .arb note saying it was kept on purpose during localization.
- **Where:** `lib/l10n/app_en.arb:7676; lib/l10n/app_en.arb:1513 (bw2DomainTooLong, used at lib/features/btc/providers/btc_adnr_create_form_provider.dart:62); lib/l10n/app_en.arb:323 (adnrFaucetRequiredBody); lib/l10n/app_en.arb:4505 (used at smart_contract_creator_main.dart:222), lib/l10n/app_en.arb:323 (create_adnr_dialog.dart:97), lib/l10n/app_en.arb:6064 (topic_list_screen.dart:67); lib/l10n/app_en.arb:4488, lib/l10n/app_en.arb:4387, lib/l10n/app_en.arb:4395 (used at smart_contract_creator_main.dart:120, 261, 274)`
- **Fix:** Correct the English .arb values (and the Spanish ones if they copied the error), then run gen-l10n.

### 22. Boot screen log list drops the newest line

- [x] **Found by:** TC-AUTH-001
- **What happens:** BootContainer uses getRange(start, logs.length - 1), and the end index is exclusive, so the latest log line is never shown (and with one log line nothing shows), which hides the most current boot status.
- **Where:** `lib/core/components/boot_container.dart:31`
- **Fix:** Use getRange(start, logs.length).

### 23. BTC import 'I don't know' rejects every testnet address

- [x] **Found by:** TC-AUTH-019
- **What happens:** The address-type detection only knows mainnet prefixes (1, 3, bc1q, bc1p), so on the testnet build any tb1/m/n/2 address produces 'Invalid BTC Address' and closes the sheet. Testnet users have to know and pick the type manually.
- **Where:** `lib/features/auth/auth_utils.dart:453`
- **Fix:** When Env.isTestNet, also map tb1q, tb1p, m/n and 2 prefixes to their address types.

### 24. Revealing an existing VFX key titles the dialog 'Key Generated'

- [x] **Found by:** TC-AUTH-037
- **What happens:** The Addresses-tab row menu calls showKeys(context, keypair) without forReveal=true, so revealing an existing key shows 'Key Generated'; every other reveal path (including BTC on the same menu) passes true and shows 'Keys'.
- **Where:** `lib/features/root/web_dashboard_container.dart:1292`
- **Fix:** Pass true as the forReveal argument, as the BTC branch below it does.

### 25. Copying an address says 'Public key copied to clipboard'

- [x] **Found by:** TC-AUTH-037, TC-VAULT-030
- **What happens:** The Copy address buttons in the key-reveal dialogs (VFX, BTC, Vault and keygen) copy the address but show the keygenPublicKeyCopiedToast text, which tells the user they copied a public key.
- **Where:** `lib/features/auth/auth_utils.dart:907, lib/features/auth/auth_utils.dart:1051, lib/features/keygen/components/keygen_cta.dart:164`
- **Fix:** Use an 'Address copied to clipboard' string for these buttons.

### 26. VFX card stays 'Loading...' forever with no accounts

- [x] **Found by:** TC-AUTH-043
- **What happens:** loadWallets only sets totalBalance when the wallet list is non-empty, and the balance row shows 'Loading...' while totalBalance is null, so a fresh wallet never shows 0 VFX. Deleting the last account also leaves the old total in place.
- **Where:** `lib/core/providers/session_provider.dart:657 (display at lib/features/navigation/components/root_container_balance_row.dart:110)`
- **Fix:** Set totalBalance to the sum (0 for an empty list) whenever the wallet list loads.

### 27. Web vBTC transfer sheet shows a multi-signature fee note and 'Amount of BTC'

- [x] **Found by:** TC-BTC-033
- **What happens:** The web transfer sheet always shows 'This is a Multi-signature transaction so a higher fee rate is recommended.', although a vBTC transfer is a VFX transaction with no BTC fee rate to choose. The amount field is also labelled 'Amount of BTC to Send'.
- **Where:** `lib/features/btc_web/components/web_btc_tokenized_action_buttons.dart:519-522 (label at :507)`
- **Fix:** Show the multisig note only when forWithdrawl is true, and label the amount 'Amount of vBTC' for transfers.

### 28. Keygen panel import shows the email as the recovery mnemonic

- [x] **Found by:** TC-MISC-039
- **What happens:** handleImport passes the email as importPrivateKey's optional mnemonic argument, so the Key Generated dialog shows a 'Recovery Mnemonic' row containing the email. The panel has no entry point today, so no user sees this, and the real login import in lib/features/auth does not have the bug.
- **Where:** `lib/features/keygen/components/keygen_cta.dart:28 (shown at keygen_cta.dart:128)`
- **Fix:** Call KeygenService.importPrivateKey(value) without the email, or delete the panel if the unreachable-screens decision says so.

### 29. Shielded-fee dialog says 'vBTC privacy operations' for VFX actions

- [x] **Found by:** TC-PRV-015
- **What happens:** The Shielded VFX Required dialog body is one string that starts 'vBTC privacy operations require a small fee...', but the same guard runs before VFX unshield, VFX private transfer and VFX consolidate.
- **Where:** `lib/l10n/app_en.arb:4206 (used at lib/features/privacy/utils/vfx_fee_guard.dart:30)`
- **Fix:** Change the copy to 'Privacy operations require...' (or pass the asset in) in app_en.arb and the other locales.

### 30. Creator-name and description fields write to the contract name in state

- [x] **Found by:** TC-SC-009
- **What happens:** Typing in Minter/Creator Name calls setName, and setDescription writes to state.name, so while editing the state's name holds whatever field was typed in last and minterName/description stay stale. preSave() re-reads all three controllers before compile, which hides it today, but anything that reads the state before that gets the wrong values.
- **Where:** `lib/features/smart_contracts/providers/create_smart_contract_provider.dart:88-89, lib/features/smart_contracts/components/sc_creator/form_groups/basic_properties_form_group.dart:128`
- **Fix:** Make setDescription set description, and call setMinterName from the creator-name field's onChanged.

### 31. Paste link strips the dot from .vfx domains

- [x] **Found by:** TC-SEND-023
- **What happens:** The send form's 'here' paste link removes every non-alphanumeric character, so a pasted 'name.vfx' becomes 'namevfx' and fails validation, even though typed input allows '.' and the validator explicitly accepts .vfx domains.
- **Where:** `lib/features/send/components/send_form.dart:61`
- **Fix:** Allow '.' in the paste regex to match the field's input formatter ([a-zA-Z0-9.]).

### 32. Web explorer link has a double slash

- [x] **Found by:** TC-SEND-038
- **What happens:** The detail screen builds '${Env.baseExplorerUrl}/transaction/<hash>' but baseExplorerUrl already ends in '/', giving '...verifiedx.io//transaction/<hash>'. The same pattern is in the vBTC withdrawal dialog. Whether Spyglass tolerates it gets checked at runtime; the URL is malformed either way.
- **Where:** `lib/features/transactions/screens/web_transaction_detail_screen.dart:46 (also lib/features/btc/components/withdrawal_processing_dialog.dart:365)`
- **Fix:** Use Env.explorerWebsiteBaseUrl (no trailing slash), as Transaction.explorerUrl does.

### 33. Desktop token transfer has no self-transfer check

- [x] **Found by:** TC-TOKEN-017
- **What happens:** The web refuses a transfer to the holder's own address with a clear message (the shared rule exists because the node refuses it), but the desktop Transfer button sends it to the CLI, so the user only gets a node error, or a tx that fails later.
- **Where:** `lib/features/token/components/transfer_tokens_button.dart:65-74 (rule at lib/features/token/token_rules.dart:9)`
- **Fix:** Call isTokenTransferToSelf(fromAddress, toAddress) after the address prompt and show tokenWebTransferToSelf, as web_token_balance_list_title.dart:210 does.

### 34. Token topic form asks 'Are you sure?' before validating

- [x] **Found by:** TC-TOKEN-023
- **What happens:** Submitting an empty or invalid topic form first shows 'Are you sure you want to create this token topic?' and only validates after the user confirms.
- **Where:** `lib/features/token/components/token_topic_form.dart:171-181 (validation at lib/features/token/providers/token_topic_form_provider.dart:62)`
- **Fix:** Validate the form before opening the confirmation dialog.

### 35. Auto-activate question asked after the user cancels funding

- [x] **Found by:** TC-VAULT-010
- **What happens:** The web Fund Account button shows 'Automatically Activate?' before checking whether the first 'Fund Your Vault Account' dialog was confirmed, so cancelling still pops a second, pointless question.
- **Where:** `lib/features/web/components/web_fund_ra_account_button.dart:44`
- **Fix:** Return right after the first dialog when confirmed != true.
