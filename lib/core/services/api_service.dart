import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../routes/app_routes/app_routes.dart';
import '../constants/app_link.dart';
import '../shared/custom_snackbar.dart';

class ApiService extends GetxService {
  late Dio dio;
  final GetStorage _box = GetStorage();

  final Connectivity _connectivity = Connectivity();
  var isConnected = true.obs;

  Future<ApiService> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: AppLink.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    await checkConnection();

    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty) {
        isConnected.value = results.first != ConnectivityResult.none;
      }
    });

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          String? token = _box.read("token");
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          String currentLang =
              _box.read('lang') ?? Get.locale?.languageCode ?? 'ar';
          options.headers["Accept-Language"] = currentLang;
          options.headers["lang"] = currentLang;
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            if (_box.read("token") != null &&
                Get.currentRoute != AppRoutes.login) {
              logout(isAutomatic: true);
            }
            return handler.reject(e);
          }
          return handler.next(e);
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return this;
  }

  Future<bool> checkConnection() async {
    final List<ConnectivityResult> result = await _connectivity
        .checkConnectivity();
    if (result.isNotEmpty && result.first != ConnectivityResult.none) {
      isConnected.value = true;
    } else {
      isConnected.value = false;
    }
    return isConnected.value;
  }

  void logout({bool isAutomatic = false}) {
    _box.remove("token");
    _box.remove("step");
    _box.remove("driver_data");

    if (isAutomatic) {
      CustomSnackBar.showError("session_expired_relogin".tr);
    } else {
      CustomSnackBar.showSuccess("logged_out_successfully".tr);
    }

    Get.offAllNamed(AppRoutes.login);
  }
}
