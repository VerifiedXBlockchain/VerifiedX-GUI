import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../l10n/l10n_helper.dart';

part 'new_reserve_account.freezed.dart';
part 'new_reserve_account.g.dart';

@freezed
abstract class NewReserveAccount with _$NewReserveAccount {
  const NewReserveAccount._();

  factory NewReserveAccount({
    @JsonKey(name: "PrivateKey") required String privateKey,
    @JsonKey(name: "Address") required String address,
    @JsonKey(name: "RecoveryAddress") required String recoveryAddress,
    @JsonKey(name: "RecoveryPrivateKey") required String recoveryPrivateKey,
    @JsonKey(name: "RestoreCode") required String restoreCode,
  }) = _NewReserveAccount;

  factory NewReserveAccount.fromJson(Map<String, dynamic> json) => _$NewReserveAccountFromJson(json);

  String get backupContents {
    return [
      globalL10n.r3dBackupRestoreCode,
      restoreCode,
      "\n${globalL10n.r3dBackupPrivateKey}",
      privateKey,
      "\n${globalL10n.r3dBackupAddress}",
      address,
      "\n${globalL10n.r3dBackupRecoveryPrivateKey}",
      recoveryPrivateKey,
      "\n${globalL10n.r3dBackupRecoveryAddress}",
      recoveryAddress,
    ].join("\n");
  }
}
