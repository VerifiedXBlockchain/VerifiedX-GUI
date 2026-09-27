/// [name] with the domain [suffix] (e.g. `.vfx`, `.btc`) exactly once.
///
/// Stored domain names usually already carry their suffix
/// (`qa20260927aw1.vfx`), but not every source guarantees it, so the suffix
/// is added only when missing. Case-insensitive, so `NAME.VFX` stays as is.
String domainWithSuffix(String name, String suffix) {
  final trimmed = name.trim();
  if (trimmed.toLowerCase().endsWith(suffix.toLowerCase())) {
    return trimmed;
  }
  return "$trimmed$suffix";
}
