import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/trip_details_controller.dart';

class TripRouteHeader extends StatelessWidget {
  final TripDetailsController controller;

  const TripRouteHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColor.primaryGreen,
                size: 18.sp,
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  "${controller.pickupLocation.value} ${Get.locale?.languageCode == 'ar' ? '←' : '➔'} ${controller.destination.value}",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColor.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "${"scheduledDeparture".tr}: ${controller.departureTime.value}",
            style: TextStyle(color: context.textTertiaryColor, fontSize: 14.sp),
          ),

          SizedBox(height: 2.h),
          Text(
            "${"estimatedArrival".tr}: ${controller.arrivalTime.value}",
            style: TextStyle(color: context.textTertiaryColor, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
