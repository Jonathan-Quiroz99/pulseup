import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const String _prefsKey = 'user_session_data';

  /// Fields we allow to be written back to disk. The backend `/mobile/me`
  /// profile also carries `fotoBase64` (can be ~2MB) — that must never go
  /// into SharedPreferences, so persistence is restricted to this list.
  static const List<String> _persistedKeys = [
    'token',
    'member_id',
    'correo',
    'email',
    'display_name',
    'nombre',
    'apellidos',
    'telefono',
    'fechaNacimiento',
    'fecha_nacimiento',
    'membresia',
    'estado',
    'fechaInscripcion',
    'fecha_inscripcion',
    'ultimoCheckin',
    'ultimo_checkin',
    'role',
    'profile_image',
    'picture',
  ];

  // AUTH
  static String? token;

  // USER DATA
  static Map<String, dynamic>? currentUser;

  // BASIC INFO
  static String? memberId;
  static String? email;
  static String? displayName;
  static String? firstName;
  static String? lastName;
  static String? phone;
  static String? birthDate;

  // MEMBERSHIP
  static String? membership;
  static String? membershipStatus;
  static String? joinDate;

  // CHECKIN
  static String? lastCheckin;

  // ROLE / ACCESS
  static String? role;

  // PROFILE
  static String? profileImage;

  // FLAGS
  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  /// Backend `estado` is always the masculine literal ("Activo"), never
  /// "Activa". Kept as a single source of truth for the comparison.
  static bool get isActiveMember => membershipStatus == 'Activo';

  static String get fullName {
    final raw = (displayName != null && displayName!.isNotEmpty)
        ? displayName!
        : '${firstName ?? ''} ${lastName ?? ''}'.trim();
    // The backend stores some names all-caps — normalise to Title Case.
    return raw
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  // SET SESSION (in-memory + persisted). Used right after login/register.
  static Future<void> setSession(Map<String, dynamic> data) async {
    _populateFields(data);
    await _persist(data);
  }

  /// Merges a fresh `/mobile/me` profile into the current session so
  /// screens that re-fetch it (check-in, billing, tracking) keep the
  /// cached session honest instead of showing whatever was true at login.
  static Future<void> mergeProfile(Map<String, dynamic> profile) async {
    final merged = <String, dynamic>{
      ...?currentUser,
      ...profile,
    };
    _populateFields(merged);
    await _persist(merged);
  }

  // RESTORE SESSION on app startup. Returns true if a saved session was found.
  static Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null) return false;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _populateFields(data);
      return isLoggedIn;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _persist(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final slim = <String, dynamic>{
      for (final key in _persistedKeys)
        if (data.containsKey(key) && data[key] != null) key: data[key],
    };
    await prefs.setString(_prefsKey, jsonEncode(slim));
  }

  static void _populateFields(Map<String, dynamic> data) {
    currentUser = data;

    token = data['token'] ?? token;
    memberId = data['member_id'] ?? data['id'] ?? memberId;

    // Auth response uses `correo`; older code and Google flow used `email`.
    email = data['correo'] ?? data['email'] ?? email;

    displayName = data['display_name'] ?? data['displayName'] ?? displayName;

    firstName = data['nombre'] ?? firstName;
    lastName = data['apellidos'] ?? lastName;
    phone = data['telefono'] ?? phone;

    // Profile is camelCase (`fechaNacimiento`); keep snake_case as a fallback.
    birthDate = data['fechaNacimiento'] ?? data['fecha_nacimiento'] ?? birthDate;
    joinDate =
        data['fechaInscripcion'] ?? data['fecha_inscripcion'] ?? joinDate;
    lastCheckin =
        data['ultimoCheckin'] ?? data['ultimo_checkin'] ?? lastCheckin;

    membership = data['membresia'] ?? membership;
    membershipStatus = data['estado'] ?? membershipStatus;

    role = data['role'] ?? role;

    profileImage =
        data['profile_image'] ?? data['picture'] ?? profileImage;
  }

  // CLEAR SESSION
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);

    token = null;
    currentUser = null;
    memberId = null;
    email = null;
    displayName = null;
    firstName = null;
    lastName = null;
    phone = null;
    birthDate = null;
    membership = null;
    membershipStatus = null;
    joinDate = null;
    lastCheckin = null;
    role = null;
    profileImage = null;
  }
}
