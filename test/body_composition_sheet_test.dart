import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/features/tracking/models/body_composition.dart';
import 'package:pulseup/features/tracking/widgets/body_composition_sheet.dart';

BodyComposition _result({bool photoUsed = true, List<String> warnings = const []}) =>
    BodyComposition.fromJson({
      'bodyFatPct': 18.7, 'bodyFatLow': 14.7, 'bodyFatHigh': 22.7,
      'musclePct': 40.6, 'leanMassKg': 61, 'fatMassKg': 14, 'bmi': 23.7,
      'formulaBodyFatPct': 21.6, 'formulaMethod': 'cintura',
      'photoBodyFatPct': 12, 'photoUsed': photoUsed,
      'photoCues': 'abdomen plano', 'warnings': warnings,
    });

Future<void> _pump(WidgetTester tester, Widget sheet) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: sheet)));
}

void main() {
  testWidgets('muestra el estimado como rango y de dónde sale', (tester) async {
    await _pump(tester, BodyCompositionSheet(
        result: _result(), measurementLabel: '14 nov', canSave: true));
    expect(find.text('18.7 %'), findsOneWidget);
    expect(find.text('entre 14.7 y 22.7 %'), findsOneWidget);
    expect(find.text('40.6 %'), findsOneWidget);
    expect(find.text('Tus medidas (cintura y altura)'), findsOneWidget);
    expect(find.text('La IA vio: abdomen plano'), findsOneWidget);
    expect(find.text('Guardar en mis medidas'), findsOneWidget);
  });

  testWidgets('sin medidas recientes no ofrece guardar y muestra avisos', (tester) async {
    await _pump(tester, BodyCompositionSheet(
        result: _result(photoUsed: false, warnings: ['La foto no coincide']),
        measurementLabel: '1 oct', canSave: false));
    expect(find.text('Guardar en mis medidas'), findsNothing);
    expect(find.text('La foto no coincide'), findsOneWidget);
    expect(find.text('no usado'), findsOneWidget);
  });
}
