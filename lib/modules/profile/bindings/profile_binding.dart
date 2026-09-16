import 'package:get/get.dart';

import '../../../data/providers/profile_provider.dart';
import '../../../data/repositories/profile_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileProvider>(() => ProfileProvider());

    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(Get.find<ProfileProvider>()),
    );

    Get.lazyPut<ProfileController>(
      () => ProfileController(Get.find<ProfileRepository>()),
    );
  }
}
