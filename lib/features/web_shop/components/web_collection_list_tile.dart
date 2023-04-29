import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/app_router.gr.dart';
import 'package:rbx_wallet/core/env.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';

import '../../../core/base_component.dart';
import '../../../core/web_router.gr.dart';
import '../models/web_collection.dart';

class WebCollectionTile extends BaseComponent {
  final WebCollection collection;
  const WebCollectionTile(this.collection, {Key? key}) : super(key: key);
  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: glowingBox,
          color: Colors.black,
        ),
        child: Card(
          color: Colors.black,
          child: ListTile(
            title: Text(collection.name),
            subtitle: Text(
              collection.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              if (collection.shop == null) {
                print("Shop is null");
                return;
              }
              if (Env.isWeb) {
                AutoRouter.of(context).push(WebCollectionDetailScreenRoute(shopId: collection.shop!.id, collectionId: collection.id));
              } else {
                AutoRouter.of(context).push(DebugWebCollectionDetailScreenRoute(shopId: collection.shop!.id, collectionId: collection.id));
              }
            },
          ),
        ),
      ),
    );
  }
}