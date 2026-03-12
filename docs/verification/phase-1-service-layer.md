# Phase 1 Verification: Service Layer — VbtcV2Service

**Verdict: PASS**

**File reviewed:** `lib/features/btc/services/vbtc_v2_service.dart`

---

## Checklist

| Requirement | Status | Notes |
|-------------|--------|-------|
| New file at correct path | PASS | `lib/features/btc/services/vbtc_v2_service.dart` |
| Extends `BaseService` | PASS | Line 4 |
| `apiBasePathOverride: "/vbtcapi/vbtc"` | PASS | Line 5 |
| `initiateCeremony(ownerAddress)` — POST `/InitiateMPCCeremony/{address}` | PASS | Lines 7-29, returns `ceremonyId` on success |
| `getCeremonyStatus(ceremonyId)` — GET `/GetCeremonyStatus/{id}` | PASS | Lines 31-49, returns full result map |
| `createContract({ownerAddress, name, description, ticker, ceremonyId})` — POST `/CreateVBTCContract` | PASS | Lines 51-91, returns `Hash` on success |
| Error handling: `result['Success'] == true` check | PASS | All three methods |
| Error handling: `Toast.error()` on failure | PASS | `initiateCeremony` and `createContract` show toast; `getCeremonyStatus` omits toast in catch (correct — polled method) |
| Error handling: return `null` on failure | PASS | All three methods |
| Follows `BaseService` + Dio pattern from `BtcService` | PASS | Consistent use of `postJson`/`getJson`, `cleanPath: false`, `inspect: true` on writes |
| No existing files modified | PASS | Only new file added |

## Pattern Compliance

The implementation closely follows the `BtcService` reference pattern:

- **Constructor:** `VbtcV2Service() : super(apiBasePathOverride: "/vbtcapi/vbtc")` mirrors `BtcService() : super(apiBasePathOverride: "/btcapi/BTCV2")`
- **POST methods** use `postJson` with `cleanPath: false` and `inspect: true`, consistent with `BtcService.tokenizeBtc()` and `BtcService.withdrawCoin()`
- **GET method** uses `getJson` with `cleanPath: false`, consistent with `BtcService` GET methods
- **Error handling** follows try/catch with print + Toast.error + return null, matching the existing pattern
- **Imports** are minimal and appropriate: only `Toast` and `BaseService`

## Design Notes

- `getCeremonyStatus` returns `Map<String, dynamic>?` rather than a typed model. This is correct for Phase 1 since the `MpcCeremony` freezed model is introduced in Phase 2.
- `getCeremonyStatus` intentionally omits `Toast.error()` in the catch block (unlike the other two methods). This is good design since this method will be polled repeatedly by the ceremony provider (Phase 3), and transient network errors during polling should not spam the user with toasts. The provider will handle retry logic.
- `createContract` checks for both `Success == true` and `containsKey('Hash')` before returning, which is defensive and consistent with `BtcService.tokenizeBtc()`.

## No Regressions

No existing files were modified. The new service is self-contained and has no side effects on existing code.
