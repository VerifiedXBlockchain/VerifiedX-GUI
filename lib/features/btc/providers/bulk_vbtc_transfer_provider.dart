import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/features/btc/models/vbtc_input.dart';
import 'package:collection/collection.dart';

class BulkVbtcTransferProvider extends StateNotifier<List<VBtcInput>> {
  final Ref ref;

  List<TextEditingController> controllers = [];
  TextEditingController addressController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  BulkVbtcTransferProvider(this.ref) : super([]);

  void add({required String scId, required double amount}) {
    final exists = state.firstWhereOrNull((input) => input.scId == scId) != null;
    if (exists) {
      return;
    }

    state = [
      ...state,
      VBtcInput(
        scId: scId,
        vfxFromAddress: "",
        vfxToAddress: "",
        amount: amount,
      ),
    ];

    controllers.add(TextEditingController(text: "0"));
  }

  void remove(String scId) {
    state = [...state]..removeWhere((element) => element.scId == scId);
    controllers.removeLast();
  }

  void updateAmount(int index, double amount) {
    final updatedEntry = [...state][index].updateAmount(amount);
    state = [...state]
      ..removeAt(index)
      ..insert(index, updatedEntry);
  }

  void setAllToZero() {
    state = [...state].map((e) => e.updateAmount(0)).toList();
  }
}

final bulkVbtcTransferProvider = StateNotifierProvider<BulkVbtcTransferProvider, List<VBtcInput>>((ref) {
  return BulkVbtcTransferProvider(ref);
});
