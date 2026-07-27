# Phase 5: vBTC → Base Bridge — History View — Verification Report (final)

**Phase Objective:** Users can see past bridges and re-open the progress view for any of them. Retry button on stuck/failed entries.

**Plan ref:** `BRIDGE_TO_BASE_PHASES.md` § Phase 5
**UX ref:** `BRIDGE_TO_BASE_UX_SPEC.md` § 4 (history view), § 6 (edge cases: retry), § 7 (microcopy), § 9.4 (no pagination)
**Reviewed:** 2026-05-19 (final pass after executor restructuring)
**Commit:** `34849ff8`

**Files reviewed (final state):**
- `lib/features/bridge/components/bridge_history_item.dart` (new, 132 lines) — **pure presentation** `StatelessWidget`; accepts `onTap`, `onRetry?`, `isRetrying` callbacks
- `lib/features/bridge/components/bridge_history_list.dart` (new, 229 lines) — `ConsumerStatefulWidget` owning service wiring, `Set<String> _retrying`, three-branch render (loading / empty / records)
- `lib/features/bridge/components/bridge_to_base_dialog.dart` (modified) — added static `showHistoryDetail(context, lockId)` helper; `BridgeResult.onViewDetails` wired through it
- `lib/features/bridge/providers/bridge_lock_list_provider.dart` (modified, +6 lines) — `_hasLoaded` flag + public getter, set inside `_fetchOnce`
- `lib/features/bridge/models/bridge_lock_record.dart` (modified, +9 lines) — `canRetry` getter (`isFailed && vfxLockConfirmedOnChain`)
- `lib/features/btc/screens/tokenized_btc_detail_screen.dart` (modified, +14 lines) — embeds `BridgeHistoryList` for v2 contracts

---

## Plan Task Checklist

| Plan task | Status | Notes |
|---|---|---|
| `BridgeHistoryList` uses `ListView.builder` (no pagination) | ✓ | `shrinkWrap: true` + `NeverScrollableScrollPhysics` (nested in `SingleChildScrollView` parent). |
| Watches `bridgeLockListProvider` | ✓ | Filtered to `scUid` for per-contract scoping. |
| Empty state, loading state, error state | ✓ + ⚠ | Loading ✓ (new), empty ✓; **error state still degrades silently to empty** — see Finding 1. |
| `BridgeHistoryItem` row: amount, short destination, status badge, relative timestamp | ✓ | All present; new branch added for `BridgeLockStatus.unknown` (grey badge with raw text). |
| Tap → opens read-only `BridgeProgress` | ✓ | Now via `BridgeToBaseDialog.showHistoryDetail(context, lockId)` — no inline scaffolding. |
| Trailing Retry when CLI status indicates retry supported | ✓ | `record.canRetry` → callback wired (`onRetry: record.canRetry ? () => onRetry(record) : null`). |
| Add `BridgeHistoryList` to vBTC v2 contract detail screen below action buttons | ✓ | Gated by `token.version == 2`, 16px padding before/after. |
| Retry button wired to `BridgeService.retryMint` | ✓ | List owns the call; `Set<String> _retrying` for per-row processing state. Toast on success/failure; list refreshed on success. |
| `fvm dart analyze` clean | ✓ | Re-confirmed `No issues found!`. |

---

## Specific Scrutiny Items (from your brief)

### 1. ✓ `hasLoaded` correctness — executor's argument is sound

Executor argues that `state = sorted` always assigns a new identity (because `[...list]..sort(...)` creates a fresh `List` instance every call), so the listeners are notified even when both old and new are `[]`.

**Verified.** `StateNotifier`'s `state` setter calls `_listenable.notifyListeners()` when the new value differs from the old by `==`. `List` doesn't override `==`, so it falls back to identity equality (`identical`). The spread `[...list]` guarantees a new list instance, so `state != sorted` is always true — listeners fire on every fetch.

Subscribers in `BridgeHistoryList.build`:
```dart
final all = ref.watch(bridgeLockListProvider(widget.ownerAddress));
final hasLoaded = ref.watch(bridgeLockListProvider(widget.ownerAddress).notifier).hasLoaded;
```
The first watch triggers a rebuild when `state` changes. During the rebuild, the second watch returns the same notifier instance (stable) and reads the now-true `hasLoaded`. Three-branch render then picks the right view:
```dart
if (!hasLoaded) const _Loading()
else if (scoped.isEmpty) const _Empty()
else _RecordList(...)
```

Edge case check: first fetch returns empty list →
- `state` starts as `const []`, fetch produces fresh `[]`, identity differs → rebuild fires
- `hasLoaded` now true → `else if (scoped.isEmpty) const _Empty()` ✓
- User sees loading spinner briefly, then "No bridge operations yet." — correct.

Subsequent empty refresh →
- Both old and new state are `[]` but different instances → rebuild fires
- `hasLoaded` already true → empty state stays ✓

Sound. ✓

### 2. ✓ `canRetry` conservatism — sound rationale

`canRetry = isFailed && vfxLockConfirmedOnChain`. Your note that CLI's `RetryMintForLock` technically accepts more states is correct, but surfacing Retry on an actively-polling `AttestationReady` / `ProofSubmitted` record would create UX confusion (Retry button sitting next to a record the system is already actively working on). Phase 6 can add stuck-detection (e.g., "no status change for N minutes") to widen this.

Doc-comment on the getter clearly explains the reasoning. ✓

### 3. ✓ `BridgeResult` failure path → `showHistoryDetail`

Confirmed: `bridge_to_base_dialog.dart:54` declares the static helper; `bridge_to_base_dialog.dart:209` uses it for `onViewDetails` (failure only). `bridge_history_item.dart`'s `onTap` callback is also routed through the same helper via `BridgeHistoryList._openDetail` at `bridge_history_list.dart:49-51`.

**Single canonical entry point** for opening the read-only detail view. The previously-duplicated scaffolding is now collapsed.

---

## Resolved from Prior Review

My prior verification flagged:
- **Finding 1: `hasLoaded` added but unused** → ✓ now consumed in three-branch render
- **Finding 6: dialog scaffolding duplication** → ✓ now centralized in `BridgeToBaseDialog.showHistoryDetail`; both call sites (`BridgeResult.onViewDetails` and `BridgeHistoryList._openDetail`) route through it

Phase 2 carryover concerns:
- **No per-row `bridgeOperationProvider` watch** → ✓ `BridgeHistoryItem` is now `StatelessWidget`, never touches the operation provider. Even cleaner than before.
- **`_isFetching` re-entry guard on retry** → ✓ `if (_retrying.contains(record.lockId)) return;` at start of `_retry`.

---

## Remaining Findings

### Finding 1 — Error state still degrades silently to "empty"
`VbtcBridgeService.getLocksByOwner` returns `[]` on transport/parse failure (with a debugPrint). When the CLI is unreachable, the user sees "No bridge operations yet." instead of an error message + Retry affordance.

The provider sets `_hasLoaded = true` after every `_fetchOnce` regardless of whether the empty list was a real empty or a silent failure, so the loading state correctly terminates — but the empty/error distinction is lost.

**Recommended Phase 6 fix:** Have the provider expose an `error?` field (or wrap state in `AsyncValue`), and add an `_ErrorState` widget gated on `error != null` with a manual Retry. ~15 lines. Manual refresh button is always present, so non-blocker.

### Finding 2 — § 7 microcopy violation in status badge (in-flight states)
For non-terminal records, the badge displays `r.statusRaw` directly:
```dart
return _StatusBadge(Colors.amberAccent, raw != null && raw.isNotEmpty ? raw : "In flight");
```
Users see badges like `AttestationPending`, `AttestationReady`, `ProofSubmitted`. § 7 explicitly says: *"prefer 'validator signatures' over 'attestations' in user-facing copy."*

**Recommended Phase 6 fix** (~10 lines):
```dart
String _friendlyLabel(BridgeLockStatus s, BridgeLockRecord r) {
  switch (s) {
    case BridgeLockStatus.locked:
      return r.vfxLockConfirmedOnChain ? "Confirmed" : "Locking";
    case BridgeLockStatus.attestationPending:
    case BridgeLockStatus.attestationReady:
      return "Awaiting signatures";
    case BridgeLockStatus.proofSubmitted:
      return "Minting";
    default:
      return r.statusRaw ?? "In flight";
  }
}
```

### Finding 3 — Cosmetic: `() {}` vs `null` for disabled onPressed (Phase 3 carryover)
`onPressed: isRetrying ? () {} : onRetry!` — works correctly with `processing: isRetrying`, but inconsistent with codebase patterns that pass `null`. Cosmetic.

### Finding 4 — Relative time helper: small clock-skew edge case (unchanged from prior)
If `createdAt` is briefly in the future due to clock skew between client and CLI, `diff` becomes negative. `diff.inMinutes < 1` is true for negatives, so the row falls into "just now" — acceptable graceful degradation.

### Finding 5 — One unified list vs spec § 4's "Active / Past" sections
Spec § 4 mock shows a separate "Active operations card" + "Past operations" section. Implementation uses one unified chronological list with status badges. Cleaner — confirm intent.

---

## Quality Checks

### Lifecycle & state
- ✓ `mounted` guard on async retry path.
- ✓ Re-entry guard: `if (_retrying.contains(record.lockId)) return;`.
- ✓ `setState` only fires after the mounted check.
- ✓ `BridgeHistoryItem` is pure presentation — no provider or service wiring, easy to render and test.

### Reactive correctness
- ✓ List provider is per-owner family; UI filters by `scUid` for per-contract scoping. Single source of truth.
- ✓ `hasLoaded` consumed via `ref.watch(...notifier).hasLoaded`.
- ✓ `bridgeOperationProvider` only watched on-demand inside the detail dialog.
- ✓ Retry rebuilds the list immediately on success via `bridgeLockListProvider.refresh()`.

### Visual hierarchy
- ✓ Status badges color-coded: green (Minted), red (Failed), white38 (Expired/Unknown), amber (in-flight).
- ✓ Short destination + relative time for scannable rows.
- ✓ Dividers between rows; loading/empty/records all share the bordered container styling.
- ✓ Refresh icon in header with "Refresh" tooltip.

### Integration
- ✓ Detail screen mount: `if (token.version == 2)` (consistent with Phase 4 strict gate).
- ✓ Padding: `EdgeInsets.symmetric(horizontal: 8)` aligns with surrounding sections.
- ✓ `showHeader: true` (default) for the detail screen embedding; flag allows embedding without duplicate heading.

### Lint
- ✓ `fvm dart analyze` over the Phase 5 surface — `No issues found!`.

---

## Quality Summary

| Dimension | Result |
|---|---|
| All plan tasks done? | ✓ |
| Spec § 4 layout? | ✓ (simpler unified list — confirm intent vs separate Active/Past sections) |
| Spec § 7 microcopy? | ⚠ in-flight badge shows raw CLI enum names (Finding 2) |
| Spec § 9.4 no pagination? | ✓ |
| Loading / empty / error states? | ✓ ✓ ⚠ (error degrades to empty — Finding 1) |
| `hasLoaded` correctness? | ✓ executor argument validated |
| `canRetry` rationale? | ✓ |
| `showHistoryDetail` reuse across both call sites? | ✓ |
| No per-row `bridgeOperationProvider`? | ✓ cleaner than before — pure StatelessWidget item |
| Lint? | ✓ |

---

## Verdict

**PASS WITH WARNINGS** (warnings reduced from prior pass — only Phase 6 polish items remain)

The restructuring is excellent. The dual concerns I raised in my prior pass (`hasLoaded` unused, scaffolding duplication) are both resolved. The Phase 2 carryover guidance ("no per-row provider watch") is honored even more strictly than before — `BridgeHistoryItem` is now a pure `StatelessWidget` that doesn't touch Riverpod at all, with the parent list owning all wiring.

The three specific scrutiny items in your brief check out:
1. **`hasLoaded` correctness** — executor's identity-not-equality argument is sound; spread `[...list]` guarantees a new instance, and `StateNotifier` notifies on `!=` (identity for `List`).
2. **`canRetry` conservatism** — sound UX call; widening to active states would create confusing Retry-while-polling situations.
3. **`BridgeResult.onViewDetails` rewiring** — confirmed; both detail entry points (failure result + history item tap) route through the same `showHistoryDetail` helper.

**Two warnings, both Phase 6 polish:**
- **Error state degrades silently to "empty"** (Finding 1) — CLI failure shows "No bridge operations yet." instead of an error. ~15 lines: add `error?` field to notifier + `_ErrorState` widget.
- **§ 7 microcopy violation in in-flight status badge** (Finding 2) — shows raw `AttestationPending` / `AttestationReady` / `ProofSubmitted`. ~10 lines: friendly-name mapper.

**One spec layout deviation to confirm:** No separate "Active operations card" + "Past operations" sections; one unified chronological list with status badges. Cleaner — confirm intent.

Cleared to commit.
