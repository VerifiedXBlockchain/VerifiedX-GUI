import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rbx_wallet/core/breakpoints.dart';
import '../../../core/base_component.dart';
import '../../../core/components/buttons.dart';
import '../../../core/dialogs.dart';
import '../../../core/providers/cached_memory_image_provider.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/services/explorer_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../asset/asset.dart';
import '../../global_loader/global_loading_provider.dart';
import '../../wallet/components/wallet_selector.dart';
import '../../../utils/files.dart';
import '../../../utils/toast.dart';

import '../constants.dart';
import '../providers/token_form_provider.dart';

class TokenForm extends BaseComponent {
  const TokenForm({super.key});

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final provider = ref.read(tokenFormProvider.notifier);
    final model = ref.watch(tokenFormProvider);
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Form(
        key: provider.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!kIsWeb)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.r3hTokenOwnerLabel),
                  WalletSelector(
                    includeRbx: true,
                    includeBtc: false,
                    includeRa: false,
                    withOptions: false,
                    truncatedLabel: false,
                    headerHasCopy: false,
                  ),
                ],
              ),
            TextFormField(
              controller: provider.nameController,
              validator: provider.nameValidator,
              decoration: InputDecoration(
                label: Text(
                  l10n.r3hTokenNameFieldLabel,
                  style: TextStyle(color: Colors.white),
                ),
                hintText: AppLocalizations.of(context).tokenFormNameHint,
                helperText: l10n.r3hTokenNameHelper,
              ),
            ),
            TextFormField(
              controller: provider.tickerController,
              validator: provider.tickerValidator,
              decoration: InputDecoration(
                label: Text(
                  l10n.r3hTokenTickerFieldLabel,
                  style: TextStyle(color: Colors.white),
                ),
                hintText: AppLocalizations.of(context).tokenFormTickerHint,
                helperText: l10n.r3hTokenTickerHelper,
              ),
              inputFormatters: [UpperCaseTextFormatter(), FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))],
              textCapitalization: TextCapitalization.characters,
              maxLength: TOKEN_TICKER_MAX_LENGTH,
            ),
            TextFormField(
              controller: provider.descriptionController,
              decoration: InputDecoration(
                label: Text(
                  l10n.r3hDescriptionOptionalLabel,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              minLines: 3,
              maxLines: 6,
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                provider.setMintable(!model.mintable);
                provider.supplyController.text = '0';
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Checkbox(
                        value: !model.mintable,
                        onChanged: (val) {
                          if (val != null) {
                            provider.setMintable(!val);
                            provider.supplyController.text = '0';
                          }
                        }),
                  ),
                  Text(
                    l10n.r3hTokenHasFixedSupply,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!model.mintable)
              TextFormField(
                controller: provider.supplyController,
                validator: provider.supplyValidator,
                decoration: InputDecoration(
                  label: Text(
                    l10n.r3hTotalSupplyLabel,
                    style: TextStyle(color: Colors.white),
                  ),
                  hintText: "0",
                  helperText: l10n.r3hUseZeroForInfinite,
                ),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Flex(
                direction: BreakPoints.useMobileLayout(context) ? Axis.vertical : Axis.horizontal,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.r3hDecimalPlacesLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_drop_down),
                        onPressed: model.decimalPlaces <= TOKEN_MIN_DECIMAL_PLACES
                            ? null
                            : () {
                                provider.setDecimalPlaces(model.decimalPlaces - 1);
                              },
                      ),
                      SizedBox(
                        width: 28,
                        child: Center(
                          child: Text(
                            model.decimalPlaces.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_drop_up),
                        onPressed: model.decimalPlaces >= TOKEN_MAX_DECIMAL_PLACES
                            ? null
                            : () {
                                provider.setDecimalPlaces(model.decimalPlaces + 1);
                              },
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Row(
                    children: [
                      Text(
                        l10n.r3hIsBurnableLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Checkbox(
                        value: model.burnable,
                        onChanged: (val) {
                          if (val != null) {
                            provider.setBurnable(val);
                          }
                        },
                      ),
                      SizedBox(width: 16),
                      Text(
                        l10n.r3hAllowVotingLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Checkbox(
                        value: model.voting,
                        onChanged: (val) {
                          if (val != null) {
                            provider.setVoting(val);
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            Row(
              children: [
                if (model.imageBase64 != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: Image(
                        image: CacheMemoryImageProvider(
                          model.imageBase64!,
                          Base64Decoder().convert(model.imageBase64!),
                        ),
                        width: 64,
                        height: 64,
                      ),
                    ),
                  ),
                AppButton(
                  label: model.imageBase64 == null ? l10n.r3hUploadTokenIcon : l10n.r3hReplaceTokenIcon,
                  onPressed: () async {
                    FilePickerResult? result;

                    if (kIsWeb) {
                      result = await FilePicker.platform.pickFiles(allowedExtensions: ['jpg', 'jpeg', 'gif', 'png', 'webp'], type: FileType.custom);
                      await Future.delayed(Duration(milliseconds: 10));
                      ref.read(globalLoadingProvider.notifier).start();
                      if (result == null || result.files.isEmpty) {
                        ref.read(globalLoadingProvider.notifier).complete();

                        return;
                      }
                      final bytes = result.files.single.bytes;
                      if (bytes == null) {
                        ref.read(globalLoadingProvider.notifier).complete();

                        return;
                      }

                      final base64 = resizeImageAndBase64FromBytes(bytes, 64);
                      if (base64 != null) {
                        provider.setImageBase64(base64);

                        final ext = result.files.single.extension;
                        final filename = result.files.single.name;

                        final url = await ExplorerService().uploadAsset(bytes, filename, ext);

                        final asset = Asset(
                          id: '00000000-0000-0000-0000-000000000000',
                          location: url,
                          extension: ext,
                          fileSize: result.files.single.bytes!.length,
                          bytes: bytes,
                          name: filename,
                        );

                        provider.setWebAsset(asset);
                      } else {
                        Toast.error();
                      }
                      ref.read(globalLoadingProvider.notifier).complete();
                    } else {
                      final Directory currentDir = Directory.current;
                      result = await FilePicker.platform.pickFiles();
                      Directory.current = currentDir;
                      if (result == null || result.files.isEmpty || result.files.first.path == null) {
                        return;
                      }
                      final base64 = resizeImageAndBase64(result.files.first.path!, 64);
                      if (base64 != null) {
                        provider.setImageBase64(base64);
                      } else {
                        Toast.error();
                      }
                    }
                  },
                  icon: Icons.image,
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: TextFormField(
                    controller: provider.imageUrlController,
                    decoration: InputDecoration(
                      label: Text(
                        l10n.r3hTokenIconUrlLabel,
                        style: TextStyle(color: Colors.white),
                      ),
                      hintText: "https://domain.com/image.jpg",
                      helperText: l10n.r3hOptional,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            Builder(builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                AppButton(
                  label: l10n.tokenFormCancel,
                  variant: AppColorVariant.Danger,
                  onPressed: () {
                    provider.clear();
                    AutoRouter.of(context).pop();
                  },
                ),
                SizedBox(
                  width: 64,
                ),
                AppButton(
                  label: l10n.tokenFormCreate,
                  onPressed: () async {
                    if (kIsWeb) {
                      final keypair = ref.read(webSessionProvider.select((value) => value.keypair));
                      if (keypair == null) {
                        Toast.error(l10n.tokenFormNoAccountSelectedToast);
                        return;
                      }
                    } else {
                      final currentWallet = ref.read(sessionProvider).currentWallet;

                      if (currentWallet == null) {
                        Toast.error(l10n.tokenFormNoAccountSelectedToast);
                        return null;
                      }
                    }

                    if (model.imageBase64 == null) {
                      Toast.error(l10n.tokenFormIconRequiredToast);
                      return;
                    }

                    if (!provider.formKey.currentState!.validate()) {
                      return;
                    }

                    final confirmed = await ConfirmDialog.show(
                      title: l10n.tokenFormCompileMintTitle,
                      body: l10n.r3hCompileMintBody,
                      confirmText: l10n.actionContinue,
                      cancelText: l10n.actionCancel,
                    );

                    if (confirmed != true) {
                      return;
                    }

                    final extraConfirm = await ConfirmDialog.show(
                      title: l10n.tokenFormConfirmAddressTitle,
                      body: l10n.r3hMintedByBody(kIsWeb ? ref.read(webSessionProvider.select((value) => value.keypair))!.address : ref.read(sessionProvider).currentWallet!.labelWithoutTruncation),
                      confirmText: l10n.btcCompileMint,
                      cancelText: l10n.actionCancel,
                    );

                    if (extraConfirm != true) {
                      return;
                    }

                    final success = await provider.submit();

                    if (success == true) {
                      await InfoDialog.show(
                        title: l10n.tokenFormStandByTitle,
                        body: l10n.r3hMintBroadcastedBody,
                      );

                      provider.clear();

                      AutoRouter.of(context).pop();
                    }
                  },
                )
              ],
            );
            })
          ],
        ),
      ),
    );
  }
}
