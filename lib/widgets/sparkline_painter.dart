import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class SparklineWidget extends StatelessWidget {
  const SparklineWidget({
    super.key,
    required this.values,
    required this.color,
    this.width = 84,
    this.height = 30,
  });

  final List<double> values;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(values: values, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    var min = values.reduce(math.min);
    var max = values.reduce(math.max);
    final span = (max - min).clamp(double.minPositive, double.infinity);
    min -= span * 0.15;
    max += span * 0.15;
    final adjustedSpan = max - min;

    double toX(int i) => i / (values.length - 1) * size.width;
    double toY(double v) => (1 - (v - min) / adjustedSpan) * size.height;

    final pts = List.generate(
      values.length,
      (i) => Offset(toX(i), toY(values[i])),
    );

    final path = _smoothPath(pts);

    // Gradient fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.25), color.withOpacity(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // End dot
    if (pts.isNotEmpty) {
      canvas.drawCircle(pts.last, 2.6, Paint()..color = color);
    }
  }

  Path _smoothPath(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;

      const t = 0.16;
      final c1 = Offset(
        p1.dx + (p2.dx - p0.dx) * t,
        p1.dy + (p2.dy - p0.dy) * t,
      );
      final c2 = Offset(
        p2.dx - (p3.dx - p1.dx) * t,
        p2.dy - (p3.dy - p1.dy) * t,
      );
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => values != old.values;
}
