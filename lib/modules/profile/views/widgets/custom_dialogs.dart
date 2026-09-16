import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_color.dart';

class CustomDialogs {
  static void showLogoutDialog({required VoidCallback onConfirm}) {
    Get.defaultDialog(
      title: "logout".tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "logout_confirmation_message".tr,
      textConfirm: "yes".tr,
      textCancel: "no".tr,
      confirmTextColor: Colors.white,
      cancelTextColor: AppColor.primaryGreen,
      buttonColor: AppColor.primaryGreen,
      barrierDismissible: true,
      contentPadding: const EdgeInsets.all(20),
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }
}
