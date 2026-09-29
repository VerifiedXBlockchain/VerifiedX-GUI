import 'dart:io';

import 'env.dart';

/// Where the Core CLI keeps its data on macOS, and how automation builds keep
/// integration tests away from the real databases.
///
/// The CLI derives every data folder from the user's home directory
/// (`~/rbxtest/DatabasesTestNet`, `~/rbxtest/ConfigTestNet`, ...; see
/// `Utilities/GetPathUtility.cs` in VerifiedX-Core), and .NET reads that home
/// from `$HOME`. The CLI has no data-folder argument, and its `CustomPath`
/// config key lives inside that same folder. Automation builds therefore
/// launch the CLI with `HOME` set to [cliHome], a dedicated folder under the
/// real home, and the GUI's macOS path helpers resolve against the same
/// folder through [fromDocuments] so both sides agree.
class DataHome {
  DataHome._();

  /// Folder under the real home that holds the automation data. The CLI
  /// creates `rbxtest/` (testnet) or `rbx/` (mainnet) inside it.
  static const automationFolder =
      'Library/Application Support/vfx-gui-automation';

  /// The home directory the CLI derives its data folders from, given the
  /// real [userHome].
  static String resolve(String userHome, {required bool isAutomation}) {
    return isAutomation ? '$userHome/$automationFolder' : userHome;
  }

  /// Rewrites [documentsPath] (`~/Documents`) to a CLI data path the way the
  /// GUI's macOS helpers have always done it, replacing `/Documents` with
  /// [replacement] (`/rbxtest`, `/vfx`, ...). With [automationHome] set,
  /// [replacement] is appended to it instead.
  static String rewriteDocumentsPath(
    String documentsPath,
    String replacement, {
    String? automationHome,
  }) {
    if (automationHome == null) {
      return documentsPath.replaceAll('/Documents', replacement);
    }
    return '$automationHome$replacement';
  }

  /// [resolve] for this process. Throws when `HOME` is unset, because the CLI
  /// would then fall back to the real home and silently defeat the isolation.
  ///
  /// The launch site creates this directory before starting the CLI: .NET
  /// verifies the home directory and returns an empty string for a missing
  /// one, which would send the CLI to `/rbxtest` and crash it.
  static String cliHome() {
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      throw StateError(
          'HOME is not set; cannot resolve the Core CLI data folder.');
    }
    return resolve(home, isAutomation: Env.isAutomation);
  }

  /// [rewriteDocumentsPath] for this process. Identical to the historical
  /// `replaceAll` outside automation.
  static String fromDocuments(String documentsPath, String replacement) {
    return rewriteDocumentsPath(
      documentsPath,
      replacement,
      automationHome: Env.isAutomation ? cliHome() : null,
    );
  }
}
