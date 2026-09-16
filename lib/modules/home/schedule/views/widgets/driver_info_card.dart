import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/schedule_controller.dart';

class DriverInfoCard extends StatelessWidget {
  final ScheduleController controller;
  const DriverInfoCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: LinearProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColor.primaryGreen,
              ),
              backgroundColor: AppColor.primaryGreen.withOpacity(0.1),
            ),
          ),
        );
      }

      final driver = controller.driver.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "welcome_back".tr,
                    style: TextStyle(
                      color: context.textTertiaryColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    "${"captain ".tr}${driver?.name ?? ''}",
                    style: TextStyle(
                      color: context.textPrimaryColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      );
    });
  }
}
