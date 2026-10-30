# Verification Report: Recovery Phrase Input Normalization

## Summary

Standalone fix, not a phase of `plan.md` (that plan covers the vBTC V2 web wallet). Verified against the agreed scope: a correct recovery phrase typed in another form (full-width spaces or letters from a Japanese input method, line breaks or double spaces from a paste, capitalized words) is accepted on both restore paths, and a phrase that is wrong stays refused with a specific message. An independent review found one regression in the first draft (full-width `？` and `＃` mapped to ASCII would end the desktop restore's URL path and send the node a shorter phrase); it is fixed and covered by tests. Verdict: pass with warnings, all of them outside this change.

## Results

| Check | Status | Notes |
|-------|--------|-------|
| Tests pass | PASS | Full suite 800 passed, 1 failed. The failure is `test/widget_test.dart`, the Flutter template counter test, which fails on its own and is untouched here. 11 new tests in `test/features/keygen/recovery_phrase_test.dart`. |
| Matches scope | PASS | Web restore (`KeygenService.recover`) normalizes; desktop restore (`BridgeService.restoreHd`) normalizes and validates before calling the node; web shows `keygenRecoveryMnemonicInvalid` instead of the generic toast, and desktop shows it for phrases refused locally. |
| Security | PASS | Normalization never maps one valid phrase to another: only whitespace, full-width letters and case change, and every English BIP39 word is lowercase ASCII. The desktop path sends the node only phrases that pass the English BIP39 check, so the path holds only lowercase letters and single spaces. |
| Code quality | PASS | One pure helper file with tests; call sites change by one line each. |
| Scope | PASS | No unrelated changes. `.claude/launch.json` is untracked and not part of this change. |
| Integration summary | N/A | No API changes. The node endpoint `/GetRestoreHDWallet/{mnemonic}` is called as before, with a cleaner phrase. |

## Context Health

| File | Last Updated | Lines | Status |
|------|-------------|-------|--------|
| context/ROUTER.md | 2026-04-13 | 33 | Stale |
| context/architecture.md | 2026-04-13 | 52 | Stale |
| context/conventions.md | 2026-04-13 | 57 | Stale |
| context/decisions.md | 2026-04-13 | 51 | Stale |
| context/patterns/README.md | none | 44 | No date |
| context/patterns/non-owned-vbtc-v2-contracts.md | none | 40 | No date |

Every ROUTER cross-reference resolves. The context files are six months old; `/intel` would refresh them.

## Issues

### FAIL (must fix)
- None.

### WARN (should review)
- Behavior change on desktop: Core validates a phrase after collapsing spaces but derives the seed from the text as sent (`Core-CLI/VerifiedXCore/Models/HDWallet.cs:73-79`, `BIP39/Mnemonic.cs:141`), so before this change a double-spaced phrase restored a different wallet than the same phrase with single spaces. The GUI now sends single spaces, so it restores the BIP39-correct wallet. A user who restored from a double-spaced paste before has the other wallet's keys in the node already; restoring again now gives the correct wallet.
- Core's own CLI restore (`BaseCommandServices.cs`) and the `/GetRestoreHDWallet` endpoint keep that seed-from-raw-text behavior for callers other than the GUI. That fix belongs in Core.
- `lib/features/btc_web/services/btc_web_service_web.dart:82` `keypairFromMnemonic` has no live callers and does not normalize; it would need to if revived.
- `lib/features/keygen/services/keygen_service.dart:6` unused `hex` import, there before this change.

## Verdict
PASS WITH WARNINGS
