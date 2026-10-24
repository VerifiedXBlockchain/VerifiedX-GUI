/// A BTC name receiver's signed agreement to a transfer, carried from the
/// receiver to the sender as one copyable "acceptance code":
/// `<message>|<signature>`.
///
/// The message is `<unix seconds>:<new VFX owner>:<name>.btc` and the
/// signature is the receiving BTC address's signature of it. The message holds
/// no `|`, so the code splits at the first one.
class BtcNameAcceptance {
  static const separator = "|";

  final String message;
  final String signature;
  final int timestamp;
  final String owner;
  final String name;

  const BtcNameAcceptance._({
    required this.message,
    required this.signature,
    required this.timestamp,
    required this.owner,
    required this.name,
  });

  /// The message binding a BTC name action to its VFX [owner] and [name]:
  /// `<timestamp>:<owner>:<name>.btc`, the name lowercased with `.btc` added
  /// when missing.
  static String boundMessage(int timestamp, String owner, String name) {
    return "$timestamp:${owner.trim()}:${normalizeName(name)}";
  }

  /// [name] lowercased and trimmed, ending in `.btc` exactly once.
  static String normalizeName(String name) {
    final lower = name.trim().toLowerCase();
    return lower.endsWith(".btc") ? lower : "$lower.btc";
  }

  /// The acceptance code the receiver hands to the sender.
  static String build(String message, String signature) {
    return "$message$separator$signature";
  }

  /// The acceptance in [code], or null when it is not a well-formed code.
  static BtcNameAcceptance? parse(String? code) {
    if (code == null) return null;
    final trimmed = code.trim();
    final index = trimmed.indexOf(separator);
    if (index <= 0) return null;

    final message = trimmed.substring(0, index).trim();
    final signature = trimmed.substring(index + 1).trim();
    if (signature.isEmpty || signature.contains(separator) || !signature.contains(".")) {
      return null;
    }

    final parts = message.split(":");
    if (parts.length != 3) return null;

    final timestamp = int.tryParse(parts[0]);
    final owner = parts[1];
    final name = parts[2];
    if (timestamp == null || timestamp <= 0 || owner.isEmpty || name.isEmpty) {
      return null;
    }
    // Core compares the signed name with the stored full name, "alice.btc",
    // ignoring case (BtcNameSignatures.Check): a code signed for "alice" is
    // refused, so it is not accepted here either.
    if (!name.toLowerCase().endsWith(".btc") || name.length <= ".btc".length) {
      return null;
    }

    return BtcNameAcceptance._(
      message: message,
      signature: signature,
      timestamp: timestamp,
      owner: owner,
      name: name,
    );
  }

  /// Whether this acceptance names [owner] as the new VFX owner of [name].
  /// The address must match exactly; the name is compared case-insensitively
  /// with `.btc` optional on either side.
  bool matches({required String owner, required String name}) {
    return this.owner == owner.trim() && normalizeName(this.name) == normalizeName(name);
  }
}
