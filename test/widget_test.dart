// Smoke test: the app boots to the login screen when there's no saved
// session, without throwing.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pulseup/main.dart';

void main() {
  testWidgets('boots to login screen with no saved session', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());

    // _StartupGate shows a loader until restoreSession() resolves.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
