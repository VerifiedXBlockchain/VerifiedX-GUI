import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/breakpoints.dart';
import '../../../core/components/big_button.dart';

import '../../../core/base_screen.dart';
import '../../../core/web_router.gr.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../web/components/web_mobile_drawer_button.dart';

class WebShopLandingScreen extends BaseScreen {
  const WebShopLandingScreen({Key? key})
      : super(
          includeWebDrawer: true,
          key: key,
          verticalPadding: 0,
          horizontalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final isMobile = BreakPoints.useMobileLayout(context);

    return AppBar(
      leading: isMobile ? WebMobileDrawerButton() : null,
      title: Text(AppLocalizations.of(context).dstAuctionsTitle),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Image.asset(
        //   Assets.images.gridBg.path,
        //   width: double.infinity,
        //   height: double.infinity,
        //   fit: BoxFit.cover,
        // ),
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.black38,
            // border: Border(
            //   top: BorderSide(color: Colors.white30, width: 2),
            //   bottom: BorderSide(color: Colors.white30, width: 2),
            // ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BigButton(
                  title: AppLocalizations.of(context).dstConnectToAuctionHouse,
                  iconData: Icons.connect_without_contact,
                  body: AppLocalizations.of(context).dstConnectToAuctionHouseBody,
                  onPressed: () async {
                    AutoRouter.of(context).push(WebShopListScreenRoute());
                  },
                ),
                BigButton(
                  title: AppLocalizations.of(context).dstManageMyAuctionHouse,
                  iconData: Icons.house,
                  body: AppLocalizations.of(context).dstManageMyAuctionHouseBodyWeb,
                  onPressed: () async {
                    AutoRouter.of(context).push(MyWebShopListScreenRoute());
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
