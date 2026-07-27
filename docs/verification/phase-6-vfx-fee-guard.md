# Phase 6: VFX Fee Guard Dialog — Verification Report

**Verdict**: PASS
**Date**: 2026-04-13

## Checklist
- [x] Create `VfxFeeGuard` utility with static `check(WidgetRef ref)` method
  - [x] Reads `shieldedBalanceProvider.vfxBalance`
  - [x] Returns `true` if balance >= `PRIVACY_TX_FIXED_FEE`
  - [x] Shows info dialog if insufficient:
    - [x] Title: "Shielded VFX Required"
    - [x] Body: mentions current balance, fee requirement, instruction to shield
    - [x] Action button: "Shield VFX" -> opens `ShieldDialog`
    - [x] Cancel button: dismiss
  - [x] Returns `false` when insufficient
- [x] Integrated into all vBTC spend dialogs (unshield, transfer, consolidate) — called before opening

## Files Reviewed
- `lib/features/privacy/utils/vfx_fee_guard.dart` (new)
- `lib/features/privacy/components/privacy_dashboard.dart` (modified — integration)

## Findings

### VfxFeeGuard Implementation

**Signature**: `static Future<bool> check(WidgetRef ref)` — plan specifies `bool` return but `Future<bool>` is the correct adaptation since `showDialog` is async. The static method pattern matches the plan.

**Balance check** (line 13): `ref.read(shieldedBalanceProvider)?.vfxBalance ?? 0.0` — reads VFX shielded balance. Falls back to 0.0 if null (no balance data yet). Checks `>= PRIVACY_TX_FIXED_FEE`.

**Dialog content** (lines 16-49):
- Title: "Shielded VFX Required" — exact match
- Body includes: current balance (`$vfxBalance`), fee requirement (`$PRIVACY_TX_FIXED_FEE_LABEL`), instruction to shield first
- "Shield VFX" button: pops dialog, then calls `ShieldDialog.show()` — correct (pop first so two dialogs don't stack)
- "Cancel" button: pops dialog — correct
- Returns `false` after dialog dismissed — correct

**Imports**: Clean — `app.dart` (for `rootNavigatorKey`), `app_constants.dart`, `shielded_balance_provider`, `shield_dialog.dart`.

### Dashboard Integration

**Diff**: Lines 102-110 in current `privacy_dashboard.dart` — all 3 vBTC spend callbacks now call `VfxFeeGuard.check(ref)` before opening the dialog:
```dart
onUnshield: () => _requireUnlock(() async {
  if (await VfxFeeGuard.check(ref)) UnshieldVbtcDialog.show(token);
}),
onTransfer: () => _requireUnlock(() async {
  if (await VfxFeeGuard.check(ref)) PrivateTransferVbtcDialog.show(token);
}),
onConsolidate: () => _requireUnlock(() async {
  if (await VfxFeeGuard.check(ref)) ConsolidateVbtcDialog.show(token);
}),
```

**Execution order**: `_requireUnlock` (password) -> `VfxFeeGuard.check` (fee check) -> dialog. This is the correct order — verify identity first, then check funds.

**Shield NOT guarded** — correct, T->Z shielding doesn't require VFX fees.

**Import added**: `import '../utils/vfx_fee_guard.dart'` — correct.

### Defense in Depth
The VFX fee check now exists at two levels:
1. **UI level** (Phase 6): `VfxFeeGuard.check()` shows informative dialog before the action dialog opens
2. **Provider level** (Phase 3): `_hasVfxFeeBalance()` in `VbtcPrivacyActionsNotifier` returns false with error toast if fee is insufficient

This is good defense-in-depth — the UI guard provides a better UX (explains the issue + offers to shield VFX), while the provider guard is a safety net.

### Issues
None.

### Warnings
None.

### Notes
- The fee guard file is placed in `lib/features/privacy/utils/` as specified in the plan.
- The dialog uses `ConstrainedBox(maxWidth: 400)` consistent with all other dialogs in this feature.
