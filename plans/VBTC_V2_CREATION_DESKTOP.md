# vBTC V2 Token Creation — Desktop Plan

## Scope

Replace the existing V1 tokenization form with V2 creation (MPC ceremony → contract creation) on the desktop wallet, which talks directly to the local CLI.

**Out of scope:** V1 transfer/withdraw/ownership (unchanged), version detection/routing (TBD), BTC account management (unchanged), web wallet (separate plan).

---

## Phase 1: Service Layer — `VbtcV2Service`

**New file:** `lib/features/btc/services/vbtc_v2_service.dart`

A new service class extending `BaseService` with `apiBasePathOverride: "/vbtcapi/vbtc"`.

> **Note:** This uses a different API base path (`/vbtcapi/vbtc`) than the existing `BtcService` (`/btcapi/BTCV2`), which is why it's a separate service class rather than adding methods to `BtcService`.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `initiateCeremony(ownerAddress)` | `POST /InitiateMPCCeremony/{address}` | Starts DKG, returns `ceremonyId` |
| `getCeremonyStatus(ceremonyId)` | `GET /GetCeremonyStatus/{id}` | Polls ceremony progress |
| `createContract({ownerAddress, name, description, ticker, ceremonyId})` | `POST /CreateVBTCContract` | Creates on-chain contract from completed ceremony |

Follows the same `BaseService` + Dio pattern as `BtcService`. Error handling follows existing pattern: check `result['Success'] == true`, surface errors via `Toast.error()`, return `null` on failure.

**Files touched:** None (new file only)

---

## Phase 2: Ceremony State Model

**New file:** `lib/features/btc/models/mpc_ceremony.dart`

A freezed model representing ceremony state:

```
Fields:
- ceremonyId: String
- status: MpcCeremonyStatus (enum)
- progressPercentage: int
- depositAddress: String? (populated on completion)
- frostGroupPublicKey: String? (populated on completion)
- dkgProof: String? (populated on completion)
- validatorCount: int?
- requiredThreshold: int?
- proofBlockHeight: int?

Enum MpcCeremonyStatus:
- initiated
- validatingValidators
- round1InProgress
- round2InProgress
- round3InProgress
- completed
- failed
- timedOut
```

**Post-phase step:** Run `fvm dart run build_runner build --delete-conflicting-outputs` to generate `.freezed.dart` and `.g.dart` files before proceeding to Phase 3.

**Files touched:** None (new file only)

---

## Phase 3: Ceremony Provider (State Management)

**New file:** `lib/features/btc/providers/mpc_ceremony_provider.dart`

A `StateNotifier<MpcCeremonyState>` that orchestrates the ceremony polling flow. The provider is `keepAlive: true` so it survives navigation (the ceremony continues even if the user dismisses the modal).

1. **`startCeremony(ownerAddress)`** — Calls `VbtcV2Service.initiateCeremony()`, stores `ceremonyId`, starts 2s polling timer
2. **Polling loop** — Calls `getCeremonyStatus` every 2s, updates state with progress/status/round
3. **`createContract(name, description, ticker)`** — Called after ceremony completes, hits `CreateVBTCContract`
4. **`reset()`** — Cancels any active timer, resets state to idle

### Lifecycle and cleanup

- Timer is cancelled via `ref.onDispose()` callback to prevent firing against a dead notifier
- Timer is also cancelled explicitly in `reset()` and on terminal states (completed, failed, timedOut)

### Error handling

- **Ceremony failure** (API returns `failed`/`timedOut`): State moves to `failed` with error message. User can retry from the UI (calls `reset()` then `startCeremony()` again — starts a new ceremony).
- **Network errors during polling**: A single poll failure is swallowed and retried on next tick. Three consecutive poll failures move state to `failed` with a network error message.
- **Client-side timeout**: If polling exceeds a configurable duration without reaching a terminal state, state moves to `failed` with a timeout message. Default to 5 minutes initially, but this needs validation on testnet before shipping — extract as a constant so it's easy to adjust.

### State machine

```
idle → ceremonyInProgress → ceremonyCompleted → creatingContract → contractCreated
                 ↓                                       ↓
              failed                                  failed
                 ↓
         idle (on retry)
```

**Files touched:** None (new file only)

---

## Phase 4: Ceremony Progress Modal

**New file:** `lib/features/btc/components/mpc_ceremony_progress_modal.dart`

A modal dialog that watches the `mpcCeremonyProvider`:

- Step indicators showing ceremony progression (Round 1 → 2 → 3)
- Progress percentage display
- **No cancel button** — ceremony cannot be cancelled by user
- **Dismissible** — user can close the modal and navigate away; the provider (`keepAlive: true`) continues polling in the background
- On completion: success state with deposit address shown, toast notification
- On failure/timeout: error state with message and a **Retry** button (calls `reset()` + `startCeremony()`)

### Post-dismiss behavior

If the user dismisses the modal mid-ceremony, they are notified of the outcome via:
- A global toast notification triggered by the provider when it reaches a terminal state (completed or failed)
- The token list refreshes automatically on `contractCreated`, so the new token appears if they navigate to the list

The modal can also be re-opened from the tokenize screen if a ceremony is in progress (provider state is not `idle`), allowing the user to check progress without starting a new ceremony.

**Files touched:** None (new file only)

---

## Phase 5: Replace V1 Creation Form with V2

**Modify:** `lib/features/btc/providers/tokenize_btc_form_provider.dart`

Update `submit()` to use V2 two-step flow:

1. Validate form fields
2. Call `ref.read(mpcCeremonyProvider.notifier).startCeremony(ownerAddress)` — returns immediately
3. Return a signal to the screen that the ceremony has started (the provider does **not** show the modal itself)

On ceremony completion (handled by screen watching ceremony provider state):
4. Call `VbtcV2Service.createContract()` with form data + ceremony result
5. On success: show toast, refresh token list, clear form

The old `BtcService.tokenizeBtc()` call is replaced. `submitWeb()` left unchanged.

> **Design note:** The form provider initiates the ceremony and contract creation, but the **screen** is responsible for showing/dismissing the progress modal. This preserves the existing separation between provider (state/logic) and screen (UI).

**Modify:** `lib/features/btc/screens/tokenize_btc_screen.dart`

Update form fields for V2:

- Name, Description, Ticker fields (with client-side validation — TBD: confirm field constraints from API docs)
- VFX address selector (same as current)
- Image upload and multi-asset support — **TBD pending blockchain dev confirmation**
- Submit button triggers ceremony via form provider, then shows progress modal
- If a ceremony is already in progress (provider not idle), show "View Progress" instead of "Submit"

**Files touched:** 2 existing files modified

---

## Phase 6: Onboarding Flow Update

**Modify:** `lib/features/btc/providers/tokenized_btc_onboard_provider.dart`

The "tokenize" step (step 5 of 6) in the onboarding wizard currently calls `BtcService().tokenizeBtc()` as a single async call, then listens for a transaction via `ProviderSubscription`.

### Changes needed

1. Replace the `tokenizeBtc()` call with the V2 ceremony flow: `startCeremony()` → poll → `createContract()`
2. The listener changes from watching for a transaction to watching the `mpcCeremonyProvider` state for `contractCreated`
3. During the ceremony, the onboarding wizard stays on step 5 with inline progress (reuse the ceremony step indicators from the progress modal as a widget, not a separate modal)
4. On ceremony failure: show error inline with a Retry button. The user stays on step 5 and can retry without restarting the wizard.
5. Processing state updates: `waitingForTokenization` now covers the full ceremony + contract creation duration

**Files touched:** 1 existing file modified

---

## Phase 7: Token List / Detail Screen Updates (Follow-up)

> This phase is deferred until open items are resolved, but is called out here as a known requirement.

If V2 tokens have different fields (e.g., `depositAddress`, `frostGroupPublicKey`, `dkgProof`), the following will need updates:

- `TokenizedBitcoin` model — extend with V2 fields or create a V2 variant
- Token list screen — may need version badge or different display for V2 tokens
- Token detail screen — show V2-specific fields (deposit address, validator info, etc.)

Scope depends on whether `GetTokenizedBTCList` returns V2 tokens with additional fields or if a separate endpoint is needed.

**Files touched:** TBD

---

## Open Items (Blocked on Blockchain Dev)

- [ ] Multi-asset support in `CreateVBTCContract` payload — is it supported? Not in current docs.
- [ ] Custom image support in V2 — same question.
- [ ] Does `GetTokenizedBTCList` return V2 tokens mixed in, or is there a separate endpoint?
- [ ] Version field in token response — needed for future V1/V2 routing in token list/detail screens.
- [ ] Field validation constraints for Name, Description, and Ticker (max lengths, allowed characters, etc.).
- [ ] Expected ceremony duration range — needed to calibrate client-side timeout.

---

## File Summary

| File | Action | Phase |
|------|--------|-------|
| `lib/features/btc/services/vbtc_v2_service.dart` | **New** | 1 |
| `lib/features/btc/models/mpc_ceremony.dart` | **New** | 2 |
| `lib/features/btc/providers/mpc_ceremony_provider.dart` | **New** | 3 |
| `lib/features/btc/components/mpc_ceremony_progress_modal.dart` | **New** | 4 |
| `lib/features/btc/providers/tokenize_btc_form_provider.dart` | **Modify** | 5 |
| `lib/features/btc/screens/tokenize_btc_screen.dart` | **Modify** | 5 |
| `lib/features/btc/providers/tokenized_btc_onboard_provider.dart` | **Modify** | 6 |
| Token list/detail screens | **TBD** | 7 |
