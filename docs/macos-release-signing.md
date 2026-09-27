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

1. Archive and export the app from Xcode into `installers/resources/Runner/` as before.
2. Run `make package_m1` (Apple silicon) or `make package_mac` (Intel). The target builds the CLI, copies the payload into the bundle, signs, builds the disk image, notarizes it and staples the ticket.
3. The Core CLI zip is cut from the signed bundle, so its binaries carry the same signature and are covered by the same notarization.

Both scripts stop on the first failure. A rejected notarization prints Apple's log, which names each offending file.

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

## Local changes to an installed app

`make redeploy_cli` overwrites the CLI inside `/Applications/VFXWallet.app`, which invalidates the signature of a notarized install. Use it only on development machines.
