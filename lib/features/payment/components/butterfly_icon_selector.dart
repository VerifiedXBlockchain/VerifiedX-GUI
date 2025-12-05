import 'package:flutter/material.dart';
import 'package:rbx_wallet/core/components/buttons.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';

import '../models/butterfly_link.dart';

class ButterflyIconSelector extends StatelessWidget {
  final ButterflyIcon selectedIcon;
  final ValueChanged<ButterflyIcon> onChanged;

  const ButterflyIconSelector({
    super.key,
    required this.selectedIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Icon",
          style: TextStyle(
              fontSize: 16, color: Theme.of(context).colorScheme.secondary),
        ),
        SizedBox(
          height: 8,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ButterflyIcon.values.map((icon) {
            return AppButton(
              label: _getIconLabel(icon),
              icon: _getIconData(icon),
              variant: selectedIcon == icon
                  ? AppColorVariant.Secondary
                  : AppColorVariant.Primary,
              type: AppButtonType.Elevated,
              onPressed: () {
                onChanged(icon);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIconData(ButterflyIcon icon) {
    switch (icon) {
      case ButterflyIcon.defaultIcon:
        return Icons.link;
      case ButterflyIcon.gift:
        return Icons.card_giftcard;
      case ButterflyIcon.money:
        return Icons.attach_money;
      case ButterflyIcon.heart:
        return Icons.favorite;
      case ButterflyIcon.party:
        return Icons.celebration;
      case ButterflyIcon.rocket:
        return Icons.rocket_launch;
      case ButterflyIcon.star:
        return Icons.star;
    }
  }

  String _getIconLabel(ButterflyIcon icon) {
    switch (icon) {
      case ButterflyIcon.defaultIcon:
        return 'Default';
      case ButterflyIcon.gift:
        return 'Gift';
      case ButterflyIcon.money:
        return 'Money';
      case ButterflyIcon.heart:
        return 'Heart';
      case ButterflyIcon.party:
        return 'Party';
      case ButterflyIcon.rocket:
        return 'Rocket';
      case ButterflyIcon.star:
        return 'Star';
    }
  }
}
