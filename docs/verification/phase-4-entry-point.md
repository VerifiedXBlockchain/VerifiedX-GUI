# Phase 4: vBTC → Base Bridge — Entry Point Integration — Verification Report

**Phase Objective:** Users can find and launch the bridge dialog. Visible in the app.

**Plan ref:** `BRIDGE_TO_BASE_PHASES.md` § Phase 4
**UX ref:** `BRIDGE_TO_BASE_UX_SPEC.md` § 2 (entry point), § 6 (edge cases)
**Reviewed:** 2026-05-19 (final pass after executor tightening)
**Commit:** `4caf3a55`

**Files reviewed:**
- `lib/features/btc/components/tokenized_btc_action_buttons.dart` — 19-line insert (one import + one `Tooltip(AppButton(...))` block)

---

## Final Implementation

```dart
// Bridge to Base — v2 contracts only, owner only. Disabled (with
// tooltip) when the contract has no vBTC; the dialog itself
// handles the per-user `availableVbtc` refinement via preflight.
if (isOwner && token.version == 2)
  Tooltip(
    message: token.balance > 0
        ? "Bridge vBTC to Base (vBTC.b)"
        : "No vBTC available to bridge",
    child: AppButton(
      label: "Bridge to Base",
      icon: Icons.swap_horiz,
      variant: AppColorVariant.Info,
      disabled: token.balance <= 0,
      onPressed: () {
        BridgeToBaseDialog.show(context, token, scOwner);
      },
    ),
  ),
```

Placement: between Transfer and Prove Ownership — groups action-on-asset buttons (Mint, Withdraw, Send, Transfer, Bridge) together; identity/meta actions (Prove Ownership) follow.

---

## Plan Task Checklist

| Plan task | Status | Notes |
|---|---|---|
| Placement in `tokenized_btc_action_buttons.dart` | ✓ | Between Transfer and Prove Ownership — logical grouping. |
| Only render for v2 contracts (`token.version == 2`) | ✓ | Strict spec match (executor reverted from earlier `>= 2`). |
| Only render when `token.balance > 0` (or disabled with tooltip) | ✓ | Disabled-with-tooltip pattern — better UX (affordance visible, reason explicit). |
| Calls `BridgeToBaseDialog.show(token, ownerAddress)` | ✓ | Actual call: `BridgeToBaseDialog.show(context, token, scOwner)` — matches dialog's `show(BuildContext, TokenizedBitcoin, String)` signature. |
| Manual end-to-end test against a live CLI | ⊘ | Acknowledged deferral — no live CLI in env. |

---

## UX Spec § 2 Conformance

| Spec requirement | Implementation | Status |
|---|---|---|
| Button label "Bridge to Base" | `label: "Bridge to Base"` | ✓ |
| Variant: secondary / Base brand color (subtle blue) | `variant: AppColorVariant.Info` (theme's blue) | ✓ |
| Icon: `Icons.swap_horiz` or custom | `icon: Icons.swap_horiz` | ✓ |
| Disabled state, tooltip "No vBTC available to bridge" | `disabled: token.balance <= 0`, tooltip "No vBTC available to bridge" | ✓ verbatim |
| Hidden entirely if contract is v1 | `if (isOwner && token.version == 2)` wrapper | ✓ |

---

## Executor Tightening (post-prior-review)

| Change | From | To | Reason |
|---|---|---|---|
| Version gate | `token.version >= 2` | `token.version == 2` | Strict spec match. Forward-compat for hypothetical v3 can be added when v3 exists. |
| Owner gate added | (no check) | `isOwner && ...` | Consistent with surrounding owner-only buttons (Prove Ownership immediately follows with `if (isOwner)`). A non-owner viewing someone else's contract shouldn't see a Bridge action that won't work. |

Both tightenings are sound. Owner-gating is the more meaningful one — it prevents the button from appearing on non-owned contracts where the bridge would inevitably fail.

---

## Findings

### Finding 1 — § 6 "wallet not unlocked" handled by preflight (team-lead accepted)
§ 6 says "User has no derived Base address → Disable Bridge button". The entry button doesn't gate on `hasDerivedAddress` because that would require firing the multi-call preflight on every contract render just to gate one button.

**Team-lead resolution (accepted):** Keep entry button as-is. The dialog's preflight already surfaces the failure with descriptive messaging. The "no derived address" condition is rare (effectively means the wallet key isn't accessible — which would block most other actions too). Phase 6 can revisit if this matters in practice.

Documented here per team-lead's request.

### Finding 2 — `Tooltip(AppButton)` behavior on disabled state
Worth verifying: `Tooltip` renders unconditionally regardless of the child's `disabled` flag. The Tooltip widget wraps any child and intercepts pointer events for its own hover/long-press detection, so disabled buttons still surface the contextual message. Confirmed by inspection of the widget composition — no special handling needed. ✓

The contextual tooltip text (`balance > 0 → "Bridge vBTC to Base (vBTC.b)"`; `balance <= 0 → "No vBTC available to bridge"`) gives the user a clear reason regardless of state.

### Finding 3 — Microcopy follows § 7 / § 9
- "Bridge to Base" label — § 7 ✓ ("Base" not "EVM")
- "Bridge vBTC to Base (vBTC.b)" enabled tooltip — § 7 ✓
- "No vBTC available to bridge" disabled tooltip — § 7 ✓
- No provider names anywhere — § 9 ✓

### Finding 4 — Diff is purely additive — no regressions
The diff is exactly one import (`bridge_to_base_dialog.dart`) and one `if (isOwner && token.version == 2) Tooltip(...)` block. No existing logic touched. Re-runs of the button list build identically when conditions are false. No risk of breaking other interactions.

### Finding 5 — Pre-existing lint warnings (not introduced by Phase 4)
`fvm dart analyze` on the modified file reports two `info`-level warnings, both confirmed via `git show HEAD~1:...` to predate the Phase 4 commit:
- Line 55: `unused_local_variable` — `bool debuggingAddressExists = true;`
- Line 488: `prefer_const_declarations` — a `final message` initialised to a constant

Phase 4 introduced zero new lint issues. Worth a one-line cleanup commit eventually, but not Phase 4's responsibility.

---

## Quality Summary

| Dimension | Result |
|---|---|
| Plan tasks done? | ✓ all four checkpoints |
| § 2 entry-point spec? | ✓ label, variant, icon, disabled state, v1 hidden — all match |
| § 6 edge cases? | ✓ (no-derived-address handled by dialog, team-lead accepted) |
| § 7 microcopy? | ✓ tooltip wording follows guidelines |
| Owner gating? | ✓ added in tightening — consistent with surrounding buttons |
| No regressions? | ✓ purely additive diff |
| Lint? | ✓ (no new warnings; pre-existing infos unchanged) |
| Manual CLI test? | ⊘ unverifiable from code review |

---

## Verdict

**PASS**

Phase 4 is a clean, minimal, additive change with all my prior concerns either addressed (owner gating, strict version match) or explicitly accepted (no-derived-address handled by preflight, "Reconnecting…" banner punted to Phase 6). The implementation matches every § 2 spec requirement verbatim, uses the better of the two spec-permitted disabled-state approaches, and threads the right arguments through to the dialog.

Two minor non-blockers worth a future note:
- Pre-existing lint warnings on lines 55 and 488 are not Phase 4's responsibility but warrant a one-line cleanup commit eventually.
- The Phase 3 `barrierDismissible` comment refresh mentions "Cancel" buttons that don't exist in the progress step (cosmetic — flagged in Phase 3 report).

Cleared to commit.
