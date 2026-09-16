class RestAreaModel {
  final int id;
  final String name;
  final String description;
  final double rating;
  final int ratingCount;
  final double? latitude;
  final double? longitude;

  final int? stopOrder;
  final int? durationMinutes;

  RestAreaModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.ratingCount,
    this.latitude,
    this.longitude,
    this.stopOrder,
    this.durationMinutes,
  });

  factory RestAreaModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return RestAreaModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      rating: parseDouble(json['rating']),
      ratingCount: json['rating_count'] ?? 0,
      latitude: json['latitude'] != null ? parseDouble(json['latitude']) : null,
      longitude: json['longitude'] != null
          ? parseDouble(json['longitude'])
          : null,

      stopOrder: json['stop_order'],
      durationMinutes: json['duration_minutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rating': rating,
      'rating_count': ratingCount,
      'latitude': latitude,
      'longitude': longitude,
      'stop_order': stopOrder,
      'duration_minutes': durationMinutes,
    };
  }
}
