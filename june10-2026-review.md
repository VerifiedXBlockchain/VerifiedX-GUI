# Codebase Review — June 10, 2026

Deep review of vfx-gui covering polling/responsiveness, memory, vBTC v2, privacy/security, and AI-workflow readiness. Conducted on branch `testnet` at commit `ac2e629a`.

**Overall verdict:** The architecture is sound for what it is — the desktop/web split is strategic, error handling has no empty catches, and the codebase is honest about its TODOs. Nothing calls for an overhaul. But there are a handful of small, high-leverage fixes, two of them security issues worth treating as near-term priorities.

---

## Top 5 priority fixes

1. **TLS certificate validation is disabled on all desktop HTTP requests.** Every request path in `lib/core/services/base_service.dart` (lines 87, 132, 179, 225, 257, 334) sets `badCertificateCallback = (cert, host, port) => true`, unconditionally accepting any certificate — including for remote hosts like `data.verifiedx.io`, not just localhost CLI calls. Real MITM exposure for a wallet. Fix: only allow bad certs when the host is localhost (or behind a debug flag). Same pattern in `lib/features/remote_info/services/remote_info_service.dart:20`. *(Verified.)*

2. **Debug password `"younotry"` pre-fills password prompts** (`lib/core/app_constants.dart:64`, used in `lib/core/services/password_prompt_service.dart:26/57/75`). Gated by `kDebugMode` so release builds get `""`, but it's a committed credential string and worth removing. *(Verified.)*

3. **PBKDF2 at 1,000 iterations** (`lib/core/services/encryption_service.dart:11`) protects key material at rest — including web, where the encrypted blob sits in localStorage and is XSS-reachable. Modern guidance is 600k+. The format already stores `iterations` per blob (line 45), so the constant can be bumped with lazy re-encrypt on next unlock — zero migration pain. *(Verified.)*

4. **Debug/testnet hack marks all BTC transactions as confirmed**: `lib/features/btc/components/btc_transaction_list_tile.dart:46` does `(kDebugMode && Env.isTestNet) ? true : ...isConfirmed`. On the testnet branch this masks exactly the withdrawal-confirmation behavior you'd want to be testing for vBTC v2. *(Verified.)*

5. **`PasswordRequiredProvider` polls the CLI every 10s forever with an uncancellable timer** (`lib/features/encrypt/providers/password_required_provider.dart:9` — the `Timer.periodic` reference is never stored). The tightest no-off-switch loop in the app. *(Verified.)*

---

## Responsiveness (real-time against CLI/API)

**The picture: everything is HTTP polling — zero websockets/SSE anywhere in the client, and the CLI subprocess's stdout is discarded**, so the desktop app polls localhost for state the CLI already knows the moment it changes.

### Polling map

| Loop | Interval | What it refreshes |
|------|----------|-------------------|
| Desktop `sessionProvider.mainLoop()` | 30s | wallets, balances, validators, 5 tx types, 6 topic types |
| Desktop `smartContractLoop()` | 15s | 6 NFT/token/smart-contract list providers |
| Desktop `btcLoop()` | 30s | address type, sync info, tokenized BTC list, electrum status, price |
| Web session loop | 30s | addresses, token lists, vBTC tokens, NFT lists |
| Web BTC loop | 90s | address info, BTC transactions |
| ~40 scattered feature `Timer.periodic`s | 5s–30s | shops, chat, bridge, privacy, dialogs |

Notable waste: `mainLoop` and `lib/features/bridge/providers/wallet_info_provider.dart:56` both fetch wallet state every 30s independently, and the web shop full-list provider polls every **5 seconds** (`lib/features/web_shop/providers/web_shop_full_list_provider.dart:16`) whether or not anyone is looking at shops.

### Incremental wins, in order of leverage

- **Block-height-gated refresh.** Block height is already fetched every 30s. If height hasn't changed, skip the transaction/NFT/token refetches entirely. Cheapest "more real-time" win — the height-check interval can then be *shortened* (e.g. 10s) while cutting total CLI traffic: updates land faster and the app does less work.
- **Visibility-aware polling.** Pause or stretch feature-level timers when the screen isn't mounted or the app is backgrounded (an `idle_detector_wrapper` already exists). Today shop/chat/token polls run app-wide regardless of where the user is.
- **Standardize on one poller.** `lib/core/components/poller.dart` exists but most providers roll their own `Timer.periodic`. Only two providers — `bridge_operation_provider` and `bridge_lock_list_provider` (the newest code, notably) — implement in-flight guards and proper disposal. Those two are the template; a small mixin would bring the other ~38 in line.
- **Bigger swing (requires backend roadmap):** stream CLI stdout (desktop) or add a websocket channel to Spyglass (web) for block/tx events, with polling as fallback. The only path to true push — but the items above get most of the perceived gain with no backend work.

---

## Memory

- **Image cache is the biggest real-world consumer.** NFT cards and the image sequencer use `CachedNetworkImage` with no `cacheWidth`/`cacheHeight`, so thumbnails decode at full resolution; browsing a large NFT list can balloon the decoded-image cache to hundreds of MB. Adding `memCacheWidth`/`memCacheHeight` sized to display is mechanical and high-yield (`lib/features/nft/components/nft_card.dart:81`, `lib/features/image_sequencer/image_sequencer.dart:431/459`).
- **"Full list" providers accumulate every page into memory and re-fetch all pages on a timer** (`web_shop_full_list_provider.dart:46`, `web_collection_full_list_provider.dart:73`, `web_listing_full_list_provider.dart:52`, `lib/features/nft/providers/web_nft_list_provider.dart:30`). Fine at today's data sizes, but O(catalog) memory and bandwidth forever. Server-side pagination with `ListView.builder` infinite scroll is the eventual fix; bounding the in-memory window is the cheap interim one.
- **~344 of ~347 providers are app-lifetime; almost nothing uses `autoDispose`.** Correct for session state, but family providers keyed by address/collection (NFT lists, transaction lists per address) accrete one live copy per key visited. Adding `autoDispose` to family providers is low-risk and reclaims memory as users navigate.
- Timer-without-dispose findings (web session provider, `lib/features/remote_shop/providers/connected_shop_provider.dart:54`, web chat notifier, the three web-shop list providers) matter less as classic "leaks" — most are app-lifetime singletons whose dispose would never fire anyway — but they're the same fix as visibility-aware polling: the cost is perpetual network/CPU, not unreclaimed heap.

---

## vBTC v2

Generally in good shape — the bridge providers are the best-engineered polling code in the app, and the prepare→sign→execute API usage is consistent across targets. Targeted findings:

- **Web MPC ceremony dialog has no client-side timeout** (`lib/features/btc_web/components/web_mpc_ceremony_dialog.dart:166-202`); desktop has a 5-minute cap (`lib/features/btc/providers/mpc_ceremony_provider.dart:58-60`). If the server goes quiet mid-ceremony, the web dialog polls forever. Port the desktop timeout over.
- **Web withdrawal can't retry a failed broadcast** — retry is only offered for the FROST-signing phase when `_requestHash` exists (`lib/features/btc_web/components/web_v2_withdrawal_dialog.dart:331`); a broadcast-phase failure dead-ends the dialog. Desktop also has a cancel-withdrawal path the web lacks; decide whether that asymmetry is intentional.
- The debug `isConfirmed` hack (priority #4 above) sits directly in this flow's testing path.
- **Desktop/web parity drift is the structural risk**: `tokenized_btc_action_buttons.dart` (1,335 lines, mixed v1+v2) vs `web_btc_tokenized_action_buttons.dart` (535 lines, v2-only). If v1 is done, pruning dead v1 paths from the desktop file is the cleanup with the best payoff-to-risk ratio.
- Minor: `lib/features/token/providers/web_token_actions_manager.dart:667` uses `print()` for a withdrawal-completion failure; `lib/features/btc_web/services/btc_web_service_native.dart:54` has an unimplemented `signMessage` stub.

Good news: all explorer/mempool URLs are correctly gated by `Env.isTestNet`/`Env.btcIsTestNet` — no mainnet-vs-testnet hardcode landmines found.

---

## Privacy

The privacy module's architecture is solid — the privacy wallet password has its own 10-minute idle timeout, web re-prompts for the password before revealing keys, and AES-256-GCM with proper salt/IV is used. Beyond priority items #1–3 above:

- **Sensitive-adjacent logging.** `lib/features/keygen/services/keygen_service.dart:37` prints the raw key-derivation response; `lib/core/providers/web_session_provider.dart:195` prints decryption-failure details plus full stack trace; `lib/features/privacy/services/privacy_service.dart` logs raw exception objects (which can embed API payloads) in ~9 places. There are 753 `print()` calls codebase-wide and `avoid_print` is disabled in `analysis_options.yaml` — re-enabling that lint and sweeping the key-handling paths first would close this class of issue durably.
- **Desktop shows/copies private keys without a password re-prompt** (`lib/features/auth/auth_utils.dart:890-973`), while web requires one. Matching web's behavior is a small change.
- **Clipboard copies of mnemonics/WIFs have no warning and no auto-clear** (`auth_utils.dart`, `keygen_cta.dart`, tokenize onboarding). A 60-second clipboard clear plus a one-line warning is cheap.
- The privacy viewing key renders unmasked by default (`lib/features/privacy/components/privacy_settings_menu.dart:129`); a reveal toggle would be better.

---

## AI workflow readiness

The `.claude/context/` docs (ROUTER.md, architecture.md, conventions.md, decisions.md) exist and are current as of April 2026. Repo hygiene is clean: Makefile codegen targets, generated files checked in, honest TODOs (only ~20, all feature gaps rather than hacks). The real gaps, in priority order:

1. **Tests: one placeholder counter test against 813 source files, and no CI.** The single biggest limiter on AI-assisted work — neither an agent nor a human can refactor with confidence. Coverage isn't needed; a seam is. A handful of model-serialization tests (freezed models for vBTC/transactions) plus a GitHub Actions job running `fvm flutter analyze` + `flutter test` would change the risk profile of every future change for ~half a day of work.
2. **`.claude/context/patterns/` is empty.** The poller-with-in-flight-guard pattern from `bridge_operation_provider`, the BaseService endpoint pattern, and the desktop/web branching rules are exactly what belongs there — they'd stop agents (and humans) from reinventing the inconsistent timer patterns this review found.
3. **Flutter 3.7.12 is nearly three years old.** Not urgent since it works, but the gap compounds — newer Riverpod, lints, and tooling all sit behind it.
4. Lint config is permissive in ways that map to real findings: `avoid_print: false` ↔ the logging hygiene issues; `use_build_context_synchronously: false` ↔ the async-timer-after-dispose races found in the withdrawal dialog review.

---

## One-week action plan

| Day | Work |
|-----|------|
| 1 | Cert validation fix; remove debug password; remove/gate the `isConfirmed` hack; fix `PasswordRequiredProvider` timer |
| 2 | PBKDF2 bump with lazy re-encrypt; web ceremony timeout |
| 3–4 | Block-height-gated refresh in `mainLoop`/`smartContractLoop`; `memCacheWidth` on NFT images |
| 5 | CI with analyze + first real test file |

Everything else above is good backlog; none of it is urgent.
