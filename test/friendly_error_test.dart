import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/core/http_helpers.dart';

void main() {
  test('Google sin internet no muestra el PlatformException crudo', () {
    final msg = friendlyError(
        PlatformException(code: 'network_error', message: 'm1.d: 7: '));
    expect(msg, contains('internet'));
    expect(msg, isNot(contains('PlatformException')));
  });

  test('otros errores de Google tambien salen en palabras', () {
    final msg = friendlyError(PlatformException(code: 'sign_in_failed'));
    expect(msg, isNot(contains('PlatformException')));
  });

  test('mensaje del servidor pasa sin el prefijo "Exception:"', () {
    expect(friendlyError(Exception('No se pudo conectar con MercadoPago.')),
        'No se pudo conectar con MercadoPago.');
  });
}
