import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/features/tracking/models/body_measurement.dart';
import 'package:pulseup/features/tracking/services/progress_insights.dart';

BodyMeasurement _m(String date, double kg, {double? fat, double? waist}) => BodyMeasurement(
      id: date,
      memberId: 'mem-1',
      date: date,
      weightKg: kg,
      bodyFat: fat,
      waist: waist,
      notes: '',
    );

void main() {
  final peso = ProgressMetric.all.first;
  final grasa = ProgressMetric.all.firstWhere((m) => m.key == 'grasa');

  // Como las manda el backend: la más reciente primero.
  final losing = [
    _m('2026-03-29', 87.0, fat: 24),
    _m('2026-03-22', 88.0),
    _m('2026-03-15', 89.0, fat: 25),
    _m('2026-03-08', 90.0, fat: 26),
  ];

  test('series cronológica y medidas disponibles', () {
    final i = ProgressInsights(losing);
    expect(i.series(peso).map((p) => p.value), [90, 89, 88, 87]);
    expect(i.series(grasa).map((p) => p.value), [26, 25, 24]);
    expect(i.availableMetrics().map((m) => m.key), ['peso', 'grasa']);
  });

  test('cambios desde el inicio y desde la anterior', () {
    final c = ProgressInsights(losing).changes(peso);
    expect(c.sinceStart, closeTo(-3, 1e-9));
    expect(c.sinceLast, closeTo(-1, 1e-9));
    expect(ProgressInsights([losing.first]).changes(peso).sinceStart, isNull);
  });

  test('ritmo semanal por regresión', () {
    expect(ProgressInsights(losing).weeklyRate(peso), closeTo(-1, 1e-6));
    // Menos de 7 días entre mediciones: no hay tendencia todavía.
    final sameWeek = [_m('2026-03-03', 89), _m('2026-03-01', 90)];
    expect(ProgressInsights(sameWeek).weeklyRate(peso), isNull);
  });

  test('meta: avance, lo que falta y fecha estimada', () {
    final g = ProgressInsights(losing).weightGoal(80)!;
    expect(g.start, 90);
    expect(g.current, 87);
    expect(g.losing, isTrue);
    expect(g.remaining, closeTo(7, 1e-9));
    expect(g.fraction, closeTo(0.3, 1e-9));
    expect(g.reached, isFalse);
    // 7 kg a 1 kg/semana -> 7 semanas después de la última medición.
    expect(g.eta, DateTime(2026, 3, 29).add(const Duration(days: 49)));
  });

  test('meta alcanzada o tendencia en contra', () {
    expect(ProgressInsights(losing).weightGoal(88)!.reached, isTrue);
    expect(ProgressInsights(losing).weightGoal(88)!.fraction, 1.0);
    // Quiere subir a 95 pero viene bajando: sin fecha estimada.
    final gain = ProgressInsights(losing).weightGoal(95)!;
    expect(gain.losing, isFalse);
    expect(gain.fraction, 0.0);
    expect(gain.eta, isNull);
    expect(ProgressInsights(losing).weightGoal(null), isNull);
    expect(ProgressInsights(const []).weightGoal(80), isNull);
  });

  test('meta nueva después de cumplir otra se mide desde su propio inicio', () {
    // Bajó de 90 a 87; ahora quiere SUBIR a 89 (meta definida pesando 87).
    // Antes se medía desde 90: salía "bajar" y "cumplida" de inmediato.
    final g = ProgressInsights(losing).weightGoal(89, startKg: 87)!;
    expect(g.start, 87);
    expect(g.losing, isFalse);
    expect(g.reached, isFalse);
    expect(g.remaining, closeTo(2, 1e-9));
    expect(g.fraction, 0.0);
    final s = ProgressInsights(losing).summary(89, goalStartKg: 87)!;
    expect(s.detail, contains('subir'));
  });

  test('corrección de meta en curso: el avance sigue contando desde el inicio', () {
    final g = ProgressInsights(losing).weightGoal(84, startKg: 90)!;
    expect(g.fraction, closeTo(0.5, 1e-9)); // 3 de 6 kg
  });

  test('qué cambio cuenta como mejora', () {
    expect(ProgressInsights.isImprovement(grasa, -1), isTrue);
    expect(ProgressInsights.isImprovement(grasa, 1), isFalse);
    expect(ProgressInsights.isImprovement(peso, -1), isNull); // sin meta: neutro
    expect(ProgressInsights.isImprovement(peso, -1, weightGoal: 80, current: 87), isTrue);
    expect(ProgressInsights.isImprovement(peso, -1, weightGoal: 95, current: 87), isFalse);
    expect(ProgressInsights.isImprovement(peso, 0.01, weightGoal: 80, current: 87), isNull);
  });

  test('días desde la última medición', () {
    final i = ProgressInsights(losing, now: DateTime(2026, 4, 8, 22));
    expect(i.daysSinceLast(), 10);
    expect(ProgressInsights(const []).daysSinceLast(), isNull);
  });

  test('resumen en palabras', () {
    final i = ProgressInsights(losing);
    expect(i.summary(null)!.title, 'Has bajado 3.0 kg en 3 semanas');
    expect(i.summary(null)!.detail, contains('Define una meta'));
    expect(i.summary(80)!.detail, 'Vas por buen camino. Te faltan 7.0 kg para tu meta.');
    expect(i.summary(88)!.detail, contains('Llegaste a tu meta'));
    expect(i.summary(95)!.detail, contains('Tu meta es subir'));
    expect(ProgressInsights([losing.first]).summary(80)!.title, 'Tu punto de partida: 87.0 kg');
    expect(ProgressInsights(const []).summary(80), isNull);
    // Muy rapido: -2 kg/semana.
    final fast = [_m('2026-03-15', 86), _m('2026-03-08', 88), _m('2026-03-01', 90)];
    expect(ProgressInsights(fast).summary(70)!.detail, contains('Vas rápido'));
  });
}
