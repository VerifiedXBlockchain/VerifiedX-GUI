# Phase 7: Settings — vBTC Resync & Cleanup — Verification Report

**Verdict**: PASS
**Date**: 2026-04-13

## Checklist
- [x] Add "Resync vBTC Wallet" option to `PrivacySettingsMenu`
  - [x] Shows dialog to pick which vBTC contract to resync (when multiple tokens)
  - [x] Skips picker when only one token
  - [x] Calls `PrivacyService().resyncShieldedVbtc(zfxAddress, contractUid)`
  - [x] Same confirmation pattern as VFX resync

## Files Reviewed
- `lib/features/privacy/components/privacy_settings_menu.dart` (modified)

## Findings

### Menu Item
- New `PopupMenuItem` with value `'resync_vbtc'` added at lines 72-80
- Icon: `Icons.sync` with `AppColors.getBtc()` (BTC orange) — distinguishes from VFX resync (orange)
- Label: "Resync vBTC Wallet" in BTC orange text
- Placed between VFX "Resync Wallet" and "Reset Privacy Wallet" — logical ordering
- Switch case `'resync_vbtc'` at line 32 routes to `_resyncVbtcWallet(ref)`

### `_resyncVbtcWallet` Method (lines 195-283)

**Guard checks**:
- zfxAddress null check — matches VFX `_resyncWallet` pattern
- Token list check — reads `tokenizedBitcoinListProvider`, filters `version == 2`, shows "No vBTC tokens found" if empty

**Contract picker** (lines 213-261):
- Single token: skips picker, auto-selects — good UX optimization
- Multiple tokens: shows `AlertDialog` with `ListTile` per token showing name (BTC orange) and contract UID (monospace). Returns index on tap, null on cancel.
- Plan says "sub-menu or dialog to pick which vBTC contract" — dialog picker satisfies this

**Confirmation** (lines 263-269):
- `ConfirmDialog.show()` with:
  - Title: "Resync vBTC Wallet"
  - Body: includes selected token name, warns about wipe + rescan duration
  - `destructive: true` flag
  - Confirm/Cancel buttons
- Matches VFX `_resyncWallet` confirmation pattern exactly

**API call** (lines 273-276):
- `PrivacyService().resyncShieldedVbtc(zfxAddress: zfxAddress, vbtcContractUid: selectedUid)`
- Correct service method from Phase 1
- `fromHeight`/`toHeight` default to 0 (full resync) — matches VFX pattern

**Feedback toasts**: "vBTC resync started...", "vBTC resync complete", "vBTC resync failed" — matches VFX pattern.

### Pattern Comparison with VFX Resync

| Aspect | VFX `_resyncWallet` | vBTC `_resyncVbtcWallet` | Match |
|---|---|---|---|
| zfxAddress guard | Yes | Yes | Yes |
| Confirmation dialog | Yes (destructive) | Yes (destructive) | Yes |
| Service call | `resyncShieldedWallet()` | `resyncShieldedVbtc()` | Yes |
| Toast feedback | started/complete/failed | started/complete/failed | Yes |
| Contract picker | N/A (single VFX pool) | Dialog picker (multi-contract) | Correct adaptation |

### Import Correctness
- `tokenized_bitcoin_list_provider.dart` added at line 10 — needed for token list access
- All other existing imports unchanged

### Issues
None.

### Warnings
None.

### Notes
- The single-token auto-select optimization is a nice UX touch not explicitly in the plan but sensible for the common case where a user has only one vBTC token.
- Existing menu items and methods (export/import viewing key, VFX resync, reset wallet) are completely unchanged.
