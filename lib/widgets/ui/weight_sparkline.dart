import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Minimal weight trend line — no charting dependency. Pass values in
/// chronological order (oldest first). Handles the degenerate cases:
/// empty renders nothing, a single point renders a dot.
class WeightSparkline extends StatelessWidget {
  final List<double> values;
  final double height;

  const WeightSparkline({super.key, required this.values, this.height = 48});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    return Semantics(
      label: 'Tendencia de peso, ${values.length} registros, '
          'último ${values.last.toStringAsFixed(1)} kg',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _SparkPainter(values)),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> values;

  _SparkPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final span = (max - min).abs() < 0.001 ? 1.0 : max - min;

    double x(int i) => values.length == 1
        ? size.width / 2
        : i / (values.length - 1) * size.width;
    double y(double v) => size.height - ((v - min) / span) * size.height;

    final dot = Paint()..color = AppColors.accent;

    if (values.length == 1) {
      canvas.drawCircle(Offset(x(0), size.height / 2), 3, dot);
      return;
    }

    final path = Path()..moveTo(x(0), y(values.first));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(x(i), y(values[i]));
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(x(values.length - 1), y(values.last)),
      3,
      dot,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.values != values;
}
