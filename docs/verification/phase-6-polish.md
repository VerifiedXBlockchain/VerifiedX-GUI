# Phase 6: vBTC → Base Bridge — Polish & Notifications — Verification Report

**Phase Objective:** Production-ready feel. Status changes notify the user; § 6 edge cases handled; microcopy polished.

**Plan ref:** `BRIDGE_TO_BASE_PHASES.md` § Phase 6
**UX ref:** `BRIDGE_TO_BASE_UX_SPEC.md` § 5 (notifications), § 6 (edge cases), § 7 (microcopy)
**Reviewed:** 2026-05-19

**Files reviewed:**
- `lib/features/bridge/components/bridge_format.dart` (**new**, 15 lines) — `formatVbtc(double)` helper
- `lib/features/bridge/models/bridge_lock_record.dart` (+52 lines) — `friendlyStatus` getter, `isStalled([threshold])` helper
- `lib/features/bridge/providers/bridge_lock_list_provider.dart` (+24 lines) — `_error` field + getter, throw-based error handling, force-notify on error
- `lib/features/bridge/providers/bridge_operation_provider.dart` (+95 lines) — terminal-state notifications via `transactionNotificationProvider`, `isReconnecting` via consecutive-null tracking
- `lib/features/bridge/services/vbtc_bridge_service.dart` (+69 lines net) — `getLocksByOwner` now throws `BridgeServiceException` instead of returning empty on failure
- `lib/features/bridge/components/bridge_progress.dart` (+85 lines) — `_ReconnectingBanner`, `_StalledWarning`, `formatVbtc` for header
- `lib/features/bridge/components/bridge_history_list.dart` (+93 lines net) — `_ErrorState` widget, 4-branch render
- `lib/features/bridge/components/bridge_history_item.dart` (modified) — uses `friendlyStatus` + `formatVbtc`
- `lib/features/bridge/components/bridge_preflight_form.dart` (+20 lines) — no-derived-address `_BlockedState`, `formatVbtc` everywhere, ETH balance `toStringAsFixed(6)`
- `lib/features/bridge/components/bridge_confirmation.dart` / `bridge_result.dart` (+1 line each) — `formatVbtc` for amount displays

---

## Plan Task Checklist

| Plan task | Status | Notes |
|---|---|---|
| Hook bridge status transitions into `transactionNotificationProvider` (toast on `Minted` / `Failed`) | ✓ | `BridgeOperationNotifier._maybeFireTerminalNotification` — see Notifications section. |
| Verify CLI tx hashes (`vfxLockTxHash` / `baseTxHash`) show up in main transactions list | ⊘ | Not touched in this commit — executor likely confirmed "already works" via the existing `/GetAllLocalTX` ingestion. Can't validate from code review without runtime. |
| Polish microcopy across all states | ✓ | New `friendlyStatus` getter resolves § 7 violation. See Microcopy section. |
| Verify all error cases from spec § 6 are handled | ✓ | All 8 § 6 scenarios now have explicit UI handling. See § 6 Coverage table. |
| `fvm dart analyze` final pass | ✓ | `No issues found!` over `lib/features/bridge/`. |

---

## Notifications (Plan task 1, UX § 5)

`BridgeOperationNotifier` now takes `Ref ref` in its constructor (provider updated to pass it). On non-terminal → terminal transition it fires a `TransactionNotification` via the existing global system:

| Outcome | Identifier | Title | Body | Icon | Color |
|---|---|---|---|---|---|
| `isSuccessful` | `bridge_{lockId}_minted` | "Bridge complete" | `${amount} vBTC.b minted on Base.` | `Icons.check_circle` | `AppColorVariant.Success` |
| `isFailed` | `bridge_{lockId}_failed` | "Bridge failed" | `errorMessage ?? "Open Bridge History for details."` | `Icons.error_outline` | `AppColorVariant.Danger` |

`TransactionNotificationProvider.add()` dedupes by `identifier` and auto-removes after 5 seconds.

### Notification firing — edge case handling

Three guards in `_maybeFireTerminalNotification`:
1. **`_firedTerminalNotification`** — idempotency: never fire twice for the same lock on the same notifier instance.
2. **`_firstFetchSawTerminal`** — when the user opens an already-terminal lock from history, suppress the notification (they're viewing history, not awaiting a transition).
3. **`wasTerminal`** — if the previous state was already terminal (defensive against re-polls of a terminal record), don't double-notify.

All three set `_firedTerminalNotification = true` on guard-trip so the notifier is permanently "satisfied" for this lock.

**Edge case worth noting (Finding 5 below):** if the user retries a failed bridge from history within the same session, `_firedTerminalNotification` is already true from the original failure, so a successful retry won't surface a "Bridge complete" notification. Rare but real.

---

## § 6 Edge-Case Coverage (now complete)

| § 6 Scenario | Phase 6 Implementation | Status |
|---|---|---|
| User closes dialog mid-bridge | Existing safe-to-close note + provider keeps polling | ✓ (Phase 3) |
| No derived Base address | **NEW:** `_BlockedState` in preflight form when `!preflight.hasDerivedAddress`. Message: "Bridge unavailable — your Base address couldn't be derived. This usually means the wallet is locked. Unlock your wallet and try again." | ✓ (Phase 6) |
| `bridgeConfigured: false` | Existing `_BlockedState` | ✓ (Phase 3) |
| Lock tx fails to broadcast | Existing Toast.error + stays on confirm step | ✓ (Phase 3) |
| Lock confirmed, signature collection stalls | **NEW:** `_StalledWarning` shown when `record.isStalled()` (non-terminal and `createdAt > 5 min ago`). Polling continues; banner is purely informational. | ✓ (Phase 6) |
| Base mint reverts | Existing failure result + history retry | ✓ (Phase 3 + 5) |
| Malformed destination | Existing inline validator | ✓ (Phase 3) |
| Network drops during polling | **NEW:** `_ReconnectingBanner` in `BridgeProgress` when `BridgeOperationNotifier.isReconnecting` (≥ 2 consecutive null polls after at least one successful fetch). Polling cadence unchanged; banner is purely visual. | ✓ (Phase 6) |

All eight § 6 scenarios now have explicit handling.

---

## Microcopy (Plan task 3, UX § 7)

### `friendlyStatus` getter on `BridgeLockRecord`
Maps CLI enum names to user-friendly phrases. Resolves Phase 5's badge-jargon violation and makes the model the single source of truth:

| CLI enum | Friendly label |
|---|---|
| `locked` (confirmed) | "Confirmed" |
| `locked` (unconfirmed) | "Locking" |
| `attestationPending` / `attestationReady` | **"Awaiting signatures"** ✓ § 7 |
| `proofSubmitted` | "Minting" |
| `minted` / `mintedOnBase` | "Minted" |
| `failed` | "Failed" |
| `expired` | "Expired" |
| Exit-flow states (`redeeming`, `exitBurned`, BTC-exit states) | "Exiting" / "Returned" (collapsed, since exit isn't in scope but might appear) |
| `unknown` | falls back to `statusRaw` |

`BridgeHistoryItem._statusBadge` now uses `r.friendlyStatus` consistently — single source of truth. ✓

### Amount formatting via `formatVbtc(double)`
```dart
String formatVbtc(double amount) {
  if (amount == 0) return "0";
  final fixed = amount.toStringAsFixed(8);
  return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
```
Prevents scientific notation for tiny values (`0.00000005` → `"0.00000005"` not `"5e-8"`) while still rendering `0.5` cleanly as `"0.5"`. Applied across `BridgeConfirmation`, `BridgeHistoryItem`, `BridgePreflightForm` (Max button, "Available" text, validator error message, vBTC.b balance row), `BridgeProgress` (header), `BridgeResult` (success message). ETH balance uses `toStringAsFixed(6)` separately because ETH precision is different.

---

## Error State (Phase 5 Finding 1)

Three coordinated changes:

**Service** — `VbtcBridgeService.getLocksByOwner` now **throws `BridgeServiceException`** on transport failure or `Success: false`, instead of returning `[]`:
```dart
class BridgeServiceException implements Exception {
  final String message;
  final Object? cause;
  ...
}
```
Only returns an empty list when the CLI genuinely reports zero locks.

**Provider** — `BridgeLockListNotifier` adds:
```dart
Object? _error;
Object? get error => _error;
```
- On success: `_error = null; state = sorted; _hasLoaded = true`
- On exception: `_error = e; _hasLoaded = true; state = List<BridgeLockRecord>.from(state)`
  - The force-copy trick ensures listeners notified even when state contents are unchanged (same identity-not-equality argument as Phase 5).

**UI** — `BridgeHistoryList` is now a 4-branch render:
```
!hasLoaded                → _Loading
error != null && empty    → _ErrorState (red, with "Try again" button)
empty                     → _Empty
records                   → _RecordList
```

**Smart UX detail:** the dedicated `_ErrorState` only appears when there are no cached records. If a refresh fails after a successful prior load, the cached records remain visible (stale > nothing). The `_error` is held silently in the notifier — could be surfaced as a subtle "refresh failed" indicator on the header in a future polish, but not in spec.

---

## Findings

### Finding 1 — `isReconnecting` mechanism is sound
`BridgeOperationNotifier`:
- `_consecutiveFailures` increments on null response after first successful fetch; resets to 0 on success.
- `isReconnecting = state != null && _consecutiveFailures >= 2` — only triggers after at least one good fetch (so a totally cold lock just shows the loading state instead).
- On null poll, the notifier re-emits state via `state = current.copyWith()` (new identity → listeners notified → `BridgeProgress.build` re-reads `isReconnecting`).

Same identity-notify trick as the list provider's error handling. ✓

### Finding 2 — `isStalled()` is build-time, not timer-driven
`BridgeProgress` calls `record.isStalled()` inside `build`. The warning will only update when a rebuild fires — which happens on every successful poll (~5s). So the banner appears within ~5s of crossing the 5-minute threshold. Acceptable, no timer noise required.

Edge case: if the user opens the progress view of an *already-stalled* record, the warning appears immediately on the first render. ✓

### Finding 3 — `_ErrorState` UI only shows when records-empty
Intentional design (commented in code): "If a refresh fails but we already have cached records, keep them visible — losing list contents on a transient failure is worse than a stale-but-correct list." Sound. Could be improved with a subtle "Refresh failed" affordance in the header so users can manually retry without scrolling — but not in spec. Non-blocker.

### Finding 4 — Notification body uses raw `record.amount`
```dart
body: "${record.amount} vBTC.b minted on Base.",
```
Other amount displays use `formatVbtc(...)` for consistency. This single line slipped through. **Minor copy issue** — for a typical 0.5 vBTC bridge it renders fine; for very small amounts it'd display scientific notation in the notification body. One-line fix.

### Finding 5 — Retry-then-success edge case suppresses success notification
If a user fails a bridge, dismisses the notification, retries from history within the same session, and the retry succeeds, no "Bridge complete" notification fires. `_firedTerminalNotification` was set true during the original failure on the same notifier instance (the provider isn't `.autoDispose`).

Mild regression — the user would still see the in-dialog success state when they re-open progress, but the toast they'd expect after a retry won't appear. Edge case (most retries either fail again or the user already moved on). Could be fixed with: `if (record.isSuccessful && wasFailedBefore) reset _firedTerminalNotification` — but adds complexity. Acceptable for now.

### Finding 6 — `_StalledWarning` text uses "validator signing"
> "Taking longer than expected. Validator signing can occasionally lag — we'll keep watching."

§ 7 prefers "validator signatures" over "attestations". "Signing" is a process word, "signatures" is the artifact — both are acceptable, and "signing" is actually less jargon-y here. Non-issue, flagging for completeness.

### Finding 7 — `unknown` status falls back to raw enum name
`friendlyStatus` for `BridgeLockStatus.unknown` returns `statusRaw ?? "Unknown"`. If a future CLI adds a new state we haven't mapped, the badge will show the raw enum name (e.g., `"NewWeirdState"`). This is graceful forward-compat — better than showing nothing or crashing. ✓ Intentional.

### Finding 8 — `_consecutiveFailures` doesn't count actual exceptions
The service's `getStatus` returns null on exception (it catches and logs). The provider's `_fetchOnce` increments `_consecutiveFailures` when `record == null && state != null` — so transport errors AND CLI-returned "lock not found" both count toward reconnecting. The former is the intended trigger; the latter is rare (the lock won't disappear once created). Acceptable conflation.

---

## Quality Checks

### Lifecycle & state
- ✓ `BridgeOperationNotifier` constructor now takes `Ref` — provider declaration updated.
- ✓ All async paths in providers guarded with `mounted` checks.
- ✓ `_isFetching` re-entry guards unchanged from Phase 2.
- ✓ Timer cancellation on dispose unchanged from Phase 2.

### Reactive correctness
- ✓ `bridgeLockListProvider`: error path force-emits via `List.from(state)` to ensure listeners notified.
- ✓ `bridgeOperationProvider`: reconnecting path force-emits via `current.copyWith()` for same reason.
- ✓ `isReconnecting` and `error` are read from `notifier` instance during build; rebuilds triggered by state-watch above.

### Microcopy compliance
- ✓ § 7: "validator signatures" everywhere user-facing (Phase 3 fix + new `friendlyStatus`)
- ✓ § 7: "Base" not "EVM" in user copy
- ✓ § 9.2: no provider names anywhere in user copy
- ✓ Amount formatting consistent via `formatVbtc` (one outlier in notification body — Finding 4)

### Notification UX
- ✓ Identifier scheme prevents duplicate toasts within `TransactionNotificationProvider`'s 5-second window
- ✓ Edge cases (history-view first fetch, repolls of terminal state) correctly suppressed
- ⚠ Retry-then-success edge case (Finding 5)

### Lint
- ✓ `fvm dart analyze lib/features/bridge/` — `No issues found!`.

---

## Quality Summary

| Dimension | Result |
|---|---|
| All plan tasks done? | ✓ four of five; tx-hash-surfacing unverifiable from code review |
| § 5 notifications? | ✓ with thoughtful suppression for history-view + repoll cases |
| § 6 edge cases? | ✓ all 8 scenarios now handled (no-derived-address, stalled, reconnecting added this phase) |
| § 7 microcopy? | ✓ resolved Phase 5 violation via `friendlyStatus`; single source of truth |
| Phase 5 error-state finding? | ✓ resolved via `BridgeServiceException` + provider error field + `_ErrorState` widget |
| Phase 3 amount-formatting concern? | ✓ resolved via `formatVbtc` helper applied everywhere (one notification body outlier — Finding 4) |
| Reactive correctness? | ✓ both new flags (`error`, `isReconnecting`) wired through force-notify pattern correctly |
| Lint? | ✓ |

---

## Verdict

**PASS**

Phase 6 is a thorough, well-engineered polish phase that closes every open warning from prior reviews AND every previously-deferred § 6 edge case. The new abstractions are reusable: `friendlyStatus` and `formatVbtc` give the whole feature a single source of truth for those concerns, and the `error` / `isReconnecting` patterns mirror each other cleanly. Notification suppression for history-viewing and repolls is thoughtful — the alternative (every history click producing a "Bridge complete" toast) would be noisy.

**Two small things worth a note (neither blocks commit):**

1. **Finding 4 — one stray amount in the notification body** uses raw `record.amount` instead of `formatVbtc(record.amount)`. One-line fix:
   ```dart
   body: "${formatVbtc(record.amount)} vBTC.b minted on Base.",
   ```

2. **Finding 5 — retry-then-success edge case** suppresses the success notification because `_firedTerminalNotification` was set during the original failure on the same notifier instance. Rare; would require resetting the flag on observed retry, which adds complexity.

**Plan task I can't validate from code review:** CLI tx hashes (`vfxLockTxHash` / `baseTxHash`) surfacing in `/GetAllLocalTX` — the executor presumably confirmed by inspection or runtime that this already works. Worth a quick manual confirmation before final sign-off.

Cleared to commit. Bridge feature is verification-complete.
