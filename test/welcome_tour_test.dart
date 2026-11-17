import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/features/auth/user_session.dart';
import 'package:pulseup/features/onboarding/welcome_tour.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserSession.logout();
    UserSession.memberId = 'mem-7';
    UserSession.firstName = 'ROLANDO';
  });

  Future<void> openFromHome(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => WelcomeTour.showIfFirstTime(context),
            child: const Text('home'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows once per member and walks to the data step', (tester) async {
    await openFromHome(tester);
    expect(find.text('¡Bienvenido, Rolando!'), findsOneWidget);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();
    }
    expect(find.text('Tus datos, una sola vez'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '50');
    await tester.tap(find.text('Guardar y empezar'));
    await tester.pumpAndSettle();
    expect(find.text('La altura debe estar entre 120 y 230 cm'), findsOneWidget);

    await tester.tap(find.text('Lo hago después'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);

    // Ya visto: no vuelve a salir para este socio.
    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(find.byType(WelcomeTour), findsNothing);
  });

  testWidgets('a different member sees it too', (tester) async {
    SharedPreferences.setMockInitialValues({'welcome_seen_mem-7': true});
    UserSession.memberId = 'mem-8';
    await openFromHome(tester);
    expect(find.byType(WelcomeTour), findsOneWidget);
  });
}
