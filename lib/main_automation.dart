import 'package:flutter_driver/driver_extension.dart';

import 'core/automation/driver_label_finder.dart';
import 'main.dart' as app;

/// Entrypoint for the Flutter Driver flavor (`make run_macos_driver`): the
/// production app with the driver extension compiled in, so `tool/drive.dart`
/// can tap, type, wait and read text through the VM service. Production
/// `lib/main.dart` never imports the extension.
///
/// Text entry emulation stays on (the default) because `drive.dart type`
/// relies on it. The emulation intercepts the text input channel, so the
/// physical keyboard cannot type into fields in this flavor.
void main(List<String> args) {
  enableFlutterDriverExtension(finders: [ByLabelFinderExtension()]);
  app.main(args);
}
