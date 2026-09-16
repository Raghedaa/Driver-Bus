import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/services/trip_location_service.dart';
import '../../../core/shared/custom_snackbar.dart';
import '../../../core/utils/polyline_decoder.dart';
import '../../../data/models/station_model.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/repositories/trip_repository.dart';
import '../../../routes/app_routes/app_routes.dart';
import '../../home/schedule/controllers/schedule_controller.dart';

List<LatLng> _decodePolylineIsolate(String encoded) => decodePolyline(encoded);

class TripTrackingController extends GetxController {
  final int tripId;
  TripTrackingController({required this.tripId});

  late final TripLocationService _locationService;

  var isMapReady = false.obs;
  var polylinePoints = <LatLng>[].obs;
  var markers = <Marker>[].obs;
  var isLoading = true.obs;
  var isOnline = true.obs;

  var tripDestinationName = "".obs;
  var autoFollow = true.obs;

  TripModel? currentTrip;
  var isTripInProgress = false.obs;
  var isEndingTrip = false.obs;
  var isActiveTracking = false.obs;

  late MapController mapController;

  Rxn<LatLng> get busLocation => _locationService.busLocation;
  RxDouble get heading => _locationService.heading;
  RxBool get isGpsEnabled => _locationService.isGpsEnabled;

  StreamSubscription? _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    polylinePoints.clear();
    markers.clear();
    mapController = MapController();

    _locationService = Get.isRegistered<TripLocationService>()
        ? Get.find<TripLocationService>()
        : Get.put(TripLocationService(), permanent: true);

    _init();

    ever(_locationService.busLocation, (LatLng? pos) {
      if (pos == null) return;
      if (isMapReady.value && autoFollow.value) {
        mapController.move(pos, mapController.camera.zoom);
      }
    });
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    mapController.dispose();
    super.onClose();
  }

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isNotEmpty) {
      isOnline.value = results.first != ConnectivityResult.none;
    }

    await fetchTripDetails();

    isActiveTracking.value = isTripInProgress.value;

    if (isTripInProgress.value) {
      await _locationService.startTracking(tripId);
    } else {
      debugPrint("ℹ️ الرحلة بحالة (${currentTrip?.status}) — لن يبدأ التتبع");
    }

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      if (results.isNotEmpty) {
        isOnline.value = results.first != ConnectivityResult.none;
      }
    });
  }

  String get trackingStatusMessage {
    if (currentTrip == null) return '';

    switch (currentTrip!.status.toLowerCase()) {
      case 'scheduled':
        return 'trip_not_started_yet'.tr;
      case 'completed':
        return 'trip_already_completed'.tr;
      case 'cancelled':
        return 'trip_cancelled'.tr;
      default:
        return '';
    }
  }

  Color get trackingStatusColor {
    if (currentTrip == null) return Colors.grey;

    switch (currentTrip!.status.toLowerCase()) {
      case 'scheduled':
        return AppColor.orange;
      case 'completed':
        return AppColor.success;
      case 'cancelled':
        return AppColor.error;
      default:
        return Colors.grey;
    }
  }

  IconData get trackingStatusIcon {
    if (currentTrip == null) return Icons.info_outline;

    switch (currentTrip!.status.toLowerCase()) {
      case 'scheduled':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  void onMapReady() {
    isMapReady.value = true;
    Future.delayed(const Duration(milliseconds: 500), updateCamera);
  }

  void updateCamera() {
    if (!isMapReady.value) return;

    if (polylinePoints.length >= 2) {
      mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: polylinePoints,
          padding: const EdgeInsets.all(100),
        ),
      );
    } else if (busLocation.value != null) {
      mapController.move(busLocation.value!, 12.0);
    } else if (polylinePoints.isNotEmpty) {
      mapController.move(polylinePoints.first, 12.0);
    }
  }

  Future<void> recenterMap() async {
    autoFollow.value = true;
    final pos = busLocation.value;
    if (pos != null && isMapReady.value) {
      mapController.move(pos, 15.0);
    }
    await _locationService.recenter();
  }

  Future<void> fetchTripDetails() async {
    isLoading.value = true;
    polylinePoints.clear();
    markers.clear();

    try {
      final repo = Get.find<TripRepository>();

      final TripModel? trip = await repo.getTripDetails(
        tripId: tripId,
        isOnline: isOnline.value,
      );

      if (trip == null) {
        debugPrint("❌ الرحلة غير موجودة: id=$tripId");
        return;
      }

      currentTrip = trip;
      isTripInProgress.value = trip.status.toLowerCase() == 'in_progress';

      final List<dynamic> rawStations = await repo.getStations(
        isOnline: isOnline.value,
      );
      final List<StationModel> allStations = rawStations
          .map((j) => StationModel.fromJson(j))
          .toList();

      LatLng? startPoint;
      LatLng? endPoint;

      final StationModel? startStation = allStations.firstWhereOrNull(
        (s) => s.id == trip.originStation.id,
      );
      if (startStation?.latitude != null && startStation!.latitude != 0.0) {
        startPoint = LatLng(startStation.latitude!, startStation.longitude!);
      }

      final StationModel? endStation = allStations.firstWhereOrNull(
        (s) => s.id == trip.destinationStation.id,
      );
      if (endStation?.latitude != null && endStation!.latitude != 0.0) {
        endPoint = LatLng(endStation.latitude!, endStation.longitude!);
        tripDestinationName.value = endStation.name;
      }

      await _buildPolyline(trip, startPoint, endPoint);

      _buildMarkers(trip, startStation, endStation, startPoint, endPoint);

      Future.delayed(const Duration(milliseconds: 300), updateCamera);
    } catch (e) {
      debugPrint("❌ خطأ في fetchTripDetails: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _buildPolyline(
    TripModel trip,
    LatLng? startPoint,
    LatLng? endPoint,
  ) async {
    final RouteInfo? route = trip.route;
    final String? encodedPolyline = route?.routePolyline;

    if (encodedPolyline != null && encodedPolyline.isNotEmpty) {
      try {
        final decoded = await compute(_decodePolylineIsolate, encodedPolyline);
        polylinePoints.assignAll(decoded);
        return;
      } catch (e) {
        debugPrint("❌ فشل فك تشفير الـ polyline: $e");
      }
    }

    if (isOnline.value) {
      final built = await _buildPolylineFromOSRM(trip, startPoint, endPoint);
      if (built) return;
    }

    _buildFallbackPolyline(trip, startPoint, endPoint, route);
  }

  Future<bool> _buildPolylineFromOSRM(
    TripModel trip,
    LatLng? startPoint,
    LatLng? endPoint,
  ) async {
    try {
      final List<LatLng> waypoints = [];
      if (startPoint != null) waypoints.add(startPoint);

      for (final area in trip.route?.restAreas ?? []) {
        waypoints.add(LatLng(area.latitude, area.longitude));
      }

      if (endPoint != null) waypoints.add(endPoint);
      if (waypoints.length < 2) return false;

      final String coords = waypoints
          .map((p) => "${p.longitude},${p.latitude}")
          .join(';');

      final response = await Dio().get(
        "https://router.project-osrm.org/route/v1/driving/$coords"
        "?overview=full&geometries=geojson",
      );

      if (response.statusCode == 200) {
        final route = response.data['routes'][0];

        final List<dynamic> coords2 = route['geometry']['coordinates'];
        polylinePoints.assignAll(
          coords2.map((c) => LatLng(c[1] as double, c[0] as double)),
        );
        return true;
      }
    } catch (e) {
      debugPrint("⚠️ OSRM فشل: $e");
    }
    return false;
  }

  void _buildFallbackPolyline(
    TripModel trip,
    LatLng? startPoint,
    LatLng? endPoint,
    RouteInfo? route,
  ) {
    final List<LatLng> fallback = [];
    if (startPoint != null) fallback.add(startPoint);
    for (final area in route?.restAreas ?? []) {
      fallback.add(LatLng(area.latitude, area.longitude));
    }
    if (endPoint != null) fallback.add(endPoint);

    if (fallback.length >= 2) {
      polylinePoints.assignAll(fallback);
    }
  }

  void _buildMarkers(
    TripModel trip,
    StationModel? startStation,
    StationModel? endStation,
    LatLng? startPoint,
    LatLng? endPoint,
  ) {
    final List<Marker> newMarkers = [];

    if (startPoint != null) {
      newMarkers.add(
        _buildMarker(
          point: startPoint,
          name: startStation?.name ?? "",
          color: AppColor.success,
          icon: Icons.location_on,
        ),
      );
    }

    for (final area in trip.route?.restAreas ?? []) {
      newMarkers.add(
        _buildMarker(
          point: LatLng(area.latitude, area.longitude),
          name: area.name,
          color: AppColor.orange,
          icon: Icons.coffee,
          iconSize: 28,
        ),
      );
    }

    if (endPoint != null) {
      newMarkers.add(
        _buildMarker(
          point: endPoint,
          name: endStation?.name ?? "",
          color: AppColor.error,
          icon: Icons.flag,
        ),
      );
    }

    markers.assignAll(newMarkers);
  }

  Marker _buildMarker({
    required LatLng point,
    required String name,
    required Color color,
    required IconData icon,
    double iconSize = 30,
  }) {
    return Marker(
      point: point,
      width: 100,
      height: 55,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              name,
              style: const TextStyle(color: AppColor.white, fontSize: 9),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(icon, color: color, size: iconSize),
        ],
      ),
    );
  }

  void goBack() {
    if (Get.isRegistered<ScheduleController>() && currentTrip != null) {
      Get.find<ScheduleController>().updateTripInList(currentTrip!);
    }
    Get.until((route) => route.settings.name == AppRoutes.schedule);
  }

  Future<void> endTripAction() async {
    if (currentTrip == null || !isTripInProgress.value || isEndingTrip.value) {
      return;
    }

    final bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Confirm'.tr),
        content: Text('confirm_end_trip_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel'.tr,
              style: const TextStyle(color: AppColor.error),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryGreen,
            ),
            child: Text('Confirm'.tr),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isEndingTrip.value = true;
    try {
      final repo = Get.find<TripRepository>();
      final TripModel updatedTrip = await repo.updateTripStatus(
        tripId: tripId,
        status: 'completed',
        isOnline: isOnline.value,
      );

      currentTrip = updatedTrip;
      isTripInProgress.value =
          updatedTrip.status.toLowerCase() == 'in_progress';
      isActiveTracking.value = false;

      await _locationService.stopTracking();

      CustomSnackBar.showSuccess(
        isOnline.value
            ? 'trip_completed_successfully'.tr
            : 'trip_completed_locally'.tr,
      );

      if (Get.isRegistered<ScheduleController>()) {
        Get.find<ScheduleController>().updateTripInList(updatedTrip);
      }
      Get.until((route) => route.settings.name == AppRoutes.schedule);
    } catch (e) {
      CustomSnackBar.showError(
        'failed_to_update_trip_status'.trParams({'error': e.toString()}),
      );
    } finally {
      isEndingTrip.value = false;
    }
  }
}
