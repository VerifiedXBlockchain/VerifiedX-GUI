import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../nft/services/nft_service.dart';
import '../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../../core/dialogs.dart';
import '../../l10n/generated/app_localizations.dart';
import '../reserve/services/reserve_account_service.dart';
import '../../utils/toast.dart';

import '../../core/components/buttons.dart';
import '../nft/providers/minted_nft_list_provider.dart';
import '../nft/providers/nft_detail_provider.dart';
import '../smart_contracts/services/smart_contract_service.dart';
import 'asset.dart';

class DownloadOrAssociate extends StatefulWidget {
  final Asset asset;
  final String nftId;
  final Function() onComplete;
  final String ownerAddress;
  final bool allowBeaconRequest;
  const DownloadOrAssociate({
    Key? key,
    required this.asset,
    required this.nftId,
    required this.onComplete,
    required this.ownerAddress,
    required this.allowBeaconRequest,
  }) : super(key: key);

  @override
  State<DownloadOrAssociate> createState() => _DownloadOrAssociateState();
}

class _DownloadOrAssociateState extends State<DownloadOrAssociate> {
  bool visible = false;

  @override
  void initState() {
    super.initState();

    checkAvailable();
  }

  Future<void> checkAvailable() async {
    final syncPath = widget.asset.localPath;
    if (syncPath != null) {
      final exists = await File(syncPath).exists();

      setState(() {
        visible = !exists;
      });
    } else {
      if (syncPath != null) {
        FileImage(File(syncPath)).evict;
      }
      setState(() {
        visible = true;
      });
    }
  }

  void chooseLocalFiles(WidgetRef ref) async {
    FilePickerResult? result;
    if (!kIsWeb) {
      final Directory currentDir = Directory.current;
      result = await FilePicker.platform.pickFiles();
      Directory.current = currentDir;
    } else {
      result = await FilePicker.platform.pickFiles();
    }
    if (result == null) {
      return;
    }

    final location = result.files.single.path;

    if (location == null) {
      return;
    }

    final success = await SmartContractService().associateAsset(
      widget.nftId,
      location,
    );

    if (success == true) {
      await checkAvailable();
      ref.refresh(nftDetailProvider(widget.nftId));
      ref.refresh(mintedNftListProvider);
      widget.onComplete();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!visible) {
      return const SizedBox();
    }

    return Consumer(builder: (context, ref, _) {
      if (widget.ownerAddress.startsWith("xRBX")) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              l10n.tkbVaultAuthorizeDownload,
              style: TextStyle(color: Colors.deepPurple.shade200),
            ),
            const SizedBox(
              height: 6,
            ),
            AppButton(
              label: l10n.tkbAuthorizeNow,
              onPressed: () async {
                final password = await PromptModal.show(
                  title: l10n.tkbVaultAccountPassword,
                  validator: (_) => null,
                  labelText: l10n.tkbPassword,
                  lines: 1,
                  obscureText: true,
                  revealObscure: true,
                );
                if (password == null) {
                  return;
                }
                await ReserveAccountService().downloadAssets(widget.nftId, widget.ownerAddress, password);
              },
            )
          ]),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.tkbMediaNotFound(widget.asset.fileName)),
            Text(l10n.tkbCheckOtherAccount),
            const SizedBox(
              height: 12,
            ),
            AppButton(
              label: widget.allowBeaconRequest ? l10n.tkbCallMedia : l10n.tkbAssociateMedia,
              onPressed: () async {
                if (widget.allowBeaconRequest) {
                  showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.black87,
                      builder: (context) {
                        return ModalContainer(
                          color: Colors.black,
                          withDecor: false,
                          withClose: true,
                          children: [
                            ListTile(
                              leading: Icon(Icons.wifi_tethering_outlined),
                              title: Text(l10n.tkbCallMediaFromBeacon),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () async {
                                final success = await NftService().requestMediaFromBeacon(widget.nftId);
                                if (success == true) {
                                  widget.onComplete();

                                  InfoDialog.show(
                                      contextOverride: context,
                                      title: l10n.tkbCallToBeaconStartedTitle,
                                      body: l10n.tkbCallToBeaconStartedBody);

                                  Toast.message(l10n.tkbCallToBeaconStartedToast);
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.file_upload),
                              title: Text(l10n.tkbAssociateLocalFile),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () async {
                                chooseLocalFiles(ref);
                              },
                            ),
                          ],
                        );
                      });
                } else {
                  chooseLocalFiles(ref);
                }
              },
            ),
          ],
        ),
      );
    });
  }
}
