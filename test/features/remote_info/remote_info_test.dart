import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/remote_info/models/remote_info.dart';

Map<String, dynamic> _payload(Map<String, dynamic>? snapshot) => {
      "gui": {"version": "4.0.3", "tag": "beta4.0.3", "url": "https://example.com/gui", "date": "2023-11-25"},
      "cli": {"version": "4.0.1", "tag": "beta4.0.1", "url": "https://example.com/cli", "date": "2023-11-25"},
      if (snapshot != null) "snapshot": snapshot,
    };

void main() {
  group('RemoteInfo.fromJson', () {
    test('parses the testnet feed, whose snapshot url is null', () {
      final info = RemoteInfo.fromJson(_payload({"height": 212050, "url": null, "date": "2023-06-11"}));

      expect(info.snapshot!.height, 212050);
      expect(info.snapshot!.url, isNull);
      expect(info.gui.version, '4.0.3');
    });

    test('parses a feed with no snapshot block', () {
      final info = RemoteInfo.fromJson(_payload(null));

      expect(info.snapshot, isNull);
      expect(info.cli.version, '4.0.1');
    });

    test('keeps the snapshot url when the mainnet feed sends one', () {
      final info = RemoteInfo.fromJson(_payload({"height": 4333740, "url": "https://example.com/snap.zip", "date": "2023-06-11"}));

      expect(info.snapshot!.url, 'https://example.com/snap.zip');
    });
  });
}
