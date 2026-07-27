// ignore_for_file: unnecessary_const

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/components/currency_segmented_button.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:rbx_wallet/core/theme/colors.dart';
import 'package:rbx_wallet/features/btc/components/btc_utxo_list.dart';
import 'package:rbx_wallet/core/components/back_to_home_button.dart';

import '../../../core/base_screen.dart';
import '../../../core/providers/currency_segmented_button_provider.dart';
import '../../../core/providers/session_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../btc/components/btc_transaction_list.dart';
import '../components/combined_transactions_list.dart';
import '../components/transaction_list.dart';
import '../components/vfx_transaction_filter_button.dart';
import '../providers/transaction_list_provider.dart';

/// Wrapper that runs a faster transaction poll while the screen is visible.
class _FastPollScope extends ConsumerStatefulWidget {
  final Widget child;
  const _FastPollScope({required this.child});

  @override
  ConsumerState<_FastPollScope> createState() => _FastPollScopeState();
}

class _FastPollScopeState extends ConsumerState<_FastPollScope> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      ref.read(sessionProvider.notifier).loadTransactions();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class TransactionsScreen extends BaseScreen {
  const TransactionsScreen({Key? key}) : super(key: key, verticalPadding: 0, horizontalPadding: 0);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(currencySegementedButtonProvider);

    late final String title;
    switch (mode) {
      case CurrencyType.any:
        title = AppLocalizations.of(context).txAppBarAll;
        break;
      case CurrencyType.vfx:
        title = AppLocalizations.of(context).txAppBarVfx;
        break;
      case CurrencyType.btc:
        title = AppLocalizations.of(context).txAppBarBtc;
        break;
    }

    return AppBar(
      title: Text(title),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      leading: mode == CurrencyType.vfx ? VfxTransactionFilterButton() : null,
      // leading: BackToHomeButton(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: CurrencySegementedButton(
              includeAny: true,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return _FastPollScope(child: _buildBody(context, ref));
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(currencySegementedButtonProvider);
    final btcColor = Theme.of(context).colorScheme.btcOrange;
    switch (mode) {
      case CurrencyType.btc:
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                indicatorColor: btcColor,
                tabs: [
                  Tab(
                    child: Text(AppLocalizations.of(context).txTabTransactions),
                  ),
                  Tab(
                    child: Text(AppLocalizations.of(context).txTabInputs),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    BtcTransactionList(),
                    BtcUtxoList(),
                  ],
                ),
              )
            ],
          ),
        );
      case CurrencyType.vfx:
        return DefaultTabController(
          length: 5,
          child: Column(
            children: [
              TabBar(
                indicatorColor: AppColors.getBlue(),
                tabs: [
                  Tab(
                    child: Text(AppLocalizations.of(context).txTabAll),
                  ),
                  Tab(
                    child: Text(AppLocalizations.of(context).txTabPending),
                  ),
                  Tab(
                    child: Text(AppLocalizations.of(context).txTabSuccessful),
                  ),
                  Tab(
                    child: Text(AppLocalizations.of(context).txTabFailed),
                  ),
                  Tab(
                    child: Text(AppLocalizations.of(context).txTabVaulted),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBarView(
                    children: [
                      TransactionListType.All,
                      TransactionListType.Pending,
                      TransactionListType.Success,
                      TransactionListType.Failed,
                      TransactionListType.Reserved,
                      // TransactionListType.Validated,
                    ].map((type) => TransactionList(type: type)).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      case CurrencyType.any:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CombinedTransactionsList(),
        );
    }
  }
}
