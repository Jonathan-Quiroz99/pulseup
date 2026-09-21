// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/http_helpers.dart';

/// Thrown by [ApiService.googleLogin] when the backend confirms no account
/// exists for that Google identity yet (HTTP 404) — the caller should route
/// the user to registration instead of treating this as a generic error.
class GoogleAccountNotFoundException implements Exception {
  final String message;
  GoogleAccountNotFoundException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = ApiConfig.fullUrl;

  Map<String, dynamic> _decodeOrThrow(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data as Map<String, dynamic>;
    }
    throw Exception(data['detail'] ?? data['message'] ?? response.body);
  }

  /// Manual (correo/contraseña) registration. Creates the member as
  /// "Pendiente" with the chosen plan — activation happens via payment
  /// (online) or staff confirmation (efectivo).
  Future<Map<String, dynamic>> registerMember({
    required String nombre,
    required String apellidos,
    required String correo,
    required String telefono,
    required String fechaNacimiento,
    required String plan,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/public/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'apellidos': apellidos,
        'correo': correo,
        'telefono': telefono,
        'fechaNacimiento': fechaNacimiento,
        'plan': plan,
        'password': password,
      }),
    ).timeout(apiTimeout);

    debugPrintApi('REGISTER STATUS: ${response.statusCode}');
    debugPrintApi('REGISTER BODY: ${response.body}');

    return _decodeOrThrow(response);
  }

  /// Registers a brand-new member using a verified Google credential. Only
  /// call this after [googleLogin] confirms the account does not exist yet.
  Future<Map<String, dynamic>> registerGoogleMember({
    required String credential,
    required String nombre,
    required String apellidos,
    required String telefono,
    required String fechaNacimiento,
    required String plan,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/public/register/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'credential': credential,
        'nombre': nombre,
        'apellidos': apellidos,
        'telefono': telefono,
        'fechaNacimiento': fechaNacimiento,
        'plan': plan,
      }),
    ).timeout(apiTimeout);

    debugPrintApi('REGISTER GOOGLE STATUS: ${response.statusCode}');
    debugPrintApi('REGISTER GOOGLE BODY: ${response.body}');

    return _decodeOrThrow(response);
  }

  // Login de miembros (correo/contraseña) para tu app móvil
  Future<Map<String, dynamic>> memberLogin(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/mobile/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': email,
        'password': password,
      }),
    ).timeout(apiTimeout);

    debugPrintApi('STATUS CODE: ${response.statusCode}');
    debugPrintApi('BODY: ${response.body}');

    return _decodeOrThrow(response);
  }

  /// Logs in with a Google credential for an EXISTING member only. Throws
  /// [GoogleAccountNotFoundException] (not a generic Exception) when the
  /// backend reports no account exists yet, so the caller can route to
  /// registration instead of showing an error.
  Future<Map<String, dynamic>> googleLogin(
    String credential,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/public/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'credential': credential}),
    ).timeout(apiTimeout);

    debugPrintApi('GOOGLE STATUS: ${response.statusCode}');
    debugPrintApi('GOOGLE BODY: ${response.body}');

    if (response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw GoogleAccountNotFoundException(
        data['detail'] ?? 'Cuenta de Google no registrada',
      );
    }

    return _decodeOrThrow(response);
  }

  /// Fetches the active membership catalog (id, nombre, precio, duracion,
  /// beneficios) so registration can show real plans instead of a static
  /// list.
  Future<List<Map<String, dynamic>>> getPlans() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/public/plans'),
    ).timeout(apiTimeout);

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los planes');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  /// Fetches the current member's profile (used to re-check membership
  /// status, e.g. after returning from an online payment).
  Future<Map<String, dynamic>> getMemberProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/me'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener el perfil');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Fetches the current member's payment history.
  Future<List<Map<String, dynamic>>> getMemberPayments(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/me/payments'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(apiTimeout);

    await checkAuthResponse(response);

    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener el historial de pagos');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  /// Creates a MercadoPago checkout preference and returns the URL to open
  /// (init_point) so the member can pay for their membership online.
  Future<String> createPaymentPreference({
    required String concepto,
    required String monto,
    required String email,
    required String memberId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/mp/preference/public'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'concepto': concepto,
        'monto': monto,
        'email': email,
        'member_id': memberId,
      }),
    ).timeout(apiTimeout);

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'No se pudo iniciar el pago');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['init_point'] as String;
  }
}

/// Thin wrapper so API request/response logging is a single place to
/// eventually swap for a real logging framework. Silent in release builds
/// so tokens and response bodies don't land in device logs.
void debugPrintApi(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
