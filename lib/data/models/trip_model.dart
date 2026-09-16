import 'package:get/get.dart';

class TripModel {
  final int id;
  final String status;
  final DateTime departureTime;
  final DateTime estimatedArrivalTime;
  final int baseFare;
  final int availableSeats;
  final int routeId;
  final int vehicleId;
  final int driverId;
  final int originStationId;
  final int destinationStationId;
  final int originCityId;
  final int destinationCityId;
  final City originCity;
  final City destinationCity;
  final Station originStation;
  final Station destinationStation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RestAreaInTrip> restAreas;
  final RouteInfo? route;

  TripModel({
    required this.id,
    required this.status,
    required this.departureTime,
    required this.estimatedArrivalTime,
    required this.baseFare,
    required this.availableSeats,
    required this.routeId,
    required this.vehicleId,
    required this.driverId,
    required this.originStationId,
    required this.destinationStationId,
    required this.originCityId,
    required this.destinationCityId,
    required this.originCity,
    required this.destinationCity,
    required this.originStation,
    required this.destinationStation,
    required this.createdAt,
    required this.updatedAt,
    required this.restAreas,
    this.route,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      status: json['status'],
      departureTime: DateTime.parse(json['departure_time']),
      estimatedArrivalTime: DateTime.parse(json['estimated_arrival_time']),
      baseFare: json['base_fare'],
      availableSeats: json['available_seats'],
      routeId: json['route_id'],
      vehicleId: json['vehicle_id'],
      driverId: json['driver_id'],
      originStationId: json['origin_station_id'],
      destinationStationId: json['destination_station_id'],
      originCityId: json['origin_city_id'],
      destinationCityId: json['destination_city_id'],
      originCity: City.fromJson(json['origin_city']),
      destinationCity: City.fromJson(json['destination_city']),
      originStation: Station.fromJson(json['origin_station']),
      destinationStation: Station.fromJson(json['destination_station']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),

      restAreas: json['rest_areas'] != null
          ? List<RestAreaInTrip>.from(
              json['rest_areas'].map((x) => RestAreaInTrip.fromJson(x)),
            )
          : [],
      route: json['route'] != null ? RouteInfo.fromJson(json['route']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'departure_time': departureTime.toIso8601String(),
      'estimated_arrival_time': estimatedArrivalTime.toIso8601String(),
      'base_fare': baseFare,
      'available_seats': availableSeats,
      'route_id': routeId,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'origin_station_id': originStationId,
      'destination_station_id': destinationStationId,
      'origin_city_id': originCityId,
      'destination_city_id': destinationCityId,
      'origin_city': originCity.toJson(),
      'destination_city': destinationCity.toJson(),
      'origin_station': originStation.toJson(),
      'destination_station': destinationStation.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'rest_areas': restAreas.map((x) => x.toJson()).toList(),
      'route': route?.toJson(),
    };
  }

  TripModel copyWith({
    int? id,
    String? status,
    DateTime? departureTime,
    DateTime? estimatedArrivalTime,
    int? baseFare,
    int? availableSeats,
    int? routeId,
    int? vehicleId,
    int? driverId,
    int? originStationId,
    int? destinationStationId,
    int? originCityId,
    int? destinationCityId,
    City? originCity,
    City? destinationCity,
    Station? originStation,
    Station? destinationStation,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mappedStatus,
    List<RestAreaInTrip>? restAreas,
    RouteInfo? route,
  }) {
    return TripModel(
      id: id ?? this.id,
      status: mappedStatus ?? status ?? this.status,
      departureTime: departureTime ?? this.departureTime,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      baseFare: baseFare ?? this.baseFare,
      availableSeats: availableSeats ?? this.availableSeats,
      routeId: routeId ?? this.routeId,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      originStationId: originStationId ?? this.originStationId,
      destinationStationId: destinationStationId ?? this.destinationStationId,
      originCityId: originCityId ?? this.originCityId,
      destinationCityId: destinationCityId ?? this.destinationCityId,
      originCity: originCity ?? this.originCity,
      destinationCity: destinationCity ?? this.destinationCity,
      originStation: originStation ?? this.originStation,
      destinationStation: destinationStation ?? this.destinationStation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      restAreas: restAreas ?? this.restAreas,
      route: route ?? this.route,
    );
  }

  double get originLatitude =>
      originStation.latitude ?? originCity.latitude ?? 0;
  double get originLongitude =>
      originStation.longitude ?? originCity.longitude ?? 0;
  double get destinationLatitude =>
      destinationStation.latitude ?? destinationCity.latitude ?? 0;
  double get destinationLongitude =>
      destinationStation.longitude ?? destinationCity.longitude ?? 0;

  String get pickupLocation => "${originStation.name}, ${originCity.name}";
  String get destination =>
      "${destinationStation.name}, ${destinationCity.name}";
  String get fullRoute => "${originCity.name} ➔ ${destinationCity.name}";
  String get stationRoute =>
      "${originStation.name} ➔ ${destinationStation.name}";

  String get departureTimeFormatted => _formatDateTime(departureTime);
  String get arrivalTimeFormatted => _formatDateTime(estimatedArrivalTime);
  String get distanceFormatted =>
      "${originCity.name} - ${destinationCity.name}";

  String get tripDuration {
    final duration = estimatedArrivalTime.difference(departureTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return 'trip_duration_format'.trParams({
      'hours': hours.toString(),
      'minutes': minutes.toString(),
    });
  }

  String get passengerCount => "$availableSeats/45";
  String get fareFormatted => "$baseFare SYP";
  bool get hasMap => status == 'in_progress' || status == 'ongoing';
  String get vehicleNumber => "Bus #$vehicleId";

  String get mappedStatus {
    switch (status) {
      case 'in_progress':
      case 'ongoing':
        return 'ongoing';
      case 'scheduled':
        final now = DateTime.now();
        return departureTime.isAfter(now) ? 'upcoming' : 'completed';
      case 'upcoming':
        return 'upcoming';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return status;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'in_progress':
      case 'ongoing':
        return 'in_progress'.tr;
      case 'scheduled':
        final now = DateTime.now();
        return departureTime.isAfter(now) ? 'upcoming'.tr : 'completed'.tr;
      case 'upcoming':
        return 'upcoming'.tr;
      case 'completed':
        return 'completed'.tr;
      case 'cancelled':
        return 'cancelled'.tr;
      default:
        return status;
    }
  }

  static String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');

    final bool isArabic = Get.locale?.languageCode == 'ar';

    final period = dateTime.hour >= 12
        ? (isArabic ? 'م' : 'PM')
        : (isArabic ? 'ص' : 'AM');

    final monthsEn = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final monthsAr = [
      'كانون الثاني',
      'شباط',
      'آذار',
      'نيسان',
      'أيار',
      'حزيران',
      'تموز',
      'آب',
      'أيلول',
      'تشرين الأول',
      'تشرين الثاني',
      'كانون الأول',
    ];

    final monthStr = isArabic
        ? monthsAr[dateTime.month - 1]
        : monthsEn[dateTime.month - 1];

    if (isArabic) {
      return '$monthStr ${dateTime.day}، الساعة $displayHour:$minute $period';
    } else {
      return '$monthStr ${dateTime.day}, $displayHour:$minute $period';
    }
  }
}

class City {
  final int id;
  final String name;
  final double? latitude;
  final double? longitude;

  City({required this.id, required this.name, this.latitude, this.longitude});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class Station {
  final int id;
  final String name;
  final double? latitude;
  final double? longitude;
  final int? cityId;
  final City? city;

  Station({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.cityId,
    this.city,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      cityId: json['city_id'],
      city: json['city'] != null ? City.fromJson(json['city']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'city_id': cityId,
    'city': city?.toJson(),
  };
}

class RestAreaInTrip {
  final int id;
  final int? tripId;
  final int? restAreaId;

  RestAreaInTrip({required this.id, this.tripId, this.restAreaId});

  factory RestAreaInTrip.fromJson(Map<String, dynamic> json) {
    return RestAreaInTrip(
      id: json['id'] ?? 0,
      tripId: json['trip_id'],
      restAreaId: json['rest_area_id'] ?? json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trip_id': tripId,
    'rest_area_id': restAreaId,
  };
}

class RouteRestArea {
  final int id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final int? stopOrder;
  final int? durationMinutes;
  final double? rating;
  final int? ratingCount;

  RouteRestArea({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.stopOrder,
    this.durationMinutes,
    this.rating,
    this.ratingCount,
  });

  factory RouteRestArea.fromJson(Map<String, dynamic> json) {
    return RouteRestArea(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      stopOrder: json['stop_order'],
      durationMinutes: json['duration_minutes'],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      ratingCount: json['rating_count'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'stop_order': stopOrder,
    'duration_minutes': durationMinutes,
    'rating': rating,
    'rating_count': ratingCount,
  };
}

class RouteInfo {
  final int id;
  final String name;
  final String? routePolyline;
  final double? routeDistanceMeters;
  final double? routeDurationSeconds;
  final List<RouteRestArea> restAreas;

  RouteInfo({
    required this.id,
    required this.name,
    this.routePolyline,
    this.routeDistanceMeters,
    this.routeDurationSeconds,
    required this.restAreas,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: json['id'],
      name: json['name'] ?? '',
      routePolyline: json['route_polyline'],
      routeDistanceMeters: (json['route_distance_meters'] as num?)?.toDouble(),
      routeDurationSeconds: (json['route_duration_seconds'] as num?)
          ?.toDouble(),
      restAreas: json['rest_areas'] != null
          ? List<RouteRestArea>.from(
              json['rest_areas'].map((x) => RouteRestArea.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'route_polyline': routePolyline,
    'route_distance_meters': routeDistanceMeters,
    'route_duration_seconds': routeDurationSeconds,
    'rest_areas': restAreas.map((x) => x.toJson()).toList(),
  };
}
