import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/base_component.dart';
import '../../../../core/components/buttons.dart';
import '../../../../core/dialogs.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../utils/toast.dart';
import '../../../bridge/services/bridge_service.dart';
import '../../../encrypt/providers/wallet_is_encrypted_provider.dart';
import '../../../global_loader/global_loading_provider.dart';

class HdWalletButton extends BaseComponent {
  const HdWalletButton({
    Key? key,
  }) : super(key: key);

  Future<void> create(BuildContext context, WidgetRef ref, int strength) async {
    ref.read(globalLoadingProvider.notifier).start();
    final mnumonic = await BridgeService().getHdWallet(strength);
    ref.read(globalLoadingProvider.notifier).complete();

    if (mnumonic != null) {
      Navigator.of(context).pop(mnumonic);
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppButton(
      label: l10n.hnavHdCreateAccount,
      icon: Icons.hd_outlined,
      onPressed: !ref.watch(sessionProvider.select((v) => v.cliStarted))
          ? null
          : () async {
              if (ref.read(walletIsEncryptedProvider)) {
                Toast.error(l10n.hnavHdEncryptedError);
                return;
              }

              final String? mneumonic = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    // buttonPadding: EdgeInsets.all(8.0),
                    // actionsPadding: EdgeInsets.all(0.0),
                    title: Text(l10n.hnavHdAccountTitle),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          l10n.actionCancel,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      )
                    ],
                    content: SizedBox(
                      width: 500,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.hnavHdExplanation1),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(l10n.hnavHdExplanation2),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            l10n.hnavHdExplanation3,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Divider(),
                          Text(
                            l10n.hnavHdGenerateStrength,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              AppButton(
                                label: l10n.hnavHd12Words,
                                onPressed: () async {
                                  await create(context, ref, 12);
                                },
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              AppButton(
                                label: l10n.hnavHd24Words,
                                onPressed: () async {
                                  await create(context, ref, 24);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              if (mneumonic != null) {
                await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return RecoveryPhraseDialog(mneumonic: mneumonic);
                  },
                );
              }
            },
    );
  }
}

class RecoveryPhraseDialog extends StatelessWidget {
  const RecoveryPhraseDialog({
    Key? key,
    required this.mneumonic,
  }) : super(key: key);

  final String mneumonic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.hnavRecoveryPhraseGeneratedTitle),
      actions: [
        TextButton(
          onPressed: () async {
            final confirmed = await ConfirmDialog.show(
              title: l10n.hnavCloseRecoveryPhraseTitle,
              body: l10n.hnavCloseRecoveryPhraseBody,
              confirmText: l10n.hnavAgreeAndClose,
              cancelText: l10n.actionCancel,
            );

            if (confirmed == true) {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            l10n.actionDone,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        )
      ],
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.hnavCopyRecoveryPhraseInstruction),
            Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    label: Text(l10n.walletRecoveryPhrase),
                  ),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  initialValue: mneumonic,
                  readOnly: true,
                  minLines: 1,
                  maxLines: 6,
                ),
                // IconButton(onPressed:  (){}, icon: Icon(Icons.copy))
                const SizedBox(
                  height: 16,
                ),
                AppButton(
                  label: l10n.hnavCopyToClipboard,
                  icon: Icons.copy,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: mneumonic));
                    Toast.message(l10n.keygenMnemonicCopiedToast);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
