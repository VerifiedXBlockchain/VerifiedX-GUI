# Phase 1: Models — Verification Report

**Plan:** vBTC V2 Transfer & Withdrawal (majestic-noodling-cloud)
**Phase:** 1 — Models
**Reviewer:** reviewer agent
**Date:** 2026-03-12
**Verdict:** PASS

---

## Checklist

### 1a. WithdrawalResult model

| Criteria | Status | Notes |
|----------|--------|-------|
| New file at `lib/features/btc/models/withdrawal_result.dart` | PASS | File exists as expected |
| `success` field (bool) | PASS | `final bool success`, required in constructor |
| `message` field (String?) | PASS | `final String? message`, optional |
| `requestHash` field (String?) | PASS | `final String? requestHash`, optional |
| `vfxTransactionHash` field (String?) | PASS | `final String? vfxTransactionHash`, optional |
| `btcTransactionHash` field (String?) | PASS | `final String? btcTransactionHash`, optional |
| `status` field (String?) | PASS | `final String? status`, optional |
| No freezed (simple class) | PASS | Plain Dart class, no code generation needed |
| Const constructor | PASS | Constructor is `const`, good practice |

### 1b. Version field on TokenizedBitcoin

| Criteria | Status | Notes |
|----------|--------|-------|
| `@JsonKey(name: "Version")` annotation | PASS | Matches plan exactly |
| `@Default(1)` for backward compat | PASS | V1 tokens without Version field will default to 1 |
| Type is `int` | PASS | Correct |
| Generated files updated | PASS | Both `.freezed.dart` and `.g.dart` contain `version` field |
| JSON deserialization correct | PASS | `tokenized_bitcoin.g.dart:21` reads `json['Version'] as int? ?? 1` |
| JSON serialization correct | PASS | `tokenized_bitcoin.g.dart:36` writes `'Version': instance.version` |

---

## Scope Check

- No files modified outside of plan scope
- No V1 behavior affected (default value ensures backward compatibility)
- No extra features or unnecessary abstractions added

## Issues Found

None.

## Summary

Phase 1 implementation is minimal, correct, and matches the plan exactly. The `WithdrawalResult` model has all six specified fields with correct types and nullability. The `version` field on `TokenizedBitcoin` uses the correct JSON key name, defaults to 1 for V1 backward compatibility, and the generated files are up to date.
