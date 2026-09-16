import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/constants/app_color.dart';
import '../../../../data/models/notification_model.dart';
import '../../../home/schedule/controllers/schedule_controller.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Get.isDarkMode;

    return Obx(() {
      Get.find<ScheduleController>().currentLanguage.value;

      String timeStr = timeago.format(
        notification.timestamp,
        locale: Get.locale?.languageCode == 'ar' ? 'ar' : 'en_short',
      );

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: notification.isRead
                ? (isDark ? context.cardColor.withOpacity(0.5) : context.white)
                : (AppColor.primaryGreen.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: notification.isRead
                  ? Colors.transparent
                  : AppColor.primaryGreen.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconWithBadge(),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          timeStr,
                          style: TextStyle(
                            color: context.grey,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      notification.body.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.grey,
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildIconWithBadge() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.trip:
        iconData = Icons.directions_bus_filled;
        iconColor = AppColor.primaryGreen;
        break;
      case NotificationType.alert:
        iconData = Icons.warning_rounded;
        iconColor = AppColor.orange;
        break;
      case NotificationType.message:
        iconData = Icons.mark_as_unread_sharp;
        iconColor = AppColor.primaryGreen;
        break;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 22.sp),
        ),
        if (!notification.isRead)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 11.w,
              height: 11.h,
              decoration: BoxDecoration(
                color: AppColor.green,
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.white, width: 1.5.w),
              ),
            ),
          ),
      ],
    );
  }
}
