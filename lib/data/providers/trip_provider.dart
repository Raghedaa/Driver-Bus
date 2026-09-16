import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../core/constants/app_link.dart';
import '../../core/services/api_service.dart';

class TripProvider {
  final Dio _dio = Get.find<ApiService>().dio;

  Future<Response> getDriverTrips({int page = 1}) async {
    return await _dio.get(AppLink.driverTrips, queryParameters: {'page': page});
  }

  Future<Response> getTripDetails(int tripId) async {
    return await _dio.get(AppLink.driverTripDetails(tripId));
  }

  Future<Response> updateTripStatus({
    required int tripId,
    required String status,
  }) async {
    return await _dio.patch(
      AppLink.updateTripStatus(tripId),
      data: {"status": status},
    );
  }

  Future<Response> getCities() async {
    return await _dio.get(AppLink.cities);
  }

  Future<Response> getStations() async {
    return await _dio.get(AppLink.stations);
  }

  Future<Response> getRestAreas() async {
    return await _dio.get(AppLink.restAreas);
  }

  Future<Response> sendTripLocation({
    required int tripId,
    required double lat,
    required double lng,
    required double speed,
    required double heading,
    required double accuracy,
  }) async {
    return await _dio.post(
      AppLink.trackTripLocation(tripId),
      data: {
        "lat": lat,
        "lng": lng,
        "speed": speed,
        "heading": heading,
        "accuracy": accuracy,
      },
    );
  }
}
