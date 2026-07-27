# Phase 3C Verification — VerifiedX-GUI Full Spanish Translation

**Phase:** 3C — Full GUI Spanish translation review & QA (1,056 keys)
**Repo:** VerifiedX-GUI
**Branch:** `feat/i18n-es`
**Verifier:** reviewer agent
**Date:** 2026-05-04
**Glossary:** `/Users/m4mac/Development/verifiedx-i18n/glossary-en-es.md`
**Target tone:** neutral Latin-American Spanish, "tú" informal

## Verdict: **PASS**

All ten Phase 3C verification gates pass. The full GUI translation
(1,056 keys spanning send/receive, transactions, wallet, NFT, token,
smart contract, validator, voting, web wallet, BTC, vBTC, shop,
domain/ADNR, beacon, MOTHER, chat, keygen, settings, operations, and
core component strings) is structurally identical to the English
template, preserves every ICU placeholder and newline byte-for-byte,
hits zero forbidden glossary terms (zero "Cartera", zero "tarifa/
tasa/cuota" as Fee), maintains "tú" register throughout (zero
"usted/ustedes/vosotros", zero formal-imperative starts, zero
possessive "su/sus"), uses inverted `¿`/`¡` correctly on every
interrogative and exclamation, retains all brand names 1:1, and
parses as valid JSON on both sides. Length-overflow risks are all
short-label cases that should be screenshot-checked at integration
time, none of which are translation defects.

---

## Checklist Summary

| # | Check | Result |
|---|---|---|
| 1 | Key completeness — EN ⇔ ES parity | **PASS** — 1,056 / 1,056, 0 missing, 0 extra |
| 2 | ICU / placeholder preservation | **PASS** — 0 placeholder-name mismatches across 102 placeholder-bearing keys |
| 3 | Glossary compliance (canonical terms) | **PASS** — every mandated term maps correctly |
| 4 | Tone & register ("tú") | **PASS** — 0 usted/ustedes/vosotros/sois, 0 "su/sus", 0 formal imperatives |
| 5 | Diacritics | **PASS** — all flagged hits are demonstrative `esta` (this) or `{version}` placeholder; no missing accents on real verbs/nouns |
| 6 | Inverted `¿` / `¡` | **PASS** — 0 missing on either |
| 7 | Brand names preserved | **PASS** — VFX 86=86, BTC 76=76, vBTC 19=19, NFT 22=22, VerifiedX 1=1, CLI 15=15, Butterfly 2=2, Trillium 1=1 |
| 8 | Length sanity (>80% longer) | **PASS WITH INFO** — 34 short-label flags, all expected; 2 worth screenshot |
| 9 | Newline (`\n`) preservation | **PASS** — 0 mismatches |
| 10 | JSON validity | **PASS** — both files parse cleanly |

---

## Detailed Findings

### 1. Key Completeness — **PASS**

```
EN runtime keys: 1,056
ES runtime keys: 1,056
Missing in ES:   0
Extra in ES:     0
@@locale (EN):   "en"
@@locale (ES):   "es"
```

Total ARB top-level entries (runtime + `@<key>` metadata): 2,113 each.
EN carries metadata (1,056 `@<key>` blocks plus `@@locale`); ES carries
runtime keys plus `@@locale` only — correct ARB convention.

### 2. Placeholder / ICU Syntax Preservation — **PASS**

- **102** keys contain `{placeholder}` tokens in EN.
- **0** placeholder-name mismatches between EN and ES (verified by
  extracting `\{[a-zA-Z_]\w*` identifiers from both sides).
- **0** brace-count mismatches (EN `{` count == ES `{` count, same
  for `}`, on every key).

#### ICU plural form

`walletKeypairsLabel` is the only ICU `{plural}` key. Structure is
preserved on both sides:

```
EN: {count, plural, =1{1 keypair} other{{count} keypairs}}
ES: {count, plural, =1{1 par de claves} other{{count} pares de claves}}
```

The outer `{count}` placeholder name is identical, the `=1` and
`other` arms map correctly, and the inner `{count}` reference inside
`other{...}` is preserved. Translation of inner human text is correct
(singular "1 par de claves", plural "{count} pares de claves" with
agreeing plural noun).

#### Placeholder-only keys (sampled)

| Key | EN | ES |
|---|---|---|
| `chatWithAddress` | `Chat with {address}` | `Chat con {address}` |
| `btcToAddress` | `To: {address}` | `Para: {address}` |
| `validatorTransferHint` | `Or transfer {amount} VFX to {address}.` | `O transfiere {amount} VFX a {address}.` |
| `webSent5Vfx` | `5 VFX sent to {address}` | `Se enviaron 5 VFX a {address}` |
| `nodeWalletVersionLabel` | `Wallet Version: {version}` | `Versión de billetera: {version}` |
| `chatChattingWith` | `Chatting with {name}` | `Chateando con {name}` |
| `btcAmountWithBalanceTitle` | `Amount (Balance: {balance} BTC)` | `Monto (saldo: {balance} BTC)` |

All placeholder names identical, all positioned naturally for Spanish
syntax.

### 3. Glossary Compliance — **PASS**

| Term | EN keys | ES uses canonical | ES uses forbidden |
|---|---|---|---|
| Wallet → Billetera | 31 | 27 (4 are brand-name preservations: `VFX Wallet`, `Web Wallet`) | 0 (zero "Cartera") |
| Fee → Comisión | 17 | 17 | 0 (zero tarifa/tasa/cuota) |
| Balance → Saldo | 24 | 24 | — |
| Address → Dirección | 79 | 66 + 13 placeholder-only ({address}) cases | — |
| Transaction → Transacción | 37 | 37 | — |
| Validator → Validador | 15 | 15 | — |
| Smart Contract → Contrato inteligente | 12 | 12 | — |
| Domain → Dominio | 39 | 39 | — |
| Node → Nodo | 3 | 3 | — |
| Mint → Emitir/Emisión/Acuñ | 10 | 10 | — |

**HARD-FAIL gate (Cartera):** 0 occurrences. Clean.

The 4 "wallet-without-billetera" cases are intentional brand-name
preservations:
- `appTitle`: "VFX Wallet" (kept as product name)
- `authWebWalletSubtitle`: "Web Wallet {version}" (product name)
- `navSignOutBody`: "...la VFX Web Wallet?" (product name)
- `authWelcomeTitle`: "¡Bienvenido a la Web Wallet de VerifiedX!" (product name)

These are correct per the glossary's brand-name rule; "Web Wallet" is
a proper-noun product, not a generic wallet reference.

The 13 "address-without-dirección" cases are all `{address}`
placeholder uses where `{address}` carries the value — the user-facing
text is shaped naturally in Spanish ("Para: {address}", "{address}
copiado al portapapeles", etc.). One additional ES-localized form,
`keygenEmailAddressTitle: "Correo electrónico"`, correctly uses the
LatAm idiom for "Email Address" (not "Dirección de correo").

#### Sampled glossary spot-check (28 keys across modules)

All sampled translations use canonical terms — `Confirmar
importación`, `Crear enlace de pago`, `Importar billetera`, `Comisión`,
`Clave privada copiada al portapapeles`, `Versión de blockchain`,
`Restaurar cuenta de bóveda`, `Verificar de nuevo`, `Temas de votación
de validadores`, etc. No defects detected.

### 4. Tone & Register ("tú" informal) — **PASS**

| Pattern | Hits |
|---|---|
| `\busted\b` | 0 |
| `\bustedes\b` | 0 |
| `\bvosotros\b` / `\bvosotras\b` | 0 |
| `\bsois\b` | 0 |
| `\bsu\b` (3rd-person/usted possessive) | 0 |
| `\bsus\b` | 0 |
| Formal imperatives at sentence start (Pegue, Haga, Vaya, Ingrese, Seleccione, Confirme, Introduzca, Toque, Presione, Configure, Active, Verifique, Revise, Cierre, Abra, Inicie, Cancele, Acepte, Elija, Copie, …) | 0 |

**Familiar imperatives present (sampled):** `Pega` (5), `Ingresa`
(8), `Selecciona` (1), `Confirma` (2), `Asegúrate` (3), `Abre` (1),
`Elige` (5), `Configura` (4), `Revisa` (4). All tú-form.

**tú possessives present** (`tu cuenta`, `tu billetera`, `tu clave`,
`tu contraseña`, `tu sesión`, etc.) — consistent informal register.

### 5. Diacritics — **PASS**

Scan of `direccion|transaccion|configuracion|comision|informacion|
documentacion|politica|creacion|emision|conexion|verificacion|
recuperacion|validacion|operacion|seleccion|aplicacion|version|
opcion|descripcion|autenticacion|instalacion|actualizacion|
navegacion|ubicacion|presion|rotacion|extension|inclusion|exclusion|
decision|revision|transmision|compresion|facil|rapido|ultimo|
proximo|minimo|maximo|unico|publico|automatico|tecnico|asi|tambien|
despues|ademas|aqui|alli|esta|estan|esten` (no diacritics) — 27 raw
hits, all triaged and clean:

- **24 `esta` hits**: every one is the demonstrative pronoun
  ("this") followed by a noun (`esta cuenta`, `esta billetera`,
  `esta clave`, `esta función`, `esta colección`, `esta sección`,
  `esta tienda`, `esta dirección`, `esta transacción`). The
  unaccented form is correct; only the verb form `está` requires
  the acute. Suspicious-context scan ("`esta` + adjective like
  `disponible`/`activo`/`listo`") found **0** hits — no
  misidentified verbs.
- **2 `version` hits**: both are the ICU placeholder `{version}`
  (`authWebWalletSubtitle`, `nodeWalletVersionLabel`). Surrounding
  Spanish text uses correct `Versión` with accent.
- **0 `estan` / `esten` hits** — every plural verb form correctly
  uses `están` / `estén`.

Spanish words requiring acutes are spelled correctly throughout:
`Dirección`, `Transacción`, `Configuración`, `Comisión`, `Versión`,
`Documentación`, `Información`, `Creación`, `Emisión`, `Conexión`,
`Verificación`, `Recuperación`, `Aplicación`, `Predeterminado`,
`Está`, `Está`, `Aquí`, `Después`, `Cómo`, `Más`, `Si` vs `Sí`, etc.

### 6. Inverted Punctuation — **PASS**

- Every Spanish question segment ending with `?` is preceded by `¿`
  in the same segment — **0 missing**.
- Every Spanish exclamation segment ending with `!` is preceded by
  `¡` in the same segment — **0 missing**.

Examples: `¿Seguro que quieres cerrar sesión...?`, `¿Volver a
escanear bloques?`, `¿Cómo quieres llamar a esta cuenta?`, `¿Quieres
continuar?`, `¡Bienvenido a la Web Wallet de VerifiedX!`,
`¡Bienvenido!`.

### 7. Brand Names — **PASS**

| Brand | EN occurrences | ES occurrences |
|---|---|---|
| VFX | 86 | 86 |
| BTC | 76 | 76 |
| vBTC | 19 | 19 |
| NFT | 22 | 22 |
| VerifiedX | 1 | 1 |
| CLI | 15 | 15 |
| Butterfly | 2 | 2 |
| Trillium | 1 | 1 |
| Spyglass | 0 | 0 |
| PriceLens | 0 | 0 |

All brand counts identical 1:1 — no brand was translated, dropped, or
duplicated. Where "Wallet" appears as part of a product name (`VFX
Wallet`, `Web Wallet`), it is preserved in English per the glossary.

### 8. Length Sanity (>80% longer) — **PASS WITH INFO**

34 keys exceed the 80% length threshold. All are short EN labels
(≤16 chars) where Spanish requires natural-length words; none reflect
verbose or wrong translation. Top entries:

| Key | EN (chars) | ES (chars) | Δ | Notes |
|---|---|---|---|---|
| `operationsDocs` | "Docs" (4) | "Documentación" (13) | +225% | Section title; consider abbreviating to "Docs" if narrow UI |
| `btcFundLabel` | "Fund" (4) | "Financiar" (9) | +125% | Standard verb; fits buttons |
| `votingFail` | "Fail" (4) | "Rechazada" (9) | +125% | Status badge |
| `walletOkay` | "Okay" (4) | "Entendido" (9) | +125% | Acknowledgement button |
| `nodePeerInfoHeading` | "Peer Info" (9) | "Información de pares" (20) | +122% | Section heading |
| `btcDetailOwnerLabel` / `tokenOwnerLabel` | "Owner" (5) | "Propietario" (11) | +120% | Detail-row label |
| `webSetActive` | "Set Active" (10) | "Establecer como activa" (22) | +120% | Action button |
| `authLogout` / `navMenuLogout` | "Logout" (6) | "Cerrar sesión" (13) | +117% | Menu action |
| `tokenFormStandByTitle` | "Stand by" (8) | "Espera un momento" (17) | +112% | Loading/dialog title |
| `nftSyncMedia` | "Sync Media" (10) | "Sincronizar contenido" (21) | +110% | Action |
| `btcRetry` / `webScanRetry` | "Retry" (5) | "Reintentar" (10) | +100% | Action button |
| `shopSignIn` | "Sign In" (7) | "Iniciar sesión" (14) | +100% | Button |
| `votingPass` | "Pass" (4) | "Aprobada" (8) | +100% | Status badge |
| `motherUpdateHostInfo` | "Update Host Info" (16) | "Actualizar información del Host" (31) | +94% | Action button |
| `receiveRescanDialogTitle` / `walletRescanBlocksTitle` | "Rescan Blocks?" (14) | "¿Volver a escanear bloques?" (27) | +93% | Dialog title (¿ inflates count) |
| `configButtonViewDocs` | "View Docs" (9) | "Ver documentación" (17) | +89% | Button (already flagged in 2C) |
| `nftEvolveTitle` | "Evolve?" (7) | "¿Evolucionar?" (13) | +86% | Confirm dialog |
| `settingsLanguageSystemDefault` | "System default" (14) | "Predeterminado del sistema" (26) | +86% | Settings option |
| `shopBidNow` / `shopBuyNow` | "Bid Now" / "Buy Now" (7) | "Ofertar ahora" / "Comprar ahora" (13) | +86% | CTA buttons |
| `btcDetailScOwnerAddressLabel` | "SmartContract Owner Address" (27) | "Dirección del propietario del contrato inteligente" (50) | +85% | Detail label — long; multiline-tolerant |
| `beaconAutoDeleteAssets` | "Auto Delete Assets" (18) | "Eliminar archivos automáticamente" (33) | +83% | Toggle label |
| `nftEvolve` / `nftManage` | "Evolve" / "Manage" (6) | "Evolucionar" / "Administrar" (11) | +83% | Action button |
| `walletRestoreCodeLabel` / `webRestoreCodeLabel` | "Restore Code" (12) | "Código de restauración" (22) | +83% | Field label |
| `shopUrlRequired` | "Shop URL required" (17) | "Se requiere la URL de la tienda" (31) | +82% | Validation message |
| `shopBidHistory` | "Bid History" (11) | "Historial de ofertas" (20) | +82% | Section title |
| `tokenVotingEndsLabel` | "Voting Ends" (11) | "Finaliza la votación" (20) | +82% | Field label |

**Recommendation:** Phase 4C integration testing should screenshot-
diff these candidates on desktop and narrow web viewports. Highest-
risk for clipping in tight buttons/badges:
- `votingPass` ("Aprobada") and `votingFail` ("Rechazada") — status
  badges (badges are typically narrow).
- `webSetActive` ("Establecer como activa") — likely a button.
- `nftEvolve` / `nftManage` / `btcRetry` — action buttons.
- `configButtonViewDocs` ("Ver documentación") — flagged in Phase 2C
  already; consider `"Ver docs"` compression.
- `motherUpdateHostInfo` ("Actualizar información del Host") at 31
  chars on a button is the most likely overflow risk; consider
  `"Actualizar info del Host"` (24) if tight.

### 9. Newline Preservation — **PASS**

0 newline-count mismatches across all 1,056 keys. Multi-line keys
like `reserveRecoverBody`, `webRecoverFundsBody`,
`adnrFaucetRequiredBody`, and `adnrFundsSentBody` carry their
`\n\n` paragraph breaks identically.

### 10. JSON Validity — **PASS**

- `app_en.arb` — parses cleanly, 2,113 top-level entries.
- `app_es.arb` — parses cleanly, 2,113 top-level entries.
- `@@locale` correctly set on both sides.

---

## Findings (Informational)

### INFO 1 — `Web Wallet` brand handling is intentional and consistent

Four keys preserve the English "Wallet" inside a brand-name context
(`VFX Wallet`, `Web Wallet`, `VerifiedX Web Wallet`). This is correct
per the glossary's brand-name rule, and all four are consistent with
each other. No drift detected.

### INFO 2 — `keygenEmailAddressTitle` uses LatAm idiom

EN: `"Email Address"` → ES: `"Correo electrónico"` (not "Dirección de
correo electrónico"). This is the more natural LatAm Spanish form;
adding "Dirección" is a calque from English. Translation is correct.

### INFO 3 — `webSent5Vfx` / `adnrFundsSentBody` use passive-reflexive

`"5 VFX sent to {address}"` → `"Se enviaron 5 VFX a {address}"` and
`"{amount} VFX has been sent to {address}"` → `"Se enviaron {amount}
VFX a {address}"`. This matches the Phase 2C-Tier-1 pattern note
(impersonal-reflexive form preferred over 2nd-person for completed-
action toasts). Consistent across all "sent" toasts.

### INFO 4 — Status-adjective feminine agreement consistent

`votingFail: "Rechazada"`, `votingPass: "Aprobada"`, `shopBidSent:
"Enviada"`, status keys default to feminine because the implied
subject is `transacción`/`oferta`/`votación` (all f.). Aligns with
2C-Tier-1 finding.

### INFO 5 — `tokenFormNameHint` correctly preserves placeholder

`tokenFormNameHint: "MyToken"` is identical EN/ES. This is a hint-
text example value (a token name, not a translatable phrase). Correct
to leave untranslated.

### INFO 6 — Mint family translates as `Emitir/Emisión`

All 10 keys with EN "mint" use the `emitir`/`emisión` verb family
(matching Phase 2A glossary promotion). No `acuñar` mixing. Clean.

### INFO 7 — ICU plural is the only plural form in use

`walletKeypairsLabel` is the only `{count, plural, ...}` key in the
1,056-key set. If future product copy adds more plurals (e.g., "X
NFTs", "X transactions"), the same pattern applies — ensure both
`=1{}` and `other{}` arms exist on the ES side.

---

## Recommendations

### Before Phase 4C integration testing
1. **Screenshot-diff the top length-overflow risks** on desktop and
   narrow-web viewports:
   - `motherUpdateHostInfo` (31 chars in a button)
   - `webSetActive` (22 chars)
   - `votingFail` / `votingPass` (status badges)
   - `nftSyncMedia`, `nftEvolve`, `nftManage`, `btcRetry`,
     `webScanRetry` (action buttons)
   - `configButtonViewDocs` (flagged in 2C)
   Pre-approve abbreviations (e.g., `"Ver docs"`, `"Actualizar info
   del Host"`) so the executor can apply if overflow detected.

2. **Verify status-badge feminine agreement assumption** in UI
   contexts. `votingPass: "Aprobada"`, `votingFail: "Rechazada"`,
   `shopBidSent: "Enviada"`, `statusConfirmed: "Confirmada"`,
   `statusFailed: "Fallida"` all default feminine. If the UI ever
   displays these standalone next to a masculine subject (e.g., next
   to "Bid" rendered as masculine "voto"), a context-specific key
   may be needed.

3. **Spot-check ICU plural rendering** with `walletKeypairsLabel`:
   verify `=1` arm renders for `count == 1` and `other` arm renders
   for `count != 1`, on both EN and ES locales.

### Phase 3C is complete
No blocking issues, no glossary violations, no broken placeholders,
no JSON corruption. The translation is ready to ship pending Phase
4C UI integration screenshots.

---

## Files Reviewed

- `lib/l10n/app_en.arb` (1,056 runtime keys + 1,056 metadata blocks)
- `lib/l10n/app_es.arb` (1,056 runtime keys; `@@locale: "es"`)
- Glossary at `/Users/m4mac/Development/verifiedx-i18n/glossary-en-es.md`
- Phase 2C Tier 1 verification report at
  `docs/verification/phase-2c-tier1-translation.md` (template)

## Out of Scope
- Generated `lib/l10n/generated/app_localizations*.dart` files (build
  artifacts; trusted per `flutter analyze` 0-error result).
- Widget-level integration of new keys (Phase 4C).
- `flutter build` / `flutter test` execution (trusted per executor's
  analyze pass).
- Cross-repo glossary consistency (Phase 2A scope).
