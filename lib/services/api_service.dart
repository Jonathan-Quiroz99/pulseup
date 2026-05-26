// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class ApiService {
  static const String _baseUrl = ApiConfig.fullUrl;
  String? _token;
  
  void setToken(String token) {
    _token = token;
  }
  
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<Map<String, dynamic>> registerMember({

  required String nombre,
  required String apellidos,
  required String correo,
  required String telefono,
  required String fechaNacimiento,
  required String membresia,
  required String password,

}) async {

  final response = await http.post(

    Uri.parse(
      '$_baseUrl/mobile/auth/register',
    ),

    headers: {
      'Content-Type': 'application/json',
    },

    body: jsonEncode({

      'nombre': nombre,

      'apellidos': apellidos,

      'correo': correo,

      'telefono': telefono,

      'fechaNacimiento': fechaNacimiento,

      'membresia': membresia,

      'password': password,
    }),
  );

  print(
    'REGISTER STATUS: ${response.statusCode}',
  );

  print(
    'REGISTER BODY: ${response.body}',
  );

  final data = jsonDecode(response.body);

  if (
      response.statusCode == 200 ||
      response.statusCode == 201
  ) {

    if (data['token'] != null) {

      _token = data['token'];
    }

    return data;

  } else {

    throw Exception(

      data['detail'] ??
      data['message'] ??
      response.body,
    );
  }
}
  
  // 1. Login de miembros (para tu app móvil)
  Future<Map<String, dynamic>> memberLogin(
    String email,
    String password,
  ) async {

    final response = await http.post(
      Uri.parse('$_baseUrl/mobile/auth/login'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'correo': email,
        'password': password,
      }),
    );

    print('STATUS CODE: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      _token = data['token'];

      return data;

    } else {

      throw Exception(response.body);
    }
  }  

  Future<Map<String, dynamic>> googleLogin(
    String credential,
  ) async {

    final response = await http.post(
      Uri.parse('$_baseUrl/mobile/auth/google'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'credential': credential,
      }),
    );

    print('GOOGLE STATUS: ${response.statusCode}');
    print('GOOGLE BODY: ${response.body}');

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      _token = data['token'];

      return data;

    } else {

      throw Exception(response.body);
    }
  }
  
  // 2. Obtener perfil del miembro
  Future<Map<String, dynamic>> getMemberProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/members/me'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get profile');
    }
  }
  
  // 3. Obtener membresía actual
  Future<Map<String, dynamic>> getCurrentMembership() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/memberships/current'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get membership');
    }
  }
  
  // 4. Registrar check-in
  Future<Map<String, dynamic>> registerCheckin(String method) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/mobile/checkins'),
      headers: _getHeaders(),
      body: jsonEncode({
        'metodo': method, // 'QR', 'Manual', 'App'
        'puerta': 'App Móvil',
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register checkin');
    }
  }
  
  // 5. Obtener historial de pagos
  Future<List<dynamic>> getPaymentHistory() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/payments'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get payment history');
    }
  }
  
  // 6. Obtener historial de check-ins
  Future<List<dynamic>> getCheckinHistory() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/checkins/history'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get checkin history');
    }
  }
  
  // 7. Obtener planes de entrenamiento
  Future<List<dynamic>> getWorkoutPlans() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/workout-plans'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get workout plans');
    }
  }
  
  // 8. Obtener clases disponibles
  Future<List<dynamic>> getAvailableClasses() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/classes'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get classes');
    }
  }
  
  // 9. Registrar en una clase
  Future<void> enrollInClass(String classId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/mobile/classes/$classId/enroll'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to enroll in class');
    }
  }
  
  // 10. Obtener mediciones corporales
  Future<List<dynamic>> getBodyMeasurements() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mobile/measurements'),
      headers: _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get measurements');
    }
  }
}