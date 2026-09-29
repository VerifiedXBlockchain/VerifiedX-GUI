import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/core/data_home.dart';

void main() {
  const userHome = '/Users/someone';

  group('DataHome.resolve', () {
    test('is the real home outside automation', () {
      expect(DataHome.resolve(userHome, isAutomation: false), userHome);
    });

    test('is a dedicated folder under Application Support in automation', () {
      expect(
        DataHome.resolve(userHome, isAutomation: true),
        '/Users/someone/Library/Application Support/vfx-gui-automation',
      );
    });
  });

  group('DataHome.rewriteDocumentsPath', () {
    test('replaces /Documents the way the helpers always did', () {
      expect(
        DataHome.rewriteDocumentsPath('/Users/someone/Documents', '/rbxtest'),
        '/Users/someone/rbxtest',
      );
      expect(
        DataHome.rewriteDocumentsPath(
          '/Users/someone/Documents',
          '/RBXTest/ConfigTestNet/config.txt',
        ),
        '/Users/someone/RBXTest/ConfigTestNet/config.txt',
      );
    });

    test('appends the replacement to the automation home instead', () {
      expect(
        DataHome.rewriteDocumentsPath(
          '/Users/someone/Documents',
          '/rbxtest',
          automationHome: '/tmp/automation',
        ),
        '/tmp/automation/rbxtest',
      );
    });
  });

  group('without the AUTOMATION dart-define', () {
    test('cliHome is the real HOME', () {
      expect(DataHome.cliHome(), Platform.environment['HOME']);
    });

    test('fromDocuments is the plain replacement', () {
      expect(
        DataHome.fromDocuments('/Users/someone/Documents', '/vfx'),
        '/Users/someone/vfx',
      );
    });
  });
}
