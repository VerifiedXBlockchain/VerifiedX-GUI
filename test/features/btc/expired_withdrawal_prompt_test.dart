import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_wallet/app.dart';
import 'package:rbx_wallet/core/api_token_manager.dart';
import 'package:rbx_wallet/core/providers/session_provider.dart';
import 'package:rbx_wallet/core/services/base_service.dart';
import 'package:rbx_wallet/core/singletons.dart';
import 'package:rbx_wallet/core/theme/app_theme.dart';
import 'package:rbx_wallet/features/btc/components/tokenized_btc_action_buttons.dart';
import 'package:rbx_wallet/features/btc/models/tokenized_bitcoin.dart';
import 'package:rbx_wallet/features/price/providers/price_detail_providers.dart';
import 'package:rbx_wallet/features/wallet/models/wallet.dart';
import 'package:rbx_wallet/features/wallet/providers/wallet_list_provider.dart';
import 'package:rbx_wallet/l10n/generated/app_localizations.dart';

final _wallet = Wallet(id: 1, publicKey: 'pub', address: 'owner', balance: 1, isValidating: false);
final _token = TokenizedBitcoin(
  id: 1,
  smartContractUid: 'sc:1',
  rbxAddress: 'owner',
  btcAddress: 'tb1qfixture',
  tokenName: 'vBTC',
  tokenDescription: '',
  smartContractMainId: 1,
  isPublished: true,
  version: 2,
  myBalance: 0.01,
);

class _SessionStub extends SessionProvider {
  _SessionStub(Ref ref) : super(ref, SessionModel(cliStarted: true, currentWallet: _wallet));

  @override
  Future<void> init(bool inLoop) async {}
}

class _NodeFixture implements HttpClientAdapter {
  bool includeContract = true;
  String? activeHash;
  List<Map<String, dynamic>>? escrowed = [
    {
      'RequestHash': 'expired',
      'Amount': 0.001,
      'BTCDestination': 'tb1qdest',
      'Expired': true,
      'Unpayable': true,
      'CancellationPending': false,
    },
  ];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final Map<String, dynamic> body;
    if (options.path == '/GetContractList') {
      body = {
        'Success': true,
        'Contracts': [
          if (includeContract)
            {
              'SmartContractUID': 'sc:1',
              'OwnerAddress': 'owner',
              'DepositAddress': 'tb1qfixture',
              'Name': 'vBTC',
              'ActiveWithdrawalRequestHash': activeHash,
            },
        ],
      };
    } else if (options.path == '/GetVBTCBalance/owner/sc:1') {
      body = {
        'Success': true,
        'AvailableBalance': 0.01,
        if (escrowed != null) 'EscrowedWithdrawals': escrowed,
      };
    } else {
      throw StateError('Unexpected fixture request: ${options.path}');
    }
    return ResponseBody.fromString(jsonEncode(body), 200, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _NodeFixture node;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    singleton.registerSingleton<ApiTokenManager>(ApiTokenManagerImplementation());
  });

  setUp(() {
    rootNavigatorKey = GlobalKey<NavigatorState>();
    node = _NodeFixture();
    BaseService.httpClientAdapterOverride = node;
  });

  tearDown(() => BaseService.httpClientAdapterOverride = null);

  Future<void> pressWithdraw(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sessionProvider.overrideWith((ref) => _SessionStub(ref)),
        walletListProvider.overrideWith((ref) => WalletListProvider(ref, [_wallet])),
        btcCurrentPriceDataDetailProvider.overrideWith((ref) => null),
      ],
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        theme: AppTheme.dark().themeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: TokenizedBtcActionButtons(token: _token, scOwner: 'owner')),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vbtc:withdraw')));
    await tester.pumpAndSettle();
  }

  testWidgets('expired escrow is explained after Core clears the active hash, then the form opens', (tester) async {
    await pressWithdraw(tester);
    expect(find.text('Withdrawal Request Expired'), findsOneWidget);
    expect(find.textContaining('0.001 vBTC to tb1qdest'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);

    await tester.tap(find.text('Open Withdrawal Form'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('escrow is explained even when the contract is missing from the refreshed list', (tester) async {
    node.includeContract = false;
    await pressWithdraw(tester);
    expect(find.text('Withdrawal Request Expired'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('pending cancellation is explained after the active hash clears', (tester) async {
    node.escrowed!.single['CancellationPending'] = true;
    await pressWithdraw(tester);
    expect(find.textContaining('A cancellation has already been requested'), findsOneWidget);
  });

  testWidgets('older nodes without escrow data still open the form', (tester) async {
    node.escrowed = null;
    await pressWithdraw(tester);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('expired escrow does not replace the live completion prompt', (tester) async {
    node.activeHash = 'live';
    node.escrowed!.add({'RequestHash': 'live', 'Amount': 0.01});
    await pressWithdraw(tester);
    expect(find.text('Pending Withdrawal Found'), findsOneWidget);
    expect(find.text('Complete'), findsOneWidget);
    expect(find.text('Withdrawal Request Expired'), findsNothing);
  });
}
