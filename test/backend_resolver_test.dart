import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/core/backend_resolver.dart';

void main() {
  group('BackendResolver.normalizeServerInput', () {
    test('IP sola -> http con puerto 8000', () {
      expect(BackendResolver.normalizeServerInput('192.168.137.1'),
          'http://192.168.137.1:8000');
    });
    test('IP con puerto se respeta', () {
      expect(BackendResolver.normalizeServerInput(' 10.0.0.5:9000/ '),
          'http://10.0.0.5:9000');
    });
    test('URL completa se respeta', () {
      expect(BackendResolver.normalizeServerInput('https://x.onrender.com/'),
          'https://x.onrender.com');
    });
    test('esquemas raros se rechazan', () {
      expect(BackendResolver.normalizeServerInput('javascript://x'), isNull);
      expect(BackendResolver.normalizeServerInput('ftp://10.0.0.1'), isNull);
    });
    test('vacío -> null (automático)', () {
      expect(BackendResolver.normalizeServerInput('   '), isNull);
    });
  });
}
