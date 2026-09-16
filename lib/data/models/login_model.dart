class SendOtpRequest {
  final String phoneNumber;
  final String intent;
  SendOtpRequest({required this.phoneNumber, required this.intent});

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
    'intent': intent,
  };
}

class VerifyOtpRequest {
  final String phoneNumber;
  final String code;
  final String intent;

  VerifyOtpRequest({
    required this.phoneNumber,
    required this.code,
    required this.intent,
  });

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
    'code': code,
    'intent': intent,
  };
}

class LoginResponseModel {
  final bool success;
  final String? message;
  final String? token;
  final UserData? userData;

  LoginResponseModel({
    required this.success,
    this.message,
    this.token,
    this.userData,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return LoginResponseModel(
      success:
          json['success'] ?? json['status'] == 200 || data['token'] != null,
      message: json['message'] ?? data['message'],
      token: data['token'],
      userData: data['user'] != null ? UserData.fromJson(data['user']) : null,
    );
  }
}

class UserData {
  final String id;
  final String name;
  final String? employeeId;
  final String? license;
  final int experience;
  final String? avatar;
  final String phoneNumber;
  final String? email;

  UserData({
    required this.id,
    required this.name,
    this.employeeId,
    this.license,
    required this.experience,
    this.avatar,
    required this.phoneNumber,
    this.email,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      employeeId: json['employeeId'] ?? json['employee_id'],
      license: json['license'] ?? json['license_number'],
      experience: json['experience'] ?? 0,
      avatar: json['avatar'] ?? json['profile_picture'],
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'],
    );
  }
}
