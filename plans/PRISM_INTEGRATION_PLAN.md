# PRISM Privacy Layer — Execution Plan

## Context
New privacy layer on the VFX network (testnet only). UTXO-based shielded pool with PLONK ZK proofs. Integrating into desktop GUI, VFX only (vBTC later). API lives at same host:port, path prefix `/privacyapi/PrivacyV1/`. Node auto-scans for notes. WalletPassword fields ignored.

## Key References
- Integration doc: `docs/prism/PRISM_INTEGRATION_GUIDE.md`
- Core CLI: `/Users/tyler/prj/rbx/Core-CLI` (GlobalsPrivacy.cs, PrivacyV1Controller.cs)
- BaseService pattern: `lib/core/services/base_service.dart` (uses `apiBasePathOverride` to swap path)
- Example feature service: `lib/features/btc/services/btc_service.dart`
- Side nav: `lib/features/navigation/components/root_container_side_nav_list.dart`
- Router: `lib/core/app_router.dart`
- Constants: PrivateTxFixedFee=0.000003, MinShieldAmountVFX=0.001

---

## Phase 1: Foundation (Service + Models)
> No UI. Pure data layer. Can be verified by importing and calling from a test.

**Files to create:**

`lib/features/privacy/services/privacy_service.dart`
- Extends `BaseService` with `apiBasePathOverride: "/privacyapi/PrivacyV1"`
- Methods:
  - `getPlonkStatus()` → GET `/GetPlonkStatus`
  - `generateShieldedAddress()` → POST `/GenerateShieldedAddress`
  - `shieldVfx(fromAddress, amount, recipientZfxAddress)` → POST `/ShieldVFX`
  - `unshieldVfx(zfxAddress, toAddress, amount)` → POST `/UnshieldVFX`
  - `privateTransferVfx(zfxAddress, recipientZfxAddress, amount)` → POST `/PrivateTransferVFX`
  - `consolidateVfx(zfxAddress)` → POST `/ConsolidateShieldedVFX`
  - `getShieldedBalance(zfxAddress, {includeCommitments})` → GET `/GetShieldedBalance`
  - `exportViewingKey(zfxAddress)` → POST `/ExportViewingKey`
  - `importViewingKey(zfxAddress, viewingKeyBase64, {transparentAddress})` → POST `/ImportViewingKey`
  - `scanShielded(zfxAddress, fromHeight, toHeight)` → POST `/ScanShielded`
  - `resyncShieldedWallet(zfxAddress, {fromHeight, toHeight})` → POST `/ResyncShieldedWallet`

`lib/features/privacy/models/plonk_status.dart`
- Freezed model: `proofProvingImplemented`, `proofVerificationImplemented`, `enforcePlonkProofsForZk`, `capVerifyV1`, `capProveV1`
- `@JsonKey(name: "ProofProvingImplemented")` etc. for API field mapping

`lib/features/privacy/models/shielded_address.dart`
- Freezed model: `zfxAddress`, `derivationPath`, `coinType`, `addressIndex`
- `@JsonKey(name: "ZfxAddress")` etc.

`lib/features/privacy/models/shielded_balance.dart`
- Freezed model: `shieldedBalances` (Map<String, double>), `unspentCommitments`, `unspentSum`, `lastScannedBlock`, `isViewOnly`, `commitments` (optional list)

`lib/features/privacy/models/shielded_commitment.dart`
- Freezed model: `commitment`, `assetType`, `amount`, `treePosition`, `blockHeight`, `isSpent`

**Run:** `fvm flutter pub run build_runner build --delete-conflicting-outputs`

**Checkpoint:** Service and models compile. No UI yet.

---

## Phase 2: Providers
> State management. Connects service layer to future UI.

**Files to create:**

`lib/features/privacy/providers/plonk_status_provider.dart`
- `@Riverpod(keepAlive: true)` — fetches PLONK status once, caches it
- Returns `PlonkStatus?` (null = not fetched yet, or node doesn't support)
- Exposes `bool get isPrivacyEnabled` convenience

`lib/features/privacy/providers/shielded_address_provider.dart`
- StateNotifier managing `ShieldedAddress?`
- `generate()` — calls service, stores result
- `load()` — tries to fetch balance (if it succeeds, address exists; if not, null)
- Persists zfx_ address locally (SharedPreferences or provider state)

`lib/features/privacy/providers/shielded_balance_provider.dart`
- Fetches balance from service with `includeCommitments: true`
- Auto-refresh on a timer (e.g. every 30s) since node auto-scans
- Returns `ShieldedBalance?`

`lib/features/privacy/providers/privacy_actions_provider.dart`
- Stateless action methods: `shield()`, `unshield()`, `transfer()`, `consolidate()`
- Each calls the service, shows toast on success/error, triggers balance refresh

**Run:** `fvm flutter pub run build_runner build --delete-conflicting-outputs`

**Checkpoint:** Providers compile. Still no UI.

---

## Phase 3: Screen Shell + Navigation Wiring
> Privacy tab appears in side nav (PLONK-gated). Screen shows activation or placeholder.

**Files to create:**

`lib/features/privacy/screens/privacy_screen.dart`
- Top-level screen for the tab
- Reads `plonkStatusProvider` and `shieldedAddressProvider`
- If no address: show activation card
- If address exists: show dashboard (placeholder for now)

`lib/features/privacy/components/privacy_activation_card.dart`
- Intro text explaining the privacy layer
- "Activate Privacy Wallet" button → calls `shieldedAddressProvider.generate()`
- Loading state while generating

**Files to modify:**

`lib/core/app_router.dart`
- Add `AutoRoute` child for Privacy screen under RootContainer

`lib/features/navigation/components/root_container_side_nav_list.dart`
- Add `RootContainerSideNavItem` for "Privacy" (desktop only, `!kIsWeb`)
- Conditionally shown based on PLONK status provider

**Run:** `fvm flutter pub run build_runner build --delete-conflicting-outputs` (for router codegen)

**Checkpoint:** App compiles. Privacy tab visible in side nav. Clicking it shows activation screen. Clicking "Activate" generates a zfx_ address.

---

## Phase 4: Dashboard
> Main privacy screen with balance, address, action buttons, and commitment list.

**Files to create:**

`lib/features/privacy/components/privacy_dashboard.dart`
- Displays zfx_ address with copy button
- Shows shielded VFX balance (total)
- 4 action buttons: Shield, Unshield, Transfer, Consolidate (wired to open dialogs in Phase 5)
- For now, buttons show "Coming soon" toast

`lib/features/privacy/components/commitment_list.dart`
- Expandable section: "Commitments (N notes)"
- Lists individual notes: amount, tree position, block height
- Collapsed by default

**Files to modify:**

`lib/features/privacy/screens/privacy_screen.dart`
- Replace dashboard placeholder with `PrivacyDashboard` widget

**Checkpoint:** Privacy screen shows real balance and address from the node. Commitment list expands/collapses. Action buttons are visible but not yet functional.

---

## Phase 5: Action Dialogs
> All 4 privacy operations become functional.

**Files to create:**

`lib/features/privacy/components/shield_dialog.dart`
- From Address: dropdown pre-filled with current wallet
- Amount: text field (validates ≥ 0.001 VFX)
- Shows transparent fee info
- Recipient auto-set to user's zfx_ address
- Confirm → calls `privacyActionsProvider.shield()`, closes dialog, refreshes balance

`lib/features/privacy/components/unshield_dialog.dart`
- To Address: blank text field (any transparent address)
- Amount: text field
- Shows fee deduction note ("0.000003 VFX fee deducted from shielded balance")
- Confirm → calls `privacyActionsProvider.unshield()`

`lib/features/privacy/components/private_transfer_dialog.dart`
- Recipient: blank text field (validates `zfx_` prefix)
- Amount: text field
- Fee info
- Confirm → calls `privacyActionsProvider.transfer()`

`lib/features/privacy/components/consolidate_dialog.dart`
- No form fields, just confirmation text
- Shows: "Merge your 2 smallest notes. Fee: 0.000003 VFX"
- Disabled if < 2 unspent notes
- Confirm → calls `privacyActionsProvider.consolidate()`

**Files to modify:**

`lib/features/privacy/components/privacy_dashboard.dart`
- Wire action buttons to open their respective dialogs

**Checkpoint:** Full shield/unshield/transfer/consolidate flow works end-to-end against a testnet node.

---

## Phase 6: Settings Menu (Viewing Keys + Resync)
> Advanced features behind the gear icon.

**Files to create:**

`lib/features/privacy/components/privacy_settings_menu.dart`
- Gear icon button in the dashboard header
- PopupMenu with 3 options:
  - **Export Viewing Key** → calls service, shows Base64 key in a copyable dialog
  - **Import Viewing Key** → dialog with zfx_ address + Base64 key fields
  - **Resync Wallet** → confirmation dialog, calls `resyncShieldedWallet(zfxAddress, fromHeight: 0, toHeight: 0)`

**Files to modify:**

`lib/features/privacy/components/privacy_dashboard.dart`
- Add gear icon to header row, wired to `PrivacySettingsMenu`

**Checkpoint:** All features complete. Viewing keys can be exported/imported. Resync recovers from bad state.

---

## Verification (after all phases)
- Testnet node with PLONK enabled
- Privacy tab appears in nav, activation flow works
- Shield VFX → balance updates after block confirms
- Unshield back → transparent balance increases
- Private transfer to another zfx_ address
- Consolidate with multiple notes
- Error cases: insufficient balance, below minimum, < 2 notes for consolidate
- PLONK gating: tab hidden when node lacks support
- Export/import viewing key round-trip
- Resync recovers correct balance
