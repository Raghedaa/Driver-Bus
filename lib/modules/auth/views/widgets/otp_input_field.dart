import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../../../../../core/shared/verification_code_field.dart';
import '../../controllers/auth_controller.dart';

class OtpInputField extends GetView<AuthController> {
  const OtpInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return VerificationCodeField(
      length: 6,
      controller: controller.otpController,
      onCompleted: (code) => controller.verifyAndLogin(code),
    );
  }
}
