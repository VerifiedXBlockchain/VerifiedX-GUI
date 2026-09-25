import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/mother/services/mother_service.dart';

void main() {
  group('MotherData.fromResponse', () {
    test('recognises a host from the reply without a password', () {
      final data = MotherData.fromResponse({'Id': 1, 'Name': 'Home', 'StartDate': 1727280000});

      expect(data?.name, 'Home');
    });

    test('returns null when the wallet is not a host', () {
      expect(MotherData.fromResponse({}), isNull);
    });
  });

  group('motherActionFailure', () {
    test('is null on success', () {
      expect(motherActionFailure({'Result': 'Success', 'Message': 'Mother setup has been completed.'}), isNull);
    });

    test('returns the node message on a refusal', () {
      expect(
        motherActionFailure({'Result': 'Fail', 'Message': 'Mother address and password may not contain line breaks.'}),
        'Mother address and password may not contain line breaks.',
      );
    });

    test('returns an empty reason when the node gave none', () {
      expect(motherActionFailure({}), '');
    });
  });
}
