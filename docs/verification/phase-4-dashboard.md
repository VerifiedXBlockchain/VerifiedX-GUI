# Phase 4: Dashboard — Verification Report

**Phase Objective:** Main privacy screen with balance, address, action buttons, and commitment list.

**Reviewed:** 2026-03-24

---

## Plan Task Checklist

### `lib/features/privacy/components/privacy_dashboard.dart`

- [x] Displays zfx_ address with copy button (via `_AddressCard`)
- [x] Shows shielded VFX balance total (via `_BalanceCard` using `balance.vfxBalance`)
- [x] 4 action buttons: Shield, Unshield, Transfer, Consolidate (via `_ActionButtons`)
- [x] Buttons show "coming soon" toast (e.g., "Shield dialog coming in Phase 5")
- [x] Uses `AppButton` with `AppColorVariant` — all 4 variants (Success, Warning, Primary, Info) exist in enum
- [x] Extends `BaseComponent` — matches existing component convention
- [x] Watches `shieldedBalanceProvider` for reactive updates

**Additional quality details (beyond plan):**
- [x] Copy button uses `Clipboard.setData` + Toast feedback
- [x] Balance card shows loading spinner when balance is null
- [x] Note count with proper plural handling (`note` vs `notes`)
- [x] Last scanned block height displayed
- [x] View-only badge shown when `balance.isViewOnly` is true
- [x] `SingleChildScrollView` wrapper for overflow safety

### `lib/features/privacy/components/commitment_list.dart`

- [x] Expandable section: "Commitments (N notes)"
- [x] Lists individual notes: amount, asset type, tree position, block height
- [x] Collapsed by default (`initiallyExpanded: false`)
- [x] Extends `BaseComponent` — matches convention
- [x] Returns `SizedBox.shrink()` when commitments are null or empty
- [x] Filters to show only unspent commitments
- [x] Status indicator dot (green for unspent, red for spent)

### `lib/features/privacy/screens/privacy_screen.dart` (modified)

- [x] Dashboard placeholder replaced with `PrivacyDashboard` widget
- [x] Import added for `privacy_dashboard.dart`
- [x] Passes `shieldedAddress` to `PrivacyDashboard(address: shieldedAddress)`

---

## Findings

### Pattern Compliance

**Widget decomposition:** The dashboard is cleanly decomposed into private widget classes (`_AddressCard`, `_BalanceCard`, `_ActionButtons`) — keeps the file organized without polluting the public API. This matches patterns seen in other feature screens.

**AppButton usage:** Uses the project's `AppButton` from `core/components/buttons.dart` with `AppColorVariant` values (Success, Warning, Primary, Info) — all verified to exist in `app_theme.dart:23-35`. Consistent with how other features use action buttons.

**Card styling:** Uses `AppColors.getGray(ColorShade.s200)` for card backgrounds — matches the activation card from Phase 3 and general dark-theme card patterns in the codebase.

**CommitmentList filtering:** Wisely filters to only unspent commitments for display, while still showing the unspent count in the header. This is the right UX — users care about spendable notes, not spent history.

### Observations (No Action Required)

1. **Balance display format:** Uses `${balance!.vfxBalance}` directly, which will render as Dart's default double toString (e.g., "100.0" not "100.00"). This is fine for now — consistent with how other balance displays in the app work. Formatting can be refined later if needed.

2. **ExpansionTile divider workaround:** The `Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent))` wrapper suppresses the default ExpansionTile divider. This is a common Flutter pattern and works correctly.

---

## Verdict: PASS

Dashboard displays address with copy button, shielded balance with note count and block height, 4 action buttons with placeholder toasts, and an expandable commitment list. Screen properly wired to replace Phase 3 placeholder. All UI components use existing project patterns (BaseComponent, AppButton, AppColors). Commitment list correctly filters unspent notes and collapses by default.
