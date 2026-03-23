# VBTC V2 Implementation — Clarifying Questions

## 1. Version Detection (CLI Side)

The doc references `TokenizationV2Feature`. When the CLI returns `GetTokenizedBTCList`, will it include a version field (e.g., `"Version": 2` or `"FeatureType": "TokenizationV2"`)? Or do we need to infer version from something like the presence of `FrostGroupPublicKey`?

This drives the entire routing strategy in the GUI.

**Answer:**
We'll learn more when we actually get creation working.


---

## 2. Transfer/Withdraw for V2 Tokens

The doc only covers contract creation. Once a V2 contract exists, do transfer (`/TransferCoin`), withdrawal (`/WithdrawalCoin`), and ownership transfer use the same V1 endpoints? Or are there new V2-specific endpoints under `/vbtcapi/vbtc/`?

**Answer:**
Let's focus on the creation for this sprint. More will come!

---

## 3. Naming: "eBTC" vs "vBTC"

You mentioned V1 as "eBTC" in your notes but the codebase uses "vBTC" everywhere for V1. What's the user-facing naming?

- V1 = "eBTC" badge, V2 = "vBTC" badge?
- Or V1 = "vBTC V1", V2 = "vBTC V2"?
- Something else?

**Answer:**
"vBTC" that was a typo. Stands for "Verified Bitcoin"


---

## 4. Web Wallet MPC Ceremony

The MPC ceremony requires hitting the local CLI (`localhost:{port}/vbtcapi/vbtc/InitiateMPCCeremony`). The web wallet has no local CLI. Options:

- Is V2 creation desktop-only for now?
- Does the Spyglass/Explorer service need to proxy the ceremony?
- Will there be a `CreateVBTCContractRaw` flow the web wallet can use if the ceremony was completed elsewhere?

**Answer:**
We will have a proxy for this - like we do for other web wallet raw smart contract creations

---

## 5. Ceremony UX Expectations

The doc shows the ceremony can take up to 4 minutes (polling every 2s, 120 polls). What's the expected UX?

- Modal with progress bar showing ceremony status (Round 1 → 2 → 3)?
- Background task with notification when ready?
- Can the user cancel mid-ceremony from the UI?

**Answer:**
I think it'd be cool to have a modal progress bar for this. We shouldn't let people cancel, though. And this should be something I guess that we allow to dismiss if people don't want to wait around. But we should still send a notification when it completes. 
However, if this ends up being a transaction on Chain, we don't really have to worry about the notification too much since we're already having watchers on our transaction list when new ones come in which auto notifies a toast. 


---

## 6. V2 Creation Form vs V1

The V2 creation has different parameters (no `FileLocation`, has `CeremonyId` instead). The V1 form has asset upload, multi-asset support, etc.

- Is V2 going to support those same features (custom image, multi-asset)?
- Or is V2 creation simpler (just name/description/ticker)?
- Should V2 creation replace the existing form, or be a separate flow?

**Answer:**
I think we should replace the form since we will no longer allow creating the V1 versions. But I will need to circle back with the dev because we should allow the multi-asset and the custom image in this. 
I'm not sure if that's just something the documentation's not included or if it just hasn't been built yet. 


---

## 7. CLI Endpoint Changes

Will the existing V1 endpoint (`/btcapi/BTCV2/GetTokenizedBTCList`) start returning V2 tokens mixed in with V1 tokens? Or will V2 tokens only appear via a new endpoint under `/vbtcapi/vbtc/`?

**Answer:**
Good question. I suppose we'll find this out once we get things working. 
