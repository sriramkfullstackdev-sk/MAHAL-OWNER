class ApiConstants {
  static const String apiBase = "http://192.168.29.236:3000/api";
  static const String authUrl = "$apiBase/auth";
  static const String ownerUrl = "$apiBase/owner";
  static const String mahalUrl = "$apiBase/mahal";
  static const String bookingsUrl = "$apiBase/bookings";
  static const String notificationUrl = "$apiBase/notification";

  static const String baseUrl = authUrl;

  // Global Session storage
  static String? token;
  static String? phone;
  static String? mahalownerId;
  static String? mahalId;
  static String? fcmToken;
}