import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base_component.dart';
import '../../../core/env.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/validation.dart';
import '../../smart_contracts/components/sc_creator/common/form_group_container.dart';
import '../../smart_contracts/components/sc_creator/common/form_group_header.dart';
import '../../smart_contracts/components/sc_creator/common/help_button.dart';
import '../constants.dart';
import '../providers/config_form_provider.dart';

class ConfigurationFormGroup extends BaseComponent {
  const ConfigurationFormGroup({Key? key}) : super(key: key);

  @override
  Widget desktopBody(BuildContext context, WidgetRef ref) {
    return FormGroupContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FormGroupHeader(
            AppLocalizations.of(context).hnavConfigHeader,
            helpType: HelpType.configuration,
          ),
          Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Flexible(
                  child: _ApiPort(),
                ),
                Flexible(
                  child: _ApiCallUrl(),
                ),
                Flexible(child: _WalletUnlockTime()),
                Flexible(
                  child: _PasswordClearTime(),
                ),
                Flexible(child: _NftTimeout()),
                Flexible(
                  child: _AutoDownloadNftAsset(),
                ),
                Flexible(child: _IgnoreIncomingNfts()),
                Flexible(child: _RejectAssetsExtensionTypes()),
                Flexible(child: _AllowedExtensionTypes()),
                Flexible(child: _MotherAddress()),
                Flexible(child: _MotherPassword()),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ApiCallUrl extends BaseComponent {
  const _ApiCallUrl({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final provider = ref.read(configFormProvider.notifier);
    return TextFormField(
      controller: provider.apiCallUrlController,
      decoration: InputDecoration(
        label: Text(
          AppLocalizations.of(context).hnavConfigApiCallUrl,
          style: const TextStyle(color: Colors.white),
        ),
        hintText: "",
        suffixIcon: const HelpButton(HelpType.apiCallUrl),
      ),
    );
  }
}

class _MotherAddress extends BaseComponent {
  const _MotherAddress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final provider = ref.read(configFormProvider.notifier);
    return TextFormField(
      controller: provider.motherAddressController,
      decoration: InputDecoration(
        label: Text(
          AppLocalizations.of(context).hnavConfigMotherAddress,
          style: const TextStyle(color: Colors.white),
        ),
        hintText: "",
        suffixIcon: const HelpButton(HelpType.motherAddress),
      ),
    );
  }
}

class _MotherPassword extends BaseComponent {
  const _MotherPassword({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final provider = ref.read(configFormProvider.notifier);
    return TextFormField(
      obscureText: true,
      controller: provider.motherPasswordController,
      decoration: InputDecoration(
        label: Text(
          AppLocalizations.of(context).hnavConfigMotherPassword,
          style: const TextStyle(color: Colors.white),
        ),
        hintText: "",
        suffixIcon: const HelpButton(HelpType.motherPassword),
      ),
    );
  }
}

class _AutoDownloadNftAsset extends BaseComponent {
  const _AutoDownloadNftAsset({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final provider = ref.read(configFormProvider.notifier);
    final model = ref.watch(configFormProvider);
    return Row(
      children: [
        Checkbox(
            value: model.autoDownloadNftAsset,
            onChanged: (val) {
              provider.changeAutoDownloadNFTAssets(val!);
            }),
        GestureDetector(
          onTap: () {
            provider.changeAutoDownloadNFTAssets(!model.autoDownloadNftAsset);
          },
          child: Text(AppLocalizations.of(context).hnavConfigAutoDownloadNft),
        ),
        const HelpButton(HelpType.autoDownloadNftAsset)
      ],
    );
  }
}

class _IgnoreIncomingNfts extends BaseComponent {
  const _IgnoreIncomingNfts({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final provider = ref.read(configFormProvider.notifier);
    final model = ref.watch(configFormProvider);
    return Row(
      children: [
        Checkbox(
            value: model.ignoreIncomingNfts,
            onChanged: (val) {
              provider.changeIgnoreIncomingNfts(val!);
            }),
        GestureDetector(
          onTap: () {
            provider.changeIgnoreIncomingNfts(!model.ignoreIncomingNfts);
          },
          child: Text(AppLocalizations.of(context).hnavConfigIgnoreIncomingNfts),
        ),
        const HelpButton(HelpType.ignoreIncomingNfts)
      ],
    );
  }
}

class _WalletUnlockTime extends BaseComponent {
  const _WalletUnlockTime({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final provider = ref.read(configFormProvider.notifier);
    return TextFormField(
      controller: provider.walletUnlockTimeController,
      validator: (val) => formValidatorNumber(val, AppLocalizations.of(context).hnavConfigAccountUnlockTime),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: provider.setWalletUnlockTime,
      decoration: InputDecoration(
        label: Text(
          AppLocalizations.of(context).hnavConfigAccountUnlockTime,
          style: const TextStyle(color: Colors.white),
        ),
        hintText: WALLET_UNLOCK_TIME_DEFAULT.toString(),
        suffixIcon: const HelpButton(HelpType.walletUnlockTime),
      ),
    );
  }
}

class _NftTimeout extends BaseComponent {
  const _NftTimeout({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final provider = ref.read(configFormProvider.notifier);
    return TextFormField(
      controller: provider.nftTimeoutController,
      validator: (val) => formValidatorNumber(val, AppLocalizations.of(context).hnavConfigNftTimeout),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: provider.setNftTimeout,
      decoration: InputDecoration(
        label: Text(
          AppLocalizations.of(context).hnavConfigNftTimeout,
          style: const TextStyle(color: Colors.white),
        ),
        hintText: NFT_TIMEOUT_DEFAULT.toString(),
        suffixIcon: const HelpButton(HelpType.nftTimeout),
      ),
    );
  }
}

class _ApiPort extends BaseComponent {
  const _ApiPort({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final provider = ref.read(configFormProvider.notifier);
    return TextFormField(
      controller: provider.apiPortController,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: provider.setApiPort,
      decoration: InputDecoration(
        label: Text(
          AppLocalizations.of(context).hnavConfigApiPort,
          style: const TextStyle(color: Colors.white),
        ),
        hintText: Env.isTestNet ? '17292' : '7292',
        suffixIcon: const HelpButton(HelpType.apiPort),
      ),
    );
  }
}

class _PasswordClearTime extends BaseComponent {
  const _PasswordClearTime({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final provider = ref.read(configFormProvider.notifier);
    return TextFormField(
      controller: provider.passwordClearTimeController,
      validator: (val) => formValidatorNumber(val, AppLocalizations.of(context).hnavConfigPasswordClearTime),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: provider.setPasswordClearTime,
      decoration: InputDecoration(
        label: Text(
          AppLocalizations.of(context).hnavConfigPasswordClearTime,
          style: const TextStyle(color: Colors.white),
        ),
        hintText: PASSWORD_CLEAR_TIME_DEFAULT.toString(),
        suffixIcon: const HelpButton(HelpType.passwordClearTime),
      ),
    );
  }
}

class _AllowedExtensionTypes extends BaseComponent {
  const _AllowedExtensionTypes({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final provider = ref.read(configFormProvider.notifier);
    return TextFormField(
      controller: provider.allowedExtensionTypesController,
      onChanged: provider.setAllowedExtensionTypes,
      decoration: InputDecoration(
        label: Text(
          AppLocalizations.of(context).hnavConfigAllowedExtensionTypes,
          style: const TextStyle(color: Colors.white),
        ),
        suffixIcon: const HelpButton(HelpType.allowedAssetExtensionTypes),
      ),
    );
  }
}

class _RejectAssetsExtensionTypes extends BaseComponent {
  const _RejectAssetsExtensionTypes({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final provider = ref.read(configFormProvider.notifier);
    return TextFormField(
      controller: provider.rejectAssetExtensionTypesController,
      onChanged: provider.setRejectedAssetExtensionTypes,
      decoration: InputDecoration(
        label: Text(
          AppLocalizations.of(context).hnavConfigRejectedExtensionTypes,
          style: const TextStyle(color: Colors.white),
        ),
        suffixIcon: const HelpButton(HelpType.rejectAssetExtensionTypes),
      ),
    );
  }
}
