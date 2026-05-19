# Phase 3: vBTC → Base Bridge — Dialog UI — Verification Report

**Phase Objective:** The main bridge flow works end-to-end against a real CLI. Four-step dialog (preflight, confirm, progress, result). No history view yet.

**Plan ref:** `BRIDGE_TO_BASE_PHASES.md` § Phase 3
**UX ref:** `BRIDGE_TO_BASE_UX_SPEC.md` § 3 (the dialog)
**Reviewed:** 2026-05-19

**Files reviewed:**
- `lib/features/bridge/components/bridge_to_base_dialog.dart` (215 lines) — step orchestrator
- `lib/features/bridge/components/bridge_preflight_form.dart` (545 lines) — step 1
- `lib/features/bridge/components/bridge_confirmation.dart` (163 lines) — step 2
- `lib/features/bridge/components/bridge_progress.dart` (419 lines) — step 3 + read-only re-use
- `lib/features/bridge/components/bridge_result.dart` (244 lines) — step 4
- `lib/features/bridge/components/bridge_explorer_links.dart` (33 lines) — VFX / Basescan URL helpers

---

## Plan Task Checklist

### Dialog orchestrator (`bridge_to_base_dialog.dart`)
| Task | Status | Notes |
|---|---|---|
| Stateful widget with `_BridgeStep` enum | ✓ | Enum is named `BridgeStep` (public, not `_BridgeStep`) — minor deviation, fine. Cases match plan: `preflight, confirm, progress, result`. |
| Static `show(token, ownerAddress)` helper | ✓ | Uses `rootNavigatorKey.currentContext` — consistent with `ShieldDialog`/`UnshieldDialog` precedent. |

### Step 1 — `BridgePreflightForm`
| Task | Status | Notes |
|---|---|---|
| Loading state during preflight | ✓ | `_Loading` shows centered spinner + "Checking your accounts…" — matches spec verbatim. |
| Form with amount + Max button | ✓ | Max sets controller to `preflight.availableVbtc.toString()`. |
| Destination + Reset-to-derived button | ✓ | Auto-fills from `preflight.derivedBaseAddress` once on first load (only if user hasn't typed); button restores. |
| Inline validation (amount, destination) | ✓ | `_validateAmount`: required, positive, ≤ `availableVbtc`. `_validateDestination`: required, matches `^0x[0-9a-fA-F]{40}$`. `autovalidateMode: onUserInteraction`. |
| Yellow gas warning when ETH < `BRIDGE_MIN_ETH_FOR_GAS` | ✓ | `_GasWarning` amber-styled banner via `preflight.isLowOnGas(BRIDGE_MIN_ETH_FOR_GAS)`. Warning only — doesn't block. |
| One-way disclaimer at top | ✓ | `_OneWayDisclaimer` matches spec wording. |
| Network info section | ✓ | Network name, contract (copy + explorer link via `BridgeExplorerLinks.baseAddress`), derived address (copy), ETH balance, vBTC.b balance. |
| "Review Bridge" → step 2 | ✓ | `_submit` runs validator then `onReview`. |
| Error states | ✓ | `availableVbtc<=0` → `_BlockedState` "no vBTC". `!bridgeConfigured` → `_BlockedState` "Bridging is currently unavailable…". Preflight HTTP error → `_ErrorState` with Retry that calls `ref.invalidate(...)`. |

### Step 2 — `BridgeConfirmation`
| Task | Status | Notes |
|---|---|---|
| Summary card with amount + destination | ✓ | Big "amount vBTC → amount vBTC.b" with truncated address + `SelectableText` full address. |
| Step list (1–3 of the actual flow) | ✓ | Lock → Wait for attestations → Submit mintWithProof. |
| One-way reminder | ✓ | Bottom info box with Fireblocks/MetaMask wording (see Finding 1 below). |
| Back / Confirm & Bridge buttons | ✓ | Both disabled during `isSubmitting`; Confirm shows `processing: true` spinner. |

### Step 3 — `BridgeProgress`
| Task | Status | Notes |
|---|---|---|
| Vertical stepper keyed off `BridgeLockRecord.status` | ✓ | Five visible stages: VFX submitted → Confirmed on VFX → Validator signatures → Submit mint on Base → Minted on Base. |
| Tx hash rows with copy + explorer links (VFX + Basescan) | ✓ | `_TxRow` for `vfxLockTxHash` (→ Spyglass) and `baseTxHash` (→ Basescan). |
| Signature counter when in attestation phase | ✓ | "X / Y signatures collected" shown when `requiredSignatures > 0`. Maps to `attestationPending`/`attestationReady` (the actual CLI enum names, not the spec's informal `AwaitingSignatures`). |
| Note about safe-to-close | ✓ | `_SafeToCloseNote`. |
| Disable Cancel during in-flight | ✓ (different shape than spec implied) | There's no Cancel button in the progress step. The dialog's top-right X is the only dismiss path. The whole step is built around "safe to close" — see Finding 3. |

### Step 4 — `BridgeResult`
| Task | Status | Notes |
|---|---|---|
| Success: vBTC.b balance message + Basescan link | ✓ | "You now have N vBTC.b on Base at 0x…" with copy + explorer. |
| "What's next" card | ✓ | Contains `Fireblocks, MetaMask, or another EVM wallet` — see Finding 1. |
| Failure: error message + link to history detail | ✓ (Phase 5 wiring deferred) | `_Failure` shows `errorMessage`, "Your vBTC may still be locked…" copy, Close button. "View Details" surfaces the read-only progress view in a nested dialog as a stand-in until Phase 5 wires real navigation. Reasonable interim. |

### Other plan tasks
| Task | Status | Notes |
|---|---|---|
| Wire to `bridgeOperationProvider` for live status | ✓ | `BridgeProgress` watches it; auto-fires `onTerminal` once. |
| `fvm dart analyze` clean | ✓ | Confirmed: `No issues found!` over `lib/features/bridge/`. |
| Manual verification against live CLI | ⊘ | Can't verify from a code review — flag for team-lead to confirm. |

---

## Findings

### Finding 1 — ⚠ Plan-vs-spec conflict: provider names in "What's next" card
**Plan said:** `What's next" card (generic — no provider names)` (Phase 3 § BridgeResult task).
**UX spec § 3 said (verbatim):** `Use Fireblocks, MetaMask, or another EVM wallet to:`
**Implementation used:** `Use Fireblocks, MetaMask, or another EVM wallet to:` (matches the spec).

The same provider-name pattern shows up in three other places:
- `_OneWayDisclaimer` (preflight step): "use Fireblocks, MetaMask, or another EVM wallet to manage, transfer, or exit"
- `_Failure` placeholder / Confirmation reminder: "You'll use a Base wallet (Fireblocks, MetaMask, etc.) for any further actions on vBTC.b"

The executor reasonably went with the more concrete spec wording. **Team-lead decision needed:** keep spec wording (concrete, helpful, name-drops competitor wallets) or revert to plan's generic "Base wallet / EVM wallet" framing. If the goal is to avoid implicitly endorsing third parties, swap to generic. If the goal is user clarity, the named version is more actionable. Not a blocker — easy one-line copy edit either way.

### Finding 2 — ⚠ Inconsistency: `barrierDismissible: true` vs comment intent
In `bridge_to_base_dialog.dart` line 38–41:
```dart
// Don't allow tap-outside-to-dismiss while a submission is in flight —
// the user can still close via the X / Cancel buttons, which the steps
// gate themselves.
barrierDismissible: true,
```
Comment says the intent is to **prevent** outside-tap dismissal during submission. Actual value (`true`) means outside-tap **does** dismiss the dialog at any step, including during `_isSubmitting`. `showDialog`'s `barrierDismissible` is fixed at modal-creation time and can't be made dynamic without wrapping in `PopScope`/`WillPopScope`.

The `if (!mounted) return;` guards inside `_handleConfirm` prevent crashes — so functionally safe. But the behavior contradicts the stated intent. **Recommend:** either set `barrierDismissible: false` and rely on the X button only, or update the comment to reflect actual behavior. Non-blocker since the safe-to-close design makes outside-tap acceptable, but the mismatch will confuse future readers.

### Finding 3 — Spec-vs-implementation on "Cancel disabled in progress"
UX spec § 3 (Progress): "Cancel button is disabled. A note: 'Safe to close this dialog…'"
Plan Phase 3: "Disable Cancel during in-flight"

Implementation: There's **no Cancel button** in the progress step. The only dismiss is the top-right X, and it's enabled (because the safe-to-close note says closing is fine — the bridge continues in the background). The spec's "Cancel button is disabled" is logically inconsistent with the "safe to close" copy — if it's safe to close, why disable the only close action?

The executor's resolution (no Cancel button, X stays enabled, safe-to-close note explains) is internally coherent and matches the spirit of "the bridge continues whether you stay or leave". **Sound design choice.** Worth flagging so team-lead can confirm.

### Finding 4 — `BridgeProgress` stepper failure-state inference
When `record.isFailed`, `_inProgressIndexAtFailure()` infers which stage was active at failure using populated hashes / signature counts. The CLI doesn't tell us which stage failed, so this is necessarily a heuristic:
- `baseTxHash` present → stage 4 (mint submission)
- signatures present or VFX confirmed → stage 2 (attestations)
- VFX hash present → stage 1 (confirmation)
- otherwise → stage 0 (submission)

This is reasonable. Edge case: if the failure happens between stages (e.g., `vfxLockConfirmedOnChain` is true but `errorMessage` is about a totally different issue), the red X might land on a stage that was already "done". Low-impact since the error message text itself is shown in `_FailureBox`. Worth a future enhancement when the CLI surfaces a failure-stage hint.

### Finding 5 — Amount display formatting
`BridgeConfirmation` renders `"$amount vBTC"` using Dart's default `double.toString()`. For typical bridge amounts (≥ 0.00001 vBTC per `MIN_SHIELD_AMOUNT_VBTC`), this displays cleanly. But for very small values (e.g., `1e-7`), Dart can emit scientific notation. The form's `_validateAmount` doesn't impose a minimum, so it's technically possible — though improbable in practice — to enter `0.0000001` and see "1e-7 vBTC" on the confirmation screen.

`BridgeResult._Success` has the same pattern: `"You now have ${record.amount} vBTC.b on Base"`.

**Recommend (non-blocker for Phase 3):** Phase 6 (polish) should wrap these in a small `_formatVbtc(double)` helper that uses `toStringAsFixed(8)` and trims trailing zeros. Worth adding to your polish list.

### Finding 6 — `onPressed: isSubmitting ? () {} : onBack` pattern
In `BridgeConfirmation`, disabled buttons use `onPressed: () {}` (empty function) alongside `disabled: true`. Looking at the `AppButton` implementation (`buttons.dart`), `disabled` correctly forces the disabled-color styling, so visually it works. But passing an empty function rather than `null` means a hit-test still produces a tap that does nothing. Tap-feedback may still show.

Existing project pattern (e.g., `home_buttons.dart` and similar) varies — some use `null`, some use `() {}`. Not a blocker; flagging for consistency review at polish time.

### Finding 7 — `_handleReview` discards preflight argument
Signature: `void _handleReview(_, double amount, String destination)`. The first underscore parameter is the `BridgePreflight` (matches the callback type `void Function(BridgePreflight, double, String)` declared on `BridgePreflightForm`) but is unused in the body. Either:
- The handler should take it and forward to `_handleConfirm` so initiating logic can re-validate against the live preflight (defensive), OR
- The form's callback shouldn't even pass it.

Either way, the current "`_`" pattern is unconventional and slightly confusing. Non-blocker — cosmetic.

---

## Quality Checks

### Lifecycle & state
- ✓ `dispose()` disposes both text controllers.
- ✓ All async paths guarded with `if (!mounted) return;`.
- ✓ `_firedTerminal` flag in `BridgeProgress` prevents double-firing the terminal callback.
- ✓ Post-frame callback in `_BridgeProgressState.build` ensures `onTerminal` doesn't fire mid-build (parent setState wouldn't be safe).
- ✓ `ref.read(bridgeLockListProvider(ownerAddress).notifier).refresh()` called after `initiateLock` — Phase 5 history will pick up the new lock immediately.

### Read-only re-use for Phase 5
- ✓ `BridgeProgress(readOnly: true)` suppresses the safe-to-close note and skips `onTerminal`. Clean abstraction; Phase 5 history detail can render it without modification.

### Reactive correctness
- ✓ `bridgePreflightProvider(_args)` is watched via `async.when(...)`; retry calls `ref.invalidate(...)` (correct way to force re-fetch of a FutureProvider.family).
- ✓ `bridgeOperationProvider(lockId)` is watched; polling is the provider's responsibility (Phase 2).
- ✓ Destination auto-seed only fires when user hasn't typed (`_destinationEdited` flag).

### Explorer links
- ✓ `BridgeExplorerLinks.vfxTx(hash)` uses `Env.explorerWebsiteBaseUrl` (confirmed: `lib/core/env.dart:83`).
- ✓ `BridgeExplorerLinks.baseTx(hash)` switches between basescan.org / sepolia.basescan.org via `Env.isTestNet` (confirmed at `lib/core/env.dart:103`).
- ✓ `BridgeExplorerLinks.baseAddress(address)` for the success-step destination link.

### Visual hierarchy & accessibility
- ✓ Color contrasts are reasonable (white on dark with white54/38 muting for secondary info).
- ✓ Long addresses use `SelectableText` so users can copy manually if the icon misses.
- ✓ Stage icons have semantic meaning (check_circle = done, radio_button_checked = in progress, cancel = failed). No text-only state.

### Lint
- ✓ `fvm dart analyze lib/features/bridge/` — `No issues found!`.

---

## Quality Summary

| Dimension | Result |
|---|---|
| Works against plan? | ✓ all four steps implemented |
| Matches UX spec wording? | ✓ — but spec/plan disagree on provider names (Finding 1) |
| Reactive correctness? | ✓ FutureProvider invalidation, StateNotifier watching, mounted guards |
| Failure paths handled? | ✓ error/blocked states for no vBTC, no bridge config, network failure, retry; failure result view with retry/details affordance |
| Lifecycle clean? | ✓ controllers disposed, no leaks, mounted guards, post-frame callback |
| Read-only re-use viable for Phase 5? | ✓ explicit `readOnly` flag suppresses interactivity correctly |
| Lint? | ✓ clean |

---

## Verdict

**PASS WITH WARNINGS**

All four steps are implemented per plan, lint clean, and reactive integration with Phase 2's providers is correct. The read-only `BridgeProgress` mode sets Phase 5 up for clean re-use, and the post-`initiateLock` list refresh ensures the history view (Phase 5) will see the new lock immediately.

**Three things worth your attention before commit:**

1. **Plan-vs-spec naming conflict** (Finding 1): Plan said "no provider names" in the "What's next" card; UX spec said "Fireblocks, MetaMask, or another EVM wallet" verbatim. Executor used the spec wording (three places: preflight disclaimer, confirmation reminder, success card). Pick a side — if it's the plan, three quick microcopy edits to genericise.

2. **`barrierDismissible: true` contradicts its own comment** (Finding 2). Either set to `false` or rewrite the comment. Mounted guards prevent crashes either way.

3. **Manual CLI verification** is plan-required but I can't validate it from code review. Confirm it was done end-to-end against a live CLI before commit (or note when it was tested).

Plus three low-priority polish items for Phase 6: amount formatting (`toStringAsFixed(8)`), `null` vs `() {}` for disabled buttons, and the unused-preflight `_` parameter in `_handleReview`.

Nothing here blocks the commit. Sound implementation.
