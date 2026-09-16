import 'package:get_storage/get_storage.dart';

import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationRepository {
  final NotificationProvider _provider;
  final GetStorage _storage = GetStorage();
  NotificationRepository(this._provider);

  final String _notificationsKey = 'cached_driver_notifications';

  Future<List<NotificationModel>> fetchNotifications({
    int page = 1,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      final cachedData = _storage.read<List<dynamic>>(_notificationsKey);
      if (cachedData != null) {
        return cachedData
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      return [];
    }

    try {
      final response = await _provider.getNotifications(page: page);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        if (page == 1) {
          _storage.write(_notificationsKey, data);
        }

        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Repository Error fetching notifications: $e");

      final cachedData = _storage.read<List<dynamic>>(_notificationsKey);
      if (cachedData != null) {
        return cachedData
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      return [];
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _provider.markAsRead(notificationId);
      return response.statusCode == 200;
    } catch (e) {
      print("Repository Error markAsRead: $e");
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _provider.markAllAsRead();
      return response.statusCode == 200;
    } catch (e) {
      print("Repository Error markAllAsRead: $e");
      return false;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _provider.getUnreadCount();
      if (response.statusCode == 200) {
        return response.data['unread_count'] ??
            response.data['count'] ??
            response.data['data']?['count'] ??
            0;
      }
      return 0;
    } catch (e) {
      print("Repository Error getUnreadCount: $e");
      return 0;
    }
  }
}
