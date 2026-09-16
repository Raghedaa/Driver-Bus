import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../data/models/trip_model.dart';
import '../../../../../routes/app_routes/app_routes.dart';
import '../../controllers/schedule_controller.dart';

class TripCard extends StatelessWidget {
  final TripModel trip;
  final ScheduleController controller;

  const TripCard({super.key, required this.trip, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Get.toNamed(
          AppRoutes.tripDetails,
          arguments: trip,
        );

        if (result is TripModel) {
          controller.updateTripInList(result);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: context.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: context.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    trip.statusDisplayName,
                    style: TextStyle(
                      color: AppColor.primaryGreen,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "ID: #${trip.id}",
                  style: TextStyle(color: context.grey, fontSize: 12.sp),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            _buildLocationRow(
              Icons.radio_button_off,
              "ORIGIN".tr,
              trip.pickupLocation,
              context,
              isFirst: true,
            ),
            _buildLocationRow(
              Icons.circle,
              "DESTINATION".tr,
              trip.destination,
              context,
              isLast: true,
            ),
            SizedBox(height: 12.h),
            Divider(color: context.grey.withOpacity(0.2)),
            SizedBox(height: 8.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            size: 16.sp,
                            color: context.grey,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              trip.departureTimeFormatted,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: context.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        trip.tripDuration,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, color: context.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                if (trip.hasMap)
                  ElevatedButton(
                    onPressed: () => controller.viewMap(trip),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryGreen,
                      foregroundColor: AppColor.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      "View Map".tr,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${trip.passengerCount} ${"passengers".tr}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.grey, fontSize: 12.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "${trip.fareFormatted} / ${"seat".tr}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColor.primaryGreen,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    String label,
    String city,
    BuildContext context, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, size: 16.sp, color: context.black),
            if (!isLast)
              Container(
                width: 1.5,
                height: 35.h,
                color: context.grey.withOpacity(0.3),
              ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.grey,
                  fontSize: 10.sp,
                  letterSpacing: 1,
                ),
              ),
              Text(
                city,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: context.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isLast) SizedBox(height: 15.h),
            ],
          ),
        ),
      ],
    );
  }
}
