import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/buyer_chat_thread_list.dart';
import '../providers/buyer_chat_thread_list_provider.dart';

import '../../../core/base_screen.dart';
import '../../../l10n/generated/app_localizations.dart';

class BuyerChatThreadListScreen extends BaseScreen {
  const BuyerChatThreadListScreen({Key? key}) : super(key: key);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(l10n.chatTitle),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: () {
            ref.read(buyerChatThreadListProvider.notifier).fetch();
          },
          icon: Icon(Icons.refresh),
        )
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _ThreadPoller(
          pollFunction: () {
            ref.read(buyerChatThreadListProvider.notifier).fetch();
          },
        ),
        Expanded(child: BuyerChatThreadList()),
      ],
    );
  }
}

class _ThreadPoller extends StatefulWidget {
  final Function pollFunction;
  const _ThreadPoller({required this.pollFunction});

  @override
  State<_ThreadPoller> createState() => __ThreadPollerState();
}

class __ThreadPollerState extends State<_ThreadPoller> {
  late final Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      widget.pollFunction();
    });
    super.initState();
    widget.pollFunction();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
