import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_constants.dart';

class AuthService {

  static const _tokenKey = 'owner_jwt_token';
  static const _phoneKey = 'owner_phone';
  static const _ownerIdKey = 'owner_id';
  static const _registrationCompleteKey = 'owner_registration_complete';

  static bool registrationComplete = false;

  static Future<void> saveSession({
    required String token,
    required String phone,
    String? ownerId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_phoneKey, phone);
    if (ownerId != null) await prefs.setString(_ownerIdKey, ownerId);
  }

  static Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return false;

    ApiConstants.token = token;
    ApiConstants.phone = prefs.getString(_phoneKey);
    ApiConstants.mahalownerId = prefs.getString(_ownerIdKey);
    registrationComplete = prefs.getBool(_registrationCompleteKey) ?? true;
    return true;
  }

  static Future<void> setRegistrationComplete(bool value) async {
    registrationComplete = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_registrationCompleteKey, value);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_ownerIdKey);
    await prefs.remove(_registrationCompleteKey);
    ApiConstants.token = null;
    ApiConstants.phone = null;
    ApiConstants.mahalownerId = null;
    registrationComplete = false;
  }

  static Future<Map<String,dynamic>> checkMobile(String phoneNumber) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/check-mobile"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "phone_number": phoneNumber
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String,dynamic>> sendOtp(
      String phoneNumber) async {

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/send-otp"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "phone_number": phoneNumber
      }),
    );

    return jsonDecode(response.body);
  }

}