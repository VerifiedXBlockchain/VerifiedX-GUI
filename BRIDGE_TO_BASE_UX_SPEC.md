# vBTC → Base Bridge: UX Specification

**Status:** Draft v1
**Scope:** On-ramp only (VFX vBTC → vBTC.b on Base). Exit/burn flows are out of scope — users will use external tools (Fireblocks, MetaMask, etc.) once the asset is on Base.

---

## 1. Goals & Non-Goals

### Goals
- Let users move vBTC from VFX onto Base in a single confident flow
- Surface all the prerequisite checks (gas, balance, contract state) before the user commits
- Give clear, honest messaging about the one-way nature of the flow from our app
- Show progress through the full state machine so users aren't left wondering

### Non-Goals
- Bridge out (Base → VFX or Base → BTC). Defer to external EVM wallets/integrations
- Generic EVM wallet features (token list, swap, etc.)
- vBTC.b management on Base beyond a balance display

---

## 2. Entry Point

**Location:** vBTC v2 contract detail screen, alongside the existing action buttons (mint, withdraw, send, etc.).

**Button:** "Bridge to Base"
- Variant: secondary / Base brand color (suggest a subtle blue, distinct from VFX blue)
- Icon: `Icons.swap_horiz` or a custom Base-style icon
- Disabled state: if `availableVbtc <= 0`, show with tooltip "No vBTC available to bridge"
- Hidden entirely: if the contract is v1 (only v2 contracts have bridge support)

**Why per-contract:** Each vBTC contract is its own pool. Bridge operations are scoped to a single contract, so the action belongs in the contract's context rather than a global view.

---

## 3. The Bridge Dialog

A single modal dialog (`AlertDialog`) that swaps its content between four states. Pattern matches existing `ShieldDialog` / `UnshieldDialog` for consistency.

```
┌─────────────────────────────────────┐
│  Bridge to Base                  ×  │
│                                     │
│  [content swaps per step]           │
│                                     │
│  [Cancel] [Primary Action]          │
└─────────────────────────────────────┘
```

### Step 1: Preflight & Form

Triggered when the dialog opens. Calls `GET /api/vbtc/bridge/preflight/{ownerAddress}/{scUID}` once.

**While loading:** centered spinner + "Checking your accounts…"

**On preflight success, content shows:**

```
[!] Bridging is one-way from this app. Once vBTC.b is on Base,
    use Fireblocks, MetaMask, or another EVM wallet to manage,
    transfer, or exit.

Amount to bridge
[ 0.5             ] vBTC
Available: 1.234 vBTC                              [Max]

Base (EVM) Address
[ 0xAbCd…1234                                    ]
Auto-derived from your VFX key. Edit to send to a different
Base address (get this from your DeFi provider / Base wallet).
                                            [Reset to derived]

Network info
  Network            Base Mainnet
  Contract           0x5678…ef01                  [copy] [↗]
  Your Base address  0xAbCd…1234                  [copy]
  ETH for gas        0.0042 ETH ✓
  vBTC.b balance     0.00 vBTC.b
```

**Preflight error states (replace the form):**
- `availableVbtc <= 0` → "You don't have any vBTC in this contract to bridge."
- `ethBalance < BRIDGE_MIN_ETH_FOR_GAS` (0.0005 ETH) → yellow warning banner: "Low ETH on your Base address for gas. Consider funding 0xAbCd…1234 with more ETH before bridging." Warning only — don't block, since gas costs can vary.
- `!bridgeConfigured` → "Bridging is currently unavailable. The CLI is not configured to talk to Base."
- preflight HTTP error → "Couldn't reach the bridge service. Check your connection and try again." with Retry button.

**Validation:**
- Amount: required, decimal, > 0, ≤ `availableVbtc`, ≤ some max (e.g. configurable per-tx limit from preflight if returned)
- Destination: required, valid EVM address (0x + 40 hex). Inline error if malformed.

**Primary action button:** "Review Bridge" → enabled when form is valid.

---

### Step 2: Confirm

```
You're about to bridge

   0.5 vBTC                from VFX
   →
   0.5 vBTC.b              to 0xAbCd…1234 on Base

This will:
  1. Lock your 0.5 vBTC on VFX
  2. Wait for validators to sign mint attestations
  3. Submit a mintWithProof transaction on Base
     (paid from your derived Base address: 0xAbCd…1234)

Estimated time: 2–5 minutes once submitted.

[!] Reminder: this is one-way from this app. You'll use a Base wallet
    (Fireblocks, MetaMask, etc.) for any further actions on vBTC.b.
```

**Buttons:** `[Back] [Confirm & Bridge]`

---

### Step 3: Progress

Triggered after confirm calls `POST /api/vbtc/bridge/toBase`. Capture `lockId` and start polling `GET /api/vbtc/bridge/status/{lockId}` every ~5s.

Show a vertical stepper with all states from the CLI:

```
✓  VFX lock submitted          07:23:14
   Tx: 89a7…c4f1                            [copy] [↗ explorer]

✓  Confirmed on VFX            07:23:48
   Block height: 12,847,329

◐  Collecting validator signatures…
   5 / 7 signatures collected

○  Submitting mint on Base
○  Minted on Base
```

State mappings (from `BridgeLockRecord.status`):
- `Pending` → step 1 in progress
- `Locked` → step 1 done, step 2 in progress
- `AwaitingSignatures` → step 2 done, step 3 in progress (with signature counter from `signaturesCollected / requiredSignatures`)
- `ProofSubmitted` → step 3 done, step 4 in progress
- `Minted` / `MintedOnBase` → all done → transition to Result step
- `Failed` → red X on the failing step, error message displayed, retry option if applicable

**While in progress:** Cancel button is disabled. A note: "Safe to close this dialog — your bridge will continue in the background. Track progress in Bridge History."

---

### Step 4: Result

**Success:**
```
✓  Bridged to Base

You now have 0.5 vBTC.b on Base
at 0xAbCd…1234                              [copy] [↗ basescan]

What's next?
Use Fireblocks, MetaMask, or another EVM wallet to:
 • Earn yield via Base DeFi
 • Transfer to another Base address
 • Exit back to vBTC on VFX or directly to BTC
   (whoever holds the vBTC.b initiates the exit; the
   network will detect it and credit you back automatically)

[Done]  [View on Basescan]
```

**Failure:**
```
✗  Bridge failed

[error message from the CLI]

Your vBTC may still be locked on VFX. Check Bridge History
for details, or contact support if this persists.

[Close]  [View Details]
```

---

## 4. Bridge History (per-contract)

A new section on the vBTC v2 contract detail screen, below the action buttons.

**Layout:**

```
Bridge History
  [Active operations card — if any in-flight]
  Past operations
    0.5 vBTC → 0x…1234            Minted        2 hours ago
    0.1 vBTC → 0x…1234            Failed        Yesterday
    1.2 vBTC → 0x…ab90            Minted        3 days ago

  [View all]
```

**Data source:** `GET /api/vbtc/bridge/GetBridgeLocksByOwner/{ownerAddress}` filtered to the current contract's scUID.

**Rendering:** `ListView.builder` for performance — no pagination, show whatever the CLI returns.

**Each row:**
- Amount and short destination
- Status badge (color-coded: green = Minted, yellow = in-flight, red = Failed)
- Relative timestamp
- Trailing "Retry" button when the status indicates a retry is supported (e.g. stuck mint after a failed attestation submission)
- Tap → opens a detail view (or re-uses the Progress step UI in read-only mode)

**Empty state:** "No bridge operations yet."

**Refresh:** auto-refresh every 30s if any operation is in-flight, otherwise on pull-to-refresh / button.

---

## 5. State Persistence & Notifications

- In-flight operations should be tracked in a Riverpod provider so they survive screen navigation
- When an in-flight operation transitions to `Minted` or `Failed`, fire a notification via the existing `transactionNotificationProvider` system (like privacy actions do)
- The bridge tx hashes (`vfxLockTxHash`, `baseTxHash`) should also surface as Transactions in the main transactions list, if the CLI returns them through `/GetAllLocalTX`

---

## 6. Edge Cases & Error Handling

| Scenario | Handling |
|----------|----------|
| User closes dialog mid-bridge | Operation continues server-side; visible in Bridge History |
| User has no derived Base address (key unavailable) | Disable Bridge button; show "Bridge unavailable — wallet not unlocked" |
| Preflight returns `bridgeConfigured: false` | Show full-dialog error; no form |
| Lock tx fails to broadcast | Show error in result step; nothing locked on chain |
| Lock confirmed but signature collection stalls | After 5 min, show warning "Taking longer than expected" with a "Continue waiting" option |
| Base mint reverts | Show error with reason; user can retry from history |
| User edits destination to malformed address | Inline validation error; submit button stays disabled |
| Network drops during polling | Pause polling; show "Reconnecting…" banner; resume on recovery |

---

## 7. Copy / Microcopy Guidelines

- "Base" not "EVM" — Base is the brand the user will recognize
- "vBTC.b" is the asset name on Base (matches contract)
- Avoid jargon: prefer "validator signatures" over "attestations" in user-facing copy
- One-way messaging: consistent phrasing — "from this app" is key (it's not actually one-way at the protocol level, just from our wallet)
- Confirmation language: "Bridge" as a verb is fine; avoid "send to Base" since that implies a simple transfer

---

## 8. Implementation Notes

**New providers needed:**
- `bridgeLockListProvider` (family by ownerAddress) — fetches and caches `GetBridgeLocksByOwner` response with auto-refresh logic
- `bridgePreflightProvider` (family by ownerAddress+scUID) — one-shot fetch, no auto-refresh
- `bridgeOperationProvider` (family by lockId) — polls status every 5s while in non-terminal state
- `activeBridgeOperationsProvider` — derived, surfaces in-flight ops globally for badge counts / notifications

**New service:**
- `BridgeService` extending `BaseService` with `apiBasePathOverride: "/api/vbtc/bridge"` — wraps all CLI endpoints

**New models (freezed):**
- `BridgePreflight` (matches preflight response)
- `BridgeLockRecord` (matches status response)
- `BridgeLockRequest` (request body for `toBase`)

**Component structure:**
- `BridgeToBaseDialog` (the main dialog with step switching)
- `BridgePreflightForm` (step 1)
- `BridgeConfirmation` (step 2)
- `BridgeProgress` (step 3, also reused for history detail)
- `BridgeResult` (step 4)
- `BridgeHistoryList` (the per-contract list)
- `BridgeHistoryItem` (row in the list)

---

## 9. Resolved Decisions

1. **Gas threshold:** `0.0005 ETH` as the low-balance warning threshold. Define as a single constant (e.g. `BRIDGE_MIN_ETH_FOR_GAS` in `app_constants.dart`) so it can be tuned after real-world testing.
2. **Custom destination labeling:** Generic — label the field "Base (EVM) Address". No provider names (no "Fireblocks", "Coinbase", etc.). Helper text: "Get this address from your DeFi provider / Base wallet." Provider-specific integrations are deferred to a future iteration when Fireblocks / Blockdaemon integrations are ready.
3. **Notification persistence:** Out of scope for v1. Users shouldn't be closing the wallet mid-bridge, and the History view will show the eventual status on next open.
4. **History pagination:** No pagination — render whatever the CLI returns. Use a `ListView.builder` (not a `Column` inside a `SingleChildScrollView`) so it stays performant regardless of list length.
5. **Stuck-lock retry:** Surface user-facing "Retry" buttons in the History row / detail view when the CLI's status indicates a retry is supported. Hook into the CLI's existing retry endpoints (`RetryMintForLock` etc. — verify exact endpoint name during implementation).

---

## 10. Out of Scope (for clarity)

- Burn UI (`burnForVfxExit` / `burnForBTCExit`)
- Live tracking of operations that originate from external wallets (Fireblocks burns) — though the resulting credit-back to VFX *will* appear in the main transactions list automatically
- Multi-contract bulk bridging
- Scheduling / recurring bridges
- vBTC.b transfers on Base from within our app
