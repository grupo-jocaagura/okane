import 'package:flutter/material.dart';

/// # WavyHeader
///
/// Fondo superior con caja y borde inferior ondulado generada con
/// Catmull-Rom → cúbicas Bezier. Totalmente parametrizable por porcentajes.
///
/// ## Parámetros clave
/// - [color]: color de relleno
/// - [cornerRadius]: radio de las esquinas superiores
/// - [topHeight]: alto de la “caja” antes de la onda
/// - [tension]: 0.0–1.0 (suavidad de la spline)
/// - [points]: lista de puntos de control (en % del ancho, y en px relativos al baseline)
///
/// El baseline de la onda es `topHeight`. Cada punto se define como:
/// `(xPercent, yOffset)`, donde `xPercent` ∈ [0..1] y `yOffset` es
/// cuánto sube/baja respecto al baseline (+ abajo, - arriba).
///
/// ---
/// ## Ejemplo de uso (MD)
/// ```dart
/// Widget build(BuildContext context) {
///   return SizedBox(
///     height: 260,
///     width: double.infinity,
///     child: CustomPaint(
///       painter: WavyHeaderPainter(
///         color: const Color(0xFFFFB087),
///         cornerRadius: 16,
///         topHeight: 190,
///         tension: 1.0,
///         points: <WavyPoint>[
///           // Empezamos en el borde derecho (1.0, 0), sube levemente,
///           // baja en el tercio izquierdo y vuelve a subir un poco al salir.
///           const WavyPoint(1.00, 0),      // borde derecho, baseline
///           const WavyPoint(0.70, -18),    // leve “crest” a la derecha
///           const WavyPoint(0.42, 46),     // “valley” principal
///           const WavyPoint(0.00, 28),     // sale por la izquierda más bajo
///         ],
///       ),
///     ),
///   );
/// }
/// ```
/// ---
class WavyHeaderPainter extends CustomPainter {
  WavyHeaderPainter({
    required this.color,
    this.cornerRadius = 20,
    this.topHeight = 200,
    this.tension = 1.0,
    List<WavyPoint>? points,
  }) : points =
           points ??
           const <WavyPoint>[
             WavyPoint(1.00, 0),
             WavyPoint(0.70, -16),
             WavyPoint(0.40, 48),
             WavyPoint(0.00, 24),
           ];

  final Color color;
  final double cornerRadius;
  final double topHeight;
  final double tension;
  final List<WavyPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;

    final double w = size.width;
    final double r = cornerRadius.clamp(0, 1000).toDouble();
    final double yBase = topHeight;

    final Path path = Path()
      ..moveTo(r, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, yBase);

    // ---- Onda inferior con Catmull-Rom → cúbicas ----
    final List<Offset> pts = points
        .map(
          (WavyPoint point) => Offset(
            (point.xPercent.clamp(0.0, 1.0)) * w,
            yBase + point.yOffset,
          ),
        )
        .toList();

    if (pts.length >= 2) {
      final List<Offset> cr = <Offset>[pts.first, ...pts, pts.last];

      for (int i = 0; i < cr.length - 3; i++) {
        final Offset p0 = cr[i];
        final Offset p1 = cr[i + 1];
        final Offset p2 = cr[i + 2];
        final Offset p3 = cr[i + 3];

        // Catmull-Rom → Bezier (uniforme) con factor de tensión
        final double t = tension.clamp(0.0, 1.0);
        final Offset c1 = p1 + (p2 - p0) * (t / 6.0);
        final Offset c2 = p2 - (p3 - p1) * (t / 6.0);

        if (i == 0) {
          if ((path.getBounds().bottomRight - p1).distance > 0.5) {
            path.lineTo(p1.dx, p1.dy);
          }
        }
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
      }
    }

    // Subimos por la izquierda y cerramos con esquina superior izquierda
    path
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavyHeaderPainter oldDelegate) {
    return color != oldDelegate.color ||
        cornerRadius != oldDelegate.cornerRadius ||
        topHeight != oldDelegate.topHeight ||
        tension != oldDelegate.tension ||
        points != oldDelegate.points;
  }
}

class WavyPoint {
  const WavyPoint(this.xPercent, this.yOffset);
  final double xPercent; // 0..1 del ancho
  final double yOffset; // + debajo del baseline, - por encima
}
