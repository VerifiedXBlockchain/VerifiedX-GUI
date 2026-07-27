import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/components/badges.dart';
import '../../../core/components/buttons.dart';
import '../../../core/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/mother_child.dart';

class MotherChildCard extends StatelessWidget {
  final MotherChild child;

  const MotherChildCard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              child.validatorName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Colors.white),
            ),
            const Divider(),
            Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Row(
                      label: l10n.motherChildBalance,
                      value: "${child.balance} VFX",
                    ),
                    const Divider(),
                    _Row(
                      label: l10n.motherChildIpAddress,
                      value: child.ipAddress,
                    ),
                    const Divider(),
                    _Row(
                      label: l10n.motherChildBlockHeight,
                      value: "${child.blockHeight}",
                    ),
                    const Divider(),
                    _Row(
                      label: l10n.motherChildIsValidating,
                      value: child.activeWithValidating ? l10n.motherChildYes : l10n.motherChildNo,
                      color: child.activeWithValidating
                          ? AppColorVariant.Success
                          : AppColorVariant.Danger,
                    ),
                    const Divider(),
                    _Row(
                      label: l10n.motherChildIsConnected,
                      value: child.activeWithMother ? l10n.motherChildYes : l10n.motherChildNo,
                      color: child.activeWithMother
                          ? AppColorVariant.Success
                          : AppColorVariant.Danger,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AppButton(
                  label: l10n.motherOpenInExplorer,
                  onPressed: () {
                    launchUrlString(
                        "${Env.baseExplorerUrl}/validators/${child.address}");
                  },
                ),
              ),
            ),
            Expanded(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(),
                  Text(
                    child.address,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final AppColorVariant color;
  const _Row({
    Key? key,
    required this.label,
    required this.value,
    this.color = AppColorVariant.Primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        AppBadge(
          label: value,
          variant: color,
        )
      ],
    );
  }
}
