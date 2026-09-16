import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../core/constants/app_link.dart';
import '../../core/services/api_service.dart';

class NotificationProvider extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Response> getNotifications({int page = 1, int read = 0}) async {
    try {
      final response = await _apiService.dio.get(
        AppLink.getNotifications,
        queryParameters: {'page': page, 'read': read},
      );
      return response;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Response> markAsRead(String notificationId) async {
    try {
      return await _apiService.dio.patch(
        AppLink.markNotificationAsRead(notificationId),
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.message;
    }
  }

  Future<Response> markAllAsRead() async {
    try {
      return await _apiService.dio.patch(AppLink.markAllNotifications);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.message;
    }
  }

  Future<Response> getUnreadCount() async {
    try {
      return await _apiService.dio.get(AppLink.unreadNotificationsCount);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.message;
    }
  }
}
