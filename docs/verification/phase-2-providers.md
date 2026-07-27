# Phase 2: Providers — Verification Report

**Phase Objective:** State management. Connects service layer to future UI. No UI yet.

**Reviewed:** 2026-03-24

---

## Plan Task Checklist

### `lib/features/privacy/providers/plonk_status_provider.dart`

- [x] `@Riverpod(keepAlive: true)` — fetches PLONK status once, caches it
- [x] Returns `PlonkStatus?` (null = not fetched yet, or node doesn't support)
- [x] Exposes `bool get isPrivacyEnabled` convenience getter
- [x] Generated `.g.dart` present with correct `NotifierProvider<PlonkStatusNotifier, PlonkStatus?>` type

### `lib/features/privacy/providers/shielded_address_provider.dart`

- [x] StateNotifier managing `ShieldedAddress?`
- [x] `generate()` — calls service, stores result
- [x] `load()` — calls `generateShieldedAddress()` to detect existing address
- [x] Kicks off balance polling via `shieldedBalanceProvider.notifier.start()` on successful generate/load
- [x] `clear()` — resets state and stops balance polling

### `lib/features/privacy/providers/shielded_balance_provider.dart`

- [x] Fetches balance from service with `includeCommitments: true`
- [x] Auto-refresh on a timer (30s) — `Timer.periodic(const Duration(seconds: 30), ...)`
- [x] Returns `ShieldedBalance?`
- [x] `start(zfxAddress)` — stores address, fetches immediately, starts timer
- [x] `fetch()` — guards on null address, updates state on success
- [x] `stop()` — cancels timer, clears address and state
- [x] `dispose()` — cancels timer (cleanup safety net)

### `lib/features/privacy/providers/privacy_actions_provider.dart`

- [x] Action methods: `shield()`, `unshield()`, `transfer()`, `consolidate()`
- [x] Each calls the correct service method
- [x] Shows Toast on success and error
- [x] Triggers balance refresh via `shieldedBalanceProvider.notifier.fetch()` after success
- [x] Loading state managed via `state = true/false` with `finally` block
- [x] Returns `bool` to indicate success/failure to callers

### Code Generation

- [x] `plonk_status_provider.g.dart` generated — Riverpod codegen output valid

---

## Findings

### Pattern Compliance

**StateNotifier usage:** Matches existing codebase patterns exactly. The project uses `StateNotifier` + `StateNotifierProvider` extensively (e.g., `BeaconFormProvider`, `WalletIsEncryptedProvider`, `GenesisBlockProvider`). All three manual providers follow this convention.

**Riverpod codegen (plonk_status):** Uses `@Riverpod(keepAlive: true)` with codegen — this is the newer Riverpod style also used in the codebase (e.g., `btc_balance_provider.g.dart`). Appropriate for a singleton that should survive navigation.

**Timer.periodic for polling:** Matches existing patterns (`web_session_provider.dart`, `password_required_provider.dart`, `listing_details.dart`). 30-second interval is reasonable for block-level refresh cadence.

**Toast usage:** `Toast.message()` for success and `Toast.error()` for failures — matches existing codebase convention in services and providers.

### Observations (No Action Required)

1. **`load()` calls `generateShieldedAddress()` rather than a GET endpoint:** The plan says "tries to fetch balance (if it succeeds, address exists)." The implementation calls `generateShieldedAddress()` which is idempotent (same HD seed + index = same address). This is a reasonable approach since there's no dedicated "get existing address" endpoint in the API — generating the same address is effectively a lookup. Functionally correct.

2. **No SharedPreferences persistence for zfx_ address:** The plan mentions "Persists zfx_ address locally (SharedPreferences or provider state)." The implementation uses provider state only (not SharedPreferences). This means the address is re-derived on app restart. Since `GenerateShieldedAddress` is deterministic from the HD wallet, this is functionally equivalent. No issue.

3. **PrivacyActions uses `bool` state for loading:** Clean approach — `StateNotifier<bool>` where `true` = loading. This is simple and effective for the action-oriented nature of this provider.

---

## Verdict: PASS

All 4 providers implemented with correct service wiring, auto-refresh, toast feedback, and balance refresh triggers. Follows existing StateNotifier and Riverpod patterns. Timer cleanup is properly handled. Codegen output valid.
