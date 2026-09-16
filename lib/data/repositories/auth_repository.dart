import 'package:dio/dio.dart';

import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _provider;

  AuthRepository(this._provider);

  Future<Response> sendOtp(String phone) async {
    return await _provider.sendOtp(phone);
  }

  Future<Response> login(String phone, String code) async {
    return await _provider.loginWithOtp(phone, code);
  }

  Future<Response> updateFcmToken(String token, String platform) async {
    return await _provider.updateFcmToken(token, platform);
  }
}
