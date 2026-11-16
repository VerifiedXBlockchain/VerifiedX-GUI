import 'package:freezed_annotation/freezed_annotation.dart';

part 'p2p_tx_description.freezed.dart';
part 'p2p_tx_description.g.dart';

/// A shop transaction as the registry describes it: the unsigned description
/// a wallet posted as a dry run, or the one the block indexer made from a
/// real transaction (then with [hash] and [height]). [data] uses Core's field
/// names. Nothing in it is a signature over the transaction, and a listing's
/// `sale.start` always shows `data.BidSignature` as null.
@freezed
class P2pTxDescription with _$P2pTxDescription {
  const P2pTxDescription._();

  factory P2pTxDescription({
    // Core's TransactionType: 5 NFT_SALE, 7 DSTR.
    required int type,
    required String function,
    @JsonKey(name: 'from_address') required String fromAddress,
    @JsonKey(name: 'to_address') required String toAddress,
    String? amount,
    String? fee,
    // Unix seconds.
    int? timestamp,
    @Default(<String, dynamic>{}) Map<String, dynamic> data,
    String? hash,
    int? height,
  }) = _P2pTxDescription;

  factory P2pTxDescription.fromJson(Map<String, dynamic> json) => _$P2pTxDescriptionFromJson(json);

  DateTime? get at => timestamp == null ? null : DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000, isUtc: true);
}
