import 'dart:io';

import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            onTap: () => controller.pickImage(),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: context.cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Obx(() {
                ImageProvider? backgroundImage;

                if (controller.profileImagePath.value.isNotEmpty) {
                  backgroundImage = FileImage(
                    File(controller.profileImagePath.value),
                  );
                } else if (controller.driverData.value?.avatar != null &&
                    controller.driverData.value!.avatar!.isNotEmpty) {
                  backgroundImage = NetworkImage(
                    controller.driverData.value!.avatar!,
                  );
                }

                return CircleAvatar(
                  radius: 55.r,
                  backgroundColor: AppColor.primaryGreen.withOpacity(0.1),
                  backgroundImage: backgroundImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (backgroundImage == null &&
                          !controller.isUpdating.value)
                        Icon(
                          Icons.person,
                          size: 60.sp,
                          color: AppColor.primaryGreen,
                        ),

                      if (controller.isUpdating.value)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColor.white,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          GestureDetector(
            onTap: () => controller.pickImage(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColor.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).cardColor,
                  width: 2,
                ),
              ),
              child: Icon(Icons.camera_alt, color: AppColor.white, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }
}
