# Smoke pass

A smoke pass is the release suite in `README.md` run as a prioritised sweep of one build on testnet, by Claude, with accounts the agent owns. It exists to answer "does everything still work on this build" in a day or two, and to leave every defect in the issue tracker. The full release pass (both lanes, every case, Tyler's accounts, the cross-platform phase) is described in `README.md` and still applies to a release.

The first smoke pass is `20261021a`: GUI `testnet` at `dee29244` (8.0.6, the deployed web wallet) on the 9.0 testnet (the 9.0 rule set has been live since block 1,172,000; see "9.0 changes" below).

## How a smoke pass differs from a release pass

| | Release pass (`README.md`) | Smoke pass (this file) |
|---|---|---|
| Accounts | Tyler's, from `~/.config/vfx-release-tests/accounts.<lane>.env` | Created by the agent in the app under test, kept in `~/.config/vfx-release-tests/agent/accounts.<lane>.env` |
| Funding | Pre-funded; treasury step run by an agent | The lane funds its own addresses through the faucet automation token after setup (see "Funding"); Tyler only when the token is unavailable |
| Web target | Local automation build on `localhost:42069` | The deployed testnet wallet, `https://wallet-testnet.verifiedx.io/?automation=1` (local build as fallback) |
| Browser | Claude in Chrome | Claude's built-in browser pane (Chrome extension as fallback) |
| Desktop target | `make run_macos_driver` (isolated folder) | `make run_macos_driver_real`: the same flavor without the automation define, on Tyler's real `~/rbxtest` folder, already at tip; his wallet backed up and closed |
| Order | Bitcoin first so confirmations overlap | Core functionality first, then privacy, then everything Bitcoin and vBTC last (S5); nothing touches the Bitcoin network before S5 |
| Case set | Every case | Tier A: every `P0` and `P1` case in scope, in the order below. Tier C (`P2`) only if time allows |
| Findings | Results file plus `BUGS-TO-FIX.md` | Results file plus one GitHub issue per defect on the `E2E Testing` board |
| Blocking | Release blocked on any `P0` failure | A blocking failure pauses the lane and asks Tyler whether to fix now or skip the area |

Everything not listed here (case format, hooks, waits, evidence, result values, the `Pending BTC` table, the `Too many elements` rule, temporary secrets) is as in `README.md` and the area files.

## Scope of a smoke pass

In scope: areas 01 to 09, 11, 12 and 13 as listed in `README.md`, on the web wallet and the macOS desktop GUI.

Out of scope, in addition to the README's exclusions (P2P shop, Windows). Never test these in a smoke pass:

- **Bfly on testnet:** one Bfly deployment serves both networks and is a separate product; its cases (TC-MISC-017 to 020, 023) are out.
- **Base bridge (vBTCb):** not exercised on testnet.
- **MOTHER:** out.
- **v1 vBTC:** dead; every legacy-vault case is `skipped` for good.

Case-level exclusions:

| Excluded | Why |
|---|---|
| TC-AUTH-003, 005, 006; TC-NET-012, 013 | Snapshot and improper-shutdown fixtures. (TC-AUTH-004, declining the snapshot prompt, runs once as the desktop lane's first boot if the prompt appears: see S0.) |
| TC-AUTH-021, 032, 063 | Need the extension, a legacy session, or a previous-release wallet fixture |
| TC-DASH-018, 036, 041, 042 | No trigger (state rebuild, unreachable screen, update prompts) |
| TC-NET-016, 017, 021, 029 | Validating needs 5,000 VFX locked from block 1,171,999 (validator bond) and open ports; beacons need a remote host |
| TC-MISC-017 to 020, 023 | Butterfly login and payment links (a separate product) |
| TC-MISC-026 to 030 | On-ramp provider iframes do not render under `?automation` |
| TC-MISC-031 to 033 | The SMS faucet needs a person; the lanes fund themselves through the token path instead |
| TC-BTC-042, 043, 048 to 052 | The legacy FROST withdrawal path. Every vault this pass creates is a watched vault (created after block 1,172,000), so TC-BTC-053 to 059 run instead. Legacy vaults freeze at block 1,192,500 |
| TC-VAULT-021 | Settles 24 hours after the send; check in a later pass |
| Every `P2` case | Tier C; run after Tier A if the lane has time, in the same order |

The macOS lane drives Tyler's real wallet folder (his decision, 2026-10-21), so cases that change the wallet as a whole, or that would touch his accounts, are also out:

| Excluded (macOS, shared folder) | Why |
|---|---|
| TC-AUTH-004, 043 | The chain is at tip and the wallet has accounts, so neither prompt appears |
| TC-AUTH-048 | Bulk import adds accounts to Tyler's wallet that only he can tidy |
| TC-AUTH-052, 053, 054 | Hide account (per-row taps beside his rows), backup all keys (exports his keys), create HD account (may replace his seed) |
| TC-AUTH-055 to 062 | Wallet encryption is wallet-wide and irreversible, and the lock and unlock cases need it |
| (privacy runs) | Tyler confirmed on 2026-10-21 that `~/rbxtest` has no shielded wallet and no privacy password of his, so `05-privacy.md` runs in full with the agent's own accounts; the privacy password the lane sets (`TEST_ENCRYPTION_PASSWORD` from its env file) becomes the folder's, and Tyler can read it there later |

## Agent-owned accounts

The lanes' accounts belong to the agent, so it is free to type their passwords, reveal and back up their keys, lock and unlock, and spend their testnet funds. Nothing of Tyler's is used: not his wallet, not his env files, not his keys. Testnet VFX and signet BTC have no value: the lane funds, sends, mints and withdraws without asking.

- **Files.** `~/.config/vfx-release-tests/agent/accounts.web.env` and `accounts.macos.env`, mode 600, created by the lane during S1 with the same variable names as the README's "Test data" table (`TEST_VFX_A_PRIVKEY`, `TEST_VFX_A_ADDRESS`, `TEST_VFX_B_…`, `TEST_MNEMONIC`, `TEST_BTC_WIF`, `TEST_BTC_ADDRESS`, `TEST_ENCRYPTION_PASSWORD`, plus `TEST_WEB_PASSWORD` on web). The files persist between smoke passes, so a later pass starts from funded accounts; a lane that finds its file already present reuses it and skips the creation cases (recording them `skipped`) unless the file is missing a variable.
- **Passwords.** Generated by the agent (`openssl rand -base64 18`), written to the file, and typed into the app wherever a case says `TEST_ENCRYPTION_PASSWORD` or `TEST_WEB_PASSWORD`.
- **Secrets handling.** Values are read from the file only when a step needs them, typed only into the app under test, and never written into results, screenshot names, issue text, commit messages or chat. Addresses are public and are recorded freely.
- **Web lane (S1).** Account A is a new mnemonic account (TC-AUTH-013; the key dialog shows the mnemonic, address and private key: record all three, the mnemonic as `TEST_MNEMONIC`). Its BTC address is derived from the same keys; TC-AUTH-039 reveals the BTC private key and WIF (`TEST_BTC_WIF`, `TEST_BTC_ADDRESS`). Account B is a second account created through `Add Account` (TC-AUTH-031, create rather than import) and its key is revealed with TC-AUTH-037 after switching to it (TC-AUTH-033). The "run web account" that the Vault lifecycle cases need (`06-vault-accounts.md`) is a third account created at the start of S3.
- **macOS lane (S1).** The accounts are created inside Tyler's own testnet wallet (`~/rbxtest`), beside his. The privacy wallet the lane activates in S4 is likewise the agent's (Tyler has none there), with its password from the env file. Accounts A and B are created with TC-AUTH-045, twice. The `Account Created` dialog shows the private key once: copy it with the dialog's copy button and read it from the clipboard (`pbpaste`) straight into the env file, then clear the clipboard. The BTC account is created with TC-BTC-004 the same way (the Core CLI exports no BTC key later, so this is the only moment to capture it). The wallet is not encrypted by the lane (`TEST_ENCRYPTION_PASSWORD` is unused on desktop). Rules for a shared wallet: the agent only ever selects, reveals, sends from, tokenizes with or otherwise acts on its own addresses (the ones in its env file); it never selects one of Tyler's accounts, never reveals or exports his keys, and treats totals and lists that include his accounts as context, judging only its own rows. It records which account was selected at boot and re-selects it before quitting.

## Funding

After S1 each lane funds its own addresses from the Spyglass testnet faucet with the automation token, which skips the SMS check and pays in the same call (`platform/testnet-tooling.md` in vfx-platform-context, and `docs/SIGNET.md` in vfx-node-farm): read `~/.config/vfx-release-tests/faucet.env` into the shell (`set -a; . ~/.config/vfx-release-tests/faucet.env; set +a`), then `POST https://data-testnet.verifiedx.io/api/faucet/request/` with `X-Faucet-Token: $FAUCET_AUTOMATION_TOKEN` and `{"address": "<x…>", "amount": "<VFX>", "btc_address": "<tb1…>", "btc_amount": "<BTC>"}`, one call per address. Never write the token into results, issues, commits or chat. Mine one signet block for the BTC (SMOKE-BTC.md, "Timing"), record the faucet transaction ids in the results file, and continue with S2; S3 starts once account A shows its VFX on Spyglass (`GET https://data-testnet.verifiedx.io/api/addresses/<address>/`).

The token path shares a daily cap of 1,000 VFX and 0.1 BTC per rolling 24 hours across all automation. Only when the token is missing, refused (401/403) or the cap is spent does the lane fall back to Tyler: it writes one combined `## Funding request` block (asset, address, amount for every address in the lane) at the top of its results file, puts it on Tyler's `/bench`, and carries on with S2.

Amounts per lane, with the README minimums (200 and 20 VFX) plus margin for the 9.0 fee rules and a Tier C tail:

| Asset | To | Amount |
|---|---|---|
| VFX | account A | 250 |
| VFX | account B | 25 |
| testnet BTC | the lane's BTC address | 0.0005 |

Every vBTC withdrawal pays out to the lane's own `TEST_BTC_ADDRESS`; nothing is returned at close-out, and the lanes keep their balances for the next pass. Nobody imports the treasury key into a lane during a smoke pass.

## Targets and tools

### Web lane

- Open `https://wallet-testnet.verifiedx.io/?automation=1` in Claude's built-in browser pane. Inject `tool/automation/flt_semantics.js` with the `javascript_tool`, call `fltA11y.enable()` (the deployed build does not click the semantics placeholder itself), and check `fltA11y.status()` reports `mode: "light"` with nodes. Details and caveats: `docs/automation.md`, "Deployed web wallet". The parameter must be on every fresh navigation; `Logout`, `Sign Out` and `Lock Wallet` reload without it.
- The hooks in the cases (`button "Send"`, `textbox "Amount"`, `fltA11y.tap(...)`, `await fltA11y.type(...)`) work unchanged in the pane; `read_page`, `find`, `form_input` and screenshots have the same names as the Chrome extension's tools. Keep the pane open so the tab stays visible.
- Record the build from the landing screen (`Web Wallet Testnet <version>`) and from `main.dart.js?version=` in the page source. If `fltA11y.status()` never reports nodes, fall back to the local automation build (`make run_web_automation` from the same commit) and say so in the results file.
- Fresh browser: `indexedDB.deleteDatabase('vfx'); localStorage.clear();` for the `wallet-testnet.verifiedx.io` origin, then load the URL again. Do this only where a case asks for it, and never after S1 without first confirming the env file holds every key (the wallet's storage is the only other copy).

### macOS lane

- The lane runs on Tyler's real data folder (`~/rbxtest`) with `make run_macos_driver_real`, the driver flavor without the automation define (`docs/automation.md`, "Driver on the real data folder"). Nothing is isolated: the CLI is his testnet node, the wallet holds his accounts, preferences are the installed wallet's, and the GUI and CLI update dialogs can appear at boot (decline them and note it in the results).
- Pre-flight: no `VerifiedXCore` process (`pgrep -fl VerifiedXCore` empty) and nothing answering `http://localhost:17292/api/V1/CheckStatus/`. If one is running it is Tyler's wallet: ask him to quit it and wait; never kill it. The installed wallet stays closed until the driver app has quit at the end of the lane.
- Backup: Tyler makes it before the lane starts, with the wallet quit: `cp -R ~/rbxtest ~/rbxtest-backup-20261021a` and `defaults export io.reserveblock.wallet ~/rbxtest-backup-20261021a/wallet-prefs.plist`. The lane checks that `~/rbxtest-backup-20261021a/DatabasesTestNet` exists before S1 and stops if it does not.
- Stop and ask Tyler, before S1, if the boot screen or the first guarded action asks for a wallet password (the wallet is encrypted and the agent has no password for it). At S4, if the privacy status screen shows a shielded wallet already activated (Tyler said there is none), stop and ask before touching it.
- Data: `~/rbxtest` is at tip (Tyler's node synced it on 2026-10-21), so no snapshot prompt and no sync wait; record the height at boot anyway. `vfx_plonk_v4.params` is already in `~/rbxtest/PlonkParamsTestNet/`, so nothing is staged for S4. The isolated automation folder is not used by this lane.
- Privacy (S4) runs in full on the shared folder with the agent's accounts A and B: Tyler confirmed there is no shielded wallet or privacy password of his there. The lane activates with its own accounts, sets the privacy password from its env file, and shields, unshields, transfers and consolidates only its own VFX.
- Start: `LANG=en_US.UTF-8 PATH="$HOME/.rbenv/versions/3.4.4/bin:$PATH" make run_macos_driver_real > <scratch>/flutter-run.log 2>&1 &`, read the VM service URL from the log, drive with `$HOME/fvm/versions/3.7.12/bin/dart run tool/drive.dart --vm-service-url <url> <command>`. Quit with `osascript -e 'tell application id "io.reserveblock.wallet" to quit'`. Revert `macos/Runner.xcodeproj/project.pbxproj` if CocoaPods rewrote it. All of this is in `docs/automation.md`.
- Record the Core CLI version the boot screen and Activity Log print (TC-AUTH-001). The installed CLI at `/Applications/VFXWallet.app/Contents/Resources/VFXCore/` was updated on 2026-10-21 and should be the 9.0 testnet build; if the log shows an 8.x version, stop before S1 and tell Tyler.
- When `drive.dart` cannot reach something (native panels, a `Too many elements` duplicate, a control with no key), use computer use on the app window (it is a dev build started by this session) for that tap, note `manual tap` in the result, and carry on. `osascript` keystrokes need Accessibility permission for the shell's process; if the prompt appears, Tyler grants it.

## Stages and order

Each lane runs its cases in this order. Within a stage, `P0` cases first, then `P1`, following file order; the per-lane tables below are already in run order. The stage names are what the results file groups rows under.

| Stage | What | Web | macOS |
|---|---|---|---|
| S0 boot | Desktop boot on the real folder, CLI version, height, selected account | – | TC-AUTH-001, 002, 007; 008 at the very end |
| S1 accounts | Create the agent's accounts (VFX A and B, and the BTC account, which only derives keys and touches no Bitcoin network), capture secrets, write the funding request, end the turn | TC-AUTH-009, 010, 013, 020, 031, 033, 037, 039, 040 | TC-AUTH-045 ×2, 050, 051, TC-BTC-004 (no encryption on the shared wallet) |
| S2 no-funds checks | Every in-scope case with `Moves funds: no` in 01, 02, 03, 07, 08, 09, 06, 11, 12, while waiting for funding | 95 cases | 99 cases |
| S3 funded core | The fund-moving cases of 03, 07 (VFX domains), 08, 09, 06, in that order. Nothing Bitcoin-related here (Tyler's decision): no BTC sends, no vault creation, no deposits before S5 | 37 cases | 38 cases |
| S4 privacy | `05-privacy.md` (desktop only), in full with the agent's own accounts; the v4 params are already in the folder | – | 17 cases |
| S5 BTC + vBTC | Opens with the slow steps: create two vBTC contracts (TC-BTC-023 / 022, twice) and fund each with 0.0001 BTC (TC-BTC-027 / 026), adding them to the `Pending BTC` table. While those confirm: BTC sends and history, BTC domains, vBTC list and detail, then Tier C cases of earlier areas if the wait goes on. Once the deposits show: transfers, bulk transfers, watched-vault withdrawals (TC-BTC-053 to 059) | 45 cases | 40 cases |
| S6 cross-platform | `13-cross-platform.md` `P0` and `P1` plus the `Phase: cross-platform` cases; run by whichever lane finishes last, with the other lane's app still open | 18 cases | 16 cases |
| Close-out | Pending BTC table drained (60 minutes max), leftover BTC returned to the treasury, results file finished, last commit | | |

Chain waits as in the area files: 2 to 3 minutes for a VFX transaction, about 10 minutes per Bitcoin confirmation on the VerifiedX signet (depth 3 for a vault credit); the 20261021a pass ran on Bitcoin testnet4, whose stalls blocked its S5.

## Case lists

Generated from the area files on 2026-10-21 (`P0` and `P1`, exclusions above applied, new 9.0 cases included). A case listing both platforms appears in both lanes and is run once in each.

### Web lane: 204 cases (54 P0, 150 P1; 69 move funds)
#### S1 accounts

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-AUTH-009 | P0 | no | Web landing screen on a fresh browser |
| TC-AUTH-010 | P0 | no | Login sheet lists every sign-in method |
| TC-AUTH-013 | P0 | no | Create a new mnemonic (HD) account |
| TC-AUTH-020 | P1 | no | Set Encryption Password validation |
| TC-AUTH-031 | P0 | no | Add a second account with its own password |
| TC-AUTH-033 | P0 | no | Switch between accounts |
| TC-AUTH-037 | P0 | no | Reveal and copy the VFX private key |
| TC-AUTH-040 | P0 | no | Reveal keys with a wrong password |
| TC-BTC-005 | P1 | no | Generate a BTC keypair (web) |

#### S2 no-funds checks

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-AUTH-011 | P0 | no | Create or log in with Email & Password |
| TC-AUTH-012 | P1 | no | Email & Password validation messages |
| TC-AUTH-014 | P0 | no | Recover from a mnemonic |
| TC-AUTH-015 | P1 | no | Mnemonic recovery rejects empty and invalid phrases |
| TC-AUTH-016 | P0 | no | Import a VFX private key |
| TC-AUTH-017 | P1 | no | VFX private key validation |
| TC-AUTH-022 | P0 | no | Unlock after a reload |
| TC-AUTH-023 | P0 | no | Wrong or empty password on unlock |
| TC-AUTH-024 | P1 | no | Return to the same page after unlocking |
| TC-AUTH-025 | P0 | no | Lock Wallet from the account menu |
| TC-AUTH-026 | P1 | no | Idle timeout warning and auto-lock |
| TC-AUTH-027 | P1 | no | Logout from the unlock screen |
| TC-AUTH-029 | P0 | no | Sign out from the side nav |
| TC-AUTH-030 | P1 | no | Sign out from the dashboard and the Addresses tab |
| TC-AUTH-035 | P1 | no | Manage Accounts sheet |
| TC-AUTH-036 | P1 | no | Forget an account |
| TC-AUTH-038 | P1 | no | Reveal the Vault account keys and restore code |
| TC-AUTH-041 | P1 | no | Reveal keys of an inactive account |
| TC-AUTH-042 | P1 | no | Backup keys to a text file |
| TC-DASH-001 | P0 | no | Web dashboard loads with balances |
| TC-DASH-002 | P0 | no | VFX balance card: latest transaction and actions |
| TC-DASH-006 | P1 | no | Addresses panel |
| TC-DASH-007 | P1 | no | Block height tab |
| TC-DASH-008 | P1 | no | Price cards and price charts |
| TC-DASH-009 | P1 | no | All My Tokens |
| TC-DASH-019 | P0 | no | Web side nav items |
| TC-DASH-021 | P0 | no | Every web nav item opens its section |
| TC-DASH-026 | P1 | no | Collapse and expand the side nav |
| TC-DASH-027 | P1 | no | Web mobile layout and drawer |
| TC-DASH-038 | P1 | no | Switch the web language to Spanish and back |
| TC-DASH-040 | P1 | no | Version display |
| TC-SEND-001 | P1 | no | Send screen shows the form, sender and balance |
| TC-SEND-004 | P1 | no | Cancelling at confirmation sends nothing |
| TC-SEND-006 | P1 | no | Paste an address from the clipboard |
| TC-SEND-012 | P1 | no | Prefilled VFX send from the URL |
| TC-SEND-015 | P1 | no | Required fields |
| TC-SEND-016 | P1 | no | Invalid recipient address |
| TC-SEND-017 | P1 | no | Invalid amounts: zero, negative, malformed |
| TC-SEND-018 | P1 | no | Amount larger than the balance |
| TC-SEND-024 | P1 | no | Receive VFX shows and copies the address |
| TC-SEND-027 | P1 | no | Request funds link |
| TC-SEND-032 | P1 | no | Web transactions screen |
| TC-SEND-036 | P1 | no | Open the transaction detail screen |
| TC-SEND-037 | P1 | no | Copy hash and addresses from the detail screen |
| TC-ADNR-001 | P1 | no | Domains screen layout and cost notes |
| TC-ADNR-002 | P1 | no | Create dialog opens and requires a name |
| TC-ADNR-003 | P1 | no | Name field drops characters other than letters and numbers |
| TC-ADNR-004 | P1 | no | Name longer than 65 characters is refused |
| TC-ADNR-007 | P1 | no | Web: create refused when the balance is too low |
| TC-ADNR-009 | P1 | no | Creating a domain name that is already taken fails |
| TC-ADNR-010 | P1 | no | Domain shown on account labels and the web Addresses panel |
| TC-ADNR-011 | P1 | no | Receive screen shows the domain and request links use it |
| TC-ADNR-013 | P1 | no | Send to a domain that does not exist |
| TC-ADNR-014 | P1 | no | Transfer dialog validates the address |
| TC-TOKEN-001 | P1 | no | Fungible Tokens screen, empty and populated |
| TC-TOKEN-003 | P1 | no | Create form opens with its defaults |
| TC-TOKEN-005 | P1 | no | Fixed supply shows and validates the supply field |
| TC-TOKEN-006 | P1 | no | Icon, name and ticker are required |
| TC-TOKEN-010 | P1 | no | Owner view of a token |
| TC-TOKEN-017 | P1 | no | Transfer and burn amount and address validation |
| TC-TOKEN-019 | P1 | no | Holder (non-owner) view |
| TC-TOKEN-032 | P1 | no | All My Tokens lists fungible tokens with balances |
| TC-TOKEN-033 | P1 | no | Balances agree across screens |
| TC-SC-001 | P1 | no | Smart contract landing screen |
| TC-SC-006 | P1 | no | Compile with an empty form lists every missing field |
| TC-SC-007 | P1 | no | Primary asset choose, replace, reveal and remove |
| TC-SC-010 | P0 | no | View the minted NFT |
| TC-SC-011 | P1 | no | Feature chooser offers Royalty, Evolving and Multi Asset, once each |
| TC-SC-012 | P1 | no | Royalty validation |
| TC-SC-013 | P1 | no | Add, edit and remove a royalty |
| TC-SC-014 | P1 | no | Multi Asset: add and remove additional assets |
| TC-SC-016 | P1 | no | Properties: text, number and color, edit and remove |
| TC-SC-017 | P1 | no | Property validation |
| TC-SC-018 | P1 | no | Manual evolving stages: add, validate, delete |
| TC-SC-019 | P1 | no | Date/time evolving stage |
| TC-SC-025 | P1 | no | Search and clear |
| TC-SC-027 | P1 | no | Manage Minted NFTs tab and management modal |
| TC-SC-029 | P1 | no | Copy smart contract id and addresses |
| TC-SC-031 | P1 | no | Full NFT detail: features, properties, additional assets, stages |
| TC-SC-042 | P1 | no | Transfer prompt rejects bad addresses |
| TC-SC-044 | P0 | no | Account B receives the transferred NFTs (web) |
| TC-SC-046 | P1 | no | Sender sees the transferred badge |
| TC-SC-048 | P1 | no | Bulk create landing |
| TC-SC-049 | P1 | no | Wizard instance validation |
| TC-SC-051 | P1 | no | Wizard instance with royalty, additional asset, evolve phase and property |
| TC-SC-055 | P1 | no | Import a collection from CSV |
| TC-SC-056 | P1 | no | Import a collection from JSON |
| TC-VAULT-002 | P1 | no | Web Vault Account screen |
| TC-VAULT-020 | P1 | no | Web Vault must keep 0.5 VFX, and locked funds cannot be spent |
| TC-VAULT-030 | P1 | no | Reveal Vault keys |
| TC-NET-043 | P1 | no | Latest block panel details |
| TC-MISC-021 | P1 | no | Create Payment Link entry point on Send |
| TC-MISC-022 | P1 | no | Payment link amount validation |
| TC-MISC-024 | P1 | no | Get VFX on testnet offers only the testnet faucet |
| TC-MISC-025 | P1 | no | Get VFX on mainnet reports no gateway |

#### S3 funded core

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-DASH-005 | P1 | yes | Balances refresh without a reload |
| TC-SEND-003 | P0 | yes | Send VFX to a valid address (web) |
| TC-SEND-019 | P1 | yes | Amounts with many decimals |
| TC-SEND-020 | P1 | yes | Web counts pending sends against the balance |
| TC-SEND-022 | P1 | yes | Send to a Vault (xRBX) address |
| TC-SEND-023 | P1 | yes | Send to a VFX domain |
| TC-ADNR-006 | P0 | yes | Create a VFX domain on account A |
| TC-ADNR-012 | P1 | yes | Send VFX to a VFX domain |
| TC-ADNR-015 | P0 | yes | Transfer a VFX domain from A to B |
| TC-ADNR-016 | P1 | yes | Delete a VFX domain (cancel, then confirm) |
| TC-TOKEN-009 | P0 | yes | Create a mintable, burnable token with voting and a pre-mint |
| TC-TOKEN-014 | P1 | yes | Mint more of a mintable token |
| TC-TOKEN-015 | P1 | yes | Mint amount validation |
| TC-TOKEN-016 | P0 | yes | Transfer tokens from A to B |
| TC-TOKEN-020 | P1 | yes | Burn tokens |
| TC-TOKEN-021 | P1 | yes | Pause a token, see transfers blocked, resume |
| TC-TOKEN-024 | P1 | yes | Create a token voting topic |
| TC-TOKEN-025 | P1 | yes | Owner votes Yes |
| TC-TOKEN-026 | P1 | yes | Holder votes No |
| TC-TOKEN-027 | P1 | yes | Balance below the topic minimum cannot vote |
| TC-TOKEN-029 | P1 | yes | Ban an address and list bans |
| TC-TOKEN-030 | P1 | yes | Create a fixed-supply, non-burnable token without voting |
| TC-TOKEN-031 | P1 | yes | Change token ownership |
| TC-SC-009 | P0 | yes | Create and mint a basic NFT |
| TC-SC-022 | P1 | yes | Create and mint a full-featured NFT |
| TC-SC-023 | P1 | yes | Create and mint a date/time evolving NFT |
| TC-SC-040 | P1 | yes | Evolve to stage 1 |
| TC-SC-041 | P1 | yes | Devolve back to base |
| TC-SC-043 | P0 | yes | Transfer an NFT to account B |
| TC-SC-047 | P1 | yes | Burn an NFT |
| TC-SC-054 | P1 | yes | Compile and mint a collection |
| TC-VAULT-010 | P0 | yes | Fund the web Vault (Vault W) |
| TC-VAULT-012 | P0 | yes | Activate the web Vault |
| TC-VAULT-017 | P1 | yes | Timelock below 24 hours is raised to 24 |
| TC-VAULT-018 | P0 | yes | Send from the web Vault with a timelock |
| TC-VAULT-019 | P0 | yes | Call back a web Vault send |
| TC-VAULT-029 | P0 | yes | Recover the web Vault |

#### S5 BTC + vBTC

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-AUTH-018 | P0 | no | Import a Bitcoin private key or WIF key |
| TC-AUTH-019 | P1 | no | Bitcoin key import rejects bad input |
| TC-AUTH-039 | P1 | no | Reveal the BTC keys |
| TC-DASH-003 | P1 | no | BTC balance card |
| TC-SEND-010 | P0 | yes | Send BTC from the web wallet |
| TC-SEND-011 | P1 | no | BTC send validation |
| TC-SEND-025 | P1 | no | Receive BTC shows and copies the BTC address |
| TC-ADNR-017 | P1 | no | BTC domain section and cost note |
| TC-ADNR-019 | P1 | no | Web: faucet prompt when VFX is too low for a BTC domain |
| TC-ADNR-020 | P0 | yes | Create a BTC domain |
| TC-ADNR-021 | P1 | no | BTC domain shown on the Addresses panel and Receive |
| TC-ADNR-022 | P0 | yes | Transfer a BTC domain |
| TC-ADNR-023 | P1 | yes | Delete a BTC domain |
| TC-BTC-002 | P0 | no | Add a BTC account from a WIF key (web) |
| TC-BTC-003 | P1 | no | Import validation (both platforms) |
| TC-BTC-011 | P0 | yes | Send BTC with the fee-rate picker (web) |
| TC-BTC-012 | P1 | no | Custom fee rate (both platforms) |
| TC-BTC-013 | P1 | no | BTC send validation (both platforms) |
| TC-BTC-017 | P1 | no | BTC transaction list (web) |
| TC-BTC-018 | P1 | no | History with an OP_RETURN output (web) |
| TC-BTC-019 | P1 | no | vBTC Tokens screen entry points (both platforms) |
| TC-BTC-021 | P1 | no | Create validation (web) |
| TC-BTC-023 | P0 | yes | Create a vBTC contract through the MPC ceremony (web) |
| TC-BTC-025 | P1 | yes | Tokenization wizard (both platforms) |
| TC-BTC-027 | P0 | yes | Fund a vBTC contract from the web BTC account (web) |
| TC-BTC-028 | P1 | no | Fund validation (web) |
| TC-BTC-029 | P1 | no | Copy the deposit address and manual send (both platforms) |
| TC-BTC-030 | P0 | no | Token list (both platforms) |
| TC-BTC-031 | P0 | no | Owned token detail (both platforms) |
| TC-BTC-033 | P0 | yes | Transfer vBTC to another VFX address (web) |
| TC-BTC-034 | P1 | no | Transfer validation (both platforms) |
| TC-BTC-035 | P1 | yes | Transfer contract ownership (both platforms) |
| TC-BTC-038 | P0 | yes | Bulk transfer across two contracts (web) |
| TC-BTC-039 | P1 | yes | Bulk transfer that fits one contract (both platforms) |
| TC-BTC-040 | P1 | no | Bulk transfer validation (both platforms) |
| TC-BTC-041 | P1 | no | Bulk transfer guards (both platforms) |
| TC-BTC-044 | P0 | yes | Withdraw from a received (non-owned) contract (both platforms) |
| TC-BTC-045 | P0 | no | Received contract: list, detail and actions (both platforms) |
| TC-BTC-046 | P1 | yes | Forward received vBTC (both platforms) |
| TC-BTC-047 | P1 | no | Withdrawal validation (both platforms) |
| TC-BTC-053 | P0 | yes | Withdraw from a watched vault: status step, no FROST (web) |
| TC-BTC-054 | P1 | yes | Raise the fee of a pinned watched withdrawal (web) |
| TC-BTC-055 | P1 | yes | Release a pinned watched withdrawal (web) |
| TC-BTC-056 | P1 | no | Close and resume the watched-withdrawal dialog (web) |
| TC-BTC-057 | P1 | yes | Cancel a watched withdrawal while it is Waiting (web) |

#### S6 cross-platform

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-SC-045 | P1 | no | Transfer Now fetches assets into the web wallet |
| TC-VAULT-026 | P1 | no | Restore a Vault from its restore code (web) |
| TC-XP-001 | P0 | yes | Send VFX from web to macOS |
| TC-XP-002 | P0 | yes | Send VFX from macOS to web |
| TC-XP-003 | P1 | no | Same account seen from both platforms |
| TC-XP-004 | P1 | yes | Send BTC from web to macOS |
| TC-XP-005 | P1 | yes | Send BTC from macOS to web |
| TC-XP-006 | P0 | yes | Transfer vBTC from web to macOS |
| TC-XP-007 | P0 | yes | Transfer vBTC from macOS to web |
| TC-XP-008 | P0 | yes | Forward received vBTC back to its owner |
| TC-XP-009 | P1 | yes | Bulk vBTC transfer across platforms |
| TC-XP-010 | P1 | yes | Withdraw received vBTC to Bitcoin on the other platform |
| TC-XP-011 | P0 | yes | Transfer an NFT from macOS to web, then fetch its assets |
| TC-XP-012 | P0 | yes | Transfer an NFT from web to macOS |
| TC-XP-013 | P1 | yes | Transfer tokens between platforms in both directions |
| TC-XP-014 | P1 | yes | Send VFX to the other platform's domain |
| TC-XP-015 | P1 | yes | Transfer a domain from web to macOS |
| TC-XP-016 | P1 | no | Restore each lane's vault on the other platform |

### macOS lane: 218 cases (51 P0, 167 P1; 71 move funds)
#### S0 boot

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-AUTH-001 | P0 | no | Cold boot shows the boot screen and starts the Core CLI |
| TC-AUTH-002 | P1 | no | Boot log lines in the Activity Log |
| TC-AUTH-007 | P1 | no | Restart CLI from Operations |
| TC-AUTH-008 | P0 | no | Quitting the app stops the Core CLI |

#### S1 accounts

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-AUTH-045 | P0 | no | Create a new VFX account |
| TC-AUTH-050 | P0 | no | Switch the selected account |
| TC-AUTH-051 | P0 | no | Reveal a desktop VFX private key |
| TC-BTC-004 | P1 | no | Create a new BTC account (macOS) |

#### S2 no-funds checks

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-AUTH-044 | P0 | no | Restore an HD wallet from a recovery phrase |
| TC-AUTH-046 | P0 | no | Import a VFX private key |
| TC-AUTH-047 | P1 | no | VFX private key import rejects bad input |
| TC-DASH-009 | P1 | no | All My Tokens |
| TC-DASH-012 | P0 | no | Desktop dashboard loads with balances |
| TC-DASH-013 | P1 | no | Desktop VFX card actions |
| TC-DASH-015 | P1 | no | Desktop latest transaction cards |
| TC-DASH-016 | P1 | no | Desktop price charts |
| TC-DASH-020 | P0 | no | Desktop side nav items |
| TC-DASH-022 | P0 | no | Every desktop nav item opens its section |
| TC-DASH-024 | P1 | no | Desktop sections that need an account |
| TC-DASH-026 | P1 | no | Collapse and expand the side nav |
| TC-DASH-028 | P1 | no | Block tab and status indicators |
| TC-DASH-029 | P1 | no | Sync indicator on a syncing chain |
| TC-DASH-030 | P1 | no | Operations status panel |
| TC-DASH-032 | P1 | no | Activity Log and Print Addresses |
| TC-DASH-037 | P1 | no | Switch the desktop language to Spanish and back |
| TC-DASH-040 | P1 | no | Version display |
| TC-SEND-001 | P1 | no | Send screen shows the form, sender and balance |
| TC-SEND-004 | P1 | no | Cancelling at confirmation sends nothing |
| TC-SEND-006 | P1 | no | Paste an address from the clipboard |
| TC-SEND-007 | P1 | no | Choose one of my addresses (macOS) |
| TC-SEND-015 | P1 | no | Required fields |
| TC-SEND-016 | P1 | no | Invalid recipient address |
| TC-SEND-017 | P1 | no | Invalid amounts: zero, negative, malformed |
| TC-SEND-018 | P1 | no | Amount larger than the balance |
| TC-SEND-024 | P1 | no | Receive VFX shows and copies the address |
| TC-SEND-027 | P1 | no | Request funds link |
| TC-SEND-029 | P1 | no | Desktop transactions screen modes and tabs |
| TC-SEND-030 | P1 | no | Desktop transaction tile details and copy hash |
| TC-SEND-033 | P1 | no | Filter by transaction type |
| TC-SEND-034 | P1 | no | Filter by address |
| TC-ADNR-001 | P1 | no | Domains screen layout and cost notes |
| TC-ADNR-002 | P1 | no | Create dialog opens and requires a name |
| TC-ADNR-003 | P1 | no | Name field drops characters other than letters and numbers |
| TC-ADNR-004 | P1 | no | Name longer than 65 characters is refused |
| TC-ADNR-009 | P1 | no | Creating a domain name that is already taken fails |
| TC-ADNR-010 | P1 | no | Domain shown on account labels and the web Addresses panel |
| TC-ADNR-011 | P1 | no | Receive screen shows the domain and request links use it |
| TC-ADNR-013 | P1 | no | Send to a domain that does not exist |
| TC-ADNR-014 | P1 | no | Transfer dialog validates the address |
| TC-TOKEN-001 | P1 | no | Fungible Tokens screen, empty and populated |
| TC-TOKEN-003 | P1 | no | Create form opens with its defaults |
| TC-TOKEN-005 | P1 | no | Fixed supply shows and validates the supply field |
| TC-TOKEN-006 | P1 | no | Icon, name and ticker are required |
| TC-TOKEN-010 | P1 | no | Owner view of a token |
| TC-TOKEN-017 | P1 | no | Transfer and burn amount and address validation |
| TC-TOKEN-019 | P1 | no | Holder (non-owner) view |
| TC-TOKEN-032 | P1 | no | All My Tokens lists fungible tokens with balances |
| TC-TOKEN-033 | P1 | no | Balances agree across screens |
| TC-SC-001 | P1 | no | Smart contract landing screen |
| TC-SC-006 | P1 | no | Compile with an empty form lists every missing field |
| TC-SC-007 | P1 | no | Primary asset choose, replace, reveal and remove |
| TC-SC-010 | P0 | no | View the minted NFT |
| TC-SC-011 | P1 | no | Feature chooser offers Royalty, Evolving and Multi Asset, once each |
| TC-SC-012 | P1 | no | Royalty validation |
| TC-SC-013 | P1 | no | Add, edit and remove a royalty |
| TC-SC-014 | P1 | no | Multi Asset: add and remove additional assets |
| TC-SC-016 | P1 | no | Properties: text, number and color, edit and remove |
| TC-SC-017 | P1 | no | Property validation |
| TC-SC-018 | P1 | no | Manual evolving stages: add, validate, delete |
| TC-SC-019 | P1 | no | Date/time evolving stage |
| TC-SC-025 | P1 | no | Search and clear |
| TC-SC-027 | P1 | no | Manage Minted NFTs tab and management modal |
| TC-SC-029 | P1 | no | Copy smart contract id and addresses |
| TC-SC-031 | P1 | no | Full NFT detail: features, properties, additional assets, stages |
| TC-SC-032 | P1 | no | Desktop asset files, thumbnails and assets folder (macOS) |
| TC-SC-042 | P1 | no | Transfer prompt rejects bad addresses |
| TC-SC-046 | P1 | no | Sender sees the transferred badge |
| TC-SC-048 | P1 | no | Bulk create landing |
| TC-SC-049 | P1 | no | Wizard instance validation |
| TC-SC-051 | P1 | no | Wizard instance with royalty, additional asset, evolve phase and property |
| TC-SC-055 | P1 | no | Import a collection from CSV |
| TC-SC-056 | P1 | no | Import a collection from JSON |
| TC-VAULT-003 | P1 | no | Setup New Account password validation |
| TC-VAULT-004 | P0 | no | Create a Vault and back up its keys (Vault D) |
| TC-VAULT-007 | P1 | no | A Vault that is not activated cannot send or share its address |
| TC-VAULT-008 | P1 | no | Activation with a wrong password |
| TC-VAULT-015 | P1 | no | Wrong Vault password on send |
| TC-VAULT-022 | P1 | no | Manage Vault Accounts screen |
| TC-VAULT-031 | P1 | no | Recover with a wrong restore code (desktop) |
| TC-NET-001 | P1 | no | Hidden network features stay hidden |
| TC-NET-002 | P0 | no | Operations status panel shows live CLI status |
| TC-NET-003 | P1 | no | Network metrics dialog |
| TC-NET-004 | P1 | no | Operations segments show the expected tools |
| TC-NET-005 | P1 | no | Print Addresses writes every account to the activity log |
| TC-NET-007 | P1 | no | Restart CLI from Operations |
| TC-NET-008 | P1 | no | Validator Check reports the validating state |
| TC-NET-015 | P1 | no | Validator screen below the 5,000 VFX requirement |
| TC-NET-024 | P1 | no | Search the Validator Pool by exact name |
| TC-NET-025 | P1 | no | Validator Pool search with no match, clear and back |
| TC-NET-027 | P1 | no | Beacon list |
| TC-NET-028 | P1 | no | Add Remote Beacon validation |
| TC-NET-030 | P1 | no | Create / Host Beacon validation |
| TC-NET-043 | P1 | no | Latest block panel details |
| TC-MISC-021 | P1 | no | Create Payment Link entry point on Send |
| TC-MISC-022 | P1 | no | Payment link amount validation |
| TC-MISC-024 | P1 | no | Get VFX on testnet offers only the testnet faucet |
| TC-MISC-025 | P1 | no | Get VFX on mainnet reports no gateway |

#### S3 funded core

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-DASH-005 | P1 | yes | Balances refresh without a reload |
| TC-SEND-002 | P0 | yes | Send VFX to a valid address (macOS) |
| TC-SEND-019 | P1 | yes | Amounts with many decimals |
| TC-SEND-022 | P1 | yes | Send to a Vault (xRBX) address |
| TC-SEND-023 | P1 | yes | Send to a VFX domain |
| TC-ADNR-006 | P0 | yes | Create a VFX domain on account A |
| TC-ADNR-008 | P1 | yes | macOS: fund-account prompt when the account is too low |
| TC-ADNR-012 | P1 | yes | Send VFX to a VFX domain |
| TC-ADNR-015 | P0 | yes | Transfer a VFX domain from A to B |
| TC-ADNR-016 | P1 | yes | Delete a VFX domain (cancel, then confirm) |
| TC-TOKEN-009 | P0 | yes | Create a mintable, burnable token with voting and a pre-mint |
| TC-TOKEN-014 | P1 | yes | Mint more of a mintable token |
| TC-TOKEN-015 | P1 | yes | Mint amount validation |
| TC-TOKEN-016 | P0 | yes | Transfer tokens from A to B |
| TC-TOKEN-020 | P1 | yes | Burn tokens |
| TC-TOKEN-021 | P1 | yes | Pause a token, see transfers blocked, resume |
| TC-TOKEN-024 | P1 | yes | Create a token voting topic |
| TC-TOKEN-025 | P1 | yes | Owner votes Yes |
| TC-TOKEN-026 | P1 | yes | Holder votes No |
| TC-TOKEN-027 | P1 | yes | Balance below the topic minimum cannot vote |
| TC-TOKEN-029 | P1 | yes | Ban an address and list bans |
| TC-TOKEN-030 | P1 | yes | Create a fixed-supply, non-burnable token without voting |
| TC-TOKEN-031 | P1 | yes | Change token ownership |
| TC-SC-009 | P0 | yes | Create and mint a basic NFT |
| TC-SC-022 | P1 | yes | Create and mint a full-featured NFT |
| TC-SC-023 | P1 | yes | Create and mint a date/time evolving NFT |
| TC-SC-040 | P1 | yes | Evolve to stage 1 |
| TC-SC-041 | P1 | yes | Devolve back to base |
| TC-SC-043 | P0 | yes | Transfer an NFT to account B |
| TC-SC-047 | P1 | yes | Burn an NFT |
| TC-SC-054 | P1 | yes | Compile and mint a collection |
| TC-VAULT-005 | P0 | yes | Fund Vault D from account A and auto-activate |
| TC-VAULT-006 | P1 | yes | Fund a second Vault manually (Vault E) |
| TC-VAULT-009 | P0 | yes | Activate a funded Vault manually |
| TC-VAULT-014 | P0 | yes | Send from a desktop Vault with a timelock |
| TC-VAULT-016 | P0 | yes | Call back a desktop Vault send |
| TC-VAULT-017 | P1 | yes | Timelock below 24 hours is raised to 24 |
| TC-VAULT-032 | P0 | yes | Recover a desktop Vault |

#### S4 privacy

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-PRV-001 | P0 | no | PLONK parameters and the privacy status gate |
| TC-PRV-003 | P0 | no | Activate the privacy wallet |
| TC-PRV-004 | P1 | no | Record a second shielded address (account B) |
| TC-PRV-005 | P1 | no | Re-activate account A and recover its shielded state |
| TC-PRV-006 | P1 | no | Unlock after restart, and the auto-lock |
| TC-PRV-007 | P1 | no | Dashboard content and address copy |
| TC-PRV-008 | P0 | yes | Shield VFX |
| TC-PRV-009 | P1 | no | Shield validation |
| TC-PRV-010 | P0 | yes | Unshield VFX to a transparent address |
| TC-PRV-011 | P1 | no | Unshield validation |
| TC-PRV-012 | P0 | yes | Private transfer to another shielded address |
| TC-PRV-013 | P1 | no | Private transfer validation |
| TC-PRV-014 | P1 | no | Wrong privacy password locks the wallet |
| TC-PRV-015 | P1 | no | Spending with no shielded VFX |
| TC-PRV-016 | P1 | yes | Consolidate notes |
| TC-PRV-019 | P1 | no | Export and copy the viewing key |
| TC-PRV-023 | P1 | no | vBTC privacy stays hidden while gated |

#### S5 BTC + vBTC

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-AUTH-049 | P1 | no | Import a BTC private key |
| TC-DASH-014 | P1 | no | Desktop BTC card actions |
| TC-SEND-009 | P0 | yes | Send BTC with a fee-rate preset (macOS) |
| TC-SEND-011 | P1 | no | BTC send validation |
| TC-SEND-025 | P1 | no | Receive BTC shows and copies the BTC address |
| TC-ADNR-017 | P1 | no | BTC domain section and cost note |
| TC-ADNR-018 | P1 | no | macOS: BTC domain form validation |
| TC-ADNR-020 | P0 | yes | Create a BTC domain |
| TC-ADNR-022 | P0 | yes | Transfer a BTC domain |
| TC-ADNR-023 | P1 | yes | Delete a BTC domain |
| TC-BTC-001 | P0 | no | Import a BTC account from its private key (macOS) |
| TC-BTC-003 | P1 | no | Import validation (both platforms) |
| TC-BTC-006 | P1 | no | BTC account list, selection and copy (macOS) |
| TC-BTC-007 | P1 | no | BTC connection status and balance card (macOS) |
| TC-BTC-008 | P1 | no | UTXO list (macOS) |
| TC-BTC-010 | P0 | yes | Send BTC with a fee preset (macOS) |
| TC-BTC-012 | P1 | no | Custom fee rate (both platforms) |
| TC-BTC-013 | P1 | no | BTC send validation (both platforms) |
| TC-BTC-014 | P1 | yes | Replace by fee, including the high-fee confirmation (macOS) |
| TC-BTC-016 | P1 | no | BTC transaction list and detail (macOS) |
| TC-BTC-019 | P1 | no | vBTC Tokens screen entry points (both platforms) |
| TC-BTC-020 | P1 | no | Create requires a funded VFX account (macOS) |
| TC-BTC-022 | P0 | yes | Create a vBTC contract through the MPC ceremony (macOS) |
| TC-BTC-025 | P1 | yes | Tokenization wizard (both platforms) |
| TC-BTC-026 | P0 | yes | Fund a vBTC contract from a BTC account (macOS) |
| TC-BTC-029 | P1 | no | Copy the deposit address and manual send (both platforms) |
| TC-BTC-030 | P0 | no | Token list (both platforms) |
| TC-BTC-031 | P0 | no | Owned token detail (both platforms) |
| TC-BTC-032 | P0 | yes | Transfer vBTC to another VFX address (macOS) |
| TC-BTC-034 | P1 | no | Transfer validation (both platforms) |
| TC-BTC-035 | P1 | yes | Transfer contract ownership (both platforms) |
| TC-BTC-037 | P0 | yes | Bulk transfer across two contracts (macOS) |
| TC-BTC-039 | P1 | yes | Bulk transfer that fits one contract (both platforms) |
| TC-BTC-040 | P1 | no | Bulk transfer validation (both platforms) |
| TC-BTC-041 | P1 | no | Bulk transfer guards (both platforms) |
| TC-BTC-044 | P0 | yes | Withdraw from a received (non-owned) contract (both platforms) |
| TC-BTC-045 | P0 | no | Received contract: list, detail and actions (both platforms) |
| TC-BTC-046 | P1 | yes | Forward received vBTC (both platforms) |
| TC-BTC-047 | P1 | no | Withdrawal validation (both platforms) |
| TC-BTC-059 | P0 | yes | Withdraw from a watched vault on desktop (macOS) |

#### S6 cross-platform

| Case | Pri | Funds | Title |
|---|---|---|---|
| TC-VAULT-027 | P1 | no | Restore a Vault from its restore code (desktop) |
| TC-XP-001 | P0 | yes | Send VFX from web to macOS |
| TC-XP-002 | P0 | yes | Send VFX from macOS to web |
| TC-XP-003 | P1 | no | Same account seen from both platforms |
| TC-XP-004 | P1 | yes | Send BTC from web to macOS |
| TC-XP-005 | P1 | yes | Send BTC from macOS to web |
| TC-XP-006 | P0 | yes | Transfer vBTC from web to macOS |
| TC-XP-007 | P0 | yes | Transfer vBTC from macOS to web |
| TC-XP-008 | P0 | yes | Forward received vBTC back to its owner |
| TC-XP-009 | P1 | yes | Bulk vBTC transfer across platforms |
| TC-XP-011 | P0 | yes | Transfer an NFT from macOS to web, then fetch its assets |
| TC-XP-012 | P0 | yes | Transfer an NFT from web to macOS |
| TC-XP-013 | P1 | yes | Transfer tokens between platforms in both directions |
| TC-XP-014 | P1 | yes | Send VFX to the other platform's domain |
| TC-XP-015 | P1 | yes | Transfer a domain from web to macOS |
| TC-XP-016 | P1 | no | Restore each lane's vault on the other platform |

## 9.0 changes reflected in the cases

Core 9.0 has been live on testnet since block 1,172,000 (2026-10-20), and GUI `testnet` carries the matching client changes (PRs #42 to #50). The suite was updated on 2026-10-21:

| Change | Cases |
|---|---|
| A recipient address from the other network is refused by the form (`This address belongs to another network…`) | TC-SEND-016 step 2 |
| `.vfx` names are resolved before the fee quote; the confirmation reads `name (address)`; an unknown name stops the send with `… could not be resolved to an address…` | TC-SEND-023, TC-ADNR-012, TC-ADNR-013 (now P1) |
| Unshield amounts have at most 8 decimal places | TC-PRV-011 step 4 |
| Mint refused client-side when the amount has more decimals than the token or the contract is paused | TC-TOKEN-015 steps 5 and 6 (now P1) |
| Transaction types 43 to 46 are named (`Bitcoin Report`, `vBTC Withdrawal Fee Raise` / `Release`, `Bitcoin Reorg`, `vBTC Vault Rekey`) | TC-BTC-054, 055 (the list after a raise or release) |
| Watched-vault withdrawals: no FROST, no completion; status step with raise fee, release and cancel on web; desktop behaviour to be established | TC-BTC-053 to 059, `04-btc-vbtc.md` preconditions |
| BTC-name signed acceptance (PR #42) | Not active (`BTC_NAME_SIGNED_MESSAGE_HEIGHT` is a placeholder); no case change |
| Validator bond (5,000 VFX locked, `ExitValidator` with a 1,200-block unlock) | Validator cases stay excluded |

Not covered by any case and worth a note in the results if seen: the activity log or transaction list showing `Bitcoin Report` or `Bitcoin Reorg` rows (they are addressed to `BTC_Attestation`, so they should never reach a user's own list).

## Filing issues

Every failure, every product gap and every automation gap that stops a case goes to the private tracker `VerifiedXBlockchain/VerifiedX-Issues` as an issue on the `E2E Testing` org project, number 4 (https://github.com/orgs/VerifiedXBlockchain/projects/4; fields `Status`, `Priority` P0/P1/P2, `Platform` Web/macOS/Both/CLI, `Area` with one option per area file, for example `03 send-receive`, plus `00 core-cli`). Aaron's Core CLI smoke test files on the same board with `Platform` CLI and `Area` 00 core-cli; leave those items to him. Results rows link the issue number.

- **Before filing**, search the tracker (`gh issue list --repo VerifiedXBlockchain/VerifiedX-Issues --search "<words>" --state all`) and the previous run's failures (`docs/testing/runs/20260927a-web.md`, "Failures" sections; several were fixed in `760f16fd`). If an open issue matches, comment on it with the run id, case id and build instead of filing a new one; if a closed one matches, file a new issue that links it as a regression.
- **Known before the pass:** VerifiedX-Issues #302, the first NFT transfer of a desktop session fails because the CLI connects to a beacon lazily inside the transfer request (TC-SC-043, macOS). Record the first attempt's message, retry once, and on a passing retry mark the case `pass` with a note linking #302.
- **Labels:** `source:e2e-smoke` plus the component (`component:gui` for desktop, `component:web-wallet` for web, `component:spyglass` or `component:core` when the fault is clearly in the backend or node). Add a `severity:*` label only when funds can be lost or stuck; the suite's `P0`/`P1`/`P2` goes on the board's `Priority` field, lowered or raised by what the failure actually does to a user.
- **Title:** `[e2e] <web|desktop|both>: <symptom in one line>`, for example `[e2e] web: View All Txs opens the All tab, not VFX`. A blocking failure gets the prefix `[BLOCKING]` before `[e2e]`.
- **Body** (one issue per defect, not per case):

  ```
  Case: TC-SEND-020 (03-send-receive-transactions.md) · Run: 20261021a · Lane: web
  Build: web wallet 8.0.6 at wallet-testnet.verifiedx.io (GUI testnet dee29244); Core testnet <version from the boot log, desktop only>
  Steps: <numbered, exactly what was done, with the hook used>
  Expected: <from the case>
  Actual: <what happened, verbatim UI text, tx hashes, heights>
  Evidence: <screenshot file name(s) in the run's shots folder; log excerpt for desktop>
  Impact: <what a user loses; why this priority>
  Workaround: <if any>
  ```

- **Commands:** `gh issue create --repo VerifiedXBlockchain/VerifiedX-Issues --title … --body-file … --label source:e2e-smoke --label component:web-wallet`, then `gh project item-add 4 --owner VerifiedXBlockchain --url <issue url> --format json` (gives the item id) and `gh project item-edit --project-id <project id> --id <item id> --field-id <field id> --single-select-option-id <option id>` for `Priority`, `Platform` and `Area`; the project, field and option ids come from `gh project view 4 --owner VerifiedXBlockchain --format json` and `gh project field-list 4 --owner VerifiedXBlockchain --format json`, read once at the start of the lane and read again if an edit reports an unknown option (editing a field's options re-creates their ids). Never close an issue, never touch the `VFX Findings` board, never paste tracker content anywhere public (Core, docs, Discord).
- A **product question** (behaviour that is neither clearly right nor wrong) is not an issue: put it under `## Questions` in the results file.

## Blocking failures

A failure is blocking when the lane cannot usefully continue its current stage because of it: the agent cannot create or unlock an account, cannot send VFX, the app or the Core CLI crashes and does so again on retry, funds are lost or stuck, or every case of an area fails at the same step. When that happens the lane:

1. Files the issue with the `[BLOCKING]` prefix and `Priority` P0.
2. Records the state in the results file (`## Paused` with the case, the issue number, what still works), commits it.
3. Ends its turn with one question for Tyler: fix now (the lane waits, then re-runs the failed case on the new build) or skip the area and continue.

Anything else is filed and the lane moves on to the next case. A failing precondition that no case covers (Spyglass down, no Bitcoin blocks, no funding yet) is recorded `blocked` with the reason and the lane keeps going with what it can run.

## Results and commits

- One results file per lane, `docs/testing/runs/20261021a-web.md` and `docs/testing/runs/20261021a-macos.md`, with the header block, the `Funding request` and `Pending BTC` tables, one `## <stage>` section per stage holding the result rows (`| TC-… | pass/fail/blocked/skipped | note, with #issue for a fail |`), then `## Failures` (one subsection per failed case, as `20260927a-web.md` does), `## Questions`, `## Objects created` (addresses, contract ids, domains, token ids; never keys) and `## Handover`.
- Screenshots in the session's scratch folder, named by case id; the results header gives the folder.
- After each stage: `git add docs/testing/runs/20261021a-<lane>.md && git commit -m "docs(testing): 20261021a <lane> lane through <stage>"` on `testnet`, nothing else staged, no push. Two lanes share this checkout, so never `git stash`, `reset`, `checkout` another branch, or stage another lane's file.
- S6 writes `docs/testing/runs/20261021a-cross.md` the same way.

## Starting a lane session

Each lane is its own Claude Code session in this checkout (`~/prj/vfx/vfx-gui`, branch `testnet`). Tyler starts them with the prompts below; each lane funds its own addresses after S1 ("Funding"). The `E2E Testing` board is org project 4.

**Web lane**

```
You are running the web lane of smoke pass 20261021a for the VFX wallet, in this checkout (vfx-gui, branch testnet). Read docs/testing/SMOKE.md first, then docs/testing/README.md and docs/automation.md, then each area file as you reach it. Follow SMOKE.md: agent-owned accounts (create them in the app; secrets only in ~/.config/vfx-release-tests/agent/accounts.web.env, mode 600, never in results, issues or chat), the deployed wallet at https://wallet-testnet.verifiedx.io/?automation=1 driven in the built-in browser pane with tool/automation/flt_semantics.js and fltA11y.enable(), stages S1 → S2 → S3 → S5 (→ S6 if the macOS lane has finished) in the order of the web lane table with nothing Bitcoin-related before S5, results in docs/testing/runs/20261021a-web.md committed on testnet after each stage (never push; stage nothing but that file; no stash, reset or branch changes), and one GitHub issue per defect in VerifiedXBlockchain/VerifiedX-Issues on the E2E Testing board (org project 4) with the label source:e2e-smoke. After S1, fund your addresses through the faucet token (SMOKE.md, "Funding"; fall back to one Funding request block on my /bench only if the token fails) and continue with S2; begin S3 when account A shows its VFX on Spyglass. A blocking failure (SMOKE.md, "Blocking failures") pauses the lane: file it, record the state, commit, and ask me whether to fix now or skip the area. The macOS lane runs in another session in this same checkout: never touch its results file. Begin with the pre-flight checks under "Web lane" and tell me the build you are testing before S1.
```

**macOS lane**

```
You are running the macOS lane of smoke pass 20261021a for the VFX desktop wallet, in this checkout (vfx-gui, branch testnet). Read docs/testing/SMOKE.md first, then docs/testing/README.md and docs/automation.md, then each area file as you reach it. This lane drives Tyler's real testnet data folder (~/rbxtest) through the driver flavor without the automation define (`make run_macos_driver_real`), so follow SMOKE.md "macOS lane" exactly: pre-flight (no VerifiedXCore running and nothing on port 17292, and if one is running ask me to quit my wallet rather than killing it; confirm ~/rbxtest-backup-20261021a/DatabasesTestNet exists and stop if it does not; start `make run_macos_driver_real` with the CocoaPods PATH prefix, output to a log file; decline any GUI or CLI update dialog; record the Core CLI version, the chain height and the account selected at boot, and stop if the CLI is not the 9.0 testnet build or if a wallet password is asked for), agent-owned accounts created inside my wallet (secrets only in ~/.config/vfx-release-tests/agent/accounts.macos.env, mode 600, captured from the clipboard at creation; never in results, issues or chat; only ever select, reveal, send from or act on your own addresses, never mine, and re-select the account that was selected at boot before you quit), the shared-folder exclusions in SMOKE.md (no wallet encryption, HD seed, key backup, hide or bulk import; privacy runs in full with your own accounts, since no shielded wallet or privacy password of mine exists there), stages S0 → S1 → S2 → S3 → S4 → S5 (→ S6 if the web lane has finished) in the order of the macOS lane table with nothing Bitcoin-related before S5, driven with tool/drive.dart and computer use only where drive.dart cannot reach, results in docs/testing/runs/20261021a-macos.md committed on testnet after each stage (never push; stage nothing but that file; no stash, reset or branch changes), and one GitHub issue per defect in VerifiedXBlockchain/VerifiedX-Issues on the E2E Testing board (org project 4) with the label source:e2e-smoke. After S1, fund your addresses through the faucet token (SMOKE.md, "Funding"; fall back to one Funding request block on my /bench only if the token fails) and continue with S2; begin S3 when account A shows its VFX in the wallet. A blocking failure (SMOKE.md, "Blocking failures") pauses the lane: file it, record the state, commit, and ask me whether to fix now or skip the area. The web lane runs in another session in this same checkout: never touch its results file. Begin with S0 and tell me the Core CLI version, the chain height and the account that was selected at boot before S1.
```
