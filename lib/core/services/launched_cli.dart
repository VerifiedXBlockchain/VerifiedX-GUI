import 'dart:io';

import 'package:process_run/shell.dart';

/// Remembers the CLI process this GUI session launched, so the GUI can stop
/// it when the node refuses SendExit (a locked encrypted wallet answers 401).
/// A CLI the GUI only reattached to is never recorded and never terminated.
class LaunchedCli {
  static Shell? _macShell;
  static String? _windowsExecutablePath;

  /// Records the shell that runs the macOS CLI binary directly.
  static void launchedOnMac(Shell shell) {
    _macShell = shell;
    _windowsExecutablePath = null;
  }

  /// Records the CLI binary VFXLauncher.exe starts on Windows. The launcher
  /// is a separate process, so the CLI is found again by its executable path.
  static void launchedOnWindows(String executablePath) {
    _windowsExecutablePath = executablePath;
    _macShell = null;
  }

  /// Terminates the CLI this session launched. Returns false when this
  /// session launched none or the termination could not be delivered.
  static Future<bool> terminate() async {
    final shell = _macShell;
    if (shell != null) {
      // SIGTERM lets the .NET runtime run its exit handlers.
      return shell.kill(ProcessSignal.sigterm);
    }

    final executablePath = _windowsExecutablePath;
    if (executablePath != null && Platform.isWindows) {
      final quotedPath = executablePath.replaceAll("'", "''");
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        "Get-Process -Name VerifiedXCore -ErrorAction SilentlyContinue | "
            "Where-Object { \$_.Path -eq '$quotedPath' } | Stop-Process -Force",
      ]);
      if (result.exitCode != 0) {
        print("Terminating the CLI failed: ${result.stderr}");
        return false;
      }
      return true;
    }

    return false;
  }
}
