import 'package:driver_bus_app/routes/app_pages/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/constants/app_theme.dart';
import 'core/localization/locale_controller.dart';
import 'core/localization/my_locale.dart';
import 'core/services/api_service.dart';
import 'core/services/notification_service..dart';
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await Get.putAsync(() => ApiService().init());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Get.putAsync(() => NotificationService().init());
  final localeController = Get.put(LocaleController());
  final themeController = Get.put(ThemeController());

  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('ar_short', timeago.ArShortMessages());

  runApp(
    MyApp(localeController: localeController, themeController: themeController),
  );
}

class MyApp extends StatelessWidget {
  final LocaleController localeController;
  final ThemeController themeController;

  const MyApp({
    super.key,
    required this.localeController,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(
          () => GetMaterialApp(
            navigatorKey: Get.key,
            title: 'appName'.tr,
            debugShowCheckedModeBanner: false,
            locale: localeController.initialLocale,
            translations: AppTranslations(),
            fallbackLocale: const Locale('en'),
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: themeController.isDarkMode.value
                ? ThemeMode.dark
                : ThemeMode.light,
            initialRoute: AppPages.initialRoute,
            getPages: AppPages.routes,
          ),
        );
      },
    );
  }
}
