import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class BarsPainter extends CustomPainter {
  BarsPainter({required this.graph});
  final ModelGraph graph;

  @override
  void paint(Canvas canvas, Size size) {
    const double padLeft = 24;
    const double padRight = 16;
    const double padTop = 8;
    const double padBottom = 40;

    final Rect plot = Rect.fromLTWH(
      padLeft,
      padTop,
      size.width - padLeft - padRight,
      size.height - padTop - padBottom,
    );

    // Ejes
    final Paint axis = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      axis,
    );
    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      axis,
    );

    final double xMin = graph.xAxis.min;
    final double xMax = graph.xAxis.max;
    const double yMin = 0; // anclamos a 0 para barras
    final double yMax = graph.yAxis.max <= 0 ? 1 : graph.yAxis.max;

    double sx(double x) => plot.left + (x - xMin) * plot.width / (xMax - xMin);
    double sy(double y) =>
        plot.bottom - (y - yMin) * plot.height / (yMax - yMin);

    // Barras (anchura calculada por número de puntos)
    final int n = graph.points.length;
    if (n == 0) {
      return;
    }

    final double band = plot.width / n;
    final double barWidth = band * 0.5;
    final Paint bar = Paint()..color = const Color(0xFFFFD54F);

    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < n; i++) {
      final ModelPoint p = graph.points[i];
      final double cx = sx(p.vector.dx);
      final double top = sy(max(0, p.vector.dy));
      final Rect r = Rect.fromCenter(
        center: Offset(cx, (top + plot.bottom) / 2),
        width: barWidth,
        height: (plot.bottom - top).abs(),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(8)),
        bar,
      );

      // Label de mes (debajo)
      tp.text = TextSpan(
        text: p.label,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      );
      tp.layout(maxWidth: band);
      tp.paint(canvas, Offset(cx - tp.width / 2, plot.bottom + 8));
    }

    // Ticks Y (4 marcas)
    final TextPainter ty = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    for (int i = 0; i <= 4; i++) {
      final double v = yMin + (i * (yMax - yMin) / 4.0);
      final double yy = sy(v);
      canvas.drawLine(Offset(plot.left - 4, yy), Offset(plot.left, yy), axis);

      ty.text = TextSpan(
        text: _fmtShortCop(v),
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      );
      ty.layout();
      ty.paint(canvas, Offset(plot.left - 6 - ty.width, yy - ty.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant BarsPainter oldDelegate) =>
      oldDelegate.graph != graph;

  String _fmtShortCop(double v) {
    if (v >= 1e6) {
      return '${(v / 1e6).toStringAsFixed(1)}M';
    }
    if (v >= 1e3) {
      return '${(v / 1e3).toStringAsFixed(0)}k';
    }
    return v.toStringAsFixed(0);
  }
}
