# Phase 3: vBTC → Base Bridge — Dialog UI — Verification Report

**Phase Objective:** The main bridge flow works end-to-end. Four-step dialog (preflight, confirm, progress, result). No history view yet.

**Plan ref:** `BRIDGE_TO_BASE_PHASES.md` § Phase 3
**UX ref:** `BRIDGE_TO_BASE_UX_SPEC.md` § 3 (the dialog), § 6 (edge cases), § 7 (copy guidelines), § 9 (resolved decisions — binding)
**Reviewed:** 2026-05-19

**Files reviewed:**
- `lib/features/bridge/components/bridge_to_base_dialog.dart` (215 lines) — step orchestrator
- `lib/features/bridge/components/bridge_preflight_form.dart` (545 lines) — step 1
- `lib/features/bridge/components/bridge_confirmation.dart` (163 lines) — step 2
- `lib/features/bridge/components/bridge_progress.dart` (419 lines) — step 3 + read-only re-use
- `lib/features/bridge/components/bridge_result.dart` (244 lines) — step 4
- `lib/features/bridge/components/bridge_explorer_links.dart` (33 lines) — Spyglass / Basescan URL helpers

---

## Plan Task Checklist

### Dialog orchestrator (`bridge_to_base_dialog.dart`)
| Task | Status | Notes |
|---|---|---|
| Stateful widget with `_BridgeStep` enum | ✓ | Enum named `BridgeStep` (public, not `_BridgeStep`) — minor deviation, fine. |
| Static `show(token, ownerAddress)` helper | ✓ | Uses `rootNavigatorKey.currentContext` — consistent with `ShieldDialog`/`UnshieldDialog`. |

### Step 1 — `BridgePreflightForm`
| Task | Status | Notes |
|---|---|---|
| Loading state during preflight | ✓ | `_Loading` shows centered spinner + "Checking your accounts…". |
| Form with amount + Max button | ✓ | Max sets controller to `preflight.availableVbtc.toString()`. |
| Destination + Reset-to-derived button | ✓ | Auto-fills from `preflight.derivedBaseAddress` once on first load (only if user hasn't typed); button restores. |
| Inline validation (amount, destination) | ✓ functionally; ⚠ error copy | `_validateAmount`: required, positive, ≤ `availableVbtc`. `_validateDestination`: required, matches `^0x[0-9a-fA-F]{40}$`. `autovalidateMode: onUserInteraction`. **Error copy violates § 7** — see Finding 1b. |
| Yellow gas warning when ETH < `BRIDGE_MIN_ETH_FOR_GAS` | ✓ | `_GasWarning` amber-styled banner via `preflight.isLowOnGas(BRIDGE_MIN_ETH_FOR_GAS)`. Warning only — doesn't block. |
| One-way disclaimer at top | ✓ | `_OneWayDisclaimer` — provider names correctly absent (§ 9 ✓). |
| Network info section | ✓ | Network name, contract (copy + explorer link), derived address (copy), ETH balance, vBTC.b balance. |
| "Review Bridge" → step 2 | ✓ | `_submit` runs validator then `onReview`. |
| Error states | ✓ (partial) | `availableVbtc<=0`, `!bridgeConfigured`, HTTP error with Retry (`ref.invalidate(bridgePreflightProvider(_args))`). § 6 "User has no derived Base address" case not explicitly handled at this layer — flagged in Finding 3. |

### Step 2 — `BridgeConfirmation`
| Task | Status | Notes |
|---|---|---|
| Summary card with amount + destination | ✓ | Big "amount vBTC → amount vBTC.b" with truncated address + `SelectableText` full address. |
| Step list (1–3 of the flow) | ⚠ copy | Lock → "Wait for validators to sign mint **attestations**" → Submit mintWithProof. **The word "attestations" violates § 7** — see Finding 1a. |
| One-way reminder | ✓ | Bottom info box uses "your DeFi provider or another Base (EVM) wallet" — provider names correctly absent. |
| Back / Confirm & Bridge buttons | ✓ | Both disabled during `isSubmitting`; Confirm shows `processing: true` spinner. |

### Step 3 — `BridgeProgress`
| Task | Status | Notes |
|---|---|---|
| Vertical stepper keyed off `BridgeLockRecord.status` | ✓ | Five visible stages: VFX submitted → Confirmed on VFX → Validator signatures → Submit mint on Base → Minted on Base. User-visible label for stage 3 uses "validator signatures" (✓ § 7). |
| Tx hash rows with copy + explorer links (VFX + Basescan) | ✓ | `_TxRow` for `vfxLockTxHash` (→ Spyglass via `Env.explorerWebsiteBaseUrl`) and `baseTxHash` (→ Basescan/Sepolia via `Env.isTestNet`). |
| Signature counter when in attestation phase | ✓ | "X / Y signatures collected" shown when `requiredSignatures > 0`. Maps `attestationPending`/`attestationReady` (CLI enum). |
| Note about safe-to-close | ✓ | `_SafeToCloseNote`. |
| Disable Cancel during in-flight | ✓ (different shape than spec implied) | No Cancel button exists in the progress step. The dialog's top-right X is the only dismiss path and stays enabled — see Finding 4. |

### Step 4 — `BridgeResult`
| Task | Status | Notes |
|---|---|---|
| Success: vBTC.b balance message + Basescan link | ✓ | "You now have N vBTC.b on Base at 0x…" with copy + explorer. |
| "What's next" card | ✓ | "Use your DeFi provider or another Base (EVM) wallet to:" — provider names correctly absent (§ 9 ✓). |
| Failure: error message + link to history detail | ✓ (Phase 5 wiring deferred) | `_Failure` shows `errorMessage`, "Your vBTC may still be locked…" copy, Close button. "View Details" surfaces the read-only progress view in a nested dialog as a stand-in until Phase 5 wires real navigation. Acknowledged deferral. |

### Cross-cutting
| Task | Status | Notes |
|---|---|---|
| Wire to `bridgeOperationProvider` for live status | ✓ | `BridgeProgress` watches it; auto-fires `onTerminal` once via `_firedTerminal` + post-frame callback. |
| Post-`initiateLock` list refresh | ✓ | `bridgeLockListProvider(ownerAddress).notifier.refresh()` — Phase 5 history sees new lock immediately. |
| `BridgeProgress(readOnly: true)` for Phase 5 re-use | ✓ | Suppresses safe-to-close note and skips `onTerminal`. Clean abstraction. |
| `fvm dart analyze` clean | ✓ | Re-confirmed: `No issues found!`. |
| Manual CLI verification | ⊘ | Acknowledged deferral — no live CLI in env. |

---

## Microcopy Audit (§ 7 + § 9)

§ 7 binding guidelines:
1. "Base" not "EVM"
2. Avoid jargon: prefer "validator signatures" over "attestations"
3. One-way messaging: consistent "from this app"
4. "Bridge" as verb; avoid "send to Base"

§ 9 Resolved Decision 2: "Label the field 'Base (EVM) Address'. No provider names (no 'Fireblocks', 'Coinbase', etc.)."

| Location | Copy | Verdict |
|---|---|---|
| `bridge_preflight_form.dart:206` | Label: "Base (EVM) Address" | ✓ exactly per § 9 |
| `bridge_preflight_form.dart:97` | Validator error: `"Must be a valid 0x EVM address (40 hex chars)"` | ✗ **§ 7 violation** — should be "valid 0x Base address (40 hex chars)" |
| `bridge_preflight_form.dart:285` | Disclaimer: "use your DeFi provider or another Base (EVM) wallet…" | ✓ no provider names; "Base (EVM)" parenthetical mirrors § 9 pattern |
| `bridge_confirmation.dart:78` | Step 2 label: `"Wait for validators to sign mint attestations"` | ✗ **§ 7 violation** — should be "Wait for validators to sign your bridge" or "Wait for validator signatures" |
| `bridge_confirmation.dart:104` | Reminder: "you'll use your DeFi provider or another Base (EVM) wallet…" | ✓ no provider names |
| `bridge_progress.dart` user labels | "Collecting validator signatures…" / "Validator signatures collected" | ✓ uses § 7 preferred term |
| `bridge_progress.dart:136` | Comment: `// Lock confirmed, waiting for attestations.` | ✓ code comment, not user-facing |
| `bridge_result.dart:120` | "Use your DeFi provider or another Base (EVM) wallet to:" | ✓ no provider names |

**Net:** Two real § 7 violations (both user-facing), zero § 9 provider-name violations. Provider names appear to have been removed from an earlier draft — only "DeFi provider" remains, which is a category not a brand. Good.

---

## § 6 Edge-Case Coverage

| Scenario | Implementation | Status |
|---|---|---|
| User closes dialog mid-bridge | Provider keeps polling; safe-to-close note in progress step | ✓ |
| No derived Base address (key unavailable) | Spec says "Disable Bridge button; show 'Bridge unavailable — wallet not unlocked'". Dialog allows user to type their own address — no explicit guard, no error message. | ⚠ see Finding 3 |
| `bridgeConfigured: false` | Full-dialog error in `_BlockedState` | ✓ |
| Lock tx fails to broadcast | Toast.error from `initiateLock` returning null + form stays on confirm step | ✓ |
| Lock confirmed, signature collection stalls | "Taking longer than expected" after 5 min | ⊘ deferred to Phase 6 (acknowledged) |
| Base mint reverts | Reaches failure result; "View Details" affordance present | ✓ |
| Malformed destination | Inline error from `_validateDestination` | ✓ |
| Network drops during polling | Spec says "Pause polling; show 'Reconnecting…' banner". Not implemented — polling just continues and `getStatus` returns null on failure. | ⚠ see Finding 5 |

---

## Findings

### Finding 1 — ⚠ Two § 7 microcopy violations (user-facing)

**1a.** `bridge_confirmation.dart:78`
```dart
const _StepLine(index: 2, label: "Wait for validators to sign mint attestations"),
```
§ 7 binding: "Avoid jargon: prefer 'validator signatures' over 'attestations' in user-facing copy."

Suggested fix:
```dart
const _StepLine(index: 2, label: "Wait for validators to sign your bridge"),
```
…or "Wait for validator signatures" to mirror the progress step's wording.

**1b.** `bridge_preflight_form.dart:97`
```dart
return "Must be a valid 0x EVM address (40 hex chars)";
```
§ 7 binding: "Base not EVM."

Suggested fix:
```dart
return "Must be a valid 0x Base address (40 hex chars)";
```

Both are one-line copy edits. **Recommend fixing before commit** so the spec/implementation drift doesn't compound across phases.

### Finding 2 — Provider-name guideline correctly observed
My prior verification (against an earlier state of the file) flagged "Fireblocks, MetaMask" in three places as a § 9 violation. **This is resolved** — current text in all three locations is "your DeFi provider or another Base (EVM) wallet". Good catch by the executor between my passes.

### Finding 3 — ⚠ "No derived Base address" edge case unhandled at dialog layer
§ 6 says: "User has no derived Base address (key unavailable) → Disable Bridge button; show 'Bridge unavailable — wallet not unlocked'."

The preflight model exposes `hasDerivedAddress: bool`, but the dialog doesn't check it. The user can still type their own Base address into the field and proceed. This is technically *more flexible* than the spec demands but loses the explicit "wallet not unlocked" diagnostic.

Two interpretations:
- The entry-point Bridge button (Phase 4) is supposed to be disabled in this case, so the dialog never opens. If so, this is a Phase 4 concern, not Phase 3.
- The dialog should also defensively handle the case (since the user could land here via deep link / programmatic open in future).

**Recommend**: Phase 4 must verify the entry button respects `hasDerivedAddress`. If Phase 4 handles it, this is non-blocking. If Phase 4 doesn't, this regresses.

### Finding 4 — Plan/spec "Disable Cancel in progress" resolved by removing Cancel button
UX spec § 3 says "Cancel button is disabled" during progress, alongside the "safe to close" copy. These are logically inconsistent — if it's safe to close, why disable closing?

Implementation: **no Cancel button exists** in the progress step. The dialog's top-right X is the only dismiss path and stays enabled. The "safe to close" note tells the user closing is fine. Internally coherent and matches the spirit of "the bridge continues whether you stay or leave." Sound design choice — flagging so you can confirm.

### Finding 5 — § 6 "network drops during polling" not handled
Spec wants "Pause polling; show 'Reconnecting…' banner; resume on recovery." Implementation just lets polling continue — `VbtcBridgeService.getStatus` returns null on failure and the next interval tries again. No user-visible signal that the network is degraded.

Not in the executor's stated deferrals list. Could legitimately be Phase 6 polish (similar to the "Taking longer than expected" deferral), but worth confirming with team-lead. Non-blocker for Phase 3 functionality.

### Finding 6 — `barrierDismissible: true` contradicts its own comment
In `bridge_to_base_dialog.dart` lines 38–41:
```dart
// Don't allow tap-outside-to-dismiss while a submission is in flight —
// the user can still close via the X / Cancel buttons, which the steps
// gate themselves.
barrierDismissible: true,
```
Comment says the intent is to **prevent** outside-tap dismissal during submission, but the value is `true`. `showDialog`'s param is fixed at modal-creation time; to be dynamic it'd need `PopScope` wrapping.

The `if (!mounted) return;` guards inside `_handleConfirm` prevent crashes — so functionally safe. But the behavior contradicts the stated intent. **Recommend:** either set `barrierDismissible: false` and rely on the X, or update the comment to reflect actual behavior. Non-blocker.

### Finding 7 — `BridgeProgress` failure-stage inference is heuristic
When `record.isFailed`, `_inProgressIndexAtFailure()` infers which stage was active by walking populated hashes / signature counts. The CLI doesn't tell us which stage failed, so a heuristic is necessary. Current logic:
- `baseTxHash` present → stage 4 (mint submission)
- signatures present or VFX confirmed → stage 2 (attestations)
- VFX hash present → stage 1 (confirmation)
- otherwise → stage 0 (submission)

Reasonable. Edge case: failure mid-stage might show the red X on what looks like a "done" stage. The `_FailureBox` showing `errorMessage` mitigates this. Worth a future enhancement when the CLI surfaces a failure-stage hint.

### Finding 8 — Amount display formatting (non-blocker, Phase 6)
Both `BridgeConfirmation` (`"$amount vBTC"`) and `BridgeResult._Success` (`"You now have ${record.amount} vBTC.b…"`) use Dart's default `double.toString()`. For values under ~1e-4, this can emit scientific notation. Improbable given expected bridge amounts (≥ 0.00001 vBTC) but worth a `_formatVbtc(double)` helper in Phase 6 polish.

### Finding 9 — `_handleReview(_, double, String)` discards preflight argument
The first `_` is the `BridgePreflight` (matches the callback type) but is unused. Cosmetic — works correctly. Could be renamed to `_preflight` and used to forward defensively to `_handleConfirm`, but no real bug.

---

## Quality Checks

### Lifecycle & state
- ✓ Both text controllers disposed in `dispose()`.
- ✓ All async paths guarded with `if (!mounted) return;`.
- ✓ `_firedTerminal` flag in `BridgeProgress` prevents double-firing the terminal callback.
- ✓ Post-frame callback in `_BridgeProgressState.build` ensures `onTerminal` doesn't fire mid-build (parent setState would be unsafe otherwise).
- ✓ Controllers passed in from parent dialog — values persist across step navigation (Back from confirm).
- ✓ Submit guard (`_isSubmitting`) disables Back/Close while POST in flight.

### Reactive correctness
- ✓ `bridgePreflightProvider(_args)` watched via `async.when(loading/error/data)`.
- ✓ Retry calls `ref.invalidate(bridgePreflightProvider(_args))` — correct invalidation pattern for `FutureProvider.family`.
- ✓ `bridgeOperationProvider(lockId)` watched; null treated as loading.
- ✓ Destination auto-seed only fires when user hasn't typed (`_destinationEdited` flag).
- ✓ Post-`initiateLock` calls `bridgeLockListProvider(ownerAddress).notifier.refresh()`.

### Read-only re-use for Phase 5
- ✓ `BridgeProgress(readOnly: true)` suppresses safe-to-close note and skips `onTerminal`. Phase 5 history detail can mount it without modification.

### Explorer links
- ✓ `BridgeExplorerLinks.vfxTx(hash)` uses `Env.explorerWebsiteBaseUrl` (confirmed at `lib/core/env.dart:83`).
- ✓ `BridgeExplorerLinks.baseTx(hash)` switches via `Env.isTestNet` between basescan.org and sepolia.basescan.org (confirmed at `lib/core/env.dart:103`).
- ✓ `BridgeExplorerLinks.baseAddress(address)` used for success-step destination link.

### Visual hierarchy & accessibility
- ✓ Color contrasts reasonable (white on dark with white54/38 muting for secondary info).
- ✓ Long addresses use `SelectableText` so users can copy manually if the icon misses.
- ✓ Stage icons have semantic meaning (check_circle = done, radio_button_checked = in progress, cancel = failed).

### Lint
- ✓ `fvm dart analyze lib/features/bridge/` — `No issues found!`.

---

## Quality Summary

| Dimension | Result |
|---|---|
| All steps implemented per plan? | ✓ four steps + read-only mode + explorer links |
| § 3 layout / functionality? | ✓ |
| § 6 edge cases? | ✓ most; 2 deferred (one acknowledged, one not) |
| § 7 microcopy? | ✗ 2 violations (Finding 1a, 1b) |
| § 9 resolved decisions? | ✓ provider names absent, gas constant used, retry endpoint accepted |
| Reactive correctness? | ✓ FutureProvider invalidation, StateNotifier watching, mounted guards |
| Lifecycle clean? | ✓ controllers disposed, no leaks, post-frame callback |
| Read-only re-use viable? | ✓ explicit `readOnly` flag suppresses interactivity correctly |
| Lint? | ✓ clean |

---

## Verdict

**PASS WITH WARNINGS**

Implementation is functionally complete, well-structured, lint-clean, and the reactive integration with Phase 2 providers is correct. The read-only `BridgeProgress` mode sets Phase 5 up for clean re-use, and the post-`initiateLock` list refresh ensures the history view will pick up new locks immediately. The executor already resolved my earlier provider-name concern (one less thing to fix).

**Recommended fixes before merge:**

1. **Two § 7 microcopy violations (one-line each):**
   - `bridge_confirmation.dart:78` — replace "mint attestations" with "validator signatures" (or "sign your bridge")
   - `bridge_preflight_form.dart:97` — replace "0x EVM address" with "0x Base address"

2. **Verify Phase 4 disables the entry button when `!preflight.hasDerivedAddress`** (Finding 3). If Phase 4 doesn't handle this, the § 6 "wallet not unlocked" case regresses.

**Non-blocker watch-outs (defer to Phase 6 unless team-lead disagrees):**
- § 6 "network drops during polling" → no "Reconnecting…" banner. Not in deferral list — clarify.
- `barrierDismissible: true` ↔ comment inconsistency (Finding 6).
- Amount display formatting (Finding 8).

**Cosmetic (no action needed):**
- `BridgeStep` is public, plan said `_BridgeStep`. Fine.
- "Disable Cancel in progress" resolved by removing Cancel button entirely (Finding 4) — coherent design.
- `_handleReview` discards preflight via `_` (Finding 9).
- Failure-stage inference heuristic (Finding 7).

Cleared to commit **once Finding 1a & 1b are addressed** (or once team-lead explicitly accepts the microcopy as-is).
