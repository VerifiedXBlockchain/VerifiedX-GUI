import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/web/providers/web_currency_segmented_button_provider.dart';

void main() {
  group('currencyAfterVfxSelection', () {
    test('BTC or Vault left from the previous account goes back to VFX', () {
      expect(currencyAfterVfxSelection(WebCurrencyType.btc), WebCurrencyType.vfx);
      expect(currencyAfterVfxSelection(WebCurrencyType.vault), WebCurrencyType.vfx);
    });

    test('VFX and All already describe the VFX address and stay', () {
      expect(currencyAfterVfxSelection(WebCurrencyType.vfx), WebCurrencyType.vfx);
      expect(currencyAfterVfxSelection(WebCurrencyType.any), WebCurrencyType.any);
    });
  });
}
