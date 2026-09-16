import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../core/services/notification_service..dart';
import '../../../../core/shared/custom_snackbar.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../routes/app_routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = Get.find<AuthRepository>();
  final GetStorage _box = GetStorage();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isOtpStep = false.obs;
  var currentStep = 0.obs;

  var timerSeconds = 45.obs;
  var canResend = false.obs;
  Timer? _timer;

  void startTimer() {
    canResend.value = false;
    timerSeconds.value = 45;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        canResend.value = true;
        _timer?.cancel();
      }
    });
  }

  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await _repository.sendOtp(phoneController.text.trim());

      if (response.statusCode == 200 || response.statusCode == 201) {
        isOtpStep.value = true;
        currentStep.value = 1;
        startTimer();
        CustomSnackBar.showSuccess("otpSent");
      }
    } on dio.DioException catch (e) {
      String errorMessage = "sendFailed";
      CustomSnackBar.showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyAndLogin(String code) async {
    isLoading.value = true;
    try {
      final response = await _repository.login(
        phoneController.text.trim(),
        code,
      );

      if (response.statusCode == 200) {
        String token = response.data['access_token'];
        _box.write("token", token);
        _box.write("step", "2");

        if (Get.isRegistered<NotificationService>()) {
          Get.find<NotificationService>().syncTokenToServer();
        }

        CustomSnackBar.showSuccess("loginSuccess");
        Get.offAllNamed(AppRoutes.schedule);
      }
    } on dio.DioException catch (e) {
      otpController.clear();

      String errorMessage = "invalidCode";

      CustomSnackBar.showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendCode() async {
    if (!canResend.value) return;

    isLoading.value = true;
    try {
      final response = await _repository.sendOtp(phoneController.text.trim());

      if (response.statusCode == 200 || response.statusCode == 201) {
        startTimer();
        CustomSnackBar.showSuccess("otpResent");
      }
    } on dio.DioException catch (e) {
      String errorMessage = "resendFailed";
      CustomSnackBar.showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
