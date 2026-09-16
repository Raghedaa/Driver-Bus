import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_color.dart';
import '../../controllers/auth_controller.dart';

class OtpHeader extends GetView<AuthController> {
  const OtpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Verify Phone".tr,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.primaryGreen,
          ),
        ),
        SizedBox(height: 12.h),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "We've sent a 6-digit code to your phone number".tr,
                style: TextStyle(color: context.grey, fontSize: 15.sp),
              ),
              TextSpan(
                text: " ${controller.phoneController.text}",
                style: TextStyle(
                  color: AppColor.primaryGreen,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
