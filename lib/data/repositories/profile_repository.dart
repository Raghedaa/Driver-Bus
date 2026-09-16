import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../providers/profile_provider.dart';

class ProfileRepository {
  final ProfileProvider _provider;
  final GetStorage _storage = GetStorage();

  final String _profileKey = 'cached_driver_profile';

  ProfileRepository(this._provider);

  Future<Response> getDriverProfile({required bool isOnline}) async {
    if (!isOnline) {
      final cachedData = _storage.read<Map<String, dynamic>>(_profileKey);
      if (cachedData != null) {
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {'data': cachedData},
        );
      }
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 400,
        data: {'data': null},
      );
    }

    try {
      final response = await _provider.getProfile();
      if (response.statusCode == 200) {
        _storage.write(_profileKey, response.data['data']);
      }
      return response;
    } catch (e) {
      final cachedData = _storage.read<Map<String, dynamic>>(_profileKey);
      if (cachedData != null) {
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {'data': cachedData},
        );
      }
      rethrow;
    }
  }

  Future<Response> updateDriverProfile({
    String? name,
    String? phone,
    String? email,
    String? imagePath,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      throw Exception('connection_required');
    }

    Response response;
    if (imagePath != null && imagePath.isNotEmpty) {
      Map<String, dynamic> mapData = {};
      if (name != null) mapData["name"] = name;
      if (phone != null) mapData["phone_number"] = phone;
      if (email != null) mapData["email"] = email;

      mapData["avatar"] = await MultipartFile.fromFile(
        imagePath,
        filename: "avatar.jpg",
      );
      FormData formData = FormData.fromMap(mapData);
      response = await _provider.updateProfileMultipart(formData);
    } else {
      Map<String, dynamic> jsonData = {};
      if (name != null) jsonData["name"] = name;
      if (phone != null) jsonData["phone_number"] = phone;
      if (email != null) jsonData["email"] = email;

      response = await _provider.updateProfileJson(jsonData);
    }

    if (response.statusCode == 200) {
      _storage.write(_profileKey, response.data['data']);
    }
    return response;
  }
}
