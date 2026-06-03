# Phase 5 Verification: Contract Creation (MPC)

**Verdict: PASS**

---

## Task 1: Add MPC ceremony methods

The plan states methods can be in WebTokenActionsManager "or a dedicated provider." The implementation calls `ExplorerService()` directly from the dialog rather than routing through WebTokenActionsManager — this is valid since the dialog is a self-contained flow and the service methods are already thin wrappers.

**File:** `lib/features/btc_web/components/web_mpc_ceremony_dialog.dart`

| Method | Endpoint Called | Status |
|---|---|---|
| Initiate ceremony | `ExplorerService().initiateV2Ceremony(ownerAddress)` | Done (line 69) |
| Poll ceremony status | `ExplorerService().getV2CeremonyStatus(ceremonyId)` | Done (line 101) |
| Create contract | `ExplorerService().createV2Contract(...)` | Done (lines 143-148) |

---

## Task 2: Create web MPC ceremony progress dialog

**File:** `lib/features/btc_web/components/web_mpc_ceremony_dialog.dart` (420 lines)

| Requirement | Status | Notes |
|---|---|---|
| Initiate ceremony on open | Done | `initState()` calls `_initiateCeremony()` (line 53) |
| Poll every 3-5 seconds | Done | `Timer.periodic(Duration(seconds: 4))` (line 94) |
| Show progress bar (0-100%) using `progress` field | Done | `LinearProgressIndicator(value: _progress / 100.0)` (line 246-249) |
| Show status message from the API | Done | Displays `_statusMessage` (lines 256-262) |
| On completion, prompt for token name/description | Done | `_CeremonyStep.promptingDetails` with text fields for name, description, ticker (lines 272-310) |
| Call createV2Contract with the ceremony ID | Done | `_createContract()` passes all params including `_ceremonyId!` (lines 143-148) |
| Show success with new token details | Done | Shows transaction hash and SC identifier with copy buttons (lines 326-379) |
| Error handling | Done | Failure step with error message and retry button (lines 382-418) |
| Handles ceremony failure/timeout status | Done | Checks for `Failed`, `failed`, `TimedOut` status (line 117) |

---

## Task 3: Wire into the web tokenize BTC screen

**File:** `lib/features/btc/screens/tokenize_btc_screen.dart` (lines 222-244)

| Requirement | Status | Notes |
|---|---|---|
| When `kIsWeb` is true, use MPC ceremony flow | Done | Line 223: `if (kIsWeb)` gates the web path |
| Create button uses MPC ceremony flow | Done | Line 241: `WebMpcCeremonyDialog.show(ownerAddress: keypair.address)` |
| Balance/keypair validation before opening | Done | Lines 229-239: checks keypair and minimum balance |

---

## Task 4: Update web token list to support new Create flow

| Requirement | Status | Notes |
|---|---|---|
| Create button works for web V2 | Done | The tokenize screen is navigable from the web wallet, and the `kIsWeb` check correctly routes to the MPC dialog |
| After creation, refresh the token list | Done | Line 371 in dialog: `ref.read(btcWebVbtcTokenListProvider.notifier).reload(widget.ownerAddress)` before closing |

---

## Summary

All 4 tasks complete. The MPC ceremony dialog is well-structured with 6 steps (initiating, polling, prompting details, creating contract, success, failure). Polls every 4 seconds with a progress bar. Prompts for token metadata after ceremony completes. Refreshes the token list on success. Error handling covers initiation failure, ceremony failure/timeout, and contract creation failure with retry capability. No issues found.
