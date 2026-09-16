import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../trip_details/controllers/trip_details_controller.dart';

class RouteInfoCard extends StatelessWidget {
  const RouteInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final detailsController = Get.find<TripDetailsController>();

    final trip = detailsController.currentTrip;

    if (trip == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: context.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: context.black.withOpacity(0.01), blurRadius: 6),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildInfoColumn(
              context,
              "ROUTE".tr,
              "${trip.pickupLocation} ➔ ${trip.destination}",
              CrossAxisAlignment.start,
              isRoute: true,
            ),
          ),

          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: _buildInfoColumn(
              context,
              "DEPARTURE".tr,
              trip.departureTimeFormatted,
              CrossAxisAlignment.end,
              isRoute: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String title,
    String value,
    CrossAxisAlignment alignment, {
    required bool isRoute,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10.sp,
            color: context.textTertiaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          maxLines: isRoute ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignment == CrossAxisAlignment.start
              ? TextAlign.left
              : TextAlign.right,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.primaryGreen,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
