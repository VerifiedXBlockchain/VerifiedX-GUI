abstract class HtmlHelpersInterface {
  void redirect(String url);
  String getUrl();
  String getUserAgent();
  void triggerDownload(String url);
  void reload();
  void downloadKeysWeb(List<int> bytes);
}
