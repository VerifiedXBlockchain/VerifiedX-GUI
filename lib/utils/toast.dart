import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

import '../app.dart';
import '../core/dialogs.dart';
import '../core/theme/app_theme.dart';
import '../l10n/l10n_helper.dart';
import 'html_helpers.dart';

class Toast {
  static message(String message, [bool surpress = false]) {
    if (surpress) {
      print(message);
      return;
    }

    final l10n = globalL10n;
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: kIsWeb && HtmlHelpers().getUserAgent().contains('OS 15_') ? '-apple-system' : null,
        ),
      ),
      backgroundColor: AppColors.getSpringGreen(),
      action: SnackBarAction(
        label: l10n.tkbDismiss,
        textColor: Colors.white70,
        onPressed: () {},
      ),
    );
    rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  static error([String? message, bool surpress = false]) {
    final l10n = globalL10n;
    message ??= l10n.r3hProblemOccurred;
    if (surpress) {
      print(message);
      return;
    }

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontFamily: kIsWeb && HtmlHelpers().getUserAgent().contains('OS 15_') ? '-apple-system' : null,
        ),
      ),
      backgroundColor: Color(0xFFBA2121),
      action: SnackBarAction(
        label: l10n.tkbDismiss,
        textColor: Colors.white70,
        onPressed: () {},
      ),
    );
    rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}

class OverlayToast {
  static message({required String message, String? title}) {
    InfoDialog.show(title: title ?? globalL10n.statusSuccess, body: message);
  }

  static error([String? message]) {
    InfoDialog.show(title: globalL10n.btcWebError, body: message ?? globalL10n.txpErrorOccurred);

    // final context = rootNavigatorKey.currentContext!;
    // showTopSnackBar(
    //   context,
    //   CustomSnackBar.error(
    //     message: message ?? "An error occurred",
    //   ),
    // );
  }
}
