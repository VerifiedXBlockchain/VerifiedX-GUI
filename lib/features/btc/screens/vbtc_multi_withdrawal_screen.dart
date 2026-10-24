import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rbx_wallet/core/app_constants.dart';
import 'package:rbx_wallet/core/base_screen.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/core/dialogs.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/core/providers/web_session_provider.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:rbx_wallet/core/theme/components.dart';
import 'package:rbx_wallet/features/btc/providers/tokenized_bitcoin_list_provider.dart';
import 'package:rbx_wallet/utils/toast.dart';
import '../../../core/utils/tx_refresh.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/formatting.dart';
import '../../bridge/models/log_entry.dart';
import '../../bridge/providers/log_provider.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../btc_web/providers/btc_web_vbtc_token_list_provider.dart';
import '../../btc_web/services/web_vbtc_withdrawal_part_actions.dart';
import '../../btc_web/utils/vbtc_multi_allocator.dart';
import '../../btc_web/utils/vbtc_multi_withdrawal.dart';
import '../../token/providers/web_token_actions_manager.dart';
import '../components/vbtc_multi_withdrawal_dialog.dart';
import '../models/vbtc_withdrawal_part.dart';
import '../services/desktop_vbtc_withdrawal_part_actions.dart';
import '../services/vbtc_v2_service.dart';
import '../utils.dart';

/// Withdraws one BTC amount drawn from up to 10 of the account's watched
/// vaults in a single request, the withdrawal counterpart of Bulk Transfer.
/// The user picks a total, a Bitcoin address and a fee rate; the vaults are
/// chosen largest first, shown before signing, and each pays out with its
/// own Bitcoin transaction. Desktop sends the total to the node, which
/// allocates the same way; web sends the shown shares to Core's raw builder
/// through Spyglass and signs the result itself.
class VbtcMultiWithdrawalScreen extends BaseStatefulScreen {
  /// Prefilled when the per-vault Withdraw sends the user here because one
  /// vault cannot cover the amount.
  final double? initialAmount;

  const VbtcMultiWithdrawalScreen({super.key, this.initialAmount})
      : super(horizontalPadding: 16, verticalPadding: 8);

  @override
  VbtcMultiWithdrawalScreenState createState() => VbtcMultiWithdrawalScreenState();
}

class VbtcMultiWithdrawalScreenState extends BaseScreenState<VbtcMultiWithdrawalScreen> {
  final formKey = GlobalKey<FormState>();
  late final amountController = TextEditingController(text: widget.initialAmount?.toString() ?? '');
  final addressController = TextEditingController();

  /// Desktop: each held vault's kind, read from the node. Null until the
  /// first load; a vault the node could not answer for stays out of the
  /// available amount until a later load gets an answer. Used only for the
  /// available amount and Max: what is sent is checked against Core's own
  /// allocation.
  Map<String, VbtcVaultKind?>? _kinds;
  bool _loadingKinds = false;

  @override
  void initState() {
    super.initState();
    _loadKinds();
  }

  @override
  void dispose() {
    amountController.dispose();
    addressController.dispose();
    super.dispose();
  }

  /// Reads the kind of every held vault not known yet: new since the last
  /// load, or one the node could not answer for. Runs on open and whenever
  /// the vault list refreshes.
  Future<void> _loadKinds() async {
    // Web: Spyglass marks each token `is_watched` already.
    if (kIsWeb) {
      _kinds = const {};
      return;
    }
    if (_loadingKinds) return;
    final address = ref.read(sessionProvider).currentWallet?.address ?? '';
    final known = _kinds ?? const {};
    final tokens = ref
        .read(tokenizedBitcoinListProvider)
        .where((t) => t.version >= 2 && t.myBalance > 0 && known[t.smartContractUid] == null)
        .toList();
    if (tokens.isEmpty) {
      if (_kinds == null) setState(() => _kinds = {});
      return;
    }
    _loadingKinds = true;
    final kinds = await Future.wait(
      tokens.map((t) => VbtcV2Service().getVaultKind(address: address, scUid: t.smartContractUid)),
    );
    _loadingKinds = false;
    if (!mounted) return;
    setState(() {
      _kinds = {
        ...known,
        for (var i = 0; i < tokens.length; i++) tokens[i].smartContractUid: kinds[i],
      };
    });
  }

  /// Every vault the account holds a spendable balance on, with whether it
  /// may go into this request. Balances already net out withdrawals in
  /// progress (the CLI's AvailableBalance, the explorer's
  /// available_balances, less this session's unconfirmed spends on web).
  List<_Vault> _vaults() {
    if (kIsWeb) {
      final address = ref.watch(webSessionProvider).keypair?.address;
      if (address == null) return const [];
      final manager = ref.read(webTokenActionsManager);
      // The web list holds one entry per (contract, loaded address).
      final byContract = <String, _Vault>{};
      for (final t in ref.watch(btcWebVbtcTokenListProvider)) {
        byContract[t.scIdentifier] = _Vault(
          scIdentifier: t.scIdentifier,
          name: t.name,
          balance: manager.spendableContractBalance(address, t.scIdentifier, t.availableBalanceForAddress(address)),
          kind: t.isWatched ? VbtcVaultKind.watched : VbtcVaultKind.legacy,
        );
      }
      return byContract.values.where((v) => v.balance > 0).toList();
    }
    final kinds = _kinds ?? const {};
    return ref
        .watch(tokenizedBitcoinListProvider)
        .where((t) => t.version >= 2 && t.myBalance > 0)
        .map((t) => _Vault(
              scIdentifier: t.smartContractUid,
              name: t.tokenName,
              balance: t.myBalance,
              kind: kinds[t.smartContractUid],
            ))
        .toList();
  }

  Map<String, double> _watchedBalances(List<_Vault> vaults) => {
        for (final v in vaults.where((v) => v.kind == VbtcVaultKind.watched)) v.scIdentifier: v.balance,
      };

  @override
  AppBar? appBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context).btcMultiWdTitle),
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Widget body(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen(tokenizedBitcoinListProvider, (_, __) => _loadKinds());
    if (_kinds == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final vaults = _vaults();
    final max = vbtcMultiWithdrawalMax(_watchedBalances(vaults));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.btcMultiWdIntro(VBTC_MULTI_WITHDRAWAL_MAX_VAULTS),
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          AppCard(
            fullWidth: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.btcMultiWdAvailable),
                Text(
                  "$max vBTC",
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
                        key: const ValueKey('vbtc:multi_wd_amount'),
                        controller: amountController,
                        validator: (value) => formValidatorVbtcMultiAmount(value, max),
                        decoration: InputDecoration(
                          label: Text(l10n.btcMultiWdAmountLabel),
                          hintText: l10n.btcBulkAmountHint,
                          suffixText: "vBTC",
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: AppButton(
                        label: l10n.r3fMaxLabel(max.toString()),
                        type: AppButtonType.Text,
                        underlined: true,
                        onPressed: () {
                          amountController.text = max.toString();
                        },
                        variant: AppColorVariant.Btc,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('vbtc:multi_wd_address'),
                  controller: addressController,
                  validator: formValidatorBtcAddress,
                  decoration: InputDecoration(
                    label: Text(l10n.btcMultiWdAddressLabel),
                    hintText: l10n.btcMultiWdAddressHint,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
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
                key: const Key('vbtc:multi_wd_submit'),
                label: l10n.btcWithdrawLabel,
                onPressed: () => _withdraw(context, vaults),
                variant: AppColorVariant.Btc,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _withdraw(BuildContext context, List<_Vault> vaults) async {
    final l10n = AppLocalizations.of(context);

    if (!formKey.currentState!.validate()) {
      return;
    }

    final requestorAddress = kIsWeb ? _webRequestor(l10n) : _desktopRequestor(l10n);
    if (requestorAddress == null) {
      return;
    }

    final amount = double.parse(amountController.text.trim());
    final btcAddress = addressController.text.trim();

    final feeRate = await promptForFeeRate(context);
    if (feeRate == null || !mounted) {
      return;
    }

    final VbtcWithdrawalPlan plan;
    if (kIsWeb) {
      // Web names its shares, watched vaults only, and checks Core's answer
      // against them before signing.
      plan = planVbtcMultiWithdrawal(_watchedBalances(vaults), amount, feeRate);
    } else {
      final shares = await _desktopCoreShares(l10n, requestorAddress, btcAddress, amount, feeRate);
      if (shares == null || !mounted) {
        return;
      }
      plan = vbtcWithdrawalPlanForShares(shares, feeRate, vbtcMultiWithdrawalMax(_watchedBalances(vaults)));
    }
    if (!plan.ok) {
      Toast.error(vbtcWithdrawalPlanError(l10n, plan, amount));
      return;
    }

    final parts = _partsFor(plan.shares, vaults);
    final confirmed = await ConfirmDialog.show(
      title: l10n.btcMultiWdConfirmTitle,
      content: VbtcMultiWithdrawalSummary(
        parts: parts,
        plan: plan,
        btcAddress: btcAddress,
      ),
      confirmText: l10n.btcWithdrawLabel,
      cancelText: l10n.actionCancel,
    );
    if (confirmed != true || !mounted) {
      return;
    }

    if (kIsWeb) {
      await _sendWeb(l10n, requestorAddress, plan, amount, btcAddress, vaults);
    } else {
      await _sendDesktop(l10n, requestorAddress, plan, amount, btcAddress, vaults);
    }
  }

  /// Desktop: the shares Core would send. RequestWithdrawalMulti sends only
  /// the total and Core picks the vaults, legacy ones included until they
  /// freeze, from its own view of the balances. So the shares shown and
  /// checked are Core's, asked for first without sending anything, never a
  /// guess from balances this screen may not have read. Null after telling
  /// the user why not.
  Future<List<VbtcAllocationInput>?> _desktopCoreShares(
    AppLocalizations l10n,
    String requestorAddress,
    String btcAddress,
    double amount,
    int feeRate,
  ) async {
    ref.read(globalLoadingProvider.notifier).start();
    final preview = await VbtcV2Service().previewWithdrawalMulti(
      requestorAddress: requestorAddress,
      btcAddress: btcAddress,
      amount: amount,
      feeRate: feeRate,
    );
    ref.read(globalLoadingProvider.notifier).complete();
    if (preview == null) {
      return null;
    }
    // A share on a vault the chain does not watch would need a FROST
    // completion, which this flow does not run.
    if (preview.unwatchedVaults.isNotEmpty) {
      Toast.error(l10n.btcMultiWdLegacyVault);
      return null;
    }
    return preview.allocations;
  }

  String? _desktopRequestor(AppLocalizations l10n) {
    final currentWallet = ref.read(sessionProvider).currentWallet;
    if (currentWallet == null) {
      Toast.error(l10n.btcBulkNoVfxSelectedToast);
      return null;
    }
    // Core refuses reserve requesters too, after the round-trip.
    if (vbtcSenderIsVault(currentWallet.address)) {
      Toast.error(l10n.tkbVaultCannotWithdraw);
      return null;
    }
    if (currentWallet.balance < MIN_RBX_FOR_SC_ACTION) {
      Toast.error(l10n.r3fInsufficientVfxBalance);
      return null;
    }
    return currentWallet.address;
  }

  /// The primary account: the Vault (xRBX) address cannot request a
  /// withdrawal, and its balances are not offered here.
  String? _webRequestor(AppLocalizations l10n) {
    final keypair = ref.read(webSessionProvider).keypair;
    if (keypair == null) {
      Toast.error(l10n.btcBulkNoVfxSelectedToast);
      return null;
    }
    if (!ref.read(webTokenActionsManager).verifyBalance()) {
      return null;
    }
    return keypair.address;
  }

  /// Desktop: the node allocates, signs and broadcasts in one call.
  Future<void> _sendDesktop(
    AppLocalizations l10n,
    String requestorAddress,
    VbtcWithdrawalPlan plan,
    double amount,
    String btcAddress,
    List<_Vault> vaults,
  ) async {
    ref.read(globalLoadingProvider.notifier).start();
    final result = await VbtcV2Service().requestWithdrawalMulti(
      requestorAddress: requestorAddress,
      btcAddress: btcAddress,
      amount: amount,
      feeRate: plan.feeRate,
    );
    ref.read(globalLoadingProvider.notifier).complete();
    if (result == null || !mounted) {
      return;
    }

    ref.read(logProvider.notifier).append(
          LogEntry(
            message: "vBTC withdrawal requested from ${result.allocations.length} vault(s): ${result.requestHash}",
            textToCopy: result.requestHash,
            variant: AppColorVariant.Btc,
          ),
        );
    notifyTransactionSubmitted();
    ref.read(tokenizedBitcoinListProvider.notifier).refresh();
    Navigator.of(context).pop();

    // Core's allocation, not the preview: it is what the request holds.
    await VbtcMultiWithdrawalDialog.show(
      requestHash: result.requestHash,
      parts: _partsFor(result.allocations, vaults),
      actions: DesktopVbtcWithdrawalPartActions(
        requestHash: result.requestHash,
        requestorAddress: requestorAddress,
      ),
    );
  }

  /// Web: Core builds the request from the confirmed shares; the wallet
  /// checks, signs and sends it.
  Future<void> _sendWeb(
    AppLocalizations l10n,
    String requestorAddress,
    VbtcWithdrawalPlan plan,
    double amount,
    String btcAddress,
    List<_Vault> vaults,
  ) async {
    final manager = ref.read(webTokenActionsManager);
    final requestHash = await manager.requestV2WithdrawalMulti(
      shares: plan.shares,
      btcAddress: btcAddress,
      totalAmount: amount,
      feeRate: plan.feeRate,
    );
    if (requestHash == null || !mounted) {
      return;
    }

    final session = ref.read(webSessionProvider);
    ref.read(btcWebVbtcTokenListProvider.notifier).reload(requestorAddress, raAddress: session.raKeypair?.address);
    Navigator.of(context).pop();

    await VbtcMultiWithdrawalDialog.show(
      requestHash: requestHash,
      parts: _partsFor(plan.shares, vaults),
      actions: WebVbtcWithdrawalPartActions(
        manager: manager,
        requestHash: requestHash,
        requestorAddress: requestorAddress,
      ),
    );
  }

  List<VbtcWithdrawalPart> _partsFor(List<VbtcAllocationInput> shares, List<_Vault> vaults) {
    return shares.map((share) {
      final matches = vaults.where((v) => v.scIdentifier == share.scIdentifier).toList();
      return VbtcWithdrawalPart(
        scIdentifier: share.scIdentifier,
        name: matches.isEmpty ? share.scIdentifier : matches.first.name,
        amount: share.amount,
      );
    }).toList();
  }
}

/// Why [plan] cannot be sent, in the words the form shows.
String vbtcWithdrawalPlanError(AppLocalizations l10n, VbtcWithdrawalPlan plan, double amount) {
  switch (plan.failure!) {
    case VbtcWithdrawalPlanFailure.invalidAmount:
      return l10n.btcInvalidAmount;
    case VbtcWithdrawalPlanFailure.invalidFeeRate:
      return l10n.tkbInvalidFeeRate;
    case VbtcWithdrawalPlanFailure.insufficientBalance:
      return l10n.btcBulkInsufficientCombined(plan.available.toString(), amount.toString());
    case VbtcWithdrawalPlanFailure.tooManyVaults:
      return l10n.btcMultiWdTooManyVaults(VBTC_MULTI_WITHDRAWAL_MAX_VAULTS);
    case VbtcWithdrawalPlanFailure.shareBelowFeeFloor:
      return l10n.btcMultiWdBelowFloor(
        plan.belowFloorPart!,
        plan.shares[plan.belowFloorPart! - 1].amount.toString(),
        plan.feeRate,
        formatBtcAmount(plan.floorSats / 100000000),
      );
  }
}

/// What the request will do, shown before it is signed: each part with its
/// vault and amount, the fee per part and in total, and what arrives.
class VbtcMultiWithdrawalSummary extends StatelessWidget {
  final List<VbtcWithdrawalPart> parts;
  final VbtcWithdrawalPlan plan;
  final String btcAddress;

  const VbtcMultiWithdrawalSummary({
    super.key,
    required this.parts,
    required this.plan,
    required this.btcAddress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const muted = TextStyle(color: Colors.white70, fontSize: 13);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(l10n.btcMultiWdConfirmDestination(btcAddress)),
            SizedBox(height: 4),
            Text(l10n.btcMultiWdConfirmFeeRate(plan.feeRate), style: muted),
            SizedBox(height: 12),
            for (var i = 0; i < parts.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "${l10n.btcMultiWdPartLabel(i + 1)} · ${parts[i].name}: ${parts[i].amount} vBTC",
                  key: Key('vbtc:multi_wd_confirm_part_${i + 1}'),
                ),
              ),
            SizedBox(height: 12),
            Text(
              l10n.btcMultiWdConfirmPerPartFee(
                plan.minPerShareFeeSats,
                formatBtcAmount(plan.minPerShareFeeSats / 100000000),
              ),
              style: muted,
            ),
            Text(
              l10n.btcMultiWdConfirmTotalFee(
                plan.minTotalFeeSats,
                formatBtcAmount(plan.minTotalFeeSats / 100000000),
                parts.length,
              ),
              style: muted,
            ),
            SizedBox(height: 8),
            Text(
              l10n.btcMultiWdConfirmNet(formatBtcAmount(plan.maxNetAmount)),
              style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.btcOrange),
            ),
            SizedBox(height: 12),
            Text(l10n.btcMultiWdConfirmNote, style: muted),
          ],
        ),
      ),
    );
  }
}

class _Vault {
  final String scIdentifier;
  final String name;
  final double balance;
  final VbtcVaultKind? kind;

  const _Vault({
    required this.scIdentifier,
    required this.name,
    required this.balance,
    required this.kind,
  });
}
