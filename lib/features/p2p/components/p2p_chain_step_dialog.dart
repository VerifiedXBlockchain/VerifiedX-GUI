import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../chain/p2p_chain_error.dart';
import '../chain/p2p_tx_builders.dart';
import '../models/p2p_error.dart';
import '../models/p2p_tx_description.dart';
import '../providers/p2p_listing_providers.dart';
import '../services/p2p_session.dart';
import '../services/p2p_signer.dart';
import '../utils/p2p_error_text.dart';
import '../utils/p2p_view.dart';
import 'p2p_parts.dart';

/// A line of the summary at the top of a chain step's confirmation.
class P2pStepRow {
  final String label;
  final String value;

  /// Whether [value] is an address or an id, set in the fixed-width font.
  final bool mono;

  const P2pStepRow(this.label, this.value, {this.mono = false});
}

/// Confirms a shop step that is a transaction on chain: shows what it is
/// for, then the whole transaction, and carries it out only on Confirm.
///
/// While the shop's chain steps are dry runs the sheet says so: it carries
/// the "Dry run" badge, shows the transaction the step would send, and
/// records it with the registry. Nothing is signed or sent.
class P2pChainStepDialog extends ConsumerStatefulWidget {
  final String title;
  final List<P2pStepRow> rows;

  /// Builds the transaction's description, with its fee.
  final Future<P2pTxDescription> Function() describe;

  /// Carries the described transaction out.
  final Future<void> Function(P2pTxDescription tx) carryOut;

  /// What the step is called once it is done: "your purchase".
  final String doneBody;

  const P2pChainStepDialog({
    super.key,
    required this.title,
    required this.rows,
    required this.describe,
    required this.carryOut,
    required this.doneBody,
  });

  /// Resolves true when the step was carried out.
  static Future<bool> show({
    required String title,
    required List<P2pStepRow> rows,
    required Future<P2pTxDescription> Function() describe,
    required Future<void> Function(P2pTxDescription tx) carryOut,
    required String doneBody,
  }) async {
    final done = await showDialog<bool>(
      context: rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => P2pChainStepDialog(title: title, rows: rows, describe: describe, carryOut: carryOut, doneBody: doneBody),
    );
    return done == true;
  }

  @override
  ConsumerState<P2pChainStepDialog> createState() => _P2pChainStepDialogState();
}

class _P2pChainStepDialogState extends ConsumerState<P2pChainStepDialog> {
  P2pTxDescription? _tx;
  Object? _error;
  bool _isSubmitting = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _describe();
  }

  Future<void> _describe() async {
    setState(() {
      _tx = null;
      _error = null;
    });
    try {
      final tx = await widget.describe();
      if (mounted) {
        setState(() => _tx = tx);
      }
    } on P2pChainError catch (e) {
      _failed(e);
    } on P2pError catch (e) {
      _failed(e);
    }
  }

  Future<void> _confirm() async {
    final tx = _tx;
    if (tx == null || _isSubmitting) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.carryOut(tx);
      if (mounted) {
        setState(() => _done = true);
      }
    } on P2pError catch (e) {
      _failed(e);
    } on P2pSigningError catch (e) {
      _failed(e);
    } on P2pSignInMismatch catch (e) {
      _failed(e);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _failed(Object error) {
    if (mounted) {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dryRun = ref.watch(p2pChainStepsProvider).isDryRun;
    final tx = _tx;

    final Widget content;
    if (_done) {
      content = _recorded(l10n);
    } else if (tx == null && _error == null) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CenteredLoader(),
            const SizedBox(height: 12),
            Text(l10n.p2pChainDescribing, style: const TextStyle(color: p2pMuted)),
          ],
        ),
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in widget.rows) _row(row.label, row.value, mono: row.mono),
          if (tx != null) ...[
            const SizedBox(height: 14),
            _transaction(l10n, tx),
            if (dryRun) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.science_outlined, size: 16, color: AppColors.gold[50]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.p2pChainNothingSent,
                      key: const Key('p2p:step_nothing_sent'),
                      style: TextStyle(color: AppColors.gold[50], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              p2pErrorText(l10n, _error!),
              key: const Key('p2p:step_error'),
              style: TextStyle(color: AppColors.getSanguine(ColorShade.s50), fontSize: 13, height: 1.35),
            ),
          ],
        ],
      );
    }

    return AlertDialog(
      backgroundColor: const Color(0xFF191b1d),
      title: Row(
        children: [
          Expanded(child: Text(widget.title)),
          if (dryRun) P2pTag(key: const Key('p2p:step_dry_run'), label: l10n.p2pDryRunBadge, color: AppColors.gold[50]!),
        ],
      ),
      content: SizedBox(width: 520, child: SingleChildScrollView(child: content)),
      actions: _done
          ? [
              AppButton(
                key: const Key('p2p:step_done'),
                label: l10n.actionDone,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ]
          : [
              AppButton(
                key: const Key('p2p:step_cancel'),
                label: l10n.actionCancel,
                type: AppButtonType.Text,
                variant: AppColorVariant.Light,
                disabled: _isSubmitting,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              if (tx == null && _error != null)
                AppButton(
                  key: const Key('p2p:step_retry'),
                  label: l10n.p2pRetry,
                  icon: Icons.refresh,
                  onPressed: _describe,
                )
              else
                AppButton(
                  key: const Key('p2p:step_confirm'),
                  label: _isSubmitting ? l10n.p2pChainRecording : l10n.p2pChainConfirmDryRun,
                  processing: _isSubmitting,
                  disabled: tx == null,
                  onPressed: _confirm,
                ),
            ],
    );
  }

  /// The whole transaction: its fields, the payments inside it, its data and
  /// what it would take from the sender in all.
  Widget _transaction(AppLocalizations l10n, P2pTxDescription tx) {
    final payments = p2pInnerPayments(tx);
    final totals = P2pTxTotals.of(tx);
    final data = _dataRows(tx.data);

    return Container(
      key: const Key('p2p:step_transaction'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p2pSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p2pBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.p2pChainHeadingDryRun, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          _row(l10n.p2pChainType, "${p2pTxTypeName(tx.type)} (${tx.type})", mono: true),
          _row(l10n.p2pChainFunction, tx.function, mono: true),
          _row(l10n.p2pChainFrom, shortP2pAddress(tx.fromAddress, 8, 8), mono: true),
          _row(l10n.p2pChainTo, shortP2pAddress(tx.toAddress, 8, 8), mono: true),
          _row(l10n.p2pChainAmount, p2pVfxText(l10n, tx.amount), mono: true),
          _row(l10n.p2pChainFee, p2pVfxText(l10n, tx.fee), mono: true),
          for (final payment in payments)
            _row(
              payment.tag == null ? l10n.p2pChainPayment : l10n.p2pChainPaymentTagged(payment.tag!),
              l10n.p2pChainPaymentTo(
                p2pVfxText(l10n, payment.amount.toDecimalString()),
                shortP2pAddress(payment.to),
                p2pVfxText(l10n, payment.fee.toDecimalString()),
              ),
              mono: true,
            ),
          if (data.isNotEmpty) ...[
            const Divider(height: 16, color: p2pBorder),
            Text(l10n.p2pChainData, style: const TextStyle(color: p2pMuted, fontSize: 12)),
            for (final row in data) _row(row.label, row.value, mono: true),
          ],
          const Divider(height: 16, color: p2pBorder),
          _row(l10n.p2pChainTotalFees, p2pVfxText(l10n, totals.fee.toDecimalString()), mono: true),
          _row(l10n.p2pChainTotal, p2pVfxText(l10n, totals.total.toDecimalString()), mono: true, strong: true, valueKey: const Key('p2p:step_total')),
        ],
      ),
    );
  }

  /// The data's fields in reading order: the function and the payments have
  /// their own rows above, and a nested record is listed by its fields.
  List<P2pStepRow> _dataRows(Map<String, dynamic> data) {
    final rows = <P2pStepRow>[];
    void push(String label, Object? value) {
      if (value == null || value == '') {
        return;
      }
      rows.add(P2pStepRow(label, value is String && value.length > 28 ? shortP2pAddress(value, 12, 10) : value.toString()));
    }

    data.forEach((key, value) {
      if (key == 'Function' || key == 'Transactions') {
        return;
      }
      if (value is Map) {
        value.forEach((inner, innerValue) => push("$key.$inner", innerValue));
      } else {
        push(key, value);
      }
    });
    return rows;
  }

  Widget _recorded(AppLocalizations l10n) {
    final success = AppColors.getSpringGreen(ColorShade.s50);
    return Column(
      key: const Key('p2p:step_recorded'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Icon(Icons.check_circle_outline, size: 44, color: success),
        const SizedBox(height: 10),
        Text(l10n.p2pChainRecorded, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(l10n.p2pChainRecordedBody(widget.doneBody), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _row(String label, String value, {bool mono = false, bool strong = false, Key? valueKey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: strong ? Colors.white : p2pMuted, fontSize: 13, fontWeight: strong ? FontWeight.w700 : FontWeight.w400)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              key: valueKey,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontFamily: mono ? 'RobotoMono' : null,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
