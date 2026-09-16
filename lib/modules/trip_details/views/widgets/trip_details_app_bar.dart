import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_color.dart';
import '../../controllers/trip_details_controller.dart';

class TripDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TripDetailsController controller;

  const TripDetailsAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.transparent,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.all(8.w),
        child: CircleAvatar(
          backgroundColor: context.cardColor,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColor.black,
            ),

            onPressed: () => Get.back(result: controller.currentTrip),
          ),
        ),
      ),
      title: Text(
        "tripDetails".tr,
        style: TextStyle(
          color: context.textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        Obx(
          () => Container(
            margin: EdgeInsets.all(8.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: controller.statusColor.value.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Center(
              child: Text(
                controller.tripStatusDisplay.value,
                style: TextStyle(
                  color: controller.statusColor.value,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
