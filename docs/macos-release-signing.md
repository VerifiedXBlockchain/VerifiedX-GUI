# macOS release signing and notarization

The macOS wallet ships as a disk image downloaded from the web. Gatekeeper only opens it without warnings when the app is signed with a Developer ID certificate, runs with the hardened runtime, and has been notarized by Apple. `make package_m1` and `make package_mac` do all three.

## Why signing runs last

A code signature seals every file in the app bundle. The packaging step copies the Core CLI and the BIP39 wordlists into the bundle after Xcode exports it, which breaks the signature Xcode applied. `scripts/sign_macos_app.sh` therefore re-signs the whole bundle once the payload is in place, and nothing may be added to the bundle after it runs.

## Bundle layout

| Path | Content |
|------|---------|
| `Contents/MacOS/` | The Flutter executable only. Data files here break the signature once the app is copied out of a disk image. |
| `Contents/Frameworks/` | Flutter engine and plugin frameworks. |
| `Contents/Resources/VFXCore/` | Core CLI publish output (`VerifiedXCore` plus its native libraries). |
| `Contents/Resources/BIP39/` | Wordlists. The GUI starts the CLI with `Contents/Resources` as its working directory, and the CLI reads `BIP39/wordlist` relative to that. |

## One-time setup

1. **Developer ID Application certificate.** Only the Account Holder of the Apple Developer team can create one (Certificates, Identifiers & Profiles, or Xcode > Settings > Accounts > Manage Certificates). Install it, with its private key, in the login keychain of the build machine. `security find-identity -v -p codesigning` must list a `Developer ID Application: ...` identity. An `Apple Development` certificate is not accepted by Gatekeeper.
2. **Notary credentials.** Create an app-specific password at account.apple.com for the Apple ID on the team, then store it in the keychain:

   ```sh
   xcrun notarytool store-credentials vfx-notary --apple-id <apple id> --team-id <TEAMID>
   ```

3. **Environment.** Export both values in the shell that runs `make`:

   ```sh
   export MACOS_SIGN_IDENTITY="Developer ID Application: <Team Name> (<TEAMID>)"
   export MACOS_NOTARY_PROFILE="vfx-notary"
   ```

## Release flow

One command builds everything:

```sh
make release_macos_testnet
make release_macos_mainnet
```

`scripts/package_macos.sh` builds the Flutter app and the Core CLI, assembles the bundle, signs it, builds the disk image, notarizes it and staples the ticket. Artifacts land in `installers/exports/<network>/` with a `BUILD-INFO-<arch>.txt` that records what went into them.

Nothing depends on what was last opened in Xcode or checked out in the Core CLI repo:

| Input | Where it comes from |
|-------|---------------------|
| Network | The command. It selects the Xcode scheme and passes the dart-define on the command line, which outranks `EnvironmentConfig.xcconfig`. |
| Bundle version | `APP_V` in `lib/core/app_constants.dart`. The version in the Xcode project is ignored. |
| Core CLI | A clean export of a git ref, fetched from origin: `origin/main` for mainnet, `origin/testnet` for testnet. Uncommitted changes in the Core checkout are never built. Override with `--core-ref <branch, tag or commit>`. |
| CLI architecture | This machine's, or `--arch arm64` / `--arch x64`. The Flutter app is universal and .NET publishes for either architecture, so one Mac builds both installers. |

Options go through `ARGS`, for example `make release_macos_testnet ARGS="--core-ref beta7.1.0"`.

Guards that stop the build:

- A mainnet build with uncommitted GUI changes, unless `--allow-dirty` is passed. Other networks print the changes and record them in the build info.
- A mainnet build whose Core CLI ref forces testnet in `Program.cs`.
- A bundle version that differs from `APP_V`, or a binary built for the wrong architecture.
- Any binary in the bundle that is unsigned or signed by another team.

A native library in the CLI build that lacks the target architecture does not stop the build. It is reported as a warning and under `cannot load` in the build info, because the CLI starts without it and fails only in the feature that needs it.

`--skip-notarize` stops after signing. Use it to test the pipeline before the Developer ID certificate exists; the result is blocked by Gatekeeper on other Macs.

A failed step prints the end of its log and the path to the full log in `build/macos-package/logs/`. A rejected notarization prints Apple's log, which names each offending file.

### Manual flow

`make package_m1` and `make package_mac` still work for an app exported from Xcode into `installers/resources/Runner/`. They build the CLI from the Core checkout as it is, then sign and notarize the same way.

## Entitlements

| File | Applies to | Grants |
|------|------------|--------|
| `macos/Runner/Release.entitlements` | The app | No hardened runtime exceptions. Flutter release builds are compiled ahead of time and need none. |
| `macos/Runner/VFXCore.entitlements` | `VerifiedXCore` | JIT and unsigned executable memory, which the .NET runtime needs. Library validation stays on, so the CLI only loads libraries signed by the same team. |

## Checking a build by hand

```sh
codesign --verify --deep --strict --verbose=2 <VFXWallet.app>
codesign --display --verbose=2 --entitlements - <VFXWallet.app>/Contents/Resources/VFXCore/VerifiedXCore
xcrun stapler validate <installer.dmg>
spctl --assess --type open --context context:primary-signature --verbose=2 <installer.dmg>
```

The real test is a download: fetch the disk image with a browser on a Mac that has never run the wallet, drag the app to Applications and open it with a double click.

## Disk image window

`installers/dmg/config.json` lays out the window and `background.png` / `background@2x.png` are its artwork. The two are tied together: Finder draws the icons and their names on top of the image, so moving an icon means moving its slot in the art.

| Setting | Value | Note |
|---------|-------|------|
| Window | 600 x 400 | Same as the image, so no blank strip shows beside or below it. |
| Icons | 80 px, centered at (170, 220) and (430, 220) | Finder uses the coordinates as icon centers. An icon placed too close to an edge makes Finder shift every icon. |
| Visible height | 394 px with Finder defaults, about 318 px with the status, tab and path bars on | The bars are the viewer's Finder settings. Nothing that must be read sits below y = 300. |
| Name band | Blue Dark `#497C9F` | Finder draws names in black in light mode and white in dark mode; this color keeps both readable. |

The artwork source is HTML in the brand toolkit, `materials/installers/macos-dmg/background.html`, with the render commands in its header. `preview.html` beside it renders a mock-up of the Finder window for review. Copy both rendered PNGs here after a change.

The image has no `install.command`. A notarized app opens with a double click, and a script that clears the quarantine flag would skip the Gatekeeper check the notarization exists for.

## Local changes to an installed app

`make redeploy_cli` overwrites the CLI inside `/Applications/VFXWallet.app`, which invalidates the signature of a notarized install. Use it only on development machines.
