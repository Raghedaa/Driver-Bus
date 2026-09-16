class AppLink {
  static const String baseUrl = "https://syria-travel.app/api";

  // Auth
  static const String sendOtp = "$baseUrl/auth/otp/send";
  static const String verifyOtp = "$baseUrl/auth/otp/verify";
  static const String loginOtp = "$baseUrl/auth/otp/login";

  //Profile
  static const String driverProfile = "$baseUrl/driver/driver-profile";

  // Trips
  static const String driverTrips = "$baseUrl/driver/trips";

  // Trip Details
  static String driverTripDetails(int tripId) =>
      "$baseUrl/driver/trips/$tripId";

  // Update Trip Status
  static String updateTripStatus(int tripId) =>
      "$baseUrl/driver/trips/$tripId/status";

  static String tripPassengers(int tripId) =>
      "/driver/trips/$tripId/passengers";

  static const String stations = "$baseUrl/stations";
  static const String cities = "$baseUrl/cities";
  static const String restAreas = "$baseUrl/rest-areas";

  // Bookings
  static const String verifyTicket = "/driver/bookings/verify";
  static const String updateFcmToken = "$baseUrl/auth/fcm-token";
  //Notifications
  static const String getNotifications = "$baseUrl/notifications";

  static const String markAllNotifications = "$baseUrl/notifications/mark-all";
  static const String unreadNotificationsCount =
      "$baseUrl/notifications/unread-count";

  static String markNotificationAsRead(String id) =>
      "$baseUrl/notifications/$id/mark";

  static String trackTripLocation(int tripId) =>
      "$baseUrl/driver/trips/$tripId/track";
}
