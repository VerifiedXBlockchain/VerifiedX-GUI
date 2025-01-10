import 'package:rbx_wallet/features/btc_web/models/btc_web_account.dart';
import 'package:rbx_wallet/features/keygen/models/keypair.dart';
import 'package:rbx_wallet/features/keygen/models/ra_keypair.dart';

class MultiAccountInstance {
  final int id;
  final Keypair? keypair;
  final RaKeypair? raKeypair;
  final BtcWebAccount? btcKeypair;
  final String? name;

  const MultiAccountInstance({
    required this.id,
    required this.keypair,
    required this.raKeypair,
    required this.btcKeypair,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keypair': keypair?.toJson(),
      'raKeypair': raKeypair?.toJson(),
      'btcKeypair': btcKeypair?.toJson(),
      'name': name,
    };
  }

  factory MultiAccountInstance.fromJson(Map<String, dynamic> json) {
    return MultiAccountInstance(
      id: json['id'] ?? 0,
      keypair: json['keypair'] != null ? Keypair.fromJson(json['keypair']) : null,
      raKeypair: json['raKeypair'] != null ? RaKeypair.fromJson(json['raKeypair']) : null,
      btcKeypair: json['btcKeypair'] != null ? BtcWebAccount.fromJson(json['btcKeypair']) : null,
      name: json['name'],
    );
  }

  MultiAccountInstance rename(String newName) {
    return MultiAccountInstance(
      id: id,
      keypair: keypair,
      raKeypair: raKeypair,
      btcKeypair: btcKeypair,
      name: newName,
    );
  }
}
