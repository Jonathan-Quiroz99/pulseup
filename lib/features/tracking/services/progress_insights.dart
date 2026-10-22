import '../models/body_measurement.dart';

/// Una medida que se puede graficar (peso, grasa, cintura...).
class ProgressMetric {
  final String key;
  final String label;
  final String unit;

  /// true = bajar es lo deseable (grasa, cintura); null = depende de la meta
  /// (peso); false = subir es lo deseable (músculo).
  final bool? lowerIsBetter;
  final double? Function(BodyMeasurement m) read;

  const ProgressMetric(this.key, this.label, this.unit, this.lowerIsBetter, this.read);

  static final all = <ProgressMetric>[
    ProgressMetric('peso', 'Peso', 'kg', null, (m) => m.weightKg > 0 ? m.weightKg : null),
    ProgressMetric('grasa', 'Grasa', '%', true, (m) => m.bodyFat),
    ProgressMetric('musculo', 'Músculo', '%', false, (m) => m.muscle),
    ProgressMetric('cintura', 'Cintura', 'cm', true, (m) => m.waist),
    ProgressMetric('cadera', 'Cadera', 'cm', true, (m) => m.hip),
    ProgressMetric('pecho', 'Pecho', 'cm', null, (m) => m.chest),
    ProgressMetric('brazo', 'Brazo', 'cm', false, (m) => m.arm),
  ];
}

class MetricPoint {
  final DateTime date;
  final double value;
  const MetricPoint(this.date, this.value);
}

/// Estado de la meta de peso, al estilo de las apps de progreso (Happy
/// Scale, etc.): punto de partida, avance, lo que falta y una fecha estimada
/// según la tendencia reciente, no según la última pesada (que varía mucho
/// día a día).
class GoalProgress {
  final double start;
  final double current;
  final double goal;

  /// 0..1 del camino recorrido entre [start] y [goal].
  final double fraction;
  final bool reached;

  /// Fecha estimada para llegar, o null si la tendencia no apunta a la meta
  /// o no hay datos suficientes.
  final DateTime? eta;

  const GoalProgress({
    required this.start,
    required this.current,
    required this.goal,
    required this.fraction,
    required this.reached,
    required this.eta,
  });

  bool get losing => goal < start;
  double get remaining => (current - goal).abs();
}

class ProgressInsights {
  /// [measurements] como vienen del backend: la más reciente primero.
  ProgressInsights(List<BodyMeasurement> measurements, {DateTime? now})
      : _chrono = [
          for (final m in measurements.reversed)
            if (DateTime.tryParse(m.date) != null) m,
        ],
        _now = now ?? DateTime.now();

  final List<BodyMeasurement> _chrono;
  final DateTime _now;

  /// Serie cronológica (más vieja primero) de una medida.
  List<MetricPoint> series(ProgressMetric metric) => [
        for (final m in _chrono)
          if (metric.read(m) case final v?) MetricPoint(DateTime.parse(m.date), v),
      ];

  /// Medidas con al menos un dato, en el orden de [ProgressMetric.all].
  List<ProgressMetric> availableMetrics() =>
      ProgressMetric.all.where((m) => series(m).isNotEmpty).toList();

  /// Cambio desde la primera medición y desde la anterior (null si no hay).
  ({double? sinceStart, double? sinceLast}) changes(ProgressMetric metric) {
    final s = series(metric);
    if (s.length < 2) return (sinceStart: null, sinceLast: null);
    return (
      sinceStart: s.last.value - s.first.value,
      sinceLast: s.last.value - s[s.length - 2].value,
    );
  }

  /// Días desde la última medición (null si no hay ninguna).
  int? daysSinceLast() {
    if (_chrono.isEmpty) return null;
    final last = DateTime.parse(_chrono.last.date);
    final today = DateTime(_now.year, _now.month, _now.day);
    return today.difference(DateTime(last.year, last.month, last.day)).inDays;
  }

  /// Ritmo en unidades por semana (regresión lineal de los últimos
  /// [windowDays] días). Null con menos de 2 puntos o menos de 7 días de
  /// diferencia entre el primero y el último: no alcanza para una tendencia.
  double? weeklyRate(ProgressMetric metric, {int windowDays = 56}) {
    final s = series(metric);
    if (s.isEmpty) return null;
    final cutoff = s.last.date.subtract(Duration(days: windowDays));
    final pts = s.where((p) => !p.date.isBefore(cutoff)).toList();
    if (pts.length < 2) return null;
    if (pts.last.date.difference(pts.first.date).inDays < 7) return null;

    final t0 = pts.first.date;
    final xs = [for (final p in pts) p.date.difference(t0).inHours / 24.0];
    final ys = [for (final p in pts) p.value];
    final n = pts.length;
    final mx = xs.reduce((a, b) => a + b) / n;
    final my = ys.reduce((a, b) => a + b) / n;
    var num = 0.0, den = 0.0;
    for (var i = 0; i < n; i++) {
      num += (xs[i] - mx) * (ys[i] - my);
      den += (xs[i] - mx) * (xs[i] - mx);
    }
    if (den == 0) return null;
    return num / den * 7;
  }

  GoalProgress? weightGoal(double? goal) {
    if (goal == null) return null;
    final weight = ProgressMetric.all.first;
    final s = series(weight);
    if (s.isEmpty) return null;

    final start = s.first.value;
    final current = s.last.value;
    final totalDistance = (start - goal).abs();
    // Meta igual al peso inicial, o ya cruzada en la dirección elegida.
    final reached = totalDistance < 0.05 ||
        (goal < start ? current <= goal : current >= goal);
    final fraction = reached
        ? 1.0
        : ((start - current) / (start - goal)).clamp(0.0, 1.0).toDouble();

    DateTime? eta;
    final rate = weeklyRate(weight);
    if (!reached && rate != null && rate.abs() >= 0.05) {
      final towardGoal = goal < current ? rate < 0 : rate > 0;
      if (towardGoal) {
        final weeks = (current - goal).abs() / rate.abs();
        // Más de 2 años no es una predicción útil.
        if (weeks <= 104) {
          eta = s.last.date.add(Duration(days: (weeks * 7).round()));
        }
      }
    }

    return GoalProgress(
      start: start,
      current: current,
      goal: goal,
      fraction: fraction,
      reached: reached,
      eta: eta,
    );
  }

  /// Resumen en palabras ("Has bajado 1.2 kg en 3 semanas") para quien no
  /// quiere leer gráficas. Null si no hay mediciones.
  ({String title, String detail})? summary(double? goal) {
    final s = series(ProgressMetric.all.first);
    if (s.isEmpty) return null;
    String kg(double v) => '${v.abs().toStringAsFixed(1)} kg';

    if (s.length == 1) {
      return (
        title: 'Tu punto de partida: ${kg(s.first.value)}',
        detail: 'Vuelve a medirte en una semana, a la misma hora y antes de desayunar, '
            'para empezar a ver tu avance.',
      );
    }

    final delta = s.last.value - s.first.value;
    final days = s.last.date.difference(s.first.date).inDays;
    final weeks = (days / 7).round();
    final span = days >= 14
        ? 'en $weeks semanas'
        : days <= 1
            ? 'desde tu primera medición'
            : 'en $days días';
    final title = delta <= -0.05
        ? 'Has bajado ${kg(delta)} $span'
        : delta >= 0.05
            ? 'Has subido ${kg(delta)} $span'
            : 'Tu peso se ha mantenido $span';

    if (goal == null) {
      return (title: title, detail: 'Define una meta de peso para saber si vas por buen camino.');
    }
    final g = weightGoal(goal)!;
    if (g.reached) {
      return (title: title, detail: '¡Llegaste a tu meta de ${kg(goal)}! Puedes definir una nueva.');
    }
    final rate = weeklyRate(ProgressMetric.all.first);
    final towardGoal = g.losing ? delta < -0.05 : delta > 0.05;
    if (!towardGoal) {
      return (
        title: title,
        detail: 'Tu meta es ${g.losing ? 'bajar' : 'subir'} a ${kg(goal)}. Todavía no se nota el '
            'cambio: platica con tu entrenador sobre tu rutina y tu alimentación.',
      );
    }
    final remaining = 'Te faltan ${kg(g.remaining)} para tu meta.';
    if (g.losing && rate != null && rate < -1.0) {
      return (
        title: title,
        detail: '$remaining Vas rápido: bajar más de 1 kg por semana puede hacerte perder músculo.',
      );
    }
    return (title: title, detail: 'Vas por buen camino. $remaining');
  }

  /// ¿Este cambio es bueno? null = neutral (no hay criterio).
  static bool? isImprovement(ProgressMetric metric, double delta, {double? weightGoal, double? current}) {
    if (delta.abs() < 0.05) return null;
    var lowerIsBetter = metric.lowerIsBetter;
    if (metric.key == 'peso' && weightGoal != null && current != null) {
      lowerIsBetter = weightGoal < current;
    }
    if (lowerIsBetter == null) return null;
    return lowerIsBetter ? delta < 0 : delta > 0;
  }
}
