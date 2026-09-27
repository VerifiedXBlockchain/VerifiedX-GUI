// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'html_helpers_interface.dart';

class HtmlHelpersImplementation extends HtmlHelpersInterface {
  @override
  void redirect(String url) {
    html.window.location.href = url;
  }

  @override
  String getUrl() {
    return html.window.location.href;
  }

  @override
  String getUserAgent() {
    return html.window.navigator.userAgent;
  }

  @override
  void triggerDownload(String url) {
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.target = "_blank";
    anchorElement.click();
  }

  @override
  void downloadKeysWeb(List<int> bytes) {
    final _base64 = base64Encode(bytes);
    final anchor = html.AnchorElement(href: 'data:application/octet-stream;base64,$_base64')..target = 'blank';
    final date = DateTime.now();
    final d = "${date.year}-${date.month}-${date.day}";
    final name = "vfx-keys-backup-$d.txt";

    anchor.download = name;

    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
  }

  @override
  void reload() {
    html.window.location.reload();
  }

  @override
  bool enableSemantics() {
    final glassPane = html.document.querySelector('flt-glass-pane');
    if (glassPane == null) {
      return false;
    }
    // The engine keeps the placeholder in the glass pane's shadow root, or in
    // a child flt-element-host-node when the automation shim in index.html
    // forced the light-DOM path.
    final shadowRoot = glassPane.shadowRoot;
    final placeholder = shadowRoot != null
        ? shadowRoot.querySelector('flt-semantics-placeholder')
        : glassPane.querySelector('flt-semantics-placeholder');
    if (placeholder == null) {
      return false;
    }
    // The engine's MobileSemanticsEnabler (mobile user agents) only accepts a
    // click whose element-relative offset is within 1px of the placeholder's
    // viewport midpoint, so it compares offset against an absolute point; aim
    // clientX/Y at rect.left + midX to satisfy it. DesktopSemanticsEnabler
    // (Chrome on macOS, the automation flow) accepts any click targeted at the
    // placeholder, so the same event works there too.
    final rect = placeholder.getBoundingClientRect();
    final midX = rect.left + rect.width / 2;
    final midY = rect.top + rect.height / 2;
    placeholder.dispatchEvent(html.MouseEvent(
      'click',
      clientX: (rect.left + midX).round(),
      clientY: (rect.top + midY).round(),
    ));
    return true;
  }

  @override
  Future<bool> loadScript(String src) async {
    // Deferred <script> tags run before DOMContentLoaded. Waiting for it keeps
    // a script that builds on one of them (btc-*.js needs btc.js's window.btc)
    // from running first when main.dart.js was injected during parsing.
    if (html.document.readyState == 'loading') {
      await html.window.onContentLoaded.first;
    }
    final loaded = Completer<bool>();
    final script = html.ScriptElement()
      ..type = 'application/javascript'
      ..src = src;
    script.onLoad.first.then((_) {
      if (!loaded.isCompleted) loaded.complete(true);
    });
    script.onError.first.then((_) {
      if (!loaded.isCompleted) loaded.complete(false);
    });
    html.document.body!.append(script);
    return loaded.future;
  }
}
