// import 'package:driver_bus_app/core/constants/app_color.dart';
// import 'package:driver_bus_app/core/extensions/context_extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// import '../../../../core/shared/custom_app_button.dart';
// import '../../../../routes/app_routes/app_routes.dart';
// import '../../controllers/passenger_controller.dart';
// import '../widgets/passenger_card.dart';
// import '../widgets/passenger_search_bar.dart';
// import '../widgets/passenger_stats_row.dart';
// import '../widgets/route_info_card.dart';
//
// class PassengerListView extends StatelessWidget {
//   const PassengerListView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(PassengerController());
//
//     return Scaffold(
//       backgroundColor: context.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: Padding(
//           padding: EdgeInsets.all(8.w),
//           child: CircleAvatar(
//             backgroundColor: context.cardColor,
//             child: IconButton(
//               icon: Icon(
//                 Icons.arrow_back_ios_new,
//                 size: 18,
//                 color: AppColor.black,
//               ),
//               onPressed: () => Get.back(),
//             ),
//           ),
//         ),
//         title: Text(
//           "Passenger List".tr,
//           style: TextStyle(
//             color: context.textPrimaryColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           const RouteInfoCard(),
//           PassengerSearchBar(controller: controller),
//           const PassengerStatsRow(),
//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading.value && controller.passengers.isEmpty) {
//                 return Center(
//                   child: CircularProgressIndicator(
//                     color: AppColor.primaryGreen,
//                   ),
//                 );
//               }
//
//               if (controller.passengers.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.people_outline,
//                         size: 64.sp,
//                         color: Colors.grey,
//                       ),
//                       SizedBox(height: 16.h),
//                       Text(
//                         "No passengers found".tr,
//                         style: TextStyle(
//                           color: context.textTertiaryColor,
//                           fontSize: 16.sp,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               return RefreshIndicator(
//                 color: AppColor.primaryGreen,
//                 onRefresh: () => controller.loadPassengersFromApi(),
//                 child: NotificationListener<ScrollNotification>(
//                   onNotification: (scrollInfo) {
//                     if (scrollInfo.metrics.pixels ==
//                             scrollInfo.metrics.maxScrollExtent &&
//                         !controller.isLoading.value) {
//                       controller.loadMorePassengers();
//                     }
//                     return false;
//                   },
//                   child: ListView.builder(
//                     padding: EdgeInsets.symmetric(horizontal: 20.w),
//                     itemCount: controller.filteredPassengers.length + 1,
//                     itemBuilder: (context, index) {
//                       if (index == controller.filteredPassengers.length) {
//                         return controller.isLoading.value
//                             ? Padding(
//                                 padding: EdgeInsets.all(20.h),
//                                 child: Center(
//                                   child: CircularProgressIndicator(),
//                                 ),
//                               )
//                             : SizedBox.shrink();
//                       }
//                       return PassengerCard(
//                         passenger: controller.filteredPassengers[index],
//                       );
//                     },
//                   ),
//                 ),
//               );
//             }),
//           ),
//           _buildScanButton(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildScanButton() {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       child: CustomAppButton(
//         text: "Scan Ticket".tr,
//         icon: Icons.qr_code_scanner,
//         onPressed: () => Get.toNamed(AppRoutes.qrScanner),
//       ),
//     );
//   }
// }

import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/shared/custom_app_button.dart';
import '../../../../routes/app_routes/app_routes.dart';
import '../../controllers/passenger_controller.dart';
import '../widgets/passenger_card.dart';
import '../widgets/passenger_search_bar.dart';
import '../widgets/passenger_stats_row.dart';
import '../widgets/route_info_card.dart';

class PassengerListView extends StatelessWidget {
  const PassengerListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<PassengerController>()
        ? Get.find<PassengerController>()
        : Get.put(PassengerController());

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: CircleAvatar(
            backgroundColor: context.cardColor,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColor.black,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Text(
          "Passenger List".tr,
          style: TextStyle(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const RouteInfoCard(),
          PassengerSearchBar(controller: controller),
          const PassengerStatsRow(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.passengers.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryGreen,
                  ),
                );
              }

              if (controller.passengers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "No passengers found".tr,
                        style: TextStyle(
                          color: context.textTertiaryColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColor.primaryGreen,
                onRefresh: () => controller.loadPassengersFromApi(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        !controller.isLoading.value) {
                      controller.loadMorePassengers();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: controller.filteredPassengers.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.filteredPassengers.length) {
                        return controller.isLoading.value
                            ? Padding(
                                padding: EdgeInsets.all(20.h),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : SizedBox.shrink();
                      }
                      return PassengerCard(
                        passenger: controller.filteredPassengers[index],
                      );
                    },
                  ),
                ),
              );
            }),
          ),
          _buildScanButton(),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: CustomAppButton(
        text: "Scan Ticket".tr,
        icon: Icons.qr_code_scanner,
        onPressed: () => Get.toNamed(AppRoutes.qrScanner),
      ),
    );
  }
}
