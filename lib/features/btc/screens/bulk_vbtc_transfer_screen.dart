import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rbx_wallet/core/app_constants.dart';
import 'package:rbx_wallet/core/base_screen.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/core/dialogs.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:rbx_wallet/core/theme/components.dart';
import 'package:rbx_wallet/features/btc/providers/tokenized_bitcoin_list_provider.dart';
import 'package:rbx_wallet/utils/toast.dart';
import '../../../core/utils/tx_refresh.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/validation.dart';
import '../../bridge/models/log_entry.dart';
import '../../bridge/providers/log_provider.dart';
import '../../global_loader/global_loading_provider.dart';
import '../models/tokenized_bitcoin.dart';
import '../models/vbtc_multi_transfer_result.dart';
import '../services/vbtc_v2_service.dart';
import '../utils.dart';

/// Sends one vBTC amount drawn from every V2 token the current wallet can
/// spend from. The CLI allocates the inputs itself, so the user only picks a
/// total and a recipient.
///
/// Desktop-only for now: the web wallet needs Spyglass multi-transfer
/// endpoints before it can build this transaction.
class BulkVbtcTransferScreen extends BaseStatefulScreen {
  const BulkVbtcTransferScreen({super.key})
      : super(horizontalPadding: 16, verticalPadding: 8);

  @override
  BulkVbtcTransferScreenState createState() => BulkVbtcTransferScreenState();
}

class BulkVbtcTransferScreenState
    extends BaseScreenState<BulkVbtcTransferScreen> {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    addressController.dispose();
    super.dispose();
  }

  /// V2 tokens the current wallet holds a spendable balance on. `myBalance`
  /// is the CLI's AvailableBalance, so anything locked in a pending
  /// withdrawal is already excluded. Outflows still in the mempool are not;
  /// the CLI reports those as an insufficient-balance error at send time.
  List<TokenizedBitcoin> _spendableTokens() {
    return ref
        .watch(tokenizedBitcoinListProvider)
        .where((t) => t.version >= 2 && t.myBalance > 0)
        .toList();
  }

  /// Summed then re-parsed at 8 decimals so the label and the MAX button
  /// never show floating-point noise.
  double _available(List<TokenizedBitcoin> tokens) {
    final sum = tokens.fold<double>(0.0, (total, t) => total + t.myBalance);
    return double.parse(sum.toStringAsFixed(8));
  }

  @override
  AppBar? appBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context).btcBulkTransferTitle),
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Widget body(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = _spendableTokens();
    final available = _available(tokens);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.btcBulkIntro,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          AppCard(
            fullWidth: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.btcBulkAvailableTotal),
                Text(
                  "$available vBTC",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.btcOrange,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: amountController,
                        validator: (value) =>
                            formValidatorVbtcMultiAmount(value, available),
                        decoration: InputDecoration(
                          label: Text(l10n.btcBulkAmountLabel),
                          hintText: l10n.btcBulkAmountHint,
                          suffixText: "vBTC",
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: AppButton(
                        label: l10n.r3fMaxLabel(available.toString()),
                        type: AppButtonType.Text,
                        underlined: true,
                        onPressed: () {
                          amountController.text = available.toString();
                        },
                        variant: AppColorVariant.Btc,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  validator: formValidatorVbtcRecipient,
                  decoration: InputDecoration(
                    label: Text(l10n.btcBulkTransferToLabel),
                    hintText: l10n.btcBulkTransferToHint,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9.]')),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: l10n.actionCancel,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                variant: AppColorVariant.Light,
                type: AppButtonType.Text,
              ),
              SizedBox(width: 8),
              AppButton(
                label: l10n.actionSend,
                onPressed: () => _send(context, tokens),
                variant: AppColorVariant.Btc,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _send(BuildContext context, List<TokenizedBitcoin> tokens) async {
    final l10n = AppLocalizations.of(context);

    if (!formKey.currentState!.validate()) {
      return;
    }

    final currentWallet = ref.read(sessionProvider).currentWallet;
    if (currentWallet == null) {
      Toast.error(l10n.btcBulkNoVfxSelectedToast);
      return;
    }
    // The CLI rejects Vault senders too, but that message only arrives after
    // the request round-trips; catching it here keeps the form responsive.
    if (currentWallet.isReserved) {
      Toast.error(l10n.btcBulkReserveSenderInvalid);
      return;
    }
    if (currentWallet.balance < MIN_RBX_FOR_SC_ACTION) {
      Toast.error(l10n.r3fInsufficientVfxBalance);
      return;
    }

    final amount = double.parse(amountController.text.trim());
    final toAddress = addressController.text.trim();

    final confirmed = await ConfirmDialog.show(
      title: l10n.btcBulkConfirmTxTitle,
      body: l10n.r3fBulkConfirmBody(amount.toString(), toAddress),
      confirmText: l10n.actionSend,
      cancelText: l10n.actionCancel,
    );
    if (confirmed != true) {
      return;
    }

    ref.read(globalLoadingProvider.notifier).start();
    final result = await VbtcV2Service().transferVbtcMulti(
      fromAddress: currentWallet.address,
      toAddress: toAddress,
      totalAmount: amount,
    );
    ref.read(globalLoadingProvider.notifier).complete();

    if (result == null) {
      return;
    }

    final message = l10n.tkbVbtcTransferBroadcasted(result.transactionHash);
    ref.read(logProvider.notifier).append(
          LogEntry(
            message: message,
            textToCopy: result.transactionHash,
            variant: AppColorVariant.Btc,
          ),
        );
    notifyTransactionSubmitted();
    ref.read(tokenizedBitcoinListProvider.notifier).refresh();
    Toast.message(l10n.r3fBulkSentToast(amount.toString(), toAddress));

    if (!mounted) {
      return;
    }
    await InfoDialog.show(
      title: l10n.btcBulkSuccessTitle,
      body: _allocationSummary(l10n, result, tokens, toAddress),
      buttonColorOverride: Theme.of(context).colorScheme.btcOrange,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// The CLI picked the inputs, so this is the user's only view of which
  /// tokens were debited. Falls back to the contract id for any allocation
  /// the local token list does not know by name.
  String _allocationSummary(
    AppLocalizations l10n,
    VbtcMultiTransferResult result,
    List<TokenizedBitcoin> tokens,
    String toAddress,
  ) {
    final lines = result.allocations.map((allocation) {
      final token = tokens
          .where((t) => t.smartContractUid == allocation.smartContractUid)
          .toList();
      final name = token.isEmpty
          ? allocation.smartContractUid
          : token.first.tokenName;
      return "• $name: ${allocation.amount} vBTC";
    });

    return "${l10n.r3fBulkSentToast(result.totalAmount.toString(), toAddress)}"
        "\n\n${l10n.btcBulkDrawnFrom}\n${lines.join('\n')}";
  }
}
