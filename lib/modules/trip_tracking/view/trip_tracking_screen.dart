import 'package:driver_bus_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service.dart';
import '../controllers/trip_tracking_controller.dart';

class TripTrackingScreen extends GetView<TripTrackingController> {
  const TripTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialZoom: 15,
              onMapReady: () => controller.onMapReady(),
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  controller.autoFollow.value = false;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.driver_bus_app',
                additionalOptions: const {
                  'User-Agent': 'FlutterMap/com.example.driver_bus_app',
                },
                tileProvider: NetworkTileProvider(),
                errorTileCallback: (tile, error, stackTrace) {
                  debugPrint(
                    "⚠️ خطأ في تحميل الـ Tile، يتم الاعتماد على كاش الذاكرة.",
                  );
                },
              ),

              Obx(() {
                if (controller.polylinePoints.length < 2) {
                  return const SizedBox.shrink();
                }
                return PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.polylinePoints.toList(),
                      strokeWidth: 6,
                      color: const Color(0xFF4285F4),
                      borderStrokeWidth: 3,
                      borderColor: Colors.white,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
                );
              }),

              Obx(() => MarkerLayer(markers: controller.markers.toList())),

              Obx(() {
                if (!controller.isActiveTracking.value ||
                    controller.busLocation.value == null) {
                  return const SizedBox.shrink();
                }
                return MarkerLayer(
                  markers: [
                    Marker(
                      point: controller.busLocation.value!,
                      width: 48,
                      height: 48,
                      child: _DriverMarker(heading: controller.heading.value),
                    ),
                  ],
                );
              }),
            ],
          ),

          Obx(() {
            if (controller.tripDestinationName.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  bottom: 12,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.goBack(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        controller.tripDestinationName.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Obx(
                      () => controller.isActiveTracking.value
                          ? AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: controller.autoFollow.value
                                    ? AppColor.primaryGreen
                                    : Colors.grey[400],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (controller.autoFollow.value)
                                    const _PulsingDot()
                                  else
                                    const Icon(
                                      Icons.pause_circle_outline,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.autoFollow.value
                                        ? "live_status".tr
                                        : "paused_status".tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }),

          Obx(() {
            if (controller.isActiveTracking.value) {
              return const SizedBox.shrink();
            }

            final double topOffset =
                controller.tripDestinationName.value.isEmpty
                ? MediaQuery.of(context).padding.top + 16
                : MediaQuery.of(context).padding.top + 76;

            return Positioned(
              top: topOffset,
              left: 16,
              right: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: controller.trackingStatusColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      controller.trackingStatusIcon,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'tracking_inactive'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            controller.trackingStatusMessage,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          Obx(() {
            if (!controller.isActiveTracking.value) {
              return const SizedBox.shrink();
            }

            final apiService = Get.find<ApiService>();
            final bool hasNoInternet = !apiService.isConnected.value;
            final bool hasNoGps = !controller.isGpsEnabled.value;

            if (!hasNoInternet && !hasNoGps) return const SizedBox.shrink();

            final double topOffset =
                controller.tripDestinationName.value.isEmpty
                ? MediaQuery.of(context).padding.top + 16
                : MediaQuery.of(context).padding.top + 76;

            final String title = hasNoGps
                ? "gps_disabled_title".tr
                : "no_internet_title".tr;
            final String message = hasNoGps
                ? "gps_disabled_error".tr
                : "no_internet_error".tr;
            final IconData icon = hasNoGps
                ? Icons.location_off
                : Icons.wifi_off;

            return Positioned(
              top: topOffset,
              left: 16,
              right: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.error.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () async {
                        if (hasNoGps) {
                          controller.recenterMap();
                          return;
                        }
                        bool connected = await apiService.checkConnection();
                        if (connected) controller.fetchTripDetails();
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Row(
                    children: [
                      const Spacer(),

                      Obx(
                        () => !controller.isActiveTracking.value
                            ? const SizedBox.shrink()
                            : controller.autoFollow.value
                            ? const SizedBox.shrink()
                            : GestureDetector(
                                onTap: () => controller.recenterMap(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                    border: Border.all(
                                      color: AppColor.primaryGreen,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.black.withOpacity(0.08),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.my_location,
                                        color: AppColor.primaryGreen,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "recenter".tr,
                                        style: const TextStyle(
                                          color: AppColor.primaryGreen,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(width: 8),

                      Obx(
                        () => GestureDetector(
                          onTap: controller.isActiveTracking.value
                              ? () => controller.recenterMap()
                              : null,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: controller.isActiveTracking.value
                                  ? AppColor.primaryGreen
                                  : Colors.grey[400],
                              shape: BoxShape.circle,
                              boxShadow: controller.isActiveTracking.value
                                  ? [
                                      BoxShadow(
                                        color: AppColor.primaryGreen
                                            .withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: const Icon(
                              Icons.directions_bus_sharp,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Obx(() {
                    if (!controller.isActiveTracking.value) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isEndingTrip.value
                              ? null
                              : () => controller.endTripAction(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isEndingTrip.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.flag,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "end_trip_button".tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          Obx(() {
            if (!controller.isLoading.value) return const SizedBox.shrink();
            return Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColor.primaryGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "loading_route".tr,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DriverMarker extends StatelessWidget {
  final double heading;
  const _DriverMarker({required this.heading});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: heading * 3.14159 / 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: AppColor.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const Icon(Icons.my_location, color: AppColor.white, size: 25),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
