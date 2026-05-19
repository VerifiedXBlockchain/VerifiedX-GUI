# Phase 4: vBTC → Base Bridge — Entry Point Integration — Verification Report

**Phase Objective:** Users can find and launch the bridge dialog. Visible in the app.

**Plan ref:** `BRIDGE_TO_BASE_PHASES.md` § Phase 4
**UX ref:** `BRIDGE_TO_BASE_UX_SPEC.md` § 2 (entry point), § 6 (edge cases)
**Reviewed:** 2026-05-19

**Files reviewed:**
- `lib/features/btc/components/tokenized_btc_action_buttons.dart` — diff: +19 lines (one import + one Tooltip-wrapped AppButton)

---

## Plan Task Checklist

| Plan task | Status | Notes |
|---|---|---|
| Placement in `tokenized_btc_action_buttons.dart` | ✓ | Inserted right before the "Prove Ownership" button, alongside existing actions. Natural position in the action row. |
| Only render for v2 contracts (`token.version == 2`) | ✓ (improved) | Uses `token.version >= 2` — forward-compatible if a hypothetical v3 lands (still gets the button without code change). Sensible widening. |
| Only render when `token.balance > 0` (or disabled with tooltip) | ✓ | Implementation uses the **disabled-with-tooltip** approach: button always renders for v2+ contracts, but `disabled: token.balance <= 0` with the tooltip "No vBTC available to bridge". This is the better UX — users see the affordance exists even when greyed out, with clear reason. |
| Calls `BridgeToBaseDialog.show(token, ownerAddress)` | ✓ | Actual call is `BridgeToBaseDialog.show(context, token, scOwner)`. The dialog's `show()` signature is `show(BuildContext, TokenizedBitcoin, String)` — three params matched correctly. |
| Manual end-to-end test against a live CLI | ⊘ | Can't validate from code review. Acknowledge if executor verified; otherwise flag for QA. |

---

## UX Spec § 2 Conformance

| Spec requirement | Implementation | Status |
|---|---|---|
| Button label "Bridge to Base" | `label: "Bridge to Base"` | ✓ |
| Variant: secondary / Base brand color (subtle blue, distinct from VFX blue) | `variant: AppColorVariant.Info` (theme's info/blue) | ✓ — reasonable mapping |
| Icon: `Icons.swap_horiz` or custom Base-style | `icon: Icons.swap_horiz` | ✓ |
| Disabled state: `availableVbtc <= 0`, tooltip "No vBTC available to bridge" | `disabled: token.balance <= 0`, tooltip "No vBTC available to bridge" | ✓ (verbatim tooltip) |
| Hidden entirely if contract is v1 | `if (token.version >= 2)` wrapper | ✓ |

---

## Findings

### Finding 1 — ⚠ § 6 "wallet not unlocked" edge case unhandled at entry layer (Phase 3 carryover)
In my Phase 3 review I flagged: § 6 says "User has no derived Base address (key unavailable) → Disable Bridge button; show 'Bridge unavailable — wallet not unlocked'". I asked Phase 4 to enforce this at the entry button.

**Phase 4 does NOT check `hasDerivedAddress`.** The button only checks `token.balance`. A user without a derived Base address can still:
1. Click the (enabled) Bridge button
2. See the dialog open and the preflight load with `hasDerivedAddress: false`
3. Type any address into the destination field and proceed (the dialog allows custom destinations)

**Pragmatic verdict:** Without calling preflight at button-render time, the entry layer can't know whether the wallet's key state allows a derived Base address. Eagerly calling preflight just to gate one button would be wasteful (preflight is a multi-call composite). The current behavior is actually **more permissive** than the spec demands — a user can still bridge to a manually-entered address (e.g., a custodial address they pasted). The cost is losing the explicit "wallet not unlocked" diagnostic message when that's the underlying cause.

**Recommendation:** Document this as an intentional deviation from § 6's strict reading, OR add a simple defensive `_BlockedState` in the preflight form for the case where `!preflight.hasDerivedAddress && !preflight.bridgeConfigured` (since the two failure modes might present similarly). Non-blocker — current behavior is functional, just less specific in error messaging.

### Finding 2 — Tooltip / accessibility
The Tooltip wraps the entire AppButton — works in both enabled and disabled states (`Tooltip.message` is set unconditionally). Hover/long-press shows the appropriate text in either state:
- Enabled: "Bridge vBTC to Base (vBTC.b)"
- Disabled: "No vBTC available to bridge"

§ 7 "Base not EVM" respected. § 9 no-provider-names respected. ✓

### Finding 3 — Phase 4 diff is purely additive — no regressions
The diff is one import and one Tooltip/AppButton block. No existing logic touched. The button list ordering keeps the Bridge action visually adjacent to the other contract actions (Mint, Withdraw, Send, etc.). No risk of breaking other interactions.

### Finding 4 — Pre-existing lint warnings (not introduced by Phase 4)
`fvm dart analyze lib/features/btc/components/tokenized_btc_action_buttons.dart` reports two `info`-level warnings:
- Line 55: `unused_local_variable` — `bool debuggingAddressExists = true;` (pre-existing in HEAD).
- Line 488: `prefer_const_declarations` — a `final` that could be `const` (pre-existing in HEAD).

Confirmed via `git show HEAD:...` — both predate the Phase 4 commit. Phase 4 added no new warnings, so the "lint clean" claim for the Phase 4 *change* is accurate. Worth a one-line cleanup commit later but not Phase 4's responsibility.

### Finding 5 — `show()` signature change between Phase 3 and Phase 4 reports
My Phase 3 verification report listed the signature as `show(TokenizedBitcoin token, String ownerAddress)` (2 args). The actual committed signature in Phase 3 was `show(BuildContext context, TokenizedBitcoin token, String ownerAddress)` (3 args) — my Phase 3 report had stale info on this detail (file was edited during my review window). Phase 4's call site `BridgeToBaseDialog.show(context, token, scOwner)` is **correct** against the actual signature.

**Side note:** Phase 3 also addressed my Finding 6 (`barrierDismissible: true` vs comment) — the comment was rewritten to: *"Tap-outside-to-dismiss is allowed: bridge operations are safe to close at any time — polling continues server-side and history will surface the result."* Now consistent with the value. (Minor lingering issue: the new comment says "Step-level UI (X / Cancel) provides the explicit close affordance" but the progress step has no Cancel button — see Phase 3 Finding 4. Cosmetic.)

---

## Quality Summary

| Dimension | Result |
|---|---|
| Plan tasks done? | ✓ all four checkpoints |
| § 2 entry-point spec? | ✓ label, variant, icon, disabled state, v1 hidden — all match |
| § 7 microcopy? | ✓ tooltip wording follows guidelines |
| No regressions? | ✓ purely additive diff |
| Lint? | ✓ for the Phase 4 change (pre-existing warnings unchanged) |
| § 6 "wallet not unlocked"? | ⚠ entry button doesn't gate on `hasDerivedAddress`; dialog allows manual destination (see Finding 1) |
| Manual CLI test? | ⊘ unverifiable from code review |

---

## Verdict

**PASS WITH WARNINGS**

Phase 4 is a clean, minimal, additive change — the right scope for what's essentially a single button. It matches every § 2 spec requirement (label, icon, variant, disabled-with-tooltip pattern, v1-hidden) and uses the better of the two spec-permitted approaches for the disabled state. The call into the dialog correctly threads `context`, `token`, and `scOwner`.

**One spec gap (Finding 1):** § 6's "wallet not unlocked → disable button" isn't enforced at the entry layer. Without preflight at render-time, the button can't know the wallet's key state. Pragmatic interpretation: current behavior is more permissive (user can bridge to a manually-entered address even without a derived one), which is arguably better than blocking. **Team-lead decision:** accept as intentional deviation, OR add a defensive no-derived-address branch in the preflight form (Phase 3 carryover).

**Two non-blockers worth noting:**
- Pre-existing lint warnings in `tokenized_btc_action_buttons.dart` (lines 55, 488) are not Phase 4's doing — but worth a one-line cleanup eventually.
- The Phase 3 `barrierDismissible` comment has been refreshed (good!) but the new comment references a "Cancel" button that doesn't exist in the progress step. Cosmetic.

Cleared to commit.
