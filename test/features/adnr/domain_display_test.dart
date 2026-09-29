import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/adnr/utils/domain_display.dart';

void main() {
  test('does not double a suffix the stored name already has', () {
    expect(domainWithSuffix('qa20260927aw1.vfx', '.vfx'), 'qa20260927aw1.vfx');
    expect(domainWithSuffix('qa20260927awb1.btc', '.btc'), 'qa20260927awb1.btc');
    expect(domainWithSuffix('Name.VFX', '.vfx'), 'Name.VFX');
  });

  test('adds the suffix when the name lacks it', () {
    expect(domainWithSuffix('qa20260927aw1', '.vfx'), 'qa20260927aw1.vfx');
    expect(domainWithSuffix('qa20260927awb1', '.btc'), 'qa20260927awb1.btc');
    expect(domainWithSuffix(' spaced ', '.vfx'), 'spaced.vfx');
  });

  test('a different suffix is not mistaken for the right one', () {
    expect(domainWithSuffix('name.btc', '.vfx'), 'name.btc.vfx');
  });
}
