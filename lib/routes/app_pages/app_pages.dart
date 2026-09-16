import 'package:driver_bus_app/modules/home/schedule/views/screen/schedule_view.dart';
import 'package:driver_bus_app/modules/notifications/views/screen/notifications_view.dart';
import 'package:driver_bus_app/modules/profile/views/screen/profile_view.dart';
import 'package:driver_bus_app/modules/trip_details/views/screen/trip_details_view.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/screen/LoginView.dart';
import '../../modules/home/schedule/bindings/schedule_binding.dart';
import '../../modules/passenger/bindings/passenger_binding.dart';
import '../../modules/passenger/views/screen/passenger_list_view.dart';
import '../../modules/passenger/views/screen/qr_scanner_view.dart';
import '../../modules/trip_tracking/binding/trip_tracking_binding.dart';
import '../../modules/trip_tracking/view/trip_tracking_screen.dart';
import '../app_routes/app_routes.dart';

class AppPages {
  static final storage = GetStorage();
  static String get initialRoute {
    String? token = storage.read("token");

    if (token != null) {
      return AppRoutes.schedule;
    } else {
      return AppRoutes.login;
    }
  }

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.passengerList,
      page: () => const PassengerListView(),
      binding: PassengerBinding(),
    ),
    GetPage(
      name: AppRoutes.qrScanner,
      page: () => const QrScannerView(),
      transition: Transition.cupertino,
      binding: PassengerBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: AppRoutes.schedule,
      page: () => const ScheduleView(),
      transition: Transition.cupertino,
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: AppRoutes.tripDetails,
      page: () => const TripDetailsView(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: AppRoutes.tripTracking,
      page: () => const TripTrackingScreen(),
      binding: TripTrackingBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
