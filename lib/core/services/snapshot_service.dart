import '../env.dart';
import '../models/snapshot_info.dart';
import 'base_service.dart';

class SnapshotService extends BaseService {
  SnapshotService() : super(hostOverride: 'https://fleet.verifiedx.io');

  Future<SnapshotInfo?> fetchLatest() async {
    try {
      final network = Env.isDevnet
          ? 'devnet'
          : Env.isTestNet
              ? 'testnet'
              : 'mainnet';
      final response = await getJson(
        '/api/snapshots/latest/',
        params: {'network': network},
      );
      print(response);
      return SnapshotInfo.fromJson(response);
    } catch (e) {
      print('SnapshotService.fetchLatest error: $e');
      return null;
    }
  }
}
