import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_window_close/flutter_window_close.dart';

import '../app.dart';
import '../core/providers/currency_segmented_button_provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../features/bridge/services/bridge_service.dart';
import '../features/global_loader/global_loading_provider.dart';
import '../features/payment/components/payment_disclaimer.dart';
import '../features/price/providers/price_detail_providers.dart';
import '../features/wallet/providers/wallet_list_provider.dart';
import '../features/web/providers/multi_account_provider.dart';
import '../utils/toast.dart';
import '../utils/validation.dart';
import 'breakpoints.dart';
import 'theme/app_theme.dart';
import 'theme/components.dart';
import 'utils.dart';

class InfoDialog {
  static alert(
    BuildContext context, {
    required String title,
    String? body,
    Widget? content,
    String? closeText,
    IconData? icon,
    Color? headerColor = Colors.white,
    Color? buttonColorOverride,
    bool withBackArrow = false,
  }) {
    return AlertDialog(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withBackArrow)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.navigate_before),
            ),
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                icon,
                color: headerColor,
              ),
            ),
          Text(
            title,
            style: TextStyle(
              color: headerColor,
            ),
          ),
        ],
      ),
      content: body != null
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(body),
            )
          : content,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.info,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(
            closeText ?? AppLocalizations.of(context).dialogClose,
            style: TextStyle(
              color: buttonColorOverride ??
                  Theme.of(context).colorScheme.secondary,
            ),
          ),
        )
      ],
    );
  }

  static show({
    required String title,
    String? body,
    Widget? content,
    String? closeText,
    IconData? icon,
    Color? headerColor = Colors.white,
    BuildContext? contextOverride,
    Color? buttonColorOverride,
    bool withBackArrow = false,
  }) async {
    final context = rootNavigatorKey.currentContext!;

    return await showDialog(
      context: contextOverride ?? context,
      builder: (context) {
        return alert(context,
            title: title,
            body: body,
            content: content,
            closeText: closeText,
            icon: icon,
            headerColor: headerColor,
            buttonColorOverride: buttonColorOverride,
            withBackArrow: withBackArrow);
      },
    );
  }
}

class ConfirmDialog {
  static alert(
    BuildContext context, {
    required String title,
    Widget? content,
    String? body,
    String? cancelText,
    String? confirmText,
    bool destructive = false,
  }) {
    return AlertDialog(
      title: Text(title),
      content: body != null
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Text(body))
          : content,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.info,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            cancelText ?? AppLocalizations.of(context).dialogNo,
            style: TextStyle(color: Theme.of(context).colorScheme.info),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            primary: destructive
                ? Colors.red.shade600
                : Theme.of(context).colorScheme.info,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(
            confirmText ?? AppLocalizations.of(context).dialogYes,
            style: TextStyle(
              color: destructive ? Colors.red.shade600 : Colors.white,
            ),
          ),
        )
      ],
    );
  }

  static Future<bool?> show({
    required String title,
    Widget? content,
    String? body,
    String? cancelText,
    String? confirmText,
    bool destructive = false,
    BuildContext? context,
  }) async {
    return await showDialog(
      context: context ?? rootNavigatorKey.currentContext!,
      builder: (context) {
        return alert(
          context,
          title: title,
          content: content,
          body: body,
          cancelText: cancelText,
          confirmText: confirmText,
          destructive: destructive,
        );
      },
    );
  }
}

class RecoverDialog {
  static alert(BuildContext context, {required String hash}) {
    return Consumer(builder: (context, ref, child) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context).r3eRecoveryStartedTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SelectableText(
            AppLocalizations.of(context).r3eRecoveryBody(hash),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.info,
              ),
            ),
            onPressed: () async {
              final success = await backupMedia(context, ref);
              if (success == true) {
                // Navigator.of(context).pop();
                if (Platform.isMacOS) {
                  Toast.message(AppLocalizations.of(context).r3eMediaBackedUp);
                }
              } else {
                Toast.error();
              }
            },
            child: Text(
              AppLocalizations.of(context).r3eExportNftMedia,
              style: TextStyle(color: Theme.of(context).colorScheme.info),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              await BridgeService().killCli();
              ref.read(globalLoadingProvider.notifier).start();
              await Future.delayed(const Duration(milliseconds: 3000));
              ref.read(globalLoadingProvider.notifier).complete();
              FlutterWindowClose.closeWindow();
            },
            child: Text(
              AppLocalizations.of(context).r3eCloseWallet,
              style: TextStyle(
                color: Colors.red.shade600,
              ),
            ),
          )
        ],
      );
    });
  }

  static Future<bool?> show({
    required String hash,
    BuildContext? context,
  }) async {
    return await showDialog(
      context: context ?? rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) {
        return alert(
          context,
          hash: hash,
        );
      },
    );
  }
}

class PromptModal {
  static Future<String?> show({
    required String title,
    required String? Function(String?) validator,
    required String labelText,
    BuildContext? contextOverride,
    String? body,
    String? footer,
    bool obscureText = false,
    bool revealObscure = false,
    String? cancelText,
    String? confirmText,
    String initialValue = "",
    bool destructive = false,
    bool allowCancel = true,
    int? lines,
    bool tightPadding = false,
    TextInputType? keyboardType,
    Function(String)? onValidSubmission,
    List<TextInputFormatter> inputFormatters = const [],
    bool popOnValidSubmission = true,
    Widget? titleTrailing,
    String? prefixText,
    Color? labelColor,
    Widget? sufixIcon,
    TextEditingController? controller,
    bool showUsdValue = false,
    CurrencyType currencyType = CurrencyType.vfx,
  }) async {
    // final context = rootNavigatorKey.currentContext!;
    final context = contextOverride ?? rootNavigatorKey.currentContext!;

    final GlobalKey<FormState> _formKey = GlobalKey();

    final TextEditingController _controller =
        controller ?? TextEditingController(text: initialValue);

    bool _obscureText = obscureText;
    double _usdValue = 0.0;
    bool _listenerAdded = false;

    void _calculateUsdValue(WidgetRef ref) {
      if (!showUsdValue) return;

      final parsedAmount = double.tryParse(_controller.value.text);
      if (parsedAmount == null || parsedAmount <= 0) {
        _usdValue = 0.0;
        return;
      }

      double? usdPrice;

      // Determine currency type and get appropriate price
      if (currencyType == CurrencyType.btc) {
        usdPrice = ref.read(btcCurrentPriceDataDetailProvider);
      } else if (currencyType == CurrencyType.vfx) {
        usdPrice = ref.read(vfxCurrentPriceDataDetailProvider);
      }

      if (usdPrice != null) {
        _usdValue = parsedAmount * usdPrice;
      } else {
        _usdValue = 0.0;
      }
    }

    void _submit(BuildContext context) {
      if (!_formKey.currentState!.validate()) return;

      final value = _controller.value.text;

      if (onValidSubmission != null) {
        if (popOnValidSubmission) {
          Navigator.of(context).pop();
        }
        onValidSubmission(value);
        return;
      } else {
        Navigator.of(context).pop(value);
      }
    }

    return await showDialog(
      context: context,
      barrierDismissible: allowCancel,
      builder: (context) {
        return AlertDialog(
          title: titleTrailing != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    titleTrailing
                  ],
                )
              : Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
          titlePadding: tightPadding
              ? const EdgeInsets.all(12.0)
              : const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 20),
          contentPadding: tightPadding
              ? const EdgeInsets.all(12.0)
              : const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          insetPadding: tightPadding
              ? const EdgeInsets.all(8.0)
              : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, minWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (body != null) Text(body),
                  StatefulBuilder(builder: (context, setState) {
                    return Consumer(
                      builder: (context, ref, child) {
                        if (!_listenerAdded) {
                          _listenerAdded = true;
                          _controller.addListener(() {
                            setState(() {
                              _calculateUsdValue(ref);
                            });
                          });
                        }

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _controller,
                                obscureText: _obscureText,
                                autofocus: true,
                                minLines: lines,
                                maxLines: lines,
                                keyboardType: keyboardType,
                                decoration: InputDecoration(
                                  suffix: sufixIcon,
                                  label: Text(
                                    labelText,
                                    style: TextStyle(
                                        color: labelColor ??
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                  ),
                                  prefixText: prefixText,
                                  helperText: showUsdValue && _usdValue > 0
                                      ? "\$${_usdValue.toStringAsFixed(2)} USD"
                                      : null,
                                ),
                                validator: validator,
                                inputFormatters: inputFormatters,
                                onFieldSubmitted: (_) {
                                  _submit(context);
                                },
                              ),
                            ),
                            if (obscureText && revealObscure)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                icon: Icon(
                                  _obscureText
                                      ? Icons.remove_red_eye
                                      : Icons.hide_source_outlined,
                                ),
                              )
                          ],
                        );
                      },
                    );
                  }),
                  if (footer != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        footer,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            if (allowCancel)
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.info,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  cancelText ?? AppLocalizations.of(context).actionCancel,
                  style: TextStyle(color: Theme.of(context).colorScheme.info),
                ),
              ),
            TextButton(
              style: TextButton.styleFrom(
                primary: destructive
                    ? Colors.red.shade600
                    : Theme.of(context).colorScheme.info,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _submit(context);
              },
              child: Text(confirmText ?? AppLocalizations.of(context).dialogSubmit,
                  style: TextStyle(color: Theme.of(context).colorScheme.info)),
            )
          ],
        );
      },
    );
  }
}

class AuthModalResponse {
  final String email;
  final String password;

  const AuthModalResponse(this.email, this.password);
}

class AuthModal {
  static Future<void> show({
    bool forCreate = true,
    bool withExplanation = false,
    required BuildContext context,
    required Function(AuthModalResponse) onValidSubmission,
  }) async {
    // final context = rootNavigatorKey.currentContext!;

    final GlobalKey<FormState> _formKey = GlobalKey();

    final TextEditingController _emailController =
        TextEditingController(text: '');

    final TextEditingController _passwordController =
        TextEditingController(text: '');

    final TextEditingController _confirmPasswordController =
        TextEditingController(text: '');

    Future<void> submit(BuildContext context) async {
      if (!_formKey.currentState!.validate()) return;

      if (forCreate &&
          _passwordController.text != _confirmPasswordController.text) {
        Toast.error(AppLocalizations.of(context).prvPasswordsDoNotMatch);
        return;
      }

      onValidSubmission(
        AuthModalResponse(_emailController.text, _passwordController.text),
      );

      Navigator.of(context).pop();
    }

    bool obscuringPassword = true;

    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(
              forCreate
                  ? AppLocalizations.of(context).r3eCreateAccount
                  : AppLocalizations.of(context).r3eLogin,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
          titlePadding: const EdgeInsets.all(18.0),
          contentPadding: const EdgeInsets.all(18.0),
          insetPadding: const EdgeInsets.all(8.0),
          // backgroundColor: const Color(0xFF040f26),
          content: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (withExplanation)
                      Text(AppLocalizations.of(context)
                          .r3eAccountRequiredExplanation),
                    Text(
                      AppLocalizations.of(context).r3eEmailPasswordSeedInfo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)
                            .keygenEmailAddressTitle,
                      ),
                      validator: formValidatorEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    StatefulBuilder(builder: (context, setState) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: obscuringPassword,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).tkbPassword,
                              ),
                              validator: formValidatorPassword,
                              keyboardType: TextInputType.emailAddress,
                              onFieldSubmitted: (_) {
                                if (!forCreate) {
                                  submit(context);
                                }
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                obscuringPassword = !obscuringPassword;
                              });
                            },
                            icon: Icon(
                              obscuringPassword
                                  ? Icons.remove_red_eye
                                  : Icons.hide_source_outlined,
                            ),
                          )
                        ],
                      );
                    }),
                    if (forCreate)
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).txpConfirmPassword,
                        ),
                        validator: formValidatorPassword,
                        keyboardType: TextInputType.emailAddress,
                        onFieldSubmitted: (_) {
                          submit(context);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.info,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context).actionCancel,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.info.withOpacity(0.7)),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.info,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                submit(context);
              },
              child: Text(AppLocalizations.of(context).r3eLogin,
                  style: TextStyle(color: Theme.of(context).colorScheme.info)),
            )
          ],
        );
      },
    );
  }
}

class PaymentTermsDialog {
  static Future<bool?> show(
      BuildContext context, PaymentGateway paymentGateway) async {
    return await showDialog(
      context: context,
      builder: (context) {
        bool hasAgreed = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).r3eDisclaimer),
              content: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PaymentDisclaimer(paymentGateway: paymentGateway),
                    SizedBox(height: 8),
                    CheckboxListTile(
                      value: hasAgreed,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            hasAgreed = val;
                          });
                        }
                      },
                      title: Text(AppLocalizations.of(context).r3eAgreeDisclaimer),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      checkColor: Colors.white,
                      activeColor: Theme.of(context).colorScheme.primary,
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context).actionCancel,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: hasAgreed
                      ? () {
                          Navigator.of(context).pop(true);
                        }
                      : () {
                          Toast.error(AppLocalizations.of(context)
                              .r3eMustAgreeTerms);
                        },
                  child: Text(
                    AppLocalizations.of(context).actionConfirm,
                    style: TextStyle(
                        color: hasAgreed ? Colors.white : Colors.white54),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}

class SelectAddressDialog {
  static Future<String?> show(BuildContext context, WidgetRef ref) async {
    List<Map<String, dynamic>> wallets;
    if (kIsWeb) {
      wallets = [
        ...ref
            .read(multiAccountProvider)
            .map((e) => {'address': e.keypair?.address ?? '', 'vault': false})
            .toList(),
        ...ref
            .read(multiAccountProvider)
            .map((e) => {'address': e.raKeypair?.address ?? '', 'vault': true})
            .toList()
      ];
    } else {
      wallets = ref
          .read(walletListProvider)
          .map((e) => {'address': e.address, 'vault': e.isReserved})
          .toList();
    }

    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).sendChooseAddressTitle),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(
                AppLocalizations.of(context).actionCancel,
                style: TextStyle(color: Colors.white60),
              ),
            )
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: wallets
                .map(
                  (w) => TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(w['address']);
                    },
                    child: Text(
                      w['address'],
                      style: TextStyle(
                          color: !w['vault']
                              ? Colors.white
                              : Theme.of(context).colorScheme.reserve,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class SpecialDialog<T> {
  Future<T?> show(
    BuildContext context, {
    required Widget content,
    bool dissmissible = true,
    double maxWidth = 500.0,
    String? title,
  }) async {
    return await showGeneralDialog(
      context: context,
      barrierColor: Colors.black45,
      pageBuilder: (context, anim1, anim2) {
        return content;
      },
      barrierDismissible: dissmissible,
      transitionDuration: Duration(milliseconds: 200),
      barrierLabel: '',
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: IntrinsicHeight(
                  child: AppCard(
                    padding: 0,
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  title,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            if (title == null && dissmissible)
                              SizedBox(height: 18 + 8 + 8),
                            Container(color: Colors.black12, child: widget),
                          ],
                        ),
                        if (dissmissible)
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: IconButton(
                                icon: Icon(Icons.close),
                                iconSize: 14,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ButterflyOptionsDialog {
  static Future<String?> show({BuildContext? context}) async {
    return await showDialog<String>(
      context: context ?? rootNavigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).r3eLaunchButterfly),
              IconButton(
                onPressed: () => Navigator.of(context).pop(null),
                icon: const Icon(Icons.close, size: 20),
                color: Colors.white38,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(BreakPoints.useMobileLayout(context)
                ? AppLocalizations.of(context).r3eButterflyDescMobile
                : AppLocalizations.of(context).r3eButterflyDescDesktop),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop("visit"),
              child: Text(
                AppLocalizations.of(context).r3eJustTakeMeThere,
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop("login"),
              child: Text(
                AppLocalizations.of(context).r3eLoginWithThisAccount,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
