import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_color.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40.h),
        Center(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColor.primaryGreen,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.directions_bus,
              color: AppColor.white,
              size: 50.sp,
            ),
          ),
        ),
        SizedBox(height: 32.h),
        Center(
          child: Column(
            children: [
              Text(
                'welcome'.tr,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryGreen,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'loginToStart'.tr,
                style: TextStyle(fontSize: 16.sp, color: context.grey),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}
