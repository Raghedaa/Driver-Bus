import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_color.dart';

class StatusDropdownSelector extends StatelessWidget {
  final RxString value;
  final List<String> options;
  final IconData icon;
  final Function(String?) onChanged;

  const StatusDropdownSelector({
    super.key,
    required this.value,
    required this.options,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: context.textTertiaryColor.withOpacity(0.2)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value.value,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: context.textTertiaryColor,
            ),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Row(
                  children: [
                    Icon(icon, color: AppColor.primaryGreen, size: 20.sp),
                    SizedBox(width: 10.w),
                    Text(
                      option.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
