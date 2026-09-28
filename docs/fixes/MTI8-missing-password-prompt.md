# MTI#8: native actions that don't ask for the wallet password

The node clears the unlock password after PasswordClearTime (10 minutes by default). From then on, LockedWalletPolicy answers 401 to every route that isn't in AllowedWhileLocked. This list covers every native (Mac) GUI action that calls one of those routes without calling passwordRequiredGuard / passwordRequiredGuardV2 first on every path.

Sources: GUI origin/docs/test-run-20260927a (the 7.0.4 build, origin/feat/macos-notarization, has no guard changes) and Core origin/security/audit-sep2026-remediation (LockedWalletPolicy.cs).

Totals: 109 native actions call a route that is blocked while locked. 32 ask for the password first, 5 only on some paths (PARTIAL), 70 never ask (3 of them run in the background), and 2 can't run while encrypted.

Paths are relative to lib/features/ unless shown otherwise. "What the user sees on 401": raw = the DioException text from e.toString(); generic = a localized error or a bare Toast.error(); silent = nothing.

## vBTC

| Action | Call site | Route (Core action) | Status | What the user sees on 401 |
|---|---|---|---|---|
| Withdraw (v2 request) | btc/components/tokenized_btc_action_buttons.dart:497 | POST vbtcapi/vbtc/RequestWithdrawal (VBTC.RequestWithdrawal) | UNGUARDED | raw |
| Complete withdrawal | btc/components/withdrawal_processing_dialog.dart:138 (opened from tokenized_btc_action_buttons.dart:454, :536) | POST CompleteWithdrawal (VBTC.CompleteWithdrawal) | UNGUARDED | raw, in the dialog |
| Cancel withdrawal | btc/components/withdrawal_processing_dialog.dart:491 | POST CancelWithdrawal (VBTC.CancelWithdrawal) | UNGUARDED | raw |
| Withdraw (v1) | btc/components/tokenized_btc_action_buttons.dart:559 | POST btcapi/BTCV2/WithdrawalCoin (BTCV2.WithdrawalCoin) | UNGUARDED | raw |
| Transfer vBTC amount | btc/components/tokenized_btc_action_buttons.dart:768 (guardV2 at :759 only when the sender starts with xRBX) | POST TransferVBTC (VBTC.TransferVBTC) | PARTIAL | raw |
| Transfer shares (v1) | btc/components/tokenized_btc_action_buttons.dart:794 (same xRBX-only guard) | POST btcapi/BTCV2/TransferCoin (BTCV2.TransferCoin) | PARTIAL | raw |
| Transfer ownership (v2, including "to Vault") | btc/components/tokenized_btc_action_buttons.dart:688, :876 | GET TransferOwnership (VBTC.TransferOwnership) | UNGUARDED | raw |
| Bulk vBTC transfer | btc/screens/bulk_vbtc_transfer_screen.dart:302 | POST TransferVBTCMulti (VBTC.TransferVBTCMulti) | UNGUARDED | raw |
| Tokenize BTC (MPC ceremony, then create contract) | btc/screens/tokenize_btc_screen.dart:289 → btc/providers/mpc_ceremony_provider.dart:78, :196 | POST InitiateMPCCeremony, CreateVBTCContract (VBTC.*) | UNGUARDED | raw, plus the ceremony error state |
| Fund vBTC (BTC deposit modal) | btc/components/tokenized_btc_action_buttons.dart:282 | btcapi/BTCV2/SendTransaction (BTCV2.SendTransaction) | UNGUARDED | raw |
| Onboarding "transfer BTC to vBTC" | btc/screens/tokenize_btc_onboarding_steps.dart:179 → btc/providers/tokenized_btc_onboard_provider.dart:413 | btcapi/BTCV2/SendTransaction (BTCV2.SendTransaction) | UNGUARDED | raw |
| Prove ownership | lib/core/utils.dart:465 (from tokenized_btc_action_buttons.dart:939 and token/screens/token_management_screen.dart:231) | scapi/scv1/ProveOwnership (SCV1.ProveOwnership) | UNGUARDED | generic |

## Privacy (they ask for the shielded password, never the wallet password)

| Action | Call site | Route (Core action) | Status | What the user sees on 401 |
|---|---|---|---|---|
| Activate privacy (create shielded address) | privacy/components/privacy_activation_card.dart:92 → privacy/providers/shielded_address_provider.dart:27 | PrivacyV1.CreateShieldedAddressFromAccount | UNGUARDED | raw |
| Shield VFX | privacy/providers/privacy_actions_provider.dart:43 | PrivacyV1.ShieldVFX | UNGUARDED | raw |
| Unshield VFX | privacy/providers/privacy_actions_provider.dart:73 | PrivacyV1.UnshieldVFX | UNGUARDED | raw |
| Private transfer VFX | privacy/providers/privacy_actions_provider.dart:105 | PrivacyV1.PrivateTransferVFX | UNGUARDED | raw |
| Consolidate shielded VFX | privacy/providers/privacy_actions_provider.dart:135 | PrivacyV1.ConsolidateShieldedVFX | UNGUARDED | raw |
| Shield vBTC | privacy/providers/vbtc_privacy_actions_provider.dart:51 | PrivacyV1.ShieldVBTC | UNGUARDED | raw |
| Unshield vBTC | privacy/providers/vbtc_privacy_actions_provider.dart:87 | PrivacyV1.UnshieldVBTC | UNGUARDED | raw |
| Private transfer vBTC | privacy/providers/vbtc_privacy_actions_provider.dart:126 | PrivacyV1.PrivateTransferVBTC | UNGUARDED | raw |
| Consolidate shielded vBTC | privacy/providers/vbtc_privacy_actions_provider.dart:163 | PrivacyV1.ConsolidateShieldedVBTC | UNGUARDED | raw |
| Export viewing key | privacy/components/privacy_settings_menu.dart:111 | PrivacyV1.ExportViewingKey | UNGUARDED | generic |
| Import viewing key | privacy/components/privacy_settings_menu.dart:349 | PrivacyV1.ImportViewingKey | UNGUARDED | generic |
| Resync | privacy/components/privacy_settings_menu.dart:192 | PrivacyV1.ResyncShieldedWallet | UNGUARDED | generic |
| Resync vBTC | privacy/components/privacy_settings_menu.dart:286 | PrivacyV1.ResyncShieldedVBTC | UNGUARDED | generic |

## Vaults (reserve accounts)

| Action | Call site | Route (Core action) | Status | What the user sees on 401 |
|---|---|---|---|---|
| Create Vault | reserve/providers/reserve_account_provider.dart:92 (from manage_reserve_accounts_screen.dart:66, reserve_account_overview_screen.dart:346) | POST rsapi/RSV1/NewReserveAddress (RSV1.NewReserveAddress) | UNGUARDED | silent (not awaited, uncaught) |
| Fund Vault ("Awaiting funds", and automatically after create at :106) | reserve/providers/reserve_account_provider.dart:151 (from reserve_account_overview_screen.dart:240) | api/V1/SendTransaction (V1.SendTransaction) | UNGUARDED | silent (uncaught) |
| Activate Vault | reserve/providers/reserve_account_provider.dart:414 (from reserve_account_overview_screen.dart:250, manage_reserve_accounts_screen.dart:462) | GET RSV1/PublishReserveAccount (RSV1.PublishReserveAccount) | UNGUARDED | generic |
| Auto-activation (background) | reserve/providers/ra_auto_activate_provider.dart:132 | RSV1.PublishReserveAccount | UNGUARDED | generic, and the pending badge is cleared |
| Restore Vault | reserve/providers/reserve_account_provider.dart:250 (from reserve_account_overview_screen.dart:187, :372, manage_reserve_accounts_screen.dart:79) | POST RSV1/RestoreReserveAddress (RSV1.RestoreReserveAddress) | UNGUARDED | generic |
| Recover Vault | reserve/providers/reserve_account_provider.dart:287 (from reserve_account_overview_screen.dart:301) | GET RSV1/RecoverReserveAccountTx (RSV1.RecoverReserveAccountTx) | UNGUARDED | silent |
| Call back tx | reserve/components/callback_button.dart:42 | GET RSV1/CallBackReserveAccountTx (RSV1.CallBackReserveAccountTx) | UNGUARDED | silent |
| Download Vault NFT assets | asset/download_or_associate_asset.dart:133 | GET RSV1/GetReserveAccountNFTAssets (RSV1.GetReserveAccountNFTAssets) | UNGUARDED | generic |

## Send VFX

| Action | Call site | Route (Core action) | Status | What the user sees on 401 |
|---|---|---|---|---|
| Butterfly payment link (create, then fund the escrow) | send/screens/send_screen.dart:90 → payment/providers/butterfly_creation_provider.dart:156 | api/V1/SendTransaction (V1.SendTransaction) | UNGUARDED | uncaught: the link is already created, the escrow isn't funded, isProcessing is never reset |

## BTC

| Action | Call site | Route (Core action) | Status | What the user sees on 401 |
|---|---|---|---|---|
| Create BTC account | guarded at wallet/components/wallet_selector.dart:338 and wallet/utils.dart:299, NOT at btc/screens/tokenize_btc_onboarding_steps.dart:622 | btcapi/BTCV2/GetNewAddress (BTCV2.GetNewAddress) | PARTIAL | generic |
| Import BTC key | guarded at receive/screens/receive_screen.dart:449, NOT at wallet/components/wallet_selector.dart:304, wallet/utils.dart:433, btc/screens/tokenize_btc_onboarding_steps.dart:592 | btcapi/BTCV2/ImportPrivateKey (BTCV2.ImportPrivateKey) | PARTIAL | generic |
| Rebroadcast | btc/components/btc_transaction_list_tile.dart:269 | btcapi/BTCV2/Rebroadcast (BTCV2.Rebroadcast) | UNGUARDED | raw |

## Tokens

| Action | Call site | Route (Core action) | Status | What the user sees on 401 |
|---|---|---|---|---|
| Create token (compile, then mint) | token/components/token_form.dart:382 → token/providers/token_form_provider.dart:158, :208 | scv1/CreateSmartContract, MintSmartContract (SCV1.*) | UNGUARDED | generic / silent |
| Mint | token/components/mint_tokens_button.dart:73 | tkapi/TKV2/TokenMint (TKV2.TokenMint) | UNGUARDED | generic |
| Transfer | token/components/transfer_tokens_button.dart:87 | TKV2.TransferToken | UNGUARDED | generic |
| Burn | token/components/burn_tokens_button.dart:77 | TKV2.BurnToken | UNGUARDED | generic |
| Pause | token/components/pause_token_button.dart:77 | TKV2.PauseTokenContract | UNGUARDED | generic |
| Ban address | token/components/ban_token_address_button.dart:51 | TKV2.BanAddress | UNGUARDED | generic |
| Change ownership | token/components/change_token_ownership_button.dart:62 (guardV2 only for xRBX) | TKV2.ChangeTokenContractOwnership | PARTIAL | generic |
| Auto-mint after deploy (background) | transactions/providers/transaction_signal_provider.dart:220 | TKV2.TokenMint | UNGUARDED | generic |

## NFTs / smart contracts

| Action | Call site | Route (Core action) | Status | What the user sees on 401 |
|---|---|---|---|---|
| Bulk wizard mint | smart_contracts/screens/smart_contract_wizard_screen.dart:159 → smart_contracts/providers/sc_wizard_provider.dart:811, :836 | SCV1.CreateSmartContract, SCV1.MintSmartContract | UNGUARDED | generic (not verified on screen) |
| Complete sale | transactions/components/transaction_list_tile.dart:340 | SCV1.CompleteTransferSale | UNGUARDED | generic |
| Evolve / devolve | nft/modals/nft_management_modal.dart:43, :466 → nft/providers/nft_detail_provider.dart:508 | SCV1.EvolveSpecific | UNGUARDED | generic |
| Import NFT from network | nft/screens/nft_list_screen.dart:67 | SCV1.AddNFTDataFromNetwork | UNGUARDED | generic |
| Associate media | asset/download_or_associate_asset.dart:86 | SCV1.AssociateNFTAsset | UNGUARDED | silent |
| Call media from beacon | asset/download_or_associate_asset.dart:169 | SCV1.CallMediaFromBeacon | UNGUARDED | silent |

## Shop, bids and chat (no guard anywhere in these folders)

| Action | Call site | Route (Core action) | Status | What the user sees on 401 |
|---|---|---|---|---|
| Save shop | dst/providers/dec_shop_form_provider.dart:69; dst/components/publish_shop_button.dart:70 | DSTV1.SaveDecShop | UNGUARDED | silent |
| Publish / update shop | dst/components/publish_shop_button.dart:74, :112; dst/screens/create_dec_shop_container_screen.dart:124 | DSTV1.GetPublishDecShop, DSTV1.GetUpdateDecShop | UNGUARDED | generic / silent |
| Shop online / offline | dst/components/shop_online_button.dart:53, :69 | DSTV1.GetSetShopStatus | UNGUARDED | silent |
| Delete shop (local / remote) | dst/screens/my_collection_list_screen.dart:151, :183, :187 | DSTV1.GetDeleteLocalDecShop, DSTV1.GetDeleteDecShop | UNGUARDED | generic |
| Import shop | dst/screens/my_collection_list_screen.dart:366 | DSTV1.GetImportDecShopFromNetwork | UNGUARDED | generic |
| Save / toggle live collection | dst/providers/collection_form_provider.dart:50, :94 | DSTV1.SaveCollection | UNGUARDED | silent |
| Delete collection | dst/providers/collection_form_provider.dart:106; dst/providers/dec_shop_form_provider.dart:85; dst/screens/my_collection_list_screen.dart:154, :190 | DSTV1.DeleteCollection | UNGUARDED | silent |
| Save listing | dst/providers/listing_form_provider.dart:259 | DSTV1.SaveListing | UNGUARDED | silent |
| Delete listing | dst/providers/listing_form_provider.dart:296 | DSTV1.DeleteListing | UNGUARDED | silent |
| Retry sale | dst/components/listing_list.dart:103 | DSTV1.RetrySale | UNGUARDED | generic |
| Buy now | remote_shop/providers/bid_list_provider.dart:125 (from remote_shop/components/listing_details.dart:720); web_shop/providers/web_shop_bid_provider.dart:965, native branch (from web_listing_detail.dart:1070) | DSTV1.SendBuyNowBid | UNGUARDED | generic |
| Place bid | remote_shop/providers/bid_list_provider.dart:241 (from listing_details.dart:824); web_shop/providers/web_shop_bid_provider.dart:732, native branch (from web_listing_detail.dart:1186) | DSTV1.SendBid | UNGUARDED | generic |
| Resend bid | remote_shop/components/bid_history_modal.dart:53 | DSTV1.ResendBid | UNGUARDED | silent |
| Chat send (buyer) | chat/providers/shop_chat_list_provider.dart:42 | DSTV1.SendChatMessage | UNGUARDED | silent |
| Chat send (seller) | chat/providers/seller_chat_list_provider.dart:41 | DSTV1.SendShopChatMessage | UNGUARDED | silent |
| Chat resend | chat/providers/chat_list_provider_interface.dart:80, :87 | DSTV1.ResendChatMessage | UNGUARDED | silent |
| Chat delete thread | chat/providers/chat_list_provider_interface.dart:94 | DSTV1.DeleteChatMessages | UNGUARDED | silent |

## Keys, validator and other

| Action | Call site | Route (Core action) | Status | What the user sees on 401 |
|---|---|---|---|---|
| Onboarding "Import existing" VFX key | btc/screens/tokenize_btc_onboarding_steps.dart:359 | api/V1/ImportPrivateKey (V1.ImportPrivateKey) | UNGUARDED | silent (uncaught) |
| Stop validating | validator/screens/validator_screen.dart:356 → validator/providers/current_validator_provider.dart:42 | V1.TurnOffValidator | UNGUARDED | generic |
| Rename validator | validator/screens/validator_screen.dart:301 | V1.ChangeValidatorName | UNGUARDED | generic |
| Beacons: create / add / delete | beacon/providers/beacon_form_provider.dart:63; beacon/providers/add_beacon_form_provider.dart:55; beacon/components/beacon_context_menu.dart:46 | BCV1.CreateBeacon, BCV1.AddBeacon, BCV1.DeleteBeacon | UNGUARDED | generic |
| CLI update check (background) | lib/core/providers/session_provider.dart:416, :425 | V1.GetLatestRelease | UNGUARDED | silent (the check is skipped) |

## Guarded only when the dialog opens

These call the guard when the modal or dialog opens, not on submit. If the dialog stays open past the 10 minutes, the submit still gets a 401.

| Action | Guard | Submit call site | Core action | What the user sees on 401 |
|---|---|---|---|---|
| BTC domain create / transfer / delete | btc/components/btc_adnr_card.dart:94, :129, :155 | btc/components/btc_adnr_card.dart:278, :421, :178 | BTCV2.CreateAdnr, TransferAdnr, DeleteAdnr | generic |
| VFX domain create / transfer / delete | adnr/components/vfx_adnr_component.dart:97, :126, :176 | adnr/components/create_adnr_dialog.dart:254; vfx_adnr_component.dart:144, :198 | TXV1.CreateAdnr, TransferAdnr, DeleteAdnr | raw ("An error occurred: DioException...") |
| Fund wallet for domain | same | adnr/components/vfx_adnr_component.dart:269 | V1.SendTransaction | uncaught |
| Mother get / create / join / stop | home/components/home_buttons/mother_button.dart:22 | mother_button.dart:23; mother/components/mother_create_host_dialog.dart:82; mother/components/mother_add_host_dialog.dart:76; mother/components/mother_modal.dart:129 | V1.GetMother, StartMother, JoinMother, StopMother | generic |

## Note on the actions that do ask

Every guarded action uses passwordRequiredGuard, which first reads the cached passwordRequiredProvider state. That state only re-checks the node every 10 seconds, so for up to 10 seconds after the node clears the password (or right after encrypting, see MTI#6), guarded actions also skip the prompt and get the 401.
