import 'package:flutter/material.dart';

import 'painters/pie_painter.dart';

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({
    required this.totals,
    required this.colors,
    super.key,
    this.centerLabel,
    this.centerValue,
  });

  final Map<String, double> totals;
  final Map<String, Color> colors;
  final String? centerLabel;
  final String? centerValue;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PiePainter(
        totals: totals,
        colors: colors,
        centerLabel: centerLabel,
        centerValue: centerValue,
      ),
      child: const SizedBox.expand(),
    );
  }
}
