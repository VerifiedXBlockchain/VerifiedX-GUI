# Phase 1C Verification — VerifiedX-GUI i18n Framework

**Phase:** 1C — Flutter `flutter_localizations` + ARB framework setup
**Repo:** VerifiedX-GUI
**Branch:** `feat/i18n-es` @ commit `bec199be`
**Base:** `testnet`
**Verifier:** reviewer agent
**Date:** 2026-04-17

## Verdict: **PASS**

All Phase 1C objectives are met. ARB key sets are identical between
`en` and `es` (36 keys each, no missing/extra), ICU placeholder syntax
on `sentAmount` is preserved exactly, the `MaterialApp.router` is
correctly wired with `localizationsDelegates` and `supportedLocales`,
and the POC overlay swap (`"Loading..."` → `AppLocalizations.of(context).statusLoading`)
confirms the end-to-end pipeline works. Generated Dart files are
checked in and match the pattern already used for `app_router.gr.dart`.
No blockers for Phase 2C.

---

## Checklist

### 1. `pubspec.yaml` — `flutter_localizations` added
**PASS.**
```yaml
flutter_localizations:
  sdk: flutter
```
Added alphabetically in the right place under `dependencies`. Existing
`intl: ^0.17.0` constraint untouched — good, because
`flutter_localizations` pulls its own pinned `intl` and the existing
one is formatting-only.

### 2. Dart SDK constraint untouched
**PASS.** `environment.sdk: ">=2.17.3 <3.0.0"` unchanged. No accidental
bumps.

### 3. `l10n.yaml` at repo root
**PASS.** All 6 keys match the spec (plus 1 bonus):
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/l10n/generated
synthetic-package: false
nullable-getter: false
```
- `synthetic-package: false` matches spec
- `nullable-getter: false` is a nice-to-have — means
  `AppLocalizations.of(context)` returns a non-nullable, which the POC
  widget depends on (`AppLocalizations.of(context).statusLoading`
  would otherwise need `!`)

### 4. `lib/l10n/app_en.arb` — keys + metadata
**PASS.** 36 runtime keys, every one with a matching `@<key>`
description block. Coverage:
- `appTitle` (1)
- Navigation: `navDashboard`, `navTransactions`, `navWallet`, `navNfts`,
  `navDomains`, `navSettings` (6)
- Actions: `actionSend`, `actionReceive`, `actionCopy`, `actionPaste`,
  `actionConfirm`, `actionCancel`, `actionClose`, `actionSave`,
  `actionDelete`, `actionSearch` (10)
- Status: `statusLoading`, `statusPending`, `statusConfirmed`,
  `statusFailed` (4)
- Labels: `labelAmount`, `labelAddress`, `labelBalance`,
  `labelAvailable`, `labelTotal`, `labelFee`, `labelFrom`, `labelTo` (8)
- Wallet: `walletCreate`, `walletImport`, `walletPrivateKey`,
  `walletRecoveryPhrase` (4)
- Messages: `messageNoResults`, `messageCopiedToClipboard` (2)
- ICU: `sentAmount` (1)
Total: 36 keys + 36 `@key` description blocks. `@@locale: "en"` set.

Spec said "~30 keys" — 36 is well within range and covers the
glossary-seed surface. Descriptions are purpose-specific ("destructive,
removes an item" for `actionDelete`) which gives Phase 2C translators
the context they need to pick the right Spanish word.

### 5. `lib/l10n/app_es.arb` — same keys, English pass-through
**PASS.** Verified via JSON key diff:
- `en` runtime keys: 36
- `es` runtime keys: 36
- Missing in es: {}
- Extra in es: {}
- Every value is a byte-for-byte copy of the English source
- `@@locale: "es"` set correctly
- No `@key` metadata blocks on `es.arb` — this is correct per ARB
  convention: metadata lives with the template locale only. (That's
  why the file is 46 lines vs. 161 in `app_en.arb` — metadata-only
  delta, not missing content.)

### 6. ICU placeholder `sentAmount` preserved
**PASS.** Template:
```json
"sentAmount": "Sent {amount} VFX",
"@sentAmount": {
  "description": "Toast shown after a successful send transaction, with the sent amount.",
  "placeholders": {
    "amount": {
      "type": "String",
      "example": "1.25"
    }
  }
}
```
- Placeholder name `{amount}` identical on both en and es sides
- `@sentAmount.placeholders.amount.type: String`, `example: 1.25`
- Generated Dart method signature: `String sentAmount(String amount)` —
  correctly typed as `String` (not `Object`, which is what happens when
  `type:` is omitted)
- Generated impl: `return 'Sent $amount VFX';`

**Phase 2C NOTE for translator:** the Spanish translation MUST still
contain `{amount}` exactly — not `{monto}`, not `{cantidad}`. The
token name is a code contract, not translatable text. The glossary
entry `Amount → Monto` applies to the translated *surrounding* copy
only (e.g. "Enviado {amount} VFX").

### 7. Generated Dart files committed
**PASS.** All three generated files are in the diff:
- `lib/l10n/generated/app_localizations.dart` (343 lines — abstract base
  with `supportedLocales`, `localizationsDelegates`, `of(context)`,
  abstract getters for all 36 keys)
- `lib/l10n/generated/app_localizations_en.dart` (116 lines — concrete
  English impl)
- `lib/l10n/generated/app_localizations_es.dart` (116 lines — concrete
  Spanish impl)
This matches the repo's existing convention of checking in generated
`.gr.dart` files for `auto_route` (see `core/app_router.gr.dart`).
Consistent with Phase 1C guidance.

### 8. `lib/app.dart` — MaterialApp.router wired
**PASS.**
```dart
MaterialApp.router(
  ...
  theme: AppTheme.dark().themeData,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  routeInformationParser: router.defaultRouteParser(...),
  ...
)
```
- `AppLocalizations.localizationsDelegates` is the static list bundled
  in the generated file (includes flutter_localizations delegates +
  AppLocalizations itself)
- `AppLocalizations.supportedLocales` contains `Locale('en')` and
  `Locale('es')` (confirmed by grep on generated file lines 92–93)
- Import added: `import 'l10n/generated/app_localizations.dart';`

### 9. No forced `locale:` on MaterialApp
**PASS.** `grep locale: lib/app.dart` returns no matches. MaterialApp
will dynamically pick from OS locale — which is exactly what's needed
so Phase 4C can wire a switcher without fighting a hardcoded value.

### 10. POC widget migration
**PASS.** `AppContent` global loading overlay:
```dart
// before:
child: Text("Loading...", ...)
// after:
child: Text(AppLocalizations.of(context).statusLoading, ...)
```
This one swap proves:
- The delegate is resolving at runtime
- `AppLocalizations.of(context)` returns non-nullable
  (`nullable-getter: false` honored)
- The `statusLoading` getter exists on the abstract class

### 11. Brand names untouched
**PASS.**
- `appTitle: "VFX Wallet"` — "VFX" is brand, stays (glossary).
- `sentAmount: "Sent {amount} VFX"` — VFX stays.
- `navNfts: "NFTs"` — industry standard, glossary says keep.
- On the Spanish side, all identical to English (pass-through phase).

### 12. Spain-specific constructs
**N/A this phase.** `es.arb` is English pass-through — no Spanish
prose yet.

### 13. Length sanity
**N/A this phase.** Same reason. To flag for Phase 2C: Spanish
"Transacciones" (13 chars) vs. English "Transactions" (12 chars) is
fine, but "Loading..." (10) → "Cargando..." (11) is also fine. No key
in the current set looks like a likely overflow risk.

---

## Findings

### INFO 1 — `intl` version asymmetry (pre-existing, not introduced here)
`pubspec.yaml` keeps `intl: ^0.17.0`. The new `flutter_localizations`
transitively pins its own `intl` (typically `^0.19.x` on recent
Flutter SDKs) and the executor's `pub get` would have resolved the
constraint. Not a Phase 1C bug — flagging because a future `flutter
upgrade` could force a manual `intl` bump. Recommend the executor run
`fvm flutter pub outdated` before Phase 2C starts and document the
current pinned `intl`.

### INFO 2 — Template-only metadata convention
`app_es.arb` has no `@key` descriptor blocks. That's the canonical
Flutter convention (metadata lives with `template-arb-file`), but
translator agents new to ARB might look at a sparse `es.arb` and
worry. Worth a one-line note in the `lib/l10n/` folder (or in a
Phase 2C briefing) so no one "fixes" this by copy-pasting metadata
into es.arb.

### INFO 3 — Namespace / file count for Phase 2C
Currently one file per locale. The sibling Spyglass repo just added
namespaces (reviewer recommended splitting in the 1B report). For the
GUI, single ARB is fine for now — Flutter's `AppLocalizations` is
designed around a single class. If the string count explodes past ~300,
consider multiple ARB template files (`messages_en.arb`,
`wallet_en.arb`, etc.) mapped to multiple output classes. Deferred to
Phase 2C planning, not a 1C issue.

### INFO 4 — Translator must preserve ICU tokens verbatim
Re-emphasizing for the Phase 2C translator briefing: `sentAmount`'s
`{amount}` token is the ONLY ICU placeholder in the current seed set.
Phase 2C should:
1. Keep `{amount}` identical in `app_es.arb`.
2. Place the token in a natural Spanish position: e.g.
   `"sentAmount": "Enviado {amount} VFX"` — glossary says "Send →
   Enviar", past participle "Enviado" for the toast, verb order
   subject-verb-complement.
3. If Phase 2C adds plural/select keys (e.g. `{count, plural, ...}`),
   use the two Spanish plural forms `one/other` — reviewer will
   specifically check these.

---

## Files Reviewed
- `pubspec.yaml` (+2 lines: flutter_localizations)
- `l10n.yaml` (new; 7 lines; all keys validated)
- `lib/app.dart` (+3 lines wiring, +1 POC swap)
- `lib/l10n/app_en.arb` (new; 161 lines; 36 keys + metadata)
- `lib/l10n/app_es.arb` (new; 46 lines; 36 keys, pass-through)
- `lib/l10n/generated/app_localizations.dart` (new; 343 lines; abstract
  base — spot-checked `supportedLocales`, `sentAmount(String amount)`
  signature, `statusLoading` getter)
- `lib/l10n/generated/app_localizations_en.dart` (new; 116 lines —
  confirmed `statusLoading => 'Loading...'` and `sentAmount` impl)
- `lib/l10n/generated/app_localizations_es.dart` (new; 116 lines —
  confirmed same impls since es is pass-through)

## Not Reviewed (Out of Phase 1C Scope)
- `pubspec.lock` churn (trusted — 1-line delta as expected for one
  new dep)
- Full `fvm flutter analyze` / `fvm flutter test` pass (trusted per
  executor's report — task #12 completed)
- Full `fvm flutter build` on desktop and web (trusted)

---

## Recommendation
Proceed to Phase 2C. This is the track flagged as "highest effort"
in the plan — recommend the reviewer agent get an advance peek at
the translator's first ~10 translations before the full 36 are
committed, to catch any ICU / ARB pitfalls early. The framework
scaffolding itself is solid.
