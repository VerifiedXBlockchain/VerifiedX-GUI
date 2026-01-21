import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'butterfly_link.freezed.dart';
part 'butterfly_link.g.dart';

enum ButterflyLinkStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('ready_for_redemption')
  readyForRedemption,
  @JsonValue('claiming')
  claiming,
  @JsonValue('claimed')
  claimed,
}

enum ButterflyIcon {
  @JsonValue('default')
  defaultIcon,
  @JsonValue('gift')
  gift,
  @JsonValue('money')
  money,
  @JsonValue('heart')
  heart,
  @JsonValue('party')
  party,
  @JsonValue('rocket')
  rocket,
  @JsonValue('star')
  star,
}

@freezed
class ButterflyLink with _$ButterflyLink {
  const ButterflyLink._();

  const factory ButterflyLink({
    @JsonKey(name: 'link_id') required String linkId,
    @JsonKey(name: 'short_url') required String shortUrl,
    @JsonKey(name: 'full_url') required String fullUrl,
    @JsonKey(name: 'escrow_address') required String escrowAddress,
    required double amount,
    @JsonKey(name: 'claim_amount') required double claimAmount,
    required String message,
    required ButterflyIcon icon,
    required ButterflyLinkStatus status,
    @JsonKey(name: 'sender_address') required String senderAddress,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'tx_hash') String? txHash,
    @JsonKey(name: 'claimed_at') DateTime? claimedAt,
  }) = _ButterflyLink;

  factory ButterflyLink.fromJson(Map<String, dynamic> json) =>
      _$ButterflyLinkFromJson(json);

  String get displayAmount => '${claimAmount.toStringAsFixed(2)} VFX';

  String get statusLabel {
    switch (status) {
      case ButterflyLinkStatus.pending:
        return 'Pending Deposit';
      case ButterflyLinkStatus.readyForRedemption:
        return 'Ready to Claim';
      case ButterflyLinkStatus.claiming:
        return 'Being Claimed';
      case ButterflyLinkStatus.claimed:
        return 'Claimed';
    }
  }

  Color get statusColor {
    switch (status) {
      case ButterflyLinkStatus.pending:
        return Colors.orange;
      case ButterflyLinkStatus.readyForRedemption:
        return Colors.green;
      case ButterflyLinkStatus.claiming:
        return Colors.blue;
      case ButterflyLinkStatus.claimed:
        return Colors.grey;
    }
  }

  IconData get iconData {
    switch (icon) {
      case ButterflyIcon.defaultIcon:
        return Icons.link;
      case ButterflyIcon.gift:
        return Icons.card_giftcard;
      case ButterflyIcon.money:
        return Icons.attach_money;
      case ButterflyIcon.heart:
        return Icons.favorite;
      case ButterflyIcon.party:
        return Icons.celebration;
      case ButterflyIcon.rocket:
        return Icons.rocket_launch;
      case ButterflyIcon.star:
        return Icons.star;
    }
  }
}
