# Phase 3: Providers — vBTC Balance & Actions — Verification Report

**Verdict**: PASS
**Date**: 2026-04-13

## Checklist
- [x] `ShieldedVbtcBalanceManager` — polls per-contract vBTC shielded balance
  - [x] Takes `zfxAddress` + `vbtcContractUid`
  - [x] 30-second polling interval (same as VFX)
  - [x] Fetches via `PrivacyService().getShieldedVbtcBalance()`
- [x] `VbtcPrivacyActionsNotifier` — mirrors `PrivacyActionsNotifier` for vBTC
  - [x] `shieldVbtc(...)` — no password needed (T->Z)
  - [x] `unshieldVbtc(...)` — requires password + checks shielded VFX fee balance
  - [x] `transferVbtc(...)` — requires password + checks shielded VFX fee balance
  - [x] `consolidateVbtc(...)` — requires password + checks shielded VFX fee balance
  - [x] Each spend method refreshes both vBTC and VFX shielded balances after success
- [x] VFX fee guard helper: `_hasVfxFeeBalance()` checks `shieldedBalanceProvider.vfxBalance >= PRIVACY_TX_FIXED_FEE`

## Files Reviewed
- `lib/features/privacy/providers/shielded_vbtc_balance_provider.dart` (new)
- `lib/features/privacy/providers/vbtc_privacy_actions_provider.dart` (new)
- `lib/features/privacy/providers/shielded_balance_provider.dart` (existing, for comparison)
- `lib/features/privacy/providers/privacy_actions_provider.dart` (existing, for comparison)

## Findings

### ShieldedVbtcBalanceManager — Pattern Comparison with ShieldedBalanceNotifier

| Aspect | VFX (ShieldedBalanceNotifier) | vBTC (ShieldedVbtcBalanceManager) | Correct |
|---|---|---|---|
| State type | `ShieldedBalance?` (single) | `Map<String, ShieldedBalance?>` (per-contract) | Yes — multi-contract |
| Timer | Single `Timer?` | `Map<String, Timer>` (per-contract) | Yes |
| Polling interval | 30 seconds | 30 seconds | Yes |
| `includeCommitments` | `true` | `true` | Yes |
| Fetch calls | `getShieldedBalance(zfxAddress)` | `getShieldedVbtcBalance(zfxAddress, contractUid)` | Yes |
| Cleanup | `stop()` clears all | `stop(contractUid)` per-contract + `stopAll()` | Yes — better granularity |
| dispose | Cancels timer | Cancels all timers | Yes |

### VbtcPrivacyActionsNotifier — Pattern Comparison with PrivacyActionsNotifier

| Aspect | VFX | vBTC | Correct |
|---|---|---|---|
| State type | `bool` (loading) | `bool` (loading) | Yes |
| Password access | `ref.read(shieldedAddressProvider.notifier).walletPassword` | Same | Yes |
| Shield — password | Not required | Not required | Yes |
| Spend ops — password | Required | Required | Yes |
| Spend ops — VFX fee check | N/A (VFX pays own fees) | `_hasVfxFeeBalance()` check before each | Yes |
| Post-success refresh (shield) | VFX balance only | vBTC balance only | Yes — correct since shield doesn't affect VFX |
| Post-success refresh (spend) | VFX balance only | Both vBTC + VFX via `Future.wait` | Yes — correct since fee deducted from VFX |
| Error handling | try/catch with Toast | try/catch with Toast | Yes |
| Loading state | `state = true` / `state = false` in finally | Same | Yes |

### VFX Fee Guard Implementation
`_hasVfxFeeBalance()` at line 21 reads `shieldedBalanceProvider` (VFX balance) and checks against `PRIVACY_TX_FIXED_FEE` from `app_constants.dart`. Applied to unshield, transfer, and consolidate — but not shield (correct, since T->Z shielding doesn't require VFX fees).

### Import Correctness
All imports verified:
- `app_constants.dart` — for `PRIVACY_TX_FIXED_FEE`
- `toast.dart` — for user notifications
- `privacy_service.dart` — for API calls
- `shielded_address_provider.dart` — for wallet password access
- `shielded_balance_provider.dart` — for VFX fee balance check + refresh
- `shielded_vbtc_balance_provider.dart` — for vBTC balance refresh

### Issues
None.

### Warnings
None.

### Notes
- The `ShieldedVbtcBalanceManager` uses `includeCommitments: true` by default, which means the UI will have commitment count data available for the consolidation dialog (Phase 5).
- The dual-refresh pattern in spend operations (`Future.wait` with both vBTC and VFX balance fetch) is a good design choice — ensures both balances update simultaneously after a fee-consuming operation.
