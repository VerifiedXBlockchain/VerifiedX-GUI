
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_component.dart';
import '../../../generated/assets.gen.dart';
import '../../../l10n/l10n_helper.dart';
import '../../../utils/toast.dart';
import '../providers/sc_wizard_log_provider.dart';
import '../providers/sc_wizard_log_visible_provider.dart';
import '../../global_loader/global_loading_provider.dart';

import '../../../core/base_screen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../wallet/components/wallet_selector.dart';
import '../providers/sc_wizard_provider.dart';
import 'smart_contract_wizard_screen.dart';

/// Saves one of the example metadata files bundled under assets/docs.
/// Web downloads it through the browser, macOS shows a save dialog, and
/// Windows/Linux write it to the Downloads folder.
Future<void> _saveBundledExample(String assetPath, {required String ext, required MimeType mimeType}) async {
  try {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    const name = "nft-metadata-example";

    if (kIsWeb) {
      await FileSaver.instance.saveFile(name: name, bytes: bytes, ext: ext, mimeType: mimeType);
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      await FileSaver.instance.saveAs(name: name, bytes: bytes, ext: ext, mimeType: mimeType);
      return;
    }

    final savedPath = await FileSaver.instance.saveFile(name: name, bytes: bytes, ext: ext, mimeType: mimeType);
    Toast.message(globalL10n.r3eSavedTo(savedPath));
  } catch (e) {
    print("Failed to save example file $assetPath: $e");
    Toast.error(globalL10n.scwDownloadExampleFailed);
  }
}

class BulkCreateScreen extends BaseScreen {
  const BulkCreateScreen({Key? key})
      : super(
          key: key,
          verticalPadding: 0,
          horizontalPadding: 0,
        );

  @override
  AppBar? appBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(AppLocalizations.of(context).scwMintNftCollectionTitle),
      backgroundColor: Colors.black12,
      shadowColor: Colors.transparent,
      actions: const [WalletSelector()],
    );
  }

  @override
  Widget body(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.scwMintNftCollectionTitle,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(16),
              //   child: Center(
              //     child: ConstrainedBox(
              //       constraints: const BoxConstraints(maxWidth: 500),
              //       child: const Text(
              //         "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nihil enim hoc differt. Duo Reges: constructio interrete. Primum in nostrane potestate est, quid meminerimus? Quaerimus enim finem bonorum. Iam enim adesse poterit. Age sane, inquam.",
              //         textAlign: TextAlign.center,
              //       ),
              //     ),
              //   ),
              // ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.black,
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.white54,
                          blurRadius: 4,
                          // spreadRadius: 4,
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.75),
                      child: Column(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                l10n.scwCollectionWizard,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(16),
                          //   child: Center(
                          //     child: ConstrainedBox(
                          //       constraints: const BoxConstraints(maxWidth: 500),
                          //       child: const Text(
                          //         "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nihil enim hoc differt. Duo Reges: constructio interrete. Primum in nostrane potestate est, quid meminerimus?",
                          //         textAlign: TextAlign.center,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: AppButton(
                              label: l10n.scwLaunchWizard,
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SmartContractWizardScreen()),
                                );
                              },
                              variant: AppColorVariant.Success,
                              icon: Icons.auto_awesome,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.black,
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.white54,
                          blurRadius: 4,
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.75),
                      child: Column(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                l10n.scwUploadJsonCsv,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 500),
                                child: Text(
                                  l10n.scwUploadJsonCsvBody,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "JSON",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppButton(
                                      label: l10n.scwDownloadExampleJson,
                                      onPressed: () {
                                        _saveBundledExample(
                                          Assets.docs.nftMetadataExampleJson,
                                          ext: "json",
                                          mimeType: MimeType.json,
                                        );
                                      },
                                      variant: AppColorVariant.Light,
                                      icon: Icons.download,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: AppButton(
                                        label: l10n.scwUploadJson,
                                        variant: AppColorVariant.Success,
                                        icon: Icons.upload,
                                        onPressed: () async {
                                          if (kIsWeb) {
                                            ref
                                                .read(globalLoadingProvider
                                                    .notifier)
                                                .start();
                                          } else {
                                            ref
                                                .read(scWizardLogVisibleProvider
                                                    .notifier)
                                                .start();
                                          }

                                          final shouldPush = await ref
                                              .read(scWizardProvider.notifier)
                                              .uploadJson();
                                          if (kIsWeb) {
                                            ref
                                                .read(globalLoadingProvider
                                                    .notifier)
                                                .complete();
                                          } else {
                                            ref
                                                .read(scWizardLogVisibleProvider
                                                    .notifier)
                                                .complete();
                                          }

                                          if (shouldPush == true) {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SmartContractWizardScreen()),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "CSV",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppButton(
                                      label: l10n.scwDownloadExampleCsv,
                                      onPressed: () {
                                        _saveBundledExample(
                                          Assets.docs.nftMetadataExampleCsv,
                                          ext: "csv",
                                          mimeType: MimeType.csv,
                                        );
                                      },
                                      variant: AppColorVariant.Light,
                                      icon: Icons.download,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: AppButton(
                                        label: l10n.scwUploadCsv,
                                        variant: AppColorVariant.Success,
                                        icon: Icons.upload,
                                        onPressed: () async {
                                          if (kIsWeb) {
                                            ref
                                                .read(globalLoadingProvider
                                                    .notifier)
                                                .start();
                                          } else {
                                            ref
                                                .read(scWizardLogVisibleProvider
                                                    .notifier)
                                                .start();
                                          }

                                          final shouldPush = await ref
                                              .read(scWizardProvider.notifier)
                                              .uploadCsv();

                                          if (kIsWeb) {
                                            ref
                                                .read(globalLoadingProvider
                                                    .notifier)
                                                .complete();
                                          } else {
                                            ref
                                                .read(scWizardLogVisibleProvider
                                                    .notifier)
                                                .complete();
                                          }
                                          if (shouldPush == true) {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SmartContractWizardScreen()),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (ref.watch(scWizardLogVisibleProvider)) ...[ScWizardLogWindow()]
      ],
    );

    // return Column(
    //   children: [
    //     Expanded(
    //       child: Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: ListView.builder(
    //             itemCount: items.length,
    //             itemBuilder: (context, index) {
    //               final entry = items[index].entry;

    //               return BulkSmartContractEntryListTile(entry: entry);
    //             }),
    //       ),
    //     ),
    //     Container(
    //       color: Colors.black54,
    //       child: Padding(
    //         padding: const EdgeInsets.all(16.0),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           children: [
    //             AppButton(
    //               label: "Clear",
    //               variant: AppColorVariant.Danger,
    //               onPressed: () {
    //                 ref.read(scWizardProvider.notifier).clear();
    //               },
    //             ),
    //             AppButton(
    //               label: "Replace CSV",
    //               variant: AppColorVariant.Primary,
    //               onPressed: () {
    //                 ref.read(scWizardProvider.notifier).uploadCsv();
    //               },
    //             ),
    //             AppButton(
    //               label: "Compile & Mint",
    //               variant: AppColorVariant.Success,
    //               onPressed: () {
    //                 ref.read(scWizardProvider.notifier).mint();
    //               },
    //             )
    //           ],
    //         ),
    //       ),
    //     )
    //   ],
    // );
  }
}

class ScWizardLogWindow extends BaseComponent {
  const ScWizardLogWindow({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(builder: (context) {
      final logs = ref.watch(scWizardLogProvider);

      return Container(
        color: Colors.black38,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).scwImporting,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Container(
                width: 400,
                height: 300,
                decoration:
                    BoxDecoration(color: Colors.black87, boxShadow: glowingBox),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    controller:
                        ref.read(scWizardLogProvider.notifier).scrollController,
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Container(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(log),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
