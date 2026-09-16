import 'package:get/get.dart';

import '../../../../data/providers/profile_provider.dart';
import '../../../../data/providers/trip_provider.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../data/repositories/trip_repository.dart';
import '../../../profile/controllers/profile_controller.dart';
import '../controllers/schedule_controller.dart';

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileProvider>(() => ProfileProvider());
    Get.lazyPut<TripProvider>(() => TripProvider());

    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(Get.find<ProfileProvider>()),
    );
    Get.lazyPut<TripRepository>(() => TripRepository(Get.find<TripProvider>()));

    Get.lazyPut<ProfileController>(
      () => ProfileController(Get.find<ProfileRepository>()),
    );
    Get.lazyPut<ScheduleController>(
      () => ScheduleController(tripRepository: Get.find<TripRepository>()),
    );
  }
}
