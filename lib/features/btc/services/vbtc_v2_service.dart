import '../../../utils/toast.dart';
import '../../../core/services/base_service.dart';

class VbtcV2Service extends BaseService {
  VbtcV2Service() : super(apiBasePathOverride: "/vbtcapi/vbtc");

  Future<String?> initiateCeremony(String ownerAddress) async {
    try {
      final result = await postJson(
        "/InitiateMPCCeremony/$ownerAddress",
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = result['data'];

      if (data['Success'] == true) {
        return data['CeremonyId'];
      }

      Toast.error(data['Message'] ?? "Failed to initiate ceremony.");
      return null;
    } catch (e) {
      print("InitiateMPCCeremony");
      print(e);
      Toast.error(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCeremonyStatus(String ceremonyId) async {
    try {
      final result = await getJson(
        "/GetCeremonyStatus/$ceremonyId",
        cleanPath: false,
      );

      if (result['Success'] == true) {
        return result;
      }

      Toast.error(result['Message'] ?? "Failed to get ceremony status.");
      return null;
    } catch (e) {
      print("GetCeremonyStatus");
      print(e);
      return null;
    }
  }

  Future<String?> createContract({
    required String ownerAddress,
    required String name,
    required String description,
    required String ticker,
    required String ceremonyId,
  }) async {
    final params = {
      'OwnerAddress': ownerAddress,
      'Name': name,
      'Description': description,
      'Ticker': ticker,
      'CeremonyId': ceremonyId,
    };

    try {
      final result = await postJson(
        "/CreateVBTCContract",
        params: params,
        cleanPath: false,
        inspect: true,
      );

      final Map<String, dynamic> data = result['data'];

      if (data['Success'] == true) {
        if (data.containsKey('Hash')) {
          return data['Hash'];
        }
      }

      Toast.error(data['Message'] ?? "Failed to create contract.");
      return null;
    } catch (e) {
      print("CreateVBTCContract");
      print(e);
      Toast.error(e.toString());
      return null;
    }
  }
}
