# Phase 4: Dashboard UI — vBTC Balance Display — Verification Report

**Verdict**: PASS WITH WARNINGS
**Date**: 2026-04-13

## Checklist
- [x] vBTC balance section below VFX `_BalanceCard`
  - [x] Queries `tokenizedBitcoinListProvider` for user's vBTC tokens
  - [x] Shows `VbtcBalanceCard` per token with token name, shielded balance, note count
  - [x] Section hidden when no vBTC tokens exist (`tokens.isNotEmpty` guard)
- [x] vBTC balance polling starts when dashboard mounts
- [x] Polling stops on unmount (`stopAll()` in `dispose`)
- [x] VFX layout unchanged (primary/hero balance)
- [x] "Shielded vBTC" section header with BTC orange color
- [x] Each vBTC token card has action buttons (shield/unshield/transfer/consolidate)
- [x] BTC orange color accent used to distinguish from VFX blue

## Files Reviewed
- `lib/features/privacy/components/privacy_dashboard.dart` (modified)
- `lib/features/privacy/components/vbtc_balance_card.dart` (new)

## Findings

### privacy_dashboard.dart — Changes

**New state**: `_activeVbtcContractUids` tracks which contracts are polling (line 38).

**`_startVbtcPolling()`** (line 52): Reads `tokenizedBitcoinListProvider`, iterates tokens, calls `manager.start(zfxAddress, uid)` for each. Correct.

**`dispose()`** (line 48): Calls `shieldedVbtcBalanceProvider.notifier.stopAll()`. Correct cleanup.

**vBTC section in `build()`** (lines 103-126):
- Guarded by `tokens.isNotEmpty` — hidden when no vBTC tokens
- "Shielded vBTC" header with `AppColors.getBtc()` orange
- Maps each token to `VbtcBalanceCard` with 4 action callbacks
- Unshield/Transfer/Consolidate wrapped in `_requireUnlock()` — correct (spend ops need password)
- Shield NOT wrapped in `_requireUnlock()` — correct (T->Z doesn't need password)

**Placeholder action methods** (lines 134-148): Toast messages for Phase 5 dialog integration. Appropriate interim approach.

**VFX layout**: `_BalanceCard`, `_ActionButtons`, `_AddressCard`, `_UnlockBanner` all unchanged.

### vbtc_balance_card.dart — New File

**Widget structure**: `ConsumerStatefulWidget` with `initState`/`dispose` lifecycle — matches existing patterns.

**Balance display**:
- Token name in BTC orange (`AppColors.getBtc()`) — line 82
- Contract UID in monospace below — line 89
- `balance.unspentSum` with "vBTC" label — line 104
- Loading spinner when balance is null — line 98
- Note count with proper pluralization — line 119
- Last scanned block info — line 127

**Action buttons**: 4 buttons (Shield/Unshield/Transfer/Consolidate) using `AppButton` with appropriate variants (`AppColorVariant.Btc`, `.Warning`, `.Info`). All delegate to parent callbacks.

### Warnings

**Duplicate polling start**: Both `_PrivacyDashboardState._startVbtcPolling()` (line 52) and `_VbtcBalanceCardState.initState()` (line 36) call `shieldedVbtcBalanceProvider.notifier.start()` for the same contract UID. This means polling is initiated twice per contract. It is safe because `ShieldedVbtcBalanceManager.start()` cancels existing timers before creating new ones, but it results in a redundant initial fetch. Consider removing the polling start from either the dashboard or the card to avoid the double-fetch.

### Issues
None.

### Notes
- The `VbtcBalanceCard` also handles its own lifecycle (stop on dispose), providing good encapsulation — if a card is removed from the widget tree individually, its polling stops.
- Action placeholder methods are appropriate for Phase 4; Phase 5 will replace them with actual dialog calls.
- Import list in `privacy_dashboard.dart` is clean — only adds `tokenized_bitcoin_list_provider`, `shielded_vbtc_balance_provider`, and `vbtc_balance_card`.
