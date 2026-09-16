import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../widgets/otp_action_buttons.dart';
import '../widgets/otp_header.dart';
import '../widgets/otp_input_field.dart';

class PhoneVerificationView extends GetView<AuthController> {
  const PhoneVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const OtpHeader(),
          SizedBox(height: 40.h),
          const OtpInputField(),
          SizedBox(height: 40.h),
          const OtpActionButtons(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
