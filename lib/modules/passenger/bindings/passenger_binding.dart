import 'package:get/get.dart';

import '../../../data/providers/booking_provider.dart';
import '../../../data/repositories/booking_repository.dart';
import '../controllers/passenger_controller.dart';

class PassengerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BookingProvider>()) {
      Get.lazyPut<BookingProvider>(() => BookingProvider());
    }
    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(() => BookingRepository());
    }
    Get.lazyPut<PassengerController>(() => PassengerController());
  }
}
