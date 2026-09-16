import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;

import '../../core/constants/app_link.dart';
import '../../core/services/api_service.dart';

class ProfileProvider {
  final Dio _dio = Get.find<ApiService>().dio;

  Future<Response> getProfile() async {
    return await _dio.get(AppLink.driverProfile);
  }

  Future<Response> updateProfileJson(Map<String, dynamic> data) async {
    return await _dio.patch(AppLink.driverProfile, data: data);
  }

  Future<Response> updateProfileMultipart(FormData data) async {
    return await _dio.post(AppLink.driverProfile, data: data);
  }
}
