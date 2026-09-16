import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../data/repositories/trip_repository.dart';

class _PendingLocation {
  final double lat;
  final double lng;
  final double speed;
  final double heading;
  final double accuracy;
  int retryCount;

  _PendingLocation({
    required this.lat,
    required this.lng,
    required this.speed,
    required this.heading,
    required this.accuracy,
    this.retryCount = 0,
  });
}

class TripLocationService extends GetxService {
  int? currentTripId;
  var busLocation = Rxn<LatLng>();
  var heading = 0.0.obs;
  var currentSpeed = 0.0.obs;
  var currentAccuracy = 0.0.obs;
  var isGpsEnabled = true.obs;
  var isOnline = true.obs;
  var isTracking = false.obs;

  LatLng? _lastKnownGoodLocation;

  static const double _movementThresholdMeters = 6.0;
  static const double _jumpDistanceThresholdMeters = 50000;
  static const double _headingMinSpeed = 1.0;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<ServiceStatus>? _gpsStatusStream;
  StreamSubscription? _connectivityStream;
  Timer? _pingTimer;
  final Connectivity _connectivity = Connectivity();

  final List<_PendingLocation> _pendingQueue = [];
  static const int _maxQueueSize = 20;
  static const int _maxRetryPerItem = 5;
  bool _isSendingPing = false;

  @override
  void onInit() {
    super.onInit();
    _listenConnectivity();
    _listenGpsServiceStatus();
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    _gpsStatusStream?.cancel();
    _connectivityStream?.cancel();
    _pingTimer?.cancel();
    super.onClose();
  }

  Future<void> startTracking(int tripId) async {
    if (currentTripId == tripId && isTracking.value) {
      debugPrint("ℹ️ التتبع شغّال أصلاً للرحلة #$tripId");
      return;
    }

    if (currentTripId != null && currentTripId != tripId) {
      await stopTracking();
    }

    currentTripId = tripId;
    isTracking.value = true;
    busLocation.value = null;
    _lastKnownGoodLocation = null;

    await _startPositionStream();
    _startPingTimer();
  }

  Future<void> stopTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _pingTimer?.cancel();
    _pingTimer = null;
    currentTripId = null;
    isTracking.value = false;
    busLocation.value = null;
    _pendingQueue.clear();
    debugPrint("⏹️ تم إيقاف تتبع الموقع");
  }

  Future<void> recenter() async {
    final bool enabled = await Geolocator.isLocationServiceEnabled();
    isGpsEnabled.value = enabled;
    if (!enabled) return;

    if (_positionStream == null && currentTripId != null) {
      await _startPositionStream();
      return;
    }

    try {
      final Position fresh = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          forceLocationManager: false,
          timeLimit: const Duration(seconds: 8),
        ),
      );

      if (fresh.isMocked) {
        debugPrint("🚫 recenter: موقع وهمي — تم تجاهله");
        return;
      }

      if (fresh.accuracy <= 200) {
        final pos = LatLng(fresh.latitude, fresh.longitude);
        _lastKnownGoodLocation = pos;
        busLocation.value = pos;
        currentSpeed.value = fresh.speed;
        currentAccuracy.value = fresh.accuracy;
      }
    } catch (e) {
      debugPrint("❌ recenter فشل: $e");
    }
  }

  void _listenConnectivity() {
    _connectivity.checkConnectivity().then((results) {
      if (results.isNotEmpty) {
        isOnline.value = results.first != ConnectivityResult.none;
      }
    });

    _connectivityStream = _connectivity.onConnectivityChanged.listen((results) {
      if (results.isEmpty) return;
      final bool wasOffline = !isOnline.value;
      isOnline.value = results.first != ConnectivityResult.none;

      if (wasOffline && isOnline.value && _pendingQueue.isNotEmpty) {
        _flushPendingQueue();
      }
    });
  }

  void _listenGpsServiceStatus() {
    _gpsStatusStream = Geolocator.getServiceStatusStream().listen((status) {
      final bool enabled = status == ServiceStatus.enabled;
      isGpsEnabled.value = enabled;

      if (enabled) {
        debugPrint("📍 GPS عاد — إعادة تشغيل stream");
        if (_positionStream == null && currentTripId != null) {
          _startPositionStream();
        }
      } else {
        debugPrint("📴 GPS أُوقف من إعدادات الجهاز");
      }
    });
  }

  Future<void> _startPositionStream() async {
    await _positionStream?.cancel();
    _positionStream = null;

    final bool enabled = await Geolocator.isLocationServiceEnabled();
    isGpsEnabled.value = enabled;
    if (!enabled) {
      debugPrint("❌ GPS معطّل");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint("❌ صلاحية الموقع محظورة نهائياً");
      return;
    }

    try {
      final Position initial = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          forceLocationManager: false,
          timeLimit: const Duration(seconds: 10),
        ),
      );

      debugPrint(
        "📍 أول قراءة GPS: ${initial.latitude}, ${initial.longitude}"
        " | دقة: ${initial.accuracy}م"
        "${initial.isMocked ? ' | ⚠️ وهمية' : ''}",
      );

      if (initial.isMocked) {
        debugPrint("🚫 القراءة الأولى وهمية — تم تجاهلها");
      } else if (initial.accuracy <= 200) {
        final pos = LatLng(initial.latitude, initial.longitude);
        _lastKnownGoodLocation = pos;
        busLocation.value = pos;
        currentSpeed.value = initial.speed;
        currentAccuracy.value = initial.accuracy;
      }
    } catch (e) {
      debugPrint("❌ getCurrentPosition فشل: $e");
    }

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            forceLocationManager: true,
            distanceFilter: 5,
            foregroundNotificationConfig:
                currentTripId != null && isTracking.value
                ? const ForegroundNotificationConfig(
                    notificationTitle: "جاري تتبع الرحلة",
                    notificationText: "الموقع قيد المشاركة مع لوحة التحكم",
                    enableWakeLock: true,
                    setOngoing: true,
                  )
                : null,
          ),
        ).listen(
          _handlePositionUpdate,
          onError: (error) {
            debugPrint("❌ خطأ في stream الموقع: $error");
            if (error.toString().contains('disabled')) {
              isGpsEnabled.value = false;
              _positionStream?.cancel();
              _positionStream = null;
            }
          },
        );
  }

  void _handlePositionUpdate(Position position) {
    debugPrint(
      "🔄 موقع جديد: ${position.latitude}, ${position.longitude}"
      " | دقة: ${position.accuracy}م"
      "${position.isMocked ? ' | ⚠️ وهمي' : ''}",
    );

    if (position.isMocked) {
      debugPrint("🚫 موقع وهمي (Mock Location) — تم تجاهله");
      return;
    }

    if (position.accuracy > 150) {
      debugPrint("⏳ دقة ضعيفة (${position.accuracy}م > 150م) — تم التجاهل");
      return;
    }

    final LatLng newPos = LatLng(position.latitude, position.longitude);

    if (busLocation.value != null) {
      final double moved = const Distance().as(
        LengthUnit.Meter,
        busLocation.value!,
        newPos,
      );

      if (moved < _movementThresholdMeters) {
        debugPrint(
          "⏳ اهتزاز صغير — تم التجاهل"
          " (تحرّك ${moved.toStringAsFixed(1)}م < عتبة ${_movementThresholdMeters}م)",
        );
        return;
      }

      if (_lastKnownGoodLocation != null) {
        final double distFromGood = const Distance().as(
          LengthUnit.Meter,
          _lastKnownGoodLocation!,
          newPos,
        );
        if (distFromGood > _jumpDistanceThresholdMeters) {
          debugPrint(
            "🚫 قفزة موقع كبيرة (${distFromGood.toStringAsFixed(0)}م) — تم تجاهلها",
          );
          return;
        }
      }
    }

    currentSpeed.value = position.speed;
    currentAccuracy.value = position.accuracy;

    if (busLocation.value != null && position.speed > _headingMinSpeed) {
      heading.value = position.heading;
    }

    _lastKnownGoodLocation = newPos;
    busLocation.value = newPos;
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    debugPrint("🟢 سيتم إرسال الموقع كل 15 ثانية");
    _sendLocationPing();
    _pingTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _sendLocationPing(),
    );
  }

  Future<void> _sendLocationPing() async {
    final LatLng? pos = busLocation.value;
    final int? tripId = currentTripId;

    if (pos == null || tripId == null) return;
    if (!isOnline.value) {
      debugPrint("📴 لا إنترنت — تم تجاهل الإرسال");
      return;
    }
    if (_isSendingPing) return;

    _isSendingPing = true;
    try {
      final bool sent = await _trySendLocation(
        tripId: tripId,
        lat: pos.latitude,
        lng: pos.longitude,
        speed: currentSpeed.value,
        heading: heading.value,
        accuracy: currentAccuracy.value,
      );

      if (sent) {
        debugPrint(
          "📡 تم إرسال الموقع (${pos.latitude}, ${pos.longitude})"
          " | سرعة: ${currentSpeed.value} | اتجاه: ${heading.value}",
        );
        await _flushPendingQueue();
      } else {
        debugPrint("❌ فشل الإرسال — حُفظ للإعادة لاحقاً");
        _enqueuePending(
          _PendingLocation(
            lat: pos.latitude,
            lng: pos.longitude,
            speed: currentSpeed.value,
            heading: heading.value,
            accuracy: currentAccuracy.value,
          ),
        );
      }
    } finally {
      _isSendingPing = false;
    }
  }

  Future<bool> _trySendLocation({
    required int tripId,
    required double lat,
    required double lng,
    required double speed,
    required double heading,
    required double accuracy,
  }) async {
    final repo = Get.find<TripRepository>();
    return repo.sendTripLocation(
      tripId: tripId,
      lat: lat,
      lng: lng,
      speed: speed,
      heading: heading,
      accuracy: accuracy,
      isOnline: isOnline.value,
    );
  }

  void _enqueuePending(_PendingLocation item) {
    _pendingQueue.add(item);
    if (_pendingQueue.length > _maxQueueSize) {
      _pendingQueue.removeAt(0);
    }
  }

  Future<void> _flushPendingQueue() async {
    if (_pendingQueue.isEmpty || !isOnline.value) return;
    final int? tripId = currentTripId;
    if (tripId == null) return;

    final List<_PendingLocation> toRetry = List.from(_pendingQueue);
    _pendingQueue.clear();

    for (final item in toRetry) {
      if (!isOnline.value) {
        _enqueuePending(item);
        continue;
      }

      final bool sent = await _trySendLocation(
        tripId: tripId,
        lat: item.lat,
        lng: item.lng,
        speed: item.speed,
        heading: item.heading,
        accuracy: item.accuracy,
      );

      if (sent) {
        debugPrint(
          "📡 (إعادة محاولة ✓) تم إرسال نقطة مؤجّلة (${item.lat}, ${item.lng})",
        );
      } else {
        item.retryCount++;
        if (item.retryCount < _maxRetryPerItem) {
          _enqueuePending(item);
        } else {
          debugPrint("⚠️ تخلّينا عن نقطة بعد $_maxRetryPerItem محاولات فاشلة");
        }
      }
    }
  }
}
