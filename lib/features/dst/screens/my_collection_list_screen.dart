import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/components.dart';
import '../../wallet/providers/wallet_list_provider.dart';
import '../../../core/app_constants.dart';
import '../../../core/app_router.gr.dart';
import '../../../core/base_component.dart';
import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/centered_loader.dart';
import '../../../core/dialogs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../components/publish_shop_button.dart';
import '../components/shop_online_button.dart';
import '../components/collection_list.dart';
import '../providers/collection_form_provider.dart';
import '../providers/collection_list_provider.dart';
import '../services/dst_service.dart';
import '../../../utils/toast.dart';
import '../../../utils/validation.dart';

import '../providers/dec_shop_form_provider.dart';
import '../providers/dec_shop_provider.dart';

class MyCollectionsListScreen extends BaseScreen {
  const MyCollectionsListScreen({Key? key}) : super(key: key, verticalPadding: 0, horizontalPadding: 0);

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(AppLocalizations.of(context).dstMyAuctionHouseTitle),
      backgroundColor: Colors.black,
      actions: [
        AppButton(
          type: AppButtonType.Text,
          variant: AppColorVariant.Light,
          icon: Icons.chat_bubble_outline,
          label: AppLocalizations.of(context).r3dChat,
          onPressed: () {
            AutoRouter.of(context).push(SellerChatThreadListScreenRoute());
          },
        ),
      ],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionListProvider);

    return Column(
      children: [
        Builder(
          builder: (context) {
            final data = ref.watch(decShopProvider);

            return data.when(
              error: (_, __) => SizedBox(),
              loading: () => SizedBox(),
              data: (shop) {
                if (shop == null) {
                  return SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        shop.name,
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(4.0)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 8,
                            bottom: 8,
                          ),
                          child: AppCard(
                            padding: 0,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).r3dShopUrlLabel(shop.url),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        await Clipboard.setData(ClipboardData(text: shop.url));
                                        Toast.message(AppLocalizations.of(context).r3dShopUrlCopied);
                                      },
                                      icon: Icon(
                                        Icons.copy,
                                        size: 16,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      AppCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (shop.isPublished) ShopOnlineButton(),
                            AppButton(
                              variant: AppColorVariant.Primary,
                              label: AppLocalizations.of(context).dstEditDetails,
                              icon: Icons.edit,
                              onPressed: () {
                                ref.read(decShopFormProvider.notifier).load(shop);
                                AutoRouter.of(context).push(const CreateDecShopContainerScreenRoute());
                              },
                            ),
                            DecPublishShopButton(),
                            if (!shop.isPublished)
                              AppButton(
                                variant: AppColorVariant.Danger,
                                label: AppLocalizations.of(context).dstDeleteShop,
                                icon: Icons.delete,
                                onPressed: () async {
                                  final l10n = AppLocalizations.of(context);
                                  final confirmed = await ConfirmDialog.show(
                                    title: l10n.dstDeleteShop,
                                    body: l10n.r3dConfirmDeleteUnpublishedShop,
                                    destructive: true,
                                    confirmText: l10n.adnrDelete,
                                    cancelText: l10n.actionCancel,
                                  );

                                  if (confirmed == true) {
                                    final success = await DstService().deleteShopLocally();
                                    if (success) {
                                      for (final c in collections) {
                                        await DstService().deleteCollection(c);
                                      }

                                      await Future.delayed(Duration(seconds: 1));
                                      ref.invalidate(decShopProvider);
                                      ref.read(collectionListProvider.notifier).refresh();

                                      Toast.message(l10n.r3dShopDeleted);
                                      // Navigator.of(context).pop();
                                    }
                                  }
                                },
                              ),
                            if (shop.isPublished)
                              AppButton(
                                variant: AppColorVariant.Danger,
                                label: AppLocalizations.of(context).dstDeleteShop,
                                icon: Icons.delete,
                                onPressed: () async {
                                  final l10n = AppLocalizations.of(context);
                                  final confirmed = await ConfirmDialog.show(
                                    title: l10n.dstDeleteShop,
                                    body: l10n.r3dConfirmDeletePublishedShop(SHOP_DELETE_COST.toString()),
                                    destructive: true,
                                    confirmText: l10n.adnrDelete,
                                    cancelText: l10n.actionCancel,
                                  );

                                  if (confirmed == true) {
                                    final successRemote = await DstService().deleteShop();
                                    if (successRemote) {
                                      Toast.message(l10n.r3dDeleteTxBroadcasted);

                                      final success = await DstService().deleteShopLocally();
                                      if (success) {
                                        for (final c in collections) {
                                          await DstService().deleteCollection(c);
                                        }

                                        await Future.delayed(Duration(seconds: 1));

                                        ref.invalidate(decShopProvider);
                                        ref.read(collectionListProvider.notifier).refresh();
                                        Toast.message(l10n.r3dShopDeleted);
                                        // Navigator.of(context).pop();
                                        // ref.read(globalLoadingProvider.notifier).start();
                                        // ref.read(sessionProvider.notifier).restartCli();
                                        // ref.read(globalLoadingProvider.notifier).complete();
                                      }
                                    }
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        if (collections.isEmpty)
          Builder(builder: (context) {
            final data = ref.watch(decShopProvider);

            return data.when(
              loading: () => CenteredLoader(),
              error: (_, __) => Text(""),
              data: (shop) {
                return Expanded(
                  child: Center(
                    child: AppCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (shop == null) ...[
                            Text(
                              AppLocalizations.of(context).r3dSetupAuctionHousePrompt,
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 32,
                            )
                          ],
                          if (shop != null && shop.isPublished && collections.isEmpty) ...[
                            Text(
                              AppLocalizations.of(context).r3dCreateCollectionsPrompt,
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 32,
                            )
                          ],
                          Column(
                            children: [
                              DecShopButton(),
                              if (shop != null && shop.isPublished)
                                Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: AppButton(
                                    label: AppLocalizations.of(context).r3dCreateNewCollection,
                                    icon: Icons.add,
                                    variant: AppColorVariant.Success,
                                    onPressed: () async {
                                      ref.read(storeFormProvider.notifier).clear();
                                      AutoRouter.of(context).push(const CreateCollectionContainerScreenRoute());
                                    },
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        if (collections.isNotEmpty)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CollectionList(),
            ),
          ),
        if (collections.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DecShopButton(),
                AppButton(
                  label: AppLocalizations.of(context).r3dCreateNewCollection,
                  icon: Icons.add,
                  variant: AppColorVariant.Success,
                  onPressed: () async {
                    ref.read(storeFormProvider.notifier).clear();
                    AutoRouter.of(context).push(const CreateCollectionContainerScreenRoute());
                  },
                )
              ],
            ),
          ),
      ],
    );
  }
}

class DecShopButton extends BaseComponent {
  const DecShopButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(decShopProvider);
    final addresses = ref.watch(walletListProvider).map((e) => e.address).toList();

    return data.when(
      loading: () => SizedBox(),
      error: (_, __) => SizedBox(),
      data: (shop) {
        if (shop == null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: AppLocalizations.of(context).r3dSetupAuctionHouse,
                icon: Icons.store,
                variant: AppColorVariant.Light,
                onPressed: () async {
                  ref.read(decShopFormProvider.notifier).clear();
                  AutoRouter.of(context).push(const CreateDecShopContainerScreenRoute());
                },
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                AppLocalizations.of(context).r3dOr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
              AppButton(
                label: AppLocalizations.of(context).dstImportShop,
                onPressed: () async {
                  final l10n = AppLocalizations.of(context);
                  final address = await PromptModal.show(
                    title: l10n.dstImportShop,
                    validator: formValidatorRbxAddress,
                    labelText: l10n.dstImportShopAddressLabel,
                  );

                  if (address != null) {
                    if (!addresses.contains(address)) {
                      Toast.error(AppLocalizations.of(context).r3dNotOneOfYourAddresses);
                      return;
                    }
                    final success = await DstService().importShop(address);
                    if (success == true) {
                      ref.invalidate(decShopProvider);
                      Toast.message(AppLocalizations.of(context).r3dShopImported);
                    } else {
                      Toast.error();
                    }
                  }
                },
                variant: AppColorVariant.Light,
                type: AppButtonType.Text,
              )
            ],
          );
        }

        return AppButton(
          label: AppLocalizations.of(context).r3dEditAuctionHouse,
          icon: Icons.store,
          variant: AppColorVariant.Light,
          onPressed: () async {
            ref.read(decShopFormProvider.notifier).load(shop);
            AutoRouter.of(context).push(const CreateDecShopContainerScreenRoute());
          },
        );
      },
    );
  }
}
