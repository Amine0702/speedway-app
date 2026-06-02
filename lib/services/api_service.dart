import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Central API service for SpeedWay backend (Spring Boot on port 8080).
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static const _keyToken = 'auth_token';
  static const _keyEmail = 'auth_email';
  static const _keyName = 'auth_name';

  static String? _token;
  static String? _userEmail;
  static String? _userName;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ── Session state ──────────────────────────────────────────────────────────

  static bool get isLoggedIn => _token != null;
  static String? get currentUserEmail => _userEmail;
  static String? get currentUserName => _userName;

  /// Call once at app start (before runApp or in main()) to restore session.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_keyToken);
    _userEmail = prefs.getString(_keyEmail);
    _userName = prefs.getString(_keyName);
  }

  static Future<void> _saveSession(
    String token,
    String email,
    String name,
  ) async {
    _token = token;
    _userEmail = email;
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyName, name);
  }

  static Future<void> _clearSession() async {
    _token = null;
    _userEmail = null;
    _userName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);
  }

  // ── Auth ───────────────────────────────────────────────────────────────────

  static Future<String> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );
    _handleErrors(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['accessToken'] as String;
    await _saveSession(token, email, fullName);
    return token;
  }

  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    _handleErrors(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['accessToken'] as String;
    final name = data['fullName'] as String? ?? email.split('@').first;
    await _saveSession(token, email, name);
    return token;
  }

  static Future<void> logout() async {
    await _clearSession();
  }

  // ── Cars ───────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getCars() async {
    final res = await http.get(Uri.parse('$baseUrl/cars'), headers: _headers);
    _handleErrors(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['content'] as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> getCar(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/cars/$id'),
      headers: _headers,
    );
    _handleErrors(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Returns a list of {startDate, endDate} strings for already-booked periods.
  static Future<List<Map<String, dynamic>>> getCarUnavailableDates(
    String carId,
  ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/cars/$carId/unavailable-dates'),
      headers: _headers,
    );
    _handleErrors(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  // ✅ FIX: Handles both "isAvailable" and "available" JSON keys.
  static bool parseIsAvailable(Map<String, dynamic> car) {
    final v = car['isAvailable'] ?? car['available'];
    if (v == null) return true;
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    return true;
  }

  // ── Reservations ───────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createReservation({
    required String carId,
    required String fullName,
    required String phone,
    required String permitNumber,
    required String mileage,
    required String deposit,
    required DateTime startDate,
    required DateTime endDate,
    required String pickupLocation,
    required String nationality,
    required String documentNumber,
    File? documentImageFile,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reservations'),
      headers: _headers,
      body: jsonEncode({
        'carId': carId,
        'fullName': fullName,
        'phone': phone,
        'permitNumber': permitNumber,
        'mileage': int.tryParse(mileage) ?? 0,
        'deposit': double.tryParse(deposit) ?? 0.0,
        'startDate': startDate.toIso8601String().substring(0, 10),
        'endDate': endDate.toIso8601String().substring(0, 10),
        'pickupLocation': pickupLocation,
        'nationality': nationality,
        'documentNumber': documentNumber,
      }),
    );
    _handleErrors(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getMyReservations() async {
    final res = await http.get(
      Uri.parse('$baseUrl/reservations/my'),
      headers: _headers,
    );
    _handleErrors(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  // ── Error handling ─────────────────────────────────────────────────────────

  static void _handleErrors(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    String message = 'Erreur serveur (${res.statusCode})';
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? message;
    } catch (_) {}
    throw ApiException(res.statusCode, message);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
