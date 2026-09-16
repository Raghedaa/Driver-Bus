import 'package:get/get.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../home/schedule/controllers/schedule_controller.dart';

class SettingsController extends GetxController {
  final LocaleController _localeController = Get.find<LocaleController>();
  final ThemeController _themeController = Get.find<ThemeController>();

  void changeLanguage(String langCode) {
    _localeController.changeLocale(langCode);
    if (Get.isRegistered<ScheduleController>()) {
      Get.find<ScheduleController>().updateLanguage(langCode);
    }
  }
}
