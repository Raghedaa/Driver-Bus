import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_color.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/shared/custom_app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../controllers/profile_controller.dart';

class EditProfileSheet extends StatelessWidget {
  final ProfileController controller;
  EditProfileSheet({super.key, required this.controller});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),

      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                Text(
                  "edit_profile".tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 25.h),

                CustomTextField(
                  controller: controller.nameController,
                  label: "name".tr,
                  hint: "enter_your_name".tr,
                  icon: Icons.person_outline,
                  validator: (v) => AppValidator.validateName(v),
                ),
                SizedBox(height: 16.h),

                CustomTextField(
                  controller: controller.phoneController,
                  label: "phone_number".tr,
                  hint: "09xxxxxxxx",
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                  validator: (v) => AppValidator.validatePhone(v),
                ),
                SizedBox(height: 16.h),

                CustomTextField(
                  controller: controller.emailController,
                  label: "email_address".tr,
                  hint: "example@mail.com",
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => AppValidator.validateEmail(v),
                ),
                SizedBox(height: 30.h),

                Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryGreen,
                      minimumSize: Size(double.infinity, 52.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: controller.isUpdating.value
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              controller.updateProfile();
                            }
                          },
                    child: controller.isUpdating.value
                        ? const CircularProgressIndicator(color: AppColor.white)
                        : Text(
                            "save_changes".tr,
                            style: const TextStyle(color: AppColor.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      //  ),
    );
  }
}
