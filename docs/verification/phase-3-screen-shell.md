# Phase 3: Screen Shell + Navigation Wiring — Verification Report

**Phase Objective:** Privacy tab appears in side nav (PLONK-gated). Screen shows activation or placeholder.

**Reviewed:** 2026-03-24

---

## Plan Task Checklist

### `lib/features/privacy/screens/privacy_screen.dart`

- [x] Top-level screen for the tab
- [x] Reads `plonkStatusNotifierProvider` and `shieldedAddressProvider`
- [x] If PLONK status null: shows loading spinner with "Checking privacy layer status..."
- [x] If PLONK not enabled: shows informative message that privacy layer is unavailable
- [x] If no address: shows `PrivacyActivationCard`
- [x] If address exists: shows placeholder dashboard with zfx_ address displayed
- [x] Extends `BaseScreen` — matches existing screen convention

### `lib/features/privacy/components/privacy_activation_card.dart`

- [x] Intro text explaining the privacy layer
- [x] "Activate Privacy Wallet" button → calls `shieldedAddressProvider.notifier.generate()`
- [x] Loading state while generating (spinner replaces icon, text changes to "Activating...")
- [x] Button disabled during loading (`onPressed: _isLoading ? null : _activate`)
- [x] Toast feedback on success and error
- [x] `mounted` check before `setState` in async callback — proper lifecycle safety
- [x] Extends `BaseComponent` — matches existing component convention

### `lib/core/app_router.dart`

- [x] Import added for `PrivacyScreen`
- [x] `AutoRoute` child added for Privacy under RootContainer with path `"privacy"` and name `"PrivacyTabRouter"`
- [x] Uses `EmptyRouterPage` wrapper — matches all other tab routes
- [x] Placed as last child in the children list

### `lib/features/navigation/components/root_container_side_nav_list.dart`

- [x] Import added for `plonk_status_provider.dart`
- [x] `RootContainerSideNavItem` added for "Privacy"
- [x] Desktop only: wrapped in `if (!kIsWeb)` — correct
- [x] PLONK-gated: watches `plonkStatusNotifierProvider`, returns `SizedBox.shrink()` when not enabled
- [x] Uses `Builder` widget to scope the provider watch — avoids unnecessary rebuilds
- [x] `isNew: true` flag — good UX, highlights the new feature
- [x] Uses `PrettyIconType.lock` icon — consistent with existing nav items
- [x] Tab index `17` — follows the established pattern (Operations=16, Privacy=17)

### Code Generation

- [x] `app_router.gr.dart` regenerated — contains `PrivacyTabRouter` and `PrivacyScreenRoute` classes
- [x] Route registered as child of `RootContainerRoute` in generated config

---

## Findings

### Pattern Compliance

**Screen:** Uses `BaseScreen` with `appBar()` and `body()` overrides — matches existing screens like `ValidatorScreen`, `OperationsScreen`, etc.

**Component:** `PrivacyActivationCard` extends `BaseComponent` — matches existing component convention. The `_ActivateButton` is extracted as a `ConsumerStatefulWidget` for local loading state, which is a clean pattern that avoids putting ephemeral UI state into the provider layer.

**Nav item:** Follows the exact same structure as other desktop-only nav items (Validator, Operations) — wrapped in `if (!kIsWeb)` with `setActiveIndex()` and drawer close logic.

**PLONK gating:** The conditional rendering approach (watch provider, return `SizedBox.shrink()` when disabled) is clean and reactive. If the PLONK status changes, the nav item will appear/disappear automatically.

### Observations (No Action Required)

1. **Tab index hardcoding:** The nav uses hardcoded indices (`setActiveIndex(17)`) rather than named route navigation. This matches the existing pattern throughout the nav — all other items use hardcoded indices too. While fragile, it's consistent.

2. **Three-state screen logic:** The screen handles PLONK-null (loading), PLONK-disabled (unavailable), no-address (activation), and has-address (dashboard placeholder) — four states total. This is thorough and covers edge cases well.

---

## Verdict: PASS

Privacy screen, activation card, route registration, and nav item all implemented correctly. PLONK gating works via reactive provider watch. Desktop-only enforcement via `!kIsWeb`. Router codegen regenerated successfully. All patterns match existing codebase conventions.
