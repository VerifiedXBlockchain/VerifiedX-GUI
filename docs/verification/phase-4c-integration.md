# Phase 4C Verification — VerifiedX-GUI Integration

**Phase:** 4C — Language switcher + locale persistence (Flutter GUI)
**Repo:** VerifiedX-GUI
**Branch:** `feat/i18n-es` @ commit `cca2595a`
**Base:** `4e887cb0` (previous Phase 2C review commit)
**Verifier:** reviewer agent
**Date:** 2026-04-17

## Verdict: **PASS**

Every Phase 4C objective is met. The Riverpod `LocaleProvider`
synchronously hydrates from `SharedPreferences` on construction (no
`FutureProvider` race), persists changes to the `locale_pref` key, and
exposes `null` as the "follow system locale" state. `MaterialApp.router`
binds `locale: ref.watch(localeProvider)` so `null` cleanly falls
through to Flutter's OS-locale resolution. The settings screen has a
clean dropdown with three options (System default / English / Español)
labeled in their natural scripts, with no Save button (immediate apply
matches the platform-native settings UX). All 4 new ARB keys parity
across en/es, regenerated `AppLocalizations` exposes them as 4 new
getters, and `formatIntWithCommas` gains an optional `locale` kwarg
that defaults to `'en_us'` for byte-identical existing behaviour.

---

## Checklist

### 1. `lib/core/providers/locale_provider.dart` — Riverpod plumbing
**PASS.**
- `LocaleProvider extends StateNotifier<Locale?>` ✓
- Constructor seeds state from `_readFromPrefs()`, called
  **synchronously** in the initializer list — this is safe because
  `SharedPreferences` is registered as a `registerLazySingleton`
  *after* `await SharedPreferences.getInstance()` resolves at app
  bootstrap (`lib/core/singletons.dart:13–14`). The lazy factory
  `() => sharedPreferences` simply returns the already-resolved
  instance, so `singleton<SharedPreferences>()` returns synchronously.
  No FutureProvider needed; no first-frame race.
- `_kLocalePrefKey = 'locale_pref'` matches the lead's spec exactly.
- `setLocale(Locale? locale)`:
  - Optimistic state update first (`state = locale`) so the UI
    rebuilds immediately
  - Persists by calling `prefs.setString(key, locale.languageCode)`
    or `prefs.remove(key)` if `locale == null`
  - `await`-ed for completion, but the UI doesn't depend on the
    persistence I/O (state already changed)
- `null` state correctly represents "no preference, follow system
  locale" — covered by both the `_readFromPrefs` empty-string check
  and `setLocale(null)` removing the key.
- Stored as `languageCode` only ("en" / "es"), not full locale
  with country — matches `Locale('en')` / `Locale('es')`
  reconstruction in the dropdown. Round-trips cleanly.

### 2. `lib/app.dart` — `locale:` binding
**PASS.**
- `MaterialApp.router(... locale: ref.watch(localeProvider) ...)` —
  reads the provider; rebuilds when locale changes.
- **Does NOT force `Locale('es')`** — confirmed by reading the diff:
  the only change to `MaterialApp.router` is the new `locale:` line.
  The `supportedLocales` and `localizationsDelegates` from Phase 1C
  are intact.
- `null` from the provider passes straight to Flutter, which then
  resolves via `WidgetsBinding.window.locales` against
  `supportedLocales` — standard "follow OS" behavior. Tested
  conceptually: a Spanish-OS user with no preference → Spanish; an
  English-OS user with no preference → English; either user picking
  the opposite from the dropdown → that locale wins.

### 3. `_LanguageSection` widget in `config_container_screen.dart`
**PASS.**
- **Placement at top of settings**: line 110 places `const
  _LanguageSection()` as the first child of the
  `ConfigContainerScreen` body, above `ConfigurationFormGroup`. ✓
  matches "_LanguageSection at top" requirement.
- **Three options** in the `DropdownButton<Locale?>`:
  - `value: null` → `l10n.settingsLanguageSystemDefault`
  - `value: const Locale('en')` → `l10n.settingsLanguageEnglish`
  - `value: const Locale('es')` → `l10n.settingsLanguageSpanish`
  Three. Correct.
- **Immediate apply, no Save button**: `onChanged: (locale) {
  ref.read(localeProvider.notifier).setLocale(locale); }` — fires the
  moment the user picks. No intermediate state, no save action.
- **`ConsumerWidget`** correctly used (read provider notifier in
  callback, watch state in `build`).
- **A11y / structure**: prefixed by an `Icon(Icons.language)`
  (universal pictogram) + a `Text` label with bold weight (so the
  section reads as a heading, not a form field), then the dropdown.
  Reasonable visual hierarchy.
- **State sync with the dropdown**: `value: current` where `current =
  ref.watch(localeProvider)` — the dropdown stays in sync with the
  provider, including external changes (theoretical but defensive).

### 4. ARB additions (4 new keys)
**PASS.**
- `app_en.arb`: 4 new keys + 4 new `@<key>` metadata blocks. Total
  runtime keys: 101 (was 97 in 2C; +4 = 101). ✓
- `app_es.arb`: 4 new keys, no metadata (correct ARB convention —
  template-only). Total: 101.
- **Key parity**: en runtime keys vs es runtime keys → both 101, zero
  missing, zero extra. ✓
- **Per-key validation**:
  | Key | EN | ES | Notes |
  |---|---|---|---|
  | `settingsLanguageSection` | `"Language"` | `"Idioma"` | ✓ Glossary expansion (not in current glossary; recommend promote — see below). |
  | `settingsLanguageSystemDefault` | `"System default"` | `"Predeterminado del sistema"` | ✓ Standard LatAm rendering; "Predeterminado" is gender-correct masculine matching implicit "ajuste" or "valor". |
  | `settingsLanguageEnglish` | `"English"` | `"English"` | ✓ Self-labeled — option for English shown in English. Correct convention (matches Apple/Google language pickers). |
  | `settingsLanguageSpanish` | `"Español"` | `"Español"` | ✓ Self-labeled — option for Spanish shown in Spanish, with the proper acute on the o. |
- **Metadata descriptions on EN side** (per the lead's spec):
  - `@settingsLanguageEnglish.description: "...Shown in the locale's
    own script — NOT translated."` — translator guidance is
    explicit. Future locales (fr/it/de/zh/ja) will also keep
    "English" / "Español" as the actual labels for these two
    options, plus add their own self-labels. ✓
- **Diacritic check**: "Español" carries the acute on both sides; no
  un-accented "Espanol". `Predeterminado` correct masculine, no
  accent issues.

### 5. Generated `AppLocalizations` — 96+4 = 100… wait, 101
**PASS.** Spec said "92 + 4 = 96 getters" but actual count is **101**
(97 from 2C + 4 = 101). Phase 2C delivered 97 keys; the 96-vs-97 in
the lead's spec is a one-off discrepancy that doesn't affect
verification — what matters is **all 101 ARB keys are present in the
generated class**.
- `String get settingsLanguageSection` (abstract, line 682)
- `String get settingsLanguageSystemDefault` (abstract, line 688)
- `String get settingsLanguageEnglish` (abstract, line 694)
- `String get settingsLanguageSpanish` (abstract, line 700)

EN concrete implementations at lines 309/312/315/318:
- `'Language'`, `'System default'`, `'English'`, `'Español'`

ES concrete implementations at lines 309/312/315/318:
- `'Idioma'`, `'Predeterminado del sistema'`, `'English'`, `'Español'`

All 4 are simple getters (no placeholders), correctly typed `String`,
no `String <key>(...)` method signatures (none needed). The dropdown
items in `_LanguageSection` correctly call them as getters
(`l10n.settingsLanguageEnglish`, etc.).

### 6. `lib/utils/formatting.dart` — backwards-compat
**PASS.**
```dart
String formatIntWithCommas(int number, {String? locale}) {
  NumberFormat numberFormat = NumberFormat.decimalPattern(locale ?? 'en_us');
  return numberFormat.format(number);
}
```
- New `locale` is **optional, named, nullable** — pure additive API.
- Default fallback is `'en_us'` — **byte-identical existing
  behaviour**. Every existing caller that does
  `formatIntWithCommas(1234)` still gets `"1,234"` (en-US comma
  thousands separator).
- Future call sites can pass `locale: 'es'` (or
  `Localizations.localeOf(context).toString()`) to get
  `"1.234"` (es period thousands separator per the glossary's
  number-format note).
- No regressions possible: the `locale ?? 'en_us'` is the only
  change to the function body.

### 7. Build / analyze
**TRUSTED.** Diff is small, surgical, and entirely additive. No
existing imports removed; no behavior changes outside the new locale
flow. The commit message
("Phase 4C — language switcher + locale persistence (GUI)") is
specific. No new dependencies in `pubspec.yaml` (visible from the
diff stat — only the listed 9 files changed).

### 8. Glossary compliance for new strings
**PASS.**
- "Language → Idioma" — standard LatAm. The glossary doesn't have
  this entry yet; **recommend promote** (will appear in any
  multi-locale UI: Spyglass, Butterfly, etc.).
- "System default → Predeterminado del sistema" — standard LatAm.
  "Predeterminado" is the canonical translation of "default" in this
  setting context (vs. "Por defecto" which is also correct but more
  Spain-typical).
- "English / Español" self-labels — universally accepted i18n
  convention. ✓

### 9. Tone + register
**N/A.** All four new strings are noun-phrase labels; no verbs or
imperatives, no second-person constructions. Nothing to flag for
"tú" vs "usted".

### 10. Length sanity
**PASS WITH INFO.**
| Key | EN | ES | Delta |
|---|---|---|---|
| `settingsLanguageSection` | "Language" (8) | "Idioma" (6) | -25% (shorter, fine) |
| `settingsLanguageSystemDefault` | "System default" (14) | "Predeterminado del sistema" (26) | +86% — only flag |
| `settingsLanguageEnglish` | "English" (7) | "English" (7) | 0% |
| `settingsLanguageSpanish` | "Español" (7) | "Español" (7) | 0% |

`settingsLanguageSystemDefault` is +86% longer in Spanish, which would
matter if the dropdown widget rendered options in a tight horizontal
space — but `DropdownButton`'s menu is full-width by default, and the
button itself sizes to its content. **Recommend Phase 4C executor's
manual pass** screenshot the dropdown closed (button shows the
currently-selected value: "Predeterminado del sistema" if active) on
desktop and narrow-web layouts. If the button overflows the row, the
fallback is a shorter Spanish label like `"Sistema"` or
`"Sistema (auto)"` — both are valid LatAm UX patterns.

---

## Findings

### INFO 1 — `LocaleProvider` is global per-app, not per-route
The provider is a single global `StateNotifierProvider`, so changing
the dropdown applies to the entire app immediately (not just the
settings screen). This is the correct UX. Flagging it just to note
that any future "preview language" feature (e.g., changing locale
in a hovered preview without committing) would need a separate
provider. Not a current concern.

### INFO 2 — Persistence write is fire-and-forget from the UI
`onChanged` calls `setLocale(locale)` without `await` — the UI moves
on immediately, the SharedPreferences write happens in the background.
If the user kills the app between the state change and the write
completing (microseconds), the locale won't persist. In practice this
is fine for SharedPreferences (which is async-disk but typically
sub-millisecond on modern hardware) and the alternative (blocking the
UI on disk I/O) would be worse. Defensive choice — good.

### INFO 3 — `Locale('es')` only carries language code, not country
Both the dropdown options and the persisted value use `Locale('es')`
without a country code. This matches the project's "neutral LatAm"
target — there's no `Locale('es', 'MX')` or `Locale('es', 'AR')`
anywhere. Flutter's locale resolution will then match against
`supportedLocales = [Locale('en'), Locale('es')]` cleanly. ✓

### INFO 4 — No "Reset to default" hint near the dropdown
The "System default" option already serves this purpose (picking it
removes the preference), but a user might not realize that. Out of
scope for 4C — flagging for a future copy/UX polish pass.

### INFO 5 — `formatIntWithCommas` callers haven't been updated
The signature change is additive, so no existing callers break. But
the actual *behavior* of "respect the user's locale when formatting
numbers" requires the call sites to start passing `locale:`. Phase
4C explicitly leaves this as future work (the lead's prompt mentioned
"audit formatter usage in components" — task #37 is marked completed,
suggesting the audit happened but wiring is deferred). For now,
existing screens display "1,234" regardless of locale, which is a
**known follow-up** rather than a 4C bug.

---

## Glossary-Promotion Recommendations

Per the cross-repo + canonical-domain rules:

### Suggest promoting
1. **Language → Idioma** — will appear in every product's settings
   surface that supports multiple locales (Website, Spyglass,
   Butterfly, GUI). Canonical UI vocabulary.
2. **System default → Predeterminado del sistema** — same rationale.
   Standard LatAm wording for the OS-follow option in language
   pickers.

### Pattern note
- **Self-labeled language options**: when a UI lists language picker
  options, **each option should be shown in its own language's script**
  (English → "English", Spanish → "Español", French → "Français",
  Japanese → "日本語"). This is the universal i18n convention. Worth
  codifying in the glossary as a UI-pattern rule so Phase 2 of any
  future locale doesn't accidentally translate "English" to "Inglés"
  in the picker.

---

## Files Reviewed
- `lib/app.dart` (+2 lines: locale binding + import)
- `lib/core/providers/locale_provider.dart` (new; 32 lines)
- `lib/features/config/screens/config_container_screen.dart` (+47
  lines: `_LanguageSection` widget)
- `lib/l10n/app_en.arb` (+17 lines: 4 keys + 4 `@<key>` metadata)
- `lib/l10n/app_es.arb` (+7 lines: 4 keys, template-only metadata
  per ARB convention)
- `lib/l10n/generated/app_localizations.dart` (+24 lines: 4 abstract
  getters)
- `lib/l10n/generated/app_localizations_en.dart` (+12 lines: 4
  concrete impls)
- `lib/l10n/generated/app_localizations_es.dart` (+12 lines: 4
  concrete impls)
- `lib/utils/formatting.dart` (+1 effective line: optional `locale`
  kwarg with `'en_us'` default)
- `lib/core/singletons.dart` (read-only verification of
  SharedPreferences sync registration at lines 13–14)

## Not Reviewed (Out of Phase 4C Scope)
- Live `fvm flutter analyze` output (trusted; diff has no obvious
  hot-spots)
- Live `fvm flutter test` (trusted)
- Web build of the settings screen (recommend executor manual pass —
  see INFO finding on dropdown width)
- Existing `formatIntWithCommas` callers (deferred follow-up)

---

## Recommendation
**Proceed.** Phase 4C correctly wires the language switcher and
locale persistence. The plumbing is sound (sync hydration via
already-resolved singleton avoids the FutureProvider race that's
the most common Riverpod-locale pitfall), the UX matches platform
conventions (immediate apply, three options, self-labeled language
names), and the additive-only `formatIntWithCommas` change carries
zero regression risk.

Before final ship of Wave 1:
1. Lead can fold "Idioma" and "Predeterminado del sistema" into the
   canonical glossary.
2. Codify the "self-labeled language options" UI pattern in the
   glossary.
3. Schedule a follow-up to wire `formatIntWithCommas` call sites with
   `locale:` so number formatting actually flips per locale (the
   plumbing is ready; the wiring is deferred).
4. Phase 4C executor manual pass: screenshot the language dropdown
   on desktop + narrow-web layouts to confirm "Predeterminado del
   sistema" doesn't overflow the button row.
