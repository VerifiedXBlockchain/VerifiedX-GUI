# Phase 3 Verification: Ceremony Provider

**Verdict: PASS**

**File reviewed:** `lib/features/btc/providers/mpc_ceremony_provider.dart`

---

## Checklist

| Requirement | Status | Notes |
|-------------|--------|-------|
| New file at correct path | PASS | `lib/features/btc/providers/mpc_ceremony_provider.dart` |
| `StateNotifier<MpcCeremonyState>` | PASS | Line 59 |
| `keepAlive: true` (survives navigation) | PASS | `StateNotifierProvider` (not `.autoDispose`) is kept alive by default in Riverpod |
| `startCeremony(ownerAddress)` | PASS | Lines 68-92; calls `VbtcV2Service().initiateCeremony()`, stores ceremony state, starts polling |
| Polling loop (2s interval) | PASS | `_kPollingInterval = Duration(seconds: 2)`, `Timer.periodic` at line 96 |
| `createContract(name, description, ticker)` | PASS | Lines 168-202; calls `VbtcV2Service().createContract()` after ceremony completes |
| `reset()` | PASS | Lines 204-210; cancels timer, resets all internal state |
| Timer cancelled in `dispose()` | PASS | Lines 212-216 |
| Timer cancelled in `reset()` | PASS | Line 205 |
| Timer cancelled on terminal states | PASS | Lines 107, 138, 149 |
| No existing files modified | PASS | Only new file added |

## State Machine

| Plan Transition | Implementation | Status |
|----------------|----------------|--------|
| `idle` → `ceremonyInProgress` | `startCeremony()` sets phase on success | PASS |
| `ceremonyInProgress` → `ceremonyCompleted` | `_poll()` on `MpcCeremonyStatus.completed` | PASS |
| `ceremonyInProgress` → `failed` | `_poll()` on failed/timedOut/network errors/client timeout | PASS |
| `ceremonyCompleted` → `creatingContract` | `createContract()` sets phase before API call | PASS |
| `creatingContract` → `contractCreated` | `createContract()` on success with hash | PASS |
| `creatingContract` → `failed` | `createContract()` when hash is null | PASS |
| `failed` → `idle` (on retry) | Via `reset()` returning to default state | PASS |

All transitions from the plan are implemented correctly.

## Error Handling

| Scenario | Plan Requirement | Implementation | Status |
|----------|-----------------|----------------|--------|
| API returns `failed`/`timedOut` | State → `failed` with message | Lines 147-159; distinct messages for failed vs timedOut | PASS |
| Single poll failure | Swallowed, retry next tick | Lines 120-131; increments counter, returns without state change | PASS |
| 3 consecutive poll failures | State → `failed` with network error | `_kMaxConsecutivePollFailures = 3`, lines 122-129 | PASS |
| Client-side timeout | State → `failed` with timeout message, configurable duration | `_kCeremonyTimeoutDuration = Duration(minutes: 5)`, lines 104-114 | PASS |
| Timeout as extractable constant | Easy to adjust | Named constant `_kCeremonyTimeoutDuration` at line 53 | PASS |

## Lifecycle Safety

- **`mounted` checks** after every async operation (`_poll` at lines 102, 118; `createContract` at line 186) -- prevents state updates on disposed notifier
- **Guard clause** in `createContract` -- only proceeds if phase is `ceremonyCompleted` and ceremony/owner are non-null (lines 173-174)
- **Timer cancellation** in three places: `dispose()`, `reset()`, and all terminal state transitions

## Toast Notifications (Supports Phase 4 post-dismiss behavior)

The provider fires toast notifications on all terminal states, which the plan requires for notifying the user if they've dismissed the modal:
- Ceremony completed: `Toast.message("MPC ceremony completed successfully.")`
- Ceremony failed: `Toast.error("MPC ceremony failed.")`
- Client-side timeout: `Toast.error("MPC ceremony timed out.")`
- Network failure: `Toast.error("Lost connection to ceremony.")`
- Contract created: `Toast.message("vBTC contract created. Hash: $hash")`

## State Class

`MpcCeremonyState` (lines 18-49) includes:
- `phase: MpcCeremonyPhase` -- tracks position in state machine
- `ceremony: MpcCeremony?` -- the freezed model from Phase 2
- `errorMessage: String?` -- human-readable error for UI
- `contractHash: String?` -- populated on successful contract creation
- Convenience getters: `isIdle`, `isInProgress`, `isFailed`, `isContractCreated`
- `copyWith` for immutable state updates

## Pattern Compliance

Consistent with existing project patterns:
- Uses `StateNotifierProvider` like `readyProvider`, `sessionProvider`, etc.
- State class with `copyWith` pattern matches `VBtcOnboardState`
- Service instantiation (`VbtcV2Service()`) matches the project pattern of creating service instances per call
- `Ref` stored as field on notifier, consistent with existing notifiers

## No Regressions

The provider is self-contained. No existing files were modified.
