# Release test suite

This suite lists every feature of the desktop GUI (macOS) and the web wallet that must be tested before an update ships, as full test cases that Claude runs. Each area has its own file below; this page holds the conventions every file follows, the environment and test data a run needs, and how results are recorded.

## Scope

- **Platforms:** the web wallet and the macOS desktop GUI. Windows is out of scope.
- **Out of scope:** P2P shop features (P2P Auctions, web shops, desktop auction houses, remote shops, listings, bids and shop chat).
- **Network:** testnet, with real transactions. Every flow that moves funds is executed end to end on testnet and confirmed on chain. Mainnet gets only the read-only checks marked `Mainnet smoke`, and nothing is ever signed or sent on mainnet.
- **Runner:** Claude. Web cases run through Claude in Chrome; macOS cases run through `tool/drive.dart` against the Flutter Driver build. Both are described in `docs/automation.md`, which is required reading before a run.
- **Lanes:** the web lane and the macOS lane run in parallel, each with its own test accounts, so neither can disturb the other's balances or objects. A final cross-platform phase then moves funds and assets between the two lanes' accounts. See "Running a release pass".

## Areas

| File | Area | Cases | P0 | P1 | P2 |
|---|---|---|---|---|---|
| [01-launch-auth.md](01-launch-auth.md) | Desktop boot and Core CLI, wallet creation and import, encryption, unlock, logout, key export | 62 | 27 | 26 | 9 |
| [02-dashboard-navigation-settings.md](02-dashboard-navigation-settings.md) | Dashboard, balances, navigation, status bar and sync, settings, language | 42 | 7 | 22 | 13 |
| [03-send-receive-transactions.md](03-send-receive-transactions.md) | VFX send, prefilled send, receive, transaction list, filters, detail | 39 | 4 | 24 | 11 |
| [04-btc-vbtc.md](04-btc-vbtc.md) | BTC accounts, vBTC tokenization, transfers, multi-transfer, withdrawals | 52 | 19 | 28 | 5 |
| [05-privacy.md](05-privacy.md) | Shield, unshield, private transfer, consolidate, for VFX and vBTC | 29 | 5 | 12 | 12 |
| [06-vault-accounts.md](06-vault-accounts.md) | Vault (reserve) accounts: create, activate, send, recover, manage | 32 | 11 | 14 | 7 |
| [07-domains.md](07-domains.md) | VFX and BTC domains (ADNR): create, transfer, delete | 23 | 4 | 17 | 2 |
| [08-fungible-tokens.md](08-fungible-tokens.md) | Fungible tokens: create, mint, transfer, burn, pause, voting topics | 34 | 2 | 19 | 13 |
| [09-smart-contracts-nfts.md](09-smart-contracts-nfts.md) | Smart contract wizard, templates, drafts, bulk create, NFTs, evolve, transfer, burn | 60 | 4 | 30 | 26 |
| [11-network-operations.md](11-network-operations.md) | Validator, operations, beacons, adjudicator, nodes, data node, network voting, mother dashboard | 45 | 1 | 19 | 25 |
| [12-bridge-payments-faucet-keygen.md](12-bridge-payments-faucet-keygen.md) | Base bridge, on-ramp payments, faucet, key generation | 42 | 2 | 22 | 18 |
| [13-cross-platform.md](13-cross-platform.md) | Transfers between the web lane and the macOS lane: VFX, BTC, vBTC, NFTs, tokens, domains, vaults | 16 | 7 | 9 | 0 |
| **Total** | | **476** | **93** | **242** | **141** |

Questions raised while writing the cases, with the case each belongs to, are collected in [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md). Several are suspected bugs.

## Environment

**Web.** Build or serve the testnet automation build (`make run_web_automation`, or a `flutter build web --dart-define TESTNET=true --dart-define AUTOMATION=true` served from `build/web` on port 42069) and open `http://localhost:42069/?automation=1`. The parameter must be present on every fresh load. Keep the tab visible. Screens that embed an iframe (on-ramp and payment providers) do not render in automation mode; the cases that need them say so and are run against the deployed testnet web wallet instead, read-only.

**macOS.** Quit any running VFX wallet first; `pgrep -fl VerifiedXCore` must be empty. Start `make run_macos_driver` with its output redirected to a file, read the Observatory URL from it, and drive the app with `tool/drive.dart`. Automation builds keep the Core CLI data under `~/Library/Application Support/vfx-gui-automation` and the preferences under an `automation.` prefix, so the real wallet is never touched. Delete that folder for a clean-state run. The first run in a fresh folder downloads about 250 MB and syncs testnet, so allow time before cases that need a synced chain.

**Mainnet smoke.** Only the cases tagged `Mainnet smoke` run against mainnet, on the production web wallet and a normal desktop build, and only read state.

## Test data

Test accounts are secrets and never go in this repo. Each lane has its own account file, which Tyler maintains: `~/.config/vfx-release-tests/accounts.web.env` for the web lane and `~/.config/vfx-release-tests/accounts.macos.env` for the macOS lane. Both files use the same variable names but hold different accounts, so "account A" in a case always means the current lane's account A and no case needs rewriting per lane. The cross-platform phase reads both files and names a lane explicitly, as `web:TEST_VFX_A_ADDRESS` or `macos:TEST_VFX_A_ADDRESS`. Claude reads values from these files when a step needs them, types them only into the local app under test, and never writes them into results, screenshot names, commit messages or chat. Expected variables in each file:

| Variable | Meaning |
|---|---|
| `TEST_VFX_A_PRIVKEY`, `TEST_VFX_A_ADDRESS` | Funded testnet VFX account A (sender in most cases) |
| `TEST_VFX_B_PRIVKEY`, `TEST_VFX_B_ADDRESS` | Testnet VFX account B (receiver and second party) |
| `TEST_MNEMONIC` | 12 or 24-word testnet HD mnemonic |
| `TEST_WEB_EMAIL`, `TEST_WEB_PASSWORD` | Email and password login for the web wallet (web file only) |
| `TEST_BTC_WIF`, `TEST_BTC_ADDRESS` | Funded testnet BTC account |
| `TEST_ENCRYPTION_PASSWORD` | Password used for wallet encryption and web unlock cases |

Some cases need data that only a few areas use. They read these optional variables from the same file and record the case as `blocked` when a variable is missing:

| Variable | Used by |
|---|---|
| `TEST_IMAGE_URL` | A stable public PNG URL for bulk smart contract imports (09) |
| `TEST_BASE_SEPOLIA_ADDRESS` | Destination for Base bridge cases (12); the bridge's derived gas address also needs Base Sepolia ETH |
| `TEST_FAUCET_PHONE` | Faucet cases (12) |
| `TEST_WEB_EMPTY_EMAIL`, `TEST_WEB_EMPTY_PASSWORD` | An unfunded web login for low-balance paths (07, 12) |
| `TEST_VALIDATOR_PRIVKEY`, `TEST_VALIDATOR_ADDRESS`, `TEST_EXISTING_VALIDATOR_NAME` | Validator cases (11); they also need 5,000 VFX and open ports, so they run on a dedicated machine |
| `TEST_REMOTE_BEACON_IP`, `TEST_REMOTE_BEACON_PORT` | Beacon cases (11) |
| `TEST_MOTHER_HOST_IP`, `TEST_MOTHER_HOST_PASSWORD` | MOTHER dashboard cases (11) |

No account appears in both files.

Bitcoin for both lanes comes from one shared testnet4 treasury in `~/.config/vfx-release-tests/treasury.env` (mode 600), which Tyler funds from a testnet4 faucet:

| Variable | Meaning |
|---|---|
| `TEST_BTC_TREASURY_ADDRESS` | Treasury address (`tb1q…`, native SegWit). Public; safe to show. |
| `TEST_BTC_TREASURY_WIF` | Treasury key in WIF form. Secret. |

The treasury is never imported into a lane's wallet, so the two lanes never spend from it at the same time. It is used in three places: the pre-run funding step tops up each lane's `TEST_BTC_ADDRESS` from it, every vBTC withdrawal in the suite pays out to `TEST_BTC_TREASURY_ADDRESS`, and the return step after the run sends leftover lane BTC back to it. Only the funding and return steps sign with the treasury key, and they run before and after the lanes, one at a time.
 Minimum balances before a run, per lane: account A holds at least 200 testnet VFX, account B at least 20 VFX, and the BTC account holds enough testnet BTC for one tokenization plus fees. The faucet cases in `12-bridge-payments-faucet-keygen.md` top VFX up. Cases that create on-chain objects (domains, tokens, NFTs, vault accounts) use names suffixed with the run id and the lane, `w` for web and `m` for macOS, for example `qa-20261001a-w`, or `qa20261001aw` where only letters and digits are allowed, so the two lanes and repeated runs never collide. Where an area file already defines its own platform suffix, such as `<p>` = `web` or `mac` in `09-smart-contracts-nfts.md`, that suffix plays the same role.

## Test case format

Each area file groups its cases under `##` feature headings, and each case is a `###` heading. Every case uses this shape:

```markdown
### TC-SEND-003 · Send VFX to a valid address
**Platforms:** Web, macOS · **Priority:** P0 · **Moves funds:** yes

**Preconditions:** Logged in as account A with at least 10 VFX. Chain synced (macOS).

**Steps**
1. Open Send. Web: click `button "Send"` in the side nav. macOS: `tap-key nav:send`.
2. Enter account B's address. Web: click `textbox "To"` and type it. macOS: `tap-key send:address`, then `type <address>`.
3. ...

**Expected**
- A confirmation dialog shows the recipient, the amount and the fee.
- After confirming, a success toast appears and the transaction is listed as pending, then confirmed within 2 minutes.
- Account B's balance increases by the amount.

**Cleanup:** none.
```

- **IDs** are `TC-<AREA>-<NNN>` and never reused. Area codes: `AUTH`, `DASH`, `SEND`, `BTC`, `PRV`, `VAULT`, `ADNR`, `TOKEN`, `SC`, `NET`, `MISC`, `XP`.
- **Cross-platform phase.** A case whose header line ends with `Phase: cross-platform` involves both lanes' accounts. Lanes skip it and the cross-platform phase runs it.
- **Platforms** is `Web`, `macOS` or both. When the two differ, the steps give each platform's hook on its own line.
- **Priority:** `P0` blocks a release if it fails; `P1` must be fixed or explicitly waived before release; `P2` is logged and triaged.
- **Moves funds** marks cases that sign a transaction. Those run on testnet only.
- **Hooks.** Web hooks name what Claude in Chrome's page reader shows, for example `button "Send"` or `textbox "Amount"`; when an element reads as plain text, use `fltA11y.tap("<label>")`. macOS hooks are `tool/drive.dart` commands, preferring `tap-key` for keyed controls, then `tap-label` for tooltips and labels, then `tap-text`. Keys follow the `<feature>:<detail>` convention in `.claude/context/conventions.md`.
- **Waits.** A step that depends on the chain says what to wait for and the limit, for example "wait up to 2 minutes for the status to read Success". Never sleep blindly.
- **Evidence.** Take a screenshot at each **Expected** check (Chrome screenshot, or `drive.dart screenshot`) and name it by case id.

## Known limits of automated runs

- **Steps that need a person.** The faucet's SMS code and native macOS file and save panels need Tyler during the run. Cases that depend on them say so; plan those cases into one attended block.
- **Two-party cases.** Within a lane, account A and account B are both that lane's accounts. The web lane uses B in a second Chrome profile with Claude in Chrome connected, or by signing out and in. The macOS lane imports B into the same wallet, or uses a second data folder where a case asks for a wallet holding only B.
- **Debug build differences.** The driver build is a debug build. On testnet it shows every BTC transaction as confirmed, which hides Replace By Fee and Rebroadcast, and it skips the "wallet not synced" check and prefills password fields. Cases that depend on those behaviours say they need a profile or release testnet build.
- **Hidden features.** Validator navigation, network voting, MOTHER, vBTC privacy actions and some smart contract features are behind flags or unreachable in the current release. Their cases are written in full and marked to record as `skipped` until the feature ships; a gating case checks they stay hidden.
- **Duplicate controls on macOS.** When the same unkeyed button appears more than once on a screen, `drive.dart` fails with "Too many elements". Cases name these steps; record them as `blocked` automation gaps, not product failures, until the controls get keys.
- **Temporary secrets.** Vault restore codes created during a run are kept in `$TMPDIR/vfx-run-<run id>/` with mode 600. Both lanes run on the same Mac and share that folder, because the cross-platform phase restores one lane's vault in the other. The folder is deleted at the end of the cross-platform phase.

## Lane schedule

Bitcoin testnet4 confirmations take from a few minutes to an hour, and vBTC deposits and withdrawals each need them. Each lane therefore starts its Bitcoin work first and fills the waits with the rest of the suite. Case order within a file is not run order.

1. **Setup.** Sign in and import the lane's accounts: the account A and B cases in `01-launch-auth.md` that the lane needs (TC-AUTH-016 on web; the desktop import cases on macOS), then the lane's BTC account (TC-BTC-001 on macOS, TC-BTC-002 on web).
2. **Bitcoin kickoff.** Start everything that waits on Bitcoin, without waiting for any of it:
   - Create two vBTC contracts (TC-BTC-022 twice on macOS, TC-BTC-023 twice on web). The MPC ceremony itself only needs the VFX chain and finishes in minutes.
   - Fund both contracts from the lane's BTC account (TC-BTC-026 on macOS, TC-BTC-027 on web), 0.0001 BTC each.
   - Start the lane's plain BTC send (TC-BTC-010 and TC-SEND-009 on macOS, TC-BTC-011 and TC-SEND-010 on web).
   - Write each started item into a **Pending BTC** table at the top of the lane's results file: case id, what was sent, the transaction id, the time started, and the check to run.
3. **Main body.** Run every other area of the lane, `P0` then `P1` then `P2`, following file order within a priority. At the end of each area file, and at least every 15 minutes, check the Pending BTC table: for each item whose transaction has confirmed on mempool.space, finish that case's remaining steps and expected checks, and mark it done.
4. **vBTC follow-ups.** As soon as both contracts show their deposited balance, interrupt the main body at the next case boundary and run the vBTC cases that need a funded contract: token list and detail, transfers, transfer validation, ownership, and bulk transfers (TC-BTC-030 to TC-BTC-041). These only need the VFX chain, so they finish quickly.
5. **Withdrawal kickoff.** Straight after the follow-ups, start the withdrawals to the treasury (TC-BTC-042 on macOS, TC-BTC-043 on web, then TC-BTC-044 and TC-BTC-047 to TC-BTC-052). Let the FROST signing finish, add each payout transaction to the Pending BTC table, and return to the main body.
6. **Close-out.** When the main body is done, wait for anything still pending, checking every 5 minutes for up to 60 minutes. An item still unconfirmed after that is recorded as `blocked` with its transaction id, not as a failure, unless the app itself reported an error.

Phase 2 uses the same idea: it starts the BTC sends in TC-XP-004 and TC-XP-005 first, then runs TC-XP-007 (vBTC from macOS to web) and starts the withdrawal in TC-XP-010 straight after it, and runs the VFX, remaining vBTC, NFT, token, domain and vault cases while those confirm. The Bitcoin checks come last.

## Running a release pass

A pass has two phases. Phase 1 runs the two lanes in parallel, one Claude agent per lane. Phase 2 runs the cross-platform cases with one agent that drives both the browser and the desktop app.

1. Record the build under test (version string from the app, commit hash) and the run id. Fund both lanes to the minimum VFX balances.
2. **Pre-run BTC funding.** One agent opens the web wallet with `?automation=1`, logs in with `TEST_BTC_TREASURY_WIF` through `Bitcoin Private Key / WIF Key` (TC-AUTH-018), choosing `Bech32 (Native SegWit - P2WPKH)` rather than `I don't know` (see TC-AUTH-019), and sends each lane's `TEST_BTC_ADDRESS` enough to reach 0.0005 testnet BTC, as in TC-SEND-010. It waits up to 60 minutes for both sends to confirm, then logs out. Because the lanes start only after this, the run begins with confirmed BTC on both sides.
3. **Phase 1, lanes in parallel.** The web agent runs every case that lists `Web`; the macOS agent runs every case that lists `macOS`. A case listing both platforms is run once in each lane. Each lane skips cases marked `Phase: cross-platform`. Each lane follows the stages in "Lane schedule" below, which starts the slow Bitcoin work first so its confirmations overlap with everything else. The two lanes share nothing on chain, so they never wait for each other.
4. **Phase 2, cross-platform.** After both lanes finish, one agent keeps the web lane's browser session and the macOS lane's driver app open and runs `13-cross-platform.md`. The few cases in other files marked `Phase: cross-platform` are run from inside it (TC-SC-045 from TC-XP-011, TC-VAULT-026 and TC-VAULT-027 from TC-XP-016), so each is run once. It reads both account files.
5. On a failure, capture the screenshot, the visible error text, and for macOS the tail of the `flutter run` log, then continue with the next case unless the failure blocks the rest of the area.
6. Each phase writes its own results file: `docs/testing/runs/<run-id>-web.md`, `docs/testing/runs/<run-id>-macos.md` and `docs/testing/runs/<run-id>-cross.md`. Each has one row per case run in that phase: id, result (`pass`, `fail`, `blocked`, `skipped`), and a one-line note for anything other than pass. A case listing both platforms therefore has a row in each lane's file.
7. **Return leftover BTC.** After phase 2, the same agent logs in with each lane's BTC key in turn and sends anything above 0.0002 testnet BTC back to `TEST_BTC_TREASURY_ADDRESS`, so the treasury keeps the balance between runs. Record the treasury balance at the start and end of the run in the cross-platform results file.
8. The release is blocked while any `P0` case fails in any of the three files.
