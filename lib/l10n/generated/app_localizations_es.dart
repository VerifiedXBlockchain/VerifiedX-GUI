import 'app_localizations.dart';

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'VFX Wallet';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navTransactions => 'Transacciones';

  @override
  String get navWallet => 'Billetera';

  @override
  String get navNfts => 'NFTs';

  @override
  String get navDomains => 'Dominios';

  @override
  String get navSettings => 'Configuración';

  @override
  String get actionSend => 'Enviar';

  @override
  String get actionReceive => 'Recibir';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionPaste => 'Pegar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionClear => 'Limpiar';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionYes => 'Sí';

  @override
  String get actionNo => 'No';

  @override
  String get statusLoading => 'Cargando...';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusConfirmed => 'Confirmada';

  @override
  String get statusFailed => 'Fallida';

  @override
  String get statusSuccessful => 'Exitosa';

  @override
  String get labelAmount => 'Monto';

  @override
  String get labelAddress => 'Dirección';

  @override
  String get labelBalance => 'Saldo';

  @override
  String get labelAvailable => 'Disponible';

  @override
  String get labelTotal => 'Total';

  @override
  String get labelLocked => 'Bloqueado';

  @override
  String get labelFee => 'Comisión';

  @override
  String get labelFrom => 'De';

  @override
  String get labelTo => 'Para';

  @override
  String get walletCreate => 'Crear billetera';

  @override
  String get walletImport => 'Importar billetera';

  @override
  String get walletPrivateKey => 'Clave privada';

  @override
  String get walletRecoveryPhrase => 'Frase de recuperación';

  @override
  String get messageNoResults => 'No se encontraron resultados';

  @override
  String get messageCopiedToClipboard => 'Copiado al portapapeles';

  @override
  String get messageAddressCopied => 'Dirección copiada al portapapeles';

  @override
  String get messagePrivateKeyCopied => 'Clave privada copiada al portapapeles';

  @override
  String get messageNoAccountSelected => 'No se seleccionó ninguna cuenta';

  @override
  String get messageClipboardInvalid => 'El texto del portapapeles no es válido';

  @override
  String sentAmount(String amount) {
    return 'Se enviaron $amount VFX';
  }

  @override
  String sendAppBarTitle(String currency) {
    return 'Enviar $currency';
  }

  @override
  String get sendFormLabelTo => 'Para:';

  @override
  String get sendFormLabelFrom => 'De:';

  @override
  String get sendFormLabelAmount => 'Monto:';

  @override
  String get sendFormLabelFeeRate => 'Comisión:';

  @override
  String get sendRecipientHint => 'Dirección de la cuenta del destinatario';

  @override
  String sendAmountHint(String currency) {
    return 'Monto de $currency a enviar';
  }

  @override
  String get sendBadgeNotActivated => 'No activada';

  @override
  String get sendChooseAddressTitle => 'Elige una dirección';

  @override
  String get sendPaymentLinkCta => 'Crear enlace de pago';

  @override
  String get sendPasteHelperCtrl => 'Usa ctrl+v para pegar o haz clic ';

  @override
  String get sendPasteHelperCmd => 'Usa cmd+v para pegar o haz clic ';

  @override
  String get sendPasteHelperHereLink => 'aquí';

  @override
  String receiveAppBarTitle(String currency) {
    return 'Recibir $currency';
  }

  @override
  String receiveSelectedVfxAddress(String vaultSuffix) {
    return 'Tu dirección VFX$vaultSuffix seleccionada';
  }

  @override
  String get receiveSelectedBtcAddress => 'Tu dirección BTC seleccionada';

  @override
  String get receiveVaultNotActivatedToast => 'Esta cuenta de bóveda aún no ha sido activada.';

  @override
  String get receiveActionCopyAddress => 'Copiar\nDirección';

  @override
  String get receiveActionNewAccount => 'Cuenta\nNueva';

  @override
  String get receiveActionImportKey => 'Importar\nClave';

  @override
  String get receiveRescanDialogTitle => '¿Volver a escanear bloques?';

  @override
  String get receiveRescanDialogBody => '¿Quieres volver a escanear la cadena para incluir las transacciones relevantes a esta clave?';

  @override
  String get receiveBtcAccountCreatedTitle => 'Cuenta BTC creada';

  @override
  String get receiveBtcAccountCreatedBody => 'Aquí están los detalles de tu cuenta BTC. Asegúrate de respaldar tu clave privada en un lugar seguro.';

  @override
  String get receiveBtcImportKeyDialogTitle => 'Importar clave privada BTC';

  @override
  String get receiveBtcImportKeyDialogBody => 'Pega tu clave privada BTC para importar tu cuenta.';

  @override
  String get txAppBarAll => 'Todas las transacciones';

  @override
  String get txAppBarVfx => 'Transacciones VFX';

  @override
  String get txAppBarBtc => 'Transacciones BTC';

  @override
  String get txTabAll => 'Todas';

  @override
  String get txTabPending => 'Pendientes';

  @override
  String get txTabSuccessful => 'Exitosas';

  @override
  String get txTabFailed => 'Fallidas';

  @override
  String get txTabVaulted => 'En bóveda';

  @override
  String get txTabTransactions => 'Transacciones';

  @override
  String get txTabInputs => 'Entradas';

  @override
  String get homeKeysHeading => 'Claves';

  @override
  String get homeActionSendCoin => 'Enviar\nMoneda';

  @override
  String get homeActionReceiveCoin => 'Recibir\nMoneda';

  @override
  String get homeActionTxs => 'TXs';

  @override
  String get homeGetVfxBtcCta => 'Obtén \$VFX/\$BTC';

  @override
  String get homeGetVfxCta => 'Obtén \$VFX';

  @override
  String get configAppBarTitle => 'Configuración del CLI';

  @override
  String get configCloseDialogTitle => '¿Cerrar la pantalla de configuración?';

  @override
  String get configCloseDialogBody => 'Se perderán todos los cambios sin guardar.';

  @override
  String get configButtonOpenConfig => 'Abrir config';

  @override
  String get configButtonViewDocs => 'Ver documentación';

  @override
  String get configWarningAdvanced => 'Advertencia: Estas son opciones avanzadas. Procede con precaución.';

  @override
  String get configRestartRequiredToast => 'Se requiere reiniciar el CLI para aplicar los cambios.';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsLanguageSystemDefault => 'Predeterminado del sistema';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Español';
}
