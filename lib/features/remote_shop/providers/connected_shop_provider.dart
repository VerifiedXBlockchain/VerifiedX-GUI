import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_router.gr.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/session_provider.dart';
import '../../../l10n/l10n_helper.dart';
import '../../dst/models/dec_shop.dart';
import '../models/shop_data.dart';
import 'saved_shops_provider.dart';
import 'shop_loading_provider.dart';
import '../services/remote_shop_service.dart';
import '../../../utils/toast.dart';

part 'connected_shop_provider.freezed.dart';

@freezed
class ConnectedShop with _$ConnectedShop {
  const ConnectedShop._();

  factory ConnectedShop({
    String? url,
    DecShop? decShop,
    OrganizedShop? data,
    @Default(false) bool isConnected,
    @Default(false) bool hasShownDisconnectAlert,
    @Default(false) bool shouldWarnDisconnection,
  }) = _ConnectedShop;
}

class ConnectedShopProvider extends StateNotifier<ConnectedShop> {
  final Ref ref;

  Timer? refreshTimer;
  Timer? connectionTimer;

  ConnectedShopProvider(this.ref, ConnectedShop initialState) : super(initialState);

  Future<void> connect(DecShop shop) async {
    state = ConnectedShop(
      url: shop.url,
      decShop: shop,
      isConnected: true,
      shouldWarnDisconnection: true,
    );

    await checkConnectionStatus();
    await refresh(true);

    activateRefreshTimer();

    connectionTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      checkConnectionStatus();
    });
  }

  disconnect() {
    refreshTimer?.cancel();
    state = state.copyWith(shouldWarnDisconnection: false);
  }

  activateRefreshTimer() {
    if (!state.shouldWarnDisconnection) {
      state = state.copyWith(shouldWarnDisconnection: true);
    }
    if (refreshTimer != null) {
      refreshTimer!.cancel();
    }

    refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      refresh();
    });
  }

  checkConnectionStatus() async {
    if (state.url == null) {
      return;
    }

    final isConnected = await RemoteShopService().checkConnection(state.url!);

    state = state.copyWith(isConnected: isConnected);

    // if (!isConnected) {
    //   if (state.shouldWarnDisconnection && !state.hasShownDisconnectAlert) {
    //     state = state.copyWith(hasShownDisconnectAlert: true);
    //     await InfoDialog.show(
    //       title: "Shop Disconnected",
    //       body: "The shop you are connected to ${state.decShop != null ? '(${state.decShop!.name})' : ''} has gone offline.",
    //     );
    //   }

    //   return;
    // }
  }

  refresh([bool showErrors = false]) async {
    // if (!state.isConnected) {
    //   return;
    // }

    // int listingCount = 0;
    // if (state.data != null) {
    //   for (final c in state.data!.collections) {
    //     listingCount += c.listings.length;
    //   }
    // }

    await Future.delayed(Duration(seconds: 2));

    final data = await RemoteShopService().getConnectedShopData(
      showErrors: showErrors,
    );
    if (data != null) {
      state = state.copyWith(data: data);
    }
  }

  Future<void> removeBookmarkedShop(BuildContext context, WidgetRef ref, String url) async {
    final confirmed = await ConfirmDialog.show(
      title: globalL10n.r3gRemoveShopTitle,
      body: globalL10n.r3gRemoveShopBody(url),
      confirmText: globalL10n.beaconRemove,
      cancelText: globalL10n.actionCancel,
    );
    if (confirmed == true) {
      ref.read(savedShopsProvider.notifier).remove(url);
    }
  }

  Future<void> loadShop(BuildContext context, WidgetRef ref, String url) async {
    final address = ref.read(sessionProvider).currentWallet?.address;
    if (address == null) {
      Toast.error(globalL10n.messageNoAccountSelected);
      return;
    }

    final shop = await RemoteShopService().getShopInfo(url);

    if (shop == null) {
      Toast.error(globalL10n.r3gCouldNotFindShop(url));
      return;
    }

    ref.read(savedShopsProvider.notifier).save(shop);

    final confirmed = await ConfirmDialog.show(
      title: globalL10n.r3gConnectToAuctionHouseTitle,
      body: globalL10n.r3gConnectToShopBody(shop.name, shop.url),
      confirmText: globalL10n.r3gConnect,
      cancelText: globalL10n.actionCancel,
    );

    if (confirmed == true) {
      ref.read(shopLoadingProvider.notifier).start(globalL10n.r3gConnectingToShop);
      final success = await RemoteShopService().connectToShop(myAddress: address, shopUrl: shop.url);

      if (!success) {
        ref.read(shopLoadingProvider.notifier).start(globalL10n.r3gShopIsOffline);
        await Future.delayed(Duration(seconds: 2));
        ref.read(shopLoadingProvider.notifier).complete();
        Toast.error(globalL10n.r3gCouldNotConnectOffline);
        return;
      }

      ref.read(shopLoadingProvider.notifier).start(globalL10n.r3gConnectedFetchingData(shop.url));

      await Future.delayed(Duration(milliseconds: 2500));
      ref.read(shopLoadingProvider.notifier).start(globalL10n.r3gGettingCollections);
      // await RemoteShopService().getConnectedShopData();
      await ref.read(connectedShopProvider.notifier).connect(shop);
      AutoRouter.of(context).push(RemoteShopDetailScreenRoute(shopUrl: shop.url));
      // AutoRouter.of(context).push(RemoteShopContainerScreenRoute());
      ref.read(shopLoadingProvider.notifier).complete();
    }
  }
}

final connectedShopProvider = StateNotifierProvider<ConnectedShopProvider, ConnectedShop>(
  (ref) => ConnectedShopProvider(ref, ConnectedShop()),
);
