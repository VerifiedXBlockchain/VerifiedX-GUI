// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i55;
import 'package:auto_route/empty_router_widgets.dart' as _i12;
import 'package:flutter/foundation.dart' as _i57;
import 'package:flutter/material.dart' as _i56;
import 'package:rbx_wallet/features/adjudicator/adjudicator_screen.dart'
    as _i19;
import 'package:rbx_wallet/features/adnr/screens/adnr_screen.dart' as _i34;
import 'package:rbx_wallet/features/beacon/screens/beacon_list_screen.dart'
    as _i38;
import 'package:rbx_wallet/features/btc/screens/tokenized_btc_list_screen.dart'
    as _i41;
import 'package:rbx_wallet/features/chat/screens/buyer_chat_thread_list_screen.dart'
    as _i48;
import 'package:rbx_wallet/features/chat/screens/seller_chat_screen.dart'
    as _i10;
import 'package:rbx_wallet/features/chat/screens/seller_chat_thread_list_screen.dart'
    as _i25;
import 'package:rbx_wallet/features/chat/screens/shop_chat_screen.dart' as _i11;
import 'package:rbx_wallet/features/chat/screens/web_seller_chat_screen.dart'
    as _i26;
import 'package:rbx_wallet/features/chat/screens/web_shop_chat_screen.dart'
    as _i52;
import 'package:rbx_wallet/features/config/screens/config_container_screen.dart'
    as _i6;
import 'package:rbx_wallet/features/datanode/screens/datanode_screen.dart'
    as _i21;
import 'package:rbx_wallet/features/dst/screens/create_collection_container_screen.dart'
    as _i29;
import 'package:rbx_wallet/features/dst/screens/create_dec_shop_container_screen.dart'
    as _i30;
import 'package:rbx_wallet/features/dst/screens/create_listing_container_screen.dart'
    as _i33;
import 'package:rbx_wallet/features/dst/screens/dst_landing_screen.dart'
    as _i24;
import 'package:rbx_wallet/features/dst/screens/listing_auction_detail_screen.dart'
    as _i32;
import 'package:rbx_wallet/features/dst/screens/listing_detail_screen.dart'
    as _i31;
import 'package:rbx_wallet/features/dst/screens/my_collection_detail_screen.dart'
    as _i28;
import 'package:rbx_wallet/features/dst/screens/my_collection_list_screen.dart'
    as _i27;
import 'package:rbx_wallet/features/home/screens/all_tokens_screen.dart'
    as _i14;
import 'package:rbx_wallet/features/home/screens/new_home_screen.dart' as _i13;
import 'package:rbx_wallet/features/mother/screens/mother_dashboard_screen.dart'
    as _i8;
import 'package:rbx_wallet/features/navigation/root_container.dart' as _i1;
import 'package:rbx_wallet/features/nft/screens/nft_list_screen.dart' as _i22;
import 'package:rbx_wallet/features/node/screens/node_list_screen.dart' as _i20;
import 'package:rbx_wallet/features/operations/screens/operations_screen.dart'
    as _i45;
import 'package:rbx_wallet/features/receive/screens/receive_screen.dart'
    as _i16;
import 'package:rbx_wallet/features/remote_shop/screens/remote_shop_collection_screen.dart'
    as _i50;
import 'package:rbx_wallet/features/remote_shop/screens/remote_shop_container_screen.dart'
    as _i9;
import 'package:rbx_wallet/features/remote_shop/screens/remote_shop_detail_screen.dart'
    as _i49;
import 'package:rbx_wallet/features/reserve/screens/manage_reserve_accounts_screen.dart'
    as _i40;
import 'package:rbx_wallet/features/reserve/screens/reserve_account_overview_screen.dart'
    as _i39;
import 'package:rbx_wallet/features/send/screens/send_screen.dart' as _i15;
import 'package:rbx_wallet/features/smart_contracts/components/sc_creator/smart_contract_creator_main.dart'
    as _i46;
import 'package:rbx_wallet/features/smart_contracts/screens/bulk_create_screen.dart'
    as _i5;
import 'package:rbx_wallet/features/smart_contracts/screens/my_smart_contracts_screen.dart'
    as _i2;
import 'package:rbx_wallet/features/smart_contracts/screens/smart_contract_creator_container_screen.dart'
    as _i7;
import 'package:rbx_wallet/features/smart_contracts/screens/smart_contract_drafts_screen.dart'
    as _i3;
import 'package:rbx_wallet/features/smart_contracts/screens/smart_contracts_screen.dart'
    as _i23;
import 'package:rbx_wallet/features/smart_contracts/screens/template_chooser_screen.dart'
    as _i4;
import 'package:rbx_wallet/features/token/screens/token_create_screen.dart'
    as _i43;
import 'package:rbx_wallet/features/token/screens/token_list_screen.dart'
    as _i42;
import 'package:rbx_wallet/features/token/screens/token_topic_create_screen.dart'
    as _i44;
import 'package:rbx_wallet/features/transactions/screens/transactions_screen.dart'
    as _i17;
import 'package:rbx_wallet/features/validator/screens/validator_screen.dart'
    as _i18;
import 'package:rbx_wallet/features/voting/screens/create_topic_screen.dart'
    as _i37;
import 'package:rbx_wallet/features/voting/screens/topic_detail_screen.dart'
    as _i36;
import 'package:rbx_wallet/features/voting/screens/topic_list_screen.dart'
    as _i35;
import 'package:rbx_wallet/features/web_shop/screens/web_collection_detail_screen.dart'
    as _i53;
import 'package:rbx_wallet/features/web_shop/screens/web_listing_detail_screen.dart'
    as _i54;
import 'package:rbx_wallet/features/web_shop/screens/web_shop_detail_screen.dart'
    as _i51;
import 'package:rbx_wallet/features/web_shop/screens/web_shop_list_screen.dart'
    as _i47;

class AppRouter extends _i55.RootStackRouter {
  AppRouter([_i56.GlobalKey<_i56.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i55.PageFactory> pagesMap = {
    RootContainerRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i1.RootContainer(),
      );
    },
    MySmartContractsScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i2.MySmartContractsScreen(),
      );
    },
    SmartContractDraftsScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i3.SmartContractDraftsScreen(),
      );
    },
    TemplateChooserScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i4.TemplateChooserScreen(),
      );
    },
    BulkCreateScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i5.BulkCreateScreen(),
      );
    },
    ConfigContainerScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i6.ConfigContainerScreen(),
      );
    },
    SmartContractCreatorContainerScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i7.SmartContractCreatorContainerScreen(),
      );
    },
    MotherDashboardScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i8.MotherDashboardScreen(),
      );
    },
    RemoteShopContainerScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i9.RemoteShopContainerScreen(),
      );
    },
    SellerChatScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<SellerChatScreenRouteArgs>(
          orElse: () => SellerChatScreenRouteArgs(
              address: pathParams.getString('address')));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i10.SellerChatScreen(
          key: args.key,
          address: args.address,
        ),
      );
    },
    ShopChatScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<ShopChatScreenRouteArgs>(
          orElse: () =>
              ShopChatScreenRouteArgs(url: pathParams.getString('url')));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i11.ShopChatScreen(
          key: args.key,
          url: args.url,
        ),
      );
    },
    HomeTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    SendTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    ReceiveTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    TransactionsTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    ValidatorTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    AdjudicatorTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    NodesTabsRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    DatanodeTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    NftTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    SmartContractsTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    DstsTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    AdnrTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    VotingTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    BeaconTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    ReserveAccountsTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    TokenizeBtcTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    TokenTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    OperationsTabRouter.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i12.EmptyRouterPage(),
      );
    },
    NewHomeScreenRoute.name: (routeData) {
      final args = routeData.argsAs<NewHomeScreenRouteArgs>(
          orElse: () => const NewHomeScreenRouteArgs());
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i13.NewHomeScreen(
          key: args.key,
          verticalPadding: args.verticalPadding,
          horizontalPadding: args.horizontalPadding,
        ),
      );
    },
    AllTokensScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i14.AllTokensScreen(),
      );
    },
    SendScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i15.SendScreen(),
      );
    },
    ReceiveScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i16.ReceiveScreen(),
      );
    },
    TransactionsScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i17.TransactionsScreen(),
      );
    },
    ValidatorScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i18.ValidatorScreen(),
      );
    },
    AdjudicatorScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i19.AdjudicatorScreen(),
      );
    },
    NodeListScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i20.NodeListScreen(),
      );
    },
    DataNodeScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i21.DataNodeScreen(),
      );
    },
    NftListScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i22.NftListScreen(),
      );
    },
    SmartContractsScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i23.SmartContractsScreen(),
      );
    },
    DstLandingScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i24.DstLandingScreen(),
      );
    },
    SellerChatThreadListScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i25.SellerChatThreadListScreen(),
      );
    },
    WebSellerChatScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<WebSellerChatScreenRouteArgs>(
          orElse: () => WebSellerChatScreenRouteArgs(
                address: pathParams.getString('address'),
                shopId: pathParams.getInt('shopId'),
              ));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i26.WebSellerChatScreen(
          key: args.key,
          address: args.address,
          shopId: args.shopId,
        ),
      );
    },
    MyCollectionsListScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i27.MyCollectionsListScreen(),
      );
    },
    MyCollectionDetailScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<MyCollectionDetailScreenRouteArgs>(
          orElse: () => MyCollectionDetailScreenRouteArgs(
              collectionId: pathParams.getInt('collectionId')));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i28.MyCollectionDetailScreen(
          key: args.key,
          collectionId: args.collectionId,
        ),
      );
    },
    CreateCollectionContainerScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i29.CreateCollectionContainerScreen(),
      );
    },
    CreateDecShopContainerScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i30.CreateDecShopContainerScreen(),
      );
    },
    ListingDetailScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<ListingDetailScreenRouteArgs>(
          orElse: () => ListingDetailScreenRouteArgs(
              listingId: pathParams.getInt('listingId')));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i31.ListingDetailScreen(
          key: args.key,
          listingId: args.listingId,
        ),
      );
    },
    ListingAuctionDetailScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<ListingAuctionDetailScreenRouteArgs>(
          orElse: () => ListingAuctionDetailScreenRouteArgs(
              listingId: pathParams.getInt('listingId')));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i32.ListingAuctionDetailScreen(
          key: args.key,
          listingId: args.listingId,
        ),
      );
    },
    CreateListingContainerScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<CreateListingContainerScreenRouteArgs>(
          orElse: () => CreateListingContainerScreenRouteArgs(
              collectionId: pathParams.getInt('collectionId')));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i33.CreateListingContainerScreen(
          args.collectionId,
          key: args.key,
        ),
      );
    },
    AdnrScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i34.AdnrScreen(),
      );
    },
    TopicListScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i35.TopicListScreen(),
      );
    },
    TopicDetailScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<TopicDetailScreenRouteArgs>(
          orElse: () => TopicDetailScreenRouteArgs(
              topicUid: pathParams.getString('uid')));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i36.TopicDetailScreen(
          key: args.key,
          topicUid: args.topicUid,
        ),
      );
    },
    CreateTopicScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i37.CreateTopicScreen(),
      );
    },
    BeaconListScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i38.BeaconListScreen(),
      );
    },
    ReserveAccountOverviewScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i39.ReserveAccountOverviewScreen(),
      );
    },
    ManageReserveAccountsScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i40.ManageReserveAccountsScreen(),
      );
    },
    TokenizeBtcListScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i41.TokenizeBtcListScreen(),
      );
    },
    TokenListScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i42.TokenListScreen(),
      );
    },
    TokenCreateScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i43.TokenCreateScreen(),
      );
    },
    CreateTokenTopicScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<CreateTokenTopicScreenRouteArgs>(
          orElse: () => CreateTokenTopicScreenRouteArgs(
                scId: pathParams.getString('scId'),
                address: pathParams.getString('address'),
              ));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i44.CreateTokenTopicScreen(
          key: args.key,
          scId: args.scId,
          address: args.address,
        ),
      );
    },
    OperationsScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i45.OperationsScreen(),
      );
    },
    SmartContractCreatorMainRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i46.SmartContractCreatorMain(),
      );
    },
    WebShopListScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i47.WebShopListScreen(),
      );
    },
    BuyerChatThreadListScreenRoute.name: (routeData) {
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i48.BuyerChatThreadListScreen(),
      );
    },
    RemoteShopDetailScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<RemoteShopDetailScreenRouteArgs>(
          orElse: () => RemoteShopDetailScreenRouteArgs(
              shopUrl: pathParams.getString('url')));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i49.RemoteShopDetailScreen(
          key: args.key,
          shopUrl: args.shopUrl,
        ),
      );
    },
    RemoteShopCollectionScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<RemoteShopCollectionScreenRouteArgs>(
          orElse: () => RemoteShopCollectionScreenRouteArgs(
                collectionId: pathParams.getInt('collectionId'),
                url: pathParams.getString('url'),
              ));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i50.RemoteShopCollectionScreen(
          key: args.key,
          collectionId: args.collectionId,
          url: args.url,
        ),
      );
    },
    WebShopDetailScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<WebShopDetailScreenRouteArgs>(
          orElse: () => WebShopDetailScreenRouteArgs(
              shopId: pathParams.getInt('shopId')));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i51.WebShopDetailScreen(
          key: args.key,
          shopId: args.shopId,
        ),
      );
    },
    WebShopChatScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<WebShopChatScreenRouteArgs>(
          orElse: () => WebShopChatScreenRouteArgs(
              identifier: pathParams.getString('identifier')));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i52.WebShopChatScreen(
          key: args.key,
          identifier: args.identifier,
        ),
      );
    },
    WebCollectionDetailScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<WebCollectionDetailScreenRouteArgs>(
          orElse: () => WebCollectionDetailScreenRouteArgs(
                shopId: pathParams.getInt('shopId'),
                collectionId: pathParams.getInt('collectionId'),
              ));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i53.WebCollectionDetailScreen(
          key: args.key,
          shopId: args.shopId,
          collectionId: args.collectionId,
        ),
      );
    },
    WebListingDetailScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<WebListingDetailScreenRouteArgs>(
          orElse: () => WebListingDetailScreenRouteArgs(
                shopId: pathParams.getInt('shopId'),
                collectionId: pathParams.getInt('collectionId'),
                listingId: pathParams.getInt('listingId'),
              ));
      return _i55.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i54.WebListingDetailScreen(
          key: args.key,
          shopId: args.shopId,
          collectionId: args.collectionId,
          listingId: args.listingId,
        ),
      );
    },
  };

  @override
  List<_i55.RouteConfig> get routes => [
        _i55.RouteConfig(
          RootContainerRoute.name,
          path: '/',
          children: [
            _i55.RouteConfig(
              HomeTabRouter.name,
              path: 'home',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  NewHomeScreenRoute.name,
                  path: '',
                  parent: HomeTabRouter.name,
                ),
                _i55.RouteConfig(
                  AllTokensScreenRoute.name,
                  path: 'all-tokens',
                  parent: HomeTabRouter.name,
                ),
              ],
            ),
            _i55.RouteConfig(
              SendTabRouter.name,
              path: 'send',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  SendScreenRoute.name,
                  path: '',
                  parent: SendTabRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              ReceiveTabRouter.name,
              path: 'receive',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  ReceiveScreenRoute.name,
                  path: '',
                  parent: ReceiveTabRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              TransactionsTabRouter.name,
              path: 'transactions',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  TransactionsScreenRoute.name,
                  path: '',
                  parent: TransactionsTabRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              ValidatorTabRouter.name,
              path: 'validator',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  ValidatorScreenRoute.name,
                  path: '',
                  parent: ValidatorTabRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              AdjudicatorTabRouter.name,
              path: 'adjudicator',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  AdjudicatorScreenRoute.name,
                  path: '',
                  parent: AdjudicatorTabRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              NodesTabsRouter.name,
              path: 'nodes',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  NodeListScreenRoute.name,
                  path: '',
                  parent: NodesTabsRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              DatanodeTabRouter.name,
              path: 'datanode',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  DataNodeScreenRoute.name,
                  path: '',
                  parent: DatanodeTabRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              NftTabRouter.name,
              path: 'nft',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  NftListScreenRoute.name,
                  path: '',
                  parent: NftTabRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              SmartContractsTabRouter.name,
              path: 'smart-contracts',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  SmartContractsScreenRoute.name,
                  path: '',
                  parent: SmartContractsTabRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              DstsTabRouter.name,
              path: 'dsts',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  DstLandingScreenRoute.name,
                  path: '',
                  parent: DstsTabRouter.name,
                ),
                _i55.RouteConfig(
                  SellerChatThreadListScreenRoute.name,
                  path: 'chat',
                  parent: DstsTabRouter.name,
                ),
                _i55.RouteConfig(
                  WebSellerChatScreenRoute.name,
                  path: 'chat/:shopId/:address',
                  parent: DstsTabRouter.name,
                ),
                _i55.RouteConfig(
                  MyCollectionsListScreenRoute.name,
                  path: 'me',
                  parent: DstsTabRouter.name,
                ),
                _i55.RouteConfig(
                  MyCollectionDetailScreenRoute.name,
                  path: ':collectionId',
                  parent: DstsTabRouter.name,
                ),
                _i55.RouteConfig(
                  CreateCollectionContainerScreenRoute.name,
                  path: 'createCollection',
                  parent: DstsTabRouter.name,
                ),
                _i55.RouteConfig(
                  CreateDecShopContainerScreenRoute.name,
                  path: 'createDecShop',
                  parent: DstsTabRouter.name,
                ),
                _i55.RouteConfig(
                  ListingDetailScreenRoute.name,
                  path: ':listingId',
                  parent: DstsTabRouter.name,
                ),
                _i55.RouteConfig(
                  ListingAuctionDetailScreenRoute.name,
                  path: ':listingId/auction',
                  parent: DstsTabRouter.name,
                ),
                _i55.RouteConfig(
                  CreateListingContainerScreenRoute.name,
                  path: 'createListing/:collectionId',
                  parent: DstsTabRouter.name,
                ),
              ],
            ),
            _i55.RouteConfig(
              AdnrTabRouter.name,
              path: 'adnr',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  AdnrScreenRoute.name,
                  path: '',
                  parent: AdnrTabRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              VotingTabRouter.name,
              path: 'voting',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  TopicListScreenRoute.name,
                  path: '',
                  parent: VotingTabRouter.name,
                ),
                _i55.RouteConfig(
                  TopicDetailScreenRoute.name,
                  path: ':uid',
                  parent: VotingTabRouter.name,
                ),
                _i55.RouteConfig(
                  CreateTopicScreenRoute.name,
                  path: 'create',
                  parent: VotingTabRouter.name,
                ),
              ],
            ),
            _i55.RouteConfig(
              BeaconTabRouter.name,
              path: 'beacons',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  BeaconListScreenRoute.name,
                  path: '',
                  parent: BeaconTabRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              ReserveAccountsTabRouter.name,
              path: 'reserve-accounts',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  ReserveAccountOverviewScreenRoute.name,
                  path: '',
                  parent: ReserveAccountsTabRouter.name,
                ),
                _i55.RouteConfig(
                  ManageReserveAccountsScreenRoute.name,
                  path: 'manage',
                  parent: ReserveAccountsTabRouter.name,
                ),
              ],
            ),
            _i55.RouteConfig(
              TokenizeBtcTabRouter.name,
              path: 'tokenize-btc',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  TokenizeBtcListScreenRoute.name,
                  path: '',
                  parent: TokenizeBtcTabRouter.name,
                )
              ],
            ),
            _i55.RouteConfig(
              TokenTabRouter.name,
              path: 'tokens',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  TokenListScreenRoute.name,
                  path: '',
                  parent: TokenTabRouter.name,
                ),
                _i55.RouteConfig(
                  TokenCreateScreenRoute.name,
                  path: 'create',
                  parent: TokenTabRouter.name,
                ),
                _i55.RouteConfig(
                  CreateTokenTopicScreenRoute.name,
                  path: 'create-topic/:scId/:address',
                  parent: TokenTabRouter.name,
                ),
              ],
            ),
            _i55.RouteConfig(
              OperationsTabRouter.name,
              path: 'operations',
              parent: RootContainerRoute.name,
              children: [
                _i55.RouteConfig(
                  OperationsScreenRoute.name,
                  path: '',
                  parent: OperationsTabRouter.name,
                )
              ],
            ),
          ],
        ),
        _i55.RouteConfig(
          MySmartContractsScreenRoute.name,
          path: 'my-smart-contracts',
        ),
        _i55.RouteConfig(
          SmartContractDraftsScreenRoute.name,
          path: 'smart-contract-drafts',
        ),
        _i55.RouteConfig(
          TemplateChooserScreenRoute.name,
          path: 'smart-contract-templates',
        ),
        _i55.RouteConfig(
          BulkCreateScreenRoute.name,
          path: 'bulk-create-smart-contracts',
        ),
        _i55.RouteConfig(
          ConfigContainerScreenRoute.name,
          path: 'config',
        ),
        _i55.RouteConfig(
          SmartContractCreatorContainerScreenRoute.name,
          path: 'create-smart-contract',
          children: [
            _i55.RouteConfig(
              '#redirect',
              path: '',
              parent: SmartContractCreatorContainerScreenRoute.name,
              redirectTo: 'main',
              fullMatch: true,
            ),
            _i55.RouteConfig(
              SmartContractCreatorMainRoute.name,
              path: 'main',
              parent: SmartContractCreatorContainerScreenRoute.name,
            ),
          ],
        ),
        _i55.RouteConfig(
          MotherDashboardScreenRoute.name,
          path: 'mother-dashboard',
        ),
        _i55.RouteConfig(
          RemoteShopContainerScreenRoute.name,
          path: 'remote-shop-container',
          children: [
            _i55.RouteConfig(
              '#redirect',
              path: '',
              parent: RemoteShopContainerScreenRoute.name,
              redirectTo: 'shops',
              fullMatch: true,
            ),
            _i55.RouteConfig(
              WebShopListScreenRoute.name,
              path: 'shops',
              parent: RemoteShopContainerScreenRoute.name,
            ),
            _i55.RouteConfig(
              BuyerChatThreadListScreenRoute.name,
              path: 'shops/chat',
              parent: RemoteShopContainerScreenRoute.name,
            ),
            _i55.RouteConfig(
              RemoteShopDetailScreenRoute.name,
              path: 'shops/:url',
              parent: RemoteShopContainerScreenRoute.name,
            ),
            _i55.RouteConfig(
              RemoteShopCollectionScreenRoute.name,
              path: 'shops/:url/collection/:collectionId',
              parent: RemoteShopContainerScreenRoute.name,
            ),
            _i55.RouteConfig(
              WebShopDetailScreenRoute.name,
              path: 'third-party/shop/:shopId',
              parent: RemoteShopContainerScreenRoute.name,
            ),
            _i55.RouteConfig(
              WebShopChatScreenRoute.name,
              path: 'third-party/shop/:identifier/shop',
              parent: RemoteShopContainerScreenRoute.name,
            ),
            _i55.RouteConfig(
              WebCollectionDetailScreenRoute.name,
              path: 'third-party/shop/:shopId/collection/:collectionId',
              parent: RemoteShopContainerScreenRoute.name,
            ),
            _i55.RouteConfig(
              WebListingDetailScreenRoute.name,
              path:
                  'third-party/shop/:shopId/collection/:collectionId/listing/:listingId',
              parent: RemoteShopContainerScreenRoute.name,
            ),
          ],
        ),
        _i55.RouteConfig(
          SellerChatScreenRoute.name,
          path: 'chat/:address',
        ),
        _i55.RouteConfig(
          ShopChatScreenRoute.name,
          path: 'shops/:url/chat',
        ),
      ];
}

/// generated route for
/// [_i1.RootContainer]
class RootContainerRoute extends _i55.PageRouteInfo<void> {
  const RootContainerRoute({List<_i55.PageRouteInfo>? children})
      : super(
          RootContainerRoute.name,
          path: '/',
          initialChildren: children,
        );

  static const String name = 'RootContainerRoute';
}

/// generated route for
/// [_i2.MySmartContractsScreen]
class MySmartContractsScreenRoute extends _i55.PageRouteInfo<void> {
  const MySmartContractsScreenRoute()
      : super(
          MySmartContractsScreenRoute.name,
          path: 'my-smart-contracts',
        );

  static const String name = 'MySmartContractsScreenRoute';
}

/// generated route for
/// [_i3.SmartContractDraftsScreen]
class SmartContractDraftsScreenRoute extends _i55.PageRouteInfo<void> {
  const SmartContractDraftsScreenRoute()
      : super(
          SmartContractDraftsScreenRoute.name,
          path: 'smart-contract-drafts',
        );

  static const String name = 'SmartContractDraftsScreenRoute';
}

/// generated route for
/// [_i4.TemplateChooserScreen]
class TemplateChooserScreenRoute extends _i55.PageRouteInfo<void> {
  const TemplateChooserScreenRoute()
      : super(
          TemplateChooserScreenRoute.name,
          path: 'smart-contract-templates',
        );

  static const String name = 'TemplateChooserScreenRoute';
}

/// generated route for
/// [_i5.BulkCreateScreen]
class BulkCreateScreenRoute extends _i55.PageRouteInfo<void> {
  const BulkCreateScreenRoute()
      : super(
          BulkCreateScreenRoute.name,
          path: 'bulk-create-smart-contracts',
        );

  static const String name = 'BulkCreateScreenRoute';
}

/// generated route for
/// [_i6.ConfigContainerScreen]
class ConfigContainerScreenRoute extends _i55.PageRouteInfo<void> {
  const ConfigContainerScreenRoute()
      : super(
          ConfigContainerScreenRoute.name,
          path: 'config',
        );

  static const String name = 'ConfigContainerScreenRoute';
}

/// generated route for
/// [_i7.SmartContractCreatorContainerScreen]
class SmartContractCreatorContainerScreenRoute
    extends _i55.PageRouteInfo<void> {
  const SmartContractCreatorContainerScreenRoute(
      {List<_i55.PageRouteInfo>? children})
      : super(
          SmartContractCreatorContainerScreenRoute.name,
          path: 'create-smart-contract',
          initialChildren: children,
        );

  static const String name = 'SmartContractCreatorContainerScreenRoute';
}

/// generated route for
/// [_i8.MotherDashboardScreen]
class MotherDashboardScreenRoute extends _i55.PageRouteInfo<void> {
  const MotherDashboardScreenRoute()
      : super(
          MotherDashboardScreenRoute.name,
          path: 'mother-dashboard',
        );

  static const String name = 'MotherDashboardScreenRoute';
}

/// generated route for
/// [_i9.RemoteShopContainerScreen]
class RemoteShopContainerScreenRoute extends _i55.PageRouteInfo<void> {
  const RemoteShopContainerScreenRoute({List<_i55.PageRouteInfo>? children})
      : super(
          RemoteShopContainerScreenRoute.name,
          path: 'remote-shop-container',
          initialChildren: children,
        );

  static const String name = 'RemoteShopContainerScreenRoute';
}

/// generated route for
/// [_i10.SellerChatScreen]
class SellerChatScreenRoute
    extends _i55.PageRouteInfo<SellerChatScreenRouteArgs> {
  SellerChatScreenRoute({
    _i57.Key? key,
    required String address,
  }) : super(
          SellerChatScreenRoute.name,
          path: 'chat/:address',
          args: SellerChatScreenRouteArgs(
            key: key,
            address: address,
          ),
          rawPathParams: {'address': address},
        );

  static const String name = 'SellerChatScreenRoute';
}

class SellerChatScreenRouteArgs {
  const SellerChatScreenRouteArgs({
    this.key,
    required this.address,
  });

  final _i57.Key? key;

  final String address;

  @override
  String toString() {
    return 'SellerChatScreenRouteArgs{key: $key, address: $address}';
  }
}

/// generated route for
/// [_i11.ShopChatScreen]
class ShopChatScreenRoute extends _i55.PageRouteInfo<ShopChatScreenRouteArgs> {
  ShopChatScreenRoute({
    _i57.Key? key,
    required String url,
  }) : super(
          ShopChatScreenRoute.name,
          path: 'shops/:url/chat',
          args: ShopChatScreenRouteArgs(
            key: key,
            url: url,
          ),
          rawPathParams: {'url': url},
        );

  static const String name = 'ShopChatScreenRoute';
}

class ShopChatScreenRouteArgs {
  const ShopChatScreenRouteArgs({
    this.key,
    required this.url,
  });

  final _i57.Key? key;

  final String url;

  @override
  String toString() {
    return 'ShopChatScreenRouteArgs{key: $key, url: $url}';
  }
}

/// generated route for
/// [_i12.EmptyRouterPage]
class HomeTabRouter extends _i55.PageRouteInfo<void> {
  const HomeTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          HomeTabRouter.name,
          path: 'home',
          initialChildren: children,
        );

  static const String name = 'HomeTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class SendTabRouter extends _i55.PageRouteInfo<void> {
  const SendTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          SendTabRouter.name,
          path: 'send',
          initialChildren: children,
        );

  static const String name = 'SendTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class ReceiveTabRouter extends _i55.PageRouteInfo<void> {
  const ReceiveTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          ReceiveTabRouter.name,
          path: 'receive',
          initialChildren: children,
        );

  static const String name = 'ReceiveTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class TransactionsTabRouter extends _i55.PageRouteInfo<void> {
  const TransactionsTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          TransactionsTabRouter.name,
          path: 'transactions',
          initialChildren: children,
        );

  static const String name = 'TransactionsTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class ValidatorTabRouter extends _i55.PageRouteInfo<void> {
  const ValidatorTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          ValidatorTabRouter.name,
          path: 'validator',
          initialChildren: children,
        );

  static const String name = 'ValidatorTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class AdjudicatorTabRouter extends _i55.PageRouteInfo<void> {
  const AdjudicatorTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          AdjudicatorTabRouter.name,
          path: 'adjudicator',
          initialChildren: children,
        );

  static const String name = 'AdjudicatorTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class NodesTabsRouter extends _i55.PageRouteInfo<void> {
  const NodesTabsRouter({List<_i55.PageRouteInfo>? children})
      : super(
          NodesTabsRouter.name,
          path: 'nodes',
          initialChildren: children,
        );

  static const String name = 'NodesTabsRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class DatanodeTabRouter extends _i55.PageRouteInfo<void> {
  const DatanodeTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          DatanodeTabRouter.name,
          path: 'datanode',
          initialChildren: children,
        );

  static const String name = 'DatanodeTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class NftTabRouter extends _i55.PageRouteInfo<void> {
  const NftTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          NftTabRouter.name,
          path: 'nft',
          initialChildren: children,
        );

  static const String name = 'NftTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class SmartContractsTabRouter extends _i55.PageRouteInfo<void> {
  const SmartContractsTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          SmartContractsTabRouter.name,
          path: 'smart-contracts',
          initialChildren: children,
        );

  static const String name = 'SmartContractsTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class DstsTabRouter extends _i55.PageRouteInfo<void> {
  const DstsTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          DstsTabRouter.name,
          path: 'dsts',
          initialChildren: children,
        );

  static const String name = 'DstsTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class AdnrTabRouter extends _i55.PageRouteInfo<void> {
  const AdnrTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          AdnrTabRouter.name,
          path: 'adnr',
          initialChildren: children,
        );

  static const String name = 'AdnrTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class VotingTabRouter extends _i55.PageRouteInfo<void> {
  const VotingTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          VotingTabRouter.name,
          path: 'voting',
          initialChildren: children,
        );

  static const String name = 'VotingTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class BeaconTabRouter extends _i55.PageRouteInfo<void> {
  const BeaconTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          BeaconTabRouter.name,
          path: 'beacons',
          initialChildren: children,
        );

  static const String name = 'BeaconTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class ReserveAccountsTabRouter extends _i55.PageRouteInfo<void> {
  const ReserveAccountsTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          ReserveAccountsTabRouter.name,
          path: 'reserve-accounts',
          initialChildren: children,
        );

  static const String name = 'ReserveAccountsTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class TokenizeBtcTabRouter extends _i55.PageRouteInfo<void> {
  const TokenizeBtcTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          TokenizeBtcTabRouter.name,
          path: 'tokenize-btc',
          initialChildren: children,
        );

  static const String name = 'TokenizeBtcTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class TokenTabRouter extends _i55.PageRouteInfo<void> {
  const TokenTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          TokenTabRouter.name,
          path: 'tokens',
          initialChildren: children,
        );

  static const String name = 'TokenTabRouter';
}

/// generated route for
/// [_i12.EmptyRouterPage]
class OperationsTabRouter extends _i55.PageRouteInfo<void> {
  const OperationsTabRouter({List<_i55.PageRouteInfo>? children})
      : super(
          OperationsTabRouter.name,
          path: 'operations',
          initialChildren: children,
        );

  static const String name = 'OperationsTabRouter';
}

/// generated route for
/// [_i13.NewHomeScreen]
class NewHomeScreenRoute extends _i55.PageRouteInfo<NewHomeScreenRouteArgs> {
  NewHomeScreenRoute({
    _i57.Key? key,
    double verticalPadding = 0,
    double horizontalPadding = 0,
  }) : super(
          NewHomeScreenRoute.name,
          path: '',
          args: NewHomeScreenRouteArgs(
            key: key,
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding,
          ),
        );

  static const String name = 'NewHomeScreenRoute';
}

class NewHomeScreenRouteArgs {
  const NewHomeScreenRouteArgs({
    this.key,
    this.verticalPadding = 0,
    this.horizontalPadding = 0,
  });

  final _i57.Key? key;

  final double verticalPadding;

  final double horizontalPadding;

  @override
  String toString() {
    return 'NewHomeScreenRouteArgs{key: $key, verticalPadding: $verticalPadding, horizontalPadding: $horizontalPadding}';
  }
}

/// generated route for
/// [_i14.AllTokensScreen]
class AllTokensScreenRoute extends _i55.PageRouteInfo<void> {
  const AllTokensScreenRoute()
      : super(
          AllTokensScreenRoute.name,
          path: 'all-tokens',
        );

  static const String name = 'AllTokensScreenRoute';
}

/// generated route for
/// [_i15.SendScreen]
class SendScreenRoute extends _i55.PageRouteInfo<void> {
  const SendScreenRoute()
      : super(
          SendScreenRoute.name,
          path: '',
        );

  static const String name = 'SendScreenRoute';
}

/// generated route for
/// [_i16.ReceiveScreen]
class ReceiveScreenRoute extends _i55.PageRouteInfo<void> {
  const ReceiveScreenRoute()
      : super(
          ReceiveScreenRoute.name,
          path: '',
        );

  static const String name = 'ReceiveScreenRoute';
}

/// generated route for
/// [_i17.TransactionsScreen]
class TransactionsScreenRoute extends _i55.PageRouteInfo<void> {
  const TransactionsScreenRoute()
      : super(
          TransactionsScreenRoute.name,
          path: '',
        );

  static const String name = 'TransactionsScreenRoute';
}

/// generated route for
/// [_i18.ValidatorScreen]
class ValidatorScreenRoute extends _i55.PageRouteInfo<void> {
  const ValidatorScreenRoute()
      : super(
          ValidatorScreenRoute.name,
          path: '',
        );

  static const String name = 'ValidatorScreenRoute';
}

/// generated route for
/// [_i19.AdjudicatorScreen]
class AdjudicatorScreenRoute extends _i55.PageRouteInfo<void> {
  const AdjudicatorScreenRoute()
      : super(
          AdjudicatorScreenRoute.name,
          path: '',
        );

  static const String name = 'AdjudicatorScreenRoute';
}

/// generated route for
/// [_i20.NodeListScreen]
class NodeListScreenRoute extends _i55.PageRouteInfo<void> {
  const NodeListScreenRoute()
      : super(
          NodeListScreenRoute.name,
          path: '',
        );

  static const String name = 'NodeListScreenRoute';
}

/// generated route for
/// [_i21.DataNodeScreen]
class DataNodeScreenRoute extends _i55.PageRouteInfo<void> {
  const DataNodeScreenRoute()
      : super(
          DataNodeScreenRoute.name,
          path: '',
        );

  static const String name = 'DataNodeScreenRoute';
}

/// generated route for
/// [_i22.NftListScreen]
class NftListScreenRoute extends _i55.PageRouteInfo<void> {
  const NftListScreenRoute()
      : super(
          NftListScreenRoute.name,
          path: '',
        );

  static const String name = 'NftListScreenRoute';
}

/// generated route for
/// [_i23.SmartContractsScreen]
class SmartContractsScreenRoute extends _i55.PageRouteInfo<void> {
  const SmartContractsScreenRoute()
      : super(
          SmartContractsScreenRoute.name,
          path: '',
        );

  static const String name = 'SmartContractsScreenRoute';
}

/// generated route for
/// [_i24.DstLandingScreen]
class DstLandingScreenRoute extends _i55.PageRouteInfo<void> {
  const DstLandingScreenRoute()
      : super(
          DstLandingScreenRoute.name,
          path: '',
        );

  static const String name = 'DstLandingScreenRoute';
}

/// generated route for
/// [_i25.SellerChatThreadListScreen]
class SellerChatThreadListScreenRoute extends _i55.PageRouteInfo<void> {
  const SellerChatThreadListScreenRoute()
      : super(
          SellerChatThreadListScreenRoute.name,
          path: 'chat',
        );

  static const String name = 'SellerChatThreadListScreenRoute';
}

/// generated route for
/// [_i26.WebSellerChatScreen]
class WebSellerChatScreenRoute
    extends _i55.PageRouteInfo<WebSellerChatScreenRouteArgs> {
  WebSellerChatScreenRoute({
    _i57.Key? key,
    required String address,
    required int shopId,
  }) : super(
          WebSellerChatScreenRoute.name,
          path: 'chat/:shopId/:address',
          args: WebSellerChatScreenRouteArgs(
            key: key,
            address: address,
            shopId: shopId,
          ),
          rawPathParams: {
            'address': address,
            'shopId': shopId,
          },
        );

  static const String name = 'WebSellerChatScreenRoute';
}

class WebSellerChatScreenRouteArgs {
  const WebSellerChatScreenRouteArgs({
    this.key,
    required this.address,
    required this.shopId,
  });

  final _i57.Key? key;

  final String address;

  final int shopId;

  @override
  String toString() {
    return 'WebSellerChatScreenRouteArgs{key: $key, address: $address, shopId: $shopId}';
  }
}

/// generated route for
/// [_i27.MyCollectionsListScreen]
class MyCollectionsListScreenRoute extends _i55.PageRouteInfo<void> {
  const MyCollectionsListScreenRoute()
      : super(
          MyCollectionsListScreenRoute.name,
          path: 'me',
        );

  static const String name = 'MyCollectionsListScreenRoute';
}

/// generated route for
/// [_i28.MyCollectionDetailScreen]
class MyCollectionDetailScreenRoute
    extends _i55.PageRouteInfo<MyCollectionDetailScreenRouteArgs> {
  MyCollectionDetailScreenRoute({
    _i57.Key? key,
    required int collectionId,
  }) : super(
          MyCollectionDetailScreenRoute.name,
          path: ':collectionId',
          args: MyCollectionDetailScreenRouteArgs(
            key: key,
            collectionId: collectionId,
          ),
          rawPathParams: {'collectionId': collectionId},
        );

  static const String name = 'MyCollectionDetailScreenRoute';
}

class MyCollectionDetailScreenRouteArgs {
  const MyCollectionDetailScreenRouteArgs({
    this.key,
    required this.collectionId,
  });

  final _i57.Key? key;

  final int collectionId;

  @override
  String toString() {
    return 'MyCollectionDetailScreenRouteArgs{key: $key, collectionId: $collectionId}';
  }
}

/// generated route for
/// [_i29.CreateCollectionContainerScreen]
class CreateCollectionContainerScreenRoute extends _i55.PageRouteInfo<void> {
  const CreateCollectionContainerScreenRoute()
      : super(
          CreateCollectionContainerScreenRoute.name,
          path: 'createCollection',
        );

  static const String name = 'CreateCollectionContainerScreenRoute';
}

/// generated route for
/// [_i30.CreateDecShopContainerScreen]
class CreateDecShopContainerScreenRoute extends _i55.PageRouteInfo<void> {
  const CreateDecShopContainerScreenRoute()
      : super(
          CreateDecShopContainerScreenRoute.name,
          path: 'createDecShop',
        );

  static const String name = 'CreateDecShopContainerScreenRoute';
}

/// generated route for
/// [_i31.ListingDetailScreen]
class ListingDetailScreenRoute
    extends _i55.PageRouteInfo<ListingDetailScreenRouteArgs> {
  ListingDetailScreenRoute({
    _i57.Key? key,
    required int listingId,
  }) : super(
          ListingDetailScreenRoute.name,
          path: ':listingId',
          args: ListingDetailScreenRouteArgs(
            key: key,
            listingId: listingId,
          ),
          rawPathParams: {'listingId': listingId},
        );

  static const String name = 'ListingDetailScreenRoute';
}

class ListingDetailScreenRouteArgs {
  const ListingDetailScreenRouteArgs({
    this.key,
    required this.listingId,
  });

  final _i57.Key? key;

  final int listingId;

  @override
  String toString() {
    return 'ListingDetailScreenRouteArgs{key: $key, listingId: $listingId}';
  }
}

/// generated route for
/// [_i32.ListingAuctionDetailScreen]
class ListingAuctionDetailScreenRoute
    extends _i55.PageRouteInfo<ListingAuctionDetailScreenRouteArgs> {
  ListingAuctionDetailScreenRoute({
    _i57.Key? key,
    required int listingId,
  }) : super(
          ListingAuctionDetailScreenRoute.name,
          path: ':listingId/auction',
          args: ListingAuctionDetailScreenRouteArgs(
            key: key,
            listingId: listingId,
          ),
          rawPathParams: {'listingId': listingId},
        );

  static const String name = 'ListingAuctionDetailScreenRoute';
}

class ListingAuctionDetailScreenRouteArgs {
  const ListingAuctionDetailScreenRouteArgs({
    this.key,
    required this.listingId,
  });

  final _i57.Key? key;

  final int listingId;

  @override
  String toString() {
    return 'ListingAuctionDetailScreenRouteArgs{key: $key, listingId: $listingId}';
  }
}

/// generated route for
/// [_i33.CreateListingContainerScreen]
class CreateListingContainerScreenRoute
    extends _i55.PageRouteInfo<CreateListingContainerScreenRouteArgs> {
  CreateListingContainerScreenRoute({
    required int collectionId,
    _i57.Key? key,
  }) : super(
          CreateListingContainerScreenRoute.name,
          path: 'createListing/:collectionId',
          args: CreateListingContainerScreenRouteArgs(
            collectionId: collectionId,
            key: key,
          ),
          rawPathParams: {'collectionId': collectionId},
        );

  static const String name = 'CreateListingContainerScreenRoute';
}

class CreateListingContainerScreenRouteArgs {
  const CreateListingContainerScreenRouteArgs({
    required this.collectionId,
    this.key,
  });

  final int collectionId;

  final _i57.Key? key;

  @override
  String toString() {
    return 'CreateListingContainerScreenRouteArgs{collectionId: $collectionId, key: $key}';
  }
}

/// generated route for
/// [_i34.AdnrScreen]
class AdnrScreenRoute extends _i55.PageRouteInfo<void> {
  const AdnrScreenRoute()
      : super(
          AdnrScreenRoute.name,
          path: '',
        );

  static const String name = 'AdnrScreenRoute';
}

/// generated route for
/// [_i35.TopicListScreen]
class TopicListScreenRoute extends _i55.PageRouteInfo<void> {
  const TopicListScreenRoute()
      : super(
          TopicListScreenRoute.name,
          path: '',
        );

  static const String name = 'TopicListScreenRoute';
}

/// generated route for
/// [_i36.TopicDetailScreen]
class TopicDetailScreenRoute
    extends _i55.PageRouteInfo<TopicDetailScreenRouteArgs> {
  TopicDetailScreenRoute({
    _i57.Key? key,
    required String topicUid,
  }) : super(
          TopicDetailScreenRoute.name,
          path: ':uid',
          args: TopicDetailScreenRouteArgs(
            key: key,
            topicUid: topicUid,
          ),
          rawPathParams: {'uid': topicUid},
        );

  static const String name = 'TopicDetailScreenRoute';
}

class TopicDetailScreenRouteArgs {
  const TopicDetailScreenRouteArgs({
    this.key,
    required this.topicUid,
  });

  final _i57.Key? key;

  final String topicUid;

  @override
  String toString() {
    return 'TopicDetailScreenRouteArgs{key: $key, topicUid: $topicUid}';
  }
}

/// generated route for
/// [_i37.CreateTopicScreen]
class CreateTopicScreenRoute extends _i55.PageRouteInfo<void> {
  const CreateTopicScreenRoute()
      : super(
          CreateTopicScreenRoute.name,
          path: 'create',
        );

  static const String name = 'CreateTopicScreenRoute';
}

/// generated route for
/// [_i38.BeaconListScreen]
class BeaconListScreenRoute extends _i55.PageRouteInfo<void> {
  const BeaconListScreenRoute()
      : super(
          BeaconListScreenRoute.name,
          path: '',
        );

  static const String name = 'BeaconListScreenRoute';
}

/// generated route for
/// [_i39.ReserveAccountOverviewScreen]
class ReserveAccountOverviewScreenRoute extends _i55.PageRouteInfo<void> {
  const ReserveAccountOverviewScreenRoute()
      : super(
          ReserveAccountOverviewScreenRoute.name,
          path: '',
        );

  static const String name = 'ReserveAccountOverviewScreenRoute';
}

/// generated route for
/// [_i40.ManageReserveAccountsScreen]
class ManageReserveAccountsScreenRoute extends _i55.PageRouteInfo<void> {
  const ManageReserveAccountsScreenRoute()
      : super(
          ManageReserveAccountsScreenRoute.name,
          path: 'manage',
        );

  static const String name = 'ManageReserveAccountsScreenRoute';
}

/// generated route for
/// [_i41.TokenizeBtcListScreen]
class TokenizeBtcListScreenRoute extends _i55.PageRouteInfo<void> {
  const TokenizeBtcListScreenRoute()
      : super(
          TokenizeBtcListScreenRoute.name,
          path: '',
        );

  static const String name = 'TokenizeBtcListScreenRoute';
}

/// generated route for
/// [_i42.TokenListScreen]
class TokenListScreenRoute extends _i55.PageRouteInfo<void> {
  const TokenListScreenRoute()
      : super(
          TokenListScreenRoute.name,
          path: '',
        );

  static const String name = 'TokenListScreenRoute';
}

/// generated route for
/// [_i43.TokenCreateScreen]
class TokenCreateScreenRoute extends _i55.PageRouteInfo<void> {
  const TokenCreateScreenRoute()
      : super(
          TokenCreateScreenRoute.name,
          path: 'create',
        );

  static const String name = 'TokenCreateScreenRoute';
}

/// generated route for
/// [_i44.CreateTokenTopicScreen]
class CreateTokenTopicScreenRoute
    extends _i55.PageRouteInfo<CreateTokenTopicScreenRouteArgs> {
  CreateTokenTopicScreenRoute({
    _i57.Key? key,
    required String scId,
    required String address,
  }) : super(
          CreateTokenTopicScreenRoute.name,
          path: 'create-topic/:scId/:address',
          args: CreateTokenTopicScreenRouteArgs(
            key: key,
            scId: scId,
            address: address,
          ),
          rawPathParams: {
            'scId': scId,
            'address': address,
          },
        );

  static const String name = 'CreateTokenTopicScreenRoute';
}

class CreateTokenTopicScreenRouteArgs {
  const CreateTokenTopicScreenRouteArgs({
    this.key,
    required this.scId,
    required this.address,
  });

  final _i57.Key? key;

  final String scId;

  final String address;

  @override
  String toString() {
    return 'CreateTokenTopicScreenRouteArgs{key: $key, scId: $scId, address: $address}';
  }
}

/// generated route for
/// [_i45.OperationsScreen]
class OperationsScreenRoute extends _i55.PageRouteInfo<void> {
  const OperationsScreenRoute()
      : super(
          OperationsScreenRoute.name,
          path: '',
        );

  static const String name = 'OperationsScreenRoute';
}

/// generated route for
/// [_i46.SmartContractCreatorMain]
class SmartContractCreatorMainRoute extends _i55.PageRouteInfo<void> {
  const SmartContractCreatorMainRoute()
      : super(
          SmartContractCreatorMainRoute.name,
          path: 'main',
        );

  static const String name = 'SmartContractCreatorMainRoute';
}

/// generated route for
/// [_i47.WebShopListScreen]
class WebShopListScreenRoute extends _i55.PageRouteInfo<void> {
  const WebShopListScreenRoute()
      : super(
          WebShopListScreenRoute.name,
          path: 'shops',
        );

  static const String name = 'WebShopListScreenRoute';
}

/// generated route for
/// [_i48.BuyerChatThreadListScreen]
class BuyerChatThreadListScreenRoute extends _i55.PageRouteInfo<void> {
  const BuyerChatThreadListScreenRoute()
      : super(
          BuyerChatThreadListScreenRoute.name,
          path: 'shops/chat',
        );

  static const String name = 'BuyerChatThreadListScreenRoute';
}

/// generated route for
/// [_i49.RemoteShopDetailScreen]
class RemoteShopDetailScreenRoute
    extends _i55.PageRouteInfo<RemoteShopDetailScreenRouteArgs> {
  RemoteShopDetailScreenRoute({
    _i57.Key? key,
    required String shopUrl,
  }) : super(
          RemoteShopDetailScreenRoute.name,
          path: 'shops/:url',
          args: RemoteShopDetailScreenRouteArgs(
            key: key,
            shopUrl: shopUrl,
          ),
          rawPathParams: {'url': shopUrl},
        );

  static const String name = 'RemoteShopDetailScreenRoute';
}

class RemoteShopDetailScreenRouteArgs {
  const RemoteShopDetailScreenRouteArgs({
    this.key,
    required this.shopUrl,
  });

  final _i57.Key? key;

  final String shopUrl;

  @override
  String toString() {
    return 'RemoteShopDetailScreenRouteArgs{key: $key, shopUrl: $shopUrl}';
  }
}

/// generated route for
/// [_i50.RemoteShopCollectionScreen]
class RemoteShopCollectionScreenRoute
    extends _i55.PageRouteInfo<RemoteShopCollectionScreenRouteArgs> {
  RemoteShopCollectionScreenRoute({
    _i57.Key? key,
    required int collectionId,
    required String url,
  }) : super(
          RemoteShopCollectionScreenRoute.name,
          path: 'shops/:url/collection/:collectionId',
          args: RemoteShopCollectionScreenRouteArgs(
            key: key,
            collectionId: collectionId,
            url: url,
          ),
          rawPathParams: {
            'collectionId': collectionId,
            'url': url,
          },
        );

  static const String name = 'RemoteShopCollectionScreenRoute';
}

class RemoteShopCollectionScreenRouteArgs {
  const RemoteShopCollectionScreenRouteArgs({
    this.key,
    required this.collectionId,
    required this.url,
  });

  final _i57.Key? key;

  final int collectionId;

  final String url;

  @override
  String toString() {
    return 'RemoteShopCollectionScreenRouteArgs{key: $key, collectionId: $collectionId, url: $url}';
  }
}

/// generated route for
/// [_i51.WebShopDetailScreen]
class WebShopDetailScreenRoute
    extends _i55.PageRouteInfo<WebShopDetailScreenRouteArgs> {
  WebShopDetailScreenRoute({
    _i57.Key? key,
    required int shopId,
  }) : super(
          WebShopDetailScreenRoute.name,
          path: 'third-party/shop/:shopId',
          args: WebShopDetailScreenRouteArgs(
            key: key,
            shopId: shopId,
          ),
          rawPathParams: {'shopId': shopId},
        );

  static const String name = 'WebShopDetailScreenRoute';
}

class WebShopDetailScreenRouteArgs {
  const WebShopDetailScreenRouteArgs({
    this.key,
    required this.shopId,
  });

  final _i57.Key? key;

  final int shopId;

  @override
  String toString() {
    return 'WebShopDetailScreenRouteArgs{key: $key, shopId: $shopId}';
  }
}

/// generated route for
/// [_i52.WebShopChatScreen]
class WebShopChatScreenRoute
    extends _i55.PageRouteInfo<WebShopChatScreenRouteArgs> {
  WebShopChatScreenRoute({
    _i57.Key? key,
    required String identifier,
  }) : super(
          WebShopChatScreenRoute.name,
          path: 'third-party/shop/:identifier/shop',
          args: WebShopChatScreenRouteArgs(
            key: key,
            identifier: identifier,
          ),
          rawPathParams: {'identifier': identifier},
        );

  static const String name = 'WebShopChatScreenRoute';
}

class WebShopChatScreenRouteArgs {
  const WebShopChatScreenRouteArgs({
    this.key,
    required this.identifier,
  });

  final _i57.Key? key;

  final String identifier;

  @override
  String toString() {
    return 'WebShopChatScreenRouteArgs{key: $key, identifier: $identifier}';
  }
}

/// generated route for
/// [_i53.WebCollectionDetailScreen]
class WebCollectionDetailScreenRoute
    extends _i55.PageRouteInfo<WebCollectionDetailScreenRouteArgs> {
  WebCollectionDetailScreenRoute({
    _i57.Key? key,
    required int shopId,
    required int collectionId,
  }) : super(
          WebCollectionDetailScreenRoute.name,
          path: 'third-party/shop/:shopId/collection/:collectionId',
          args: WebCollectionDetailScreenRouteArgs(
            key: key,
            shopId: shopId,
            collectionId: collectionId,
          ),
          rawPathParams: {
            'shopId': shopId,
            'collectionId': collectionId,
          },
        );

  static const String name = 'WebCollectionDetailScreenRoute';
}

class WebCollectionDetailScreenRouteArgs {
  const WebCollectionDetailScreenRouteArgs({
    this.key,
    required this.shopId,
    required this.collectionId,
  });

  final _i57.Key? key;

  final int shopId;

  final int collectionId;

  @override
  String toString() {
    return 'WebCollectionDetailScreenRouteArgs{key: $key, shopId: $shopId, collectionId: $collectionId}';
  }
}

/// generated route for
/// [_i54.WebListingDetailScreen]
class WebListingDetailScreenRoute
    extends _i55.PageRouteInfo<WebListingDetailScreenRouteArgs> {
  WebListingDetailScreenRoute({
    _i57.Key? key,
    required int shopId,
    required int collectionId,
    required int listingId,
  }) : super(
          WebListingDetailScreenRoute.name,
          path:
              'third-party/shop/:shopId/collection/:collectionId/listing/:listingId',
          args: WebListingDetailScreenRouteArgs(
            key: key,
            shopId: shopId,
            collectionId: collectionId,
            listingId: listingId,
          ),
          rawPathParams: {
            'shopId': shopId,
            'collectionId': collectionId,
            'listingId': listingId,
          },
        );

  static const String name = 'WebListingDetailScreenRoute';
}

class WebListingDetailScreenRouteArgs {
  const WebListingDetailScreenRouteArgs({
    this.key,
    required this.shopId,
    required this.collectionId,
    required this.listingId,
  });

  final _i57.Key? key;

  final int shopId;

  final int collectionId;

  final int listingId;

  @override
  String toString() {
    return 'WebListingDetailScreenRouteArgs{key: $key, shopId: $shopId, collectionId: $collectionId, listingId: $listingId}';
  }
}
