import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/trip_details_controller.dart';

class TripMapPreview extends StatelessWidget {
  const TripMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripDetailsController>();

    return GestureDetector(
      onTap: () {
        if (controller.currentTrip != null) {
          Get.toNamed(
            '/trip-tracking',
            arguments: {'tripId': controller.currentTrip!.id},
          );
        }
      },
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            colors: [
              AppColor.primaryGreen.withOpacity(0.8),
              AppColor.primaryGreen.withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.map_outlined,
                size: 80.sp,
                color: AppColor.white.withOpacity(0.3),
              ),
            ),
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColor.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trip_origin,
                            color: AppColor.primaryGreen,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              controller.pickupLocation.value,
                              style: const TextStyle(
                                color: AppColor.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          SizedBox(width: 7.w),
                          Container(
                            height: 20.h,
                            width: 2.w,
                            color: AppColor.primaryGreen.withOpacity(0.5),
                          ),
                          SizedBox(width: 15.w),
                          Obx(
                            () => Text(
                              controller.duration.value,
                              style: TextStyle(
                                color: AppColor.primaryGreen,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColor.error,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              controller.destination.value,
                              style: const TextStyle(
                                color: AppColor.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16.h,
              right: 16.w,
              child: Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    controller.distance.value,
                    style: TextStyle(
                      color: AppColor.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
