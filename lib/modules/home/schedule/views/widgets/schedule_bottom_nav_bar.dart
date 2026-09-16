import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/constants/app_color.dart';
import '../../controllers/schedule_controller.dart';

class ScheduleBottomNavBar extends StatelessWidget {
  final ScheduleController controller;
  const ScheduleBottomNavBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.currentIndex.value;

      return BottomAppBar(
        color: context.white,
        elevation: 16,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.r,
        height: 72.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(
                    context,
                    icon: current == 0
                        ? Icons.notifications_rounded
                        : Icons.notifications_none_rounded,
                    label: "Notifications".tr,
                    active: current == 0,
                    onTap: () => controller.changePage(0),
                  ),
                  _navItem(
                    context,
                    icon: current == 2
                        ? Icons.settings_rounded
                        : Icons.settings_outlined,
                    label: "Settings".tr,
                    active: current == 2,
                    onTap: () => controller.changePage(2),
                  ),
                ],
              ),
            ),

            SizedBox(width: 70.w),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(
                    context,
                    icon: current == 1
                        ? Icons.directions_bus_rounded
                        : Icons.directions_bus_outlined,
                    label: "Trips".tr,
                    active: current == 1,
                    onTap: () => controller.changePage(1),
                  ),
                  _navItem(
                    context,
                    icon: current == 3
                        ? Icons.person_rounded
                        : Icons.person_outline_rounded,
                    label: "Profile".tr,
                    active: current == 3,
                    onTap: () => controller.changePage(3),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: active ? AppColor.primaryGreen : context.grey,
                size: 22.r,
              ),
              SizedBox(height: 4.h),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? AppColor.primaryGreen : context.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
