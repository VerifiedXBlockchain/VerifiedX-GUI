import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/generated/app_localizations.dart';
import '../base_component.dart';
import '../providers/session_provider.dart';
import '../theme/app_theme.dart';
import '../../features/btc/providers/btc_account_list_provider.dart';
import '../../features/wallet/providers/wallet_list_provider.dart';

import '../providers/currency_segmented_button_provider.dart';
import '../theme/colors.dart';

class CurrencySegementedButton extends BaseComponent {
  final Function(CurrencyType)? onChange;
  final bool shouldToggleGlobal;
  final bool includeAny;

  /// For Send and Receive, which render the session's selected account: the
  /// segment shows that account's currency when the app-wide choice names
  /// another (the price chart, the balance cards and the account list set it
  /// on their own). The app-wide choice is not written back: tabs stay
  /// mounted when hidden, and other screens use it as their filter.
  final bool followSession;
  const CurrencySegementedButton({
    super.key,
    this.onChange,
    this.includeAny = true,
    this.shouldToggleGlobal = true,
    this.followSession = false,
  });

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final provider = ref.read(currencySegementedButtonProvider.notifier);
    final state = ref.watch(currencySegementedButtonProvider);
    final shown = followSession
        ? currencyMatchingSession(state, btcSelected: ref.watch(sessionProvider.select((v) => v.btcSelected)), includeAny: includeAny) ?? state
        : state;

    return SegmentedButton<CurrencyType>(
      multiSelectionEnabled: false,
      selectedIcon: null,
      showSelectedIcon: false,
      selected: {shown},
      style: ButtonStyle(
        side: MaterialStateProperty.all(
          BorderSide(
            width: 1,
            color: Colors.white54,
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.selected)) {
              switch (shown) {
                case CurrencyType.any:
                  return Colors.white;
                case CurrencyType.vfx:
                  return AppColors.getBlue();
                case CurrencyType.btc:
                  return Theme.of(context).colorScheme.btcOrange;
              }
            }
            return Colors.black;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.selected)) {
              return Theme.of(context).colorScheme.primary;
            }
            return Colors.white;
          },
        ),
      ),
      onSelectionChanged: (value) {
        provider.set(value.first);

        if (onChange != null) {
          onChange!(value.first);
        }

        if (shouldToggleGlobal) {
          switch (value.first) {
            case CurrencyType.any:
              if (ref.read(sessionProvider).btcSelected) {
                if (ref.read(btcAccountListProvider).isEmpty) {
                  ref.read(sessionProvider.notifier).toggleToVfxWallet();
                }
              } else {
                if (ref.read(walletListProvider).isEmpty) {
                  ref.read(sessionProvider.notifier).toggleToBtcWallet();
                }
              }

              return;
            case CurrencyType.vfx:
              ref.read(sessionProvider.notifier).toggleToVfxWallet();
              return;
            case CurrencyType.btc:
              ref.read(sessionProvider.notifier).toggleToBtcWallet();

              return;
          }
        }
      },
      segments: [
        if (includeAny)
          ButtonSegment(
            label: Text(AppLocalizations.of(context).hnavCurrencyAll),
            value: CurrencyType.any,
          ),
        ButtonSegment(
          label: Text("VFX"),
          value: CurrencyType.vfx,
        ),
        ButtonSegment(
          label: Text("BTC"),
          value: CurrencyType.btc,
        ),
      ],
    );
  }
}
