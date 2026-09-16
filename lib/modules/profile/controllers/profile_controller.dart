import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api_service.dart';
import '../../../core/shared/custom_snackbar.dart';
import '../../../data/models/driver_model.dart';
import '../../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository;
  final Connectivity _connectivity = Connectivity();

  ProfileController(this._repository);

  var isLoading = true.obs;
  var isUpdating = false.obs;
  var driverData = Rxn<DriverModel>();

  var isOnline = true.obs;

  var profileImagePath = ''.obs;

  final ImagePicker _picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();

    _checkInitialConnectivity();
    _listenToConnectivityChanges();
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> result = await _connectivity
        .checkConnectivity();
    if (result.isNotEmpty && result.first != ConnectivityResult.none) {
      isOnline.value = true;
    } else {
      isOnline.value = false;
    }
    fetchProfile(isOnline: isOnline.value);
  }

  void _listenToConnectivityChanges() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty) {
        isOnline.value = results.first != ConnectivityResult.none;
      }
    });
  }

  Future<void> fetchProfile({bool isOnline = true}) async {
    try {
      isLoading.value = true;
      final response = await _repository.getDriverProfile(isOnline: isOnline);
      if (response.statusCode == 200 && response.data['data'] != null) {
        driverData.value = DriverModel.fromJson(response.data['data']);
        _fillControllers();
      }
    } catch (e) {
      CustomSnackBar.showError('profile_load_error'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void _fillControllers() {
    nameController.text = driverData.value?.name ?? "";
    phoneController.text = driverData.value?.phone ?? "";
    emailController.text = driverData.value?.email ?? "";
  }

  Future<void> updateProfile() async {
    try {
      if (!isOnline.value) {
        CustomSnackBar.showError('connection_required'.tr);
        return;
      }

      String? updatedName;
      String? updatedPhone;
      String? updatedEmail;

      if (nameController.text != (driverData.value?.name ?? "")) {
        updatedName = nameController.text;
      }
      if (phoneController.text != (driverData.value?.phone ?? "")) {
        updatedPhone = phoneController.text;
      }
      if (emailController.text != (driverData.value?.email ?? "")) {
        updatedEmail = emailController.text;
      }

      if (updatedName == null &&
          updatedPhone == null &&
          updatedEmail == null &&
          profileImagePath.value.isEmpty) {
        CustomSnackBar.showError('no_changes_made'.tr);
        return;
      }

      isUpdating.value = true;

      final response = await _repository.updateDriverProfile(
        name: updatedName,
        phone: updatedPhone,
        email: updatedEmail,
        imagePath: profileImagePath.value.isNotEmpty
            ? profileImagePath.value
            : null,
        isOnline: isOnline.value,
      );

      if (response.statusCode == 200) {
        CustomSnackBar.showSuccess('profile_update_success'.tr);
        profileImagePath.value = '';
        fetchProfile(isOnline: isOnline.value);
      }
    } catch (e) {
      if (e.toString().contains('connection_required')) {
        CustomSnackBar.showError('connection_required'.tr);
      } else {
        CustomSnackBar.showError('profile_update_error'.tr);
      }
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> uploadJustImage() async {
    try {
      isUpdating.value = true;

      final response = await _repository.updateDriverProfile(
        imagePath: profileImagePath.value,
        isOnline: isOnline.value,
      );

      if (response.statusCode == 200) {
        fetchProfile(isOnline: isOnline.value);
        profileImagePath.value = '';
        CustomSnackBar.showSuccess('image_update_success'.tr);
      }
    } catch (e) {
      if (e.toString().contains('connection_required')) {
        CustomSnackBar.showError('connection_required'.tr);
      } else {
        CustomSnackBar.showError('image_upload_error'.tr);
      }
    } finally {
      isUpdating.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        profileImagePath.value = pickedFile.path;
        await uploadJustImage();
      }
    } catch (e) {
      CustomSnackBar.showError('image_pick_error'.tr);
    }
  }

  void logout() {
    Get.find<ApiService>().logout(isAutomatic: false);
  }

  void back() {
    Get.back();
  }
}
