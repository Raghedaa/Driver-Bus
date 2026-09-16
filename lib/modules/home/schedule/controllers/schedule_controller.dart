import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../../../../core/shared/custom_snackbar.dart';
import '../../../../data/models/driver_model.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../data/providers/profile_provider.dart';
import '../../../../data/repositories/trip_repository.dart';
import '../../../profile/controllers/profile_controller.dart';

class ScheduleController extends GetxController {
  final ProfileProvider _profileProvider = ProfileProvider();
  final TripRepository _tripRepository;
  final ProfileController _profileController = Get.find<ProfileController>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  Rxn<DriverModel> get driver => _profileController.driverData;
  var isLoading = true.obs;

  var trips = <TripModel>[].obs;
  var selectedStatus = 'ongoing'.obs;
  var currentIndex = 1.obs;
  var isOnline = true.obs;

  var currentLanguage = ''.obs;
  var currentPage = 1.obs;
  var hasMorePages = true.obs;
  var isLoadingMore = false.obs;
  ScheduleController({required TripRepository tripRepository})
    : _tripRepository = tripRepository;

  @override
  void onInit() {
    super.onInit();

    currentLanguage.value = Get.locale?.languageCode ?? 'ar';

    _checkInitialConnectivity();
    _listenToConnectivityChanges();

    ever(currentLanguage, (_) async {
      await fetchTrips();
    });
  }

  void updateLanguage(String langCode) {
    currentLanguage.value = langCode;
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> result = await _connectivity
        .checkConnectivity();

    if (result.isNotEmpty && result.first != ConnectivityResult.none) {
      isOnline.value = true;
    } else {
      isOnline.value = false;
      _showOfflineSnackBar();
    }
    fetchDriverProfile();
    fetchTrips();
  }

  void _showOfflineSnackBar() {
    CustomSnackBar.showError('connection_required'.tr);
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      isOnline.value = false;
    } else {
      if (!isOnline.value) {
        isOnline.value = true;
        _syncPendingTripUpdates();
      }
    }
  }

  Future<void> fetchDriverProfile() async {
    try {
      await _profileController.fetchProfile(isOnline: isOnline.value);
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> fetchTrips({int page = 1}) async {
    try {
      if (page == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final fetchedTrips = await _tripRepository.getDriverTrips(
        page: page,
        isOnline: isOnline.value,
      );

      if (page == 1) {
        trips.value = fetchedTrips;
      } else {
        trips.addAll(fetchedTrips);
      }

      hasMorePages.value = fetchedTrips.length >= 15;
      currentPage.value = page;
    } catch (e) {
      CustomSnackBar.showError('Failed to load trips');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void loadMoreTrips() {
    if (!hasMorePages.value || isLoadingMore.value) return;
    fetchTrips(page: currentPage.value + 1);
  }

  Future<void> updateTripStatus(int tripId, String newStatus) async {
    try {
      isLoading.value = true;

      await _tripRepository.updateTripStatus(
        tripId: tripId,
        status: newStatus,
        isOnline: isOnline.value,
      );

      int index = trips.indexWhere((t) => t.id == tripId);
      if (index != -1) {
        trips[index] = trips[index].copyWith(status: newStatus);
        trips.refresh();
      } else {
        await fetchTrips();
      }

      if (!isOnline.value) {
        CustomSnackBar.showSuccess('trip_status_updated_locally'.tr);
      }
    } catch (e) {
      CustomSnackBar.showError('failed_to_update_status'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void updateTripInList(TripModel updatedTrip) {
    final index = trips.indexWhere((t) => t.id == updatedTrip.id);
    if (index != -1) {
      trips[index] = updatedTrip;
      trips.refresh();
    } else {
      fetchTrips();
    }
  }

  Future<void> _syncPendingTripUpdates() async {
    final pendingUpdates = _tripRepository.getPendingTripUpdates();
    if (pendingUpdates.isEmpty) return;

    pendingUpdates.forEach((tripIdStr, status) async {
      int tripId = int.parse(tripIdStr);
      try {
        await _tripRepository.updateTripStatus(
          tripId: tripId,
          status: status,
          isOnline: true,
        );
        _tripRepository.removeTripFromPending(tripId);
      } catch (e) {
        print("Failed to sync status for trip $tripId: $e");
      }
    });

    fetchTrips();
  }

  final List<String> statusOptions = ['ongoing', 'upcoming', 'completed'];

  List<TripModel> get filteredTrips {
    currentLanguage.value;
    selectedStatus.value;

    return trips
        .where((trip) => trip.mappedStatus == selectedStatus.value)
        .toList();
  }

  void changeStatus(String status) => selectedStatus.value = status;
  void changePage(int index) {
    currentIndex.value = index;
    if (index == 2) {
      currentLanguage.value = Get.locale?.languageCode ?? 'ar';
    }
  }

  void toggleDriverStatus() {
    if (_profileController.driverData.value != null) {
      String newStatus = _profileController.driverData.value!.status == "active"
          ? "offline"
          : "active";
      _profileController.driverData.value = _profileController.driverData.value!
          .copyWith(status: newStatus);
      CustomSnackBar.showSuccess(
        newStatus == "active"
            ? "You are now Online".tr
            : "You are now Offline".tr,
      );
    }
  }

  void viewMap(TripModel trip) {
    Get.toNamed('/trip-tracking', arguments: {'tripId': trip.id});
  }

  String getStatusText(String status) => status.tr;

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
