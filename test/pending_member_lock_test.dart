import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/core/navigation/app_screen.dart';
import 'package:pulseup/features/auth/user_session.dart';
import 'package:pulseup/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    // Sin token el inicio no llama al servidor; la bienvenida ya se vio.
    SharedPreferences.setMockInitialValues({'welcome_seen_mem-1': true});
    await UserSession.logout();
    UserSession.memberId = 'mem-1';
  });

  test('only plan features require an active membership', () {
    expect(
      AppScreen.values.where((s) => s.requiresActivePlan),
      [AppScreen.routines, AppScreen.tracking, AppScreen.nutrition],
    );
  });

  testWidgets('pending member sees routines locked', (tester) async {
    UserSession.membershipStatus = 'Pendiente';
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Activa tu membresía'), findsOneWidget);

    await tester.tap(find.text('Rutinas'));
    await tester.pumpAndSettle();
    expect(find.text('Rutinas se activa con tu pago'), findsOneWidget);
    expect(find.text('Ver cómo pagar'), findsOneWidget);
  });

  testWidgets('active member gets the real screens', (tester) async {
    UserSession.membershipStatus = 'Activo';
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Activa tu membresía'), findsNothing);

    await tester.tap(find.text('Rutinas'));
    await tester.pumpAndSettle();
    expect(find.text('Rutinas se activa con tu pago'), findsNothing);
  });
}
