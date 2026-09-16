import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_color.dart';
import '../../controllers/schedule_controller.dart';

class StatusTabs extends StatelessWidget {
  final ScheduleController controller;
  const StatusTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: controller.statusOptions.map((status) {
              bool isSelected = controller.selectedStatus.value == status;
              return GestureDetector(
                onTap: () => controller.changeStatus(status),
                child: Container(
                  margin: EdgeInsets.only(right: 24.w),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? AppColor.primaryGreen
                            : Colors.transparent,
                        width: 2.w,
                      ),
                    ),
                  ),
                  child: Text(
                    controller.getStatusText(status),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? AppColor.primaryGreen : context.grey,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
