class DriverModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? phone;
  final String? address;
  final String? licenseNumber;
  final String? rating;
  final int? totalTrips;
  final String? status;
  final String? avatar;

  DriverModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    this.address,
    this.licenseNumber,
    this.rating,
    this.totalTrips,
    this.status,
    this.avatar,
  });

  DriverModel copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? address,
    String? licenseNumber,
    String? rating,
    int? totalTrips,
    String? status,
    String? avatar,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
    );
  }

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    var profile = json['driver_profile'] ?? {};

    String? avatarUrl;
    if (profile['avatar'] is Map) {
      avatarUrl = profile['avatar']['url'];
    } else if (profile['avatar'] is String) {
      avatarUrl = profile['avatar'];
    }

    String rawStatus = profile['status']?.toString().toLowerCase() ?? "";
    String cleanStatus = (rawStatus == "active" || rawStatus == "online")
        ? "active"
        : "offline";

    return DriverModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone_number'],
      address: json['address'],
      licenseNumber: profile['license_number']?.toString(),
      rating: profile['rating']?.toString() ?? "0.0",
      totalTrips: profile['total_rides'] ?? 0,
      status: cleanStatus,
      avatar: avatarUrl,
    );
  }
}
