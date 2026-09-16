import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void show({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.snackbar(
      title.tr,
      message.tr,
      backgroundColor: isError
          ? AppColor.error.withOpacity(0.8)
          : AppColor.primaryGreen.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }

  static void showSuccess(String message) {
    show(title: "success", message: message, isError: false);
  }

  static void showError(String message) {
    show(title: "error", message: message, isError: true);
  }
}
