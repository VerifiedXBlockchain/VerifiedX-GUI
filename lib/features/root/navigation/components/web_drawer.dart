import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/theme/colors.dart';

import '../../../../core/base_component.dart';
import '../../../auth/screens/web_auth_screen.dart';
import '../../../navigation/components/root_container_side_nav_list.dart';

class WebDrawer extends BaseComponent {
  const WebDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.getGray(ColorShade.s200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: WebWalletWordWordmark(
              withSubtitle: false,
            ),
          ),
          Expanded(
            child: RootContainerSideNavList(
              isExpanded: true,
              // tabsRouter: tabsRouter,
              inDrawer: true,
            ),
          ),
        ],
      ),
    );
  }
}
