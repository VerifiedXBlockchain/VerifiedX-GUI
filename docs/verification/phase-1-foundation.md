# Phase 1: vBTC → Base Bridge — Foundation (Service, Models, Constants) — Verification Report

**Phase Objective:** Stand up the data layer for the vBTC → Base bridge — constants, freezed models, and the service wrapper. No UI. Verifiable by manual endpoint hits.

**Plan ref:** `BRIDGE_TO_BASE_PHASES.md` § Phase 1
**UX ref:** `BRIDGE_TO_BASE_UX_SPEC.md` § 8 (CLI/API surface) + § 3 (consumer of these models)
**CLI cross-checked against:**
- `ReserveBlockCore/Controllers/WalletController.cs` (`[Route("wallet")]`)
- `ReserveBlockCore/BrowserWalletServices/WalletVbtcService.cs`
- `ReserveBlockCore/BrowserWalletServices/WalletDtos.cs` (`VBTCBridgeToBaseRequest`)
- `ReserveBlockCore/Bitcoin/Controllers/VBTCController.cs` (`[Route("vbtcapi/[controller]")]`)
- `ReserveBlockCore/Bitcoin/Models/BridgeLockRecord.cs`

**Reviewed:** 2026-05-18

> Note: this filename overwrites a 2026-03-24 verification report from the privacy/prism Phase 1. That content is archived in git history.

---

## Plan Task Checklist

| Plan task | Status | Notes |
|---|---|---|
| `BRIDGE_MIN_ETH_FOR_GAS = 0.0005` in `lib/core/app_constants.dart` | ✓ | Comment explains it's warning-only, not blocking. |
| `BridgePreflight` freezed model | ✓ | 17 fields, all matching CLI projection. Includes `hasNoVbtc` / `isLowOnGas(min)` getters. |
| `BridgeLockRecord` freezed model | ✓ | Includes `BridgeLockStatus` enum, raw-string parsing fallback to `unknown`, `isTerminal`/`isSuccessful`/`isFailed`/`createdAt` getters. |
| `BridgeLockRequest` freezed model | ✓ | `amount` typed `String` (matches CLI `VBTCBridgeToBaseRequest.Amount` which is also `string`). `.fromValues(...)` convenience accepts `double`. |
| `VbtcBridgeService.preflight` | ✓ | Rethrows on exception so UI can render retry state. |
| `VbtcBridgeService.initiateLock` | ✓ | Follows POST with auto `getStatus(lockId)` to return a populated record. |
| `VbtcBridgeService.getStatus` | ✓ | Quiet on success (no per-poll noise). |
| `VbtcBridgeService.getLocksByOwner` | ✓ | Uses internal `_VbtcControllerProxy` (different controller). Empty list on any failure. |
| `VbtcBridgeService.retryMint(lockId, ownerAddress)` | ✓ | Two-arg signature confirmed against CLI route. |
| `VbtcBridgeService.getBaseBalance` | ✓ | Handles both `num` and culture-invariant `String` balance forms. |
| `fvm dart run build_runner build --delete-conflicting-outputs` | ✓ | `.freezed.dart` + `.g.dart` present for all three models. |
| `fvm dart analyze` clean | ✓ | `No issues found!` over `lib/features/bridge/` + `lib/core/app_constants.dart`. |

---

## Executor Deviation Validation

### Deviation 1 — Class renamed `BridgeService` → `VbtcBridgeService` (filename `vbtc_bridge_service.dart`)
**Verdict: SOUND.** An existing `BridgeService` (the CLI process wrapper) already lives at `lib/features/bridge/services/bridge_service.dart` and is referenced in 30+ places (`main.dart`, `app.dart`, `session_provider.dart`, `home_buttons.dart`, validator providers, etc.). The rename was unavoidable. Header doc-comment explains the collision. **Confirmed no regression:** `git diff HEAD -- lib/features/bridge/services/bridge_service.dart` produces no output.

### Deviation 2 — `apiBasePathOverride` is `/wallet/api/vbtc/bridge`
**Verdict: CORRECT.** `WalletController` is decorated `[Route("wallet")]`, and each bridge endpoint is `[HttpGet("api/vbtc/bridge/...")]` — so the full path is `/wallet/api/vbtc/bridge/...`. The plan and UX spec wrote `/api/vbtc/bridge/...` informally. The executor's path is the real one.

### Deviation 3 — `getLocksByOwner` uses internal `_VbtcControllerProxy`
**Verdict: SOUND, pattern correctly followed.** `VBTCController` is decorated `[Route("vbtcapi/[controller]")]`, producing `/vbtcapi/vbtc/...`. The proxy mirrors exactly the `VbtcV2Service` setup (`apiBasePathOverride: "/vbtcapi/vbtc"`). Private nested class is appropriate (no other consumers).

### Deviation 4 — `initiateLock` calls `getStatus` after POST
**Verdict: SOUND.** Wallet `/toBase` returns a sparse `{success, lockId, ...}` envelope (confirmed in `WalletVbtcService.BridgeToBase`). The follow-up `getStatus` hydrates a full `BridgeLockRecord` matching the polling shape — caller never has to special-case the initial record vs. polled records. Good API design.

### Deviation 5 — `BridgeLockRecord.fromUnifiedJson` handles dual casing
**Verdict: SOUND for casing — but see Finding 1 (status enum serialization).** The two CLI sources do indeed return different casings:
- `WalletVbtcService.GetBridgeLockStatus` projects to an anonymous lowercase object (`lockId`, `scUID`, …, explicit `status = record.Status.ToString()`).
- `VBTCController.GetBridgeLocksByOwner` serializes raw `BridgeLockRecord` instances with `JsonConvert.SerializeObject(...)` — PascalCase property names (`LockId`, `SmartContractUID`, …).

The `pick(['lower', 'Pascal'])` pattern handles every field cleanly. `signaturesCollected` is helpfully derived from `signatures.length` when the by-owner payload doesn't pre-aggregate the count.

### Deviation 6 — `retryMint(String lockId, String ownerAddress)`
**Verdict: CORRECT.** Route confirmed: `[HttpPost("api/vbtc/bridge/retry/{lockId}/{ownerAddress}")]`, method `VBTCBridgeRetry(string lockId, string ownerAddress)`, service call `WalletVbtcService.RetryBridgeMint(lockId, ownerAddress)`. Plan explicitly authorised verifying the shape during implementation. Phase 5 history retry must thread `ownerAddress` to the call.

---

## CLI Cross-Validation

### Preflight (lowercase JSON projection) — all 17 fields covered
| CLI field (lowercase) | Dart `@JsonKey` | Status |
|---|---|---|
| success | success | ✓ |
| message (on error) | message | ✓ |
| ownerAddress | ownerAddress | ✓ |
| scUID | scUID | ✓ |
| availableVbtc | availableVbtc | ✓ |
| vbtcError | vbtcError | ✓ |
| derivedBaseAddress | derivedBaseAddress | ✓ |
| hasDerivedAddress | hasDerivedAddress | ✓ |
| ethBalance | ethBalance | ✓ |
| ethError | ethError | ✓ |
| vbtcBBalance | vbtcBBalance | ✓ |
| vbtcBError | vbtcBError | ✓ |
| bridgeConfigured | bridgeConfigured | ✓ |
| canReadEth | canReadEth | ✓ |
| canReadVbtc | canReadVbtc | ✓ |
| networkName | networkName | ✓ |
| chainId | chainId | ✓ |
| contractAddress | contractAddress | ✓ |

### Status endpoint (lowercase JSON, anonymous projection) — all projected fields covered
- All 20 projected lowercase fields are present in `BridgeLockRecord`.
- `status` is sent as `record.Status.ToString()` — i.e., `"Locked"`, `"Minted"`, etc. The Dart `bridgeLockStatusFromString` switch matches all 17 enum names exactly. ✓
- BTC-exit projection fields (`btcExitDestination`, `btcExitTxHash`) are NOT included in the wallet status projection — Dart model declares them nullable, so calls via `status` will leave them perpetually null. Fine since BTC-exit is out of scope for Phase 1, and the by-owner endpoint does include them.

### `VBTCBridgeToBaseRequest` (POST body)
```csharp
public class VBTCBridgeToBaseRequest {
    public string ScUID;
    public string OwnerAddress;
    public string Amount;
    public string EvmDestination;
}
```
Dart `BridgeLockRequest` matches exactly with `@JsonKey` overrides (lowercase first-letter `scUID`/`ownerAddress`/`amount`/`evmDestination`). ✓

`.fromValues(amount: double)` formats via `amount.toString()`. CLI parses with `decimal.TryParse(..., InvariantCulture)` (verified in `WalletController.VBTCBridgeToBase` → `decimal.TryParse(req.Amount, NumberStyles.Float, CultureInfo.InvariantCulture, out var amount)` per the wallet helper convention). ✓ — but see Finding 3 about scientific notation.

### `BridgeLockStatus` enum mapping
CLI: `Locked=0, ProofSubmitted=1, …, Expired=16` (17 values).
Dart: all 17 enum cases + `unknown` fallback. Order/index alignment matters **only if the wire format ever sends ints** — see Finding 1.

---

## Findings

### Finding 1 — ⚠️ PHASE-5 RISK: `GetBridgeLocksByOwner` likely emits `Status` as integer

**Severity:** High for Phase 5; invisible in Phase 1.

The CLI by-owner endpoint serializes raw `BridgeLockRecord` instances with `JsonConvert.SerializeObject(...)`. **No `StringEnumConverter` is registered globally** in the CLI (confirmed: `grep -rn "StringEnumConverter\|JsonConvert.DefaultSettings"` returned zero matches in `ReserveBlockCore/`). Newtonsoft.Json defaults to **integer** serialization for enums. So `Status` will arrive as `"Status": 0` for Locked, not `"Status": "Locked"`.

The Dart model declares `@JsonKey(name: "status") String? statusRaw`, and `fromUnifiedJson` passes `pick(['status', 'Status'])` directly into `BridgeLockRecord.fromJson({...})`. The generated `_$BridgeLockRecordFromJson` does `statusRaw: json['status'] as String?`, which throws a `TypeError` casting `int` to `String?`. **`getLocksByOwner` catches that exception and silently drops the row, logging `Failed to parse lock entry: ...` to debugPrint.**

Net effect: when Phase 5 wires up the history view, **every entry will be silently dropped** and the user will see an empty history even with confirmed bridges in the DB. Phase 1 is unaffected because no UI consumes `getLocksByOwner` yet.

The wallet `getStatus` endpoint is safe — it explicitly calls `record.Status.ToString()`.

**Recommended fix in `fromUnifiedJson`** (1–2 lines):
```dart
final rawStatus = pick(['status', 'Status']);
final statusForJson = rawStatus is int
    ? (rawStatus >= 0 && rawStatus < BridgeLockStatus.values.length
        ? _statusEnumWireName(BridgeLockStatus.values[rawStatus])
        : null)
    : rawStatus;
// then pass statusForJson into the fromJson map under 'status'
```
…with a small `_statusEnumWireName` helper that returns the CLI-style PascalCase name (`Locked`, `ProofSubmitted`, etc.) for a given enum value. Or, simpler: ask the CLI team to wrap `BridgeLockRecord` in an anonymous lowercase projection (matching the status endpoint) before returning from `GetBridgeLocksByOwner`.

Either way, this needs handling before Phase 5 ships.

### Finding 2 — Missing fields from `BridgeLockRecord` (non-blocking)
The CLI model declares three fields not surfaced in the Dart record:
- `BtcExitAmountSent : decimal?` — only set during BTC-exit flow (out of scope per spec).
- `BtcExitFeePaid : decimal?` — same.
- `Id : long` (LiteDB `[BsonId]`) — internal storage key, never useful client-side.

The by-owner endpoint includes them in its raw serialization; Dart's `fromJson` ignores unknown keys by default. **No action needed for Phase 1.** Worth noting if/when BTC-exit gets added to the UI.

### Finding 3 — `amount.toString()` can emit scientific notation
For very small `double` values (e.g., `1e-7`), `Double.toString()` may render `"1e-7"`. C# `decimal.TryParse("1e-7", NumberStyles.Float, ...)` does succeed for that exact form, but `NumberStyles.AllowExponent` must be in the parse flags for it to work. Worth verifying — and Phase 3's form-layer formatting (e.g., `toStringAsFixed(8)`) would side-step the question entirely. **Non-blocker for Phase 1.**

### Finding 4 — `createdAt` getter assumes seconds (non-blocking, easy to verify)
`BridgeLockRecord.createdAt` multiplies `createdAtUtc` by 1000 to construct the `DateTime`. The CLI uses `TimeUtil.GetTime()` for `CreatedAtUtc` — that helper returns **Unix seconds** in this codebase (confirmed by precedent in `BridgeLockRecord.cs` where `FinalizedAtUtc` is compared with second-resolution logic). So the multiplier is correct. ✓

### Finding 5 — `isTerminal` includes `expired` (intentional extension)
Plan named only `Minted`, `MintedOnBase`, `Failed` as terminal. The CLI enum includes `Expired = 16` which clearly belongs in the terminal set. Phase 2's polling loop should respect this — flagging so the next executor doesn't over-poll expired locks. Non-blocker; correct extension.

### Finding 6 — Style alignment with `VbtcV2Service` (positive)
The new service mirrors `VbtcV2Service` exactly:
- Same `_tag` + `_log` helper signature
- Same `BaseService` extension pattern with `apiBasePathOverride`
- Same `cleanPath: false` discipline for path-parameter endpoints
- Same try/catch + debugPrint pattern
Consistency is good. Maintainer-friendly.

---

## Quality Summary

| Dimension | Result |
|---|---|
| Works against plan? | ✓ all 12 plan tasks implemented |
| Matches CLI contract? | ✓ paths, body, projection fields all confirmed; ⚠ status enum serialization risk on by-owner endpoint |
| Safe? | ✓ exceptions caught/rethrown appropriately for UI patterns; no auth leakage; no destructive operations |
| Maintainable? | ✓ matches existing project patterns; well-commented; deviations documented inline |
| Performant? | ✓ no caches, timers, or long-lived state — pure request wrapper |
| Test coverage? | n/a — plan explicitly says manual harness verification |

---

## Verdict

**PASS WITH WARNINGS**

All Phase 1 plan tasks are implemented, `fvm dart analyze` is clean, freezed/json codegen ran, every executor deviation has been validated against the CLI and is sound, and the generic `BridgeService` is untouched. The CLI route paths, request/response shapes, and enum/projection mappings all match.

**Three things downstream phases must know:**

1. **Phase 5 (history view) will see empty history** unless `fromUnifiedJson` is taught to handle integer-valued `Status` from `GetBridgeLocksByOwner` (Finding 1). Two-line fix; could be added in Phase 1 cleanup or Phase 5 setup.
2. Class is `VbtcBridgeService`, not `BridgeService`. Phase 2 providers must import the renamed class.
3. `retryMint` requires `ownerAddress` — Phase 5's retry button needs to thread it.

Nothing in this phase is a blocker. Foundation is sound; the by-owner enum issue is a real risk that's invisible until Phase 5 — flag now so it doesn't get missed.
