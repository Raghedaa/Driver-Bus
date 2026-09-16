import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/shared/custom_snackbar.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/repositories/trip_repository.dart';

class TripDetailsController extends GetxController {
  final TripRepository _tripRepository = Get.find<TripRepository>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  var routeId = "".obs;
  var pickupLocation = "".obs;
  var destination = "".obs;
  var departureTime = "".obs;
  var arrivalTime = "".obs;
  var passengerCount = "".obs;
  var distance = "".obs;
  var fare = "".obs;
  var duration = "".obs;
  var vehicleNumber = "".obs;

  var tripStatus = "Start".obs;
  var tripStatusDisplay = "".obs;
  var statusColor = Colors.grey.obs;

  var isUpdating = false.obs;
  var isLoadingTrip = false.obs;
  var isOnline = true.obs;

  final List<String> tripStatusOptions = [
    'scheduled',
    'in_progress',
    'completed',
    'cancelled',
  ];

  TripModel? currentTrip;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
    _handleIncomingArguments();
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> result = await _connectivity
        .checkConnectivity();
    if (result.isNotEmpty) {
      isOnline.value = result.first != ConnectivityResult.none;
    }
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty) {
        isOnline.value = results.first != ConnectivityResult.none;
      }
    });
  }

  void _handleIncomingArguments() async {
    if (Get.arguments == null) return;

    if (Get.arguments is TripModel) {
      currentTrip = Get.arguments as TripModel;
      _loadTripData();
    } else if (Get.arguments is int) {
      int tripId = Get.arguments as int;
      await _fetchTripById(tripId);
    }
  }

  Future<void> _fetchTripById(int tripId) async {
    try {
      isLoadingTrip.value = true;

      final List<TripModel> trips = await _tripRepository.getDriverTrips(
        page: 1,
        isOnline: isOnline.value,
      );

      final foundTrip = trips.firstWhereOrNull((t) => t.id == tripId);

      if (foundTrip != null) {
        currentTrip = foundTrip;
        _loadTripData();
      } else {
        CustomSnackBar.showError('trip_not_found'.tr);
      }
    } catch (e) {
      print("Error fetching single trip details: $e");
      CustomSnackBar.showError('Failed to load trip details'.tr);
    } finally {
      isLoadingTrip.value = false;
    }
  }

  void _loadTripData() {
    if (currentTrip == null) return;

    final trip = currentTrip!;
    routeId.value = "#TR-${trip.id}";
    pickupLocation.value = trip.pickupLocation;
    destination.value = trip.destination;
    departureTime.value = trip.departureTimeFormatted;
    arrivalTime.value = trip.arrivalTimeFormatted;
    passengerCount.value = trip.availableSeats.toString();
    distance.value = trip.distanceFormatted;
    fare.value = trip.fareFormatted;
    duration.value = trip.tripDuration;
    vehicleNumber.value = trip.vehicleNumber;
    tripStatusDisplay.value = trip.statusDisplayName;
    tripStatus.value = trip.status;
  }

  void updateTripStatus(String? newValue) {
    if (newValue != null) tripStatus.value = newValue;
  }

  Future<void> startTripAction() async {
    if (currentTrip == null) return;

    String newStatus;
    String successMessage;
    String confirmMessage;

    switch (tripStatus.value) {
      case 'scheduled':
        newStatus = 'in_progress';
        confirmMessage = 'Are you sure you want to start this trip?';
        successMessage = isOnline.value
            ? 'Trip started successfully'
            : 'Trip started locally (will sync later)';
        break;
      case 'in_progress':
        newStatus = 'completed';
        confirmMessage =
            'Are you sure you want to mark this trip as completed?';
        successMessage = isOnline.value
            ? 'Trip completed successfully'
            : 'Trip completed locally (will sync later)';
        break;
      case 'completed':
      case 'cancelled':
        CustomSnackBar.showError(
          'cannot_update_status_from'.trParams({
            'status': tripStatusDisplay.value,
          }),
        );
        return;
      default:
        CustomSnackBar.showError(
          'cannot_update_status_from'.trParams({
            'status': tripStatusDisplay.value,
          }),
        );
        return;
    }

    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Confirm'.tr),
        content: Text(confirmMessage.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'.tr, style: TextStyle(color: AppColor.error)),
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

    try {
      isUpdating.value = true;

      if (tripStatus.value == 'scheduled') {
        final updatedTrip = await _tripRepository.updateTripStatus(
          tripId: currentTrip!.id,
          status: newStatus,
          isOnline: isOnline.value,
        );

        currentTrip = updatedTrip;
        _loadTripData();

        CustomSnackBar.showSuccess(successMessage.tr);

        final result = await Get.toNamed(
          '/trip-tracking',
          arguments: {'tripId': updatedTrip.id},
        );

        if (result is TripModel) {
          currentTrip = result;
          _loadTripData();
        } else {
          await _refreshCurrentTrip();
        }
        return;
      }

      final updatedTrip = await _tripRepository.updateTripStatus(
        tripId: currentTrip!.id,
        status: newStatus,
        isOnline: isOnline.value,
      );

      currentTrip = updatedTrip;
      _loadTripData();

      CustomSnackBar.showSuccess(successMessage.tr);
    } catch (e) {
      CustomSnackBar.showError('Failed to update trip status: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> _refreshCurrentTrip() async {
    if (currentTrip == null) return;
    try {
      final trips = await _tripRepository.getDriverTrips(
        page: 1,
        isOnline: isOnline.value,
      );
      final refreshed = trips.firstWhereOrNull((t) => t.id == currentTrip!.id);
      if (refreshed != null) {
        currentTrip = refreshed;
        _loadTripData();
      }
    } catch (e) {
      debugPrint("❌ _refreshCurrentTrip: $e");
    }
  }

  String get actionButtonText {
    switch (tripStatus.value) {
      case 'scheduled':
        return 'startTrip'.tr;
      case 'in_progress':
        return 'endTrip'.tr;
      case 'completed':
        return 'completed'.tr;
      case 'cancelled':
        return 'cancelled'.tr;
      default:
        return 'updateStatus'.tr;
    }
  }

  bool get canUpdateStatus {
    return tripStatus.value == 'scheduled' || tripStatus.value == 'in_progress';
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
