# Phase 2: Models & Constants — Verification Report

**Verdict**: PASS
**Date**: 2026-04-13

## Checklist
- [x] Add `MIN_SHIELD_AMOUNT_VBTC = 0.00001` to `app_constants.dart`
- [x] Create `ShieldedVbtcBalance` model (or reuse `ShieldedBalance` if response shape matches)
- [x] Add helper getter/method to `ShieldedBalance` for vBTC balance lookup
- [x] Run codegen if new freezed models are added (not needed — no freezed field changes)

## Findings

### Task 1: Constant added correctly
`MIN_SHIELD_AMOUNT_VBTC = 0.00001` added at `app_constants.dart:43`, immediately after `MIN_SHIELD_AMOUNT_VFX`. Value matches plan specification exactly.

### Task 2: Model reuse decision — correct
No new `ShieldedVbtcBalance` model was created. The plan explicitly allowed reuse: "or reuse `ShieldedBalance` if response shape matches". Since `getShieldedVbtcBalance` in Phase 1 already returns `ShieldedBalance?` and parses the response with `ShieldedBalance.fromJson`, the response shape is compatible. This is the right call — avoids unnecessary model duplication.

### Task 3: Helper method — pragmatic adaptation
Plan specified: "helper getter to extract vBTC balances from the `shieldedBalances` map (entries where key starts with `"VBTC:"`)".

Implementation added:
```dart
double vbtcBalance(String contractUid) {
  return shieldedBalances[contractUid] ?? 0.0;
}
```

This is a method (not a getter) that takes a contract UID and does a direct map lookup. This deviates from the plan's suggestion of filtering by `"VBTC:"` prefix, but is arguably better design: the API returns balance per-contract (one API call per vBTC token), so each `ShieldedBalance` instance will contain a single contract's balance. A filter-based approach would be useful if one response returned all vBTC balances, but that's not how the API works. The method signature aligns perfectly with Phase 3's provider design (which will call per-contract).

### Task 4: Codegen — not needed
Only a hand-written method was added to `ShieldedBalance` (in the `const ShieldedBalance._()` custom class section). No freezed fields were added or modified, so no codegen run was required. The existing `.freezed.dart` and `.g.dart` files remain valid.

### Issues
None.

### Warnings
None.

### Notes
- Both changed files (`app_constants.dart`, `shielded_balance.dart`) had minimal, focused diffs — no unrelated changes.
