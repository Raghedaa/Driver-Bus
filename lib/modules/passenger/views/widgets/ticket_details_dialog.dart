import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_color.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../data/models/passenger_model.dart';
import '../../../../routes/app_routes/app_routes.dart';
import '../../controllers/passenger_controller.dart';

class TicketDetailsDialog extends StatelessWidget {
  const TicketDetailsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PassengerController>();
    final passenger = controller.currentScannedPassenger.value;

    if (passenger == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: context.white,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, passenger),
          SizedBox(height: 24.h),
          _buildInfoRow(context, "passenger".tr, passenger.name),
          _buildInfoRow(context, "phone".tr, passenger.phoneNumber ?? 'N/A'),
          _buildInfoRow(context, "seat".tr, passenger.seatNumbersFormatted),
          _buildInfoRow(
            context,
            "status".tr,
            passenger.status.tr.toUpperCase(),
            isPaid: passenger.isPaid,
          ),
          SizedBox(height: 30.h),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PassengerModel passenger) {
    final isVerified = passenger.isPaid;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isVerified
                ? AppColor.success.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isVerified ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isVerified ? AppColor.success : AppColor.orange,
            size: 40.sp,
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isVerified ? "ticketVerified".tr : "ticketStatus".tr,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: context.black,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(isVerified, passenger),
      ],
    );
  }

  Widget _buildStatusBadge(bool isVerified, PassengerModel passenger) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isVerified ? AppColor.primaryGreen : AppColor.orange,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        isVerified ? "VERIFIED".tr : passenger.status.tr.toUpperCase(),
        style: TextStyle(
          color: AppColor.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isPaid = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: context.grey, fontSize: 14.sp),
          ),
          Text(
            value,
            style: TextStyle(
              color: isPaid ? AppColor.success : context.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.qrScanner);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryGreen,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              "nextScan".tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
