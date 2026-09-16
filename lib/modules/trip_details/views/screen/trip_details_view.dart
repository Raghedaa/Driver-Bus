import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/shared/custom_app_button.dart';
import '../../controllers/trip_details_controller.dart';
import '../widgets/trip_details_app_bar.dart';
import '../widgets/trip_map_preview.dart';
import '../widgets/trip_route_header.dart';
import '../widgets/trip_stats_grid.dart';

class TripDetailsView extends StatelessWidget {
  const TripDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TripDetailsController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back(result: controller.currentTrip);
      },
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: TripDetailsAppBar(controller: controller),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TripMapPreview(),
              SizedBox(height: 24.h),

              TripRouteHeader(controller: controller),
              SizedBox(height: 24.h),

              TripStatsGrid(controller: controller),
              SizedBox(height: 30.h),

              Center(
                child: Obx(
                  () => CustomAppButton(
                    text: controller.actionButtonText,
                    isLoading: controller.isUpdating.value,
                    onPressed: controller.canUpdateStatus
                        ? () => controller.startTripAction()
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
