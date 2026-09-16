import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:driver_bus_app/modules/notifications/views/screen/notifications_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../profile/views/screen/profile_view.dart';
import '../../../../settings/views/screen/settings_view.dart';
import '../../controllers/schedule_controller.dart';
import '../widgets/driver_info_card.dart';
import '../widgets/schedule_bottom_nav_bar.dart';
import '../widgets/schedule_empty_state.dart';
import '../widgets/status_tabs.dart';
import '../widgets/trip_card.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final ScheduleController controller = Get.find<ScheduleController>();

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const NotificationsView(),
            _buildScheduleContent(controller),
            const SettingsView(),
            const ProfileView(),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(
        () => SizedBox(
          height: 64.r,
          width: 64.r,
          child: FloatingActionButton(
            elevation: 4,
            backgroundColor: controller.currentIndex.value == 1
                ? AppColor.primaryGreen
                : context.white,
            shape: CircleBorder(
              side: BorderSide(
                color: AppColor.primaryGreen.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            onPressed: () => controller.changePage(1),
            child: Icon(
              Icons.directions_bus_rounded,
              color: controller.currentIndex.value == 1
                  ? AppColor.white
                  : AppColor.primaryGreen,
              size: 28.r,
            ),
          ),
        ),
      ),

      bottomNavigationBar: ScheduleBottomNavBar(controller: controller),
    );
  }

  Widget _buildScheduleContent(ScheduleController controller) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColor.white,
        backgroundColor: AppColor.primaryGreen,
        onRefresh: () async => await controller.fetchTrips(),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 0),
                  child: DriverInfoCard(controller: controller),
                ),
                Obx(
                  () => controller.isOnline.value
                      ? const SizedBox.shrink()
                      : Positioned(
                          left: 35.w,
                          top: 30.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cloud_off_rounded,
                                  color: Colors.red.shade700,
                                  size: 11.r,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'offline_mode'.tr,
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: StatusTabs(controller: controller),
            ),
            Expanded(
              child: Obx(
                () => controller.filteredTrips.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 0.6.sh,
                          child: const ScheduleEmptyState(),
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200) {
                            controller.loadMoreTrips();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          itemCount: controller.filteredTrips.length + 1,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index == controller.filteredTrips.length) {
                              return Obx(
                                () => controller.isLoadingMore.value
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColor.primaryGreen,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              );
                            }
                            return TripCard(
                              trip: controller.filteredTrips[index],
                              controller: controller,
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
