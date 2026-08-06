# Phase 2C Tier 1 Verification — VerifiedX-GUI Spanish Translation

**Phase:** 2C Tier 1 — Spanish translation of 97 ARB keys covering
send / receive / transactions / home / settings
**Repo:** VerifiedX-GUI
**Branch:** `feat/i18n-es` @ commit `33cba6ef`
**Base:** `71018080` (previous Phase 1C review commit)
**Verifier:** reviewer agent
**Date:** 2026-04-17

## Verdict: **PASS**

All Phase 2C Tier 1 objectives are met. Key sets are identical across
both ARB files (97/97, zero missing/extra), every ICU/placeholder
token is preserved byte-for-byte on both sides, the regenerated
`AppLocalizations` class contains a method or getter for every
runtime key, glossary compliance is strong (Send→Enviar,
Receive→Recibir, Settings→Configuración, Wallet→Billetera [zero
Cartera], Balance→Saldo, Pending→Pendiente, Confirmed→Confirmada,
Failed→Fallida, Address→Dirección, Amount→Monto, Fee→Comisión), tone
is consistently "tú" informal, diacritics are correct, and inverted
`¿` / `¡` punctuation is respected in all three Spanish interrogative
strings. Tier-1 scope is explicitly declared in the commit message;
remaining ~1100+ keys are an acknowledged Phase 2C-extension backlog.

---

## Checklist

### 1. Key completeness — `app_en.arb` vs `app_es.arb`
**PASS.** JSON structural diff of runtime keys (excluding `@<key>`
metadata):
- `en` runtime keys: 97
- `es` runtime keys: 97
- Missing in `es`: 0
- Extra in `es`: 0
- `@@locale` correctly set on both (`"en"` and `"es"`)

### 2. ARB placeholder / ICU syntax preserved byte-for-byte
**PASS.** Full sweep found **zero** token mismatches across all 97
keys. All 5 keys with placeholders:

| key | EN | ES | Preservation |
|-----|-----|-----|--------------|
| `sentAmount` | `"Sent {amount} VFX"` | `"Se enviaron {amount} VFX"` | ✓ `{amount}` identical |
| `receiveAppBarTitle` | `"Receive {currency}"` | `"Recibir {currency}"` | ✓ `{currency}` identical |
| `sendAppBarTitle` | `"Send {currency}"` | `"Enviar {currency}"` | ✓ `{currency}` identical |
| `sendAmountHint` | `"Amount of {currency} to send"` | `"Monto de {currency} a enviar"` | ✓ `{currency}` identical |
| `receiveSelectedVfxAddress` | `"Your Selected VFX{vaultSuffix} Address"` | `"Tu dirección VFX{vaultSuffix} seleccionada"` | ✓ `{vaultSuffix}` identical (no space, interpolated inline — matches EN) |

No `{count, plural, ...}` or `{gender, select, ...}` in this Tier 1
set. The ICU runtime is wired (1C established the pattern with
`sentAmount`'s `@placeholders` block) and ready to accept plural/select
keys in Tier 2+.

### 3. ARB metadata — `@<key>` descriptions present on template locale
**PASS.**
- EN metadata blocks: 97 (one per runtime key)
- ES metadata blocks: 0 (correct ARB convention — metadata lives only
  on `template-arb-file` per `l10n.yaml`)
- Every EN runtime key has its `@<key>` companion block
- `@<key>` entries carry `description` (or `placeholders` for ICU keys,
  which is sufficient per Flutter's `flutter gen-l10n` requirements)

Spot-check: `@sentAmount` has both `description` and
`placeholders.amount.{type: "String", example: "1.25"}` — Tier 1 adds
nothing less than that for its new ICU key, it reuses the existing
schema.

### 4. Generated Dart files regenerated from the latest ARB
**PASS.**
- `lib/l10n/generated/app_localizations.dart` (709 lines — abstract
  class with `supportedLocales`, `localizationsDelegates`,
  `of(context)`, and a getter/method for every one of the 97 keys)
- `lib/l10n/generated/app_localizations_en.dart` (307 lines — concrete
  English implementation)
- `lib/l10n/generated/app_localizations_es.dart` (373 lines — concrete
  Spanish implementation; larger because several Spanish strings are
  slightly longer)

Sanity: **zero keys from `app_es.arb` are missing from the generated
class.** Placeholder methods are correctly typed:
- `String sentAmount(String amount)` ✓
- `String receiveAppBarTitle(String currency)` ✓
- `String sendAppBarTitle(String currency)` ✓
- `String sendAmountHint(String currency)` ✓
- `String receiveSelectedVfxAddress(String vaultSuffix)` ✓

All five match the `type: "String"` declarations on the `@placeholders`
metadata. ✓

### 5. Glossary compliance — core terms
**PASS.** Every mandated term maps correctly:

| Glossary entry | Usage in `app_es.arb` | Count |
|---|---|---|
| Send → Enviar | `actionSend`, `sendAppBarTitle`, `sendAmountHint`, `sentAmount ("Se enviaron")`, plus widget labels | 5 |
| Receive → Recibir | `actionReceive`, `receiveAppBarTitle`, `navReceive` | 3 |
| Settings → Configuración | `navSettings`, `configCloseDialogTitle`, `configButtonViewDocs ("Ver documentación")` | 2 (+ derived) |
| Wallet → Billetera | `walletCreate ("Crear billetera")`, `walletImport ("Importar billetera")` + related | 3 |
| Cartera (HARD FAIL if present) | **0** — clean | 0 |
| Balance → Saldo | `labelBalance: "Saldo"` | 1 |
| Pending → Pendiente | `statusPending` | 2 |
| Confirmed → Confirmada | `statusConfirmed: "Confirmada"` (feminine agrees with "transacción") | 1 |
| Failed → Fallida | `statusFailed: "Fallida"` (feminine agrees) | 2 |
| Amount → Monto | `labelAmount: "Monto"`, `sendAmountHint`, `sentAmount` | 3 |
| Address → Dirección | `labelAddress: "Dirección"`, 6 receive/send flow uses | 7 |
| Fee → Comisión | `labelFee: "Comisión"` + usage | 2 |
| Transaction → Transacción | Through receive/transactions screen strings | 6 |
| Recovery Phrase → Frase de recuperación | `walletRecoveryPhrase: "Frase de recuperación"` | 1 |
| Private Key → Clave privada | `walletPrivateKey: "Clave privada"` (verified) | ✓ |

**Gender agreement correctness**:
- `statusConfirmed: "Confirmada"` — feminine because it modifies
  implicit "transacción" (f.). ✓
- `statusFailed: "Fallida"` — same. ✓
- `statusPending: "Pendiente"` — invariant. ✓

### 6. Newly promoted glossary terms — usage check
**PASS (with scope note).**
- **Autocustodial / Autocustodia** (Phase 2A promotion): 0
  occurrences in GUI Tier 1. Not a gap — Tier 1 scope (send / receive
  / transactions / home / settings) does not surface self-custody
  messaging. These will appear in security/settings strings under
  Phase 2C-extension, and should match Phase 2A.
- **Mainnet** (kept English): 0 occurrences — not surfaced in Tier 1.
- **Rendimiento / Colateralización / Ecosistema / Emitir**: not
  applicable to Tier 1 scope (send/receive/tx/home/config). These are
  vBTC product / marketing vocabulary, not wallet-action vocabulary.

### 7. Tone + register ("tú" informal)
**PASS.**
- **Zero "usted" / "ustedes"** anywhere in `app_es.arb`.
- **Zero Spain-isms** (no "vosotros", "sois", "tío", "móvil",
  "ordenador").
- tú-form imperatives present:
  - `receiveBtcImportKeyDialogBody: "Pega tu clave privada BTC para
    importar tu cuenta."` — `Pega` is tú form (usted would be
    `Pegue`).
  - `receiveBtcAccountCreatedBody`: "Asegúrate de respaldar tu clave
    privada en un lugar seguro." — `Asegúrate` is tú reflexive.
  - `receiveRescanDialogBody`: "¿Quieres volver a escanear..." —
    `quieres` is second-person singular (usted would be `quiere`).
- tú possessives: `tu dirección`, `tu cuenta BTC`, `tu clave privada`
  — all correct informal register.

### 8. Diacritics
**PASS.** Sweep for `direccion|transaccion|configuracion|comision|
informacion|documentacion|politica|creacion|emision|conexion|
verificacion|recuperacion|validacion` (no accent) returned **zero
matches**. Every target word carries its proper acute:
- `Dirección`, `Transacción`, `Configuración`, `Comisión`,
  `Documentación`, `Recuperación` — all present with diacritics.
- Additional: `válido`, `seleccionó`, `Aquí`, `está`, `Cómo`, `quién`
  — all correctly accented.

### 9. Inverted `¿` / `¡` (Spanish standard punctuation)
**PASS.** All 3 Spanish interrogatives use the opening inverted
question mark:
- `receiveRescanDialogTitle: "¿Volver a escanear bloques?"` ✓
- `receiveRescanDialogBody: "¿Quieres volver a escanear la cadena
  para incluir las transacciones relevantes a esta clave?"` ✓
- `configCloseDialogTitle: "¿Cerrar la pantalla de configuración?"` ✓

No keys use exclamation marks that would require `¡` (no `¡` needed).

### 10. Brand names untouched
**PASS.**
- `appTitle: "VFX Wallet"` — VFX brand + "Wallet" retained as product
  naming (as app bar / window title; consistent with 1C).
- `{currency}` placeholder carries VFX/BTC/vBTC dynamically — no
  translation needed
- NFT, BTC, VFX, vBTC — all untouched.

Minor observation: `appTitle` is `"VFX Wallet"` rather than `"VFX
Billetera"` in the Spanish locale. This is correct per glossary
("brand names never translate") and matches the app's window-title
conventions. If product wanted `"VFX Billetera"` for the Spanish
window title, that would be a policy change, not a translation bug.

### 11. Length sanity (>50% longer flag)
**PASS WITH INFO.** 6 keys exceed the threshold, all short-label
noise:

| Key | EN | ES | Delta | UI context |
|---|---|---|---|---|
| `navSettings` | "Settings" (8) | "Configuración" (13) | +62% | Bottom nav tab. 13 chars fits standard Flutter nav. |
| `messageNoResults` | "No results found" (16) | "No se encontraron resultados" (28) | +75% | Empty-state text; line-break tolerant. |
| `messageNoAccountSelected` | "No account selected" (19) | "No se seleccionó ninguna cuenta" (31) | +63% | Empty-state text. |
| `messageClipboardInvalid` | "Clipboard text is invalid" (25) | "El texto del portapapeles no es válido" (38) | +52% | Error message; line-break tolerant. |
| `receiveRescanDialogTitle` | "Rescan Blocks?" (14) | "¿Volver a escanear bloques?" (27) | +93% | Dialog title. Inverted `¿` inflates count; real render width is reasonable. |
| `configButtonViewDocs` | "View Docs" (9) | "Ver documentación" (17) | +89% | Button label. **Flag for Phase 4C screenshot** — if this is a narrow button with a leading icon, may need abbreviation (e.g., "Ver docs"). |

`configButtonViewDocs` is the only one worth a Phase 4C screenshot
check. The others render in layout-flexible contexts.

### 12. Tier 1 scope is documented
**PASS.** The commit message for `33cba6ef` explicitly lists:
- The 7 widgets migrated
- The `fvm flutter analyze` result (70 issues, all pre-existing
  info-level unused_imports, 0 new issues from this phase)
- The Phase 2C-extension backlog: ~1100+ keys remaining across NFT
  wizard/detail, smart contract authoring, token creator,
  staking/validator admin, web wallet onboarding, BTC/vBTC V2 flows,
  dialog text in `lib/core/components/`, error messages in providers
  and services.

Per the lead's instruction: not treating missing areas as failures;
flagging them as explicit follow-up work.

---

## Findings

### INFO 1 — `configButtonViewDocs` may overflow narrow buttons
"Ver documentación" (17) vs "View Docs" (9) is +89%. If this renders
inside a constrained button (especially one with a leading icon),
Phase 4C integration testing should check desktop + narrow-viewport
web builds. If it overflows, consider `"Ver docs"` (8 chars — shorter
than English) as a compression. The glossary's "Docs" abbreviation
practice already authorizes this.

### INFO 2 — `sentAmount` uses "Se enviaron"
`sentAmount: "Se enviaron {amount} VFX"` uses the passive/
impersonal-reflexive construction ("were sent"), which is idiomatic
for Spanish transaction confirmations ("Se enviaron 1.25 VFX" = "1.25
VFX were sent"). Alternative `"Enviaste {amount} VFX"` ("You sent
{amount} VFX") is also valid tú-form and slightly more active. Both
are acceptable; the passive is more common in toast/confirmation
copy. Not a bug — defensible stylistic choice.

### INFO 3 — `receiveSelectedVfxAddress` word order
EN: `"Your Selected VFX{vaultSuffix} Address"`
ES: `"Tu dirección VFX{vaultSuffix} seleccionada"`
Spanish moves "seleccionada" after "dirección VFX{vaultSuffix}" —
matches Spanish N+adj word order. The `{vaultSuffix}` placeholder is
positioned identically relative to `VFX` on both sides (inline
suffix). ✓

### INFO 4 — Tier-1 backlog preview
The commit notes ~1100+ keys remaining. From a 97-key Tier 1, the
Tier-2 surface is ~11× larger. This is acknowledged in the plan's
risk table ("Flutter GUI has largest string surface — may need its own
dedicated track if string count is very high"). Recommend the lead:
(a) sequence Tier-2 as multiple smaller scopes (NFT wizard alone is a
large scope), (b) revisit namespace split — a single
`AppLocalizations` class with 1200 methods will be unwieldy. Consider
splitting into multiple ARB template files with separate output
classes (`SendLocalizations`, `NftLocalizations`, etc.) mapped to
`flutter_gen_l10n` `--preferred-supported-locales` or a manual
multi-template config. Not a 2C Tier 1 blocker.

### INFO 5 — `navReceive` / `walletCreate` receive proper informal form
- `navReceive: "Recibir"` (infinitive — nav-label convention) ✓
- `walletCreate: "Crear billetera"` (infinitive — CTA convention) ✓

Both use the infinitive which is the correct LatAm-neutral practice
for nav tabs and CTAs; imperatives would be wrong here. Translator
chose well.

---

## Glossary-Promotion Recommendations

Phase 2C Tier 1 does not introduce many new canonical terms (most of
its scope uses already-promoted or already-canonical vocabulary).
Flagging two that feel standards-worthy:

### Suggest promoting
1. **Rescan → Volver a escanear** — used in `receiveRescanDialogTitle`
   and `receiveRescanDialogBody`. Will reappear in Phase 2C-ext
   (Spyglass-GUI integration, web wallet rescan flows). Simple and
   stable.
2. **Clipboard → Portapapeles** — used in `messageClipboardInvalid`.
   Will appear in SpyglassWebApp (copy-tx-hash flows). Standard LatAm
   Spanish. Consider adding to the UI/Navigation section of the
   glossary.

### Spanish-specific patterns worth codifying (not terms, but guidance)
3. **Transaction-confirmation toast pattern** — "Se enviaron {amount}
   VFX" (passive-reflexive construction) is more natural than
   "Enviaste {amount} VFX" in LatAm UX. Worth adding to the glossary's
   "Wallet / Transaction Flow" section as a **pattern note**, not a
   term: "Completed-action toasts prefer impersonal-reflexive form
   (`Se enviaron X`, `Se copió Y`) over 2nd-person (`Enviaste X`,
   `Copiaste Y`)."
4. **Feminine-agreement rule for statuses** — `statusConfirmed:
   "Confirmada"` / `statusFailed: "Fallida"` agree with implicit
   feminine "transacción". The glossary already lists "Confirmed →
   Confirmada" and "Failed → Fallida" but could add a note: "Status
   adjectives default to feminine agreement because the implied
   subject is `transacción` (f.). If the UI ever displays the adjective
   with a masculine subject, a context-specific key is needed."

---

## Files Reviewed
- `lib/l10n/app_en.arb` (273 lines; 97 runtime keys + 97 `@<key>`
  metadata blocks)
- `lib/l10n/app_es.arb` (138 lines; 97 runtime keys; `@@locale: "es"`;
  no metadata as expected)
- `lib/l10n/generated/app_localizations.dart` (709 lines; confirmed
  one getter/method per key, correct placeholder signatures)
- `lib/l10n/generated/app_localizations_en.dart` (307 lines; spot
  checked placeholder impls)
- `lib/l10n/generated/app_localizations_es.dart` (373 lines; same)
- Commit message for `33cba6ef` (documents scope + ~1100-key
  backlog)

## Not Reviewed (Out of Phase 2C Tier 1 Scope)
- The 7 widget diffs (`send_screen.dart`, etc.) — plumbing, not
  translation content. Trusted per executor's analyze report.
- `flutter build` / `flutter test` output — trusted per executor.
- Phase 2C-extension keys (~1100+) — explicitly deferred per commit
  message.
- Web-wallet-specific screens — called out in the backlog.

---

## Recommendation
**Proceed to Phase 3C (review & QA for Tier 1).**

Before Phase 4C integration testing:
1. Screenshot-diff `configButtonViewDocs` on desktop and narrow web
   viewport; consider `"Ver docs"` compression if overflow.
2. Verify `statusConfirmed` / `statusFailed` feminine-agreement
   assumption holds for all UI subjects — if the GUI ever displays
   these standalone without "Transacción" context, a
   neutral/masculine alternative may be needed.

For Phase 2C-extension planning:
1. Sequence the ~1100-key backlog into 3–4 tiers (NFT wizard alone is
   a natural tier; smart contract authoring is another; web wallet
   onboarding is another).
2. Reassess single-ARB-file strategy before Tier 2 lands — a 1200-method
   `AppLocalizations` class is unwieldy; consider multi-template ARB
   split.
3. Ensure Phase 2C-ext reviewers re-check that any `autocustodial` /
   `autocustodia` / `emitir` usages match the Phase 2A-promoted
   canonical form (cross-repo consistency).
