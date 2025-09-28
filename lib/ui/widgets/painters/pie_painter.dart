import 'package:flutter/material.dart';

class PiePainter extends CustomPainter {
  PiePainter({
    required this.totals,
    required this.colors,
    this.centerLabel,
    this.centerValue,
  });

  final Map<String, double> totals;
  final Map<String, Color> colors;
  final String? centerLabel;
  final String? centerValue;

  @override
  void paint(Canvas canvas, Size size) {
    final double total = totals.values.fold(0.0, (double a, double b) => a + b);
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double r = size.shortestSide * 0.38;

    if (total <= 0) {
      final Paint p = Paint()..color = Colors.pink.shade100;
      canvas.drawCircle(c, r, p);
      return;
    }

    double start = -90 * (3.14159 / 180);
    for (final MapEntry<String, double> e in totals.entries) {
      final double sweep = (e.value / total) * (2 * 3.14159);
      final Paint seg = Paint()
        ..color = colors[e.key] ?? Colors.grey
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        sweep,
        true,
        seg,
      );
      start += sweep;
    }

    // Centro
    final Paint hole = Paint()..color = Colors.white.withValues(alpha: 0.1);
    canvas.drawCircle(c, r * 0.55, hole);

    final TextPainter tp1 = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    if (centerLabel != null && centerLabel!.isNotEmpty) {
      tp1.text = TextSpan(
        text: centerLabel,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      );
      tp1.layout(maxWidth: r * 1.6);
      tp1.paint(canvas, Offset(c.dx - tp1.width / 2, c.dy - tp1.height - 2));
    }

    if (centerValue != null && centerValue!.isNotEmpty) {
      final TextPainter tp2 = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
          text: centerValue,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      )..layout(maxWidth: r * 1.6);
      tp2.paint(canvas, Offset(c.dx - tp2.width / 2, c.dy + 2));
    }
  }

  @override
  bool shouldRepaint(covariant PiePainter oldDelegate) {
    return oldDelegate.totals != totals;
  }
}
