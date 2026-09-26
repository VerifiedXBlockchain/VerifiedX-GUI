import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rbx_wallet/core/components/boot_container.dart';
import 'package:rbx_wallet/core/services/launched_cli.dart';
import 'package:rbx_wallet/features/bridge/services/bridge_service.dart';
import 'package:rbx_wallet/main.dart' as app;

import 'helpers.dart';

/// Binary name of the Core CLI the desktop app launches; see `getCliPath()`
/// in lib/core/providers/session_provider.dart.
const coreCliProcessName = 'VerifiedXCore';

/// Set once the test has confirmed no CLI was running and started the app,
/// so teardown only ever stops a CLI this test launched.
bool cliLaunchedByTest = false;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final running = await Process.run('pgrep', ['-fl', coreCliProcessName]);
    if (running.exitCode == 0) {
      fail('A Core CLI ($coreCliProcessName) is already running. Quit the VFX '
          'wallet before running integration tests so the test does not start '
          'a second CLI against the same data:\n${running.stdout}');
    }
  });

  tearDownAll(() async {
    if (!cliLaunchedByTest) {
      return;
    }
    // The CLI is a child process that would outlive the test app. Ask it to
    // exit the way the app does on quit, then terminate the launched process
    // in case it was still booting and could not answer.
    await BridgeService().killCli();
    await LaunchedCli.terminate();
  });

  testWidgets(
    'desktop app boots to the first screen',
    (tester) async {
      final stopwatch = Stopwatch()..start();
      cliLaunchedByTest = true;
      app.main(const []);

      await pumpUntilFound(
        tester,
        find.byType(BootContainer),
        timeout: const Duration(seconds: 30),
      );
      tester.printToConsole(
          '[smoke] boot screen rendered after ${stopwatch.elapsed}');
      expect(
        find.textContaining('[TESTNET]'),
        findsWidgets,
        reason: 'the TESTNET dart-define did not reach the app',
      );

      // The boot screen clears once the launched CLI answers on its API.
      await pumpUntilGone(
        tester,
        find.byType(BootContainer),
        timeout: const Duration(minutes: 3),
      );
      tester.printToConsole(
          '[smoke] Core CLI answered and boot screen cleared after '
          '${stopwatch.elapsed}');
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
