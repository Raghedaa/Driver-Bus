import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_color.dart';
import '../../../../data/models/passenger_model.dart';

class PassengerCard extends StatelessWidget {
  final PassengerModel passenger;
  const PassengerCard({super.key, required this.passenger});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: context.textPrimaryColor.withOpacity(0.02),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                constraints: BoxConstraints(minWidth: 46.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    "seat_with_number".trParams({
                      'number': passenger.seatNumbersFormatted ?? '',
                    }),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passenger.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "PNR: ${passenger.pnrCode ?? 'N/A'}",
                      style: TextStyle(
                        color: context.textTertiaryColor,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusTag(),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailChip(
                context,
                Icons.phone,
                passenger.phoneNumber ?? 'N/A',
              ),
              _buildDetailChip(
                context,
                Icons.payment,
                passenger.totalPriceFormatted,
              ),
              _buildDetailChip(
                context,
                Icons.person,
                passenger.genderFormatted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.fillColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: context.textTertiaryColor),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag() {
    final isPaid = passenger.isPaid;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColor.success.withOpacity(0.1)
            : AppColor.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        isPaid ? "PAID".tr : "UNPAID".tr,
        style: TextStyle(
          color: isPaid ? AppColor.success : AppColor.error,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
