// import 'dart:async';
// import 'dart:convert';
//
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../core/shared/custom_snackbar.dart';
// import '../../../data/models/passenger_model.dart';
// import '../../../data/repositories/booking_repository.dart';
// import '../views/widgets/ticket_details_dialog.dart';
//
// class PassengerController extends GetxController {
//   final BookingRepository _bookingRepository = Get.find<BookingRepository>();
//   final Connectivity _connectivity = Connectivity();
//   StreamSubscription? _connectivitySubscription;
//
//   var passengers = <PassengerModel>[].obs;
//   var searchQuery = ''.obs;
//   var currentScannedPassenger = Rxn<PassengerModel>();
//   var selectedFilter = 'ALL'.obs;
//   var isLoading = false.obs;
//   var totalPassengers = 0.obs;
//   var currentPage = 1.obs;
//   var lastPage = 1.obs;
//
//   var isOnline = true.obs;
//
//   final int tripId = Get.arguments?['trip_id'] ?? 0;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _checkInitialConnectivity();
//     _listenToConnectivityChanges();
//   }
//
//   Future<void> _checkInitialConnectivity() async {
//     final List<ConnectivityResult> result = await _connectivity
//         .checkConnectivity();
//     if (result.isNotEmpty) {
//       _updateConnectionStatus(result.first);
//     } else {
//       _updateConnectionStatus(ConnectivityResult.none);
//     }
//     loadPassengersFromApi();
//   }
//
//   void _listenToConnectivityChanges() {
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
//       List<ConnectivityResult> results,
//     ) {
//       if (results.isNotEmpty) {
//         _updateConnectionStatus(results.first);
//       }
//     });
//   }
//
//   void _updateConnectionStatus(ConnectivityResult result) {
//     if (result == ConnectivityResult.none) {
//       isOnline.value = false;
//       CustomSnackBar.showError("working_offline_mode".tr);
//     } else {
//       if (!isOnline.value) {
//         isOnline.value = true;
//         CustomSnackBar.showSuccess("back_online_syncing".tr);
//         syncPendingTicketsToServer();
//       }
//     }
//   }
//
//   Future<void> loadPassengersFromApi() async {
//     if (tripId == 0) {
//       CustomSnackBar.showError("Invalid trip ID".tr);
//       return;
//     }
//
//     isLoading.value = true;
//     try {
//       final passengerList = await _bookingRepository.getTripPassengers(
//         tripId,
//         page: currentPage.value,
//         isOnline: isOnline.value,
//       );
//
//       if (currentPage.value == 1) {
//         passengers.value = passengerList;
//       } else {
//         passengers.addAll(passengerList);
//       }
//
//       totalPassengers.value = passengers.length;
//       lastPage.value = (totalPassengers.value / 15).ceil();
//     } catch (error) {
//       CustomSnackBar.showError(error.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> processQrCode(String? pnrCode) async {
//     if (pnrCode == null || pnrCode.isEmpty) {
//       CustomSnackBar.showError("Invalid QR Code".tr);
//       return;
//     }
//
//     String cleanPnrCode = pnrCode.trim();
//
//     if (cleanPnrCode.contains('{') && cleanPnrCode.contains('pnr_code')) {
//       try {
//         final Map<String, dynamic> parsedJson = jsonDecode(cleanPnrCode);
//         if (parsedJson.containsKey('pnr_code')) {
//           cleanPnrCode = parsedJson['pnr_code'].toString().trim();
//         }
//       } catch (e) {
//         final regExp = RegExp(r'"pnr_code"\s*:\s*"([^"]+)"');
//         final match = regExp.firstMatch(cleanPnrCode);
//         if (match != null && match.groupCount >= 1) {
//           cleanPnrCode = match.group(1)!;
//         }
//       }
//     }
//
//     if (!isOnline.value) {
//       final bool isTicketInCache = passengers.any(
//         (p) => p.pnrCode == cleanPnrCode,
//       );
//
//       if (!isTicketInCache) {
//         CustomSnackBar.showError("ticket_not_cached_internet_required".tr);
//         return;
//       }
//     }
//
//     isLoading.value = true;
//
//     try {
//       final verifiedPassenger = await _bookingRepository.verifyTicket(
//         pnrCode: cleanPnrCode,
//         tripId: tripId,
//         isOnline: isOnline.value,
//       );
//
//       currentScannedPassenger.value = verifiedPassenger;
//
//       final index = passengers.indexWhere((p) => p.pnrCode == cleanPnrCode);
//       if (index != -1) {
//         passengers[index] = passengers[index].copyWith(
//           status: verifiedPassenger.status,
//         );
//         passengers.refresh();
//       }
//
//       if (Get.currentRoute == '/qr-scanner') {
//         Get.back();
//       }
//
//       showTicketResult();
//     } catch (error) {
//       CustomSnackBar.showError(error.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> syncPendingTicketsToServer() async {
//     final pendingPnrList = _bookingRepository.getPendingTickets();
//     if (pendingPnrList.isEmpty) return;
//
//     for (String pnr in pendingPnrList) {
//       try {
//         final verifiedPassenger = await _bookingRepository.verifyTicket(
//           pnrCode: pnr,
//           tripId: tripId,
//           isOnline: true,
//         );
//
//         _bookingRepository.removeTicketFromPending(pnr);
//       } catch (e) {
//         print("Failed to sync ticket $pnr: $e");
//       }
//     }
//     loadPassengersFromApi();
//   }
//
//   List<PassengerModel> get filteredPassengers {
//     final query = searchQuery.value.trim().toLowerCase();
//     if (query.isEmpty) {
//       return passengers.where((p) => _matchesFilter(p)).toList();
//     }
//     final isNumeric = RegExp(r'^\d+$').hasMatch(query);
//     return passengers.where((p) {
//       bool matchesSearch = isNumeric
//           ? p.seatNumbers.any((seat) => seat.toString() == query)
//           : (p.name.toLowerCase().contains(query) ||
//                 (p.pnrCode?.toLowerCase().contains(query) ?? false));
//       return matchesSearch && _matchesFilter(p);
//     }).toList();
//   }
//
//   bool _matchesFilter(PassengerModel p) => selectedFilter.value == 'PAID'
//       ? p.isPaid
//       : (selectedFilter.value == 'UNPAID' ? !p.isPaid : true);
//   void setFilter(String filter) => selectedFilter.value = filter;
//   void openTicketScanner() => Get.toNamed('/qr-scanner');
//   void showTicketResult() {
//     if (currentScannedPassenger.value != null)
//       Get.dialog(
//         Dialog(
//           backgroundColor: Colors.transparent,
//           child: const TicketDetailsDialog(),
//         ),
//       );
//   }
//
//   void loadPassengers() => loadPassengersFromApi();
//   void loadMorePassengers() {
//     if (currentPage.value < lastPage.value) {
//       currentPage.value++;
//       loadPassengersFromApi();
//     }
//   }
//
//   int get paidCount => passengers.where((p) => p.isPaid).length;
//   int get unpaidCount => passengers.where((p) => !p.isPaid).length;
//
//   @override
//   void onClose() {
//     _connectivitySubscription?.cancel();
//     super.onClose();
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/shared/custom_snackbar.dart';
import '../../../data/models/passenger_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../views/widgets/ticket_details_dialog.dart';

class PassengerController extends GetxController {
  final BookingRepository _bookingRepository = Get.find<BookingRepository>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  Timer? _autoRefreshTimer;

  static const Duration _autoRefreshInterval = Duration(seconds: 15);

  var passengers = <PassengerModel>[].obs;
  var searchQuery = ''.obs;
  var currentScannedPassenger = Rxn<PassengerModel>();
  var selectedFilter = 'ALL'.obs;
  var isLoading = false.obs;
  var totalPassengers = 0.obs;
  var currentPage = 1.obs;
  var lastPage = 1.obs;

  var isSilentRefreshing = false.obs;

  var isOnline = true.obs;

  final int tripId = Get.arguments?['trip_id'] ?? 0;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
    _startAutoRefresh();
  }

  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> result = await _connectivity
        .checkConnectivity();
    if (result.isNotEmpty) {
      _updateConnectionStatus(result.first);
    } else {
      _updateConnectionStatus(ConnectivityResult.none);
    }
    loadPassengersFromApi();
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
      CustomSnackBar.showError("working_offline_mode".tr);
    } else {
      if (!isOnline.value) {
        isOnline.value = true;
        CustomSnackBar.showSuccess("back_online_syncing".tr);
        syncPendingTicketsToServer();
      }
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      _silentRefresh();
    });
  }

  Future<void> _silentRefresh() async {
    if (tripId == 0) return;
    if (isLoading.value || isSilentRefreshing.value) return;
    if (!isOnline.value) return;

    isSilentRefreshing.value = true;
    try {
      final freshList = await _bookingRepository.getTripPassengers(
        tripId,
        page: 1,
        isOnline: true,
      );

      if (currentPage.value == 1) {
        passengers.value = freshList;
        totalPassengers.value = passengers.length;
        lastPage.value = (totalPassengers.value / 15).ceil();
      } else {
        for (final updated in freshList) {
          final idx = passengers.indexWhere(
            (p) => p.pnrCode == updated.pnrCode,
          );
          if (idx != -1) {
            passengers[idx] = updated;
          }
        }
      }
    } catch (_) {
    } finally {
      isSilentRefreshing.value = false;
    }
  }

  Future<void> loadPassengersFromApi() async {
    if (tripId == 0) {
      CustomSnackBar.showError("Invalid trip ID".tr);
      return;
    }

    isLoading.value = true;
    try {
      final passengerList = await _bookingRepository.getTripPassengers(
        tripId,
        page: currentPage.value,
        isOnline: isOnline.value,
      );

      if (currentPage.value == 1) {
        passengers.value = passengerList;
      } else {
        passengers.addAll(passengerList);
      }

      totalPassengers.value = passengers.length;
      lastPage.value = (totalPassengers.value / 15).ceil();
    } catch (error) {
      CustomSnackBar.showError(error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processQrCode(String? pnrCode) async {
    if (pnrCode == null || pnrCode.isEmpty) {
      CustomSnackBar.showError("Invalid QR Code".tr);
      return;
    }

    String cleanPnrCode = pnrCode.trim();

    if (cleanPnrCode.contains('{') && cleanPnrCode.contains('pnr_code')) {
      try {
        final Map<String, dynamic> parsedJson = jsonDecode(cleanPnrCode);
        if (parsedJson.containsKey('pnr_code')) {
          cleanPnrCode = parsedJson['pnr_code'].toString().trim();
        }
      } catch (e) {
        final regExp = RegExp(r'"pnr_code"\s*:\s*"([^"]+)"');
        final match = regExp.firstMatch(cleanPnrCode);
        if (match != null && match.groupCount >= 1) {
          cleanPnrCode = match.group(1)!;
        }
      }
    }

    if (!isOnline.value) {
      final bool isTicketInCache = passengers.any(
        (p) => p.pnrCode == cleanPnrCode,
      );

      if (!isTicketInCache) {
        CustomSnackBar.showError("ticket_not_cached_internet_required".tr);
        return;
      }
    }

    isLoading.value = true;

    try {
      final verifiedPassenger = await _bookingRepository.verifyTicket(
        pnrCode: cleanPnrCode,
        tripId: tripId,
        isOnline: isOnline.value,
      );

      currentScannedPassenger.value = verifiedPassenger;

      final index = passengers.indexWhere((p) => p.pnrCode == cleanPnrCode);
      if (index != -1) {
        passengers[index] = passengers[index].copyWith(
          status: verifiedPassenger.status,
        );
        passengers.refresh();
      }

      if (Get.currentRoute == '/qr-scanner') {
        Get.back();
      }

      showTicketResult();
    } catch (error) {
      CustomSnackBar.showError(error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncPendingTicketsToServer() async {
    final pendingPnrList = _bookingRepository.getPendingTickets();
    if (pendingPnrList.isEmpty) return;

    for (String pnr in pendingPnrList) {
      try {
        final verifiedPassenger = await _bookingRepository.verifyTicket(
          pnrCode: pnr,
          tripId: tripId,
          isOnline: true,
        );

        _bookingRepository.removeTicketFromPending(pnr);
      } catch (e) {
        print("Failed to sync ticket $pnr: $e");
      }
    }
    loadPassengersFromApi();
  }

  List<PassengerModel> get filteredPassengers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return passengers.where((p) => _matchesFilter(p)).toList();
    }
    final isNumeric = RegExp(r'^\d+$').hasMatch(query);
    return passengers.where((p) {
      bool matchesSearch = isNumeric
          ? p.seatNumbers.any((seat) => seat.toString() == query)
          : (p.name.toLowerCase().contains(query) ||
                (p.pnrCode?.toLowerCase().contains(query) ?? false));
      return matchesSearch && _matchesFilter(p);
    }).toList();
  }

  bool _matchesFilter(PassengerModel p) => selectedFilter.value == 'PAID'
      ? p.isPaid
      : (selectedFilter.value == 'UNPAID' ? !p.isPaid : true);
  void setFilter(String filter) => selectedFilter.value = filter;
  void openTicketScanner() => Get.toNamed('/qr-scanner');
  void showTicketResult() {
    if (currentScannedPassenger.value != null)
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: const TicketDetailsDialog(),
        ),
      );
  }

  void loadPassengers() => loadPassengersFromApi();
  void loadMorePassengers() {
    if (currentPage.value < lastPage.value) {
      currentPage.value++;
      loadPassengersFromApi();
    }
  }

  int get paidCount => passengers.where((p) => p.isPaid).length;
  int get unpaidCount => passengers.where((p) => !p.isPaid).length;

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _autoRefreshTimer?.cancel();
    super.onClose();
  }
}
