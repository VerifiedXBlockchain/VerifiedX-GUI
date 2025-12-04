import 'package:flutter/material.dart';

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
    return DropdownButtonFormField<ButterflyIcon>(
      value: selectedIcon,
      decoration: const InputDecoration(
        labelText: 'Icon',
        border: OutlineInputBorder(),
      ),
      items: ButterflyIcon.values.map((icon) {
        return DropdownMenuItem<ButterflyIcon>(
          value: icon,
          child: Row(
            children: [
              Icon(_getIconData(icon), size: 20),
              const SizedBox(width: 8),
              Text(_getIconLabel(icon)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
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
