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

  @override
  String get govAdjAdditionalLinksLabel => 'Enlaces adicionales: ';

  @override
  String get govAdjBandwidthLabel => 'Ancho de banda (TB): ';

  @override
  String get govAdjBandwidthUnlimited => 'Ilimitado';

  @override
  String get govAdjCpuCoresLabel => 'Núcleos de CPU: ';

  @override
  String get govAdjCpuLabel => 'CPU: ';

  @override
  String get govAdjCpuThreadsLabel => 'Hilos de CPU: ';

  @override
  String get govAdjGithubLinkLabel => 'Enlace de Github: ';

  @override
  String get govAdjHdSizeLabel => 'Tamaño del disco: ';

  @override
  String get govAdjInternetDownLabel => 'Velocidad de bajada (Gbps): ';

  @override
  String get govAdjInternetUpLabel => 'Velocidad de subida (Gbps): ';

  @override
  String get govAdjIpAddressLabel => 'Dirección IP del adjudicador propuesto: ';

  @override
  String get govAdjMachineProviderLabel => 'Proveedor de la máquina: ';

  @override
  String get govAdjMachineTypeLabel => 'Tipo de máquina: ';

  @override
  String get govAdjOperatingSystemLabel => 'Sistema operativo: ';

  @override
  String get govAdjRamLabel => 'RAM (GB): ';

  @override
  String get govAdjReasonLabel => 'Razones para ser agregado como adjudicador: ';

  @override
  String get govAdjTechnicalBackgroundLabel => 'Experiencia técnica: ';

  @override
  String get govAdjVfxAddressLabel => 'Dirección VFX del adjudicador propuesto: ';

  @override
  String govVoteBlock(int height) {
    return 'Bloque $height';
  }

  @override
  String get hnavActivatingSoon => 'Se activará pronto.';

  @override
  String get hnavAgreeAndClose => 'Aceptar y cerrar';

  @override
  String get hnavAllMyTokens => 'Todos mis tokens';

  @override
  String hnavBackupKeysSubtitle(String vaultSuffix) {
    return 'Exporta y guarda todas las claves privadas y direcciones de tu VFX$vaultSuffix y BTC en un archivo de texto.';
  }

  @override
  String get hnavBackupLabel => 'Copia de seguridad';

  @override
  String get hnavBackupMediaSubtitle => 'Comprime y exporta los archivos multimedia de tus NFT.';

  @override
  String hnavBlockNumber(String height) {
    return 'Bloque $height';
  }

  @override
  String get hnavBtcInactive => 'BTC inactivo';

  @override
  String get hnavBtcLoading => 'Cargando BTC';

  @override
  String get hnavBtcLoginWarningBody => 'Ten en cuenta que si inicias sesión con una clave privada BTC, y esta clave se generó originalmente con un mecanismo de inicio de sesión distinto, los pares de claves de tu cuenta VFX/de bóveda no coincidirán con tu inicio de sesión anterior, ya que las claves privadas no son reversibles.';

  @override
  String get hnavBtcOffline => 'BTC sin conexión';

  @override
  String get hnavBtcOnline => 'BTC en línea';

  @override
  String get hnavCliInactive => 'CLI inactivo';

  @override
  String get hnavCloseRecoveryPhraseBody => '¿Seguro que copiaste tu frase de recuperación en un lugar seguro?';

  @override
  String get hnavCloseRecoveryPhraseTitle => '¿Cerrar la frase de recuperación?';

  @override
  String get hnavConfigAccountUnlockTime => 'Tiempo de desbloqueo de la cuenta';

  @override
  String get hnavConfigAllowedExtensionTypes => 'Tipos de extensión permitidos';

  @override
  String get hnavConfigApiCallUrl => 'URL de llamada a la API';

  @override
  String get hnavConfigApiPort => 'Puerto de la API';

  @override
  String get hnavConfigAutoDownloadNft => 'Descargar automáticamente los archivos de NFT';

  @override
  String get hnavConfigHeader => 'Configuración';

  @override
  String get hnavConfigIgnoreIncomingNfts => 'Ignorar NFTs entrantes';

  @override
  String get hnavConfigMotherAddress => 'Dirección Mother';

  @override
  String get hnavConfigMotherPassword => 'Contraseña Mother';

  @override
  String get hnavConfigNftTimeout => 'Tiempo de espera de NFT';

  @override
  String get hnavConfigPasswordClearTime => 'Tiempo para borrar la contraseña';

  @override
  String get hnavConfigRejectedExtensionTypes => 'Tipos de extensión de activos rechazados';

  @override
  String get hnavConfirmCreateMnemonicBody => '¿Seguro que quieres crear una cuenta con mnemónico?';

  @override
  String get hnavCopyRecoveryPhraseInstruction => 'Copia tu frase de recuperación en un lugar seguro.';

  @override
  String get hnavCopyToClipboard => 'Copiar al portapapeles';

  @override
  String get hnavCouldNotGenerateKeypair => 'No se pudo generar el par de claves';

  @override
  String get hnavCreateNewMnemonic => 'Crear mnemónico nuevo';

  @override
  String get hnavCurrencyAll => 'Todas';

  @override
  String get hnavDecryptAccountKeysBody => 'Ingresa la contraseña de esta cuenta para descifrar y ver sus claves privadas.';

  @override
  String get hnavDecryptionFailedCheckPassword => 'Falló el descifrado. Revisa tu contraseña.';

  @override
  String get hnavEncryptGeneratedMnemonicMessage => 'Esta contraseña cifrará las claves del mnemónico que generaste.';

  @override
  String get hnavEncryptImportedBtcPrivateKeyMessage => 'Esta contraseña cifrará tu clave privada BTC importada.';

  @override
  String get hnavEncryptImportedPrivateKeyMessage => 'Esta contraseña cifrará tu clave privada importada.';

  @override
  String get hnavEncryptRecoveredMnemonicMessage => 'Esta contraseña cifrará las claves del mnemónico que recuperaste.';

  @override
  String get hnavEnterAccountPasswordTitle => 'Ingresa la contraseña de la cuenta';

  @override
  String get hnavEnterBtcAddressHint => 'Ingresa tu dirección BTC';

  @override
  String get hnavEnterBtcPrivateKeyOrWif => 'Ingresa tu clave privada BTC o clave WIF:';

  @override
  String get hnavEnterPrivateKeyHint => 'Ingresa tu clave privada';

  @override
  String get hnavEnterWalletPasswordTitle => 'Ingresa la contraseña de la billetera';

  @override
  String get hnavExtensionDecryptPasswordBody => 'Ingresa la contraseña que usaste en la extensión VFX para descifrar tu clave privada.';

  @override
  String get hnavExtensionNotDetected => 'No se detectó la extensión VFX';

  @override
  String get hnavExtensionUnlockFirst => 'Primero desbloquea la billetera de tu extensión';

  @override
  String get hnavExtensionWebOnly => 'La extensión VFX solo está disponible en la web';

  @override
  String get hnavFailedDecryptAccountKeys => 'No se pudieron descifrar las claves de la cuenta. Revisa tu contraseña.';

  @override
  String get hnavFungibleToken => 'Token fungible';

  @override
  String hnavFungibleTokenWithBalance(String balance, String ticker) {
    return 'Token fungible ($balance $ticker)';
  }

  @override
  String get hnavHd12Words => '12 palabras';

  @override
  String get hnavHd24Words => '24 palabras';

  @override
  String get hnavHdAccountTitle => 'Cuenta HD';

  @override
  String get hnavHdCreateAccount => 'Crear cuenta HD';

  @override
  String get hnavHdEncryptedError => 'No puedes crear una cuenta HD con una billetera cifrada.';

  @override
  String get hnavHdExplanation1 => 'Al crear una cuenta HD, creas una función para recuperar tus claves privadas mediante una frase de recuperación.';

  @override
  String get hnavHdExplanation2 => 'Una vez generada, cualquier clave que crees usará esta frase como semilla para generar la clave privada. Por lo tanto, solo necesitarás recordar esto para recuperar tus claves de forma determinista.';

  @override
  String get hnavHdExplanation3 => 'Esta es una función avanzada y no se recomienda a menos que conozcas los conceptos de billeteras jerárquicas deterministas (HD).\n\nCualquier clave creada antes de esto no se podrá recuperar con esta frase, así que asegúrate de respaldarlas también.';

  @override
  String get hnavHdGenerateStrength => 'Generar con nivel de seguridad:';

  @override
  String get hnavIDontKnow => 'No lo sé';

  @override
  String get hnavImportBtcPrivateKeyOrWifTitle => 'Importar clave privada BTC o clave WIF';

  @override
  String get hnavInvalidBtcAddress => 'Dirección BTC inválida';

  @override
  String get hnavInvalidPrivateKeyOrWif => 'No es una clave privada ni una clave WIF válida. Debe tener 64 o 52 caracteres';

  @override
  String hnavIsAdjudicating(String label) {
    return '$label está adjudicando...';
  }

  @override
  String get hnavKeysBackedUpSuccess => 'Claves respaldadas exitosamente.';

  @override
  String get hnavMediaBackedUpSuccess => 'Multimedia respaldada exitosamente.';

  @override
  String get hnavMempool => 'Mempool';

  @override
  String get hnavMempoolEmpty => 'El mempool está vacío.';

  @override
  String get hnavMnemonicTitle => 'Mnemónico';

  @override
  String get hnavNoTokensEmptyState => 'No tienes tokens vBTC, tokens fungibles ni tokens no fungibles';

  @override
  String get hnavNoWalletDetected => 'No se detectó ninguna billetera.';

  @override
  String get hnavNonFungibleToken => 'Token no fungible';

  @override
  String get hnavNoticeTitle => 'Aviso';

  @override
  String get hnavPasteBtcAddress => 'Pega tu dirección BTC:';

  @override
  String hnavPortNotOpen(String port) {
    return 'El puerto $port NO está abierto. Configura tu firewall.';
  }

  @override
  String hnavPortOpen(String port) {
    return '¡El puerto $port está abierto!';
  }

  @override
  String get hnavProposalsVoting => 'Propuestas y votación';

  @override
  String get hnavRecoverFromMnemonic => 'Recuperar desde mnemónico';

  @override
  String get hnavRecoveryPhraseGeneratedTitle => 'Frase de recuperación generada';

  @override
  String get hnavRequestCancelled => 'Solicitud cancelada';

  @override
  String get hnavRequestTimedOut => 'La solicitud expiró';

  @override
  String get hnavReserveAccountsNotExported => 'Ten en cuenta que las cuentas de reserva/protegidas no se exportarán.';

  @override
  String get hnavRestoreHiddenBracket => '[Restaurar ocultas]';

  @override
  String get hnavResyncing => 'Resincronizando...';

  @override
  String get hnavRevealPrivateKeysPasswordMessage => 'Ingresa tu contraseña para revelar las claves privadas.';

  @override
  String get hnavRevealVaultKeysPasswordMessage => 'Ingresa tu contraseña para revelar las claves privadas de la cuenta de bóveda.';

  @override
  String get hnavSectionAccountSecurity => 'Seguridad de la cuenta';

  @override
  String get hnavSectionDiagnose => 'Diagnóstico';

  @override
  String get hnavSectionTokensNfts => 'Tokens / NFTs';

  @override
  String get hnavSectionValidator => 'Validador';

  @override
  String get hnavSelectAddressType => 'Selecciona tu tipo de dirección:';

  @override
  String get hnavSelectedBtcAccountTooltip => 'Cuenta BTC seleccionada';

  @override
  String get hnavSelectedVfxAddressTooltip => 'Dirección VFX seleccionada';

  @override
  String get hnavSetEncryptionPasswordTitle => 'Establecer contraseña de cifrado';

  @override
  String hnavShowKeysAccountDetailsBody(String currencySuffix) {
    return 'Aquí están los detalles de tu cuenta$currencySuffix. Asegúrate de respaldar tu clave privada en un lugar seguro.';
  }

  @override
  String get hnavSnapshotAllDone => '¡Todo listo!';

  @override
  String get hnavSnapshotDownloading => 'Descargando...';

  @override
  String hnavSnapshotDownloadingFile(String file) {
    return 'Descargando: $file';
  }

  @override
  String get hnavSnapshotError => 'Ocurrió un error. Reinicia e inténtalo de nuevo.';

  @override
  String get hnavSnapshotImported => 'Snapshot de la base de datos importado.';

  @override
  String get hnavSnapshotInitializing => 'Inicializando...';

  @override
  String get hnavSnapshotShuttingDown => 'Cerrando el CLI...';

  @override
  String get hnavSnapshotStartingUp => 'Iniciando el CLI ahora...';

  @override
  String get hnavStartAdjudicating => 'Iniciar adjudicación';

  @override
  String get hnavStopAdjudicating => 'Detener adjudicación';

  @override
  String get hnavSynced => 'Sincronizado';

  @override
  String get hnavSyncing => 'Sincronizando...';

  @override
  String get hnavValidating => 'Validando...';

  @override
  String get hnavVaultAccountDetailsBody => 'Aquí están los detalles de tu cuenta de bóveda. Asegúrate de respaldar tu clave privada en un lugar seguro.';

  @override
  String get hnavVaultAccountDetailsTitle => 'Detalles de la cuenta de bóveda';

  @override
  String get hnavVaultSuffix => ' de bóveda';

  @override
  String hnavVbtcTokenWithBalance(String balance) {
    return 'Token vBTC ($balance vBTC)';
  }

  @override
  String get hnavVfxCliLoading => 'Cargando CLI de VFX';

  @override
  String get hnavVfxCliOffline => 'CLI de VFX sin conexión';

  @override
  String get hnavVfxOnline => 'VFX en línea';

  @override
  String get hnavWalletPasswordLabel => 'Contraseña de la billetera';

  @override
  String get hnavWarningTitle => 'Advertencia';

  @override
  String get mktAddReservePrice => 'Agregar precio de reserva';

  @override
  String get mktAuction => 'Subasta';

  @override
  String mktAuctionActivityForTitle(String name) {
    return 'Actividad de subasta de $name';
  }

  @override
  String get mktAuctionAlreadyStartedToast => 'La subasta ya comenzó.';

  @override
  String get mktAuctionFloorPriceLabel => 'Precio base de la subasta';

  @override
  String get mktAuctionNotLiveToast => 'La subasta no está activa';

  @override
  String get mktAuctionOverToast => 'La subasta ha terminado';

  @override
  String get mktAuctionReservePriceLabel => 'Precio de reserva de la subasta';

  @override
  String get mktAuctionStartedDatesLocked => 'La subasta ya comenzó, por lo que no se pueden actualizar las fechas ni las horas.';

  @override
  String get mktAuctionStartedPricingLocked => 'La subasta ya comenzó, por lo que no se pueden actualizar los precios.';

  @override
  String get mktBidAmountLabel => 'Monto de la oferta (VFX)';

  @override
  String mktBidIncrementToast(String increment, String minimum) {
    return 'El incremento mínimo es de $increment VFX. Se requiere una oferta mayor que $minimum VFX.';
  }

  @override
  String get mktBidInsufficientBody => 'No tienes saldo suficiente para cubrir esta oferta.\n\n¿Quieres pagar con tarjeta de crédito u otro token cripto?';

  @override
  String mktBidMustBeGreaterFooter(String minimum) {
    return 'Debe ser mayor que $minimum VFX';
  }

  @override
  String mktBidMustBeGreaterToast(String price) {
    return 'Tu oferta debe ser mayor que la oferta más alta actual ($price VFX)';
  }

  @override
  String get mktBidSubmittedToast => 'Oferta enviada';

  @override
  String mktBuyNowConfirmBody(String price) {
    return '¿Seguro que quieres comprar ahora por $price VFX?';
  }

  @override
  String mktBuyNowInsufficientBody(String price) {
    return 'Este NFT tiene un precio de compra inmediata de $price VFX y no tienes saldo suficiente para cubrirlo.\n\n¿Quieres pagar con tarjeta de crédito u otro token cripto?';
  }

  @override
  String get mktBuyNowPriceLabel => 'Precio de compra inmediata';

  @override
  String get mktBuyNowTxBroadcastedTitle => 'Transacción de compra inmediata transmitida.';

  @override
  String get mktBuyNowTxBroadcastedToast => 'Transacción de compra inmediata transmitida. Espera a que el dueño de la tienda la acepte';

  @override
  String get mktChooseAddressTitle => 'Elige una dirección';

  @override
  String get mktCloseCreateListingTitle => '¿Seguro que quieres cerrar la pantalla de creación de la publicación?';

  @override
  String get mktCloseEditListingTitle => '¿Seguro que quieres cerrar la pantalla de edición de la publicación?';

  @override
  String get mktCollectionDeletedToast => 'Colección eliminada.';

  @override
  String get mktCollectionDescriptionLabel => 'Descripción de la colección';

  @override
  String get mktCollectionNameLabel => 'Nombre de la colección';

  @override
  String get mktCouldNotGenerateHashToast => 'No se pudo generar el hash';

  @override
  String get mktCouldNotGetFeeToast => 'No se pudo obtener la comisión';

  @override
  String get mktCouldNotGetNonceToast => 'No se pudo obtener el nonce';

  @override
  String get mktCouldNotGetTimestampToast => 'No se pudo obtener la marca de tiempo';

  @override
  String get mktCouldNotProduceSignatureToast => 'No se pudo generar la firma';

  @override
  String get mktCouldNotVerifyTransactionToast => 'No se pudo verificar la transacción';

  @override
  String get mktCreateAuctionHouseBody => 'Crea tu casa de subastas / galería y publícala en la red.\nLuego podrás crear colecciones y agregarles publicaciones.';

  @override
  String get mktDatesHeading => 'Fechas';

  @override
  String get mktDeleteChatThreadBody => '¿Seguro que quieres eliminar este hilo de chat?';

  @override
  String get mktDeleteChatThreadLocalBody => '¿Seguro que quieres eliminar este hilo de chat localmente?';

  @override
  String get mktDeleteListing => 'Eliminar publicación';

  @override
  String get mktDeleteStoreConfirmBody => '¿Seguro que quieres eliminar esta tienda?';

  @override
  String get mktEditCollection => 'Editar colección';

  @override
  String get mktEditListing => 'Editar publicación';

  @override
  String get mktEnableAuction => '¿Habilitar subasta?';

  @override
  String get mktEnableBuyNow => '¿Habilitar compra inmediata?';

  @override
  String get mktEndDateLabel => 'Fecha de fin';

  @override
  String get mktEndTimeLabel => 'Hora de fin';

  @override
  String get mktErrorOccurred => 'Ocurrió un error.';

  @override
  String get mktGalleryOnly => '¿Solo galería?';

  @override
  String get mktInsufficientBalanceTitle => 'Saldo insuficiente';

  @override
  String mktListingForTitle(String name) {
    return 'Publicación de $name';
  }

  @override
  String get mktNftAlreadyListedToast => 'Este NFT ya está publicado. Elige otro';

  @override
  String get mktNftColonLabel => 'NFT:';

  @override
  String mktNftNameLabel(String name) {
    return 'NFT: $name';
  }

  @override
  String get mktNoAccountToast => 'No hay cuenta';

  @override
  String get mktNoAuctionToast => 'No hay subasta';

  @override
  String get mktNoBalanceToast => 'Sin saldo';

  @override
  String get mktNoBidsYet => 'Aún no hay ofertas.';

  @override
  String get mktNoMessagesYet => 'Aún no hay mensajes';

  @override
  String get mktNoShopToast => 'No hay tienda';

  @override
  String get mktNoThreadToast => 'No hay hilo';

  @override
  String get mktNotEnoughBalanceToast => 'Saldo insuficiente.';

  @override
  String get mktNotEnoughBalanceValidatingToast => 'Saldo insuficiente porque estás validando.';

  @override
  String get mktNotNotifiedToast => 'No recibirás notificaciones. Puedes cambiar esta configuración en el panel si cambias de opinión.';

  @override
  String get mktOptionsHeading => 'Opciones';

  @override
  String get mktOwnersAddressLabel => 'Dirección del propietario';

  @override
  String get mktPayWithCardCryptoTitle => 'Pagar con tarjeta de crédito / cripto';

  @override
  String get mktPlaceBid => 'Hacer oferta';

  @override
  String mktPlaceBidConfirmBody(String amount) {
    return '¿Seguro que quieres hacer una oferta de $amount VFX?';
  }

  @override
  String get mktPresignProblemToast => 'Ocurrió un problema al prefirmar la transacción de venta. Inténtalo de nuevo';

  @override
  String get mktProblemOccurredToast => 'Ocurrió un problema';

  @override
  String get mktPublishLive => 'Publicar en vivo';

  @override
  String get mktReplaceNft => 'Reemplazar NFT';

  @override
  String get mktReservePriceLabel => 'Precio de reserva';

  @override
  String get mktSelectNft => 'Seleccionar NFT';

  @override
  String get mktSelectOwnerAddressHint => 'Selecciona una dirección de la lista para que sea el propietario de la tienda.';

  @override
  String get mktShopDescriptionLabel => 'Descripción de la tienda';

  @override
  String get mktShopIdentifierLabel => 'Identificador de la tienda';

  @override
  String get mktShopNameLabel => 'Nombre de la tienda';

  @override
  String get mktSignatureNotValidPrimaryToast => 'Firma no válida (primaria)';

  @override
  String get mktStartDateLabel => 'Fecha de inicio';

  @override
  String get mktStartTimeLabel => 'Hora de inicio';

  @override
  String get mktSubscribeUpdatesBody => 'Para que la web wallet pueda enviar notificaciones a los ganadores de subastas para firmar transacciones, se requiere una dirección de correo electrónico.';

  @override
  String get mktSubscribeUpdatesTitle => '¿Suscribirte para recibir novedades?';

  @override
  String get mktSubscribedToast => 'Suscrito';

  @override
  String get mktThirdPartySaleStartNote => 'Como esta casa de subastas está alojada en la Web Wallet de VFX, el vendedor deberá autorizar la transacción de inicio de venta. La verás en tu lista de transacciones una vez enviada.';

  @override
  String get mktTxBroadcastedToast => 'Transacción transmitida';

  @override
  String get mktWaitForFinalizeBody => 'Espera a que la transacción se finalice.';

  @override
  String get scwAddAFeature => 'Agregar una función';

  @override
  String get scwAddCreatorName => 'Agregar nombre del creador';

  @override
  String get scwAddDescription => 'Agregar descripción';

  @override
  String get scwAddEvolvingPhase => 'Agregar fase de evolución';

  @override
  String get scwAddName => 'Agregar nombre';

  @override
  String get scwAddProperty => 'Agregar propiedad';

  @override
  String get scwAddPropertyButton => 'Agregar propiedad';

  @override
  String get scwAddRoyalty => 'Agregar regalía';

  @override
  String get scwAddStat => 'Agregar estadística';

  @override
  String get scwAdditionalAssets => 'Activos adicionales';

  @override
  String get scwAllowVoting => 'Permitir votación';

  @override
  String get scwBeneficiaryAddressOptional => 'Dirección del beneficiario (opcional)';

  @override
  String get scwBlockHeightValue => 'Valor de altura de bloque';

  @override
  String get scwCantAddEvolveBody => 'Ya tienes una función de evolución en este contrato inteligente. Edita la función de evolución existente para agregar más etapas.';

  @override
  String get scwCantAddEvolveTitle => 'No se puede agregar evolución';

  @override
  String get scwCantAddMultiAssetBody => 'Ya tienes una función de multiactivo en este contrato inteligente. Edita la función de multiactivo existente para agregar más activos.';

  @override
  String get scwCantAddMultiAssetTitle => 'No se puede agregar multiactivo';

  @override
  String get scwCantAddRoyaltyBody => 'Ya tienes una función de regalía en este contrato inteligente.';

  @override
  String get scwCantAddRoyaltyTitle => 'No se puede agregar regalía';

  @override
  String get scwCantAddSoulBoundBody => 'Ya tienes una función de Soul Bound en este contrato inteligente.';

  @override
  String get scwCantAddSoulBoundTitle => 'No se puede agregar Soul Bound';

  @override
  String get scwChoose => 'Elegir';

  @override
  String get scwChooseAnAddress => 'Elige una dirección';

  @override
  String get scwCollectionDescription => 'Descripción de la colección';

  @override
  String get scwCollectionName => 'Nombre de la colección';

  @override
  String get scwCollectionThumbnail => 'Miniatura de la colección';

  @override
  String get scwCollectionWizard => 'Asistente de colección';

  @override
  String get scwColorProperty => 'Propiedad de color';

  @override
  String get scwCreateAndMintBody => 'Comienza con un contrato inteligente base y agrega funciones personalizadas';

  @override
  String get scwCreateAndMintTitle => 'Crear un contrato inteligente y emitir';

  @override
  String get scwCreateSmartContractTitle => 'Crear contrato inteligente';

  @override
  String get scwCreatorName => 'Nombre del creador';

  @override
  String get scwCreatorRetainedOwnership => 'Propiedad retenida del creador';

  @override
  String scwCreatorValue(String name) {
    return 'Creador: $name';
  }

  @override
  String get scwDeletePrimaryAssetBody => '¿Estás seguro de que quieres eliminar el activo principal?';

  @override
  String get scwDeletePrimaryAssetTitle => '¿Eliminar activo principal?';

  @override
  String get scwDescription => 'Descripción';

  @override
  String get scwDescriptionOfPhysicalDigitalGood => 'Descripción del bien físico/digital';

  @override
  String get scwDownloadExampleCsv => 'Descargar CSV de ejemplo';

  @override
  String get scwDownloadExampleJson => 'Descargar JSON de ejemplo';

  @override
  String get scwEdit => 'Editar';

  @override
  String get scwEditCreatorName => 'Editar nombre del creador';

  @override
  String get scwEditDescription => 'Editar descripción';

  @override
  String get scwEditName => 'Editar nombre';

  @override
  String get scwEventAddress => 'Dirección del evento';

  @override
  String get scwEventCode => 'Código del evento';

  @override
  String get scwEventDate => 'Fecha del evento';

  @override
  String get scwEventDescription => 'Descripción del evento';

  @override
  String get scwEventName => 'Nombre del evento';

  @override
  String get scwEventTime => 'Hora del evento';

  @override
  String get scwEventUrl => 'URL del evento';

  @override
  String get scwEvolutionDate => 'Fecha de evolución';

  @override
  String scwEvolutionTime(String timezone) {
    return 'Hora de evolución ($timezone)';
  }

  @override
  String get scwEvolve => 'Evolución';

  @override
  String get scwEvolveOnRedeem => '¿Evolucionar al canjear?';

  @override
  String get scwEvolveStageAsset => 'Activo de la etapa de evolución';

  @override
  String get scwEvolveStageDescription => 'Descripción de la etapa de evolución';

  @override
  String get scwEvolveStageName => 'Nombre de la etapa de evolución';

  @override
  String get scwEvolveType => 'Tipo de evolución';

  @override
  String get scwEvolveTypeBlockHeight => 'Altura de bloque';

  @override
  String get scwEvolveTypeDateTime => 'Fecha/Hora';

  @override
  String get scwEvolveTypeManualOnly => 'Solo manual';

  @override
  String scwEvolveWithType(String type) {
    return 'Evolución ($type)';
  }

  @override
  String get scwEvolvingPhase => 'Fase de evolución';

  @override
  String get scwExpireDate => 'Fecha de expiración';

  @override
  String get scwExpireTime => 'Hora de expiración';

  @override
  String get scwFractionalInterest => 'Interés fraccionario';

  @override
  String get scwFractionalizationTitle => 'Fraccionamiento';

  @override
  String get scwFullDescription => 'Descripción completa';

  @override
  String get scwImages => 'Imagen(es)';

  @override
  String get scwImporting => 'Importando';

  @override
  String get scwLaunchIdeBody => 'Abre el IDE en línea para escribir tu propio código Trillium para tu contrato inteligente';

  @override
  String get scwLaunchIdeMobileBody => 'El IDE está optimizado para pantallas más grandes. ¿Quieres continuar?';

  @override
  String get scwLaunchIdeMobileTitle => '¿Iniciar IDE en el móvil?';

  @override
  String get scwLaunchIdeTitle => 'Iniciar IDE';

  @override
  String get scwLaunchWizard => 'Iniciar asistente';

  @override
  String get scwMaxQuantity => 'La cantidad máxima es 100.';

  @override
  String get scwMetadataUrl => 'URL de metadatos';

  @override
  String get scwMinQuantity => 'La cantidad mínima es 1.';

  @override
  String get scwMintNftCollectionBody => 'Emite varios contratos inteligentes en una colección';

  @override
  String get scwMintNftCollectionTitle => 'Emitir colección de NFT';

  @override
  String get scwName => 'Nombre';

  @override
  String get scwNetwork => 'Red';

  @override
  String scwNetworkContractAddress(String network) {
    return 'Dirección del contrato de $network';
  }

  @override
  String get scwNoProperties => 'Sin propiedades';

  @override
  String get scwNotImplemented => 'No implementado.';

  @override
  String get scwNumericalProperty => 'Propiedad numérica';

  @override
  String get scwOtherOptions => 'Otras opciones';

  @override
  String get scwOwnerAddress => 'Dirección del propietario';

  @override
  String get scwPairWrapTitle => 'Emparejar/Envolver con un NFT existente';

  @override
  String get scwPercentage => 'Porcentaje';

  @override
  String get scwPercentageRequiredForVotingApproval => 'Porcentaje requerido para aprobar la votación';

  @override
  String scwPhaseLabel(int number, String name) {
    return 'Fase #$number: $name';
  }

  @override
  String get scwPhysicalDigitalGoodName => 'Nombre del bien físico/digital';

  @override
  String get scwPrimaryAsset => 'Activo principal';

  @override
  String get scwProperties => 'Propiedades';

  @override
  String get scwPropertiesOptional => 'Propiedades (opcional)';

  @override
  String get scwPropertyName => 'Nombre de la propiedad';

  @override
  String get scwPropertyType => 'Tipo de propiedad';

  @override
  String get scwPropertyTypeColor => 'Color';

  @override
  String get scwPropertyTypeNumber => 'Número';

  @override
  String get scwPropertyTypeText => 'Texto';

  @override
  String get scwPropertyValue => 'Valor de la propiedad';

  @override
  String get scwProvenanceFilesOptional => 'Archivos de procedencia (opcional)';

  @override
  String get scwQuantity => 'Cantidad';

  @override
  String get scwQuantityToMint => 'Cantidad a emitir';

  @override
  String scwQuantityValue(int quantity) {
    return 'Cantidad: $quantity';
  }

  @override
  String get scwReasonForPairingWrapping => 'Motivo del emparejamiento/envoltura';

  @override
  String get scwRemove => 'Eliminar';

  @override
  String get scwRemoveAssetBody => '¿Estás seguro de que quieres eliminar este activo adicional?';

  @override
  String get scwRemoveAssetTitle => '¿Eliminar activo?';

  @override
  String get scwRemovePhaseBody => '¿Estás seguro de que quieres eliminar esta fase de evolución?';

  @override
  String get scwRemovePhaseTitle => '¿Eliminar fase?';

  @override
  String get scwRemovePropertyBody => '¿Estás seguro de que quieres eliminar esta propiedad?';

  @override
  String get scwRemovePropertyTitle => '¿Eliminar propiedad?';

  @override
  String get scwRemoveRoyaltyBody => '¿Estás seguro de que quieres eliminar la regalía?';

  @override
  String get scwRemoveRoyaltyTitle => '¿Eliminar regalía?';

  @override
  String get scwRoyaltyTitle => 'Regalía';

  @override
  String scwRoyaltyToAddress(String amount, String address) {
    return '$amount a $address';
  }

  @override
  String get scwRoyaltyType => 'Tipo de regalía';

  @override
  String get scwRoyaltyTypeFixed => 'Fijo';

  @override
  String get scwRoyaltyTypePercent => 'Porcentaje';

  @override
  String get scwSeatingInfo => 'Información de asientos';

  @override
  String get scwSoulBoundTitle => 'Soul Bound';

  @override
  String get scwStatTypeString => 'Tipo: String';

  @override
  String get scwStats => 'Estadísticas';

  @override
  String get scwTextProperty => 'Propiedad de texto';

  @override
  String get scwTicketTitle => 'Boleto';

  @override
  String get scwTicketType => 'Tipo de boleto';

  @override
  String get scwTokenIdOptional => 'ID del token (opcional)';

  @override
  String get scwTokenStandardOptional => 'Estándar del token (opcional)';

  @override
  String get scwTokenizationTitle => 'Tokenización';

  @override
  String get scwUploadCsv => 'Subir CSV';

  @override
  String get scwUploadJson => 'Subir JSON';

  @override
  String get scwUploadJsonCsv => 'Subir JSON / CSV';

  @override
  String get scwUploadJsonCsvBody => 'Crea una colección con un archivo JSON o CSV. Consulta los archivos de ejemplo a continuación y úsalos como plantilla. Al subir el archivo podrás configurar y ajustar las opciones a través de la interfaz del asistente.\n\nEsta es una función avanzada para usuarios que quieren compilar y emitir colecciones fuera de la interfaz gráfica.';

  @override
  String get scwUseMyAddress => 'Usar mi dirección';

  @override
  String get scwVotingDescription => 'Descripción de la votación';

  @override
  String get tkbAmountGreaterThanZero => 'El monto debe ser mayor que 0.0 BTC';

  @override
  String tkbAmountOfVbtcTo(String action) {
    return 'Monto de vBTC para $action';
  }

  @override
  String get tkbAssociateLocalFile => 'Asociar archivo local';

  @override
  String get tkbAssociateMedia => 'Asociar recurso';

  @override
  String get tkbAuthorizeNow => 'Autorizar ahora';

  @override
  String tkbBalanceFoundBody(String balance) {
    return 'Se encontró un saldo de $balance VFX en esta cuenta. Saltando al paso 3.';
  }

  @override
  String tkbBalanceValue(String balance) {
    return 'Saldo: $balance';
  }

  @override
  String tkbBlockHeightValue(String height) {
    return 'Altura de bloque: $height';
  }

  @override
  String tkbBtcAddressGenerated(String address) {
    return 'Dirección BTC generada ($address)';
  }

  @override
  String get tkbBtcAddressPending => 'Dirección BTC pendiente';

  @override
  String get tkbBtcAmount => 'Monto de BTC';

  @override
  String tkbBtcSentTo(String amount, String address) {
    return 'Se han enviado $amount BTC a $address.';
  }

  @override
  String get tkbBtcTransferBroadcasted => 'TX de transferencia de BTC transmitida con éxito.';

  @override
  String tkbBtcWithdrawalBroadcasted(String hash) {
    return 'TX de retiro de BTC transmitida con éxito. Hash: $hash';
  }

  @override
  String get tkbCallMedia => 'Solicitar recurso';

  @override
  String get tkbCallMediaFromBeacon => 'Solicitar recurso desde el Beacon';

  @override
  String get tkbCallToBeaconStartedBody => 'Ten paciencia mientras se solicitan y descargan TODOS los recursos asociados al NFT.\n\nNo cierres tu billetera ni intentes solicitarlo de nuevo.';

  @override
  String get tkbCallToBeaconStartedTitle => 'El proceso de solicitud al Beacon ha comenzado.';

  @override
  String get tkbCallToBeaconStartedToast => 'El proceso de solicitud al Beacon ha comenzado. Ten paciencia mientras se solicitan y descargan TODOS los recursos asociados al NFT.';

  @override
  String get tkbCheckOtherAccount => 'Revisa cualquier otra cuenta con la misma dirección para encontrar el recurso multimedia.';

  @override
  String get tkbChooseBtcAccount => 'Elige la cuenta BTC desde la cual enviar';

  @override
  String get tkbChooseVaultAccount => 'Elige una Cuenta de bóveda';

  @override
  String get tkbComplete => 'Completar';

  @override
  String tkbConfirmSendBtcBody(String amount, String from, String to, String fee) {
    return 'Enviando $amount BTC desde $from a $to.\n\nComisión:\n$fee BTC';
  }

  @override
  String get tkbConfirmTransaction => 'Confirmar transacción';

  @override
  String get tkbConfirmVoteNoBody => '¿Seguro que quieres votar NO en este tema del token?';

  @override
  String get tkbConfirmVoteYesBody => '¿Seguro que quieres votar SÍ en este tema del token?';

  @override
  String tkbControlledBy(String address) {
    return 'Controlado por: $address';
  }

  @override
  String tkbCouldNotResolveNft(String id) {
    return 'No se pudo resolver el NFT desde $id';
  }

  @override
  String get tkbCreateBtcDomain => 'Crear dominio BTC';

  @override
  String tkbCreateDomainFor(String address) {
    return 'Crear dominio para $address';
  }

  @override
  String get tkbCreateTokenTopicBody => '¿Seguro que quieres crear este tema del token?';

  @override
  String get tkbCreationPending => 'Creación pendiente';

  @override
  String tkbDeleteBtcDomainBody(String costLine) {
    return '¿Seguro que quieres eliminar este dominio BTC?\n$costLine\n\nUna vez eliminado, este ADNR ya no podrá recibir transacciones.';
  }

  @override
  String get tkbDeleteDomainNoCost => 'No hay costo para eliminar un dominio VFX (aparte de la comisión de la TX).';

  @override
  String tkbDeleteDomainWithCost(String cost) {
    return 'Hay un costo de $cost VFX para eliminar un dominio RBX.';
  }

  @override
  String get tkbDeletePending => 'Eliminación pendiente';

  @override
  String get tkbDescriptionColon => 'Descripción:';

  @override
  String get tkbDismiss => 'Descartar';

  @override
  String get tkbDomainName => 'Nombre del dominio';

  @override
  String get tkbDomainNameRule => 'Tu dominio solo debe contener letras y números y se le agregará automáticamente \".btc\" al verificarse';

  @override
  String get tkbDownloadAsset => 'Descargar recurso';

  @override
  String get tkbError => 'Error';

  @override
  String get tkbErrorLoadingData => 'Error al cargar los datos';

  @override
  String get tkbFailedRequestWithdrawal => 'No se pudo solicitar el retiro.';

  @override
  String tkbFeeEstimate(String feeEstimate, String feeEstimateBtc, String fee, String feeBtc) {
    return 'Estimación de tarifa: ~$feeEstimate SATS | ~$feeEstimateBtc BTC    ($fee SATS /byte | $feeBtc BTC /byte)';
  }

  @override
  String get tkbFeeRateHint => 'Tarifa en satoshis';

  @override
  String tkbFeeRatePerByte(String sats, String btc) {
    return 'Tarifa: $sats SATS por byte ($btc BTC por byte)';
  }

  @override
  String get tkbFeeRateRequired => 'Se requiere la tarifa';

  @override
  String tkbFileNameLabel(String name) {
    return 'Nombre del archivo: $name';
  }

  @override
  String get tkbFileSize => 'Tamaño del archivo';

  @override
  String get tkbFileType => 'Tipo de archivo';

  @override
  String tkbFilenameCreator(String filename, String creator) {
    return 'Nombre del archivo: $filename | Creador: $creator';
  }

  @override
  String get tkbFixedSupply => 'Suministro fijo';

  @override
  String get tkbFungibleToken => 'Token fungible';

  @override
  String get tkbGenerate => 'Generar';

  @override
  String get tkbGenerateBtcAddress => 'Generar dirección BTC';

  @override
  String get tkbGenerateBtcAddressBody => '¿Seguro que quieres generar la dirección BTC de este token?';

  @override
  String get tkbImagePreviewNotFound => 'No se encontró el archivo para la vista previa.\nProbablemente esto significa que este NFT ya no existe en esta máquina.\n';

  @override
  String get tkbInProgress => 'En curso';

  @override
  String get tkbInfinite => 'Infinito';

  @override
  String tkbInsufficientBalanceAccount(String balance) {
    return 'Saldo insuficiente para cubrir la tx y la comisión. Esta cuenta solo tiene $balance BTC.';
  }

  @override
  String get tkbInvalidFeeRate => 'Tarifa inválida. Debe ser al menos 1 satoshi.';

  @override
  String get tkbManualSendSubtitle => 'Envía la moneda manualmente a la dirección de depósito BTC de este token';

  @override
  String tkbMediaNotFound(String fileName) {
    return 'No se encontró el archivo del recurso multimedia en tu máquina ($fileName).';
  }

  @override
  String get tkbMinimumTokenRequirement => 'Requisito mínimo de tokens';

  @override
  String get tkbMinimumTokenRequirementHelper => 'El saldo mínimo de tokens necesario para votar.';

  @override
  String tkbMinimumTokensToVote(String count) {
    return 'Tokens mínimos para votar: $count';
  }

  @override
  String get tkbMultiSigFeeCalculated => 'Esto es una firma múltiple. La tarifa se ha calculado por ti.';

  @override
  String tkbNeedTokensToVote(String count) {
    return 'Necesitas al menos $count tokens para votar.';
  }

  @override
  String tkbNoAddressesHolding(String ticker) {
    return 'Ninguna de tus direcciones posee $ticker';
  }

  @override
  String get tkbNoFungibleTokens => 'Sin tokens fungibles';

  @override
  String get tkbNoFungibleTokensBody => 'No tienes tokens fungibles con suministro en ninguna de tus cuentas.';

  @override
  String get tkbNoRequestHash => 'No se devolvió ningún hash de solicitud.';

  @override
  String get tkbNoUpper => 'NO';

  @override
  String get tkbNoUtxos => 'Sin UTXOs';

  @override
  String get tkbNoVaultAccounts => 'No tienes ninguna Cuenta de bóveda en esta billetera';

  @override
  String get tkbNoVotesYet => 'Aún no hay votos.';

  @override
  String get tkbNone => 'Ninguna';

  @override
  String get tkbNotFound => 'No encontrado.';

  @override
  String get tkbOpenAsset => 'Abrir recurso';

  @override
  String get tkbOpenFolder => 'Abrir carpeta';

  @override
  String get tkbOwnershipTransferInitiated => 'Transferencia de propiedad iniciada.';

  @override
  String get tkbPassword => 'Contraseña';

  @override
  String tkbPendingWithdrawalBody(String amount, String destination) {
    return 'Tienes un retiro pendiente de $amount vBTC a $destination.\n\n¿Quieres completarlo?';
  }

  @override
  String get tkbPendingWithdrawalContractBody => 'Tienes un retiro pendiente para este contrato. ¿Quieres completarlo?';

  @override
  String get tkbPendingWithdrawalFound => 'Retiro pendiente encontrado';

  @override
  String get tkbPercentages => 'Porcentajes';

  @override
  String get tkbResult => 'Resultado';

  @override
  String get tkbResultFail => 'Rechazado';

  @override
  String get tkbResultPass => 'Aprobado';

  @override
  String get tkbSelectVfxAddress => 'Selecciona la dirección VFX';

  @override
  String get tkbSelectedAddress => 'Dirección seleccionada:';

  @override
  String get tkbSendAutomatically => 'Enviar automáticamente';

  @override
  String tkbSendFundsTo(String address) {
    return 'Envía fondos a $address (dirección copiada al portapapeles)';
  }

  @override
  String get tkbSendManually => 'Enviar manualmente';

  @override
  String tkbSmartContractUidWithValue(String uid) {
    return 'UID del contrato inteligente: $uid';
  }

  @override
  String get tkbToBtcAddress => 'A la dirección BTC';

  @override
  String get tkbToVfxAddress => 'A la dirección VFX';

  @override
  String get tkbTokenBalances => 'Saldos de tokens';

  @override
  String get tkbTokenDetails => 'Detalles del token';

  @override
  String get tkbTokenTopicCreated => 'Tema del token creado';

  @override
  String tkbTopicUidLabel(String uid) {
    return 'UID: $uid';
  }

  @override
  String get tkbTotalVotes => 'Votos totales';

  @override
  String get tkbTransactionBroadcastedBang => '¡Transacción transmitida!';

  @override
  String get tkbTransactionHash => 'Hash de la transacción';

  @override
  String get tkbTransactionHashCopied => 'Hash de la transacción copiado al portapapeles';

  @override
  String get tkbTransferBtc => 'Transferir BTC';

  @override
  String tkbTransferDomainFrom(String address) {
    return 'Transferir dominio desde $address';
  }

  @override
  String tkbTransferOwnershipBody(String address) {
    return '¿Seguro que quieres transferir la propiedad de este token vBTC a $address?';
  }

  @override
  String get tkbTransferOwnershipToReserve => 'Transferir la propiedad a una Cuenta de reserva/protegida';

  @override
  String get tkbTransferOwnershipToReserveSubtitle => 'Transfiere la propiedad de este token a tu cuenta de reserva/protegida.';

  @override
  String get tkbTransferPending => 'Transferencia pendiente';

  @override
  String get tkbTransferToken => 'Transferir token';

  @override
  String get tkbTransferTokenOwnership => 'Transferir la propiedad del token';

  @override
  String get tkbTransferTokenOwnershipSubtitle => 'Transfiere la propiedad de este token a otra cuenta VFX.';

  @override
  String get tkbTransferVbtc => 'Transferir vBTC';

  @override
  String tkbTransferVbtcBody(String amount, String address) {
    return '¿Seguro que quieres transferir $amount vBTC a $address?';
  }

  @override
  String get tkbTransferVbtcSubtitle => 'Transfiere una porción específica del vBTC dentro del token a otra dirección VFX.';

  @override
  String get tkbTxBroadcasted => '¡TX transmitida!';

  @override
  String tkbUtxoAddress(String address) {
    return 'Dirección: $address';
  }

  @override
  String tkbUtxoDetails(String txId, String amount) {
    return 'TX ID: $txId\nMonto:$amount';
  }

  @override
  String get tkbUtxoUnused => 'Sin usar';

  @override
  String get tkbUtxoUsed => 'Usado';

  @override
  String get tkbVaultAccountPassword => 'Contraseña de la Cuenta de bóveda';

  @override
  String get tkbVaultAuthorizeDownload => 'Como esta es una Cuenta de bóveda, deberás autorizar la descarga.';

  @override
  String get tkbVaultCannotWithdraw => 'Las Cuentas de bóveda no pueden retirar. Transfiere vBTC a una dirección VFX estándar';

  @override
  String get tkbVaultOwnedCannotAction => 'Los tokens que pertenecen a una Cuenta de bóveda no pueden realizar esta acción.';

  @override
  String tkbVbtcTransferBroadcasted(String hash) {
    return 'TX de transferencia vBTC V2 transmitida. Hash: $hash';
  }

  @override
  String get tkbVbtcZeroBalance => 'Los tokens vBTC con saldo cero no se pueden transferir.';

  @override
  String get tkbVfxWalletRequired => 'Se requiere una billetera VFX para esta funcionalidad.';

  @override
  String get tkbVoteCounts => 'Conteo de votos';

  @override
  String tkbVotedOnBlock(String label, String block) {
    return 'Votaste $label en el bloque $block.';
  }

  @override
  String get tkbVotesNo => 'Votos en contra';

  @override
  String get tkbVotesYes => 'Votos a favor';

  @override
  String get tkbWalletControlsDomain => 'Esta billetera controlará la propiedad de transferencia/eliminación sobre este nuevo dominio.';

  @override
  String get tkbWithdrawBtc => 'Retirar BTC';

  @override
  String tkbWithdrawBtcBody(String amount, String address) {
    return '¿Seguro que quieres retirar $amount BTC a $address?';
  }

  @override
  String get tkbYesUpper => 'SÍ';

  @override
  String get tkbYouHaveVoted => 'Has votado.';

  @override
  String tkbYourBalanceValue(String balance) {
    return 'Tu saldo: $balance';
  }

  @override
  String tkbYourBalanceVbtc(String balance, String usd) {
    return 'Tu saldo: $balance vBTC$usd';
  }

  @override
  String get txpAccountBalance => 'Saldo de la cuenta';

  @override
  String get txpAccountCreated => 'Cuenta creada';

  @override
  String get txpActivateOnNetwork => '¿Activar en la red?';

  @override
  String get txpActivateOnNetworkBody => 'Hay un costo de 4 VFX (que se queman) más la comisión de TX para activar esta cuenta de bóveda en la red.  ¿Continuar?';

  @override
  String get txpAddBtcAccount => 'Agregar cuenta BTC';

  @override
  String get txpAddNewAccount => 'Agregar nueva cuenta';

  @override
  String get txpAddVfxAccount => 'Agregar cuenta VFX';

  @override
  String get txpAddressCopied => 'Dirección copiada';

  @override
  String get txpAddressCopiedClipboard => 'Dirección copiada al portapapeles.';

  @override
  String get txpAllAddresses => 'Todas las direcciones';

  @override
  String get txpAmountCopied => 'Monto copiado';

  @override
  String get txpAutoActivate => '¿Activar automáticamente?';

  @override
  String get txpAutoActivateBody => '¿Te gustaría activar automáticamente esta cuenta una vez que se reciban los fondos?';

  @override
  String get txpAutoActivateQueued => 'Activación automática en cola.';

  @override
  String txpBlockDiffAvg(String value) {
    return 'Promedio de diferencia de bloques: $value';
  }

  @override
  String txpBlockLastDelay(String value) {
    return 'Retraso del último bloque: $value';
  }

  @override
  String txpBlockLastReceived(String value) {
    return 'Último bloque recibido: $value';
  }

  @override
  String get txpBlockNumber => 'Número de bloque';

  @override
  String txpBlocksAveraged(String value) {
    return 'Bloques promediados: $value';
  }

  @override
  String get txpBtcNoBalance => 'La cuenta BTC no tiene saldo';

  @override
  String get txpChooseCoinType => 'Elige el tipo de moneda';

  @override
  String get txpChoosePaymentGateway => 'Elige la pasarela de pago';

  @override
  String get txpClearFilters => 'Limpiar filtros';

  @override
  String get txpCompleteMoonpayDeposit => 'Completar depósito de MoonPay';

  @override
  String get txpCompleteSale => 'Completar venta';

  @override
  String txpCompleteSaleConfirmBody(String scId, String amount) {
    return '¿Seguro que quieres completar la venta de $scId por $amount VFX?';
  }

  @override
  String get txpConfirmPassword => 'Confirmar contraseña';

  @override
  String get txpConfirmPasswordBody => 'Por favor confirma tu contraseña.';

  @override
  String get txpConfirmSend => 'Confirmar envío';

  @override
  String txpConfirmSendBody(String amount, String currency, String toAddress, String fromAddress, String feeRate) {
    return 'Monto: $amount $currency\nPara: $toAddress\nDe: $fromAddress\nTasa de comisión: $feeRate sats/vB';
  }

  @override
  String get txpCopyAddress => 'Copiar dirección';

  @override
  String get txpCreate => 'Crear';

  @override
  String get txpCreateBtcAccountSub => 'Crea una nueva cuenta BTC';

  @override
  String get txpCreateVfxAccountSub => 'Crea una nueva cuenta VFX';

  @override
  String get txpCryptoDotComOnRamp => 'On-Ramp de Crypto.com';

  @override
  String get txpData => 'Datos';

  @override
  String get txpDate => 'Fecha';

  @override
  String get txpDepositAddressMoonpay => 'Dirección de depósito (MoonPay)';

  @override
  String get txpDisclaimerAnd => ' y la ';

  @override
  String txpDisclaimerIntro(String gateway) {
    return 'Entiendo que ahora compraré la moneda nativa VFX o BTC directamente a través de $gateway (';
  }

  @override
  String txpDisclaimerMiddle(String gateway) {
    return '), que es una plataforma de servicios de terceros. Al continuar y contratar los servicios de $gateway, reconoces que has leído y aceptado los ';
  }

  @override
  String txpDisclaimerOutro(String gateway) {
    return '. Además, entiendes que la Red VFX de VerifiedX es un ecosistema autónomo y descentralizado y no comparte ninguna comisión por tu uso de los servicios de $gateway, y no asume ninguna responsabilidad por cualquier problema que pueda afectar tu transacción con cualquier proveedor de servicios de terceros en cualquier momento. Para cualquier pregunta relacionada con los servicios de $gateway, comunícate con $gateway en ';
  }

  @override
  String get txpErrorOccurred => 'Ocurrió un error';

  @override
  String get txpFundAccount => 'Financiar cuenta';

  @override
  String get txpFundVaultBody => 'Ahora debes financiar tu cuenta de bóveda con un mínimo de 5 VFX. Se quemarán 4 VFX al activarla.';

  @override
  String get txpFundVaultBodyShort => 'Ahora debes financiar tu cuenta de bóveda con un mínimo de 5 VFX.';

  @override
  String get txpFundsSent => 'Fondos enviados';

  @override
  String txpFundsSentBody(String amount, String address) {
    return 'Se enviaron $amount VFX a $address.\n\nEspera a que la transacción se refleje y luego activa tu cuenta de bóveda.';
  }

  @override
  String get txpGetBtcNow => 'Obtén \$BTC ahora';

  @override
  String get txpGetQuote => 'Obtener cotización';

  @override
  String get txpGetVfxNow => 'Obtén \$VFX ahora';

  @override
  String get txpImportBtcKeySub => 'Importa una clave privada BTC existente';

  @override
  String get txpImportVfxKeySub => 'Importa una clave privada VFX existente';

  @override
  String get txpManualDeposit => 'Depósito manual';

  @override
  String txpManualDepositBody(String amount, String currency) {
    return 'Puedes enviar esto desde otra billetera enviando la cantidad exacta ($amount $currency) a la dirección de depósito de arriba.';
  }

  @override
  String get txpMeMarker => '[YO]';

  @override
  String get txpMinBalanceActivate => 'Se requiere un saldo mínimo de 5 VFX para activar.';

  @override
  String get txpMoonpayManualMarked => 'Transacción de MoonPay marcada como depósito manual';

  @override
  String get txpMustConfirmPassword => 'Debes confirmar tu contraseña.';

  @override
  String get txpNativeMoonpaySoon => 'La integración nativa de Moonpay se activará pronto.';

  @override
  String get txpNoAccountFound => 'No se encontró ninguna cuenta';

  @override
  String get txpNoAddressSelected => 'No hay dirección seleccionada';

  @override
  String get txpNonce => 'Nonce';

  @override
  String get txpNotAvailableOnPlatform => 'No disponible en esta plataforma';

  @override
  String get txpNotEnoughBtcFee => 'No hay suficiente BTC para cubrir la transacción + comisión';

  @override
  String get txpNotVaultAccount => 'No es una cuenta de bóveda';

  @override
  String get txpOffRampInstructions => 'Para completar este retiro, envía la cantidad exacta de BTC a la dirección de depósito de abajo:';

  @override
  String get txpOriginalTx => 'TX original';

  @override
  String get txpPasswordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String txpPleaseSendFundsTo(String address) {
    return 'Por favor envía fondos a $address';
  }

  @override
  String get txpPrivacyPolicy => 'Política de privacidad';

  @override
  String get txpRestoreCodeRecoveryBody => 'Pega tu CÓDIGO DE RESTAURACIÓN para importar la cuenta de recuperación de esta cuenta de bóveda.';

  @override
  String get txpScanAndPay => 'Escanear y pagar';

  @override
  String get txpSendManually => 'Ya envié / enviaré manualmente';

  @override
  String get txpSendNow => 'Enviar ahora';

  @override
  String txpSendingConfirmBody(String amount, String toAddress, String fromAddress) {
    return 'Enviando:\n$amount VFX\n\nPara:\n$toAddress\n\nDe:\n$fromAddress';
  }

  @override
  String txpSentToAddress(String amount, String currency, String address) {
    return '$amount $currency enviados a $address';
  }

  @override
  String get txpSetupBtcAccount => 'Configura una cuenta de Bitcoin';

  @override
  String get txpSetupVaultAccount => 'Configurar cuenta de bóveda';

  @override
  String get txpSetupVaultAccountBody => 'Crea una contraseña para continuar. Debes recordar esta contraseña, ya que será necesaria para cualquier transacción con esta cuenta de bóveda.';

  @override
  String get txpSetupVfxAccount => 'Configura una cuenta de VerifiedX';

  @override
  String txpStatusWithValue(String value) {
    return 'Estado: $value';
  }

  @override
  String get txpStripeCreditCard => 'Stripe (Tarjeta de crédito)';

  @override
  String txpSufficientBalanceBody(String address, String balance) {
    return 'Tienes una cuenta con saldo suficiente.\n\n¿Te gustaría enviar 5 VFX desde:\n$address\n[Saldo: $balance VFX]?';
  }

  @override
  String get txpTermsOfUse => 'Términos de uso';

  @override
  String get txpTestnetFaucet => 'Faucet de testnet';

  @override
  String get txpTestnetFaucetNoTerms => 'El faucet de testnet no tiene términos. ¡Diviértete!';

  @override
  String get txpTileAmountLabel => 'Monto: ';

  @override
  String txpTileDateLabel(String date) {
    return 'Fecha: $date';
  }

  @override
  String txpTileHashLabel(String hash) {
    return 'Hash: $hash';
  }

  @override
  String txpTileSettlementDateLabel(String date) {
    return 'Fecha de liquidación: $date';
  }

  @override
  String get txpTileStatusLabel => 'Estado: ';

  @override
  String get txpTileTypeLabel => 'Tipo: ';

  @override
  String get txpTileViewData => 'Ver datos';

  @override
  String txpTimeSinceLastBlock(String value) {
    return 'Tiempo desde el último bloque: ${value}s';
  }

  @override
  String get txpTransactionFailed => 'La transacción falló';

  @override
  String get txpTransactionHashLabel => 'Hash de transacción';

  @override
  String get txpTransactionSent => 'Transacción enviada';

  @override
  String get txpTxDetailTitle => 'Detalle de transacción';

  @override
  String get txpTxFilters => 'Filtros de transacción';

  @override
  String get txpTxHash => 'Hash de Tx';

  @override
  String get txpTxHashCopied => 'Hash de Tx copiado';

  @override
  String get txpTxType => 'Tipo de Tx';

  @override
  String txpTxTypeLabel(String suffix) {
    return 'Tipo de Tx$suffix:';
  }

  @override
  String txpValueCopied(String value) {
    return '\'$value\' copiado al portapapeles';
  }

  @override
  String get txpVaultActivationSent => 'Se envió la transacción de activación de la cuenta de bóveda.\n\nEspera a que se refleje como \"Activada\".';

  @override
  String get txpVfxAmount => 'Monto de VFX';

  @override
  String get txpVfxOffRampSoon => 'La función de retiro de VFX estará disponible pronto';

  @override
  String get txpVfxQuote => 'Cotización de VFX';

  @override
  String txpVfxQuoteBody(String amountVfx, String amountUsd) {
    return '$amountVfx VFX por \$$amountUsd USD\n¿Te gustaría continuar?';
  }

  @override
  String get txpWalletDetailsBackup => 'Aquí están los detalles de tu billetera. Asegúrate de respaldar tu clave privada en un lugar seguro.';

  @override
  String txpWalletVersionInfo(String envTag, String version, String nickname) {
    return 'VFX Wallet$envTag\nVersión $version ($nickname)';
  }

  @override
  String tkbHashLabel(String hash) {
    return 'Hash: $hash';
  }

  @override
  String get tkbBulkTransferUnavailableWeb => 'La transferencia masiva aún no está disponible en la billetera web.';

  @override
  String get tkbCreateVbtcToken => 'Crear token vBTC';

  @override
  String hnavSnapshotDownloadingProgress(String file, int done, int total) {
    return 'Descargando: $file ($done/$total)';
  }

  @override
  String get tkbFundToken => 'Financiar token';

  @override
  String get tkbManualSendExchangeSubtitle => 'Envía BTC desde cualquier exchange o billetera a la dirección de depósito de este token';
}
