# Phase 7 (Plan Phase 1): Models — Verification Report

**Plan:** vBTC V2 Transfer & Withdrawal (majestic-noodling-cloud)
**Phase:** 1 — Models
**Reviewer:** reviewer agent
**Date:** 2026-03-12
**Verdict:** PASS

---

## Checklist

### 1a. WithdrawalResult model

**File:** `lib/features/btc/models/withdrawal_result.dart` (new)

| Criteria | Status | Notes |
|----------|--------|-------|
| File exists at correct path | PASS | New file, 17 lines |
| `success` field (bool, required) | PASS | `final bool success`, required in constructor (line 2, 10) |
| `message` field (String?) | PASS | `final String? message`, optional (line 3) |
| `requestHash` field (String?) | PASS | `final String? requestHash`, optional (line 4) |
| `vfxTransactionHash` field (String?) | PASS | `final String? vfxTransactionHash`, optional (line 5) |
| `btcTransactionHash` field (String?) | PASS | `final String? btcTransactionHash`, optional (line 6) |
| `status` field (String?) | PASS | `final String? status`, optional (line 7) |
| No freezed (simple class per plan) | PASS | Plain Dart class, no code generation |
| Const constructor | PASS | `const WithdrawalResult(...)` — good practice |

### 1b. Version field on TokenizedBitcoin

**File:** `lib/features/btc/models/tokenized_bitcoin.dart` (modified, line 21)

| Criteria | Status | Notes |
|----------|--------|-------|
| `@JsonKey(name: "Version")` annotation | PASS | Matches plan exactly |
| `@Default(1)` for V1 backward compat | PASS | V1 tokens without Version field default to 1 |
| Type is `int` (non-nullable) | PASS | Correct |
| Field name is `version` | PASS | Matches plan |

### 1c. Generated files consistent

**File:** `lib/features/btc/models/tokenized_bitcoin.g.dart`

| Criteria | Status | Notes |
|----------|--------|-------|
| Deserialization reads `'Version'` key | PASS | Line 21: `json['Version'] as int? ?? 1` — nullable-safe with default |
| Serialization writes `'Version'` key | PASS | Line 36: `'Version': instance.version` |

**File:** `lib/features/btc/models/tokenized_bitcoin.freezed.dart`

| Criteria | Status | Notes |
|----------|--------|-------|
| Mixin getter for `version` | PASS | Line 44: `int get version` |
| CopyWith includes `version` | PASS | Lines 95, 138-141, 189, 232-235 |
| Constructor default value = 1 | PASS | Line 254: `this.version = 1` |
| `toString()` includes version | PASS | Line 296 |
| `==` operator includes version | PASS | Line 322 |
| `hashCode` includes version | PASS | Line 339 |
| Abstract class getter | PASS | Line 416: `int get version` |

---

## Scope Check

- Only the three expected files were modified (source + two generated)
- `withdrawal_result.dart` is a new file with no imports outside stdlib
- No V1 behavior affected — `@Default(1)` ensures existing tokens deserialize correctly
- No extra features, no unnecessary abstractions

## Issues Found

None.

## Summary

Phase 1 implementation is minimal, correct, and matches the plan exactly. The `WithdrawalResult` model has all six specified fields with correct types and nullability. The `version` field on `TokenizedBitcoin` uses the correct JSON key `"Version"`, defaults to `1` for V1 backward compatibility, and all generated files (`.freezed.dart`, `.g.dart`) are fully up to date and consistent — deserialization, serialization, copyWith, equality, and hashCode all include the new field.
