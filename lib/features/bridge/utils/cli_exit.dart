/// Polls [stillAnswering] until the CLI stops responding or [maxWait]
/// elapses. Returns true once the CLI is gone, false on timeout.
///
/// The CLI's SendExit handler sleeps two seconds, waits for any in-flight
/// trie update, and only then records a clean shutdown. Quitting the GUI
/// before that point flags the next launch as an improper shutdown, which
/// triggers a full state rebuild that zeros every balance while it replays.
Future<bool> waitUntilCliStops(
  Future<bool> Function() stillAnswering, {
  Duration maxWait = const Duration(seconds: 15),
  Duration interval = const Duration(milliseconds: 500),
}) async {
  final deadline = DateTime.now().add(maxWait);
  while (DateTime.now().isBefore(deadline)) {
    await Future.delayed(interval);
    if (!await stillAnswering()) {
      return true;
    }
  }
  return false;
}
