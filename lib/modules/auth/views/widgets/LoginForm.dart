import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/shared/custom_app_button.dart';
import '../../../../../core/shared/custom_app_text_field.dart';
import '../../../../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';

class LoginForm extends StatelessWidget {
  final AuthController controller;
  const LoginForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: context.black.withOpacity(0.1),
            blurRadius: 20.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'enterPhoneNumber'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: context.grey,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'weWillSendVerificationCode'.tr,
              style: TextStyle(fontSize: 13.sp, color: context.grey),
            ),
            SizedBox(height: 24.h),
            CustomTextField(
              controller: controller.phoneController,
              label: 'phoneNumber'.tr,
              hint: '09xxxxxxxx'.tr,
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (val) => AppValidator.validatePhone(val),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 24.h),
            Obx(
              () => CustomAppButton(
                text: 'sendCode'.tr,
                isLoading: controller.isLoading.value,
                onPressed: () => controller.sendOtp(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
