# Phase 1: vBTC → Base Bridge — Foundation (Service, Models, Constants) — Verification Report

**Phase Objective:** Stand up the data layer for the vBTC → Base bridge — constants, freezed models, and the service wrapper. No UI. Verifiable by hitting endpoints from a test harness.

**Plan ref:** `BRIDGE_TO_BASE_PHASES.md` § Phase 1
**UX ref:** `BRIDGE_TO_BASE_UX_SPEC.md` §§ 3, 6
**Reviewed:** 2026-05-18

---

## Plan Task Checklist

| Plan task | Status | Notes |
|---|---|---|
| `BRIDGE_MIN_ETH_FOR_GAS = 0.0005` in `lib/core/app_constants.dart` | ✓ | Added with explanatory comment that this is warning-only, not blocking. |
| Freezed model `BridgePreflight` matching preflight response | ✓ | All preflight fields covered + `hasNoVbtc` / `isLowOnGas(min)` convenience getters. |
| Freezed model `BridgeLockRecord` matching status response | ✓ | Includes `BridgeLockStatus` enum, raw-string parsing fallback to `unknown`, `isTerminal`/`isSuccessful`/`isFailed`/`createdAt` getters. |
| Freezed model `BridgeLockRequest` for `POST /toBase` body | ✓ | `amount` typed as `String` (matches existing CLI wallet API convention); `.fromValues(...)` convenience accepts `double`. |
| `BridgeService.preflight` | ✓ | Renamed class — see Deviation 1 below. |
| `BridgeService.initiateLock` | ✓ | After POST returns `lockId`, automatically calls `getStatus` to return a fully-populated `BridgeLockRecord` (caller-friendly). |
| `BridgeService.getStatus` | ✓ | Quiet on success (no per-poll noise), logs failures. |
| `BridgeService.getLocksByOwner` | ✓ | Uses internal `_VbtcControllerProxy` because this endpoint lives on `VBTCController`, not the wallet API. Empty list on any failure. |
| `BridgeService.retryMint` | ✓ (deviation) | Signature is `retryMint(String lockId, String ownerAddress)` — endpoint is `/retry/{lockId}/{ownerAddress}`. See Deviation 2. |
| `BridgeService.getBaseBalance` | ✓ | Handles both `num` and culture-invariant `String` balance forms. |
| `fvm dart run build_runner build --delete-conflicting-outputs` | ✓ | `.freezed.dart` + `.g.dart` files present for all three models. |
| `fvm dart analyze` clean | ✓ | Confirmed: `No issues found!` over `lib/features/bridge/` + `lib/core/app_constants.dart`. |

---

## Deviations from Plan

### Deviation 1 — Service name and filename (justified)
- **Plan:** `BridgeService` in `lib/features/bridge/services/bridge_service.dart`.
- **Actual:** `VbtcBridgeService` in `lib/features/bridge/services/vbtc_bridge_service.dart`.
- **Why:** A `BridgeService` class already exists at that exact path (`lib/features/bridge/services/bridge_service.dart`) — it's the long-standing CLI-process wrapper used in 30+ call sites (`main.dart`, `app.dart`, `session_provider.dart`, `home_buttons.dart`, etc.). Reusing the name would collide; reusing the file would force every existing caller to be re-imported.
- **Impact:** Phase 2 (providers) and downstream phases need to reference `VbtcBridgeService`, not `BridgeService`. The class header has a clear comment explaining the rename. **No blocker — rename is appropriate.**

### Deviation 2 — `retryMint` requires `ownerAddress` (verified)
- **Plan:** `Future<bool> retryMint(String lockId)` — with the note "verify exact endpoint during implementation".
- **Actual:** `Future<bool> retryMint(String lockId, String ownerAddress)` mapping to `POST /wallet/api/vbtc/bridge/retry/{lockId}/{ownerAddress}`.
- **Why:** Endpoint requires the owner address as a path parameter. Plan explicitly authorised verifying the endpoint shape during implementation.
- **Impact:** Phase 5 (history retry UI) needs to thread `ownerAddress` to the call site. **No blocker.**

### Deviation 3 — Endpoint base path
- **Plan / UX spec:** `/api/vbtc/bridge/...`
- **Actual:** `/wallet/api/vbtc/bridge/...` (with `GetBridgeLocksByOwner` on a separate `/vbtcapi/vbtc` controller).
- **Why:** Real CLI route prefixes. Code comments document this clearly.
- **Impact:** None — these are internal-to-the-service implementation details, and the documented routes match what the CLI exposes.

---

## Quality Checks

### Works against the plan's intent
- Preflight model exposes everything the dialog will need in Phase 3 (network name, contract, derived address, ETH/vBTC.b balances + their error states, gas threshold helper).
- `BridgeLockRecord` enum covers the full CLI state machine, including BTC-exit states that are out of scope for now (forward-compat — good).
- `fromUnifiedJson` cleanly absorbs the casing difference between the two CLI controllers (wallet camelCase vs `VBTCController` PascalCase). This is a real concern that the executor caught without it being explicit in the plan.

### Safety / robustness
- `getStatus` and `initiateLock` swallow exceptions and return `null` rather than throwing — appropriate for the planned UI state model (success/null path).
- `preflight` **does** rethrow on exception, deliberately so the UI can render its "couldn't reach the bridge service" retry state per spec § 3.
- `postJson` response is correctly unwrapped (`{'data': ...}`), with fallback for the case where `data` is a string requiring `jsonDecode`.
- `getBaseBalance` defensively parses both `num` and culture-invariant string forms.

### Maintainability
- Code style mirrors the existing `VbtcV2Service` (same `_log` helper signature and tag pattern). Consistent.
- `_VbtcControllerProxy` is a private internal class — well-contained, no leak.
- All public APIs have doc-comments explaining the underlying endpoint and behavior contracts.

### Performance / footprint
- No long-lived state, no caches, no timers. Pure request/response wrapper — appropriate for Phase 1.

---

## Minor Observations (non-blocking)

1. **`createdAt` timestamp assumes seconds.** `BridgeLockRecord.createdAt` multiplies `createdAtUtc` by 1000 — assuming the CLI emits Unix seconds. Worth confirming against a real response in Phase 2/3 integration; if the CLI sends millis, the getter will produce dates in the far future. Easy to spot during manual verification.

2. **Terminal-state set includes `expired`.** Plan called out `Minted`, `MintedOnBase`, `Failed`. Implementation also treats `Expired` as terminal — reasonable extension, but worth noting in case Phase 2 polling logic was designed strictly off the plan's three states.

3. **`debugPrint` verbosity.** Pretty-printed JSON dumps on every preflight / initiateLock / retry call. Matches `VbtcV2Service` precedent but will be noisy in console once the feature is in active use. Acceptable for now.

4. **`amount.toString()` for transmission.** Uses Dart's default `double.toString()` which renders `0.1` as `"0.1"`. CLI parses with InvariantCulture, so this is fine. Watch for edge cases with very small amounts (scientific notation kicks in below ~1e-4 with certain `double`s) — `amount.toStringAsFixed(8)` might be a safer wire format. Non-blocker for Phase 1 since the form layer in Phase 3 can format before constructing the request.

5. **No unit tests.** Plan explicitly says "Verifiable by manually hitting endpoints from a test harness" — tests are not required for this phase. Flagging for awareness only.

---

## Verdict

**PASS WITH WARNINGS**

All plan tasks are implemented, `fvm dart analyze` is clean, freezed/json codegen ran successfully, and the deviations are all well-justified and clearly documented in code comments. The two non-trivial deviations (`VbtcBridgeService` rename, `retryMint` signature) should be communicated to downstream phases (Phase 2 providers, Phase 5 history retry) so the executors use the actual API surface rather than the plan-as-written.

Nothing here is a blocker. The foundation is sound.
