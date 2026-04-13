/// Base58 alphabet (no 0, O, I, l)
const _base58Chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

/// Validates that [address] is a well-formed zfx_ shielded address.
bool isValidZfxAddress(String address) {
  if (!address.startsWith('zfx_')) return false;
  final body = address.substring(4);
  // Base58Check of 39 bytes (2 version + 33 key + 4 checksum) produces ~53 chars
  if (body.length < 40) return false;
  return body.split('').every((c) => _base58Chars.contains(c));
}
