# vBTC → Base Bridge: Implementation Phases

Reference: `BRIDGE_TO_BASE_UX_SPEC.md`

Each phase is scoped to one logical commit. Phases are sequential — each depends on the previous. Reasonable mid-phase checkpoints noted.

---

## Phase 1 — Foundation: Service, Models, Constants

**Goal:** All the data layer pieces in place. No UI yet. Verifiable by manually hitting endpoints from a test harness.

- [ ] Add `BRIDGE_MIN_ETH_FOR_GAS = 0.0005` constant in `lib/core/app_constants.dart`
- [ ] Create freezed model `BridgePreflight` matching `GET /api/vbtc/bridge/preflight` response
- [ ] Create freezed model `BridgeLockRecord` matching `GET /api/vbtc/bridge/status/{lockId}` response (the full state machine record)
- [ ] Create freezed model `BridgeLockRequest` for the `POST /api/vbtc/bridge/toBase` body
- [ ] Create `BridgeService` in `lib/features/bridge/services/bridge_service.dart`:
  - `Future<BridgePreflight?> preflight(String ownerAddress, String scUid)`
  - `Future<BridgeLockRecord?> initiateLock(BridgeLockRequest req)`
  - `Future<BridgeLockRecord?> getStatus(String lockId)`
  - `Future<List<BridgeLockRecord>> getLocksByOwner(String ownerAddress)`
  - `Future<bool> retryMint(String lockId)` (verify exact endpoint during implementation)
  - `Future<double?> getBaseBalance(String evmAddress)` (vBTC.b balance)
- [ ] Run `fvm dart run build_runner build --delete-conflicting-outputs` to generate freezed/json code
- [ ] `fvm dart analyze` clean

**Commit:** `feat(bridge): add service, models, and constants for vBTC Base bridge`

---

## Phase 2 — State Management: Providers

**Goal:** Reactive state for preflight, single operation polling, and history list. Still no UI.

- [ ] `bridgePreflightProvider` — `FutureProvider.family<BridgePreflight?, (String owner, String scUid)>`
- [ ] `bridgeOperationProvider` — `StateNotifierProvider.family<BridgeOperationNotifier, BridgeLockRecord?, String /*lockId*/>`
  - Polls `getStatus` every 5s while status is non-terminal
  - Stops polling on terminal status (`Minted`, `MintedOnBase`, `Failed`)
- [ ] `bridgeLockListProvider` — `StateNotifierProvider.family<BridgeLockListNotifier, List<BridgeLockRecord>, String /*ownerAddress*/>`
  - Initial load on construction
  - Auto-refresh every 30s if any item is non-terminal
  - Manual refresh method
- [ ] `activeBridgeOperationsProvider` — derived `Provider<List<BridgeLockRecord>>` that surfaces non-terminal operations across all known lists (for badge counts / global state)
- [ ] `fvm dart analyze` clean

**Commit:** `feat(bridge): add providers for preflight, status polling, and history`

---

## Phase 3 — Bridge Dialog UI

**Goal:** The main flow works end-to-end against a real CLI. No history view yet (deferred to Phase 5).

- [ ] Create `lib/features/bridge/components/bridge_to_base_dialog.dart`:
  - Stateful widget with `_BridgeStep` enum (`preflight`, `confirm`, `progress`, `result`)
  - Static `show(TokenizedBitcoin token, String ownerAddress)` helper
- [ ] `BridgePreflightForm` (step 1):
  - Loading state during preflight fetch
  - Form with amount field + Max button, destination field + Reset to derived button
  - Inline validation (amount > 0, ≤ available; destination is valid 0x address)
  - Yellow gas warning banner when ETH < `BRIDGE_MIN_ETH_FOR_GAS`
  - One-way disclaimer notice at top
  - Network info section (network name, contract address, derived address, ETH balance, vBTC.b balance)
  - "Review Bridge" button → step 2
  - Error states (no vBTC, bridge not configured, network failure with Retry)
- [ ] `BridgeConfirmation` (step 2):
  - Summary card showing amount and destination
  - Step list (1-3 of the actual flow)
  - One-way reminder
  - Back / Confirm & Bridge buttons
- [ ] `BridgeProgress` (step 3):
  - Vertical stepper UI keyed off `BridgeLockRecord.status`
  - Tx hash rows with copy + explorer links (for VFX block explorer + Basescan)
  - Signature counter when in `AwaitingSignatures`
  - Note about safe-to-close
  - Disable Cancel during in-flight
- [ ] `BridgeResult` (step 4):
  - Success: vBTC.b balance message, "What's next" card (generic — no provider names), Basescan link
  - Failure: error message, link to history detail
- [ ] Wire to `bridgeOperationProvider` for live status updates
- [ ] Manually verify the full flow against a live CLI (mainnet or testnet, depending on what we have access to)

**Commit:** `feat(bridge): add bridge to Base dialog flow`

---

## Phase 4 — Entry Point Integration

**Goal:** User can find and launch the dialog. Visible in the app.

- [ ] Identify the right placement in `lib/features/btc/components/tokenized_btc_action_buttons.dart` for the new button
- [ ] Add "Bridge to Base" `AppButton`:
  - Only render for v2 contracts (`token.version == 2`)
  - Only render when `token.balance > 0` (or disabled with tooltip otherwise)
  - Calls `BridgeToBaseDialog.show(token, ownerAddress)`
- [ ] Manual end-to-end test: navigate to a vBTC v2 contract, see the button, run a real bridge

**Commit:** `feat(bridge): add Bridge to Base entry point on vBTC v2 contracts`

---

## Phase 5 — History View

**Goal:** Users can see past bridges and re-open the progress view for any of them.

- [ ] `BridgeHistoryList` component:
  - Uses `ListView.builder` (no pagination)
  - Watches `bridgeLockListProvider`
  - Empty state, loading state, error state
- [ ] `BridgeHistoryItem` row:
  - Amount, short destination, status badge, relative timestamp
  - Tap → opens read-only progress view (reuse `BridgeProgress` with no auto-advance)
  - Trailing "Retry" button when CLI status indicates retry is supported
- [ ] Add `BridgeHistoryList` section to the vBTC v2 contract detail screen (below action buttons)
- [ ] Retry button wired to `BridgeService.retryMint`
- [ ] `fvm dart analyze` clean; manual verification

**Commit:** `feat(bridge): add bridge history view with retry support`

---

## Phase 6 — Polish & Notifications

**Goal:** Production-ready feel. Status changes notify the user; edge cases handled.

- [ ] Hook bridge status transitions into `transactionNotificationProvider` so the user gets a toast/notification when status becomes `Minted` or `Failed`
- [ ] If the CLI surfaces `vfxLockTxHash` / `baseTxHash` via `/GetAllLocalTX`, ensure they show up in the main transactions list (likely already do — verify)
- [ ] Polish microcopy across all states
- [ ] Verify all error cases from spec § 6 are handled
- [ ] `fvm dart analyze` final pass

**Commit:** `feat(bridge): notifications, microcopy polish, edge case handling`

---

## Out of Scope (for clarity)

- Burn UI (`burnForVfxExit` / `burnForBTCExit`)
- Provider-specific integrations (Fireblocks, Blockdaemon, etc.) — future phase
- Notification persistence across app restarts
- Multi-contract bulk bridging
