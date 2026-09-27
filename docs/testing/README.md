# Release test suite

This suite lists every feature of the desktop GUI (macOS) and the web wallet that must be tested before an update ships, as full test cases that Claude runs. Each area has its own file below; this page holds the conventions every file follows, the environment and test data a run needs, and how results are recorded.

## Scope

- **Platforms:** the web wallet and the macOS desktop GUI. Windows is out of scope.
- **Out of scope:** P2P shop features (P2P Auctions, web shops, desktop auction houses, remote shops, listings, bids and shop chat).
- **Network:** testnet, with real transactions. Every flow that moves funds is executed end to end on testnet and confirmed on chain. Mainnet gets only the read-only checks marked `Mainnet smoke`, and nothing is ever signed or sent on mainnet.
- **Runner:** Claude. Web cases run through Claude in Chrome; macOS cases run through `tool/drive.dart` against the Flutter Driver build. Both are described in `docs/automation.md`, which is required reading before a run.

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
| **Total** | | **460** | **86** | **233** | **141** |

Questions raised while writing the cases, with the case each belongs to, are collected in [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md). Several are suspected bugs.

## Environment

**Web.** Build or serve the testnet automation build (`make run_web_automation`, or a `flutter build web --dart-define TESTNET=true --dart-define AUTOMATION=true` served from `build/web` on port 42069) and open `http://localhost:42069/?automation=1`. The parameter must be present on every fresh load. Keep the tab visible. Screens that embed an iframe (on-ramp and payment providers) do not render in automation mode; the cases that need them say so and are run against the deployed testnet web wallet instead, read-only.

**macOS.** Quit any running VFX wallet first; `pgrep -fl VerifiedXCore` must be empty. Start `make run_macos_driver` with its output redirected to a file, read the Observatory URL from it, and drive the app with `tool/drive.dart`. Automation builds keep the Core CLI data under `~/Library/Application Support/vfx-gui-automation` and the preferences under an `automation.` prefix, so the real wallet is never touched. Delete that folder for a clean-state run. The first run in a fresh folder downloads about 250 MB and syncs testnet, so allow time before cases that need a synced chain.

**Mainnet smoke.** Only the cases tagged `Mainnet smoke` run against mainnet, on the production web wallet and a normal desktop build, and only read state.

## Test data

Test accounts are secrets and never go in this repo. A run reads them from `~/.config/vfx-release-tests/accounts.env`, which Tyler maintains. Claude reads values from that file when a step needs them, types them only into the local app under test, and never writes them into results, screenshots names, commit messages or chat. Expected variables:

| Variable | Meaning |
|---|---|
| `TEST_VFX_A_PRIVKEY`, `TEST_VFX_A_ADDRESS` | Funded testnet VFX account A (sender in most cases) |
| `TEST_VFX_B_PRIVKEY`, `TEST_VFX_B_ADDRESS` | Testnet VFX account B (receiver and second party) |
| `TEST_MNEMONIC` | 12 or 24-word testnet HD mnemonic |
| `TEST_WEB_EMAIL`, `TEST_WEB_PASSWORD` | Email and password login for the web wallet |
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

Minimum balances before a run: account A holds at least 200 testnet VFX, and the BTC account holds enough testnet BTC for one tokenization plus fees. The faucet cases in `12-bridge-payments-faucet-keygen.md` top VFX up. Cases that create on-chain objects (domains, tokens, NFTs, vault accounts) use names suffixed with the run id, for example `qa-20261001a`, so repeated runs never collide.

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

- **IDs** are `TC-<AREA>-<NNN>` and never reused. Area codes: `AUTH`, `DASH`, `SEND`, `BTC`, `PRV`, `VAULT`, `ADNR`, `TOKEN`, `SC`, `NET`, `MISC`.
- **Platforms** is `Web`, `macOS` or both. When the two differ, the steps give each platform's hook on its own line.
- **Priority:** `P0` blocks a release if it fails; `P1` must be fixed or explicitly waived before release; `P2` is logged and triaged.
- **Moves funds** marks cases that sign a transaction. Those run on testnet only.
- **Hooks.** Web hooks name what Claude in Chrome's page reader shows, for example `button "Send"` or `textbox "Amount"`; when an element reads as plain text, use `fltA11y.tap("<label>")`. macOS hooks are `tool/drive.dart` commands, preferring `tap-key` for keyed controls, then `tap-label` for tooltips and labels, then `tap-text`. Keys follow the `<feature>:<detail>` convention in `.claude/context/conventions.md`.
- **Waits.** A step that depends on the chain says what to wait for and the limit, for example "wait up to 2 minutes for the status to read Success". Never sleep blindly.
- **Evidence.** Take a screenshot at each **Expected** check (Chrome screenshot, or `drive.dart screenshot`) and name it by case id.

## Known limits of automated runs

- **Steps that need a person.** The faucet's SMS code and native macOS file and save panels need Tyler during the run. Cases that depend on them say so; plan those cases into one attended block.
- **Two-party cases.** Transfer cases that need a second party use account B in a second Chrome profile with Claude in Chrome connected, or the macOS app as the other side. One Mac runs one Core CLI, so a desktop-to-desktop case needs a second Mac.
- **Debug build differences.** The driver build is a debug build. On testnet it shows every BTC transaction as confirmed, which hides Replace By Fee and Rebroadcast, and it skips the "wallet not synced" check and prefills password fields. Cases that depend on those behaviours say they need a profile or release testnet build.
- **Hidden features.** Validator navigation, network voting, MOTHER, vBTC privacy actions and some smart contract features are behind flags or unreachable in the current release. Their cases are written in full and marked to record as `skipped` until the feature ships; a gating case checks they stay hidden.
- **Duplicate controls on macOS.** When the same unkeyed button appears more than once on a screen, `drive.dart` fails with "Too many elements". Cases name these steps; record them as `blocked` automation gaps, not product failures, until the controls get keys.
- **Temporary secrets.** Vault restore codes created during a run are kept in `$TMPDIR/vfx-run-<run id>/` with mode 600 and deleted by the last vault case.

## Running a release pass

1. Record the build under test (version string from the app, commit hash) and the run id.
2. Run all `P0` cases on both platforms, then `P1`, then `P2`. Within a priority, follow the file order, because later areas assume accounts and objects created earlier.
3. On a failure, capture the screenshot, the visible error text, and for macOS the tail of the `flutter run` log, then continue with the next case unless the failure blocks the rest of the area.
4. Write the results to `docs/testing/runs/<run-id>.md` with one row per case: id, platform, result (`pass`, `fail`, `blocked`, `skipped`), and a one-line note for anything other than pass.
5. The release is blocked while any `P0` case fails.
