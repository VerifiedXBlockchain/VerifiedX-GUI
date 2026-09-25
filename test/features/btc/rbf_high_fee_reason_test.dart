import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/btc/utils.dart';

void main() {
  group('rbfHighFeeReason', () {
    test('returns the fee sentence of the 10 percent refusal', () {
      const message = 'Fee of 5400 sats is more than 10% of the amount (20000 sats). Pass allowHighFee=true to send anyway.';

      expect(rbfHighFeeReason(message), 'Fee of 5400 sats is more than 10% of the amount (20000 sats).');
    });

    test('ignores other refusals', () {
      expect(rbfHighFeeReason('Fee rate 3000 sat/vB exceeds the maximum of 2000 sat/vB (config MaxBtcFeeRateSatPerVb).'), isNull);
      expect(rbfHighFeeReason('Incorrect URL parameters'), isNull);
      expect(rbfHighFeeReason(null), isNull);
    });
  });
}
