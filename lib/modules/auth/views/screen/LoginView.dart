import 'package:driver_bus_app/modules/auth/views/screen/phone_verification_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../widgets/LoginForm.dart';
import '../widgets/LoginLogo.dart';
import '../widgets/login_footer.dart';
import '../widgets/login_header.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Obx(() {
              if (controller.isOtpStep.value) {
                return Column(
                  children: [
                    SizedBox(height: 50.h),
                    const PhoneVerificationView(),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoginHeader(),
                  LoginForm(controller: controller),
                  SizedBox(height: 40.h),
                  const LoginFooter(),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
