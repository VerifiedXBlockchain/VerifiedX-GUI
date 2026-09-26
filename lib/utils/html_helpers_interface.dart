abstract class HtmlHelpersInterface {
  void redirect(String url);
  String getUrl();
  String getUserAgent();
  void triggerDownload(String url);
  void reload();
  void downloadKeysWeb(List<int> bytes);

  /// Clicks the Flutter web engine's hidden "Enable accessibility" placeholder
  /// so the engine starts emitting its semantics tree. Returns whether the
  /// placeholder was found. Always false off web.
  bool enableSemantics();
}
