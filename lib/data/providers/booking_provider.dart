import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../core/constants/app_link.dart';
import '../../core/services/api_service.dart';

class BookingProvider extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Response> verifyTicket(String pnrCode, int tripId) async {
    try {
      final response = await _apiService.dio.post(
        AppLink.verifyTicket,
        data: {"pnr_code": pnrCode, "trip_id": tripId},
      );
      return response;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Response> getTripPassengers(int tripId, {int page = 1}) async {
    try {
      final response = await _apiService.dio.get(
        AppLink.tripPassengers(tripId),
        queryParameters: {'page': page},
      );
      return response;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.message;
    } catch (e) {
      throw e.toString();
    }
  }
}
