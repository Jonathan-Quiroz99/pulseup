import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/progress_insights.dart';

/// Gráfica de una medida en el tiempo, sin dependencias de charting. El eje
/// X respeta las fechas reales (dos mediciones con un mes de diferencia no
/// quedan pegadas como si fueran de días seguidos). [goal] dibuja una línea
/// punteada con la meta.
class MetricLineChart extends StatelessWidget {
  final List<MetricPoint> points;
  final String unit;
  final double? goal;
  final double height;

  const MetricLineChart({
    super.key,
    required this.points,
    required this.unit,
    this.goal,
    this.height = 170,
  });

  static const _months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

  static String _date(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return SizedBox(height: height);
    final values = [for (final p in points) p.value, ?goal];
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    return Semantics(
      label: '${points.length} registros, último ${points.last.value.toStringAsFixed(1)} $unit',
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 44,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(max.toStringAsFixed(1), style: AppTextStyles.label),
                      Text(min.toStringAsFixed(1), style: AppTextStyles.label),
                    ],
                  ),
                ),
                Expanded(
                  child: CustomPaint(
                    painter: _ChartPainter(points, goal, min, max),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_date(points.first.date), style: AppTextStyles.label),
                if (points.length > 1) Text(_date(points.last.date), style: AppTextStyles.label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<MetricPoint> points;
  final double? goal;
  final double min;
  final double max;

  _ChartPainter(this.points, this.goal, this.min, this.max);

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 6.0;
    final span = (max - min).abs() < 0.001 ? 1.0 : max - min;
    final t0 = points.first.date;
    final totalDays = points.last.date.difference(t0).inHours / 24.0;

    double x(MetricPoint p) => points.length == 1 || totalDays <= 0
        ? size.width / 2
        : pad + (p.date.difference(t0).inHours / 24.0) / totalDays * (size.width - 2 * pad);
    double y(double v) => pad + (1 - (v - min) / span) * (size.height - 2 * pad);

    final grid = Paint()
      ..color = AppColors.hairline
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final gy = pad + i / 3 * (size.height - 2 * pad);
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), grid);
    }

    if (goal != null) {
      final gy = y(goal!);
      final dash = Paint()
        ..color = AppColors.success
        ..strokeWidth = 1.5;
      for (var gx = 0.0; gx < size.width; gx += 10) {
        canvas.drawLine(Offset(gx, gy), Offset((gx + 5).clamp(0, size.width), gy), dash);
      }
    }

    final line = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    if (points.length > 1) {
      final path = Path()..moveTo(x(points.first), y(points.first.value));
      for (final p in points.skip(1)) {
        path.lineTo(x(p), y(p.value));
      }
      // Relleno suave bajo la línea.
      final fill = Path.from(path)
        ..lineTo(x(points.last), size.height)
        ..lineTo(x(points.first), size.height)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.accent.withValues(alpha: 0.25), AppColors.accent.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      );
      canvas.drawPath(path, line);
    }

    final dot = Paint()..color = AppColors.accent;
    final hole = Paint()..color = AppColors.surface;
    for (final p in points) {
      final c = Offset(x(p), y(p.value));
      canvas.drawCircle(c, 4, dot);
      canvas.drawCircle(c, 1.8, hole);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.points != points || old.goal != goal || old.min != min || old.max != max;
}
