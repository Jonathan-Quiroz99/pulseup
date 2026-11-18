import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/features/onboarding/section_guide.dart';
import 'package:pulseup/features/tracking/models/body_measurement.dart';
import 'package:pulseup/features/tracking/widgets/measurement_picker_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pantalla de prueba con un botón "Analizar" que el tutorial debe señalar.
class _Screen extends StatefulWidget {
  final bool withHidden;
  const _Screen({this.withHidden = false});

  @override
  State<_Screen> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  final analyzeKey = GlobalKey();
  final missingKey = GlobalKey(); // nunca se pone en pantalla

  List<GuideStep> steps() => [
        GuideStep(
          target: analyzeKey,
          icon: Icons.auto_awesome,
          title: 'Analiza con IA',
          body: 'Presiona aquí',
        ),
        if (widget.withHidden)
          GuideStep(target: missingKey, icon: Icons.close, title: 'No existe', body: '-'),
        const GuideStep(icon: Icons.info_outline, title: 'Solo texto', body: 'Sin hueco'),
      ];

  @override
  void initState() {
    super.initState();
    SectionGuide.showIfFirstTime(context, 'prueba', steps);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(key: analyzeKey, onPressed: () {}, child: const Text('Analizar')),
        ),
      );
}

Future<void> _open(WidgetTester tester, {bool withHidden = false}) async {
  await tester.pumpWidget(MaterialApp(home: _Screen(withHidden: withHidden)));
  // Espera de SectionGuide (350 ms) + animaciones.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sale la primera vez, se avanza y no vuelve a salir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _open(tester);

    expect(find.text('Analiza con IA'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Solo texto'), findsOneWidget);
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
    expect(find.text('Solo texto'), findsNothing);

    // Segunda vez que se abre la sección: ya no sale.
    await tester.pumpWidget(const SizedBox());
    await _open(tester);
    expect(find.text('Analiza con IA'), findsNothing);
  });

  testWidgets('salta los pasos cuyo botón no está en la pantalla', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _open(tester, withHidden: true);
    expect(find.text('1/2'), findsOneWidget); // 3 pasos, 1 sin widget
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('No existe'), findsNothing);
    expect(find.text('Solo texto'), findsOneWidget);
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
  });

  testWidgets('si la capa se quita sin cerrarla, la siguiente guía igual sale', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _open(tester);
    expect(find.text('Analiza con IA'), findsOneWidget);
    // Simula cerrar sesión: se reemplaza toda la app.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    SharedPreferences.setMockInitialValues({});
    await _open(tester);
    expect(find.text('Analiza con IA'), findsOneWidget);
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();
  });

  testWidgets('"Saltar" cierra el tutorial', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _open(tester);
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();
    expect(find.text('Analiza con IA'), findsNothing);
    expect(find.text('Analizar'), findsOneWidget);
  });

  testWidgets('el selector de registro devuelve el elegido', (tester) async {
    BodyMeasurement m(String id, double kg) => BodyMeasurement(
        id: id, memberId: 'mem-1', date: '2026-11-18', weightKg: kg, notes: '');
    final measurements = [m('meas-2', 80), m('meas-1', 84)];
    BodyMeasurement? picked;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => picked = await MeasurementPickerSheet.show(
              context,
              measurements: measurements,
              initialId: 'meas-1',
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('84.0 kg · 18 nov'), findsOneWidget);
    expect(find.text('80.0 kg · 18 nov'), findsOneWidget);
    // Preseleccionado el de 84; el socio cambia al de 80.
    await tester.tap(find.text('80.0 kg · 18 nov'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar este registro'));
    await tester.pumpAndSettle();
    expect(picked?.id, 'meas-2');
  });
}
