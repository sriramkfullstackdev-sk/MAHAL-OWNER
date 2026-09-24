import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api/api_constants.dart';
import '../routes/app_routes.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();

  factory FcmService() => _instance;

  FcmService._internal();

  Future<String?> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('FCM permission denied by user.');
      return null;
    }

    FirebaseMessaging.onMessage.listen((message) {
      final context = navigatorKey.currentState?.overlay?.context;
      if (context == null || !context.mounted) return;

      final title = message.notification?.title ?? message.data['title']?.toString() ?? 'Booking Notification';
      final body = message.notification?.body ?? message.data['body']?.toString() ?? '';
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openBookingFromMessage(message, navigatorKey);
    });

    final initialMessage = await messaging.getInitialMessage();
    final initialBookingId = _bookingIdFromMessage(initialMessage);

    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      ApiConstants.fcmToken = token;
      if (ApiConstants.token != null) {
        await saveTokenToBackend(token);
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      ApiConstants.fcmToken = newToken;
      if (ApiConstants.token != null) {
        await saveTokenToBackend(newToken);
      }
    });

    return initialBookingId;
  }

  String? _bookingIdFromMessage(RemoteMessage? message) {
    final bookingId = message?.data['booking_id']?.toString();
    return bookingId == null || bookingId.isEmpty ? null : bookingId;
  }

  void _openBookingFromMessage(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final bookingId = _bookingIdFromMessage(message);
    final navigator = navigatorKey.currentState;
    if (bookingId == null || navigator == null) return;

    navigator.pushNamed(
      AppRoutes.bookingDetails,
      arguments: {'bookingId': bookingId},
    );
  }

  Future<void> registerCurrentDevice() async {
    if (ApiConstants.token == null) {
      return;
    }

    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    ApiConstants.fcmToken = token;
    await saveTokenToBackend(token);
  }

  Future<void> saveTokenToBackend(String token) async {
    if (ApiConstants.token == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.notificationUrl}/save-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConstants.token}',
      },
      body: jsonEncode({
        'fcm_token': token,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('FCM token saved successfully.');
    } else {
      debugPrint('Failed to save FCM token: ${response.body}');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
