import 'package:get_storage/get_storage.dart';

import '../models/trip_model.dart';
import '../providers/trip_provider.dart';

class TripRepository {
  final TripProvider _provider;
  final GetStorage _storage = GetStorage();

  TripRepository(this._provider);

  final String _tripsKey = 'cached_driver_trips';
  final String _pendingTripUpdatesKey = 'pending_trip_status_updates';

  final String _citiesKey = 'cached_cities';
  final String _stationsKey = 'cached_stations';
  final String _restAreasKey = 'cached_rest_areas';

  String _tripDetailsKey(int tripId) => 'cached_trip_details_$tripId';

  Future<List<TripModel>> getDriverTrips({
    int page = 1,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      final cachedData = _storage.read<List<dynamic>>(_tripsKey);
      if (cachedData != null) {
        return cachedData.map((json) => TripModel.fromJson(json)).toList();
      }
      return [];
    }

    try {
      final response = await _provider.getDriverTrips(page: page);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        if (page == 1) {
          _storage.write(_tripsKey, data);
        }

        return data.map((json) => TripModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trips');
      }
    } catch (e) {
      final cachedData = _storage.read<List<dynamic>>(_tripsKey);
      if (cachedData != null) {
        return cachedData.map((json) => TripModel.fromJson(json)).toList();
      }
      throw Exception('Error loading trips: $e');
    }
  }

  Future<TripModel?> getTripDetails({
    required int tripId,
    required bool isOnline,
  }) async {
    final String detailsKey = _tripDetailsKey(tripId);

    if (!isOnline) {
      return _readCachedTripDetails(tripId, detailsKey);
    }

    try {
      final response = await _provider.getTripDetails(tripId);

      if (response.statusCode == 200) {
        final Map<String, dynamic> tripJson = Map<String, dynamic>.from(
          response.data['data'],
        );

        _storage.write(detailsKey, tripJson);

        final trip = TripModel.fromJson(tripJson);

        _updateSingleTripInCache(trip);

        return trip;
      } else {
        throw Exception('Failed to load trip details');
      }
    } catch (e) {
      return _readCachedTripDetails(tripId, detailsKey);
    }
  }

  TripModel? _readCachedTripDetails(int tripId, String detailsKey) {
    final cachedDetails = _storage.read<Map<String, dynamic>>(detailsKey);
    if (cachedDetails != null) {
      return TripModel.fromJson(cachedDetails);
    }

    final cachedList = _storage.read<List<dynamic>>(_tripsKey);
    if (cachedList != null) {
      for (final json in cachedList) {
        final trip = TripModel.fromJson(json);
        if (trip.id == tripId) return trip;
      }
    }
    return null;
  }

  Future<TripModel> updateTripStatus({
    required int tripId,
    required String status,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      return _processTripStatusOffline(tripId, status);
    }

    try {
      final response = await _provider.updateTripStatus(
        tripId: tripId,
        status: status,
      );

      if (response.statusCode == 200) {
        final updatedTrip = TripModel.fromJson(response.data['data']);
        _updateSingleTripInCache(updatedTrip);
        return updatedTrip;
      } else {
        throw Exception('Failed to update trip status');
      }
    } catch (e) {
      return _processTripStatusOffline(tripId, status);
    }
  }

  TripModel _processTripStatusOffline(int tripId, String status) {
    final cachedData = _storage.read<List<dynamic>>(_tripsKey);
    if (cachedData == null) throw Exception('No local trips data found');

    List<TripModel> localTrips = cachedData
        .map((json) => TripModel.fromJson(json))
        .toList();
    int index = localTrips.indexWhere((t) => t.id == tripId);

    if (index == -1) throw Exception('Trip not found locally');

    TripModel updatedTrip = localTrips[index].copyWith(mappedStatus: status);
    localTrips[index] = updatedTrip;

    _storage.write(_tripsKey, localTrips.map((t) => t.toJson()).toList());

    Map<String, dynamic> pendingUpdates =
        _storage.read<Map<String, dynamic>>(_pendingTripUpdatesKey) ?? {};
    pendingUpdates[tripId.toString()] = status;
    _storage.write(_pendingTripUpdatesKey, pendingUpdates);

    return updatedTrip;
  }

  void _updateSingleTripInCache(TripModel updatedTrip) {
    final cachedData = _storage.read<List<dynamic>>(_tripsKey);
    if (cachedData != null) {
      List<TripModel> localTrips = cachedData
          .map((json) => TripModel.fromJson(json))
          .toList();
      int index = localTrips.indexWhere((t) => t.id == updatedTrip.id);
      if (index != -1) {
        localTrips[index] = updatedTrip;
        _storage.write(_tripsKey, localTrips.map((t) => t.toJson()).toList());
      }
    }
  }

  Map<String, dynamic> getPendingTripUpdates() {
    return _storage.read<Map<String, dynamic>>(_pendingTripUpdatesKey) ?? {};
  }

  void removeTripFromPending(int tripId) {
    Map<String, dynamic> pendingUpdates =
        _storage.read<Map<String, dynamic>>(_pendingTripUpdatesKey) ?? {};
    pendingUpdates.remove(tripId.toString());
    _storage.write(_pendingTripUpdatesKey, pendingUpdates);
  }

  Future<List<dynamic>> getCities({required bool isOnline}) async {
    if (!isOnline) {
      final cachedData = _storage.read<List<dynamic>>(_citiesKey);
      return cachedData ?? [];
    }

    try {
      final response = await _provider.getCities();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        _storage.write(_citiesKey, data);
        return data;
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      return _storage.read<List<dynamic>>(_citiesKey) ?? [];
    }
  }

  Future<List<dynamic>> getStations({required bool isOnline}) async {
    if (!isOnline) {
      final cachedData = _storage.read<List<dynamic>>(_stationsKey);
      return cachedData ?? [];
    }

    try {
      final response = await _provider.getStations();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        _storage.write(_stationsKey, data);
        return data;
      } else {
        throw Exception('Failed to load stations');
      }
    } catch (e) {
      return _storage.read<List<dynamic>>(_stationsKey) ?? [];
    }
  }

  Future<List<dynamic>> getRestAreas({required bool isOnline}) async {
    if (!isOnline) {
      final cachedData = _storage.read<List<dynamic>>(_restAreasKey);
      return cachedData ?? [];
    }

    try {
      final response = await _provider.getRestAreas();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        _storage.write(_restAreasKey, data);
        return data;
      } else {
        throw Exception('Failed to load rest areas');
      }
    } catch (e) {
      return _storage.read<List<dynamic>>(_restAreasKey) ?? [];
    }
  }

  Future<bool> sendTripLocation({
    required int tripId,
    required double lat,
    required double lng,
    required double speed,
    required double heading,
    required double accuracy,
    required bool isOnline,
  }) async {
    if (!isOnline) return false;

    try {
      final response = await _provider.sendTripLocation(
        tripId: tripId,
        lat: lat,
        lng: lng,
        speed: speed,
        heading: heading,
        accuracy: accuracy,
      );
      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      return false;
    }
  }
}
