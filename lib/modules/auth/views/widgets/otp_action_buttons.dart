import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/shared/custom_app_button.dart';
import '../../controllers/auth_controller.dart';

class OtpActionButtons extends GetView<AuthController> {
  const OtpActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Text(
                "Didn't receive the code?".tr,
                style: TextStyle(color: context.grey, fontSize: 14.sp),
              ),
              SizedBox(height: 15.h),

              Obx(
                () => CustomAppButton(
                  text: controller.canResend.value
                      ? "Resend".tr
                      : "${"Resend".tr} (${controller.timerSeconds}s)",
                  onPressed: controller.canResend.value
                      ? () => controller.resendCode()
                      : null,
                  isLoading: controller.isLoading.value,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),

        CustomAppButton(
          text: "Edit Phone Number".tr,
          isOutlined: true,
          onPressed: () {
            controller.isOtpStep.value = false;
            controller.currentStep.value = 0;
          },
        ),
      ],
    );
  }
}
