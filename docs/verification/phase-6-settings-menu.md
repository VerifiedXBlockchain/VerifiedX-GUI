# Phase 6: Settings Menu (Viewing Keys + Resync) — Verification Report

**Phase Objective:** Advanced features behind the gear icon: export/import viewing keys and resync wallet.

**Reviewed:** 2026-03-24

---

## Plan Task Checklist

### `lib/features/privacy/components/privacy_settings_menu.dart`

- [x] Gear icon button (uses `Icons.settings`, size 20, white54 color)
- [x] `PopupMenuButton` with 3 options

**Export Viewing Key:**
- [x] Calls `PrivacyService().exportViewingKey(zfxAddress: ...)`
- [x] Shows Base64 key in a copyable dialog via `InfoDialog.show()`
- [x] Key displayed in `SelectableText` with monospace font
- [x] Copy button with `Clipboard.setData` + Toast feedback
- [x] Error toast on failure

**Import Viewing Key:**
- [x] Dialog with zfx_ address field (validates `zfx_` prefix)
- [x] Base64 key field (multiline, `maxLines: 2`)
- [x] Calls `PrivacyService().importViewingKey(zfxAddress: ..., viewingKeyBase64: ...)`
- [x] Success toast + dialog close, error toast on failure
- [x] Loading state, `mounted` check, controller disposal
- [x] Uses `ConsumerStatefulWidget` with `rootNavigatorKey`

**Resync Wallet:**
- [x] Confirmation dialog via `ConfirmDialog.show()` with destructive styling
- [x] Explains: "wipe all cached notes and balances, then rescan from the beginning"
- [x] Calls `PrivacyService().resyncShieldedWallet(zfxAddress: ..., fromHeight: 0, toHeight: 0)`
- [x] Parameters match plan: `fromHeight: 0, toHeight: 0` (scan from genesis to current)
- [x] Success/error toast feedback

**PopupMenu styling:**
- [x] Divider between import and resync options
- [x] Resync styled in orange (destructive visual cue)
- [x] Icons for each option (key, download, sync)

### `lib/features/privacy/components/privacy_dashboard.dart` (modified)

- [x] Gear icon added to header row (address card)
- [x] `PrivacySettingsMenu` placed after copy button in `_AddressCard` row
- [x] Import added for `privacy_settings_menu.dart`

---

## Findings

### API Verification

| Feature | Service Method | API Endpoint | Parameters | Match |
|---------|---------------|--------------|------------|-------|
| Export | `exportViewingKey(zfxAddress)` | POST `/ExportViewingKey` | `{"ZfxAddress": "..."}` | Yes |
| Import | `importViewingKey(zfxAddress, viewingKeyBase64)` | POST `/ImportViewingKey` | `{"ZfxAddress": "...", "ViewingKeyBase64": "..."}` | Yes |
| Resync | `resyncShieldedWallet(zfxAddress, fromHeight: 0, toHeight: 0)` | POST `/ResyncShieldedWallet` | `{"ZfxAddress": "...", "FromHeight": 0, "ToHeight": 0}` | Yes |

Export response parsing: reads `result['ViewingKeyBase64']` — matches API response `{"ViewingKeyBase64": "aGVsbG93b3JsZC4uLg=="}` from the integration guide.

### Pattern Compliance

**InfoDialog / ConfirmDialog usage:** Both are existing project utilities from `lib/core/dialogs.dart`. `InfoDialog.show(title:, content:)` and `ConfirmDialog.show(title:, body:, confirmText:, destructive:)` — verified signatures match at lines 92 and 176 respectively.

**PopupMenuButton:** Standard Flutter widget, styled with `AppColors.getGray(ColorShade.s200)` background matching the dashboard cards. The `onSelected` switch pattern is clean and readable.

**Settings menu placement:** Added to `_AddressCard` row after the copy button — this is the "header row" the plan calls for. The gear icon sits naturally next to the copy button in the address card.

### Observations (No Action Required)

1. **Settings menu calls service directly instead of through provider:** The export/import/resync operations are called via `PrivacyService()` directly rather than through a provider. This is reasonable for these infrequent operations — they don't need state management. The action providers (shield/unshield/transfer/consolidate) have state because they manage loading state and trigger balance refresh. Export/import/resync handle their own feedback via toasts.

2. **Import dialog lacks `transparentAddress` field:** The plan says "dialog with zfx_ address + Base64 key fields." The `transparentAddress` parameter is optional per the API spec and the service method signature. Omitting it is correct — it's for optional association and not required for basic viewing key import.

---

## Verdict: PASS

All 3 settings features implemented: export viewing key (copyable Base64 dialog), import viewing key (zfx_ address + Base64 key fields with validation), resync wallet (destructive confirmation + genesis-to-current scan). Gear icon properly placed in dashboard header. API parameters match integration guide. Uses existing project dialog utilities correctly.
