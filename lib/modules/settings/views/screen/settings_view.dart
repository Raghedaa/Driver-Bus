import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_color.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../home/schedule/controllers/schedule_controller.dart';
import '../../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.find<ScheduleController>().changePage(1);
              Get.back();
            },
          ),
          title: Text(
            "settings".tr,
            style: TextStyle(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: context.textPrimaryColor),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              _buildSettingTile(
                context,
                icon: Icons.language,
                title: "language".tr,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => controller.changeLanguage('ar'),
                      child: Text(
                        "العربية".tr,
                        style: TextStyle(color: AppColor.primaryGreen),
                      ),
                    ),
                    Text(
                      "|",
                      style: TextStyle(color: context.textTertiaryColor),
                    ),
                    TextButton(
                      onPressed: () => controller.changeLanguage('en'),
                      child: Text(
                        "English".tr,
                        style: TextStyle(color: AppColor.primaryGreen),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: context.textTertiaryColor.withOpacity(0.2)),

              _buildSettingTile(
                context,
                icon: Icons.dark_mode,
                title: "darkMode".tr,
                trailing: Switch(
                  value: themeController.isDarkMode.value,
                  onChanged: (val) {
                    themeController.toggleTheme();
                  },
                  activeColor: AppColor.primaryGreen,
                ),
              ),

              Divider(color: context.textTertiaryColor.withOpacity(0.2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColor.primaryGreen),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w300,
          color: context.textPrimaryColor,
        ),
      ),
      trailing: trailing,
    );
  }
}
