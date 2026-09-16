import 'package:driver_bus_app/routes/app_routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../core/shared/custom_snackbar.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/providers/notification_provider.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../home/schedule/controllers/schedule_controller.dart';

class NotificationsController extends GetxController {
  late final NotificationRepository _repository;
  final ScheduleController _scheduleController = Get.find<ScheduleController>();

  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;
  var unreadCount = 0.obs;
  var notifPage = 1.obs;
  var hasMoreNotifs = true.obs;
  var isLoadingMoreNotifs = false.obs;
  bool get isOnline => _scheduleController.isOnline.value;

  @override
  void onInit() {
    super.onInit();
    _repository = NotificationRepository(Get.put(NotificationProvider()));
    checkConnectivityAndLoad();

    ever(_scheduleController.isOnline, (bool online) {
      if (online) checkConnectivityAndLoad();
    });

    ever(Get.find<ScheduleController>().currentLanguage, (_) {
      checkConnectivityAndLoad();
    });
  }

  Future<void> checkConnectivityAndLoad() async {
    await loadNotifications();

    if (isOnline) {
      await fetchUnreadCount();
    }
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;

      final fetchedNotifications = await _repository.fetchNotifications(
        page: 1,
        isOnline: isOnline,
      );
      notifications.value = fetchedNotifications;
      await fetchUnreadCount();
    } catch (e) {
      print("Error loading notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    if (!hasMoreNotifs.value || isLoadingMoreNotifs.value) return;

    isLoadingMoreNotifs.value = true;
    try {
      final more = await _repository.fetchNotifications(
        page: notifPage.value + 1,
        isOnline: isOnline,
      );
      notifications.addAll(more);
      hasMoreNotifs.value = more.length >= 15;
      notifPage.value++;
    } finally {
      isLoadingMoreNotifs.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    if (!isOnline) return;
    unreadCount.value = await _repository.getUnreadCount();
  }

  Future<void> handleNotificationTap(int index) async {
    final notification = notifications[index];

    if (!isOnline) {
      CustomSnackBar.showError("offline_mode_cannot_open_trip".tr);
      return;
    }

    if (!notification.isRead) {
      await markAsRead(index);
    }

    if (notification.referenceType != null &&
        notification.referenceType!.contains('Trip')) {
      if (notification.referenceId != null) {
        print("Navigating to Trip ID: ${notification.referenceId}");
        Get.toNamed(AppRoutes.tripDetails, arguments: notification.referenceId);
      } else {
        print("Reference ID is null");
      }
    }
  }

  Future<void> markAsRead(int index) async {
    if (!isOnline) {
      CustomSnackBar.showError("offline_mode_cannot_update".tr);
      return;
    }

    final notification = notifications[index];
    if (notification.isRead) return;

    notifications[index].isRead = true;
    notifications.refresh();
    if (unreadCount.value > 0) unreadCount.value--;

    bool success = await _repository.markAsRead(notification.id);
    if (!success) {
      notifications[index].isRead = false;
      notifications.refresh();
      unreadCount.value++;
      CustomSnackBar.showError("failed_to_update_status".tr);
    }
  }

  Future<void> markAllAsReadOnServer() async {
    if (!isOnline) {
      CustomSnackBar.showError("offline_mode_cannot_update".tr);
      return;
    }
    if (notifications.isEmpty) return;

    isLoading.value = true;
    bool success = await _repository.markAllAsRead();
    isLoading.value = false;

    if (success) {
      for (var notification in notifications) {
        notification.isRead = true;
      }
      notifications.refresh();
      unreadCount.value = 0;
      CustomSnackBar.showSuccess("all_marked_as_read".tr);
    } else {
      CustomSnackBar.showError("failed_to_update_status".tr);
    }
  }

  void handleIncomingNotification(Map<String, dynamic> payload) {
    try {
      final newNotification = NotificationModel.fromJson(payload);

      notifications.insert(0, newNotification);

      if (!newNotification.isRead) {
        unreadCount.value++;
      }

      _saveNotificationsToCache();
    } catch (e) {
      print("Error handling incoming notification object: $e");
    }
  }

  void _saveNotificationsToCache() {
    final List<Map<String, dynamic>> jsonList = notifications
        .map(
          (n) => {
            'id': n.id,
            'title': n.title,
            'body': n.body,
            'created_at': n.timestamp.toIso8601String(),
            'read_at': n.isRead ? DateTime.now().toIso8601String() : null,
            'type': n.type == NotificationType.trip
                ? 'trip'
                : (n.type == NotificationType.alert ? 'alert' : 'message'),
            'reference_type': n.referenceType,
            'reference_id': n.referenceId,
          },
        )
        .toList();

    GetStorage().write('cached_driver_notifications', jsonList);
  }
}
