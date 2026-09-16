import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/passenger_controller.dart';

class PassengerSearchBar extends StatelessWidget {
  final PassengerController controller;
  const PassengerSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: AppColor.primaryGreen,
            selectionColor: AppColor.primaryGreen.withOpacity(0.3),
            cursorColor: AppColor.primaryGreen,
          ),
        ),
        child: TextField(
          cursorColor: AppColor.primaryGreen,
          onChanged: (val) => controller.searchQuery.value = val,
          style: TextStyle(color: context.textPrimaryColor),
          decoration: InputDecoration(
            hintText: "Search by name or seat...".tr,
            hintStyle: TextStyle(color: context.textTertiaryColor),
            prefixIcon: Icon(Icons.search, color: context.textTertiaryColor),

            filled: true,
            fillColor: context.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
