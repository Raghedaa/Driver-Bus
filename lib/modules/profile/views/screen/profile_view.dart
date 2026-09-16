import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/shared/custom_app_button.dart';
import '../../../home/schedule/controllers/schedule_controller.dart';
import '../../controllers/profile_controller.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/detail_info_tile.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/info_grid_cards.dart';
import '../widgets/profile_avatar.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("driver_profile_title".tr),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColor.black),
          onPressed: () {
            Get.find<ScheduleController>().changePage(1);
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_note, size: 28.sp),
            onPressed: () {
              Get.bottomSheet(
                EditProfileSheet(controller: controller),
                isScrollControlled: true,
                ignoreSafeArea: false,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.primaryGreen),
          );
        }

        final driver = controller.driverData.value;
        if (driver == null) {
          return Center(child: Text("no_data_found".tr));
        }

        return RefreshIndicator(
          color: Colors.white,
          backgroundColor: AppColor.primaryGreen,
          onRefresh: () => controller.fetchProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                const ProfileAvatar(),
                SizedBox(height: 16.h),
                Text(
                  driver.name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: AppColor.primaryGreen, size: 16.sp),
                    Text(
                      " ${driver.rating} ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryGreen,
                      ),
                    ),
                    Text(
                      "(${driver.totalTrips} ${'trips'.tr})",
                      style: TextStyle(
                        color: context.textTertiaryColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    InfoGridCards(
                      title: "license_number".tr,
                      value: driver.licenseNumber ?? "---",
                    ),
                  ],
                ),

                SizedBox(height: 24.h),
                DetailInfoTile(
                  title: "username".tr,
                  value: "@${driver.username}",
                  icon: Icons.alternate_email,
                ),
                DetailInfoTile(
                  title: "address".tr,
                  value: driver.address ?? "no_address_set".tr,
                  icon: Icons.location_on_outlined,
                ),
                DetailInfoTile(
                  title: "email_address".tr,
                  value: driver.email,
                  icon: Icons.mail_outline,
                ),
                DetailInfoTile(
                  title: "phone".tr,
                  value: driver.phone ?? "---",
                  icon: Icons.phone_android,
                ),
                SizedBox(height: 32.h),
                CustomAppButton(
                  text: "logout".tr,
                  icon: Icons.logout_rounded,
                  isOutlined: true,
                  onPressed: () {
                    CustomDialogs.showLogoutDialog(
                      onConfirm: () => controller.logout(),
                    );
                  },
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        );
      }),
    );
  }
}
