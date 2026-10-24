import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/models/vbtc_multi_withdrawal_result.dart';

void main() {
  group('VbtcMultiWithdrawalPreview', () {
    test("reads Core's allocation and its attested vaults", () {
      final preview = VbtcMultiWithdrawalPreview.fromJson({
        'Success': true,
        'Allocations': [
          {'SCUID': 'w:1', 'Amount': 0.0002},
          {'SCUID': 'w:2', 'Amount': 0.0001},
        ],
        'AttestedContracts': ['w:1', 'w:2'],
      });

      expect(preview.allocations.map((a) => a.scIdentifier), ['w:1', 'w:2']);
      expect(preview.unwatchedVaults, isEmpty);
    });

    test('names a share on a vault the chain does not watch', () {
      final preview = VbtcMultiWithdrawalPreview.fromJson({
        'Allocations': [
          {'SCUID': 'legacy:1', 'Amount': 0.0003},
          {'SCUID': 'w:2', 'Amount': 0.0001},
        ],
        'AttestedContracts': ['w:2'],
      });

      expect(preview.unwatchedVaults, ['legacy:1']);
    });

    test('treats a missing attested list or allocation as not safe to send', () {
      expect(
        VbtcMultiWithdrawalPreview.fromJson({
          'Allocations': [
            {'SCUID': 'w:1', 'Amount': 0.0002},
          ],
        }).unwatchedVaults,
        ['w:1'],
      );
      expect(VbtcMultiWithdrawalPreview.fromJson({'Success': true}).unwatchedVaults, isNotEmpty);
    });
  });
}
