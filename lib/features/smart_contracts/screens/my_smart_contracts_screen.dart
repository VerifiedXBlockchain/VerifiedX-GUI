import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_router.gr.dart';
import '../../../core/base_component.dart';
import '../../../core/base_screen.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/toast.dart';
import '../../wallet/models/wallet.dart';
import '../models/smart_contract.dart';
import '../providers/create_smart_contract_provider.dart';
import '../providers/draft_smart_contracts_provider.dart';
import '../providers/my_smart_contracts_provider.dart';
import '../services/smart_contract_service.dart';

class MySmartContractsScreen extends BaseScreen {
  const MySmartContractsScreen({Key? key}) : super(key: key);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(AppLocalizations.of(context).scMyTitle),
      leading: IconButton(
        onPressed: () async {
          AutoRouter.of(context).pop();
        },
        icon: const Icon(Icons.close),
      ),
      actions: [
        IconButton(
            onPressed: () {
              ref.read(mySmartContractsProvider.notifier).load();
              ref.read(draftsSmartContractProvider.notifier).load();
            },
            icon: const Icon(Icons.refresh))
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            tabs: [
              Tab(
                child: Text(AppLocalizations.of(context).scTabCompiled),
              ),
              Tab(
                child: Text(AppLocalizations.of(context).scTabDrafts),
              ),
            ],
          ),
          Expanded(
              child: TabBarView(
            children: const [
              _CompiledList(),
              _DraftList(),
            ],
          ))
        ],
      ),
    );
  }
}

class _DraftList extends BaseComponent {
  const _DraftList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _model = ref.watch(draftsSmartContractProvider);

    if (_model.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).scNoDrafts),
      );
    }
    return ListView.builder(
      itemCount: _model.length,
      itemBuilder: (context, index) {
        final sc = _model[index];
        return ListTile(
          leading: const Icon(Icons.document_scanner_sharp),
          title: Text(sc.name),
          subtitle: Text(
            sc.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            ref.read(createSmartContractProvider.notifier).setSmartContract(sc);

            AutoRouter.of(context).push(const SmartContractCreatorContainerScreenRoute());
          },
        );
      },
    );
  }
}

class _CompiledList extends BaseComponent {
  const _CompiledList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _model = ref.watch(mySmartContractsProvider);

    if (_model.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).scNoCompiled),
      );
    }
    return ListView.builder(
      itemCount: _model.length,
      itemBuilder: (context, index) {
        final sc = _model[index];
        return ListTile(
          leading: const Icon(Icons.document_scanner_sharp),
          title: Text(sc.name),
          subtitle: Text(sc.id),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final details = await SmartContractService().retrieve(sc.id);
            if (details == null) {
              Toast.error();
              return;
            }
            final wallet = kIsWeb
                ? Wallet.fromWebWallet(
                    keypair: ref.read(webSessionProvider).keypair!,
                    balance: ref.read(webSessionProvider).balance ?? 0,
                  )
                : ref.read(sessionProvider).currentWallet!;

            final smartContract = SmartContract.fromCompiled(details, wallet);
            ref.read(createSmartContractProvider.notifier).setSmartContract(smartContract);
            AutoRouter.of(context).push(const SmartContractCreatorContainerScreenRoute());
          },
        );
      },
    );
  }
}
