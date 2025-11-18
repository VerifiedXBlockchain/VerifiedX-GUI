import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rbx_wallet/core/theme/components.dart';
import '../btc_web/models/btc_web_account.dart';
import '../btc_web/services/btc_web_service.dart';
import '../keygen/models/ra_keypair.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/password_prompt_service.dart';
import '../../core/singletons.dart';
import '../../core/storage.dart';
import 'package:rbx_wallet/features/keygen/services/keygen_service.dart'
    if (dart.library.io) 'package:rbx_wallet/features/keygen/services/keygen_service_mock.dart';
import 'package:rbx_wallet/features/web_shop/providers/web_auth_token_provider.dart';
import 'package:rbx_wallet/features/web_shop/services/web_shop_service.dart';
import 'package:rbx_wallet/utils/guards.dart';
import 'package:rbx_wallet/utils/toast.dart';
import 'package:rbx_wallet/utils/validation.dart';

import '../../core/breakpoints.dart';
import '../../core/components/buttons.dart';
import '../../core/dialogs.dart';
import '../../core/providers/web_session_provider.dart';
import '../../core/web_router.gr.dart';
import '../global_loader/global_loading_provider.dart';
import '../keygen/models/keypair.dart';
import '../smart_contracts/components/sc_creator/common/modal_container.dart';
import '../web/models/multi_account_instance.dart';
import '../../core/services/multi_account_encryption_service.dart';
import 'package:collection/collection.dart';
import 'components/auth_type_modal.dart';

enum KeypairType { vfx, ra, btc }

Future<void> login(
  BuildContext context,
  WidgetRef ref,
  Keypair keypair,
  RaKeypair? raKeypair,
  BtcWebAccount? btcKeypair,
) async {
  ref.read(webSessionProvider.notifier).login(keypair, raKeypair, btcKeypair);
}

Future<void> loginWithEncryption(
  BuildContext context,
  WidgetRef ref,
  Keypair keypair,
  RaKeypair? raKeypair,
  BtcWebAccount? btcKeypair,
  String password,
) async {
  final sessionProvider = ref.read(webSessionProvider.notifier);
  sessionProvider.encryptAndSaveKeys(keypair, raKeypair, btcKeypair, password);

  sessionProvider.login(keypair, raKeypair, btcKeypair,
      andSave: false, encryptionPassword: password);
}

Future<void> handleImportWithPrivateKey(
  BuildContext context,
  WidgetRef ref, {
  bool showRememberMe = true,
}) async {
  final privateKey = await PromptModal.show(
    contextOverride: context,
    tightPadding: true,
    title: "Import Wallet",
    validator: (String? value) =>
        formValidatorNotEmpty(value, "VFX Private Key"),
    labelText: "VFX Private Key",
  );

  if (privateKey != null) {
    // Auto-enable Remember Me since keys will be encrypted

    // Collect encryption password
    final encryptionPassword = await PasswordPromptService.promptNewPassword(
      context,
      title: "Set Encryption Password",
      customMessage: "This password will encrypt your imported private key.",
    );

    if (encryptionPassword == null) return; // User cancelled

    final keypair = await KeygenService.importPrivateKey(privateKey);

    RaKeypair? reserveKeyPair;
    int append = 0;
    while (true) {
      String input = keypair.private;
      if (input.startsWith("00")) {
        input = input.substring(2);
      }
      String seed = "${input.substring(0, 32)}$append";

      final kp = await KeygenService.seedToKeypair(seed);
      if (kp == null) {
        continue;
      }

      reserveKeyPair =
          await KeygenService.importReserveAccountPrivateKey(kp.private);

      if (reserveKeyPair.address.startsWith("xRBX")) {
        break;
      }

      append += 1;
    }

    final btcGeneratedEmail =
        btcGeneratedEmailFromPrivateKey(keypair.privateCorrected);
    final btcGeneratedPassword =
        btcGeneratedPasswordFromPrivateKey(keypair.privateCorrected);

    final btcKeypair = await BtcWebService()
        .keypairFromEmailPassword(btcGeneratedEmail, btcGeneratedPassword);

    await loginWithEncryption(
        context, ref, keypair, reserveKeyPair, btcKeypair, encryptionPassword);
  }
}

String btcGeneratedEmailFromPrivateKey(String privateKey) {
  if (privateKey.startsWith("00")) {
    privateKey = privateKey.replaceFirst("00", "");
  }
  return "${privateKey.substring(0, 8)}@${privateKey.substring(privateKey.length - 8)}.com";
}

String btcGeneratedPasswordFromPrivateKey(String privateKey) {
  if (privateKey.startsWith("00")) {
    privateKey = privateKey.replaceFirst("00", "");
  }
  return "${privateKey.substring(0, 12)}${privateKey.substring(privateKey.length - 12)}";
}

Future<void> handleImportWithBtcPrivateKey(
  BuildContext context,
  WidgetRef ref, {
  bool showRememberMe = true,
}) async {
  await InfoDialog.show(
    title: "Warning",
    body:
        "Although if you login with a BTC Private key, if this key was generated originally with a different login mechanism, your VFX/Vault account keypairs will not match with your previous login since private keys are not reversable.",
    closeText: "Okay",
  );

  final BtcPrivateKeyImportModalResult? result = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return BtcPrivateKeyImportModal();
      });

  if (result == null) return;

  final privateKey = result.privateKey;
  final addressType = result.addressType;

  // Auto-enable Remember Me since keys will be encrypted

  // Collect encryption password
  final encryptionPassword = await PasswordPromptService.promptNewPassword(
    context,
    title: "Set Encryption Password",
    customMessage: "This password will encrypt your imported BTC private key.",
  );

  if (encryptionPassword == null) return; // User cancelled

  late final BtcWebAccount? btcKeypair;

  if (privateKey.length == 64) {
    //Private Key
    btcKeypair =
        await BtcWebService().keypairFromPrivateKey(privateKey, addressType);
  } else if (privateKey.length == 52) {
    //WIF
    btcKeypair = await BtcWebService().keypairFromWif(privateKey, addressType);
  } else {
    Toast.error(
        "Not a valid Private Key or WIF Key. Should be 64 or 52 characters");
    return;
  }

  final firstSixteen = privateKey.substring(0, 16);
  final lastSixteen = privateKey.substring(privateKey.length - 16);

  final seed = "$firstSixteen$lastSixteen";

  final keypair = await KeygenService.seedToKeypair(seed);

  if (keypair == null) {
    Toast.error("Could not generate keypair");
    return;
  }

  RaKeypair? reserveKeyPair;

  int append = 0;

  while (true) {
    String input = keypair.private;
    if (input.startsWith("00")) {
      input = input.substring(2);
    }
    String raSeed = "${input.substring(0, 32)}$append";

    final kp = await KeygenService.seedToKeypair(raSeed);
    if (kp == null) {
      continue;
    }

    reserveKeyPair =
        await KeygenService.importReserveAccountPrivateKey(kp.private);

    if (reserveKeyPair.address.startsWith("xRBX")) {
      break;
    }

    append += 1;
  }

  await loginWithEncryption(
      context, ref, keypair, reserveKeyPair, btcKeypair, encryptionPassword);
}

class BtcPrivateKeyImportModalResult {
  final String privateKey;
  final String addressType;

  BtcPrivateKeyImportModalResult({
    required this.privateKey,
    required this.addressType,
  });
}

enum WebBtcAddressType {
  p2pkh("p2pkh", "P2PKH (Legacy)"),
  p2sh("p2sh", "P2SH (Nested SegWit)"),
  bech32("bech32", "Bech32 (Native SegWit - P2WPKH)"),
  bech32m("bech32m", "Bech32m (Taproot - P2TR)"),
  ;

  final String value;
  final String label;

  const WebBtcAddressType(this.value, this.label);
}

class BtcPrivateKeyImportModal extends StatefulWidget {
  const BtcPrivateKeyImportModal({
    super.key,
  });

  @override
  State<BtcPrivateKeyImportModal> createState() =>
      _BtcPrivateKeyImportModalState();
}

class _BtcPrivateKeyImportModalState extends State<BtcPrivateKeyImportModal> {
  final TextEditingController _privateKeyController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  WebBtcAddressType? _selectedAddressType = WebBtcAddressType.bech32;

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      title: "Import BTC Private Key or WIF Key",
      children: [
        const Text('Enter your BTC Private Key or WIF Key:'),
        TextField(
          controller: _privateKeyController,
          decoration: const InputDecoration(
            hintText: 'Enter your private key',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Select your address type:'),
        DropdownButtonFormField<WebBtcAddressType?>(
          value: _selectedAddressType,
          items: [
            ...WebBtcAddressType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.label),
              );
            }).toList(),
            DropdownMenuItem(
              value: null,
              child: Text("I don't know"),
            )
          ],
          onChanged: (value) {
            setState(() {
              _selectedAddressType = value;
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        if (_selectedAddressType == null) ...[
          const SizedBox(height: 20),
          const Text('Paste your BTC address:'),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              hintText: 'Enter your BTC address',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppButton(
              label: "Cancel",
              variant: AppColorVariant.Light,
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            AppButton(
              label: "Import",
              variant: AppColorVariant.Btc,
              onPressed: () {
                if (_selectedAddressType == null) {
                  final address = _addressController.text;
                  if (address.startsWith("1")) {
                    _selectedAddressType = WebBtcAddressType.p2pkh;
                  } else if (address.startsWith('3')) {
                    _selectedAddressType = WebBtcAddressType.p2sh;
                  } else if (address.startsWith('bc1q')) {
                    _selectedAddressType = WebBtcAddressType.bech32;
                  } else if (address.startsWith('bc1p')) {
                    _selectedAddressType = WebBtcAddressType.bech32m;
                  } else {
                    Toast.error("Invalid BTC Address");
                    Navigator.of(context).pop(null);
                    return;
                  }
                }
                final result = BtcPrivateKeyImportModalResult(
                  addressType: _selectedAddressType!.value,
                  privateKey: _privateKeyController.text,
                );
                Navigator.of(context).pop(result);
              },
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> handleCreateWithEmail(
  BuildContext context,
  WidgetRef ref,
  String emailValue,
  String passwordValue, {
  bool forCreate = true,
}) async {
  String email = emailValue.toLowerCase();
  String password = passwordValue;

  String seed = "$email|$password|";
  seed = "$seed${seed.length}|!@${((password.length * 7) + email.length) * 7}";

  final regChars = RegExp(r'/[a-z]+/g');
  final regUpperChars = RegExp(r'/[A-Z]+/g');
  final regNumbers = RegExp(r'/[0-9]+/g');

  final chars =
      regChars.hasMatch(password) ? regChars.allMatches(password).length : 1;
  final upperChars = regUpperChars.hasMatch(password)
      ? regUpperChars.allMatches(password).length
      : 1;
  final upperNumbers = regNumbers.hasMatch(password)
      ? regNumbers.allMatches(password).length
      : 1;

  // var append = 3571;
  seed = "$seed${(chars + upperChars + upperNumbers) * password.length}3571";

  // seed = "${seedPriorToSha}3571";
  seed = "$seed$seed";

  for (int i = 0; i <= 50; i++) {
    seed = sha256.convert(utf8.encode(seed)).toString();
  }

  final keypair = await KeygenService.seedToKeypair(seed);
  if (keypair == null) {
    ref.read(globalLoadingProvider.notifier).complete();
    Toast.error();
    return;
  }

  // Generate Reserve

  RaKeypair? reserveKeyPair;

  int append = 0;

  while (true) {
    String input = keypair.private;
    if (input.startsWith("00")) {
      input = input.substring(2);
    }
    String raSeed = "${input.substring(0, 32)}$append";

    final kp = await KeygenService.seedToKeypair(raSeed);
    if (kp == null) {
      continue;
    }

    reserveKeyPair =
        await KeygenService.importReserveAccountPrivateKey(kp.private);

    if (reserveKeyPair.address.startsWith("xRBX")) {
      break;
    }

    append += 1;
  }

  // BTC

  final btcGeneratedEmail =
      btcGeneratedEmailFromPrivateKey(keypair.privateCorrected);
  final btcGeneratedPassword =
      btcGeneratedPasswordFromPrivateKey(keypair.privateCorrected);

  final btcKeypair = await BtcWebService()
      .keypairFromEmailPassword(btcGeneratedEmail, btcGeneratedPassword);

  // if (forCreate) {
  //   await showKeys(context, keypair);
  // }

  // await TransactionService().createWallet(email, keypair.address);

  await loginWithEncryption(context, ref, keypair.copyWith(email: email),
      reserveKeyPair, btcKeypair, password);

  final authorized = await guardWebAuthorized(ref, keypair.address);
  if (authorized) {
    final subscribed =
        await WebShopService().createContact(email, keypair.address);
    if (subscribed) {
      ref.read(webAuthTokenProvider.notifier).addEmail(email);
    }
  }
}

Future<void> handleCreateWithMnemonic(
  BuildContext context,
  WidgetRef ref, {
  bool showRememberMe = true,
}) async {
  ref.read(globalLoadingProvider.notifier).start();

  await Future.delayed(const Duration(milliseconds: 300));
  RaKeypair? reserveKeyPair;
  final keypair = await KeygenService.generate();
  if (keypair == null) {
    ref.read(globalLoadingProvider.notifier).complete();
    Toast.error();
    return;
  }
  int append = 0;
  while (true) {
    String input = keypair.private;
    if (input.startsWith("00")) {
      input = input.substring(2);
    }

    String seed = "${input.substring(0, 32)}$append";

    final kp = await KeygenService.seedToKeypair(seed);
    print(kp);
    if (kp == null) {
      continue;
    }
    reserveKeyPair =
        await KeygenService.importReserveAccountPrivateKey(kp.private);

    if (reserveKeyPair.address.startsWith("xRBX")) {
      break;
    }

    append += 1;
  }

  final btcGeneratedEmail =
      btcGeneratedEmailFromPrivateKey(keypair.privateCorrected);
  final btcGeneratedPassword =
      btcGeneratedPasswordFromPrivateKey(keypair.privateCorrected);

  final btcKeypair = await BtcWebService()
      .keypairFromEmailPassword(btcGeneratedEmail, btcGeneratedPassword);
  ref.read(globalLoadingProvider.notifier).complete();

  // final btcKeypair =
  //     keypair.mneumonic != null && keypair.mneumonic!.isNotEmpty ? await BtcWebService().keypairFromMnemonic(keypair.mneumonic!) : null;

  // ref.read(globalLoadingProvider.notifier).complete();

  // await TransactionService().createWallet(null, keypair.address);
  // Auto-enable Remember Me since keys will be encrypted

  // Collect encryption password
  final encryptionPassword = await PasswordPromptService.promptNewPassword(
    context,
    title: "Set Encryption Password",
    customMessage: "This password will encrypt your generated mnemonic keys.",
  );

  if (encryptionPassword == null) {
    ref.read(globalLoadingProvider.notifier).complete();
    return;
  }

  loginWithEncryption(
      context, ref, keypair, reserveKeyPair, btcKeypair, encryptionPassword);
  await showKeys(context, keypair, false, true);
}

Future<dynamic> handleRecoverFromMnemonic(BuildContext context, WidgetRef ref,
    {bool showRememberMe = true}) async {
  final value = await PromptModal.show(
    contextOverride: context,
    title: "Input Recovery Mnemonic",
    validator: (value) => formValidatorNotEmpty(value, "Recovery Mnemonic"),
    labelText: "Recovery Mnemonic",
    lines: 3,
    tightPadding: true,
  );

  if (value != null) {
    RaKeypair? reserveKeyPair;
    ref.read(globalLoadingProvider.notifier).start();

    await Future.delayed(const Duration(milliseconds: 300));

    final keypair = await KeygenService.recover(value.trim());

    if (keypair == null) {
      Toast.error();
      ref.read(globalLoadingProvider.notifier).complete();

      return;
    }
    int append = 0;
    while (true) {
      String input = keypair.private;
      if (input.startsWith("00")) {
        input = input.substring(2);
      }

      String seed = "${input.substring(0, 32)}$append";
      final kp = await KeygenService.seedToKeypair(seed);
      if (kp == null) {
        continue;
      }
      reserveKeyPair =
          await KeygenService.importReserveAccountPrivateKey(kp.private);

      if (reserveKeyPair.address.startsWith("xRBX")) {
        print(reserveKeyPair.address);
        break;
      }

      append += 1;
    }

    final btcGeneratedEmail =
        btcGeneratedEmailFromPrivateKey(keypair.privateCorrected);
    final btcGeneratedPassword =
        btcGeneratedPasswordFromPrivateKey(keypair.privateCorrected);

    final btcKeypair = await BtcWebService()
        .keypairFromEmailPassword(btcGeneratedEmail, btcGeneratedPassword);

    ref.read(globalLoadingProvider.notifier).complete();

    // Collect encryption password
    final encryptionPassword = await PasswordPromptService.promptNewPassword(
      context,
      title: "Set Encryption Password",
      customMessage: "This password will encrypt your recovered mnemonic keys.",
    );

    if (encryptionPassword == null) return;

    // showKeys(context, keypair);
    // await TransactionService().createWallet(null, keypair.address);
    await loginWithEncryption(
        context, ref, keypair, reserveKeyPair, btcKeypair, encryptionPassword);
  }
}

Future<void> showKeysForAccount(
  BuildContext context,
  WidgetRef ref,
  MultiAccountInstance account,
  KeypairType keypairType, [
  bool forReveal = false,
]) async {
  final decryptedAccount = await _getDecryptedAccount(context, account);
  if (decryptedAccount == null) return;
  await _showKeysForType(context, decryptedAccount, keypairType, forReveal);
}

Future<MultiAccountInstance?> _getDecryptedAccount(
  BuildContext context,
  MultiAccountInstance account,
) async {
  final storage = singleton<Storage>();
  final savedData = storage.getList(Storage.MULTIPLE_ACCOUNTS);

  if (savedData == null) return account;

  final storedAccountJson = savedData
      .map((e) => jsonDecode(e) as Map<String, dynamic>)
      .where((json) => json['id'] == account.id)
      .firstOrNull;

  final hasEncryptedKeys = storedAccountJson != null &&
      MultiAccountEncryptionService.hasEncryptedPrivateKeys(storedAccountJson);

  if (!hasEncryptedKeys) return account;

  final password = await PromptModal.show(
    contextOverride: context,
    title: "Enter Account Password",
    labelText: "Account Password",
    body:
        "Enter the password for this account to decrypt and view its private keys.",
    validator: (value) => formValidatorNotEmpty(value, "Password"),
    obscureText: true,
    revealObscure: true,
    lines: 1,
  );

  if (password == null) return null;

  try {
    final decryptedJson =
        MultiAccountEncryptionService.decryptAccountPrivateKeys(
            storedAccountJson, password);
    return MultiAccountInstance.fromJson(decryptedJson);
  } catch (e) {
    Toast.error("Failed to decrypt account keys. Check your password.");
    return null;
  }
}

Future<void> _showKeysForType(
  BuildContext context,
  MultiAccountInstance account,
  KeypairType keypairType,
  bool forReveal,
) async {
  switch (keypairType) {
    case KeypairType.vfx:
      if (account.keypair != null) {
        await _showKeysInternal(context, account.keypair!, forReveal);
      }
      break;

    case KeypairType.ra:
      if (account.raKeypair != null) {
        await _showRaKeysInternal(context, account.raKeypair!, forReveal);
      }
      break;

    case KeypairType.btc:
      if (account.btcKeypair != null) {
        final kp = Keypair(
          private: account.btcKeypair!.privateKey,
          address: account.btcKeypair!.address,
          public: account.btcKeypair!.publicKey,
          btcWif: account.btcKeypair!.wif,
        );
        await _showKeysInternal(context, kp, forReveal);
      }
      break;
  }
}

Future<void> showKeys(
  BuildContext context,
  Keypair keypair, [
  bool forReveal = false,
  bool bypassPassword = false,
]) async {
  final storage = singleton<Storage>();

  if (storage.isEncryptionEnabled() &&
      storage.hasPasswordHash() &&
      !bypassPassword) {
    await PasswordPromptService.requirePasswordFor(context, (password) async {
      await _showKeysInternal(context, keypair, forReveal);
    }, customMessage: "Enter your password to reveal private keys.");
  } else {
    await _showKeysInternal(context, keypair, forReveal);
  }
}

Future<void> _showKeysInternal(
  BuildContext context,
  Keypair keypair, [
  bool forReveal = false,
]) async {
  final isBtc = keypair.btcWif != null;
  final isMobile = BreakPoints.useMobileLayout(context);

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(forReveal ? "Keys" : "Key Generated"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  "Here are your${isBtc ? ' BTC' : ''} account details. Please ensure to back up your private key in a safe place."),
            ),
            if (keypair.mneumonic != null)
              ListTile(
                leading:
                    isMobile ? null : const Icon(FontAwesomeIcons.paragraph),
                title: TextFormField(
                  initialValue: keypair.mneumonic!,
                  decoration: const InputDecoration(
                    label: Text("Recovery Mnemonic"),
                  ),
                  style: const TextStyle(fontSize: 16),
                  readOnly: true,
                  minLines: 3,
                  maxLines: 3,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: keypair.mneumonic));
                    Toast.message("Mnemonic copied to clipboard");
                  },
                ),
              ),
            ListTile(
              leading:
                  isMobile ? null : const Icon(Icons.account_balance_wallet),
              title: TextFormField(
                initialValue: keypair.address,
                decoration: InputDecoration(
                    label: Text(
                  "Address",
                  style: TextStyle(
                    color: isBtc
                        ? Theme.of(context).colorScheme.btcOrange
                        : Theme.of(context).colorScheme.secondary,
                  ),
                )),
                readOnly: true,
                style: const TextStyle(fontSize: 13),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: keypair.address));
                  Toast.message("Public key copied to clipboard");
                },
              ),
            ),
            if (keypair.btcWif != null)
              ListTile(
                leading: isMobile ? null : const Icon(Icons.security),
                title: TextFormField(
                  initialValue: keypair.btcWif,
                  decoration: InputDecoration(
                    label: Text(
                      "WIF Private Key",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.btcOrange,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                  readOnly: true,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: keypair.btcWif));
                    Toast.message("WIF private key copied to clipboard");
                  },
                ),
              ),

            ListTile(
              leading: isMobile ? null : const Icon(Icons.security),
              title: TextFormField(
                initialValue: keypair.btcWif != null
                    ? keypair.private
                    : keypair.privateCorrected,
                decoration: InputDecoration(
                  label: Text(
                    "Private Key",
                    style: TextStyle(
                      color: isBtc
                          ? Theme.of(context).colorScheme.btcOrange
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 13),
                readOnly: true,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(
                      text: keypair.btcWif != null
                          ? keypair.private
                          : keypair.privateCorrected));
                  Toast.message("Private key copied to clipboard");
                },
              ),
            ),
            // if (keypair.mneumonic != null) Text(keypair.mneumonic!),

            const Divider(),
            AppButton(
              label: "Done",
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );
    },
  );
}

Future<void> logout(BuildContext context, WidgetRef ref) async {
  await ref.read(webSessionProvider.notifier).logout();

  AutoRouter.of(context).replace(const WebAuthRouter());
}

Future<void> showRaKeys(
  BuildContext context,
  RaKeypair keypair, [
  bool forReveal = false,
]) async {
  final storage = singleton<Storage>();

  // Only require password if user has encrypted storage
  if (storage.isEncryptionEnabled() && storage.hasPasswordHash()) {
    // User has encrypted storage - require password
    await PasswordPromptService.requirePasswordFor(context, (password) async {
      await _showRaKeysInternal(context, keypair, forReveal);
    },
        customMessage:
            "Enter your password to reveal Vault account private keys.");
  } else {
    // Legacy user with unencrypted storage - show keys directly
    await _showRaKeysInternal(context, keypair, forReveal);
  }
}

Future<void> _showRaKeysInternal(
  BuildContext context,
  RaKeypair keypair, [
  bool forReveal = false,
]) async {
  final isMobile = BreakPoints.useMobileLayout(context);

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text("Vault Account Details"),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    "Here are your Vault Account details. Please ensure to back up your private key in a safe place."),
              ),

              ListTile(
                leading:
                    isMobile ? null : const Icon(Icons.account_balance_wallet),
                title: TextFormField(
                  initialValue: keypair.address,
                  decoration: const InputDecoration(label: Text("Address")),
                  readOnly: true,
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: keypair.address));
                    Toast.message("Public key copied to clipboard");
                  },
                ),
              ),
              ListTile(
                leading: isMobile ? null : const Icon(Icons.security),
                title: TextFormField(
                  initialValue: keypair.privateCorrected,
                  decoration: const InputDecoration(
                    label: Text("Private Key"),
                  ),
                  style: const TextStyle(fontSize: 13),
                  readOnly: true,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: keypair.privateCorrected));
                    Toast.message("Private key copied to clipboard");
                  },
                ),
              ),

              ListTile(
                leading:
                    isMobile ? null : const Icon(Icons.account_balance_wallet),
                title: TextFormField(
                  initialValue: keypair.recoveryAddress,
                  decoration:
                      const InputDecoration(label: Text("Recovery Address")),
                  readOnly: true,
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: keypair.recoveryAddress));
                    Toast.message("Recovery Address copied to clipboard");
                  },
                ),
              ),
              ListTile(
                leading: isMobile ? null : const Icon(Icons.security),
                title: TextFormField(
                  initialValue: keypair.recoveryPrivateCorrected,
                  decoration: const InputDecoration(
                    label: Text("Recovery Private Key"),
                  ),
                  style: const TextStyle(fontSize: 13),
                  readOnly: true,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: keypair.recoveryPrivateCorrected));
                    Toast.message("Recovery Private Key copied to clipboard");
                  },
                ),
              ),
              ListTile(
                leading: isMobile ? null : const Icon(Icons.error),
                title: TextFormField(
                  initialValue: keypair.restoreCode,
                  decoration: const InputDecoration(
                    label: Text("Restore Code"),
                  ),
                  style: const TextStyle(fontSize: 13),
                  readOnly: true,
                  minLines: 3,
                  maxLines: 6,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: keypair.restoreCode));
                    Toast.message("Restore Code copied to clipboard");
                  },
                ),
              ),
              // if (keypair.mneumonic != null) Text(keypair.mneumonic!),

              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    label: "Copy All",
                    variant: AppColorVariant.Success,
                    icon: Icons.copy,
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: keypair.backupContents));
                      Toast.message("Vault Account Data copied to clipboard");
                    },
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  AppButton(
                    label: "Done",
                    icon: Icons.check,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}

showWebLoginModal(
  BuildContext context,
  WidgetRef ref, {
  required bool allowPrivateKey,
  required bool allowBtcPrivateKey,
  required VoidCallback onSuccess,
  bool showRememberMe = true,
}) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return AuthTypeModal(
        handleMnemonic: () async {
          final kind = await showModalBottomSheet(
            context: context,
            builder: (context) {
              return ModalContainer(
                withClose: true,
                children: [
                  AppCard(
                    padding: 0,
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).pop("new");
                      },
                      title: Text("Create New Mnemonic"),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  AppCard(
                    padding: 0,
                    child: ListTile(
                      title: Text("Recover From  Mnemonic"),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).pop("recover");
                      },
                    ),
                  ),
                ],
              );
            },
          );

          if (kind == 'new') {
            final success = await ConfirmDialog.show(
                title: 'Mnemonic',
                body: 'Are you sure you want to create a Mnemonic account?');
            if (success == true) {
              await handleCreateWithMnemonic(context, ref,
                  showRememberMe: showRememberMe);
              if (ref.read(webSessionProvider).isAuthenticated) {
                onSuccess();
              }
            }
          }

          if (kind == 'recover') {
            await handleRecoverFromMnemonic(context, ref);
            if (ref.read(webSessionProvider).isAuthenticated) {
              onSuccess();
            }
          }
        },
        handleUsername: () {
          AuthModal.show(
              context: context,
              onValidSubmission: (auth) async {
                await handleCreateWithEmail(
                  context,
                  ref,
                  auth.email,
                  auth.password,
                );
                if (ref.read(webSessionProvider).isAuthenticated) {
                  onSuccess();
                }
              });
        },
        handlePrivateKey: allowPrivateKey
            ? (context) async {
                await handleImportWithPrivateKey(context, ref,
                        showRememberMe: showRememberMe)
                    .then((value) {
                  if (ref.read(webSessionProvider).isAuthenticated) {
                    onSuccess();
                  }
                });
                // await Future.delayed(const Duration(milliseconds: 300));
              }
            : null,
        handleBtcPrivateKey: allowBtcPrivateKey
            ? (context) async {
                await handleImportWithBtcPrivateKey(context, ref,
                    showRememberMe: showRememberMe);
                if (ref.read(webSessionProvider).isAuthenticated) {
                  onSuccess();
                }
              }
            : null,
      );
    },
  );
}
