import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_color.dart';
import '../../../home/schedule/controllers/schedule_controller.dart';
import '../../controller/notifications_controller.dart';
import '../widgets/notification_card.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "notifications".tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.black,
                ),
              ),
              if (controller.isOnline && controller.unreadCount.value > 0) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColor.error,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  constraints: BoxConstraints(minWidth: 22.w, minHeight: 22.h),
                  child: Text(
                    "${controller.unreadCount.value}",
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          );
        }),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.find<ScheduleController>().changePage(1),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: context.black),
            onPressed: () => controller.markAllAsReadOnServer(),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.isOnline) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
              color: AppColor.error.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: AppColor.error,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "viewing_cached_notifications".tr,
                    style: TextStyle(
                      color: AppColor.error,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryGreen,
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColor.primaryGreen,
                onRefresh: () async {
                  await controller.checkConnectivityAndLoad();
                },
                child: controller.notifications.isEmpty
                    ? _buildEmptyState(context)
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200) {
                            controller.loadMoreNotifications();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          itemCount: controller.notifications.length + 1,
                          itemBuilder: (context, index) {
                            if (index == controller.notifications.length) {
                              return Obx(
                                () => controller.isLoadingMoreNotifs.value
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColor.primaryGreen,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              );
                            }

                            return NotificationCard(
                              notification: controller.notifications[index],
                              onTap: () =>
                                  controller.handleNotificationTap(index),
                            );
                          },
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 80.sp,
              color: context.grey.withOpacity(0.4),
            ),
            SizedBox(height: 15.h),
            Text(
              "noNotifications".tr,
              style: TextStyle(color: context.grey, fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }
}
