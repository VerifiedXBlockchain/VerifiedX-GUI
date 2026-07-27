# Phase 5: Action Dialogs — vBTC Shield, Unshield, Transfer, Consolidate — Verification Report

**Verdict**: PASS
**Date**: 2026-04-13

## Checklist
- [x] `ShieldVbtcDialog` — mirrors `ShieldDialog`
  - [x] Contract UID field (pre-filled, read-only)
  - [x] Amount field labeled "Amount (vBTC)"
  - [x] Min amount: `MIN_SHIELD_AMOUNT_VBTC`
  - [x] Description: "Move vBTC from your transparent wallet into the shielded pool."
  - [x] No password needed
- [x] `UnshieldVbtcDialog` — mirrors `UnshieldDialog`
  - [x] Contract UID (read-only)
  - [x] To Address field (transparent VFX address)
  - [x] Amount field labeled "Amount (vBTC)"
  - [x] Fee info with `PRIVACY_TX_FIXED_FEE_LABEL`
- [x] `PrivateTransferVbtcDialog` — mirrors `PrivateTransferDialog`
  - [x] Contract UID (read-only)
  - [x] Recipient zfx_ address field with validation
  - [x] Amount field labeled "Amount (vBTC)"
  - [x] Fee info present
- [x] `ConsolidateVbtcDialog` — mirrors `ConsolidateDialog`
  - [x] Contract UID (read-only)
  - [x] Shows current note count
  - [x] Requires >= 2 notes
  - [x] Fee info present
- [x] All dialogs use `ConsumerStatefulWidget` + `static show()` pattern
- [x] Dashboard wired to actual dialog calls (placeholders removed)

## Files Reviewed
- `lib/features/privacy/components/shield_vbtc_dialog.dart` (new)
- `lib/features/privacy/components/unshield_vbtc_dialog.dart` (new)
- `lib/features/privacy/components/private_transfer_vbtc_dialog.dart` (new)
- `lib/features/privacy/components/consolidate_vbtc_dialog.dart` (new)
- `lib/features/privacy/components/privacy_dashboard.dart` (modified — dialog integration)
- `lib/features/privacy/components/shield_dialog.dart` (existing, for comparison)

## Findings

### Dialog-by-Dialog Review

#### ShieldVbtcDialog
- **Pattern**: `ConsumerStatefulWidget` + `static show(TokenizedBitcoin token)` — matches VFX `ShieldDialog` exactly
- **Contract UID**: Displayed as read-only text (token name + UID in monospace) — lines 91-98
- **Amount**: "Amount (vBTC)" label, min check `MIN_SHIELD_AMOUNT_VBTC` — lines 47, 109
- **Description**: Exact match: "Move vBTC from your transparent wallet into the shielded pool." — line 86
- **No password**: Calls `vbtcPrivacyActionsProvider.notifier.shieldVbtc()` which doesn't require password — correct
- **Submit**: Validates wallet, amount, zfxAddress. Calls provider. Pops on success. Matches VFX pattern.

#### UnshieldVbtcDialog
- **To Address**: TextField with "To Address (transparent)" label — line 101
- **Amount**: "Amount (vBTC)" label — line 112
- **Fee info**: "A fee of $PRIVACY_TX_FIXED_FEE_LABEL will be deducted from your shielded VFX balance." — line 119
- **Contract UID**: Read-only display — lines 89-96
- **VFX fee guard**: Handled at provider level (`_hasVfxFeeBalance()` in `VbtcPrivacyActionsNotifier.unshieldVbtc`). The dialog itself does not pre-check — Phase 6 will add the pre-show guard.

#### PrivateTransferVbtcDialog
- **Recipient**: zfx_ address field with robust validation — `_isValidZfxAddress()` checks prefix + base58 alphabet + min length — lines 15-20
- **Amount**: "Amount (vBTC)" label — line 123
- **Fee info**: Same fee message — line 130
- **Contract UID**: Read-only display — lines 100-107

#### ConsolidateVbtcDialog
- **Note count**: Reads from `shieldedVbtcBalanceProvider` per-contract — lines 53-55
- **>= 2 notes guard**: `canConsolidate = noteCount >= 2` disables button — line 106
- **Warning text**: Shows "At least 2 unspent notes are required" when insufficient — lines 90-96
- **Fee info**: "Fee: $PRIVACY_TX_FIXED_FEE_LABEL (deducted from shielded VFX balance)" — line 87

### Dashboard Integration (Phase 5 additions)
The dashboard was updated alongside the dialogs:
- Placeholder Toast methods removed
- Actual dialog `show()` calls wired: `ShieldVbtcDialog.show(token)`, `UnshieldVbtcDialog.show(token)`, etc.
- Token filtering added: `allTokens.where((t) => t.version == 2)` — correct filter for v2 vBTC tokens
- `BaseComponent` replaced with `ConsumerStatefulWidget` for stateful lifecycle
- Phase 4's duplicate polling issue resolved — `_startVbtcPolling`/`stopAll` removed; `VbtcBalanceCard` handles its own lifecycle

### Pattern Consistency with VFX Dialogs

| Aspect | VFX Dialogs | vBTC Dialogs | Match |
|---|---|---|---|
| Widget type | `ConsumerStatefulWidget` | `ConsumerStatefulWidget` | Yes |
| Show pattern | `static show()` | `static show(token)` | Yes (+ token param) |
| Submit flow | validate -> setState loading -> call provider -> pop on success | Same | Yes |
| Error handling | `Toast.error()` | `Toast.error()` | Yes |
| Loading state | `_isSubmitting` bool | `_isSubmitting` bool | Yes |
| Controller disposal | `dispose()` | `dispose()` | Yes |

### Issues
None.

### Warnings
None.

### Notes
- The VFX fee guard is currently only at the provider level (toast on error). The plan specifies a pre-show dialog guard — this is Phase 6's responsibility (`VfxFeeGuard.check()`). The current implementation is functional but the UX will improve in Phase 6.
- `PrivateTransferVbtcDialog` includes its own `_isValidZfxAddress` helper with base58 validation. This is a slightly more thorough validation than the VFX `PrivateTransferDialog` might have — good defensive coding.
- The `version == 2` filter on the dashboard is a smart addition not in the original plan, ensuring only v2 vBTC contracts (which support shielding) are shown.
