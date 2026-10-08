import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/features/send/components/send_form_prefill.dart';

void main() {
  group('SendFormPrefill', () {
    late TextEditingController addressController;
    late TextEditingController amountController;
    late ValueNotifier<int> rebuildTick;

    setUp(() {
      addressController = TextEditingController();
      amountController = TextEditingController();
      rebuildTick = ValueNotifier(0);
    });

    tearDown(() {
      addressController.dispose();
      amountController.dispose();
      rebuildTick.dispose();
    });

    Widget harness() {
      return MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: rebuildTick,
          builder: (context, tick, _) => SendFormPrefill(
            addressController: addressController,
            amountController: amountController,
            address: 'xLinkRecipient',
            amount: '5.0',
            child: Text('rebuild $tick'),
          ),
        ),
      );
    }

    testWidgets('fills the form from the link', (tester) async {
      await tester.pumpWidget(harness());

      expect(addressController.text, 'xLinkRecipient');
      expect(amountController.text, '5.0');
    });

    testWidgets('keeps the user edit when the screen rebuilds', (tester) async {
      await tester.pumpWidget(harness());

      addressController.text = 'xEditedRecipient';
      amountController.text = '1.25';

      rebuildTick.value++;
      await tester.pump();
      rebuildTick.value++;
      await tester.pump();

      expect(find.text('rebuild 2'), findsOneWidget);
      expect(addressController.text, 'xEditedRecipient');
      expect(amountController.text, '1.25');
    });
  });
}
