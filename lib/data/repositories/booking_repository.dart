import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/models/passenger_model.dart';
import '../../data/providers/booking_provider.dart';

class BookingRepository extends GetxService {
  final BookingProvider _bookingProvider = Get.find<BookingProvider>();
  final GetStorage _storage = GetStorage();

  String _passengersKey(int tripId) => 'cached_passengers_$tripId';
  String get _pendingTicketsKey => 'pending_offline_tickets';

  Future<List<PassengerModel>> getTripPassengers(
    int tripId, {
    int page = 1,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      final cachedData = _storage.read<List<dynamic>>(_passengersKey(tripId));
      if (cachedData != null) {
        return cachedData.map((json) => PassengerModel.fromJson(json)).toList();
      }
      return [];
    }

    try {
      final response = await _bookingProvider.getTripPassengers(
        tripId,
        page: page,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        if (page == 1) {
          _storage.write(_passengersKey(tripId), data);
        }

        return data.map((json) => PassengerModel.fromJson(json)).toList();
      } else {
        final cachedData = _storage.read<List<dynamic>>(_passengersKey(tripId));
        if (cachedData != null)
          return cachedData
              .map((json) => PassengerModel.fromJson(json))
              .toList();
        return [];
      }
    } catch (e) {
      final cachedData = _storage.read<List<dynamic>>(_passengersKey(tripId));
      if (cachedData != null) {
        return cachedData.map((json) => PassengerModel.fromJson(json)).toList();
      }
      return [];
    }
  }

  Future<PassengerModel> verifyTicket({
    required String pnrCode,
    required int tripId,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      return _processTicketOffline(pnrCode, tripId);
    }

    try {
      final response = await _bookingProvider.verifyTicket(pnrCode, tripId);

      if (response.statusCode == 200) {
        final passengerData = response.data['data']['passenger'];
        final List<int> seatNumbers = List<int>.from(
          response.data['data']['seat_numbers'],
        );
        final status = response.data['data']['status'];

        return PassengerModel(
          name: passengerData['name'],
          phoneNumber: passengerData['phone_number'],
          seatNumbers: seatNumbers,
          status: status,
          pnrCode: pnrCode,
        );
      } else {
        throw response.data['message'] ?? 'Verification failed';
      }
    } catch (e) {
      return _processTicketOffline(pnrCode, tripId);
    }
  }

  PassengerModel _processTicketOffline(String pnrCode, int tripId) {
    final cachedData = _storage.read<List<dynamic>>(_passengersKey(tripId));

    if (cachedData == null) {
      throw Exception('local_trip_data_not_found'.tr);
    }

    List<PassengerModel> localList = cachedData
        .map((json) => PassengerModel.fromJson(json))
        .toList();
    int index = localList.indexWhere((p) => p.pnrCode == pnrCode);

    if (index == -1) {
      throw Exception('ticket_not_found_in_this_trip'.tr);
    }

    if (localList[index].status == 'PAID') {
      throw Exception('ticket_already_verified_locally'.tr);
    }

    PassengerModel updatedPassenger = localList[index].copyWith(status: 'PAID');
    localList[index] = updatedPassenger;

    _storage.write(
      _passengersKey(tripId),
      localList.map((p) => p.toJson()).toList(),
    );

    List<dynamic> pendingTickets =
        _storage.read<List<dynamic>>(_pendingTicketsKey) ?? [];
    if (!pendingTickets.contains(pnrCode)) {
      pendingTickets.add(pnrCode);
      _storage.write(_pendingTicketsKey, pendingTickets);
    }

    return updatedPassenger;
  }

  List<String> getPendingTickets() {
    final pending = _storage.read<List<dynamic>>(_pendingTicketsKey);
    return pending != null ? List<String>.from(pending) : [];
  }

  void removeTicketFromPending(String pnrCode) {
    List<dynamic> pendingTickets =
        _storage.read<List<dynamic>>(_pendingTicketsKey) ?? [];
    pendingTickets.remove(pnrCode);
    _storage.write(_pendingTicketsKey, pendingTickets);
  }
}
