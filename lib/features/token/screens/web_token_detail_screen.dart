import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/centered_loader.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/web_fungible_token.dart';

import '../components/web_token_detail_component.dart';
import '../providers/web_token_detail_provider.dart';

class WebTokenDetailScreen extends BaseScreen {
  final String scId;
  const WebTokenDetailScreen({super.key, @PathParam("scId") required this.scId});

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final data = ref.watch(webTokenDetailProvider(scId));

    return data.when(
      loading: () => _buildAppBar(context),
      error: (e, _) => _buildAppBar(context),
      data: (tokenDetail) {
        if (tokenDetail == null) {
          return _buildAppBar(context);
        }

        return _buildAppBar(
            context,
            child: _AppBarContents(
          tokenDetails: tokenDetail,
        ));
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, {Widget? child}) {
    return AppBar(
      title: child ?? Text(AppLocalizations.of(context).tkbFungibleToken),
      shadowColor: Colors.transparent,
      backgroundColor: Colors.black,
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final data = ref.watch(webTokenDetailProvider(scId));

    return data.when(
      loading: () => CenteredLoader(),
      error: (e, _) => Center(
        child: Text(e.toString()),
      ),
      data: (tokenDetail) {
        if (tokenDetail == null) {
          return Text(AppLocalizations.of(context).tkbNotFound);
        }

        return WebTokenDetailComponent(
          tokenDetail: tokenDetail,
        );
      },
    );
  }
}

class _AppBarContents extends StatelessWidget {
  const _AppBarContents({
    super.key,
    required this.tokenDetails,
  });

  final WebFungibleTokenDetail tokenDetails;

  @override
  Widget build(BuildContext context) {
    final token = tokenDetails.token;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (token.imageUrl != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: token.imageUrl!,
                width: 32,
                height: 32,
              ),
            ),
          ),
        Text(
          token.label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
