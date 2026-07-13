# Hand-off: Adding Properties to an NFT (Web Wallet Mint)

How "Properties" (a.k.a. traits / attributes) are attached to an NFT / Smart Contract when minting, and the exact payload structure sent to the compiler. This mirrors the royalty hand-off doc — use it when integrating properties into another project.

---

## TL;DR

- Properties are a **flat string map** `{ "TraitName": "Value" }` under the `Properties` key of the compiler payload.
- Unlike royalties, properties are **NOT** a `Features` array entry — they are a top-level field.
- **Multiple properties are fully supported** (no count limit) in both the standard and bulk mint paths.
- The `type` (text/number/color/url) is a **client-side UI concept only** — it does NOT survive serialization. Only `name` → `value` reaches the chain.
- `:` and `<|>` are **stripped** from both name and value before sending.
- If there are no properties, the `Properties` key is **omitted entirely** from the payload.

---

## 1. Data model — `ScProperty`

**File:** `lib/features/sc_property/models/sc_property.dart`

```dart
enum ScPropertyType { text, number, color, url }

@freezed
class ScProperty with _$ScProperty {
  const factory ScProperty({
    @Default("") String name,
    @Default("") String value,
    @Default(ScPropertyType.text) ScPropertyType type,
  }) = _ScProperty;
}
```

`ScProperty.toJson()` produces `{ "name", "value", "type" }`, but **this client-side JSON is not what gets minted** — see §3.

`SmartContract` holds them as a list (`smart_contract.dart`):

```dart
@Default([]) List<ScProperty> properties,
```

---

## 2. Managing properties during creation

**Standard path** — `lib/features/smart_contracts/providers/create_smart_contract_provider.dart`

```dart
void addProperty(ScProperty property) {
  state = state.copyWith(properties: [...state.properties, property]); // APPEND
}

void updateProperty(ScProperty property, int index) { // REPLACE at index
  final updated = [...state.properties]..removeAt(index)..insert(index, property);
  state = state.copyWith(properties: updated);
}

void removeProperty(int index) {
  state = state.copyWith(properties: [...state.properties]..removeAt(index));
}
```

Append/replace/remove — so **multiple properties** accumulate. No uniqueness check on `name`, no max count.

**UI:** `lib/features/sc_property/components/properties_manager.dart` + `property_modal.dart`. The modal collects **name**, **value**, **type** (Text / Number / Color; Color shows a hex picker). Users add as many as they want.

---

## 3. Serialization — what actually gets sent

**File:** `lib/features/smart_contracts/models/smart_contract.dart` (`serializeForCompiler`)

```dart
Map<String, String>? propertiesOutput;
if (properties.isNotEmpty) {
  propertiesOutput = {};
  for (final property in properties) {
    final name  = property.name.replaceAll(":", "").replaceAll("<|>", "");
    final value = property.value.replaceAll(":", "").replaceAll("<|>", "");
    propertiesOutput[name] = value;   // FLAT MAP, name -> value
  }
}

final payload = CompilerPayload(
  // ...
  properties: propertiesOutput,
);

Map<String, dynamic> data = payload.toJson();
if (properties.isEmpty) {
  data.remove('Properties');   // key omitted entirely when empty
}
```

Key facts:
- Collapses to a **flat `Map<String, String>`** — `type` is dropped, only `name → value` survives.
- `:` and `<|>` stripped from name and value (these are reserved delimiters in the Core SC format).
- Duplicate names collapse — last write wins (map semantics).
- Empty list ⇒ no `Properties` key at all.

**Wire model** — `lib/features/smart_contracts/models/compiler_payload.dart`

```dart
@JsonKey(name: "Properties") Map<String, String>? properties,
```

---

## 4. Final JSON payload

Properties sit at the top level, alongside (not inside) `Features`:

```json
{
  "Name": "Legendary NFT",
  "MinterName": "ArtistName",
  "Description": "A rare digital collectible",
  "SmartContractAsset": { "...": "..." },
  "IsPublic": false,
  "SmartContractUID": "00000000-0000-0000-0000-000000000000",
  "Features": [
    { "FeatureName": 1, "FeatureFeatures": { "...royalty...": "..." } }
  ],
  "Properties": {
    "Rarity": "Legendary",
    "Edition": "1",
    "Background": "#ff0000"
  },
  "MinterAddress": "RBx...minterAddress",
  "IsMinter": true,
  "SCVersion": 1
}
```

Then it follows the same compile-then-broadcast flow as any mint (`RawService.compileAndMintSmartContract` → `RawTransaction.generate` with `TxType.nftMint`, `SCVersion: 1` appended).

---

## 5. Validation, stripping & limits

| Rule | Where | Detail |
|---|---|---|
| Name required | `edit_sc_property_provider.dart` | non-empty |
| Value required | `edit_sc_property_provider.dart` | non-empty |
| Color format | `edit_sc_property_provider.dart` | must contain `#` and be exactly 7 chars (`#RRGGBB`) |
| Number input | `property_modal.dart` | input filtered to `[0-9.]` |
| `:` / `<|>` stripped | `smart_contract.dart` | from both name and value at serialize time |
| Max count | — | none |
| Name uniqueness | — | not enforced (dupes collapse in the map) |

---

## 6. Bulk / wizard mint path

Properties are fully supported in bulk too.

- **Entry model** — `bulk_smart_contract_entry.dart`: `@Default([]) List<ScProperty> properties,`
- **Wizard provider** — `sc_wizard_provider.dart`: `addProperty(index, value)` / `removeProperty(index, assetIndex)` per entry.
- **CSV import** — columns 8+ become properties; header row supplies the name. Type auto-detected: numeric → `number`, 7-char `#…` → `color`, else `text`.
- **JSON import** — reads an `attributes` array of `{ "trait_type", "value" }` (standard NFT metadata shape) with the same type auto-detection.
- **Mint** — builds a `SmartContract` with `properties: entry.properties` and calls the **same** `serializeForCompiler()`, so the wire format is identical.

---

## 7. Integration notes for another project

1. **Properties ≠ Features.** Royalties go in the `Features` array with a `FeatureName`/`FeatureFeatures` envelope; properties are a top-level flat `Properties` map. Don't model them the same way.
2. **Type is cosmetic.** If you need typed traits on-chain, encode it into the value yourself — the compiler only stores strings.
3. **Reserve the delimiters.** Mirror the `:` / `<|>` stripping (or reject those chars on input) — the Core SC property format uses them as separators.
4. **Omit when empty.** Send no `Properties` key rather than an empty object.
5. **For OpenSea-style metadata**, map `attributes[].trait_type → name` and `attributes[].value → value`, exactly like the bulk JSON importer.

### Reference files
- `lib/features/sc_property/models/sc_property.dart` — model
- `lib/features/sc_property/components/properties_manager.dart`, `property_modal.dart` — standard UI
- `lib/features/smart_contracts/providers/create_smart_contract_provider.dart` — add/update/remove
- `lib/features/smart_contracts/models/smart_contract.dart` (`serializeForCompiler`) — flat-map build + stripping
- `lib/features/smart_contracts/models/compiler_payload.dart` — wire model
- `lib/features/smart_contracts/providers/sc_wizard_provider.dart` — bulk + CSV/JSON import
- `lib/features/raw/raw_service.dart` — compile + broadcast
