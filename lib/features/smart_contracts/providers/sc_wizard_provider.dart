import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rbx_wallet/features/smart_contracts/models/multi_asset.dart';
import 'package:path/path.dart';
import 'package:rbx_wallet/utils/validation.dart';

import '../../../core/providers/session_provider.dart';
import '../../../core/providers/web_session_provider.dart';
import '../../../core/services/transaction_service.dart';
import '../../../utils/toast.dart';
import '../../asset/asset.dart';
import '../../nft/providers/minted_nft_list_provider.dart';
import '../../nft/providers/nft_list_provider.dart';
import '../../nft/services/nft_service.dart';
import '../components/sc_wizard_minting_progress_dialog.dart';
import '../features/royalty/royalty.dart';
import '../models/bulk_smart_contract_entry.dart';
import '../models/smart_contract.dart';
import '../services/smart_contract_service.dart';
import 'my_smart_contracts_provider.dart';
import 'sc_wizard_minting_progress_provider.dart';

const LOG_HISTORY_LENGTH = 1000;

class ScWizardItem {
  final BulkSmartContractEntry entry;
  final int index;
  final int x;
  final int y;

  const ScWizardItem({
    required this.entry,
    this.index = 0,
    this.x = 0,
    this.y = 0,
  });

  ScWizardItem copyWith({BulkSmartContractEntry? entry, int? index, int? x, int? y}) {
    return ScWizardItem(
      entry: entry ?? this.entry,
      index: index ?? this.index,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  factory ScWizardItem.empty([int x = 0, int y = 0, int index = 0]) {
    return ScWizardItem(
      x: x,
      index: index,
      y: y,
      entry: BulkSmartContractEntry.empty(),
    );
  }
}

class ScWizardProvider extends StateNotifier<List<ScWizardItem>> {
  final Reader read;
  final ScrollController scrollController = ScrollController();

  ScWizardProvider(this.read, [List<ScWizardItem> model = const []]) : super(model);

  void insert({
    required BulkSmartContractEntry entry,
    required int index,
    required int y,
    required int x,
  }) {
    state = [
      ...state,
      ScWizardItem(
        entry: entry,
        index: index,
        y: y,
        x: x,
      )
    ];
  }

  ScWizardItem? itemAtCoords(int x, int y) {
    return state.firstWhereOrNull((item) => item.x == x && item.y == y);
  }

  ScWizardItem? itemAtIndex(int index) {
    return state[index];
  }

  void updateName(int index, String value) {
    ScWizardItem? item = itemAtIndex(index);
    if (item == null) return;
    item = item.copyWith(entry: item.entry.copyWith(name: value));

    state = [...state]
      ..removeAt(index)
      ..insert(index, item);
  }

  void updateCreatorName(int index, String value) {
    ScWizardItem? item = itemAtIndex(index);
    if (item == null) return;
    item = item.copyWith(entry: item.entry.copyWith(creatorName: value));

    state = [...state]
      ..removeAt(index)
      ..insert(index, item);
  }

  void updateDescription(int index, String value) {
    ScWizardItem? item = itemAtIndex(index);
    if (item == null) return;
    item = item.copyWith(entry: item.entry.copyWith(description: value));

    state = [...state]
      ..removeAt(index)
      ..insert(index, item);
  }

  void updateQuantity(int index, int value) {
    ScWizardItem? item = itemAtIndex(index);
    if (item == null) return;
    item = item.copyWith(entry: item.entry.copyWith(quantity: value));

    state = [...state]
      ..removeAt(index)
      ..insert(index, item);
  }

  void updatePrimaryAsset(int index, Asset? value) {
    ScWizardItem? item = itemAtIndex(index);

    if (item == null) return;

    item = item.copyWith(entry: item.entry.copyWith(primaryAsset: value));

    state = [...state]
      ..removeAt(index)
      ..insert(index, item);
  }

  void updateRoyalty(int index, Royalty? value) {
    ScWizardItem? item = itemAtIndex(index);

    if (item == null) return;

    item = item.copyWith(entry: item.entry.copyWith(royalty: value));

    state = [...state]
      ..removeAt(index)
      ..insert(index, item);
  }

  void addAdditionalAsset(int index, Asset asset) {
    ScWizardItem? item = itemAtIndex(index);

    if (item == null) return;

    item = item.copyWith(
      entry: item.entry.copyWith(
        additionalAssets: [...item.entry.additionalAssets, asset],
      ),
    );
    state = [...state]
      ..removeAt(index)
      ..insert(index, item);
  }

  void removeAdditionalAsset(int index, int assetIndex) {
    ScWizardItem? item = itemAtIndex(index);

    if (item == null) return;

    item = item.copyWith(
      entry: item.entry.copyWith(
        additionalAssets: [...item.entry.additionalAssets]..removeAt(assetIndex),
      ),
    );
    state = [...state]
      ..removeAt(index)
      ..insert(index, item);
  }

  Future<bool> uploadCsv() async {
    state = [];
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['csv'],
      allowMultiple: false,
    );
    if (result == null) {
      return false;
    }
    if (result.files.isEmpty) {
      return false;
    }

    PlatformFile file = result.files.first;
    if (file.path == null) {
      return false;
    }

    final input = File(file.path!).openRead();
    final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

    // final headers = fields.first;
    final rows = [...fields]..removeAt(0);
    final List<BulkSmartContractEntry> entries = [];
    for (final row in rows) {
      final name = row[0].toString();
      final description = row[1].toString();
      final primaryAssetUrl = row[2].toString();
      final creatorName = row[3].toString();

      final royaltyAmount = row[4].toString();
      final royaltyAddress = row[5].toString();
      final additionalAssetUrls = row[6].toString();

      final quantity = row[7];

      //TODO stats

      //TODO validation

      final primaryAsset = await urlToAsset(primaryAssetUrl, creatorName);
      if (primaryAsset == null) {
        Toast.error("Problem downloading $primaryAssetUrl. Skipping.");
        continue;
      }

      Royalty? royalty;
      if (royaltyAmount.isNotEmpty && royaltyAddress.isNotEmpty) {
        if (isValidRbxAddress(royaltyAddress)) {
          if (royaltyAmount.contains('%')) {
            final parsed = double.tryParse(royaltyAmount.replaceAll("%", ''));
            if (parsed != null) {
              royalty = Royalty(amount: parsed / 100, address: royaltyAddress, type: RoyaltyType.percent);
            }
          } else {
            final parsed = double.tryParse(royaltyAmount);
            if (parsed != null) {
              royalty = Royalty(amount: parsed, address: royaltyAddress, type: RoyaltyType.fixed);
            }
          }
        }
      }

      final List<Asset> additionalAssets = [];
      if (additionalAssetUrls.isNotEmpty) {
        final urls = additionalAssetUrls.split(",").map((e) => e.trim()).toList();

        if (urls.isNotEmpty) {
          for (final url in urls) {
            final a = await urlToAsset(url, creatorName);
            if (a != null) {
              additionalAssets.add(a);
            }
          }
        }
      }

      entries.add(
        BulkSmartContractEntry(
          name: name,
          description: description,
          primaryAsset: primaryAsset,
          creatorName: creatorName,
          quantity: quantity,
          royalty: royalty,
          additionalAssets: additionalAssets,
        ),
      );
    }

    state = entries
        .asMap()
        .entries
        .map((e) => ScWizardItem(
              entry: e.value,
              index: e.key,
              x: 0,
              y: 0,
            ))
        .toList();

    return entries.isNotEmpty;
  }

  Future<Asset?> urlToAsset(String url, String creatorName) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: {});
      final f = File(uri.toString().replaceAll("?", ""));
      final filename = basename(f.path);
      final ext = extension(f.path);

      print(filename);

      // final filename = url.split('/').last;
      // final extension = filename.split(".").last;

      final downloadDirectory = await getTemporaryDirectory();
      final path = "${downloadDirectory.path}/$filename";

      await Dio().download(url, path, onReceiveProgress: (value1, value2) {
        // print("Downloading $value1/$value2");
      });

      final fileSize = (await File(path).readAsBytes()).length;

      final asset = Asset(
        id: "00000000-0000-0000-0000-000000000000",
        name: filename,
        authorName: creatorName,
        location: path,
        extension: ext,
        fileSize: fileSize,
      );
      return asset;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> removeAt(int index, {int delay = 0}) async {
    await Future.delayed(Duration(milliseconds: delay));
    state = [...state]..removeAt(index);
  }

  void clear() {
    state = [];
  }

  Future<void> mint(BuildContext context) async {
    // TODO: Confirmation dialog

    read(scWizardMintingProgress.notifier).setPercent(0);

    showDialog(
      context: context,
      builder: (context) {
        return const ScWizardMintingProgressDialog();
      },
    );

    final totalItems = state.map((e) => e.entry.quantity).toList().sum;
    int totalProgress = 0;

    for (final item in state) {
      final entry = item.entry;
      final owner = read(sessionProvider).currentWallet;
      if (owner == null) {
        Toast.error("No wallet selected.");
        return;
      }

      final sc = SmartContract(
        owner: owner,
        name: entry.name,
        minterName: entry.creatorName,
        description: entry.description,
        primaryAsset: entry.primaryAsset,
        royalties: entry.royalty != null ? [entry.royalty!] : [],
        multiAssets: entry.additionalAssets.isNotEmpty ? [MultiAsset(assets: entry.additionalAssets)] : [],
      );

      final timezoneName = read(sessionProvider).timezoneName;
      final payload = sc.serializeForCompiler(timezoneName);
      int i = 0;
      while (i < entry.quantity) {
        i += 1;

        read(scWizardMintingProgress.notifier).setLabel("Minting ${totalProgress + 1}/$totalItems...");

        final csc = await SmartContractService().compileSmartContract(payload);

        if (csc == null) {
          Toast.error();
          print("CSC was null");
          return;
        }

        if (!csc.success) {
          Toast.error();
          print("CSC not successful");
          return;
        }
        final details = await SmartContractService().retrieve(csc.smartContract.id);
        if (details == null) {
          Toast.error();
          print("Details null");
          return;
        }
        final id = details.smartContract.id;

        final success = kIsWeb ? await TransactionService().mintSmartContract(id) : await SmartContractService().mint(id);
        if (!success) {
          Toast.error();
          print("Mint error");
          return;
        }

        NftService().saveId(id);

        await Future.delayed(const Duration(milliseconds: 1500));
        totalProgress += 1;

        final percent = totalProgress / totalItems;

        read(scWizardMintingProgress.notifier).setPercent(percent);

        // final updatedDetails = kIsWeb ? await TransactionService().retrieveSmartContract(id) : await SmartContractService().retrieve(id);

      }

      // clear();
    }
    read(scWizardMintingProgress.notifier).setPercent(1);
    read(scWizardMintingProgress.notifier).setLabel("Complete");

    read(mintedNftListProvider.notifier).reloadCurrentPage();

    read(mySmartContractsProvider.notifier).load();
    kIsWeb
        ? read(nftListProvider.notifier).reloadCurrentPage(read(webSessionProvider).keypair?.email, read(webSessionProvider).keypair?.public)
        : read(nftListProvider.notifier).reloadCurrentPage();
  }
}

final scWizardProvider = StateNotifierProvider<ScWizardProvider, List<ScWizardItem>>((ref) {
  return ScWizardProvider(ref.read);
});