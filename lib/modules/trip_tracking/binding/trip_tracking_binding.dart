import 'package:get/get.dart';

import '../../../../data/providers/trip_provider.dart';
import '../../../../data/repositories/trip_repository.dart';
import '../controllers/trip_tracking_controller.dart';

class TripTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TripProvider());
    Get.lazyPut(() => TripRepository(Get.find<TripProvider>()));

    final args = Get.arguments as Map<String, dynamic>;
    final int id = args['tripId'] ?? args['bookingId'];

    Get.lazyPut(() => TripTrackingController(tripId: id));
  }
}
