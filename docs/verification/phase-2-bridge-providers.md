# Phase 2: vBTC → Base Bridge — State Management (Providers) — Verification Report

**Phase Objective:** Reactive state for preflight, single-operation polling, and history list. No UI yet.

**Plan ref:** `BRIDGE_TO_BASE_PHASES.md` § Phase 2
**UX ref:** `BRIDGE_TO_BASE_UX_SPEC.md` § 8 (API surface), § 4 (history view consumer)
**Reviewed:** 2026-05-19

**Files reviewed (note: team-lead said one file; actually four — each provider in its own file, which matches the project's convention from `shielded_balance_provider.dart`, `transaction_list_provider.dart`, etc.):**
- `lib/features/bridge/providers/bridge_preflight_provider.dart`
- `lib/features/bridge/providers/bridge_operation_provider.dart`
- `lib/features/bridge/providers/bridge_lock_list_provider.dart`
- `lib/features/bridge/providers/active_bridge_operations_provider.dart`

---

## Plan Task Checklist

| Plan task | Status | Notes |
|---|---|---|
| `bridgePreflightProvider` — `FutureProvider.family<BridgePreflight?, (owner, scUid)>` | ✓ (key-class swap) | Records require Dart 3; this project pins `>=2.17.3 <3.0.0` — hand-rolled `BridgePreflightArgs` is the right call. |
| `bridgeOperationProvider` — `StateNotifierProvider.family<..., String>` | ✓ | Keyed by `lockId`, polls every 5s while non-terminal. |
| Poll stop on terminal status | ✓ | Uses `record.isTerminal` (not a hardcoded list) — `Expired` is correctly honored. |
| `bridgeLockListProvider` — `StateNotifierProvider.family<..., String>` | ✓ | Keyed by `ownerAddress`. |
| Initial load on construction | ✓ | `_bootstrap()` called from constructor in both notifiers. |
| Auto-refresh every 30s if any item non-terminal | ✓ | Pauses when drained, re-arms when `refresh()` brings in non-terminal records. |
| Manual `refresh()` method | ✓ | Both notifiers expose it. |
| `activeBridgeOperationsProvider` — derived | ✓ (family deviation, see below) | Implemented as `Provider.family<..., String /*ownerAddress*/>` rather than a global parameterless provider. Pragmatic — see Deviation 2. |
| `fvm dart analyze` clean | ✓ | Confirmed: `No issues found!` over `lib/features/bridge/`. |

---

## Team-Lead's Stated Deviations — Validation

### Deviation 1 — `BridgePreflightArgs` hand-rolled key class (vs. Dart record)
**Verdict: SOUND.** Confirmed `pubspec.yaml`: `sdk: ">=2.17.3 <3.0.0"` — records (introduced in Dart 3.0) are unavailable.

`==` correctness:
```dart
bool operator ==(Object other) =>
    identical(this, other) ||
    (other is BridgePreflightArgs &&
        other.ownerAddress == ownerAddress &&
        other.scUid == scUid);
```
- ✓ identity short-circuit
- ✓ type check
- ✓ both fields compared
- ✓ no missing fields (the class has exactly two)

`hashCode` correctness:
```dart
int get hashCode => Object.hash(ownerAddress, scUid);
```
- ✓ uses both fields
- ✓ `Object.hash` is the canonical way to combine — equal instances will produce equal hashes (Riverpod's family cache relies on `Map<Key, ...>` equality)

Class is `@immutable`, fields are `final`, constructor is `const`. Riverpod family caching will dedupe correctly.

### Deviation 2 — `activeBridgeOperationsProvider` framing (minor framing mismatch — see notes)
**Implementation differs slightly from the team-lead's description.** Team-lead described it as "session-scoped, derives from current wallet's lock list", with concern about a watch on `sessionProvider.currentWallet?.address`. Actual implementation:

```dart
final activeBridgeOperationsProvider =
    Provider.family<List<BridgeLockRecord>, String>((ref, ownerAddress) {
  if (ownerAddress.isEmpty) return const [];
  final list = ref.watch(bridgeLockListProvider(ownerAddress));
  return list.where((r) => !r.isTerminal).toList(growable: false);
});
```

No `sessionProvider` watch — it's a **caller-scoped family keyed by `ownerAddress`**, with an empty-string guard that returns `const []` to cover the "no wallet" case. This is actually cleaner than coupling to session state: callers pass `currentWallet?.address ?? ''` and the provider does the right thing.

The plan's original wording ("derived `Provider<List<BridgeLockRecord>>` that surfaces non-terminal operations across all known lists") implied a global parameterless provider that magically knew about every owner. Riverpod families don't expose all instantiated keys, so the executor scoped it per-owner. **Verdict: SOUND**, but worth noting that:
1. Callers must remember to pass the active address.
2. The team-lead's framing in the task brief is slightly inaccurate — flag for future planning so the same description doesn't get reused.

---

## What I Checked Against Your Brief

### Polling stop condition uses `record.isTerminal` ✓
`bridgeOperationProvider`: `if (current?.isTerminal == true)` and `if (record?.isTerminal == true)`.
`bridgeLockListProvider`: `state.any((r) => !r.isTerminal)`.
Neither hardcodes statuses — `Expired` and any future terminal state added to the model are honored.

### `BridgeOperationNotifier` cancels timer on dispose ✓
```dart
@override
void dispose() {
  _pollingTimer?.cancel();
  _pollingTimer = null;
  super.dispose();
}
```
Same pattern in `BridgeLockListNotifier`. Both also guard with `if (!mounted) return;` inside async callbacks. Clean.

### Auto-refresh idles when no in-flight items ✓
`_maybeScheduleAutoRefresh` exits early if `!hasInFlight`, cancels existing timer. Re-arms via `refresh()` if a non-terminal record arrives.

One subtle behavior: **once all records reach terminal and the timer is cancelled, new bridges initiated externally (by another session/process) will not appear until someone calls `refresh()` manually.** Acceptable for desktop's single-wallet model; the dialog flow naturally calls `refresh()` after `initiateLock`. Worth confirming Phase 3 wires this up.

### `_isFetching` guard prevents re-entry ✓
Both notifiers check `if (_isFetching) return state;` (or `return null`). The flag is `try { ... } finally { _isFetching = false; }` — exception-safe.

### Test constants via `@visibleForTesting` ✓
- `kBridgeOperationPollInterval = Duration(seconds: 5)`
- `kBridgeListRefreshInterval = Duration(seconds: 30)`
Both annotated; production code uses the constants directly inside the file.

### Patterns consistent with project conventions ✓
- StateNotifier subclass with constructor-driven bootstrap → matches `TransactionListProvider`.
- Family-keyed via `.family<Notifier, State, KeyType>` → standard Riverpod pattern.
- `final foo = StateNotifierProvider.family<...>((ref, key) => Notifier(key))` → conventional declaration.
- `debugPrint` with consistent `_tag` prefix → matches `VbtcBridgeService` / `VbtcV2Service`.

### No memory leaks ✓
Both `Timer.periodic` instances are nullable, set via `??=`, cancelled in `dispose` and on stop-conditions. Service instances are constructed per-call (`VbtcBridgeService()`) — stateless wrapper, no leak. No global subscriptions, no untracked listeners.

### List sorted newest-first by `createdAtUtc` ✓
`(a, b) => b.createdAtUtc.compareTo(a.createdAtUtc)` — descending order. Phase 5's history view can render without extra ordering logic.

---

## Bonus Finding — Phase 1 Risk Already Fixed

The Phase 1 verification flagged that `GetBridgeLocksByOwner` would emit `Status` as integer (no global `StringEnumConverter`), causing `_$BridgeLockRecordFromJson` to throw on cast and silently drop every history entry.

**Resolved in this phase.** `bridge_lock_record.dart` now has:
```dart
const List<String> _bridgeLockStatusWireNames = [
  'Locked', 'ProofSubmitted', 'Minted', 'Redeeming', 'Redeemed',
  'Unlocked', 'Failed', 'AttestationPending', 'AttestationReady',
  'MintedOnBase', 'ExitBurned', 'UnlockedOnVFX', 'BTCExitBurned',
  'BTCExitSigning', 'BTCExitBroadcast', 'BTCExitComplete', 'Expired',
];
```
…and `fromUnifiedJson` normalizes integer status values back to the wire-name string before passing to `fromJson`:
```dart
final rawStatus = pick(['status', 'Status']);
final normalizedStatus = rawStatus is int
    ? (rawStatus >= 0 && rawStatus < _bridgeLockStatusWireNames.length
        ? _bridgeLockStatusWireNames[rawStatus]
        : null)
    : rawStatus;
```
Names match the CLI's C# enum order exactly. Out-of-range ints fall through to `null`, which the freezed model already handles (`statusRaw = null` → `BridgeLockStatus.unknown`). Forward-compatible.

This is a Phase-1 fix that landed inside the Phase 2 commit window — slight scope creep but the right thing to do, and it unblocks Phase 5.

---

## Minor Observations (non-blocking)

1. **`bridgeOperationProvider` is NOT `.autoDispose`.** Once `ref.watch(bridgeOperationProvider(lockId))` is called, the notifier lives for the app's lifetime. The internal timer self-cancels at terminal status, so quiescent cost is zero — but if Phase 5's history view eagerly watches `bridgeOperationProvider` for every row, you'll create one persistent notifier per lock. Recommend Phase 5 only watch `bridgeOperationProvider` for the *currently-open* progress dialog (not row-by-row in the list); the list itself has all the data via `bridgeLockListProvider`.

2. **`debugPrint` once per fetch.** Reasonable noise level; could be elevated to `kIsWeb`-only or removed once feature is stable. Matches existing patterns.

3. **No `refreshOnce()` short-circuit for "already terminal":** If the dialog opens on a `lockId` that's already terminal (e.g., reopened from history), `_bootstrap` does one fetch and `_maybeStartPolling` immediately bails. Net effect: one extra HTTP call to the CLI. Negligible.

4. **`bridgeLockListProvider` initial load is async with empty state at `t=0`.** UI rendering off the provider before `_bootstrap` completes will see `[]`. Phase 5 needs to distinguish "loading" from "empty" — consider wrapping state in `AsyncValue` or adding a `bool isLoading` flag if the spec calls for distinct loading vs empty visuals.

---

## Quality Summary

| Dimension | Result |
|---|---|
| Works against plan? | ✓ all 4 providers implemented |
| Polling lifecycle? | ✓ timer cancelled on dispose, on terminal, on `!mounted` |
| Re-entry safe? | ✓ `_isFetching` guards both notifiers |
| Patterns match codebase? | ✓ aligned with `TransactionListProvider` and existing patterns |
| Memory safety? | ✓ no leaks |
| Test affordances? | ✓ `@visibleForTesting` on intervals |
| Lint? | ✓ `No issues found!` |

---

## Verdict

**PASS**

All 4 providers implemented with correct lifecycle management (timer cancellation, mounted guards, re-entry protection). Both team-lead-flagged deviations are sound. The Phase 1 enum-int risk was proactively fixed in this phase — Phase 5 history will not silently drop entries.

Two notes worth carrying forward:

1. **Framing nit:** `activeBridgeOperationsProvider` is a **family keyed by owner address** (not session-scoped). Empty-string guard covers the no-wallet case. Cleaner than coupling to `sessionProvider` — update planning notes for future phases.

2. **Phase 5 design hint:** Don't eagerly watch `bridgeOperationProvider(lockId)` per history row — it spawns a persistent notifier + 5s timer per row. Use it only for the currently-open progress dialog; the list itself already has all the data via `bridgeLockListProvider`.

Cleared to commit.
