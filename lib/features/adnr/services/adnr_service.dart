import 'dart:convert';

import '../../../core/services/base_service.dart';
import '../models/adnr_response.dart';
import '../../../core/utils/user_error_message.dart';

class AdnrService extends BaseService {
  AdnrService() : super(apiBasePathOverride: "/txapi/TXV1");

  // ADNRs

  Future<AdnrResponse> createAdnr(String address, String name) async {
    try {
      final response = await getText("/CreateAdnr/$address/$name");
      final data = jsonDecode(response);
      return AdnrResponse(
        success: data['Result'] == "Success",
        message: data['Message'],
        hash: data['Hash'],
      );
    } catch (e) {
      return AdnrResponse(success: false, message: userErrorMessage(e));
    }
  }

  Future<AdnrResponse> transferAdnr(String fromAddress, String toAddress) async {
    try {
      final response = await getText("/TransferAdnr/$fromAddress/$toAddress");
      final data = jsonDecode(response);
      return AdnrResponse(
        success: data['Result'] == "Success",
        message: data['Message'],
        hash: data['Hash'],
      );
    } catch (e) {
      return AdnrResponse(success: false, message: userErrorMessage(e));
    }
  }

  Future<AdnrResponse> deleteAdnr(String address) async {
    try {
      final response = await getText("/DeleteAdnr/$address");
      final data = jsonDecode(response);
      return AdnrResponse(
        success: data['Result'] == "Success",
        message: data['Message'],
        hash: data['Hash'],
      );
    } catch (e) {
      return AdnrResponse(success: false, message: userErrorMessage(e));
    }
  }
}
