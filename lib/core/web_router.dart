import 'package:auto_route/auto_route.dart';
import 'package:auto_route/empty_router_widgets.dart';
import '../features/adnr/screens/web_adnr_screen.dart';
import '../features/btc/screens/tokenize_btc_screen.dart';
import '../features/btc/screens/tokenized_btc_list_screen.dart';
import '../features/btc_web/screens/web_tokenized_btc_detail_screen.dart';
import '../features/chat/screens/web_seller_chat_thread_list_screen.dart';
import '../features/chat/screens/web_seller_chat_screen.dart';
import '../features/chat/screens/web_shop_chat_screen.dart';
import '../features/home/screens/all_tokens_screen.dart';
import '../features/token/screens/token_create_screen.dart';
import '../features/token/screens/token_list_screen.dart';
import '../features/token/screens/token_topic_create_screen.dart';
import '../features/token/screens/web_token_create_screen.dart';
import '../features/token/screens/web_token_detail_screen.dart';
import '../features/web_shop/screens/build_sale_start_tx_screen.dart';
import '../features/web_shop/screens/web_shop_container_screen.dart';

import '../features/auth/screens/web_auth_screen.dart';
// import '../features/dsts/screens/create_store_screen.dart';
// import '../features/dsts/screens/web_dst_screen.dart';
import '../features/home/screens/web_home_screen.dart';
import '../features/nft/screens/nft_detail_screen.dart';
import '../features/nft/screens/nft_list_screen.dart';
import '../features/receive/screens/web_receive_screen.dart';
import '../features/root/web_dashboard_container.dart';
import '../features/send/screens/web_prefilled_send_screen.dart';
import '../features/send/screens/web_send_screen.dart';
import '../features/smart_contracts/screens/web_create_smart_contract_screen.dart';
import '../features/smart_contracts/screens/smart_contract_wizard_screen.dart';
import '../features/smart_contracts/screens/bulk_create_screen.dart';
import '../features/smart_contracts/screens/web_smart_contract_landing_screen.dart';
import '../features/transactions/screens/web_transaction_detail_screen.dart';
import '../features/transactions/screens/web_transactions_screen.dart';
import '../features/web_shop/screens/create_web_listing_screen.dart';
import '../features/web_shop/screens/create_web_shop_container_screen.dart';
import '../features/web_shop/screens/my_web_shops_list_screen.dart';
import '../features/web_shop/screens/web_collection_detail_screen.dart';
import '../features/web_shop/screens/web_listing_detail_screen.dart';
import '../features/web_shop/screens/web_shop_detail_screen.dart';
import '../features/web_shop/screens/web_shop_landing_screen.dart';
import '../features/web_shop/screens/web_shop_list_screen.dart';
import '../features/reserve/screens/web_reserve_account_overview_screen.dart';

const List<AutoRoute> webRoutes = [
  // AutoRoute(initial: true, path: "", name: "WebAuthRoute", page: WebAuthScreen),
  // webStoreRouter,
  AutoRoute(
    initial: true,
    path: '',
    name: "WebAuthRouter",
    page: EmptyRouterPage,
    children: [
      AutoRoute(path: "", page: WebAuthScreen),
    ],
  ),
  // AutoRoute(path: "store/collection/:slug", page: StoreCollectionScreen),
  // AutoRoute(path: "reserve-account", page: WebReserveAccountOverviewScreen),
  webDashboardTabRouter,
  RedirectRoute(path: '*', redirectTo: '/'),
];

const List<AutoRoute> sharedWebRoutes = [
  AutoRoute(path: "token/create", page: WebTokenCreateScreen),
  AutoRoute(path: "token/detail/:scId", page: WebTokenDetailScreen),
  AutoRoute(path: "token/detail/new-topic/:scId/:address", page: CreateTokenTopicScreen),
  AutoRoute(path: "vbtc/create", page: TokenizeBtcScreen),
  AutoRoute(path: "vbtc/detail/:scId/:address", page: WebTokenizedBtcDetailScreen),
  AutoRoute(path: "detail/:hash", page: WebTransactionDetailScreen),
];

@AdaptiveAutoRouter(replaceInRouteName: 'Page,Route,Screen', routes: webRoutes)
class $WebRouter {}

const webDashboardTabRouter = AutoRoute(
  path: "dashboard",
  page: WebDashboardContainer,
  // initial: true,
  children: [
    AutoRoute(
      // initial: true,
      path: 'home',
      name: "WebHomeTabRouter",
      page: EmptyRouterPage,
      children: [
        AutoRoute(path: "", page: WebHomeScreen),
        // AutoRoute(
        //   path: "reserve-accounts",
        //   page: ReserveAccountOverviewScreen,
        //   name: "WebReserveAccountOverviewScreenRoute",
        // ),
        AutoRoute(path: "all-tokens", page: AllTokensScreen),
        // AutoRoute(name: "WebTokenDetailScreenFromHomeRoute", path: "fungible/detail/:scId", page: WebTokenDetailScreen),
        // AutoRoute(name: "CreateTokenTopicScreenFromHomeRoute", path: "fungible/detail/new-topic/:scId/:address", page: CreateTokenTopicScreen),
        ...sharedWebRoutes,
      ],
    ),
    AutoRoute(
      path: 'send',
      name: "WebSendTabRouter",
      page: EmptyRouterPage,
      children: [
        AutoRoute(path: "", page: WebSendScreen),
        AutoRoute(path: ":toAddress/:amount", page: WebPrefilledSendScreen),
        ...sharedWebRoutes,
      ],
    ),
    AutoRoute(
      path: 'vault-accounts',
      name: "WebReserveAccountsTabRouter",
      page: EmptyRouterPage,
      children: [
        AutoRoute(path: "", page: WebReserveAccountOverviewScreen),
        ...sharedWebRoutes,
      ],
    ),
    AutoRoute(
      path: 'receive',
      name: "WebReceiveTabRouter",
      page: EmptyRouterPage,
      children: [
        AutoRoute(path: "", page: WebReceiveScreen),
        ...sharedWebRoutes,
      ],
    ),
    AutoRoute(
      path: 'transactions',
      name: "WebTransactionsTabRouter",
      page: EmptyRouterPage,
      children: [
        AutoRoute(path: "", page: WebTransactionScreen),
        ...sharedWebRoutes,
      ],
    ),
    AutoRoute(
      path: 'nfts',
      name: "WebNftTabRouter",
      page: EmptyRouterPage,
      children: [
        AutoRoute(path: "", page: NftListScreen),
        AutoRoute(path: "detail/:id", page: NftDetailScreen),
        ...sharedWebRoutes,
      ],
    ),
    AutoRoute(
      path: 'adnrs',
      name: "WebAdnrTabRouter",
      page: EmptyRouterPage,
      children: [
        AutoRoute(path: "", page: WebAdnrScreen),
        ...sharedWebRoutes,
      ],
    ),
    AutoRoute(
      path: 'smart-contract',
      name: "WebSmartContractTabRouter",
      page: EmptyRouterPage,
      children: [
        AutoRoute(path: "", page: WebSmartContractLandingScreen),
        AutoRoute(path: "create", page: WebCreateSmartContractScreen),
        AutoRoute(path: "bulk", name: 'WebBulkCreateScreenRoute', page: BulkCreateScreen),
        AutoRoute(path: "create", name: "WebSmartContractWizardScreenRoute", page: SmartContractWizardScreen),
        // AutoRoute(path: "wizard", name: "WebBuldCreateScreen", page: BulkCreateScreen),
        ...sharedWebRoutes,
      ],
    ),
    AutoRoute(
      path: 'fungible-token',
      name: "WebTokenTabRouter",
      page: EmptyRouterPage,
      children: [
        AutoRoute(path: "", page: TokenListScreen),
        ...sharedWebRoutes,
      ],
    ),
    AutoRoute(
      path: 'vbtc',
      name: 'WebTokenizeBitcoinRouter',
      page: EmptyRouterPage,
      children: [
        AutoRoute(path: "", page: TokenizeBtcListScreen),
        ...sharedWebRoutes,
      ],
    ),
    AutoRoute(
      path: 'p2p',
      name: "WebShopTabRouter",
      page: WebShopContainerScreen,
      children: [
        AutoRoute(
          initial: true,
          path: "landing",
          page: WebShopLandingScreen,
        ),
        AutoRoute(
          path: "shops",
          page: WebShopListScreen,
        ),
        AutoRoute(
          path: "mine",
          page: MyWebShopListScreen,
        ),
        AutoRoute(
          path: "chat/:shopId",
          page: WebSellerChatThreadListScreen,
        ),
        AutoRoute(
          path: "chat/:identifier",
          page: WebShopChatScreen,
        ),
        AutoRoute(
          path: "chat/:shopId/:address",
          page: WebSellerChatScreen,
        ),
        AutoRoute(
          path: "createWebShop",
          page: CreateWebShopContainerScreen,
        ),
        AutoRoute(
          path: "shop/:shopId/collection/:collectionId/create-listing",
          page: CreateWebListingScreen,
        ),
        AutoRoute(
          path: "shop/:shopId",
          page: WebShopDetailScreen,
        ),
        AutoRoute(
          path: "shop/:shopId/collection/:collectionId",
          page: WebCollectionDetailScreen,
        ),
        AutoRoute(
          path: "shop/:shopId/collection/:collectionId/listing/:listingId",
          page: WebListingDetailScreen,
        ),
      ],
    ),
    AutoRoute(
      path: 'sign-tx',
      name: "WebSignTxTabRouter",
      page: EmptyRouterPage,
      children: [
        AutoRoute(
          path: "build-sale-start/:scId/:bidId/:ownerAddress",
          page: BuildSaleStartTxScreen,
        ),
      ],
    ),
  ],
);

// const webStoreRouter = AutoRoute(
//   path: "s",
//   page: StoreContainerScreen,
//   name: "StoreTabRouter",
//   children: [
//     AutoRoute(initial: true, path: ":slug", page: StoreListingScreen),
//   ],
// );
