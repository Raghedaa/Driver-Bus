import 'package:driver_bus_app/modules/trip_details/views/widgets/trip_info_stat_card.dart';
import 'package:driver_bus_app/routes/app_routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/trip_details_controller.dart';

class TripStatsGrid extends StatelessWidget {
  final TripDetailsController controller;

  const TripStatsGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  if (controller.currentTrip != null) {
                    Get.toNamed(
                      AppRoutes.passengerList,
                      arguments: {'trip_id': controller.currentTrip!.id},
                    );
                  } else {
                    Get.toNamed(AppRoutes.passengerList);
                  }
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Obx(
                  () => TripInfoStatCard(
                    label: "passengers".tr,
                    value: controller.passengerCount.value,
                    icon: Icons.people_outline,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Obx(
                () => TripInfoStatCard(
                  label: "distance".tr,
                  value: controller.distance.value,
                  icon: Icons.map_outlined,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => TripInfoStatCard(
                  label: "tripFare".tr,
                  value: controller.fare.value,
                  icon: Icons.monetization_on_outlined,
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Obx(
                () => TripInfoStatCard(
                  label: "tripDuration".tr,
                  value: controller.duration.value,
                  icon: Icons.timer_outlined,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Obx(
          () => TripInfoStatCard(
            label: "vehicle".tr,
            value: controller.vehicleNumber.value,
            icon: Icons.directions_bus,
            isFullWidth: true,
          ),
        ),
      ],
    );
  }
}
