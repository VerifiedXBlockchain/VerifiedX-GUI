import 'package:intl/intl.dart' as intl;

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

  @override
  String get walletAccountsTitle => 'Mis cuentas';

  @override
  String get walletChangeAccount => 'Cambiar cuenta:';

  @override
  String get walletPrivateKeyLabel => 'Clave privada';

  @override
  String get walletImportLabel => 'Importar';

  @override
  String get walletBulkImportTitle => 'Importador masivo de cuentas';

  @override
  String get walletBulkImportHint => 'Pega tus claves privadas. Cada clave debe ir en una línea.';

  @override
  String get walletConfirmImportTitle => 'Confirmar importación';

  @override
  String walletConfirmImportBody(String label) {
    return '¿Quieres continuar con la importación de $label?';
  }

  @override
  String walletKeypairsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pares de claves',
      one: '1 par de claves',
    );
    return '$_temp0';
  }

  @override
  String get walletRescanBlocksTitle => '¿Volver a escanear bloques?';

  @override
  String get walletRescanBlocksBodyKeys => '¿Quieres volver a escanear la cadena para incluir las transacciones relevantes a estas claves?';

  @override
  String get walletRescanBlocksBodyKey => '¿Quieres volver a escanear la cadena para incluir las transacciones relevantes a esta clave?';

  @override
  String walletImportedToast(String label) {
    return '¡$label importado!';
  }

  @override
  String walletAddressCopiedToast(String address) {
    return '$address copiado al portapapeles';
  }

  @override
  String get walletPrivateKeyCopiedToast => 'Clave privada copiada al portapapeles';

  @override
  String get walletCopyVfxAddressTooltip => 'Copiar dirección VFX';

  @override
  String get walletCopyBtcAddressTooltip => 'Copiar dirección BTC';

  @override
  String get walletAddressesPlaceholder => 'Direcciones de cuentas VFX/BTC';

  @override
  String get walletImportTitle => 'Importar billetera';

  @override
  String get walletBulkImportLabel => 'Importación masiva';

  @override
  String get walletNewAccount => 'Cuenta nueva';

  @override
  String get walletImportBtcWallet => 'Importar billetera BTC';

  @override
  String get walletImportBtcDialogTitle => 'Importar clave privada BTC';

  @override
  String get walletImportBtcDialogBody => 'Pega tu clave privada BTC para importar tu cuenta.';

  @override
  String get walletNewBtcAccount => 'Cuenta BTC nueva';

  @override
  String get walletBtcAccountCreatedTitle => 'Cuenta BTC creada';

  @override
  String get walletBtcAccountCreatedBody => 'Aquí están los detalles de tu cuenta BTC. Asegúrate de respaldar tu clave privada en un lugar seguro.';

  @override
  String get walletAddressLabel => 'Dirección';

  @override
  String get walletManageAccounts => 'Administrar cuentas';

  @override
  String get walletPrivateKeyImportedToast => '¡Clave privada importada!';

  @override
  String walletPrivateKeyImportedSyncToast(String nextSync) {
    return '¡Clave privada importada! Espera hasta $nextSync para que el saldo se sincronice.';
  }

  @override
  String get walletRevealPrivateKey => 'Revelar clave privada';

  @override
  String get walletHideAccountTitle => 'Ocultar cuenta';

  @override
  String get walletHideAccountBody => '¿Seguro que quieres ocultar esta cuenta?';

  @override
  String get walletHideLabel => 'Ocultar';

  @override
  String get walletStatusActivated => 'Activada';

  @override
  String get walletRestoreHidden => 'Restaurar cuentas ocultas';

  @override
  String get walletNoHiddenAccounts => 'No tienes cuentas ocultas.';

  @override
  String get walletNoHiddenAccountsTitle => 'No hay cuentas para restaurar';

  @override
  String get walletOkay => 'Entendido';

  @override
  String get walletSelectToRestore => 'Selecciona las cuentas a restaurar';

  @override
  String get walletRestoreAll => 'Restaurar todas';

  @override
  String get walletRestoreSelected => 'Restaurar seleccionadas';

  @override
  String get walletNameLabel => 'Nombre';

  @override
  String walletRenameTitle(String label) {
    return 'Renombrar $label';
  }

  @override
  String get walletRename => 'Renombrar';

  @override
  String get walletDelete => 'Eliminar';

  @override
  String get walletPrivateKeyValidatorLabel => 'Clave privada';

  @override
  String get walletDoneLabel => 'Listo';

  @override
  String get walletVaultAccountCreatedTitle => 'Cuenta de bóveda creada';

  @override
  String get walletRestoreCodeWarning => '🚨 Asegúrate de respaldar tu CÓDIGO DE RESTAURACIÓN en un lugar seguro. 🚨';

  @override
  String get walletRestoreCodeLabel => 'Código de restauración';

  @override
  String get walletCopyAll => 'Copiar todo';

  @override
  String get walletSaveAsFile => 'Guardar como archivo';

  @override
  String get walletVaultDataCopiedToast => 'Datos de la cuenta de bóveda copiados al portapapeles';

  @override
  String walletSavedToToast(String path) {
    return 'Guardado en $path';
  }

  @override
  String get walletRestoreCodeCopiedToast => 'Código de restauración copiado al portapapeles';

  @override
  String get walletRecoveryAddressLabel => 'Dirección de recuperación';

  @override
  String get walletRecoveryAddressCopiedToast => 'Dirección de recuperación copiada al portapapeles';

  @override
  String get walletRecoveryPrivateKeyLabel => 'Clave privada de recuperación';

  @override
  String get walletRecoveryPrivateKeyCopiedToast => 'Clave privada de recuperación copiada al portapapeles';

  @override
  String get walletBackupConfirmTitle => '¿Respaldado?';

  @override
  String get walletBackupConfirmBody => 'Confirma que has respaldado tu CÓDIGO DE RESTAURACIÓN así como tu CONTRASEÑA.';

  @override
  String get walletBackupConfirmYes => 'Respaldado';

  @override
  String get walletRestoreCodeNote => 'Necesitarás el Código de restauración y la Contraseña para recuperar cualquier transacción. Te recomendamos copiar todo y guardarlo de forma segura, como cualquier clave privada.';

  @override
  String get authWelcomeTitle => '¡Bienvenido a la Web Wallet de VerifiedX!';

  @override
  String get authWelcomeBodyOne => 'La red NO almacena tu correo/contraseña ni tu mnemónico. Se usan como semillas para generar los pares de claves de tus cuentas.';

  @override
  String get authWelcomeBodyTwo => 'Esto incluye tu cuenta VFX, tu cuenta de bóveda y tu cuenta de Bitcoin.';

  @override
  String get authWelcomeBodyThree => 'Recomendamos respaldar todas las claves privadas; sin embargo, al generarlas con correo/contraseña o mnemónico, tu clave privada VFX restaurará las tres cuentas.';

  @override
  String get authBackupKeys => 'Respaldar claves';

  @override
  String get authUnlockWalletFor => 'Desbloquear billetera para:';

  @override
  String get authUnknownAddress => 'Dirección desconocida';

  @override
  String get authEnterPassword => 'Ingresa la contraseña';

  @override
  String get authEnterPasswordBody => 'Ingresa tu contraseña para descifrar tus claves almacenadas.';

  @override
  String get authDecryptFailed => 'No se pudieron descifrar las claves';

  @override
  String get authLogout => 'Cerrar sesión';

  @override
  String get authLoginCreateAccount => 'Iniciar sesión / Crear cuenta';

  @override
  String get authResumeSession => 'Reanudar sesión';

  @override
  String authWebWalletSubtitle(String version) {
    return 'Web Wallet $version';
  }

  @override
  String get authTypeEmailPassword => 'Correo y contraseña';

  @override
  String get authTypeMnemonic => 'Mnemónico (cuenta HD)';

  @override
  String get authTypeVfxPrivateKey => 'Clave privada VFX';

  @override
  String get authTypeBtcPrivateKey => 'Clave privada de Bitcoin / Clave WIF';

  @override
  String get authTypeVfxExtension => 'Extensión VFX';

  @override
  String get btcVbtcOnboardTitle => 'Onboarding vBTC';

  @override
  String get btcExitOnboardingTitle => '¿Salir del onboarding de vBTC?';

  @override
  String get btcExitOnboardingBody => '¿Seguro que quieres cancelar la configuración de tu cuenta con Bitcoin Tokenizado?';

  @override
  String get btcVbtcReady => 'Tu token vBTC está listo y financiado.';

  @override
  String get btcViewToken => 'Ver token';

  @override
  String get btcTokenNotFoundToast => 'Token no encontrado';

  @override
  String get btcNoBtcAccountOrToken => 'No se encontró cuenta BTC ni token.';

  @override
  String get btcStartOver => 'Comenzar de nuevo';

  @override
  String btcFromAddress(String address) {
    return 'De: $address';
  }

  @override
  String btcToAddress(String address) {
    return 'Para: $address';
  }

  @override
  String get btcAmountToSendLabel => 'Monto a enviar (BTC)';

  @override
  String get btcFeeRateLabel => 'Comisión:';

  @override
  String get btcInitiateTransfer => 'Iniciar transferencia';

  @override
  String get btcInvalidAmountToast => 'Monto inválido';

  @override
  String get btcAddressLabel => 'Dirección BTC';

  @override
  String get btcAddressCopiedToast => '¡Dirección copiada al portapapeles!';

  @override
  String get btcSentManually => '¡Lo envié manualmente!';

  @override
  String get btcNoBtcAccount => 'No se encontró cuenta BTC.';

  @override
  String get btcWifCopiedToast => 'Clave privada WIF copiada al portapapeles';

  @override
  String get btcDoneExclamation => '¡Listo!';

  @override
  String get btcImportExisting => 'Importar existente';

  @override
  String get btcCreateNew => 'Crear nueva';

  @override
  String get btcBalanceFoundTitle => '¡Saldo encontrado!';

  @override
  String get btcVfxAccountImportedToast => 'Cuenta VFX importada exitosamente';

  @override
  String get btcVfxAccountCreatedToast => 'Cuenta VFX creada exitosamente';

  @override
  String get btcUseExistingVfxAccount => 'O usa una de tus cuentas VFX existentes:';

  @override
  String get btcUseExistingBtcAccount => 'O usa una de tus cuentas BTC existentes:';

  @override
  String get btcNoVfxAccount => 'No se encontró cuenta VFX.';

  @override
  String get btcUseFaucet => 'Usar faucet';

  @override
  String get btcPhoneNumberTitle => 'Número de teléfono';

  @override
  String get btcPhoneNumberLabel => 'Tu número de teléfono';

  @override
  String get btcInvalidPhoneToast => 'Número de teléfono inválido';

  @override
  String btcVerificationCodeTitle(String phone) {
    return 'Ingresa el código de verificación enviado a $phone';
  }

  @override
  String get btcVerificationCodeLabel => 'Código de verificación';

  @override
  String get btcManualSendBody => 'Como alternativa, puedes enviar el BTC manualmente a la dirección de depósito de tu token.';

  @override
  String btcNotEnoughBalance(String amount) {
    return 'No hay suficiente saldo en la cuenta BTC para enviar $amount BTC';
  }

  @override
  String btcFundsSuccessToast(String hash) {
    return '¡Éxito! Los fondos están en camino. Hash de TX: $hash';
  }

  @override
  String get btcTransferManually => 'Transferir manualmente';

  @override
  String get btcBulkTransferTitle => 'Transferencia masiva de vBTC';

  @override
  String get btcBulkMaxTransferAmount => 'Monto máximo de transferencia:';

  @override
  String get btcBulkContinue => 'Continuar';

  @override
  String get btcBulkNoTokensSelected => 'No se seleccionaron tokens.';

  @override
  String get btcBulkAmountHint => 'Monto';

  @override
  String btcBulkMaxLabel(String amount) {
    return '(MÁX: $amount vBTC)';
  }

  @override
  String btcBulkTotalLabel(String amount) {
    return 'Total: $amount vBTC';
  }

  @override
  String get btcBulkTransferToLabel => 'Transferir a dirección VFX';

  @override
  String get btcBulkTransferToHint => 'Dirección de la cuenta VFX del destinatario';

  @override
  String get btcBulkConfirmTxTitle => 'Confirmar TX masiva';

  @override
  String get btcBulkBroadcastedToast => 'TX de transferencia masiva de vBTC transmitida';

  @override
  String get btcBulkNoVfxSelectedToast => 'No se seleccionó ninguna cuenta VFX';

  @override
  String get btcTokenizeTitle => 'Tokenizar BTC (vBTC)';

  @override
  String get btcVbtcTokenHint => 'Token vBTC';

  @override
  String get btcVbtcHint => 'vBTC';

  @override
  String get btcViewProgress => 'Ver progreso';

  @override
  String get btcCompileMint => 'Compilar y emitir';

  @override
  String get btcTransactionBroadcastedTitle => 'Transacción transmitida';

  @override
  String get btcMintAndDeploy => 'Emitir y desplegar';

  @override
  String get btcVfxAddressRequired => 'Se requiere una dirección VFX';

  @override
  String get btcCreateVbtcTitle => '¿Crear token vBTC?';

  @override
  String get btcMpcStartBody => 'Esto iniciará una ceremonia MPC para crear tu token vBTC.';

  @override
  String get btcNetworkFeeBody => 'Se requiere una comisión de red de ~0,000028 VFX.';

  @override
  String btcVfxAccountLabel(String address) {
    return 'Cuenta VFX: $address';
  }

  @override
  String get btcChangeAccountLabel => 'Cambiar cuenta:';

  @override
  String get btcVfxAddressLabel => 'Dirección VFX:';

  @override
  String get btcContinueQuestion => '¿Continuar?';

  @override
  String get btcVbtcListTitle => 'Bitcoin tokenizado (vBTC)';

  @override
  String get btcBulkTransferLabel => 'Transferencia masiva de vBTC';

  @override
  String get btcNoVbtcWithBalance => 'No hay tokens vBTC con saldo';

  @override
  String get btcCreateVerifiedToken => 'Crear token Verified BTC';

  @override
  String get btcVfxBalanceRequiredTitle => 'Se requiere una dirección VFX con saldo';

  @override
  String get btcUseWizard => 'Usar asistente';

  @override
  String get btcVbtcLabel => 'vBTC';

  @override
  String get btcNoTokenizedBtc => 'No se encontró Bitcoin tokenizado en la cuenta.';

  @override
  String get btcDetailsLabel => 'Detalles';

  @override
  String get btcNoTransactions => 'Sin transacciones';

  @override
  String get btcTokenNotFoundLabel => 'Token no encontrado';

  @override
  String get btcDetailNameLabel => 'Nombre';

  @override
  String get btcDetailDescriptionLabel => 'Descripción';

  @override
  String get btcDetailOwnerLabel => 'Propietario';

  @override
  String get btcDetailScOwnerLabel => 'Propietario del contrato inteligente';

  @override
  String get btcDetailScOwnerAddressLabel => 'Dirección del propietario del contrato inteligente';

  @override
  String get btcDetailDepositAddressLabel => 'Dirección de depósito BTC';

  @override
  String get btcDetailScIdLabel => 'ID del contrato inteligente';

  @override
  String get btcDetailMyBalanceLabel => 'Mi saldo';

  @override
  String get btcDetailTotalBalanceLabel => 'Saldo total del token';

  @override
  String get btcDetailOwnerOnlyMedia => 'Solo el propietario del token puede ver el contenido adicional.';

  @override
  String get btcDetailTransferNow => 'Transferir ahora';

  @override
  String get btcTransferNowToast => 'La solicitud de transferencia se ha transmitido. Tus activos deberían estar disponibles pronto.';

  @override
  String btcLabelCopiedToast(String label) {
    return '$label copiado al portapapeles';
  }

  @override
  String get btcRetry => 'Reintentar';

  @override
  String get btcConfirmedLabel => 'Confirmada';

  @override
  String get btcPendingLabel => 'Pendiente';

  @override
  String get btcReplaceByFee => 'Reemplazar por comisión';

  @override
  String get btcRbfFeeRateTitle => 'Comisión';

  @override
  String get btcRbfFeeRateLabel => 'Comisión (SATS/byte)';

  @override
  String get btcCopyDepositAddress => 'Copiar dirección de depósito';

  @override
  String get btcAddressCopiedShort => 'Dirección BTC copiada al portapapeles';

  @override
  String get btcFundLabel => 'Financiar';

  @override
  String btcAmountWithBalanceTitle(String balance) {
    return 'Monto (saldo: $balance BTC)';
  }

  @override
  String get btcPleaseConfirmTitle => 'Confirma por favor';

  @override
  String get btcOpenInExplorer => 'Abrir en el explorador BTC';

  @override
  String get btcManualSendTitle => 'Envío manual';

  @override
  String get btcWithdrawLabel => 'Retirar';

  @override
  String get btcWithdrawAmountLabel => 'Monto del retiro';

  @override
  String get btcReceivingAddressLabel => 'Dirección receptora';

  @override
  String get btcResponseTitle => 'Respuesta';

  @override
  String get btcTransferOwnership => 'Transferir propiedad';

  @override
  String get btcVbtcNoBalanceTransfer => 'Los tokens vBTC sin saldo no se pueden transferir';

  @override
  String get btcTransferToTitle => 'Transferir a';

  @override
  String get btcTransferLabel => 'Transferir';

  @override
  String get btcProveOwnership => 'Probar propiedad';

  @override
  String get btcBorrowLend => 'Pedir/Prestar';

  @override
  String get btcActionNotAvailable => 'Acción aún no disponible.';

  @override
  String get btcCancelLabel => 'Cancelar';

  @override
  String get btcInvalidAmount => 'Monto inválido';

  @override
  String get btcNotEnoughBalanceShort => 'Saldo insuficiente';

  @override
  String get btcAddBtcAccount => 'Agregar cuenta BTC (Segwit)';

  @override
  String get btcGenerateKeypair => 'Generar par de claves';

  @override
  String get btcGenerateKeypairSubtitle => 'Genera un par de claves BTC aleatorio.';

  @override
  String get btcImportWifTitle => 'Importar clave privada WIF';

  @override
  String get btcImportWifSubtitle => 'Importa tu clave privada WIF de BTC';

  @override
  String get btcDomainPending => 'Dominio BTC pendiente';

  @override
  String get btcDomainTransferPending => 'Transferencia de dominio BTC pendiente';

  @override
  String get btcDomainDeletePending => 'Eliminación de dominio BTC pendiente';

  @override
  String get btcCreateDomain => 'Crear dominio';

  @override
  String get btcTransferBtcDomain => 'Transferir dominio BTC';

  @override
  String get btcVfxOwnerTitle => 'Propietario VFX';

  @override
  String get btcVfxAddressLabelComma => 'Dirección VFX,';

  @override
  String get btcInvalidTxData => 'Datos de transacción inválidos.';

  @override
  String get btcValidTxTitle => 'Transacción válida';

  @override
  String get btcTxCancelledToast => 'Transacción cancelada';

  @override
  String get btcDeleteDomainTitle => '¿Eliminar dominio BTC?';

  @override
  String get btcStatusLabel => 'Estado';

  @override
  String get btcFeeLabel => 'Comisión';

  @override
  String get btcBlockTimeLabel => 'Hora del bloque';

  @override
  String get btcBlockHeightLabel => 'Altura del bloque';

  @override
  String get btcWebNoBtcAddress => 'Sin dirección BTC';

  @override
  String btcWebNoTransactionsForAddress(String address) {
    return 'No se encontraron transacciones para $address.';
  }

  @override
  String get btcWebError => 'Error';

  @override
  String get reserveManageTitle => 'Administrar cuentas de bóveda';

  @override
  String get reserveSetupNewAccount => 'Configurar cuenta nueva';

  @override
  String get reserveRestoreVaultAccount => 'Restaurar cuenta de bóveda';

  @override
  String get reserveNoVaultAccounts => 'No hay cuentas de bóveda';

  @override
  String get reserveAddressColon => 'Dirección:';

  @override
  String get reserveAvailableBalanceColon => 'Saldo disponible:';

  @override
  String get reserveStatusColon => 'Estado:';

  @override
  String get reserveSendFunds => 'Enviar fondos';

  @override
  String get reserveManageAssets => 'Administrar activos';

  @override
  String get reserveAssetsNfts => 'NFTs';

  @override
  String get reserveAssetsTokens => 'Tokens fungibles';

  @override
  String get reserveAssetsBtc => 'Bitcoin (vBTC)';

  @override
  String get reserveNoAssetsToast => 'Esta cuenta no tiene activos/NFTs.';

  @override
  String get reserveTransferLabel => 'Transferir';

  @override
  String get reserveViewDetailsLabel => 'Ver detalles';

  @override
  String get reserveNoVbtcTokens => 'Esta cuenta no tiene tokens vBTC';

  @override
  String get reserveReceiveAssets => 'Recibir activos';

  @override
  String get reserveActivateAccountAction => 'Activar\nCuenta';

  @override
  String get reserveOverviewTitle => 'Cuentas de bóveda';

  @override
  String get reserveWhatIsVault => '¿Qué son las cuentas de bóveda?';

  @override
  String reserveAvailableLabel(String amount) {
    return 'Disponible: $amount VFX';
  }

  @override
  String get reserveActivated => 'Activada';

  @override
  String get reserveActivationPending => 'Activación pendiente';

  @override
  String get reserveAwaitingFunds => 'Esperando fondos';

  @override
  String get reserveActivateNow => 'Activar ahora';

  @override
  String get reserveRecoverLabel => 'Recuperar';

  @override
  String get reserveRecoverTitle => 'Recuperar fondos y NFTs';

  @override
  String reserveRecoverBody(String address) {
    return 'Esta es una función destructiva que devolverá todas las transacciones y activos pendientes a esta cuenta de recuperación:\n\n$address';
  }

  @override
  String get reserveRecoverProceed => 'Continuar';

  @override
  String get reserveBackupMediaTitle => 'Respaldar contenido';

  @override
  String get reserveBackupMediaBody => 'El contenido de los NFT no se transferirá en este proceso. ¿Quieres exportar un respaldo ahora para importarlo en tu nuevo entorno?';

  @override
  String get reserveBackupAction => 'Respaldar';

  @override
  String get reserveManageVaultAccounts => 'Administrar cuentas de bóveda';

  @override
  String get reserveExistingAccounts => 'Cuentas existentes';

  @override
  String get reserveWebTitle => 'Tu cuenta de bóveda';

  @override
  String get reserveWebNoAccount => 'No se encontró cuenta de bóveda';

  @override
  String get reserveWebRevealKeys => 'Revelar claves';

  @override
  String get reserveWebVaultBalanceTitle => 'Saldo de la cuenta de bóveda';

  @override
  String get reserveWebNoNftsToast => 'Tu cuenta de bóveda no tiene NFTs.';

  @override
  String get reserveCallbackLabel => 'Devolver';

  @override
  String get reserveCallbackTitle => 'Devolver transacción';

  @override
  String get reserveCallbackBody => 'Las devoluciones (callbacks) se pueden usar para devolver los fondos/activos a la misma cuenta con fines de custodia. Ingresa tu contraseña para devolver esta transacción.';

  @override
  String get reservePasswordLabel => 'Contraseña';

  @override
  String reserveCallbackSentToast(String hash) {
    return 'TX de devolución enviada con hash $hash';
  }

  @override
  String get nodePoolTitle => 'Pool de validadores';

  @override
  String get nodeSearchHint => 'Busca por nombre del validador...';

  @override
  String get nodeSearchExactNote => '* El nombre debe coincidir exactamente';

  @override
  String get nodeValidatorHeading => 'Validador';

  @override
  String get nodeStatusActive => 'Activo';

  @override
  String get nodeStatusInactive => 'Inactivo';

  @override
  String get nodePeerInfoHeading => 'Información de pares';

  @override
  String get nodeIpLabel => 'IP:';

  @override
  String get nodeHeightLabel => 'Altura:';

  @override
  String get nodeLatencyLabel => 'Latencia:';

  @override
  String get nodeLastCheckedLabel => 'Última verificación:';

  @override
  String nodeConnectedLabel(String date) {
    return 'Conectado: $date';
  }

  @override
  String nodeWalletVersionLabel(String version) {
    return 'Versión de billetera: $version';
  }

  @override
  String nodeConnectionDateLabel(String date) {
    return 'Fecha de conexión: $date';
  }

  @override
  String nodeBlocksLabel(String count) {
    return 'Bloques: $count';
  }

  @override
  String get validatorTitle => 'Validador';

  @override
  String get validatorNoAccountSelected => 'No se seleccionó ninguna cuenta';

  @override
  String validatorCannotValidate(String label) {
    return '$label no puede validar.';
  }

  @override
  String get validatorOnlyOneAccount => 'Solo puedes validar con una cuenta.';

  @override
  String validatorRequirementHint(String amount) {
    return 'Validar requiere $amount VFX.';
  }

  @override
  String get validatorChooseAccount => 'Elige otra cuenta:';

  @override
  String validatorTransferHint(String amount, String address) {
    return 'O transfiere $amount VFX a $address.';
  }

  @override
  String validatorPortInstructions(String port, String port2, String port3, String amount) {
    return 'Debes tener los puertos $port, $port2 y $port3 abiertos a redes externas con un saldo de $amount VFX para validar.';
  }

  @override
  String get validatorStartValidating => 'Iniciar validación';

  @override
  String validatorBalanceInsufficient(String amount) {
    return 'Saldo insuficiente para validar. Se requieren $amount VFX.';
  }

  @override
  String get validatorNamePromptTitle => 'Nombra tu validador';

  @override
  String get validatorNameLabel => 'Nombre del validador';

  @override
  String validatorNowValidating(String name, String label) {
    return '$name [$label] ahora está validando.';
  }

  @override
  String validatorNotValidating(String label) {
    return '$label NO está validando...';
  }

  @override
  String get validatorCheckAgain => 'Verificar de nuevo';

  @override
  String get validatorActive => 'Validando...';

  @override
  String validatorAddressLabel(String label) {
    return 'Dirección: $label';
  }

  @override
  String get validatorRenameTooltip => 'Renombrar validador';

  @override
  String get validatorNamePromptTitleAlt => 'Nombre del validador';

  @override
  String get validatorNameField => 'Nombre';

  @override
  String get validatorNewNameLabel => 'Nuevo nombre del validador';

  @override
  String validatorRenamedToast(String name) {
    return 'El nombre del validador se cambió a $name.';
  }

  @override
  String get validatorRestartCliTitle => 'Reiniciar CLI';

  @override
  String get validatorRestartCliBody => 'Para que el nombre se aplique,\nse requiere reiniciar el CLI.\n\n¿Reiniciar ahora?';

  @override
  String get validatorRestartCliConfirm => 'Reiniciar';

  @override
  String get validatorRestartingToast => 'Reiniciando CLI...';

  @override
  String get validatorStopValidating => 'Detener validación';

  @override
  String get validatorStopValidatingBody => '¿Seguro que quieres detener la validación?';

  @override
  String get validatorStopLabel => 'Detener';

  @override
  String validatorStoppedToast(String label) {
    return '$label ha dejado de validar.';
  }

  @override
  String validatorBlocksValidatedHeading(String count) {
    return 'Bloques validados ($count)';
  }

  @override
  String get validatorNoValidatedBlocks => 'Sin bloques validados';

  @override
  String validatorBlockTitle(String height) {
    return 'Bloque $height';
  }

  @override
  String get adnrTitleAny => 'Dominios';

  @override
  String get adnrTitleVfx => 'Dominios VFX';

  @override
  String get adnrTitleBtc => 'Dominios BTC';

  @override
  String get adnrCreateAnyHeading => 'Crea un dominio como alias de tu dirección para recibir fondos.';

  @override
  String get adnrCreateVfxHeading => 'Crea un dominio VFX como alias de tu dirección para recibir fondos.';

  @override
  String get adnrCreateBtcHeading => 'Crea un dominio BTC como alias de tu dirección BTC para recibir fondos.';

  @override
  String adnrCostNoteAny(String cost) {
    return 'Los dominios cuestan $cost VFX más la comisión de la transacción.';
  }

  @override
  String adnrCostNoteVfx(String cost) {
    return 'Los dominios VFX cuestan $cost VFX más la comisión de la transacción.';
  }

  @override
  String adnrCostNoteBtc(String cost) {
    return 'Los dominios BTC cuestan $cost VFX más la comisión de la transacción.';
  }

  @override
  String get adnrNoDomain => 'Sin dominio';

  @override
  String get adnrCreateDomain => 'Crear dominio';

  @override
  String get adnrTransfer => 'Transferir';

  @override
  String get adnrDelete => 'Eliminar';

  @override
  String get adnrCreatePending => 'Creación pendiente';

  @override
  String get adnrTransferPending => 'Transferencia pendiente';

  @override
  String get adnrDeletePending => 'Eliminación pendiente';

  @override
  String get adnrVfxDomainBadge => 'Dominio VFX';

  @override
  String get adnrBtcDomainBadge => 'Dominio BTC';

  @override
  String get adnrVfxDomainPending => 'Dominio VFX pendiente';

  @override
  String get adnrVfxDomainTransferPending => 'Transferencia de dominio VFX pendiente';

  @override
  String get adnrVfxDomainDeletePending => 'Eliminación de dominio VFX pendiente';

  @override
  String get adnrCreateVfxOnAccount => 'Crea un dominio VFX como alias de la dirección de tu cuenta para recibir fondos.';

  @override
  String get adnrTransferDomainTitle => 'Transferir dominio VFX';

  @override
  String adnrTransferDomainBody(String cost) {
    return 'Transferir un dominio VFX cuesta $cost VFX.';
  }

  @override
  String get adnrAddressFieldLabel => 'Dirección';

  @override
  String get adnrInsufficientFundsTransfer => 'No hay suficiente VFX en esta cuenta para crear una transacción.';

  @override
  String adnrInsufficientFundsCreateBtc(String cost) {
    return 'No hay suficiente VFX en tu cuenta para crear un dominio BTC. Se requieren $cost VFX (más la comisión de TX).';
  }

  @override
  String adnrInsufficientFundsCreateVfx(String cost) {
    return 'No hay suficiente VFX en esta cuenta para crear un dominio VFX. Se requieren $cost VFX (más la comisión de TX).';
  }

  @override
  String adnrInsufficientFundsCreateInWallet(String cost) {
    return 'No hay suficiente VFX en esta billetera para transferir un dominio VFX. Se requieren $cost VFX (más la comisión de TX).';
  }

  @override
  String get adnrInsufficientFundsDeleteInWallet => 'No hay suficiente VFX en esta billetera para eliminar un dominio VFX.';

  @override
  String get adnrTxBroadcastedToast => 'Transacción de dominio VFX transmitida. Revisa el registro para ver el hash.';

  @override
  String get adnrBtcTxBroadcastedToast => 'Transacción de dominio BTC transmitida. Revisa el registro para ver el hash.';

  @override
  String get adnrTransferTxBroadcastedToast => 'Transacción de transferencia de dominio VFX transmitida. Revisa los registros para el hash de tx';

  @override
  String get adnrDeleteTxBroadcastedToast => 'Transacción de eliminación de dominio VFX transmitida. Revisa los registros para el hash de tx';

  @override
  String get adnrDeleteTitle => '¿Eliminar dominio VFX?';

  @override
  String get adnrFundAccountTitle => 'Financiar cuenta';

  @override
  String get adnrFundCopyAddress => 'Copiar dirección';

  @override
  String get adnrAddressCopiedToast => 'Dirección copiada al portapapeles.';

  @override
  String get adnrFundsSentTitle => 'Fondos enviados';

  @override
  String adnrFundsSentBody(String amount, String address) {
    return 'Se enviaron $amount VFX a $address.\n\nEspera a que la transacción se refleje y luego podrás obtener tu dominio.';
  }

  @override
  String get adnrCreateDialogTitleVfx => 'Nuevo dominio VFX';

  @override
  String get adnrCreateDialogTitleBtc => 'Nuevo dominio BTC';

  @override
  String adnrCreateDialogCostVfx(String cost) {
    return 'Los dominios VFX cuestan $cost VFX.';
  }

  @override
  String adnrCreateDialogCostBtc(String cost) {
    return 'Los dominios BTC cuestan $cost VFX.';
  }

  @override
  String get adnrCreateDialogSuffixHelpVfx => 'Tu dominio solo debe contener letras y números, y se le agregará automáticamente \".vfx\" al verificarse';

  @override
  String get adnrCreateDialogSuffixHelpBtc => 'Tu dominio solo debe contener letras y números, y se le agregará automáticamente \".btc\" al verificarse';

  @override
  String get adnrDomainNameLabel => 'Nombre del dominio';

  @override
  String get adnrCreateButton => 'Crear';

  @override
  String adnrFaucetRequiredTitle(String cost) {
    return 'Se requieren $cost VFX';
  }

  @override
  String adnrFaucetRequiredBody(String cost) {
    return 'Crear un dominio BTC tiene un costo de $cost VFX (más la comisión de TX).\n\nLa comunidad ha asignado algo de VFX para reducir la barrera de entrada y probar esta función. Para evitar abusos, se requiere un número de teléfono para una autorización por SMS. Solo se almacenará un hash de tu número de teléfono.\n\n¿Quieres continuar?';
  }

  @override
  String get adnrFaucetContinue => 'Continuar';

  @override
  String get adnrFaucetNoThanks => 'No, gracias';

  @override
  String get adnrFaucetTitle => 'Faucet de VFX';

  @override
  String get adnrFaucetWaitToast => 'Espera a que llegue tu saldo antes de continuar.';

  @override
  String get adnrMaxLengthToast => 'El máximo de caracteres del dominio es 65';

  @override
  String adnrAlreadyExistsToast(String currency) {
    return 'Este dominio $currency ya existe';
  }

  @override
  String get adnrNoBtcAddress => 'No se encontró dirección BTC';

  @override
  String get adnrNoBtcWif => 'No se encontró clave privada WIF de BTC';

  @override
  String get adnrNoAccountToast => 'Sin cuenta';

  @override
  String adnrLogTransferEntry(String hash) {
    return 'Transacción de transferencia de dominio VFX transmitida. Hash de TX: $hash';
  }

  @override
  String adnrLogDeleteEntry(String hash) {
    return 'Transacción de eliminación de dominio VFX transmitida. Hash de TX: $hash';
  }

  @override
  String adnrLogCreateEntry(String hash) {
    return 'Transacción de creación de ADNR transmitida. Hash de TX: $hash';
  }

  @override
  String get nftListTitle => 'NFTs';

  @override
  String get nftImportLabel => 'Importar NFT';

  @override
  String get nftImportPromptTitle => 'Identificador del contrato inteligente';

  @override
  String get nftImportPromptBody => 'Pega el identificador único del contrato inteligente.';

  @override
  String get nftImportFieldLabel => 'Identificador';

  @override
  String get nftImportedToast => 'Contrato inteligente importado de la red';

  @override
  String get nftTabMyNfts => 'Mis NFTs';

  @override
  String get nftTabManageMinted => 'Administrar NFTs emitidos';

  @override
  String get nftBadgeTransferred => 'Transferido';

  @override
  String get nftBadgeListed => 'Listado';

  @override
  String get nftSaleInProgress => 'Venta en curso...';

  @override
  String get nftBurnedOverlay => 'Quemado';

  @override
  String get nftLockedBadge => 'NFT bloqueado';

  @override
  String get nftTransferringDefault => 'Transfiriendo...';

  @override
  String get nftMediaUploadProgress => 'Progreso de carga de contenido';

  @override
  String get nftCopyUrl => 'Copiar URL';

  @override
  String get nftUrlCopiedToast => 'URL copiada al portapapeles';

  @override
  String get nftQrSave => 'Guardar';

  @override
  String get nftQrOpen => 'Abrir';

  @override
  String get nftLearnMoreCancel => 'Cancelar';

  @override
  String get nftLearnMoreCreate => 'Crear';

  @override
  String get nftDetailFallback => 'NFT';

  @override
  String get nftMinterAddressLabel => 'Dirección del emisor';

  @override
  String get nftPropertiesHeading => 'Propiedades:';

  @override
  String get nftFeaturesHeading => 'Características:';

  @override
  String get nftRevealEvolveStages => 'Revelar etapas de evolución';

  @override
  String get nftProveOwnership => 'Probar propiedad';

  @override
  String get nftTransfer => 'Transferir';

  @override
  String get nftSell => 'Vender';

  @override
  String get nftActivatingSoonToast => '¡Próximamente!';

  @override
  String get nftNoAccountSelectedToast => 'No se seleccionó ninguna cuenta';

  @override
  String get nftVaultCannotSellToast => 'Las cuentas de bóveda no pueden vender NFTs.';

  @override
  String get nftNotEnoughBalanceToast => 'Saldo insuficiente para la transacción';

  @override
  String get nftMediaNotFoundToast => 'No se encontraron los archivos de contenido en este equipo.';

  @override
  String get nftSellTitle => 'Vender NFT';

  @override
  String get nftSellAddressLabel => 'Dirección VFX';

  @override
  String get nftInvalidAddressToast => 'Dirección inválida';

  @override
  String get nftSellAmountTitle => 'Monto de venta';

  @override
  String get nftSellAmountLabel => 'Monto VFX)';

  @override
  String get nftSellInvalidAmountToast => 'Monto inválido';

  @override
  String get nftBackupUrlTitle => 'URL de respaldo (opcional)';

  @override
  String get nftBackupUrlLabel => 'URL (opcional)';

  @override
  String get nftConfirmSaleStartTitle => 'Confirmar inicio de venta';

  @override
  String get nftManage => 'Administrar';

  @override
  String get nftViewCode => 'Ver código';

  @override
  String get nftSyncMedia => 'Sincronizar contenido';

  @override
  String get nftBurn => 'Quemar';

  @override
  String get nftBurnTitle => '¿Quemar NFT?';

  @override
  String get nftTransferNow => 'Transferir ahora';

  @override
  String get nftDecrypt => 'Descifrar';

  @override
  String get nftDecrypted => 'Descifrado';

  @override
  String get nftMediaBackupUrl => 'URL de respaldo de contenido';

  @override
  String get nftEvolveTitle => '¿Evolucionar?';

  @override
  String get nftDevolveTitle => '¿Devolucionar?';

  @override
  String get nftEvolveSentToast => '¡Transacción de evolución enviada exitosamente!';

  @override
  String get nftDevolveSentToast => '¡Transacción de devolución enviada exitosamente!';

  @override
  String get nftEvolveSentTitle => 'Transacción de evolución enviada exitosamente';

  @override
  String get nftClose => 'Cerrar';

  @override
  String get nftViewLabel => 'Ver NFT';

  @override
  String get nftOwnedByMe => 'De mi propiedad';

  @override
  String get nftAssociate => 'Asociar';

  @override
  String get nftOpenFile => 'Abrir archivo';

  @override
  String nftPhaseNameLabel(String name) {
    return 'Nombre: $name';
  }

  @override
  String get nftEvolve => 'Evolucionar';

  @override
  String get scTitle => 'Contratos inteligentes';

  @override
  String get scMyTitle => 'Mis contratos inteligentes';

  @override
  String get scTemplatesTitle => 'Plantillas de contratos inteligentes';

  @override
  String get scTabCompiled => 'Compilados';

  @override
  String get scTabDrafts => 'Borradores';

  @override
  String get scNoDrafts => 'No se encontraron borradores de contratos inteligentes';

  @override
  String get scNoCompiled => 'No se encontraron contratos inteligentes';

  @override
  String get scCreateAndMintTitle => 'Crear un contrato inteligente y emitir';

  @override
  String get scCreateAndMintBody => 'Comienza con un contrato inteligente base y agrega características personalizadas';

  @override
  String get scMintCollectionTitle => 'Emitir colección de NFTs';

  @override
  String get scMintCollectionBody => 'Emite varios contratos inteligentes en una colección';

  @override
  String get scLaunchIdeTitle => 'Abrir IDE';

  @override
  String get scLaunchIdeBody => 'Abre el IDE en línea para escribir tu propio código Trillium para tu contrato inteligente';

  @override
  String get scChooseVfxToast => 'Elige una cuenta VFX para comenzar a crear un contrato inteligente.';

  @override
  String get scVaultCannotMintToast => 'Las cuentas de bóveda no pueden emitir contratos inteligentes';

  @override
  String get scTemplatesHeading => 'Elige un contrato inteligente y agrega características';

  @override
  String get scCreateButton => 'Crear';

  @override
  String get scLearnMore => 'Más información';

  @override
  String get tokenListTitle => 'Tokens fungibles';

  @override
  String get tokenCreateNew => 'Crear token nuevo';

  @override
  String get tokenCreateTitle => 'Crear token fungible';

  @override
  String get tokenTopicCreateTitle => 'Crear tema del token';

  @override
  String get tokenNotSupportedByVault => 'No compatible con cuenta de bóveda';

  @override
  String get tokenProveOwnership => 'Probar propiedad';

  @override
  String get tokenVoting => 'Votación';

  @override
  String get tokenViewTopics => 'Ver temas';

  @override
  String get tokenNoTopicsTitle => 'Sin temas';

  @override
  String get tokenNoTopicsBody => 'Este token aún no tiene temas de votación.';

  @override
  String get tokenListBans => 'Listar bloqueos';

  @override
  String get tokenBannedAddressesTitle => 'Direcciones bloqueadas';

  @override
  String get tokenScUidLabel => 'UID del contrato inteligente';

  @override
  String get tokenNameLabel => 'Nombre del token';

  @override
  String get tokenLifetimeCapLabel => 'Suministro histórico';

  @override
  String get tokenMintableLabel => 'Emitible';

  @override
  String get tokenOwnerLabel => 'Propietario';

  @override
  String get tokenTickerLabel => 'Ticker del token';

  @override
  String get tokenCirculatingSupplyLabel => 'Suministro circulante';

  @override
  String get tokenBurnedLabel => 'Quemado';

  @override
  String get tokenBurnableLabel => 'Quemable';

  @override
  String get tokenTopicCreatedLabel => 'Tema creado';

  @override
  String get tokenVotingEndsLabel => 'Finaliza la votación';

  @override
  String get tokenVoteYes => 'Votar sí';

  @override
  String get tokenVoteNo => 'Votar no';

  @override
  String get tokenConfirmVoteYes => 'Confirmar voto [SÍ]';

  @override
  String get tokenConfirmVoteNo => 'Confirmar voto [NO]';

  @override
  String get tokenNoOwnerToast => 'No se pudo obtener el propietario del token';

  @override
  String get tokenVoteCastedToast => 'Voto registrado';

  @override
  String get tokenVoteHistory => 'Historial de votos';

  @override
  String get tokenNoVotesToast => 'Sin votos';

  @override
  String tokenVoteBlockSubtitle(String height) {
    return 'Bloque $height';
  }

  @override
  String get tokenBanAddress => 'Bloquear dirección';

  @override
  String get tokenBanAddressTitle => 'Dirección a bloquear';

  @override
  String get tokenAddressFieldLabel => 'Dirección';

  @override
  String get tokenBanBroadcastedToast => 'Transacción de bloqueo de dirección transmitida';

  @override
  String get tokenBurn => 'Quemar';

  @override
  String get tokenNotBurnableToast => 'Este token no se puede quemar';

  @override
  String get tokenAmountToBurnTitle => 'Monto a quemar';

  @override
  String get tokenAmountLabel => 'Monto';

  @override
  String get tokenInvalidAmountToast => 'Monto inválido';

  @override
  String get tokenInsufficientBalanceToast => 'Saldo insuficiente para realizar esta transacción';

  @override
  String get tokenBurnBroadcastedToast => 'Transacción de quema de tokens transmitida';

  @override
  String get tokenChangeOwnership => 'Cambiar propiedad';

  @override
  String get tokenTransferToAddressTitle => 'Transferir a dirección';

  @override
  String get tokenToAddressLabel => 'Dirección destino';

  @override
  String get tokenOwnershipBroadcastedToast => 'Transacción de cambio de propiedad transmitida';

  @override
  String get tokenCreateButton => 'Crear token';

  @override
  String get tokenSearchHint => 'Buscar...';

  @override
  String get tokenPrevPage => 'Anterior';

  @override
  String get tokenNextPage => 'Siguiente';

  @override
  String get tokenMintTokens => 'Emitir tokens';

  @override
  String get tokenAmountToMintTitle => 'Monto a emitir';

  @override
  String get tokenMintBroadcastedToast => 'Transacción de emisión de tokens transmitida';

  @override
  String get tokenStateChangePendingToast => 'El cambio de estado del token está pendiente. Espera';

  @override
  String tokenAddressCopiedToast(String address) {
    return 'Dirección copiada al portapapeles ($address)';
  }

  @override
  String get tokenFormNameHint => 'MyToken';

  @override
  String get tokenFormTickerHint => 'ABC';

  @override
  String get tokenFormCreate => 'Crear';

  @override
  String get tokenFormCancel => 'Cancelar';

  @override
  String get tokenFormNoAccountSelectedToast => 'No se seleccionó ninguna cuenta';

  @override
  String get tokenFormIconRequiredToast => 'Se requiere imagen del ícono';

  @override
  String get tokenFormCompileMintTitle => '¿Compilar y emitir contrato inteligente del token?';

  @override
  String get tokenFormConfirmAddressTitle => 'Confirmar dirección';

  @override
  String get tokenFormStandByTitle => 'Espera un momento';

  @override
  String get tokenTransfer => 'Transferir';

  @override
  String get tokenAmountToTransferTitle => 'Monto a transferir';

  @override
  String get tokenTransferBroadcastedToast => 'Transacción de transferencia de tokens transmitida';

  @override
  String get tokenTransferTo => 'Transferir a';

  @override
  String tokenWebInsufficient(String address, String ticker) {
    return 'El saldo de $ticker de esta dirección ($address) es insuficiente.';
  }

  @override
  String get tokenCreateNewVotingTopic => 'Crear nuevo tema de votación';

  @override
  String get tokenCreateNewVotingTopicBody => 'Como propietario del token, puedes crear temas para que otros holders voten.';

  @override
  String tokenListBansWithCount(String count) {
    return 'Listar bloqueos ($count)';
  }

  @override
  String get dstAuctionsTitle => 'Subastas P2P';

  @override
  String get dstConnectToAuctionHouse => 'Conectar a casa de subastas';

  @override
  String get dstConnectToAuctionHouseBody => 'Conéctate a una casa de subastas remota para intercambiar NFTs.';

  @override
  String get dstManageMyAuctionHouse => 'Administrar mi casa de subastas';

  @override
  String get dstManageMyAuctionHouseBody => 'Administra la casa de subastas de tu cuenta e intercambia NFTs.';

  @override
  String get dstManageMyAuctionHouseBodyWeb => 'Administra la casa de subastas de tu billetera e intercambia NFTs.';

  @override
  String get dstMyAuctionHouseTitle => 'Mi casa de subastas';

  @override
  String get dstEditDetails => 'Editar detalles';

  @override
  String get dstDeleteShop => 'Eliminar tienda';

  @override
  String get dstDeleteCollection => 'Eliminar colección';

  @override
  String get dstImportShop => 'Importar tienda';

  @override
  String get dstImportShopAddressLabel => 'Tu dirección VFX';

  @override
  String get dstDiscardChanges => 'Descartar cambios';

  @override
  String get dstPublishUpdatesTitle => '¿Publicar actualizaciones?';

  @override
  String get dstCliRestartTitle => 'Se requiere reiniciar el CLI';

  @override
  String get dstAuctionActivity => 'Actividad de la subasta';

  @override
  String get dstCompleted => 'Completada';

  @override
  String dstCloseShopEditConfirm(String mode) {
    return '¿Seguro que quieres cerrar la pantalla de $mode de la tienda?';
  }

  @override
  String dstCloseStoreEditConfirm(String mode) {
    return '¿Seguro que quieres cerrar la pantalla de $mode de la tienda?';
  }

  @override
  String dstCloseCollectionEditConfirm(String mode) {
    return '¿Seguro que quieres cerrar la pantalla de $mode de la colección?';
  }

  @override
  String dstCloseListingEditConfirm(String mode) {
    return '¿Seguro que quieres cerrar la pantalla de $mode del listado?';
  }

  @override
  String get dstDiscardListingTitle => '¿Seguro que quieres descartar el listado?';

  @override
  String get dstModeEditing => 'edición';

  @override
  String get dstModeCreation => 'creación';

  @override
  String get shopAuctionHousesTitle => 'Casas de subastas';

  @override
  String get shopMyAuctionHousesTitle => 'Mis casas de subastas';

  @override
  String get shopUrlPromptTitle => 'URL de la tienda';

  @override
  String get shopUrlRequired => 'Se requiere la URL de la tienda';

  @override
  String get shopUrlLabel => 'Ingresa solo el nombre de la tienda';

  @override
  String get shopWalletNotSyncedTitle => 'Billetera no sincronizada';

  @override
  String get shopWalletNotSyncedBody => 'Como tu billetera no está sincronizada, puede haber problemas para ver los datos de esta tienda. ¿Continuar de todos modos?';

  @override
  String get shopConnectToShop => 'Conectar a una tienda';

  @override
  String get shopShareShop => 'Compartir tienda';

  @override
  String get shopShareCollection => 'Compartir colección';

  @override
  String get shopCreateListing => 'Crear listado';

  @override
  String get shopCreateCollection => 'Crear colección';

  @override
  String get shopPublished => 'Publicada';

  @override
  String get shopPublishShop => 'Publicar tienda';

  @override
  String get shopPublishShopTitle => '¿Publicar tienda?';

  @override
  String get shopDeleteShopTitle => '¿Eliminar tienda?';

  @override
  String get shopDeleteCollectionConfirm => '¿Seguro que quieres eliminar esta colección?';

  @override
  String get shopErrorTitle => 'Error';

  @override
  String get shopLoading => 'Cargando...';

  @override
  String get shopNoActiveListings => 'Sin listados activos';

  @override
  String get shopNoActiveCollections => 'Sin colecciones activas';

  @override
  String get shopSendSaleStartTx => 'Enviar TX de inicio de venta';

  @override
  String get shopSignIn => 'Iniciar sesión';

  @override
  String get shopStartTransaction => 'Iniciar transacción';

  @override
  String get shopSearchAuctionHouseHint => 'Busca casas de subastas...';

  @override
  String get shopBidSent => 'Enviada';

  @override
  String get shopBidReceived => 'Recibida';

  @override
  String get shopBidPurchased => 'Comprado';

  @override
  String get shopBidAccepted => 'Aceptada';

  @override
  String get shopBidRejected => 'Rechazada';

  @override
  String get shopResendBid => 'Reenviar oferta';

  @override
  String get shopPriceLabel => 'Precio';

  @override
  String get shopBuyNow => 'Comprar ahora';

  @override
  String get shopFloorPriceLabel => 'Precio mínimo';

  @override
  String get shopHighestBidLabel => 'Oferta más alta';

  @override
  String get shopBidNow => 'Ofertar ahora';

  @override
  String get shopDetailsLabel => 'Detalles';

  @override
  String get shopAuctionDetailsTitle => 'Detalles de la subasta';

  @override
  String get shopBidHistory => 'Historial de ofertas';

  @override
  String get paymentLinkTitle => 'Enlace de pago';

  @override
  String get paymentLinkHistory => 'Historial de enlaces de pago';

  @override
  String get paymentLinkNoneYet => 'Aún no hay enlaces de pago';

  @override
  String get paymentLinkIntro => 'Usa Butterfly para crear un enlace de pago, reclamable por cualquiera a quien le envíes el enlace.';

  @override
  String get paymentAmountLabel => 'Monto (VFX)';

  @override
  String get paymentAmountHint => 'Ingresa el monto';

  @override
  String get paymentMessageLabel => 'Mensaje (opcional)';

  @override
  String get paymentMessageHint => '¿Para qué es este pago?';

  @override
  String get paymentCreateLinkLabel => 'Crear enlace de pago';

  @override
  String get paymentAmountRequired => 'Se requiere el monto';

  @override
  String get paymentValidAmount => 'Ingresa un monto válido';

  @override
  String get paymentInsufficientBalance => 'Saldo insuficiente';

  @override
  String get paymentMinimumAmount => 'El monto mínimo es 0.0001 VFX';

  @override
  String paymentAvailableLabel(String amount) {
    return 'Disponible: $amount VFX';
  }

  @override
  String get paymentPayWithCryptoCom => 'Pagar con Crypto.com';

  @override
  String get paymentPayWithCard => 'Pagar con tarjeta de crédito';

  @override
  String get paymentCancel => 'Cancelar';

  @override
  String get navMenuDashboard => 'Panel';

  @override
  String get navMenuVaultAccounts => 'Cuentas de bóveda';

  @override
  String get navMenuSend => 'Enviar';

  @override
  String get navMenuReceive => 'Recibir';

  @override
  String get navMenuTransactions => 'Transacciones';

  @override
  String get navMenuValidator => 'Validador';

  @override
  String get navMenuDomains => 'Dominios VFX/BTC';

  @override
  String get navMenuTokenizeBitcoin => 'Tokenizar Bitcoin';

  @override
  String get navMenuSmartContracts => 'Contratos inteligentes';

  @override
  String get navMenuFungibleTokens => 'Tokens fungibles';

  @override
  String get navMenuNfts => 'NFTs';

  @override
  String get navMenuP2PAuctions => 'Subastas P2P';

  @override
  String get navMenuAccountRequiredToast => 'Se requiere una cuenta para acceder a esta sección.';

  @override
  String get navMenuLogout => 'Cerrar sesión';

  @override
  String get navAddAccount => 'Agregar cuenta';

  @override
  String get statusUpdateAvailable => 'Actualización disponible';

  @override
  String get statusBlockchainVersion => 'Versión de blockchain';

  @override
  String get statusCliVersion => 'Versión de CLI';

  @override
  String get statusBlockHeight => 'Altura del bloque';

  @override
  String get statusPeers => 'Pares (Entrada / Salida)';

  @override
  String get statusWalletStarted => 'Billetera iniciada';

  @override
  String get statusNetworkMetrics => 'Métricas de red';

  @override
  String get statusCliInactive => 'CLI inactivo';

  @override
  String get statusLoadingLabel => 'Cargando';

  @override
  String get statusVfxOnline => 'VFX en línea';

  @override
  String get statusVfxOffline => 'VFX fuera de línea';

  @override
  String get statusBtcLoading => 'BTC cargando';

  @override
  String get statusBtcOnline => 'BTC en línea';

  @override
  String get statusBtcOffline => 'BTC fuera de línea';

  @override
  String get webNoWalletDetected => 'No se detectó billetera.';

  @override
  String get webSetupWallet => 'Configurar billetera';

  @override
  String get webPendingActivation => 'Activación pendiente';

  @override
  String get webActivateNow => 'Activar ahora';

  @override
  String get webRestoreVaultAccount => 'Restaurar cuenta de bóveda';

  @override
  String get webRestoreCodeLabel => 'Código de restauración';

  @override
  String get webVaultRestoredToast => 'Cuenta de bóveda restaurada';

  @override
  String get webRecover => 'Recuperar';

  @override
  String get webRecoverFundsTitle => 'Recuperar fondos y NFTs';

  @override
  String get webRecoveryBroadcasted => 'Transacción de recuperación transmitida.';

  @override
  String get webCallback => 'Devolver';

  @override
  String get webCallbackTitle => 'Devolver transacción';

  @override
  String get webCallbackBroadcasted => 'TX de devolución transmitida';

  @override
  String get webRevealPrivateKeyTitle => '¿Revelar clave privada?';

  @override
  String webAddressCopiedToast(String address) {
    return 'Dirección $address copiada al portapapeles';
  }

  @override
  String get webCurrencyAll => 'Todas';

  @override
  String get webCurrencyVfx => 'VFX';

  @override
  String get webCurrencyVault => 'Bóveda';

  @override
  String get webCurrencyBtc => 'BTC';

  @override
  String get webFundAccount => 'Financiar cuenta';

  @override
  String get webFundVaultTitle => 'Financia tu cuenta de bóveda';

  @override
  String get webAutoActivateTitle => '¿Activar automáticamente?';

  @override
  String get keygenImportWalletTitle => 'Importar billetera';

  @override
  String get keygenPrivateKeyLabel => 'Clave privada';

  @override
  String get keygenEmailAddressTitle => 'Correo electrónico';

  @override
  String get keygenEmailLabel => 'Correo';

  @override
  String get keygenRecoveryMnemonicTitle => 'Ingresa el mnemónico de recuperación';

  @override
  String get keygenRecoveryMnemonicLabel => 'Mnemónico de recuperación';

  @override
  String get keygenKeyGeneratedTitle => 'Clave generada';

  @override
  String get keygenKeyGeneratedBody => 'Aquí están los detalles de tu cuenta. Asegúrate de respaldar tu clave privada en un lugar seguro.';

  @override
  String get keygenAddressLabel => 'Dirección';

  @override
  String get keygenMnemonicCopiedToast => 'Mnemónico copiado al portapapeles';

  @override
  String get keygenPublicKeyCopiedToast => 'Clave pública copiada al portapapeles';

  @override
  String get keygenPrivateKeyCopiedToast => 'Clave privada copiada al portapapeles';

  @override
  String get keygenDone => 'Listo';

  @override
  String get keygenImportPrivateKey => 'Importar clave privada';

  @override
  String get keygenGenerateKeypair => 'Generar par de claves';

  @override
  String get keygenRecoverAccount => 'Recuperar cuenta';

  @override
  String get votingTitle => 'Temas de votación de validadores';

  @override
  String get votingCreateTopic => 'Crear tema';

  @override
  String get votingTabActive => 'Activos';

  @override
  String get votingTabInactive => 'Inactivos';

  @override
  String get votingTabVoted => 'Votados';

  @override
  String get votingTabNotVoted => 'No votados';

  @override
  String get votingTabAll => 'Todos';

  @override
  String get votingTabMyTopics => 'Mis temas';

  @override
  String get votingCreateTopicTitle => 'Crear tema';

  @override
  String get votingError => 'Error';

  @override
  String get chatTitle => 'Chats';

  @override
  String get chatTitleSingle => 'Chat';

  @override
  String chatChattingWith(String name) {
    return 'Chateando con $name';
  }

  @override
  String chatWithAddress(String address) {
    return 'Chat con $address';
  }

  @override
  String get chatNoChats => 'Sin chats';

  @override
  String get chatSendHint => 'Enviar mensaje...';

  @override
  String get chatDeleteThread => 'Eliminar hilo de chat';

  @override
  String get chatErrorTitle => 'Error';

  @override
  String get beaconTitle => 'Beacons';

  @override
  String get beaconAddRemote => 'Agregar beacon remoto';

  @override
  String get beaconCreateHost => 'Crear / Hospedar beacon';

  @override
  String get beaconAddTitle => 'Agregar beacon';

  @override
  String get beaconCreateTitle => 'Crear beacon';

  @override
  String get beaconCreatedTitle => 'Beacon creado';

  @override
  String get beaconNameLabel => 'Nombre del beacon';

  @override
  String get beaconIpLabel => 'Dirección IP';

  @override
  String get beaconPortLabel => 'Puerto (deja en blanco para usar el predeterminado)';

  @override
  String get beaconRetainDaysLabel => 'Días para retener archivos (0 para ilimitado)';

  @override
  String get beaconMakePrivate => 'Hacer privado';

  @override
  String get beaconAutoDelete => 'Eliminar automáticamente tras la descarga';

  @override
  String get beaconCancel => 'Cancelar';

  @override
  String get beaconAdd => 'Agregar';

  @override
  String get beaconCreate => 'Crear';

  @override
  String get beaconRemove => 'Eliminar';

  @override
  String get beaconRemoveTitle => 'Eliminar beacon';

  @override
  String get beaconNoBeacons => 'Sin beacons';

  @override
  String get beaconRemoteBadge => 'Remoto';

  @override
  String get faucetTitle => 'Faucet de VFX';

  @override
  String get faucetChooseAccount => 'Elige una cuenta VFX para continuar';

  @override
  String get faucetVerificationCodeLabel => 'Código de verificación';

  @override
  String get faucetVerify => 'Verificar';

  @override
  String get faucetAmountLabel => 'Monto';

  @override
  String faucetAmountSuffix(String amount) {
    return 'Monto: $amount VFX';
  }

  @override
  String get faucetPhoneLabel => 'Número de teléfono';

  @override
  String get faucetCancel => 'Cancelar';

  @override
  String get faucetRequestVfx => 'Solicitar VFX';

  @override
  String get encryptUnlockedToast => '¡Cuenta desbloqueada!';

  @override
  String get encryptIncorrectPasswordToast => 'Contraseña de descifrado de cuenta incorrecta';

  @override
  String get encryptPasswordHint => 'Contraseña de la cuenta';

  @override
  String get motherDashboardTitle => 'Panel de MOTHER';

  @override
  String get motherAddHostTitle => 'Agregar host';

  @override
  String get motherAddHostBody => 'Configura la dirección IP y la contraseña de tu HOST de MOTHER.';

  @override
  String get motherIpHostLabel => 'Dirección IP del HOST';

  @override
  String get motherPasswordHostLabel => 'Contraseña del HOST';

  @override
  String get motherHostNameLabel => 'Nombre del host';

  @override
  String get motherCreatePasswordLabel => 'Crear contraseña';

  @override
  String get motherCliRestartTitle => 'Se requiere reiniciar el CLI';

  @override
  String get motherChildBalance => 'Saldo';

  @override
  String get motherChildIpAddress => 'Dirección IP';

  @override
  String get motherChildBlockHeight => 'Altura del bloque';

  @override
  String get motherChildIsValidating => '¿Está validando?';

  @override
  String get motherChildIsConnected => '¿Conectado a Mother?';

  @override
  String get motherOpenInExplorer => 'Abrir en el explorador';

  @override
  String get motherClose => 'Cerrar';

  @override
  String get motherLaunchHost => 'Iniciar MOTHER';

  @override
  String get motherStopHost => 'Detener host';

  @override
  String get motherStopHostConfirmTitle => '¿Detener host de MOTHER?';

  @override
  String get motherSetWalletRemote => 'Establecer billetera como remota';

  @override
  String get motherStopRemote => 'Detener remoto';

  @override
  String get adjudicatorTitle => 'Adjudicator';

  @override
  String get adjudicatorNoAccountSelected => 'Ninguna cuenta seleccionada';

  @override
  String get adjudicatorStart => 'Iniciar adjudicación';

  @override
  String get adjudicatorStop => 'Detener adjudicación';

  @override
  String adjudicatorIsAdjudicating(String label) {
    return '$label  está adjudicando...';
  }

  @override
  String adjudicatorPortOpen(String port) {
    return '¡El puerto $port está abierto!';
  }

  @override
  String adjudicatorPortClosed(String port) {
    return 'El puerto $port NO está abierto. Configura tu firewall.';
  }

  @override
  String get datanodeTitle => 'Datanode';

  @override
  String get datanodeActivatingSoon => 'Activación próxima.';

  @override
  String get operationsTitle => 'Operaciones';

  @override
  String get operationsActivityLog => 'Registro de actividad';

  @override
  String get operationsStatus => 'Estado';

  @override
  String get operationsDocs => 'Documentación';

  @override
  String get operationsBlockchainVersion => 'Versión de blockchain';

  @override
  String get operationsCliVersion => 'Versión del CLI';

  @override
  String get operationsBlockHeight => 'Altura de bloque';

  @override
  String get operationsPeers => 'Pares (Entrada / Salida)';

  @override
  String get operationsWalletStarted => 'Billetera iniciada';

  @override
  String get operationsNetworkMetrics => 'Métricas de red';

  @override
  String get operationsViewMetrics => 'Ver métricas';

  @override
  String operationsActiveValidators(String value) {
    return 'Validadores activos: $value';
  }

  @override
  String get votingMustBeValidatorToCreate => 'Tu cuenta activa debe ser un validador para crear un tema.';

  @override
  String get votingOnlyOneActive => 'Solo se permite un tema activo por dirección.';

  @override
  String get votingBalanceRequired => 'Se requiere un saldo';

  @override
  String get votingInsufficientForValidate => 'El saldo no será suficiente para validar debido al costo de crear un tema (1 VFX + comisión)';

  @override
  String get votingCategoryLabel => 'Categoría';

  @override
  String get votingEndsLabel => 'Fin de votación';

  @override
  String get votingTopicNameLabel => 'Nombre del tema';

  @override
  String get votingTopicDescriptionLabel => 'Descripción del tema';

  @override
  String get votingCharLimit128 => 'Límite de 128 caracteres';

  @override
  String get votingCharLimit1600 => 'Límite de 1600 caracteres incluidos los enlaces proporcionados';

  @override
  String get votingDiscardTitle => 'Descartar';

  @override
  String get votingDiscardBody => '¿Seguro que quieres descartar este nuevo tema?';

  @override
  String votingCreateTopicConfirmBody(String cost) {
    return 'Hay un costo de $cost VFX para crear un tema.';
  }

  @override
  String get votingCreateAction => 'Crear';

  @override
  String get votingTopicCreatedToast => 'Tema creado';

  @override
  String get votingSearchHint => 'Buscar...';

  @override
  String votingEndedOn(String date) {
    return 'La votación finalizó el $date.';
  }

  @override
  String get votingMustHaveAccountToVote => 'Debes tener una cuenta seleccionada para votar.';

  @override
  String get votingMustBeValidatorToVote => 'Debes ser un validador para votar.';

  @override
  String votingAlreadyVotedPending(String label) {
    return 'Votaste $label. La transacción está pendiente.';
  }

  @override
  String votingAlreadyVoted(String label, String block) {
    return 'Votaste $label en el bloque $block';
  }

  @override
  String get votingPendingTx => 'Transacción de voto pendiente.';

  @override
  String get votingCastYourVote => 'Emite tu voto';

  @override
  String get votingVoteYes => 'Votar Sí';

  @override
  String get votingVoteNo => 'Votar No';

  @override
  String get votingConfirmYesTitle => 'Confirmar voto [SÍ]';

  @override
  String get votingConfirmYesBody => '¿Seguro que quieres votar SÍ en este tema?';

  @override
  String get votingConfirmYesAction => 'Votar SÍ';

  @override
  String get votingConfirmNoTitle => 'Confirmar voto [NO]';

  @override
  String get votingConfirmNoBody => '¿Seguro que quieres votar NO en este tema?';

  @override
  String get votingConfirmNoAction => 'Votar NO';

  @override
  String votingEndsAt(String date) {
    return 'La votación finaliza el $date.';
  }

  @override
  String get votingNoVotesYet => 'Aún no hay votos.';

  @override
  String get votingVoteCounts => 'Conteo de votos';

  @override
  String get votingVotesYes => 'Votos Sí';

  @override
  String get votingVotesNo => 'Votos No';

  @override
  String get votingTotalVotes => 'Votos totales';

  @override
  String get votingPercentages => 'Porcentajes';

  @override
  String get votingResult => 'Resultado';

  @override
  String get votingInProgress => 'En curso';

  @override
  String get votingPass => 'Aprobada';

  @override
  String get votingFail => 'Rechazada';

  @override
  String get votingShowHistory => 'Mostrar historial';

  @override
  String get votingTopicCreatedLabel => 'Tema creado';

  @override
  String votingBlockHeightDetail(String value) {
    return 'Altura de bloque: $value';
  }

  @override
  String votingTopicOwner(String address) {
    return 'Propietario del tema: $address';
  }

  @override
  String votingUid(String uid) {
    return 'UID: $uid';
  }

  @override
  String get votingCatGeneral => 'General';

  @override
  String get votingCatCodeChange => 'Cambio de código';

  @override
  String get votingCatAddDeveloper => 'Agregar desarrollador';

  @override
  String get votingCatRemoveDeveloper => 'Eliminar desarrollador';

  @override
  String get votingCatNetworkChange => 'Cambio de red';

  @override
  String get votingCatAdjVoteIn => 'Voto a favor de Adj';

  @override
  String get votingCatAdjVoteOut => 'Voto en contra de Adj';

  @override
  String get votingCatValidatorChange => 'Cambio de validador';

  @override
  String get votingCatBlockModify => 'Modificar bloque';

  @override
  String get votingCatTransactionModify => 'Modificar transacción';

  @override
  String get votingCatBalanceCorrection => 'Corrección de saldo';

  @override
  String get votingCatHackOrExploit => 'Corrección de hackeo o exploit';

  @override
  String get votingCatOther => 'Otro';

  @override
  String get votingDays30 => '30 días';

  @override
  String get votingDays60 => '60 días';

  @override
  String get votingDays90 => '90 días';

  @override
  String get votingDays180 => '180 días';

  @override
  String get votingProviderOnlineCloud => 'VPS en la nube';

  @override
  String get votingProviderOnlineDedicated => 'Dedicada en línea';

  @override
  String get votingProviderLocalDedicated => 'Dedicada local';

  @override
  String get votingProviderHomeMachine => 'Máquina de hogar';

  @override
  String get votingProviderOfficeMachine => 'Máquina de oficina';

  @override
  String get votingOsLinux => 'Linux';

  @override
  String get votingOsWindows => 'Windows';

  @override
  String get votingOsMac => 'Mac';

  @override
  String get beaconRemoveBody => '¿Seguro que quieres eliminar este beacon?';

  @override
  String get beaconRemoveSelfBody => '¿Seguro que quieres eliminar este beacon?\n\nSe requiere reiniciar el CLI.';

  @override
  String get beaconRemoveAndRestart => 'Eliminar y reiniciar CLI';

  @override
  String get beaconCreateBodyExplanation => 'Crea un beacon si quieres ser propietario del relay de archivos. Configura tu billetera como un beacon para participar en la transferencia de archivos en la red VFX. El nombre es un nombre amigable visible solo para ti. Puedes configurar un puerto específico o usar la configuración predeterminada. También puedes configurar si tu beacon es privado y por cuánto tiempo deben permanecer en caché los archivos.';

  @override
  String get beaconAddBodyExplanation => 'Agrega un beacon existente a los nodos externos para usar ese relay en lugar de los predeterminados en la red VFX. Configura tu billetera para usar un beacon remoto para la transferencia de archivos en lugar de los beacons predeterminados de la red VFX. Necesitarás conocer la dirección IP del beacon remoto. Si ese beacon usa un puerto distinto al predeterminado, también deberás indicarlo. El nombre del beacon es un nombre amigable visible solo para ti.';

  @override
  String get beaconCreatedBody => 'Se requiere reiniciar el CLI para que esto tenga efecto.\n\n¿Reiniciar ahora?';

  @override
  String get beaconActiveBadge => 'Activo';

  @override
  String get beaconInactiveBadge => 'Inactivo';

  @override
  String get beaconErrorOnePerWallet => 'Solo se permite un beacon por billetera.';

  @override
  String get beaconRestartNow => 'Reiniciar';

  @override
  String get beaconLater => 'Más tarde';

  @override
  String get beaconAutoDeleteAssets => 'Eliminar archivos automáticamente';

  @override
  String get beaconAssetCache => 'Caché de archivos';

  @override
  String get beaconCacheInfinite => 'Infinito';

  @override
  String get beaconPrivateLabel => '[Privado]';

  @override
  String get navMenuPayWithButterfly => 'Pagar con Butterfly';

  @override
  String get navMenuCryptoCom => 'Crypto.com';

  @override
  String get navMenuOperations => 'Operaciones';

  @override
  String get navMenuSignOut => 'Cerrar sesión';

  @override
  String get navMenuVaultAccountSingular => 'Cuenta de bóveda';

  @override
  String get navSignOutTitle => 'Cerrar sesión';

  @override
  String get navSignOutBody => '¿Seguro que quieres cerrar sesión en la VFX Web Wallet?';

  @override
  String get navLatestTx => 'Última TX:';

  @override
  String get navViewAllTxs => 'Ver todas las Txs';

  @override
  String get navNoTransactions => 'Sin transacciones';

  @override
  String get navConfirmedStatus => 'Confirmada';

  @override
  String get navPendingStatus => 'Pendiente';

  @override
  String get navViewAddress => 'Ver\ndirección';

  @override
  String get navViewAddresses => 'Ver\ndirecciones';

  @override
  String get navNewAddress => 'Nueva\ndirección';

  @override
  String get navGetVfx => 'Obtener\nVFX';

  @override
  String get navGetBtc => 'Obtener\nBTC';

  @override
  String navAddressSingular(String count) {
    return '$count dirección';
  }

  @override
  String navAddressPlural(String count) {
    return '$count direcciones';
  }

  @override
  String navVaultAddressSingular(String count) {
    return '$count dirección de bóveda';
  }

  @override
  String navVaultAddressPlural(String count) {
    return '$count direcciones de bóveda';
  }

  @override
  String navAccountSingular(String count) {
    return '$count cuenta';
  }

  @override
  String navAccountPlural(String count) {
    return '$count cuentas';
  }

  @override
  String get navNoVfxAccounts => 'Sin cuentas VFX';

  @override
  String get navNoBtcAccounts => 'Sin cuentas BTC';

  @override
  String get navNoAccounts => 'Sin cuentas';

  @override
  String get navNew => 'NUEVO';

  @override
  String get webRevealPrivateKeyBody => '¿Seguro que quieres revelar tu clave privada?';

  @override
  String get webRevealPrivateKeyAccountBody => '¿Seguro que quieres revelar tu clave privada de esta cuenta?';

  @override
  String get webReveal => 'Revelar';

  @override
  String webFundVaultBody(String address) {
    return '¿Quieres enviar 5 VFX desde $address?';
  }

  @override
  String get webAutoActivateBody => '¿Quieres activar la cuenta automáticamente una vez que se complete el financiamiento?';

  @override
  String webSent5Vfx(String address) {
    return 'Se enviaron 5 VFX a $address';
  }

  @override
  String webRecoverFundsBody(String address) {
    return 'Esta es una función destructiva que revertirá todas las transacciones y archivos pendientes y moverá todo a esta dirección de recuperación:\n\n$address';
  }

  @override
  String get webProceed => 'Continuar';

  @override
  String get webRestoreVaultBody => 'Importar una cuenta de bóveda existente reemplazará la actual vinculada a tu inicio de sesión. Para revertir, puedes cerrar sesión y volver a iniciarla.\n\n¿Continuar?';

  @override
  String get webRestoreCodeBody => 'Pega tu CÓDIGO DE RESTAURACIÓN para importar tu cuenta de bóveda existente.';

  @override
  String get webCalledBack => 'Revertida';

  @override
  String get webCallbackBody => '¿Seguro que quieres revertir esta transacción?';

  @override
  String get webErrorTimestamp => 'Error al obtener la marca de tiempo';

  @override
  String get webErrorNonce => 'Error al obtener el nonce';

  @override
  String get webErrorFee => 'Error al procesar la comisión';

  @override
  String get webErrorHash => 'Error al procesar el hash';

  @override
  String get webErrorSignatureGen => 'Falló la generación de la firma.';

  @override
  String get webErrorSignatureInvalid => 'Firma no válida';

  @override
  String get webErrorTxInvalid => 'Transacción no válida';

  @override
  String get webErrorRecoverySig => 'Problema al generar RecoverySigScript';

  @override
  String get webSelectAccount => 'Seleccionar cuenta';

  @override
  String get webAddBtcAccount => 'Agregar cuenta BTC';

  @override
  String get webImportBtcWifTitle => 'Importar clave privada BTC WIF';

  @override
  String get webWifPrivateKey => 'Clave privada WIF';

  @override
  String get webImport => 'Importar';

  @override
  String get webBtcAccountImported => 'Cuenta BTC importada';

  @override
  String get webManageAccounts => 'Administrar cuentas';

  @override
  String get webDefaultAccount => 'Cuenta predeterminada';

  @override
  String webAccountN(String id) {
    return 'Cuenta $id';
  }

  @override
  String get webRenameAccountTitle => 'Renombrar cuenta';

  @override
  String get webAccountName => 'Nombre de la cuenta';

  @override
  String get webRenameAccountBody => '¿Cómo quieres llamar a esta cuenta?';

  @override
  String get webLockWallet => 'Bloquear billetera';

  @override
  String webForgetTitle(String id) {
    return 'Olvidar cuenta $id';
  }

  @override
  String get webForgetBody => '¿Seguro que quieres eliminar esta cuenta de tu billetera?';

  @override
  String get webForgetBodyLastAccount => '¿Seguro que quieres eliminar esta cuenta de tu billetera? Como no tienes otras cuentas, se cerrará tu sesión.';

  @override
  String get webForget => 'Olvidar';

  @override
  String get webForgetAndLogout => 'Olvidar y cerrar sesión';

  @override
  String get webBackupKeys => 'Respaldar claves';

  @override
  String get webSetActive => 'Establecer como activa';

  @override
  String get webScanCameraError => 'Error de cámara';

  @override
  String get webScanRetry => 'Reintentar';

  @override
  String get webScanScanning => 'Escaneando...';

  @override
  String get webScanCameraRequired => 'Se requiere acceso a la cámara para escanear códigos QR';

  @override
  String get webScanInstruction => 'Coloca el código QR dentro del marco para escanear';

  @override
  String webBalanceTooltip(String available, String locked, String total) {
    return 'Disponible: $available VFX\nBloqueado: $locked VFX \nTotal: $total RBX';
  }

  @override
  String get motherTitle => 'Monitor Of The Roster';

  @override
  String get motherDescription => 'MOTHER es una herramienta para monitorear el estado de tus validadores remotos.';

  @override
  String get motherStatusHeading => 'Estado';

  @override
  String motherIsHostRow(String value) {
    return 'Es Host: $value';
  }

  @override
  String motherIsRemoteRow(String value) {
    return 'Es Remote: $value';
  }

  @override
  String motherChildrenRow(String count) {
    return 'Hijos: $count';
  }

  @override
  String get motherYes => 'SÍ';

  @override
  String get motherNo => 'NO';

  @override
  String get motherChildYes => 'Sí';

  @override
  String get motherChildNo => 'No';

  @override
  String get motherUpdateHostInfo => 'Actualizar información del Host';

  @override
  String get motherSetWalletHost => 'Establecer billetera como Host';

  @override
  String get motherStop => 'Detener';

  @override
  String get motherStopHostBody => '¿Seguro que quieres detener esta billetera como host de MOTHER?';

  @override
  String get motherCliRestartBody => '¿Quieres reiniciar ahora?';

  @override
  String get motherStopRemoteBody => '¿Seguro que quieres eliminar este nodo como REMOTE?\n\nSe requerirá reiniciar el CLI.';

  @override
  String get motherStopRemoteAction => 'Detener Remote y reiniciar CLI';

  @override
  String get motherRemoteRemoved => 'El nodo REMOTE se eliminó de MOTHER';

  @override
  String get motherWhatIs => '¿Qué es MOTHER?';

  @override
  String motherInfoBody(String port) {
    return 'MOTHER es una herramienta para monitorear el estado de tus validadores remotos.\n\nPrimero debes configurar una de tus billeteras como HOST y luego agregar tu nodo adicional como REMOTE.\n\nAl agregar un nodo REMOTE, necesitarás conocer la dirección IP y la contraseña del HOST.\n\nUna vez completado, podrás ver un panel que rastrea toda la actividad de tus nodos desde una sola billetera.\n\nNota: debes tener el puerto \'$port\' abierto en la máquina HOST.';
  }

  @override
  String get motherIpRequired => 'Dirección IP requerida';

  @override
  String get motherPasswordRequired => 'Contraseña requerida';

  @override
  String get motherNameRequired => 'Nombre requerido';

  @override
  String motherPortNote(String port) {
    return 'Debes tener el puerto \'$port\' abierto en la máquina HOST.';
  }

  @override
  String get motherHostCreated => 'Host creado';

  @override
  String get motherOpenInBrowser => 'Abrir en el navegador';

  @override
  String get homeActionTokens => 'Tokens';

  @override
  String get homeActionTutorials => 'Tutoriales';

  @override
  String get homeActionGetHelp => 'Obtener\nAyuda';

  @override
  String get homeActionOpenExplorer => 'Abrir\nExplorador';

  @override
  String get homeActionVerifyOwner => 'Verificar\nPropietario';

  @override
  String get homeActionSignOut => 'Cerrar\nSesión';

  @override
  String get homeGetHelpTitle => 'Obtener ayuda';

  @override
  String get homeJoinDiscord => 'Unirse a Discord';

  @override
  String get homeVisitWebsite => 'Visitar sitio web';

  @override
  String get homeReadDocs => 'Leer documentación';

  @override
  String get homeValidateOwnership => 'Validar propiedad';

  @override
  String get homeValidateOwnershipBody => 'Pega la firma proporcionada por el propietario para validar su propiedad.';

  @override
  String get homeSignatureLabel => 'Firma';

  @override
  String get homeInvalidSignature => 'Firma de verificación de propiedad inválida';

  @override
  String get homeVerified => 'Verificado';

  @override
  String get homeNotVerified => 'No verificado';

  @override
  String get homeOwnershipVerified => 'Propiedad verificada';

  @override
  String get homeOwnershipNotVerified => 'Propiedad NO verificada';

  @override
  String get homeOwns => 'POSEE';

  @override
  String get homeDoesNotOwn => 'NO posee';

  @override
  String get webAddressesLabel => 'Direcciones';

  @override
  String get webVaultLabel => 'Bóveda';

  @override
  String get webRecoveredDeactivated => 'Recuperada y desactivada';

  @override
  String get webCopyAddressPopup => 'Copiar dirección';

  @override
  String get webRevealPrivateKeyPopup => 'Revelar clave privada';

  @override
  String webBlockHeight(String height) {
    return 'Bloque $height';
  }

  @override
  String webTokensCount(String count) {
    return '$count Tokens';
  }

  @override
  String get dashCopyAddress => 'Copiar\nDirección';

  @override
  String get dashVaultAddress => 'Dirección\nde bóveda';

  @override
  String get dashGetVfx => 'Obtener\nVFX';

  @override
  String get dashGetBtc => 'Obtener\nBTC';

  @override
  String get dashOffRampBtc => 'Vender\nBTC';

  @override
  String get dashVbtcTokens => 'Tokens\nvBTC';

  @override
  String get dashWhatsVbtc => '¿Qué es\nvBTC?';

  @override
  String get statusSuccess => 'Éxito';

  @override
  String txFromColonAddress(String address) {
    return 'De: $address';
  }

  @override
  String txToColonAddress(String address) {
    return 'Para: $address';
  }

  @override
  String get webAddressesAddressCopiedDot => 'Dirección copiada al portapapeles.';

  @override
  String get butterflyCreatePassword => 'Crear contraseña de Butterfly';

  @override
  String get butterflyPasswordMessage => 'Crea una contraseña para transferir tus credenciales a Butterfly de forma segura. Necesitarás ingresar esta misma contraseña en el sitio web de Butterfly.';

  @override
  String get butterflyLoginTitle => 'Iniciar sesión en Butterfly';

  @override
  String butterflyLoginBody(String address) {
    return 'Estás a punto de abrir Butterfly e iniciar sesión con:\n\n$address\n\n¿Continuar?';
  }

  @override
  String get butterflyOpenButton => 'Abrir Butterfly';

  @override
  String get butterflyNoWalletError => 'No se seleccionó ninguna billetera. Crea o importa una billetera primero.';

  @override
  String butterflyLoginUrlError(String error) {
    return 'Error al generar la URL de inicio de sesión: $error';
  }

  @override
  String get navPrivateKeyNotAvailable => 'Clave privada no disponible.';

  @override
  String get webAddAccount => 'Agregar cuenta';

  @override
  String get webLanguageLabel => 'Idioma';

  @override
  String get webYourAddress => 'Tu dirección';

  @override
  String get webYourDomain => 'Tu dominio';

  @override
  String get webCopyLink => 'Copiar\nEnlace';

  @override
  String get webQrCode => 'Código\nQR';

  @override
  String get webRequestFunds => 'Solicitar fondos';

  @override
  String get webRequestFundsBody => 'Genera un enlace para enviar a otro usuario.';

  @override
  String get webAmountToRequest => 'Monto a solicitar';

  @override
  String get webGenerateLink => 'Generar enlace';

  @override
  String get webRequestLinkCopied => 'Enlace de solicitud copiado al portapapeles';

  @override
  String webCopiedToClipboard(String value) {
    return '\'$value\' copiado al portapapeles';
  }

  @override
  String get webInvalidAmount => 'Monto inválido';

  @override
  String get segmentAll => 'Todas';

  @override
  String get segmentVault => 'Bóveda';

  @override
  String get dialogClose => 'Cerrar';

  @override
  String get dialogYes => 'Sí';

  @override
  String get dialogNo => 'No';

  @override
  String get dialogSubmit => 'Enviar';
}
