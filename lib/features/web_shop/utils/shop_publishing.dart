import '../../../core/app_constants.dart';
import '../../keygen/models/keypair.dart';
import '../../raw/raw_service.dart';
import '../../web/utils/raw_transaction.dart';
import '../models/web_shop.dart';
import '../../../utils/toast.dart';
import '../../../l10n/l10n_helper.dart';

enum ShopPublishTxType { create, update, delete }

Future<bool> broadcastShopTx(
  Keypair keypair,
  WebShop shop,
  ShopPublishTxType type,
) async {
  late final double amount;
  switch (type) {
    case ShopPublishTxType.create:
      amount = SHOP_PUBLISH_COST;
      break;
    case ShopPublishTxType.update:
      amount = SHOP_UPDATE_COST;
      break;
    case ShopPublishTxType.delete:
      amount = SHOP_DELETE_COST;
      break;
  }

  late final String functionName;

  switch (type) {
    case ShopPublishTxType.create:
      functionName = "DecShopCreate()";
      break;
    case ShopPublishTxType.update:
      functionName = "DecShopUpdate()";
      break;
    case ShopPublishTxType.delete:
      functionName = "DecShopDelete()";
      break;
  }

  final txService = RawService();

  final timestamp = await txService.getTimestamp();

  if (timestamp == null) {
    Toast.error(globalL10n.r3bFailedRetrieveTimestamp);
    return false;
  }

  final nonce = await txService.getNonce(keypair.address);
  if (nonce == null) {
    Toast.error(globalL10n.r3bFailedRetrieveNonce);
    return false;
  }

  final payload = type == ShopPublishTxType.delete
      ? {
          "Function": functionName,
          "UniqueId": shop.uid,
        }
      : {
          "Function": functionName,
          "DecShop": shop.txPayload,
        };

  var txData = RawTransaction.buildTransaction(
    amount: amount,
    type: TxType.dstShop,
    toAddress: "DecShop_Base",
    fromAddress: keypair.address,
    timestamp: timestamp,
    nonce: nonce,
    data: payload,
  );

  final fee = await txService.getFee(txData);
  if (fee == null) {
    Toast.error(globalL10n.r3bFailedParseFee);
    return false;
  }

  txData = RawTransaction.buildTransaction(
    amount: amount,
    type: TxType.dstShop,
    toAddress: "DecShop_Base",
    fromAddress: keypair.address,
    timestamp: timestamp,
    nonce: nonce,
    data: payload,
    fee: fee,
  );

  final hash = (await txService.getHash(txData));

  if (hash == null) {
    Toast.error(globalL10n.r3bFailedParseHash);
    return false;
  }

  final signature = await RawTransaction.getSignature(
    message: hash,
    privateKey: keypair.private,
    publicKey: keypair.public,
  );

  if (signature == null) {
    Toast.error(globalL10n.svcSignatureGenerationFailed);
    return false;
  }

  final isValid = await txService.validateSignature(
    hash,
    keypair.address,
    signature,
  );

  if (!isValid) {
    Toast.error(globalL10n.svcSignatureNotValid);
    return false;
  }

  txData = RawTransaction.buildTransaction(
    amount: amount,
    type: TxType.dstShop,
    toAddress: "DecShop_Base",
    fromAddress: keypair.address,
    timestamp: timestamp,
    nonce: nonce,
    data: payload,
    fee: fee,
    hash: hash,
    signature: signature,
  );

  final verifyTransactionData = (await txService.sendTransaction(
    transactionData: txData,
    execute: false,
  ));
  if (verifyTransactionData == null) {
    Toast.error(globalL10n.r3bCouldNotVerifyTx);
    return false;
  }
  if (verifyTransactionData['Result'] != "Success") {
    Toast.error(verifyTransactionData['Message']);
    return false;
  }

  final tx = await RawService().sendTransaction(
    transactionData: txData,
    execute: true,
  );

  if (tx != null) {
    if (tx['Result'] == "Success") {
      switch (type) {
        case ShopPublishTxType.create:
          Toast.message(globalL10n.r3bShopPublishBroadcast);
          break;
        case ShopPublishTxType.update:
          Toast.message(globalL10n.r3bShopUpdateBroadcast);
          break;
        case ShopPublishTxType.delete:
          Toast.message(globalL10n.r3bShopDeleteBroadcast);
          break;
      }

      return true;
    }

    Toast.error(tx["Message"]);
    return false;
  }

  Toast.error();
  return false;
}
