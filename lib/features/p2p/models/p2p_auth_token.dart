/// A sign-in token from `POST /api/auth/sign-token/`: good for one hour, for
/// one address. Held in memory only and never printed.
class P2pAuthToken {
  final String token;
  final String address;
  final DateTime expiresAt;

  /// The email Spyglass already holds for the address, if any.
  final String? email;

  const P2pAuthToken({
    required this.token,
    required this.address,
    required this.expiresAt,
    this.email,
  });

  /// Throws a [FormatException] when the body carries no token or no expiry.
  factory P2pAuthToken.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final expiresAt = DateTime.tryParse(json['expires_at'] is String ? json['expires_at'] as String : '');
    if (token is! String || token.isEmpty || expiresAt == null) {
      throw const FormatException('A sign-in answer has no token or no expiry');
    }
    final address = json['address'];
    final email = json['email'];
    return P2pAuthToken(
      token: token,
      address: address is String ? address : '',
      expiresAt: expiresAt.toUtc(),
      email: email is String && email.isNotEmpty ? email : null,
    );
  }

  @override
  String toString() => "P2pAuthToken(address: $address, expiresAt: $expiresAt)";
}
