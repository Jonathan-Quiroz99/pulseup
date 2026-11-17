import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/features/tracking/services/progress_insights.dart';
import 'package:pulseup/features/tracking/widgets/goal_card.dart';

Future<int> _pumpAndTap(WidgetTester tester, GoalProgress p, Finder target) async {
  var edits = 0;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: GoalCard(progress: p, goal: p.goal, weeklyRate: null, onEdit: () => edits++),
      ),
    ),
  ));
  await tester.tap(target);
  await tester.pump();
  return edits;
}

void main() {
  const inProgress = GoalProgress(
      start: 88, current: 88, goal: 84, fraction: 0, reached: false, eta: null);

  testWidgets('tocar cualquier parte de la tarjeta abre el editor', (tester) async {
    // Antes solo respondía el texto "Editar" (área táctil mínima).
    expect(await _pumpAndTap(tester, inProgress, find.text('Meta 84.0')), 1);
  });

  testWidgets('el botón Editar sigue funcionando', (tester) async {
    expect(await _pumpAndTap(tester, inProgress, find.text('Editar')), 1);
  });

  testWidgets('meta cumplida: logro + botón para definir la siguiente', (tester) async {
    const reached = GoalProgress(
        start: 88, current: 83.8, goal: 84, fraction: 1, reached: true, eta: null);
    final edits = await _pumpAndTap(tester, reached, find.text('Definir nueva meta'));
    expect(edits, 1);
    expect(find.text('META CUMPLIDA'), findsOneWidget);
    expect(find.textContaining('Bajaste 4.2 kg desde 88.0 kg'), findsOneWidget);
  });
}
