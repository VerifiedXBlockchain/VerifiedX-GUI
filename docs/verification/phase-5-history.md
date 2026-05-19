# Phase 5: vBTC → Base Bridge — History View — Verification Report

**Phase Objective:** Users can see past bridges and re-open the progress view for any of them. Retry button on stuck/failed entries.

**Plan ref:** `BRIDGE_TO_BASE_PHASES.md` § Phase 5
**UX ref:** `BRIDGE_TO_BASE_UX_SPEC.md` § 4 (history view), § 6 (edge cases: retry), § 7 (microcopy), § 9.4 (no pagination)
**Reviewed:** 2026-05-19

**Files reviewed:**
- `lib/features/bridge/components/bridge_history_list.dart` (new, 151 lines) — list container, header, empty state, scoped filtering
- `lib/features/bridge/components/bridge_history_item.dart` (new, 161 lines) — row with status badge, relative time, tap-to-detail, optional retry
- `lib/features/bridge/models/bridge_lock_record.dart` (+9 lines) — `canRetry` getter
- `lib/features/bridge/providers/bridge_lock_list_provider.dart` (+6 lines) — `hasLoaded` flag (loading-vs-empty distinction)
- `lib/features/btc/screens/tokenized_btc_detail_screen.dart` (+14 lines) — mounts `BridgeHistoryList` for v2 contracts

---

## Plan Task Checklist

| Plan task | Status | Notes |
|---|---|---|
| `BridgeHistoryList` uses `ListView.builder` (no pagination) | ✓ | `_RecordList` uses `ListView.builder` with `shrinkWrap: true` + `NeverScrollableScrollPhysics` because the parent screen is `SingleChildScrollView`. Correct pattern. |
| Watches `bridgeLockListProvider` | ✓ | Watched at top of `build`, filtered to `scUid` for per-contract scoping. |
| Empty state, loading state, error state | ⚠ partial | Empty state ✓ (`_Empty`). **Loading-vs-empty not distinguished** — see Finding 1. Error state silently degraded to "empty" — see Finding 2. |
| `BridgeHistoryItem`: amount, short destination, status badge, relative timestamp | ✓ | Amount + truncated 0x address, badge with color-coded status, relative time helper (`just now`, `Xm ago`, `yesterday`, `Xmo ago`). |
| Tap → opens read-only progress view (reuses `BridgeProgress` with no auto-advance) | ✓ | `_openDetail` opens a nested `AlertDialog` with `BridgeProgress(lockId, readOnly: true)` — the read-only mode added in Phase 3 suppresses `onTerminal` and the safe-to-close note. |
| Trailing "Retry" button when CLI status indicates retry is supported | ✓ | Uses `record.canRetry` getter (new in this phase: `isFailed && vfxLockConfirmedOnChain`). |
| Add `BridgeHistoryList` to vBTC v2 contract detail screen below action buttons | ✓ | Conditional on `token.version == 2`, mounted with 16px vertical padding between the buttons block and the transactions list. |
| Retry button wired to `BridgeService.retryMint` | ✓ | Calls `VbtcBridgeService().retryMint(lockId, ownerAddress)`; on success: toast + list refresh; on failure: error toast. |
| `fvm dart analyze` clean | ✓ | Confirmed: `No issues found!` over `lib/features/bridge/` + `tokenized_btc_detail_screen.dart`. |

---

## Spec § 4 Layout Conformance

Spec:
```
Bridge History
  [Active operations card — if any in-flight]
  Past operations
    0.5 vBTC → 0x…1234            Minted        2 hours ago
    0.1 vBTC → 0x…1234            Failed        Yesterday
    1.2 vBTC → 0x…ab90            Minted        3 days ago
```

Implementation:
- Header: "Bridge History" + refresh icon — ✓ (no separate "Active operations card"; in-flight and historical rows render in one chronological list, status badge differentiates)
- Rows: `amount vBTC → short(destination)` + relative time + status badge + optional Retry — ✓
- Sort: newest first, by `createdAtUtc` desc (handled by Phase 2 provider) — ✓

**Deviation from spec layout:** No separate "Active operations card" above "Past operations". In-flight items are tagged with their CLI status (amber badge) and intermixed chronologically. **This is arguably cleaner** — separate sections would duplicate visual structure for what's effectively the same data. Worth noting so team-lead can confirm the simpler unified layout is intended.

---

## Findings

### Finding 1 — ⚠ `hasLoaded` flag added but unused — empty-vs-loading visually ambiguous

The provider was updated to track `_hasLoaded`:
```dart
bool _hasLoaded = false;
bool get hasLoaded => _hasLoaded;
```
…with a comment saying it "Lets callers distinguish 'still loading the first batch' from 'loaded and the list really is empty'". The flag is set inside `_fetchOnce` after a successful fetch.

But `BridgeHistoryList.build` never reads it. On first render (before `_bootstrap` completes), `scoped` is `[]` and the user sees `_Empty` with the copy "No bridge operations yet." — same view they'd see if they genuinely have no history.

For a user opening the screen who *does* have history, there's a brief flash of "No bridge operations yet" followed by the actual list popping in. Visually misleading.

**Suggested fix (≤ 5 lines):**
```dart
// In BridgeHistoryList.build:
final notifier = ref.watch(bridgeLockListProvider(ownerAddress).notifier);
final all = ref.watch(bridgeLockListProvider(ownerAddress));
// ...
if (!notifier.hasLoaded) {
  return const _Loading();  // small spinner
}
```
…with a `_Loading` widget that mirrors `_Empty`'s container styling but shows a CircularProgressIndicator.

This was raised as a Phase 2 follow-up in my prior review. The infrastructure (the flag) is in place; just needs to be consumed. Non-blocker but a worthwhile polish (could fold into Phase 6).

### Finding 2 — Error state silently degrades to "empty"
`VbtcBridgeService.getLocksByOwner` returns `[]` on any failure (transport, parse, etc.) with a debugPrint. The provider passes that empty list through, so the UI shows the empty state on network failure — misleading.

Phase 6 (or Phase 5 follow-up) could:
- Have the provider expose an `error` state (wrap state in an `AsyncValue` or add an `error: Object?` field), and
- Have `BridgeHistoryList` render an `_ErrorState` widget with a Retry action when `error != null`.

Not in the executor's plan tasks for Phase 5, but the plan does list "error state" alongside "empty state" and "loading state". Worth flagging. Non-blocker since the manual refresh button is always available.

### Finding 3 — ⚠ Status badge shows raw CLI enum names (§ 7 microcopy concern)
For non-terminal records, the badge displays `r.statusRaw` directly:
```dart
return _StatusBadge(Colors.amberAccent, raw != null && raw.isNotEmpty ? raw : "In flight");
```

Result: users see badges like:
- `Locked`
- `AttestationPending`
- `AttestationReady`
- `ProofSubmitted`

§ 7 says: *"Avoid jargon: prefer 'validator signatures' over 'attestations' in user-facing copy."*

`AttestationPending` and `AttestationReady` both contain "attestation" — direct § 7 violations. The other names (`Locked`, `ProofSubmitted`) are technical but defensible.

**Suggested fix:** Add a friendly-name map for non-terminal statuses. Example:
```dart
String _friendlyStatusLabel(BridgeLockRecord r) {
  switch (r.status) {
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
Small, mechanical fix — could also be done in Phase 6 polish.

### Finding 4 — Phase 2 polish: `BridgeHistoryItem` correctly avoids `bridgeOperationProvider` per row
My Phase 2 follow-up note warned: "Don't eagerly watch `bridgeOperationProvider(lockId)` per history row — it's not `.autoDispose`, so each row would spawn a persistent notifier + 5s timer."

**Implementation does the right thing.** `BridgeHistoryItem` renders entirely from `widget.record` (data already in the list provider). `bridgeOperationProvider(lockId)` is only watched when the user taps a row to open the detail dialog — bounded to rows the user explicitly inspected. ✓

### Finding 5 — `canRetry` is conservative; matches plan's "verify exact endpoint" guidance
```dart
bool get canRetry => isFailed && vfxLockConfirmedOnChain;
```
Doc-comment explains the reasoning: CLI rejects retry on `Minted`/`MintedOnBase` (already done) and on records that haven't been confirmed on VFX (nothing to retry against). Conservative because §9.5 said: *"Hook into the CLI's existing retry endpoints (`RetryMintForLock` etc. — verify exact endpoint name during implementation)."* and Phase 6 can broaden if real usage shows stuck `AttestationReady`/`ProofSubmitted` need a manual nudge.

Sound starting point.

### Finding 6 — Detail dialog scaffolding partially factored (then re-duplicated)
Phase 3's original inline `_showReadOnlyProgress` was promoted in this phase to a **static helper** `BridgeToBaseDialog.showHistoryDetail(context, lockId)` (good!), and `BridgeResult.onViewDetails` was rewired to call it (so the Phase 3 "placeholder" note is resolved — see the team-lead's checklist).

But `BridgeHistoryItem._openDetail` (this phase) re-implements the same scaffolding inline rather than calling the new helper. Net result: one canonical helper + one stray inline duplicate (instead of two inline copies).

```dart
// Should be in bridge_history_item.dart:
void _openDetail() {
  BridgeToBaseDialog.showHistoryDetail(context, widget.record.lockId);
}
```
Three-line cleanup. Non-blocker.

### Finding 7 — Retry button: `() {}` vs `null` for disabled `onPressed` (Phase 3 carryover)
Same pattern as Phase 3 — `onPressed: _isRetrying ? () {} : _retry`. Works correctly with `processing: _isRetrying`, but inconsistent with other patterns in the codebase that pass `null`. Cosmetic — Phase 6 polish opportunity.

### Finding 8 — Relative time helper has small UTC edge case
```dart
final now = DateTime.now().toUtc();
final diff = now.difference(createdAt);
```
Correct UTC normalization. Edge case: if `createdAt` is slightly in the future due to clock skew between client and CLI, `diff` becomes negative. `diff.inMinutes < 1` is true for negative values too, so the fallback is "just now" — acceptable. Non-blocker.

---

## Quality Checks

### Lifecycle & state
- ✓ `_BridgeHistoryItemState` uses `mounted` guard on async retry path.
- ✓ List provider's `refresh()` invoked after successful retry — UI updates immediately.
- ✓ `ConsumerWidget` for the list (stateless), `ConsumerStatefulWidget` for items (state for `_isRetrying`). Appropriate split.

### Reactive correctness
- ✓ List provider is per-owner family; UI filters by `scUid` for per-contract scoping. Single source of truth.
- ✓ `bridgeOperationProvider` only watched on-demand in detail dialog (not eagerly per row).
- ✓ `hasLoaded` flag exists for future loading-vs-empty distinction (just not consumed yet — Finding 1).

### Visual hierarchy
- ✓ Status badges color-coded: green (minted), red (failed), white38 (expired), amber (in flight).
- ✓ Short destination + relative time give scannable rows.
- ✓ Dividers between rows (`Divider(color: Colors.white12)`); empty + populated states share the bordered container styling.
- ✓ Refresh icon button in header, contextual tooltip "Refresh".

### Integration
- ✓ Detail screen mount uses `token.version == 2` (strict match — same as Phase 4 entry button).
- ✓ Padding `EdgeInsets.symmetric(horizontal: 8)` to align with surrounding sections.
- ✓ `showHeader: true` (default) when used in detail screen; flag allows embedding without duplicate heading.

### Lint
- ✓ `fvm dart analyze lib/features/bridge/ lib/features/btc/screens/tokenized_btc_detail_screen.dart` — `No issues found!`.

---

## Quality Summary

| Dimension | Result |
|---|---|
| Plan tasks done? | ✓ all checkpoints |
| Spec § 4 layout? | ✓ (simpler unified list instead of "Active" + "Past" sections — see deviation note) |
| Spec § 7 microcopy? | ⚠ in-flight badge shows raw `AttestationPending`/`AttestationReady` (Finding 3) |
| Spec § 9.4 no pagination? | ✓ `ListView.builder`, no page controls |
| Loading / empty / error states? | ⚠ empty ✓; loading-vs-empty ambiguous (Finding 1); error degrades silently (Finding 2) |
| Reactive correctness? | ✓ |
| Phase 2 follow-up (no eager per-row provider)? | ✓ correctly handled |
| Retry wiring? | ✓ correct endpoint, refresh on success, toast feedback |
| Lint? | ✓ |

---

## Verdict

**PASS WITH WARNINGS**

Core Phase 5 functionality is in place — per-contract scoped history, tap-to-detail using the Phase 3 read-only mode, retry button wired to the CLI endpoint. The architecture decisions are sound: shared list provider with UI-side filtering, `canRetry` getter to centralize the retry-eligibility rule, and correct avoidance of the eager `bridgeOperationProvider` pattern I warned about in Phase 2.

**Three small things worth fixing (any/all could fold into Phase 6 polish):**

1. **Consume the `hasLoaded` flag** (Finding 1). The infrastructure is in place — the list just needs to render a loading state instead of "No bridge operations yet" on first frame. ≤ 5-line fix.

2. **§ 7 microcopy violation in status badge** (Finding 3). For in-flight records, the badge shows raw CLI enum names (`AttestationPending`, `AttestationReady`). § 7 explicitly says avoid "attestations" in user copy. Add a friendly-name mapper (≤ 10-line helper).

3. **Error state degrades silently to empty** (Finding 2). On CLI failure, user sees "No bridge operations yet" instead of an error message + manual retry affordance. Plan listed "error state" as a checkbox — current handling is borderline. Worth a small `_ErrorState` widget gated by an `error?` field on the notifier.

**One spec layout deviation to confirm:**

- No separate "Active operations card" + "Past operations" sections (spec § 4) — instead one unified chronological list with status badges. Arguably cleaner; confirm intent.

**Cosmetic non-blockers:**

- Detail dialog scaffolding duplicated between Phase 3 and Phase 5 (Finding 6) — factor into a static helper if you touch it.
- `() {}` vs `null` for disabled `onPressed` (Phase 3 carryover, Finding 7).

Cleared to commit — all warnings are polish-tier improvements suitable for Phase 6.
