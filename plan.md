# vBTC V2 Web Wallet — Implementation Plan

> Reference: docs/vbtc-v2-web-wallet.md (planning doc)
> API spec: /Users/tyler/prj/vfx/vfx-explorer/docs/vbtc-v2-web-wallet-integration.md

All Spyglass API endpoints are already built. This is purely Flutter web wallet work.

---

## Phase 1: Model + Service Layer

**Objective:** Add V2 data structures and API service methods so the web wallet can talk to the Spyglass V2 endpoints.

### Tasks

1. **Update `BtcWebVbtcToken` model** (`lib/features/btc_web/models/btc_web_vbtc_token.dart`):
   - Add `@Default(1) int version` field
   - Add `@JsonKey(name: 'is_pending_withdrawal') @Default(false) bool isPendingWithdrawal`
   - Add `@JsonKey(name: 'frost_group_public_key') String? frostGroupPublicKey`
   - Add `@JsonKey(name: 'required_threshold') int? requiredThreshold`
   - Add `@JsonKey(name: 'withdrawal_requests') List<Map<String, dynamic>>? withdrawalRequests`
   - Keep all existing V1 fields — V1 tokens still use this model
   - Make `publicKeyProofs` optional (V2 tokens won't have it): change from `required String` to `String?`

2. **Create a withdrawal request model** (`lib/features/btc_web/models/web_vbtc_withdrawal.dart`):
   - Fields from the API: `requestorAddress`, `btcAddress`, `amount`, `feeRate`, `btcTransactionHash`, `status`, `requestTransactionHash`, `completionTransactionHash`, `createdAt`, `completedAt`
   - Use freezed + json_serializable

3. **Add V2 methods to ExplorerService** (`lib/core/services/explorer_service.dart`):
   - `Future<List<BtcWebVbtcToken>> getWebVbtcV2Tokens(String address)` → `GET /btc/vbtc-v2/{address}/`
   - `Future<BtcWebVbtcToken> getWebVbtcV2TokenDetail(String scIdentifier)` → `GET /btc/vbtc-v2/detail/{scIdentifier}/`
   - `Future<Map<String, dynamic>> initiateV2Ceremony(String ownerAddress)` → `POST /btc/vbtc-v2/ceremony/initiate/` body: `{ "owner_address": ownerAddress }`
   - `Future<Map<String, dynamic>> getV2CeremonyStatus(String ceremonyId)` → `GET /btc/vbtc-v2/ceremony/{ceremonyId}/`
   - `Future<Map<String, dynamic>> createV2Contract({ ownerAddress, name, description, ticker, ceremonyId })` → `POST /btc/vbtc-v2/create/`
   - `Future<Map<String, dynamic>> completeV2Withdrawal(String scIdentifier, String requestHash)` → `POST /btc/vbtc-v2/withdraw/complete/` (use 180s timeout)
   - `Future<Map<String, dynamic>> cancelV2Withdrawal({ scIdentifier, ownerAddress, requestHash, btcTxHash, failureProof })` → `POST /btc/vbtc-v2/withdraw/cancel/`
   
   For the detail endpoint, note it does NOT need an address parameter (unlike V1) — the API returns all address balances in the response.

4. **Regenerate freezed/json files**: Run `fvm flutter pub run build_runner build --delete-conflicting-outputs`

---

## Phase 2: Token List + Detail

**Objective:** V2 tokens show up in the web wallet token list and detail screens.

### Tasks

1. **Update `btcWebVbtcTokenListProvider`** (`lib/features/btc_web/providers/btc_web_vbtc_token_list_provider.dart`):
   - Fetch from both V1 (`getWebVbtcTokens`) and V2 (`getWebVbtcV2Tokens`) endpoints
   - V2 tokens should have `version: 2` set (the API should return this, but set it explicitly as a safety measure)
   - Merge both lists into a single list, sorted by createdAt descending

2. **Update `btcWebVbtcTokenDetailProvider`** (`lib/features/btc_web/providers/btc_web_vbtc_token_detail_provider.dart`):
   - For V2 tokens (version >= 2), call `getWebVbtcV2TokenDetail` instead of `getWebVbtcTokenDetail`
   - The composite key already includes scIdentifier — use that to determine which endpoint to call
   - OR: add a version hint to the key (e.g., `scId_address_version`)

3. **Update detail screen** (`lib/features/btc_web/screens/web_tokenized_btc_detail_screen.dart`):
   - Show V2-specific info: FROST group key, threshold, pending withdrawal status
   - Display withdrawal history if available
   - Add a version badge/indicator (V1 vs V2)

4. **Update list tile** (`lib/features/btc_web/components/web_tokenized_btc_list_tile.dart`):
   - Show version badge on V2 tokens

---

## Phase 3: Transfer

**Objective:** Users can transfer vBTC between VFX addresses on V2 contracts via the web wallet.

### Tasks

1. **Add `transferVbtcV2()` to WebTokenActionsManager** (`lib/features/token/providers/web_token_actions_manager.dart`):
   - Data payload: `{ "Function": "TransferVBTCV2()", "ContractUID": scIdentifier, "FromAddress": fromAddress, "ToAddress": toAddress, "Amount": amount }`
   - TX type: 26 (`TxType.vbtcV2Transfer`)
   - Use `_verifyConfirmAndSendTx()` with `toAddress` set to the recipient's VFX address
   - Note: the data payload is a Map (not a List like V1's `TransferCoin()`)

2. **Version-gate in web action buttons** (`lib/features/btc_web/components/web_btc_tokenized_action_buttons.dart`):
   - In the transfer handler, check `token.version >= 2`
   - V2: call `transferVbtcV2()`
   - V1: call existing `transferVbtcAmount()`

---

## Phase 4: Withdrawal

**Objective:** Full V2 withdrawal flow — request, FROST signing, completion, and cancel.

### Tasks

1. **Add `requestV2Withdrawal()` to WebTokenActionsManager**:
   - Data payload: `{ "Function": "VBTCWithdrawalRequest()", "ContractUID": scIdentifier, "RequestorAddress": requestorAddress, "BTCAddress": btcAddress, "Amount": amount, "FeeRate": feeRate }`
   - TX type: 27 (`TxType.vbtcV2WithdrawalRequest`)
   - to_address = from_address = requestor's VFX address
   - Returns the tx hash (which becomes the withdrawal_request_hash)

2. **Add `completeV2Withdrawal()` to WebTokenActionsManager**:
   - Calls `ExplorerService().completeV2Withdrawal(scIdentifier, requestHash)`
   - This is a long-running call (120s+) — the UI must show a waiting state
   - Returns success with vfx_transaction_hash + btc_transaction_hash

3. **Add `cancelV2Withdrawal()` to WebTokenActionsManager**:
   - Calls `ExplorerService().cancelV2Withdrawal(...)`

4. **Create web V2 withdrawal processing dialog** (`lib/features/btc_web/components/web_v2_withdrawal_dialog.dart`):
   - Similar to desktop's `withdrawal_processing_dialog.dart`
   - Step 1: Show "Broadcasting withdrawal request..." while the raw TX is sent
   - Step 2: Show "Waiting for block confirmation..." — poll withdrawals endpoint until the request appears
   - Step 3: Show "FROST signing in progress..." during the completeV2Withdrawal call
   - Step 4: Show success with BTC tx hash + link to mempool.space
   - Handle errors at each step with clear messaging
   - Handle timeout: "Signing may still complete — check back shortly"

5. **Wire into web action buttons**:
   - Version-gate the withdraw handler: V2 uses the new dialog, V1 uses existing flow
   - Add pending withdrawal detection: if token has a pending withdrawal, offer to complete it (same pattern as desktop)

---

## Phase 5: Contract Creation (MPC)

**Objective:** Users can create new V2 vBTC tokens from the web wallet.

### Tasks

1. **Add MPC ceremony methods to WebTokenActionsManager** (or a dedicated provider):
   - `initiateV2Ceremony(ownerAddress)` → calls `ExplorerService().initiateV2Ceremony()`
   - `pollV2CeremonyStatus(ceremonyId)` → calls `ExplorerService().getV2CeremonyStatus()`
   - `createV2Contract(ownerAddress, name, description, ticker, ceremonyId)` → calls `ExplorerService().createV2Contract()`

2. **Create web MPC ceremony progress dialog** (`lib/features/btc_web/components/web_mpc_ceremony_dialog.dart`):
   - Initiate ceremony on open
   - Poll every 3-5 seconds
   - Show progress bar (0-100%) using the `progress` field
   - Show status message from the API
   - On completion, prompt for token name/description
   - Call createV2Contract with the ceremony ID
   - Show success with the new token details

3. **Wire into the web tokenize BTC screen** (`lib/features/btc/screens/tokenize_btc_screen.dart`):
   - When `kIsWeb` is true, the create button should use the MPC ceremony flow
   - The existing screen has V1 creation logic — add a V2 path gated by a flag or default to V2
   - After successful creation, navigate to the token detail screen or refresh the list

4. **Update web token list to support the new Create flow**:
   - The create button on the token list screen should work for web V2
   - After creation, refresh the token list provider
